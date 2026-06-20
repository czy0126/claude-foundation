#!/bin/bash
# block-destructive.sh — PreToolUse 钩子：阻止破坏性命令 (bash/WSL/macOS)
# 用法：在 .claude/settings.json 的 PreToolUse 中引用此脚本
# 退出码：0=允许，2=阻止
# 依赖：无（优先用 jq，不可用时自动降级到 Python）

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python -c "import json,sys;print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")

DESTRUCTIVE_PATTERNS=(
  "rm -rf"
  "rm -r"
  "git push --force"
  "git push --delete"
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE"
  "chmod 777"
  "> /dev/sd"
  "mkfs."
  "dd if="
  "del /F /S"
)

# Standalone dangerous commands — require command-boundary match.
# These must appear as actual commands (at line start or after ;/&&/||/|),
# not as arguments to safe commands like echo/python -c.
STANDALONE_CMDS=(
  "shutdown"
  "reboot"
  "format C:"
)

block_cmd() {
  local matched="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg cmd "$COMMAND" --arg pattern "$matched" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: ("Destructive command blocked: \($pattern) matched in: \($cmd)")
      }
    }'
  else
    BLOCK_PATTERN="$matched" BLOCK_COMMAND="$COMMAND" python -c "
import json, os
p = os.environ.get('BLOCK_PATTERN','?')
c = os.environ.get('BLOCK_COMMAND','?')
print(json.dumps({
  'hookSpecificOutput': {
    'hookEventName': 'PreToolUse',
    'permissionDecision': 'deny',
    'permissionDecisionReason': f'Destructive command blocked: {p} matched in: {c}'
  }
}))
"
  fi
  exit 2
}

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    block_cmd "$pattern"
  fi
done

for cmd in "${STANDALONE_CMDS[@]}"; do
  # Match only when the word appears as a command (at start of line or after command separators)
  # Does NOT match when inside echo/printf/python string arguments
  if echo "$COMMAND" | grep -qiE "(^|[;&|]+[[:space:]]*)${cmd}([[:space:]]|$)"; then
    block_cmd "$cmd"
  fi
done

exit 0
