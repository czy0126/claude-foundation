#!/usr/bin/env python3
"""scan-environment.py — 自动发现项目资源，生成可直接填入 CLAUDE.md 的资源注册表。

用法：
    python scan-environment.py              # 终端查看完整报告
    python scan-environment.py --markdown   # 生成 Markdown 表格（直接复制到 CLAUDE.md）
    python scan-environment.py --json       # JSON 格式（供脚本消费）

发现项目：
    - Python 解释器路径、版本、关键包
    - Node.js 版本、包管理器、关键依赖
    - GPU 型号、显存、CUDA 版本
    - Git 远程地址、当前分支、最近提交
    - 项目目录结构（src/ tests/ data/ 等）
    - 数据库连接（从 .env 或配置文件推断）
    - 测试命令（从 Makefile / pyproject.toml / package.json 推断）

输出可直接复制到 project-template.md 的对应章节。
"""

import json
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

# Force UTF-8 output on Windows (prevents garbled Chinese in --markdown output)
if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass


def run(cmd: list[str], timeout: int = 10) -> str:
    """运行命令并返回 stdout，失败返回空字符串。"""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return result.stdout.strip()
    except Exception:
        return ""


def find_executable(name: str) -> str | None:
    """查找可执行文件的绝对路径。"""
    path = shutil.which(name)
    return str(Path(path).resolve()) if path else None


# ─── 1. Python 环境 ───────────────────────────────────────────────

class PythonScanner:
    @staticmethod
    def discover() -> dict:
        exe = find_executable("python") or find_executable("python3")
        version = ""
        if exe:
            version = run([exe, "--version"])
        packages = []
        if exe:
            # 优先 pip list --format json（pip >= 20.1），失败则降级到 human-readable
            raw = run([exe, "-m", "pip", "list", "--format", "json"], timeout=30)
            if not raw:
                raw = run([exe, "-m", "pip", "list"], timeout=30)
            if raw:
                try:
                    pkgs = json.loads(raw)
                    # 只保留常见的关键包
                    key_patterns = {
                        "torch", "tensorflow", "numpy", "pandas", "pytest",
                        "django", "flask", "fastapi", "sqlalchemy", "celery",
                        "requests", "httpx", "pydantic", "scipy", "scikit-learn",
                        "matplotlib", "plotly", "jupyter", "ipython",
                        "ruff", "black", "mypy", "pre-commit", "bandit",
                        "ansys", "pyfluent", "pyvista", "vtk",
                    }
                    for pkg in pkgs:
                        name = pkg.get("name", "").lower()
                        if any(k in name for k in key_patterns):
                            packages.append((pkg["name"], pkg["version"]))
                except (json.JSONDecodeError, AttributeError):
                    # Human-readable pip list fallback
                    for line in raw.split("\n"):
                        parts = line.split()
                        if len(parts) >= 2:
                            name = parts[0].lower()
                            if any(k in name for k in key_patterns):
                                packages.append((parts[0], parts[1]))

        # Conda fallback — if conda is available and pip list was empty
        if not packages:
            conda = find_executable("conda")
            if conda:
                raw = run([conda, "list", "--json"], timeout=30)
                if raw:
                    try:
                        pkgs = json.loads(raw)
                        for pkg in pkgs:
                            name = pkg.get("name", "").lower()
                            if any(k in name for k in key_patterns):
                                packages.append((pkg["name"], pkg.get("version", "")))
                    except json.JSONDecodeError:
                        pass
        return {
            "executable": exe or "NOT FOUND",
            "version": version,
            "packages": packages[:15],  # top 15
        }


# ─── 2. GPU 环境 ──────────────────────────────────────────────────

class GPUScanner:
    @staticmethod
    def discover() -> dict | None:
        nvidia_smi = find_executable("nvidia-smi")
        if not nvidia_smi:
            return None

        # Try CSV; if GPU name contains comma, fall back to space-delimited values
        output = run([nvidia_smi, "--query-gpu=name,memory.total,driver_version,cuda_version",
                      "--format=csv,noheader"], timeout=10)
        if not output:
            return None
        parts = output.split(", ")
        if len(parts) < 4:
            parts = output.split(",")
        if len(parts) >= 4:
            return {
                "name": parts[0].strip(),
                "memory": parts[1].strip(),
                "driver": parts[2].strip(),
                "cuda_version": parts[3].strip(),
            }
        return None


