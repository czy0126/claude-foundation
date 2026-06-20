#!/bin/bash
# install.sh — .claude-foundation v0.5.0 安装脚本
# 用法: bash install.sh [--global-only] [--with-hooks] [--with-rules]

set -e

FOUNDATION_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_CONFIG="$HOME/.claude"

echo "==> .claude-foundation v0.5.0 安装"
echo

# ── 依赖检查 ──
echo "── 依赖检查 ──"
MISSING=""

if command -v python >/dev/null 2>&1; then
  echo "  ✓ python: $(python --version 2>&1)"
else
  echo "  ✗ python: NOT FOUND (hooks 需要 python 作为 JSON 解析器降级方案)"
  MISSING="$MISSING python"
fi

if command -v jq >/dev/null 2>&1; then
  echo "  ✓ jq: $(jq --version 2>&1)"
else
  echo "  ⚠ jq: NOT FOUND (hooks 会降级到 python 解析 JSON)"
fi

if command -v ruff >/dev/null 2>&1; then
  echo "  ✓ ruff: $(ruff --version 2>&1)"
else
  echo "  ⚠ ruff: NOT FOUND (安装后可自动 lint Python 文件；跳过)"
fi

if command -v git >/dev/null 2>&1; then
  echo "  ✓ git: $(git --version 2>&1)"
else
  echo "  ⚠ git: NOT FOUND (SessionStart 钩子状态注入不可用)"
fi

if [ -n "$MISSING" ]; then
  echo
  echo "  ❌ 缺少必要依赖:$MISSING"
  echo "  hooks 依赖 python 作为 JSON 解析降级方案，请先安装 python。"
  exit 1
fi
echo

# ── 全局安装（必须） ──
echo "── 全局安装 ──"
mkdir -p "$CLAUDE_CONFIG"
cp "$FOUNDATION_DIR/GLOBAL-CLAUDE.md" "$CLAUDE_CONFIG/CLAUDE.md"
echo "  ✓ GLOBAL-CLAUDE.md → ~/.claude/CLAUDE.md"

# ── 命令（推荐） ──
echo "── 安装命令 ──"
mkdir -p "$CLAUDE_CONFIG/commands"
for cmd in clarify preflight audit crosscheck; do
  cp "$FOUNDATION_DIR/commands/$cmd.md" "$CLAUDE_CONFIG/commands/$cmd.md"
  echo "  ✓ commands/$cmd.md"
done

# ── 钩子（可选） ──
if [ "${1:-}" = "--with-hooks" ] || [ "${2:-}" = "--with-hooks" ]; then
  echo "── 安装钩子 ──"
  mkdir -p "$CLAUDE_CONFIG/hooks"
  for hook in block-destructive protect-sensitive inject-git-context; do
    cp "$FOUNDATION_DIR/hooks/$hook.sh" "$CLAUDE_CONFIG/hooks/$hook.sh"
    chmod +x "$CLAUDE_CONFIG/hooks/$hook.sh"
    echo "  ✓ hooks/$hook.sh"
  done
else
  echo "  ⚠ 钩子未安装（使用 --with-hooks 启用）"
fi

# ── 规则（可选） ──
if [ "${1:-}" = "--with-rules" ] || [ "${2:-}" = "--with-rules" ] || [ "${3:-}" = "--with-rules" ]; then
  echo "── 安装规则 ──"
  mkdir -p "$CLAUDE_CONFIG/rules"
  for rule in python-style js-style security test-first; do
    cp "$FOUNDATION_DIR/rules/$rule.md" "$CLAUDE_CONFIG/rules/$rule.md"
    echo "  ✓ rules/$rule.md"
  done
else
  echo "  ⚠ 规则未安装（使用 --with-rules 启用）"
fi

# ── settings.json（可选） ──
if [ "${1:-}" = "--with-settings" ] || [ "${2:-}" = "--with-settings" ] || [ "${3:-}" = "--with-settings" ]; then
  echo "── 安装 settings.json ──"
  if [ -f "$CLAUDE_CONFIG/settings.json" ]; then
    echo "  ⚠ settings.json 已存在，备份到 settings.json.bak"
    cp "$CLAUDE_CONFIG/settings.json" "$CLAUDE_CONFIG/settings.json.bak"
  fi
  cp "$FOUNDATION_DIR/settings-template.json" "$CLAUDE_CONFIG/settings.json"
  echo "  ✓ settings.json"
  echo "  ⚠ 请编辑 ~/.claude/settings.json 中的 model 字段"
fi

# ── 验证 ──
echo
echo "── 安装验证 ──"
VERIFY_OK=true

# 检查 CLAUDE.md
if [ -f "$CLAUDE_CONFIG/CLAUDE.md" ]; then
  LINES=$(wc -l < "$CLAUDE_CONFIG/CLAUDE.md")
  echo "  ✓ ~/.claude/CLAUDE.md ($LINES lines)"
else
  echo "  ✗ ~/.claude/CLAUDE.md MISSING"
  VERIFY_OK=false
fi

# 检查命令
for cmd in clarify preflight audit crosscheck; do
  if [ -f "$CLAUDE_CONFIG/commands/$cmd.md" ]; then
    echo "  ✓ commands/$cmd.md"
  else
    echo "  ✗ commands/$cmd.md MISSING"
    VERIFY_OK=false
  fi
done

# 检查 hooks（如果安装了）
if [ -f "$CLAUDE_CONFIG/hooks/block-destructive.sh" ]; then
  # 快速冒烟测试：验证 block-destructive.sh 的 stdin bug 已修复
  RESULT=$(echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp/test"}}' | bash "$CLAUDE_CONFIG/hooks/block-destructive.sh" 2>&1)
  EXIT_CODE=$?
  if [ "$EXIT_CODE" = "2" ] && echo "$RESULT" | grep -q "deny"; then
    echo "  ✓ block-destructive.sh 冒烟测试通过（正确阻止 rm -rf）"
  else
    echo "  ✗ block-destructive.sh 冒烟测试失败（exit=$EXIT_CODE, expected 2）"
    VERIFY_OK=false
  fi
fi

echo
if [ "$VERIFY_OK" = true ]; then
  echo "✅ 安装完成，验证通过。"
else
  echo "❌ 安装完成，但有验证项失败，请检查上述 ✗ 项。"
fi

echo
echo "提示："
echo "  - 使用 /clarify 改进模糊的提示词"
echo "  - 使用 /preflight 生成项目的资源注册表"
echo "  - 使用 /audit 审计变更完整性"
echo "  - 使用 /crosscheck 生成跨模型审阅提示"
echo "  - 全局安装后，所有 Claude Code 会话都会自动加载 CLAUDE.md"
