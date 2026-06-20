# CHANGELOG

**Read this in other languages:** [简体中文](CHANGELOG.zh-CN.md)

## v0.5.0 (2026-06-20)

### Added
- Suggestion card mode: presents 2-3 feasible directions + rationale before follow-up questions
- 6 shorthand triggers (e.g. "help me prompt") auto-launch /clarify suggestion card mode
- /preflight extension: now auto-generates resource registry (Markdown format)
- install.sh script: automated install + dependency checks + smoke test

### Changed
- **Merged command**: /prompt-help merged into /clarify, command count 5→4
- **Removed dual mode**: /clarify no longer splits into concise/full, unified 5-step flow
- **README restructured**: "Ten Pillars" → "Three-Layer Architecture" (Foundation/Tool/Guard), 157→98 lines
- GLOBAL-CLAUDE.md trimmed from 122 to 76 lines
- Hook output command hint shortened from verbose description to `Commands: /clarify /preflight /audit /crosscheck`

### Removed
- `/prompt-help` command (merged into /clarify)
- `.ps1` hooks (`.sh` works directly in Windows Git Bash, no PowerShell copies needed)
- GLOBAL-CLAUDE.md §4 inline cross-model review template (simplified to `/crosscheck` command reference)

### Fixed
- README install commands: `{hooks,commands,rules}` brace expansion → individual cp lines (PowerShell compatible)
- block-destructive.sh: fatal stdin consumption bug where `INPUT=$(cat)` starved python parser
- settings-template.json PostToolUse inline hook: same stdin bug
- resource-registry-template.md: corrected "GLOBAL-CLAUDE.md section 1" → "project-template.md section 1"
- GLOBAL-CLAUDE.md §5: added `~/.claude/CLAUDE.md` to load order
- prompt-craft.md §12.6: removed stale dual-mode description
- scan-environment.py: garbled Chinese output on Windows GBK encoding
- context-discipline.md: removed nonexistent /btw and /context command references
- README uninstall commands: brace expansion → individual rm lines
- test-first.md: path scope expanded from `src/**/*.py` to `**/*.py`

### Architecture
- Three-layer architecture (Foundation/Tool/Guard) replaces Ten Pillars
- Project stats: 76 core rule lines + 4 commands + 3 hooks + 4 rules + 1 install script
