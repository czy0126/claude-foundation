#!/bin/bash
# protect-sensitive.sh — PreToolUse 钩子：保护敏感文件 (bash/WSL/macOS)
# 用法：在 .claude/settings.json 的 PreToolUse 中引用此脚本
# 退出码：0=允许，2=阻止
# lock 文件和 .gitignore 仅阻止 Edit/Write，允许 Read
# 依赖：jq（可选，不可用时自动降级到 Python）

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python -c "import json,sys;print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
FILE_PATH=$(echo "$INPUT" | python -c "import json,sys;print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")

[ -z "$FILE_PATH" ] && exit 0

# 完全保护：Read 和 Edit 都阻止（凭证、私钥、密钥文件）
FULL_PROTECTED=(
  ".env"
  ".env.local"
  ".env.production"
  "credentials"
  "private.key"
  "private-key"
  ".pem"
  "-key.json"
  "secrets"
)

# 仅阻止编辑：lock 文件、git 配置（允许 Read 以了解项目状态）
EDIT_PROTECTED=(
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
  "poetry.lock"
  "Pipfile.lock"
  ".gitignore"
  ".gitmodules"
)

for pattern in "${FULL_PROTECTED[@]}"; do
  # 用 "/pattern" 确保是路径边界匹配，避免 .env 误伤 my-env-config.py
  if [[ "$FILE_PATH" == *"/$pattern/"* || "$FILE_PATH" == *"/$pattern" || "$FILE_PATH" == "$pattern" || "$FILE_PATH" == "$pattern/"* ]]; then
    if command -v jq >/dev/null 2>&1; then
      jq -n --arg file "$FILE_PATH" --arg pattern "$pattern" '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: ("Protected file (read+edit blocked): \($file) matches \($pattern)")
        }
      }'
    else
      PROT_FILE="$FILE_PATH" PROT_PATTERN="$pattern" python -c "import json,os;f=os.environ.get('PROT_FILE','?');p=os.environ.get('PROT_PATTERN','?');print(json.dumps({'hookSpecificOutput':{'hookEventName':'PreToolUse','permissionDecision':'deny','permissionDecisionReason':f'Protected file (read+edit blocked): {f} matches {p}'}}))"
    fi
    exit 2
  fi
done

for pattern in "${EDIT_PROTECTED[@]}"; do
  if [[ "$FILE_PATH" == *"/$pattern/"* || "$FILE_PATH" == *"/$pattern" || "$FILE_PATH" == "$pattern" || "$FILE_PATH" == "$pattern/"* ]]; then
    if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]]; then
      if command -v jq >/dev/null 2>&1; then
        jq -n --arg file "$FILE_PATH" --arg pattern "$pattern" '{
          hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "deny",
            permissionDecisionReason: ("Protected file (edit blocked, read allowed): \($file) matches \($pattern)")
          }
        }'
      else
        PROT_FILE="$FILE_PATH" PROT_PATTERN="$pattern" python -c "import json,os;f=os.environ.get('PROT_FILE','?');p=os.environ.get('PROT_PATTERN','?');print(json.dumps({'hookSpecificOutput':{'hookEventName':'PreToolUse','permissionDecision':'deny','permissionDecisionReason':f'Protected file (edit blocked, read allowed): {f} matches {p}'}}))"
      fi
      exit 2
    fi
  fi
done

exit 0
