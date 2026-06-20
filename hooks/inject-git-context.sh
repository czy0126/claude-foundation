#!/bin/bash
# inject-git-context.sh — SessionStart 钩子：git 状态 + 可用命令提示
# 用法：在 .claude/settings.json 的 SessionStart 中引用此脚本
# 依赖：无（优先用 jq，不可用时自动降级到 Python）

IS_GIT_REPO=$(git rev-parse --is-inside-work-tree 2>/dev/null || echo "false")

if [ "$IS_GIT_REPO" != "true" ]; then
  DATE_NOW="$(date '+%Y-%m-%d %H:%M')"
  export DATE_NOW
  python -c "import json,os;d=os.environ.get('DATE_NOW','?');print(json.dumps({'hookSpecificOutput':{'hookEventName':'SessionStart','additionalContext':f'非 git 仓库（未检测到 .git 目录）\\n当前时间: {d}\\n命令: /clarify /preflight /audit /crosscheck','sessionTitle':'非 git 仓库'}}))"
  exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "N/A")
CHANGES_COUNT=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
LAST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "N/A")
REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "N/A")

if command -v jq >/dev/null 2>&1; then
  jq -n \
    --arg branch "$BRANCH" \
    --arg changes "$CHANGES_COUNT" \
    --arg commit "$LAST_COMMIT" \
    --arg repo "$REPO" \
    --arg date "$(date '+%Y-%m-%d %H:%M')" \
    '{
      hookSpecificOutput: {
        hookEventName: "SessionStart",
        additionalContext: (
          "仓库: \($repo)\n" +
          "分支: \($branch)\n" +
          "未提交变更: \($changes) 个文件\n" +
          "最近提交: \($commit)\n" +
          "当前时间: \($date)\n" +
          "命令: /clarify /preflight /audit /crosscheck"
        ),
        sessionTitle: "\($repo) - \($branch)"
      }
    }'
else
  export REPO BRANCH CHANGES_COUNT LAST_COMMIT
  DATE_NOW="$(date '+%Y-%m-%d %H:%M')"
  export DATE_NOW
  python -c "import json,os;r=os.environ.get('REPO','?');b=os.environ.get('BRANCH','?');c=os.environ.get('CHANGES_COUNT','0');l=os.environ.get('LAST_COMMIT','?');d=os.environ.get('DATE_NOW','?');print(json.dumps({'hookSpecificOutput':{'hookEventName':'SessionStart','additionalContext':f'仓库: {r}\\n分支: {b}\\n未提交变更: {c} 个文件\\n最近提交: {l}\\n当前时间: {d}\\n命令: /clarify /preflight /audit /crosscheck','sessionTitle':f'{r} - {b}'}}))"
fi
