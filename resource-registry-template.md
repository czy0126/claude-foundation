# 项目资源注册表模板

> **每个项目都应该有一个资源注册表。** 填好这张表 = Claude 不需要每次都问"Python 在哪？数据库怎么连？"
>
> 此模板对应 project-template.md 的第一节（项目资源注册表）。复制到具体项目的 CLAUDE.md 中填写。

---

## 快速自检清单

在开始让 Claude Code 工作之前，确保以下信息在 CLAUDE.md 中**有明确答案**：

- [ ] Python 解释器的**绝对路径**是什么？（不是 `conda activate`，是 `D:\...\python.exe`）
- [ ] 测试命令的**精确拼写**是什么？（含所有必要 flag）
- [ ] 哪些文件/目录**不能修改**？（自动生成的、第三方 vendor 的、敏感配置的）
- [ ] 哪些命令是**安全的可以允许**的？（构建、测试、lint、git status）
- [ ] 哪些命令是**必须阻止**的？（rm -rf、force push、生产环境操作）
- [ ] 项目有哪些**已知的奇怪之处**？（路径不能有空格、必须用某个工作目录、编码问题）
- [ ] 当前正在**做什么**？上次做到哪了？下一步是什么？

---

## 通用资源模板

### Python 项目

```markdown
## Python 环境

[绝对路径，如：D:\Anaconda_envs\envs\myenv\python.exe]   # Python [版本]

| 包名 | 版本 | 用途 |
|------|------|------|
| torch | [version] | GPU 深度学习 |
| pandas | [version] | 数据处理 |
| pytest | [version] | 测试框架 |
| ... | ... | ... |

依赖锁定文件：[environment.yml / pyproject.toml / requirements.txt]

## GPU 环境（如适用）

| 硬件 | 型号 | 显存 |
|------|------|------|
| GPU | [model，如：NVIDIA RTX 3080 Ti] | [VRAM，如：17.2 GB] |

CUDA 版本：[version]
```

### Node.js 项目

```markdown
## 运行时

Node.js [version] (via [nvm / fnm / system])
包管理器：[npm / yarn / pnpm]

| 关键依赖 | 版本 | 用途 |
|---------|------|------|
| ... | ... | ... |
```

### 数据库

```markdown
## 数据库

| 数据库 | 连接方式 | 备注 |
|--------|---------|------|
| PostgreSQL | `postgresql://localhost:5432/mydb` | 开发环境 |
| Redis | `redis://localhost:6379` | 缓存 |
| SQLite | `./data/app.db` | 本地开发 |
```

### 外部 API

```markdown
## 外部 API

| API | 认证方式 | 文档链接 |
|-----|---------|---------|
| Anthropic API | `$ANTHROPIC_API_KEY` | docs.anthropic.com |
| GitHub API | `gh auth` / `$GITHUB_TOKEN` | |
| ... | ... | ... |
```

---

## Windows 平台特殊注意事项

如果你在 Windows 上工作，以下信息对 Claude Code 至关重要：

```markdown
## Windows 环境注意事项

- Shell：[Git Bash / PowerShell / WSL2]
- 终端编码：[UTF-8 / GBK] — 如果中文出现乱码，先检查编码
- ANSYS/Fluent 路径：[D:\Program Files\ANSYS Inc\v241] — 注意空格处理
- 临时目录：使用 `tempfile.gettempdir()` 避免路径空格问题
- 路径约定：使用正斜杠 `/` 或原始字符串 `r"..."` 或双反斜杠 `\\`
```
