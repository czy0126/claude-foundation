# .claude-foundation — Claude Code 工作根基

> 一个文件夹，三层结构。适用于任何项目的可复用 Claude Code 工作环境。
> **v0.5.0**

## 开始

```bash
# 一键安装
bash .claude-foundation/install.sh --with-hooks --with-rules --with-settings

# 或最小安装：1 个文件，立即生效
cp .claude-foundation/GLOBAL-CLAUDE.md ~/.claude/CLAUDE.md
```

其他组件按需选用。

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

双层安全：静态许可兜底（deny 规则始终生效），动态钩子捕获变体（输出结构化拒绝理由）。

---

## 文件夹结构

```
.claude-foundation/
├── CHANGELOG.md                   # 版本变更记录
├── GLOBAL-CLAUDE.md              # ⭐ 全局元规则 (77行)
├── project-template.md           # 项目 CLAUDE.md 模板
├── settings-template.json        # 权限 + 钩子 + 状态行
├── scan-environment.py           # 环境扫描脚本
├── install.sh                    # 安装脚本
├── prompt-craft.md               # 提示词工艺手册（参考）
├── verification-patterns.md      # 7 种验证模式（参考）
├── context-discipline.md         # 上下文管理（参考）
├── resource-registry-template.md # 资源注册表模板（参考）
├── memory-templates/             # 会话交接 + 已知陷阱模板
├── hooks/                        # 3 个 bash 钩子
├── rules/                        # 4 个路径范围规则
└── commands/                     # 4 个命令
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
