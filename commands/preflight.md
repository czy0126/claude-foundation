---
name: preflight
description: 运行预检 + 自动生成资源注册表——前置条件检查 + 环境扫描，输出可直接填入 CLAUDE.md
---

# /preflight — 预检 + 资源注册表

请在开始工作前，完成以下检查和资源扫描。

## 第 1 步：环境检查

- Python 解释器路径和版本：运行 `python --version`，记录完整路径
- 关键包是否已安装：检查项目 CLAUDE.md 中列出的依赖
- Node.js（如适用）：`node --version`
- GPU（如适用）：`nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader`
- Git 状态：当前分支、未提交变更数、最近提交

## 第 2 步：数据和文件检查

- 必要的输入文件是否存在？（参照项目 CLAUDE.md 中的关键文件列表）
- 输出目录结构是否完整？
- 上一步产物的日期是否与预期一致？

## 第 3 步：资源注册表

根据以上检查结果，生成资源注册表，格式如下（可直接粘贴到项目 CLAUDE.md）：

```
## Python 环境
Python：<路径>  # Python <版本>

| 包名 | 版本 | 用途 |
|------|------|------|
| torch | 2.x | GPU 训练 |
| ... | ... | ... |

## GPU 环境（如有）
| 硬件 | 型号 | 显存 |
|------|------|------|
| GPU | RTX 3080 Ti | 17.2 GB |

CUDA 版本：<版本>

## Git
- 远程：<url>
- 分支：<branch>
- 最近提交：<hash> <msg>
- 未提交变更：<n> 个文件

## 关键目录
├── src/                  # *.py
├── tests/                # test_*.py
├── data/                 # *.csv, *.json

## 测试命令
pytest  # （从 pyproject.toml / Makefile / package.json 检测）
```

## 第 4 步：结论

输出：
- `PREFLIGHT_PASSED` — 所有前置条件满足，资源表已生成
- `PREFLIGHT_BLOCKED` — 列出阻塞项和缺失资源

## 快捷方式

如果项目目录中存在 `scan-environment.py`，优先运行它生成资源表（加 `--markdown` 参数）。
否则执行以上手动检查并生成资源表。