# ─── 3. Git 信息 ──────────────────────────────────────────────────

class GitScanner:
    @staticmethod
    def discover() -> dict | None:
        if not find_executable("git"):
            return None
        is_repo = run(["git", "rev-parse", "--is-inside-work-tree"])
        if is_repo != "true":
            return None
        remote = run(["git", "remote", "get-url", "origin"])
        branch = run(["git", "branch", "--show-current"])
        last_commit = run(["git", "log", "-1", "--format=%h %s"])
        changes = run(["git", "status", "--porcelain"])
        change_count = len([l for l in (changes or "").split("\n") if l.strip()])
        return {
            "remote": remote or "N/A",
            "branch": branch or "N/A",
            "last_commit": last_commit or "N/A",
            "uncommitted_changes": change_count,
        }


# ─── 4. Node.js 环境 ──────────────────────────────────────────────

class NodeScanner:
    @staticmethod
    def discover() -> dict | None:
        exe = find_executable("node")
        if not exe:
            return None
        version = run([exe, "--version"])
        npm = find_executable("npm")
        if npm:
            npm_v = run([npm, "--version"])
        else:
            npm_v = "N/A"
        return {
            "node_version": version,
            "npm_version": npm_v,
        }


# ─── 5. 目录结构 ─────────────────────────────────────────────────

class DirectoryScanner:
    @staticmethod
    def discover(base_dir: str = ".") -> dict:
        p = Path(base_dir)
        structure = {}
        for d in p.iterdir():
            if d.is_dir() and not d.name.startswith(".") and not d.name.startswith("_"):
                files = [f.suffix for f in d.iterdir() if f.is_file()][:3]
                file_hint = ", ".join(f"*{s}" for s in set(files)) if files else ""
                structure[d.name] = file_hint
        return structure


# ─── 6. 数据库连接 ────────────────────────────────────────────────

class DBScanner:
    @staticmethod
    def discover(base_dir: str = ".") -> list[dict]:
        connections = []
        # .env files
        for env_file in [".env", ".env.local", ".env.development"]:
            path = Path(base_dir) / env_file
            if not path.exists():
                continue
            content = path.read_text(encoding="utf-8", errors="ignore")
            for line in content.split("\n"):
                line = line.strip()
                if line.startswith("#") or "=" not in line:
                    continue
                key, val = line.split("=", 1)
                key_upper = key.upper()
                if "DATABASE_URL" in key_upper or "DB_" in key_upper:
                    db_type = DBScanner._guess_db(val)
                    # 只输出连接类型，不输出值（避免泄露凭证）
                    connections.append({"name": key, "type": db_type, "uri": "[已隐藏]"})
                elif "REDIS" in key_upper:
                    connections.append({"name": key, "type": "Redis", "uri": "[已隐藏]"})
        return connections

    @staticmethod
    def _guess_db(uri: str) -> str:
        if uri.startswith("postgres") or uri.startswith("postgresql"):
            return "PostgreSQL"
        if uri.startswith("mysql"):
            return "MySQL"
        if uri.startswith("sqlite"):
            return "SQLite"
        if uri.startswith("redis"):
            return "Redis"
        if uri.startswith("mongodb"):
            return "MongoDB"
        return "Database"


# ─── 7. 测试命令 ──────────────────────────────────────────────────

class TestCommandScanner:
    @staticmethod
    def discover(base_dir: str = ".") -> str | None:
        p = Path(base_dir)
        # pyproject.toml
        if (p / "pyproject.toml").exists():
            content = (p / "pyproject.toml").read_text()
            for line in content.split("\n"):
                stripped = line.strip()
                if stripped.startswith("[tool.pytest"):
                    return "pytest  # (来自 pyproject.toml [tool.pytest])"
            for line in content.split("\n"):
                if line.startswith("test") and "=" in line:
                    return line.strip()
        # Makefile
        if (p / "Makefile").exists():
            for line in (p / "Makefile").read_text().split("\n"):
                if line.startswith("test"):
                    return line.strip()
        # package.json
        if (p / "package.json").exists():
            try:
                pkg = json.loads((p / "package.json").read_text())
                scripts = pkg.get("scripts", {})
                if "test" in scripts:
                    return f'npm test  # → {scripts["test"]}'
            except json.JSONDecodeError:
                pass
        # Default guess
        if (p / "tests").exists() or (p / "test").exists():
            return "pytest  # 猜测（发现 tests/ 目录）"
        return None


