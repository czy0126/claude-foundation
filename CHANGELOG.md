# CHANGELOG

## v0.5.0 (2026-06-20)

### 新增
- 建议卡模式：在追问之前先给使用者 2-3 个可行方向 + 推荐理由
- 6 个简略触发词（"帮我prompt"等）自动启动 /clarify 建议卡模式
- /preflight 扩展：现在自动生成资源注册表（Markdown 格式）
- install.sh 安装脚本：自动安装 + 依赖检查 + 冒烟测试

### 变更
- **合并命令**：/prompt-help 合并到 /clarify，命令数 5→4
- **移除双模式**：/clarify 不再区分精简/完整，统一为 5 步流程
- **README 重构**："十大支柱" → "三层结构"（根基层/工具层/防护层），157→98 行
- GLOBAL-CLAUDE.md 从 122 行精简到 76 行
- 钩子输出中的命令提示从冗长描述缩减为 `命令: /clarify /preflight /audit /crosscheck`

### 删除
- `/prompt-help` 命令（合并到 /clarify）
- `.ps1` 钩子（`.sh` 在 Windows Git Bash 直接可用，不需要 PowerShell 副本）
- GLOBAL-CLAUDE.md §四 内联跨模型审阅模板（简化为 `/crosscheck` 命令引用）

### 修复
- README 安装命令：`{hooks,commands,rules}` brace expansion → 逐行 cp（PowerShell 兼容）
- block-destructive.sh：修复 `INPUT=$(cat)` 消费 stdin 导致 python 解析器读到空串的致命 bug
- settings-template.json PostToolUse 内联钩子：同样的 stdin bug
- resource-registry-template.md：修正"GLOBAL-CLAUDE.md 第一节"错误引用 → "project-template.md 第一节"
- GLOBAL-CLAUDE.md §五：补全 `~/.claude/CLAUDE.md` 加载顺序
- prompt-craft.md §12.6：删除已不存在的双模式描述
- scan-environment.py：Windows GBK 编码下输出中文乱码
- context-discipline.md：删除不存在的 /btw 和 /context 命令引用
- README 卸载命令：brace expansion → 逐行 rm
- test-first.md：路径范围从 `src/**/*.py` 扩展为 `**/*.py`

### 架构
- 三层结构（根基层/工具层/防护层）替代十大支柱
- 项目统计：76 行核心规则 + 4 命令 + 3 钩子 + 4 规则 + 1 安装脚本
