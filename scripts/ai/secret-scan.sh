#!/usr/bin/env bash
# ステージ済みファイルから秘密情報のパターンを検出する
set -euo pipefail

repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
cd "$repo"

staged_files=$(git diff --staged --name-only 2>/dev/null || true)
if [ -z "$staged_files" ]; then
  echo "✓ ステージファイルなし"
  exit 0
fi

found=0
patterns=(
  'ghp_[A-Za-z0-9]{36}'         # GitHub personal access token
  'github_pat_[A-Za-z0-9_]{82}' # GitHub fine-grained token
  'sk-[A-Za-z0-9]{48}'          # OpenAI API key
  'xoxb-[0-9]+-[A-Za-z0-9]+'   # Slack bot token
  'ssh-rsa AAAA'                 # SSH private key header
  'BEGIN (RSA|EC|OPENSSH) PRIVATE KEY'
  'password\s*=\s*["\x27][^"\x27]{4,}'
  'secret\s*=\s*["\x27][^"\x27]{4,}'
)

for file in $staged_files; do
  [ -f "$file" ] || continue
  for pattern in "${patterns[@]}"; do
    if git diff --staged -- "$file" | grep -qE "$pattern"; then
      echo "⚠️  秘密情報の可能性: $file (pattern: $pattern)"
      found=1
    fi
  done
done

if [ "$found" -eq 1 ]; then
  echo "秘密情報が含まれている可能性があります。コミット前に確認してください。"
  exit 1
fi

echo "✓ 秘密情報スキャン: 問題なし"
