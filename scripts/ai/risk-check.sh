#!/usr/bin/env bash
# protected_paths.txt に列挙されたパスへの変更を検出する
set -euo pipefail

repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
cd "$repo"

policy="$repo/docs/ai/protected_paths.txt"
staged=$(git diff --staged --name-only)

if [ -z "$staged" ]; then
  exit 0
fi

while IFS= read -r pattern; do
  # コメント・空行・除外パターンをスキップ
  [[ "$pattern" =~ ^#.*$ || -z "$pattern" || "$pattern" =~ ^! ]] && continue

  while IFS= read -r file; do
    if [[ "$file" == $pattern ]]; then
      echo "⚠️  保護パスへの変更を検出: $file"
      echo "   定義: $policy"
      echo "   ユーザーの明示的な承認を得てからコミットしてください。"
      exit 1
    fi
  done <<< "$staged"
done < "$policy"

echo "✓ 保護パスへの変更なし"