# ─── 主函数 ───────────────────────────────────────────────────────

def scan(base_dir: str = ".") -> dict:
    return {
        "platform": {
            "os": platform.system(),
            "shell": os.environ.get("SHELL", os.environ.get("COMSPEC", "unknown")),
            "python_exe": sys.executable,
        },
        "python": PythonScanner.discover(),
        "node": NodeScanner.discover(),
        "gpu": GPUScanner.discover(),
        "git": GitScanner.discover(),
        "directories": DirectoryScanner.discover(base_dir),
        "databases": DBScanner.discover(base_dir),
        "test_command": TestCommandScanner.discover(base_dir),
    }


def format_markdown(data: dict) -> str:
    """生成可直接复制到 CLAUDE.md 的 Markdown。"""
    lines = []
    lines.append("<!-- 由 scan-environment.py 自动生成 -->\n")

    # Python
    py = data["python"]
    lines.append(f"## Python 环境\n")
    lines.append(f"```\nPython：{py['executable']}  # {py['version']}\n```\n")
    if py["packages"]:
        lines.append("| 包名 | 版本 | 用途 |")
        lines.append("|------|------|------|")
        for name, ver in py["packages"]:
            lines.append(f"| {name} | {ver} | |")
        lines.append("")

    # GPU
    if data["gpu"]:
        gpu = data["gpu"]
        lines.append("## GPU 环境\n")
        lines.append(f"| 硬件 | 型号 | 显存 |")
        lines.append(f"|------|------|------|")
        lines.append(f"| GPU | {gpu['name']} | {gpu['memory']} |")
        lines.append(f"\nCUDA 版本：{gpu['cuda_version']}\n")

    # Git
    if data["git"]:
        git = data["git"]
        lines.append("## Git\n")
        lines.append(f"- 远程：{git['remote']}")
        lines.append(f"- 分支：{git['branch']}")
        lines.append(f"- 最近提交：{git['last_commit']}")
        lines.append(f"- 未提交变更：{git['uncommitted_changes']} 个文件\n")

    # Node
    if data["node"]:
        nd = data["node"]
        lines.append("## Node.js\n")
        lines.append(f"- Node.js {nd['node_version']}")
        lines.append(f"- npm {nd['npm_version']}\n")

    # 目录
    if data["directories"]:
        lines.append("## 关键目录\n")
        lines.append("```")
        for name, hint in data["directories"].items():
            desc = hint if hint else ""
            lines.append(f"├── {name:20s}  # {desc}")
        lines.append("```\n")

    # 数据库
    if data["databases"]:
        lines.append("## 数据库\n")
        lines.append("| 名称 | 连接方式 | 类型 |")
        lines.append("|------|---------|------|")
        for db in data["databases"]:
            lines.append(f"| {db['name']} | {db['uri']} | {db['type']} |")
        lines.append("")

    # 测试
    if data["test_command"]:
        lines.append("## 测试命令\n")
        lines.append(f"```bash\n{data['test_command']}\n```\n")
    else:
        lines.append("## 测试命令\n")
        lines.append("```bash\n# 请手动填写\n```\n")

    return "\n".join(lines)


def main():
    import argparse
    parser = argparse.ArgumentParser(description="扫描项目环境，生成 CLAUDE.md 资源注册表")
    parser.add_argument("--dir", default=".", help="项目根目录（默认当前目录）")
    parser.add_argument("--markdown", action="store_true", help="输出 Markdown 格式")
    parser.add_argument("--json", action="store_true", help="输出 JSON 格式")
    args = parser.parse_args()

    data = scan(args.dir)

    if args.json:
        print(json.dumps(data, indent=2, ensure_ascii=False))
    elif args.markdown:
        print(format_markdown(data))
    else:
        # 人类可读
        print("=" * 60)
        print("  环境扫描报告 — 可直接填入 CLAUDE.md")
        print("=" * 60)
        print()
        print(format_markdown(data))
        print()
        print("提示：运行 python scan-environment.py --markdown > CLAUDE.md.section")
        print("      然后把内容粘贴到 CLAUDE.md 的对应章节。")


if __name__ == "__main__":
    main()
