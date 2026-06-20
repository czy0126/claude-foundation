# .claude-foundation — Claude Code Work Environment Toolkit

> A folder, three layers. Reusable Claude Code work environment for any project.
> **v0.5.0**

[![Version](https://img.shields.io/badge/version-v0.5.0-blue)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

**Read this in other languages:** [简体中文](README.zh-CN.md)

---

## Why?

Claude Code is powerful out of the box — but also **dangerously unguarded**. Three problems every team hits within the first week:

| # | Problem | Real impact |
|---|---------|-------------|
| 1 | **No safety net** | `rm -rf` goes through. `.env` gets read. One hallucinated command = real damage. |
| 2 | **LLMs fool themselves** | 35-50% of wrong code is delivered with high confidence. Without systematic defense, you ship bugs you didn't know you wrote. |
| 3 | **Reinventing setup** | Every project writes the same CLAUDE.md from scratch. Same hooks. Same rules. Same mistakes. |

**.claude-foundation** gives you a battle-tested baseline in one command. Not a framework — a **foundation**. You own it, you modify it, it adapts to your project.

---

## Quick Start

```bash
# One-click install
bash .claude-foundation/install.sh --with-hooks --with-rules --with-settings

# Or minimal install: 1 file, instant effect
cp .claude-foundation/GLOBAL-CLAUDE.md ~/.claude/CLAUDE.md
```

---

## Before / After

| Scenario | Bare Claude Code | With .claude-foundation |
|----------|-----------------|------------------------|
| LLM tries `rm -rf /tmp/*` | ⚠️ Executes immediately | 🛡️ Blocked — hook denies with reason |
| LLM tries to read `.env` | ⚠️ Succeeds silently | 🛡️ Blocked — path component match |
| User says "optimize it" | ⚠️ Edits vaguely, may break things | 🧠 /clarify diagnoses → suggests → rewrites |
| Project has no CLAUDE.md | ⚠️ No rules, no guardrails | ✅ /preflight scans env → generates resource registry |
| New teammate joins | ⚠️ "Read the channel history" | ✅ One install.sh, same baseline across machines |
| After a long session | ⚠️ Context diluted, rules forgotten | 🔄 PostCompact hook re-injects key constraints |

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

**Why two layers of security?** Static permissions (deny rules in settings.json) are the baseline — always active, zero latency. Dynamic hooks catch what static rules miss: variant commands, substring tricks, context-dependent patterns. Defense in depth.

---

## Design Philosophy

| Principle | What it means |
|-----------|---------------|
| **Ownership, not dependency** | Copy the files into your repo. No package manager, no update channel, no black box. You read the code, you change it, you own it. |
| **Layers, not monolith** | Foundation (always on), Tools (on demand), Guards (defense). Each layer works independently — use what you need, ignore the rest. |
| **Rules, not advice** | Every CLAUDE.md rule is backed by a quantified fact. "API hallucination: 34.7% of niche-library calls are fabricated" → "grep before assuming an API exists." No hand-waving. |
| **Bash + Python, nothing else** | Hooks use bash (jq preferred, python fallback). No Node.js, no Docker, no external services. Runs wherever Claude Code runs. |

---

## Bare Claude Code vs .claude-foundation

| Capability | Bare Claude Code | .claude-foundation |
|------------|-----------------|-------------------|
| Destructive command blocking | ❌ | ✅ `block-destructive.sh` |
| Sensitive file protection | ❌ | ✅ `protect-sensitive.sh` |
| Git context on startup | ❌ | ✅ `inject-git-context.sh` |
| Systematic LLM weakness defense | ❌ | ✅ 7 quantified rules in CLAUDE.md |
| Vague prompt handling | ❌ | ✅ `/clarify` auto-trigger |
| Cross-model review scaffold | ❌ | ✅ `/crosscheck` |
| Environment scanner | ❌ | ✅ `scan-environment.py` |
| Post-compact constraint re-injection | ❌ | ✅ PostCompact hook |
| One-command install | ❌ | ✅ `install.sh` |
| Windows-compatible | ⚠️ Partial | ✅ Tested on Windows 11 + Git Bash |

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

## FAQ

**Q: Do I need all components?**
No. The only required piece is `GLOBAL-CLAUDE.md` → `~/.claude/CLAUDE.md`. Everything else — hooks, commands, rules, settings — is optional and independent. Start minimal, add as you need.

**Q: Does this work on Windows?**
Yes. Tested on Windows 11 with Git Bash. Hooks use `jq` (preferred) with automatic `python` fallback. The only Windows-specific fix is `sys.stdout.reconfigure(encoding='utf-8')` in `scan-environment.py`.

**Q: Can I customize the hooks and rules?**
That's the point. Copy them into your project's `.claude/` directory and modify freely. The files are short (largest hook is 58 lines), readable bash — no framework magic.

**Q: How do I update after installing?**
Pull the latest from this repo, re-run `install.sh`. The script only adds files — it won't overwrite your customized hooks or settings unless you use `--force`. Check `CHANGELOG.md` to see what changed.

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
