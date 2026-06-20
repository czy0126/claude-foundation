# .claude-foundation — Claude Code Work Environment Toolkit

> A folder, three layers. Reusable Claude Code work environment for any project.
> **v0.5.0**

**Read this in other languages:** [简体中文](README.zh-CN.md)

## Getting Started

```bash
# One-click install
bash .claude-foundation/install.sh --with-hooks --with-rules --with-settings

# Or minimal install: 1 file, instant effect
cp .claude-foundation/GLOBAL-CLAUDE.md ~/.claude/CLAUDE.md
```

Other components are optional — pick what you need.

---

## Three-Layer Architecture

### Foundation Layer 🔴 — CLAUDE.md (77 lines, auto-loaded every session)

LLM weakness defense (7 quantified facts + hard rules) + Requirements clarification card + Plan→Do→Verify→Record cycle + Cross-model review + Prompt quality assistant (auto-trigger + 6 shorthand triggers)

### Tool Layer 🟡 — 4 Commands (loaded on demand)

| Command | Function |
|---------|----------|
| `/clarify` | Diagnose → Suggestion card → Follow-up (as needed) → Rewrite → User decides |
| `/preflight` | Environment check + Resource registry generation |
| `/audit` | Post-change integrity audit |
| `/crosscheck` | Generate cross-model review prompt |

### Guard Layer 🟡 — Permissions + Hooks + Rules

| Component | Contents |
|-----------|----------|
| `settings-template.json` | Static deny rules + PreToolUse/SessionStart/PostToolUse hook config + statusLine |
| `hooks/` (3 files) | block-destructive.sh / protect-sensitive.sh / inject-git-context.sh |
| `rules/` (4 files) | python-style / js-style / security / test-first (path-scoped rules) |

Dual-layer security: static permissions as baseline (deny rules always active), dynamic hooks catch variants (output structured deny reasons).

---

## Directory Structure

```
.claude-foundation/
├── README.md                      # ⭐ Project homepage (English)
├── README.zh-CN.md                # ⭐ Project homepage (Simplified Chinese)
├── CHANGELOG.md                   # Version history (English)
├── CHANGELOG.zh-CN.md             # Version history (Simplified Chinese)
├── GLOBAL-CLAUDE.md               # ⭐ Global meta-rules (77 lines)
├── project-template.md            # Project-level CLAUDE.md template
├── settings-template.json         # Permissions + hooks + status line
├── scan-environment.py            # Environment scanner script
├── install.sh                     # Install script
├── prompt-craft.md                # Prompt crafting handbook (reference)
├── verification-patterns.md       # 7 verification patterns (reference)
├── context-discipline.md          # Context management guide (reference)
├── resource-registry-template.md  # Resource registry template (reference)
├── memory-templates/              # Session handoff + known trap templates
├── hooks/                         # 3 bash hooks
├── rules/                         # 4 path-scoped rules
└── commands/                      # 4 slash commands
```

---

## Full Installation

```bash
# Global (required)
cp .claude-foundation/GLOBAL-CLAUDE.md ~/.claude/CLAUDE.md

# Project-level (as needed)
cp .claude-foundation/project-template.md ./CLAUDE.md
python .claude-foundation/scan-environment.py --markdown  # auto-fill resource registry

# Optional components
cp .claude-foundation/settings-template.json .claude/settings.json
cp -r .claude-foundation/hooks .claude/
cp -r .claude-foundation/commands .claude/
cp -r .claude-foundation/rules .claude/
```

---

## Maintenance

- After every meaningful change → update CLAUDE.md
- Every new trap discovered → add to known traps table with date
- `/clear` to reset context; `/compact` to compress session

---

## Uninstall

```bash
rm ~/.claude/CLAUDE.md
rm .claude/settings.json
rm -r .claude/hooks/
rm -r .claude/commands/
rm -r .claude/rules/
```

---

> **Principle**: Keep CLAUDE.md alive (continuously updated), not a dead template. Adapt to the project, not dogma.
