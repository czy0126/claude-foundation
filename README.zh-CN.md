<!-- Translated from README.md at v0.5.0, 2026-06-20 -->

# .claude-foundation — Claude Code 工作根基

> 一个文件夹，三层结构。适用于任何项目的可复用 Claude Code 工作环境。
> **v0.5.0**

[![Version](https://img.shields.io/badge/version-v0.5.0-blue)](CHANGELOG.zh-CN.md)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

**其他语言版本:** [English](README.md)

---

## 为什么需要？

Claude Code 开箱强大——但同时也**危险地缺乏防护**。每个团队在第一周都会撞上三个问题：

| # | 问题 | 实际后果 |
|---|------|---------|
| 1 | **没有安全网** | `rm -rf` 直接执行。`.env` 被读取。一次幻觉命令 = 真实损失。 |
| 2 | **LLM 欺骗自己** | 35-50% 的错误代码被高置信度交付。没有系统防御，你会在不知情中发布 bug。 |
| 3 | **重复造轮子** | 每个项目从零写 CLAUDE.md。同样的钩子。同样的规则。同样的错误。 |

**.claude-foundation** 一行命令给你一套经过实战检验的基线。不是框架——是**根基**。你拥有它，你修改它，它适配你的项目。

---

## 快速开始

```bash
# 一键安装
bash .claude-foundation/install.sh --with-hooks --with-rules --with-settings

# 或最小安装：1 个文件，立即生效
cp .claude-foundation/GLOBAL-CLAUDE.md ~/.claude/CLAUDE.md
```

---

## 使用前后对比

| 场景 | 裸 Claude Code | 使用 .claude-foundation |
|------|---------------|------------------------|
| LLM 尝试 `rm -rf /tmp/*` | ⚠️ 直接执行 | 🛡️ 被拦截——钩子输出拒绝理由 |
| LLM 尝试读取 `.env` | ⚠️ 静默成功 | 🛡️ 被拦截——路径组件精确匹配 |
| 用户说"优化一下" | ⚠️ 模糊修改，可能引入 bug | 🧠 /clarify 诊断 → 建议 → 重写 |
| 项目无 CLAUDE.md | ⚠️ 无规则无护栏 | ✅ /preflight 扫描环境 → 生成资源注册表 |
| 新成员加入 | ⚠️ "翻聊天记录去" | ✅ 一个 install.sh，多台机器同一基线 |
| 长会话后 | ⚠️ 上下文稀释，约束遗忘 | 🔄 PostCompact 钩子重新注入关键约束 |

---

## 三层结构

### 根基层 🔴 — CLAUDE.md（77 行，每会话自动加载）

LLM 缺陷防御（7 项量化事实 + 硬规则）+ 需求澄清卡 + Plan→Do→Verify→Record 循环 + 跨模型审阅 + 提示词质量辅助（自动触发 + 6 个简略触发词）

### 工具层 🟡 — 4 个命令（按需加载）

| 命令 | 功能 |
|------|------|
| `/clarify` | 诊断 → 建议卡 → 追问(按需) → 重写 → 判断权 |
| `/preflight` | 环境检查 + 资源注册表生成 |
| `/audit` | 变更后完整性审计 |
| `/crosscheck` | 生成跨模型审阅提示 |

### 防护层 🟡 — 权限 + 钩子 + 规则

| 组件 | 内容 |
|------|------|
| `settings-template.json` | 静态 deny 规则 + PreToolUse/SessionStart/PostToolUse 钩子配置 + statusLine |
| `hooks/`（3 个） | block-destructive.sh / protect-sensitive.sh / inject-git-context.sh |
| `rules/`（4 个） | python-style / js-style / security / test-first（路径范围规则） |

**为什么需要两层安全？** 静态权限（settings.json 中的 deny 规则）是基线——始终生效，零延迟。动态钩子捕获静态规则遗漏的：变体命令、子串欺骗、上下文相关模式。纵深防御。

---

## 设计哲学

| 原则 | 含义 |
|------|------|
| **拥有权，非依赖** | 把文件复制进你的仓库。不用包管理器，没有更新渠道，没有黑盒。你读代码，你改代码，你拥有它。 |
| **分层，非单体** | 根基层（始终在线）、工具层（按需加载）、防护层（防御）。每层独立运作——用什么取什么，其余忽略。 |
| **规则，非建议** | 每条 CLAUDE.md 规则都有量化事实支撑。"API 幻觉：34.7% 的小众库调用是编造的" → "不确定就 grep 验证"。不说空话。 |
| **Bash + Python，别无其他** | 钩子用 bash（jq 优先，python 兜底）。不用 Node.js，不用 Docker，不需要外部服务。Claude Code 能跑的地方就能跑。 |

---

## 裸 Claude Code vs .claude-foundation

| 能力 | 裸 Claude Code | .claude-foundation |
|------|---------------|-------------------|
| 破坏性命令拦截 | ❌ | ✅ `block-destructive.sh` |
| 敏感文件保护 | ❌ | ✅ `protect-sensitive.sh` |
| 启动时 Git 上下文 | ❌ | ✅ `inject-git-context.sh` |
| 系统化 LLM 缺陷防御 | ❌ | ✅ CLAUDE.md 7 条量化规则 |
| 模糊 prompt 处理 | ❌ | ✅ `/clarify` 自动触发 |
| 跨模型审阅脚手架 | ❌ | ✅ `/crosscheck` |
| 环境扫描器 | ❌ | ✅ `scan-environment.py` |
| 压缩后关键约束重注入 | ❌ | ✅ PostCompact 钩子 |
| 一键安装 | ❌ | ✅ `install.sh` |
| Windows 兼容 | ⚠️ 部分 | ✅ Windows 11 + Git Bash 实测 |

---

## 文件夹结构

```
.claude-foundation/
├── README.md                      # ⭐ 项目首页（英文）
├── README.zh-CN.md                # ⭐ 项目首页（简体中文）
├── CHANGELOG.md                   # 版本变更记录（英文）
├── CHANGELOG.zh-CN.md             # 版本变更记录（简体中文）
├── GLOBAL-CLAUDE.md               # ⭐ 全局元规则 (77行)
├── project-template.md            # 项目 CLAUDE.md 模板
├── settings-template.json         # 权限 + 钩子 + 状态行
├── scan-environment.py            # 环境扫描脚本
├── install.sh                     # 安装脚本
├── prompt-craft.md                # 提示词工艺手册（参考）
├── verification-patterns.md       # 7 种验证模式（参考）
├── context-discipline.md          # 上下文管理（参考）
├── resource-registry-template.md  # 资源注册表模板（参考）
├── memory-templates/              # 会话交接 + 已知陷阱模板
├── hooks/                         # 3 个 bash 钩子
├── rules/                         # 4 个路径范围规则
└── commands/                      # 4 个命令
```

---

## 完整安装

```bash
# 全局（必须）
cp .claude-foundation/GLOBAL-CLAUDE.md ~/.claude/CLAUDE.md

# 项目（按需）
cp .claude-foundation/project-template.md ./CLAUDE.md
python .claude-foundation/scan-environment.py --markdown  # 自动填充资源表

# 可选组件
cp .claude-foundation/settings-template.json .claude/settings.json
cp -r .claude-foundation/hooks .claude/
cp -r .claude-foundation/commands .claude/
cp -r .claude-foundation/rules .claude/
```

---

## 常见问题

**Q: 我需要全部组件吗？**
不需要。唯一必须的是 `GLOBAL-CLAUDE.md` → `~/.claude/CLAUDE.md`。其余一切——钩子、命令、规则、设置——都是可选且独立的。从最小开始，按需添加。

**Q: Windows 能用吗？**
能。Windows 11 + Git Bash 实测通过。钩子优先用 `jq`，自动降级到 `python`。唯一 Windows 专属修复是 `scan-environment.py` 中的 `sys.stdout.reconfigure(encoding='utf-8')`。

**Q: 我能自定义钩子和规则吗？**
这就是目的。把它们复制到你项目的 `.claude/` 目录下自由修改。文件都很短（最大钩子 58 行），可读的 bash——没有框架黑魔法。

**Q: 安装后怎么更新？**
从本仓库 pull 最新版，重新运行 `install.sh`。脚本只添加文件——不会覆盖你自定义的钩子或设置，除非你用了 `--force`。查看 `CHANGELOG.md` 了解变更内容。

---

## 维护

- 每次有意义的变更后 → 更新 CLAUDE.md
- 每次发现新陷阱 → 添加到已知陷阱表，标注日期
- `/clear` 重置上下文；`/compact` 压缩会话

---

## 卸载

```bash
rm ~/.claude/CLAUDE.md
rm .claude/settings.json
rm -r .claude/hooks/
rm -r .claude/commands/
rm -r .claude/rules/
```

---

> **原则**：保持 CLAUDE.md 活着（持续更新），不是死模板。根据项目调整，不是教条。
