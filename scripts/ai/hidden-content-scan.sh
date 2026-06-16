#!/usr/bin/env bash
# 隠しファイル・意図しないバイナリ・大きすぎるファイルを検出する
set -euo pipefail

repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
cd "$repo"

staged_files=$(git diff --staged --name-only 2>/dev/null || true)
if [ -z "$staged_files" ]; then
  exit 0
fi

found=0

for file in $staged_files; do
  [ -f "$file" ] || continue

  # ドットファイル（意図しない隠しファイル）
  basename=$(basename "$file")
  if [[ "$basename" == .* && "$file" != .claude/* && "$file" != .agents/* && "$file" != .codex/* && "$file" != .github/* && "$file" != .gitignore && "$file" != .envrc ]]; then
    echo "⚠️  隠しファイル: $file"
    found=1
  fi

  # 大きすぎるファイル（1MB 超）
  size=$(wc -c < "$file" 2>/dev/null || echo 0)
  if [ "$size" -gt 1048576 ]; then
    echo "⚠️  大きすぎるファイル (${size} bytes): $file"
    found=1
  fi

  # バイナリファイル
  if file "$file" | grep -qv text 2>/dev/null; then
    echo "⚠️  バイナリファイル: $file"
    found=1
  fi
done

if [ "$found" -eq 1 ]; then
  exit 1
fi

echo "✓ 隠しコンテンツスキャン: 問題なし"
