#!/usr/bin/env bash
# PreToolUse hook — git commit 前に保護パスと秘密情報をチェックする
set -euo pipefail

input=$(cat 2>/dev/null || echo '{}')

# stdin の JSON から tool_input.command を取得し git commit かどうか確認
is_commit=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    cmd = d.get('tool_input', {}).get('command', '')
    print('yes' if 'git commit' in cmd else 'no')
except Exception:
    print('no')
" <<< "$input" 2>/dev/null || echo 'no')

if [ "$is_commit" != "yes" ]; then
  exit 0
fi

repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
cd "$repo"

bash scripts/ai/risk-check.sh
bash scripts/ai/secret-scan.sh
