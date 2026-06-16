#!/usr/bin/env bash
# docs/ai/skills/*.md を元に .claude/skills/ と .agents/skills/ の wrapper を同期する
set -euo pipefail

repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
cd "$repo"

skills_src="$repo/docs/ai/skills"
claude_skills="$repo/.claude/skills"
agents_skills="$repo/.agents/skills"

for skill_file in "$skills_src"/*.md; do
  name=$(basename "$skill_file" .md)
  first_line=$(head -1 "$skill_file")
  description="${first_line#\# }"

  # .claude/skills/<name>/SKILL.md
  mkdir -p "$claude_skills/$name"
  target="$claude_skills/$name/SKILL.md"
  if [ ! -f "$target" ]; then
    cat > "$target" <<EOF
---
name: $name
description: $description
---

以下を読んで従ってください:

- docs/ai/skills/$name.md
- docs/ai/risk_policy.md
- docs/ai/protected_paths.txt
EOF
    echo "✓ 生成: $target"
  else
    echo "  スキップ (既存): $target"
  fi

  # .agents/skills/<name>/SKILL.md
  mkdir -p "$agents_skills/$name"
  target="$agents_skills/$name/SKILL.md"
  if [ ! -f "$target" ]; then
    cat > "$target" <<EOF
---
name: $name
description: $description
---

Read and follow:

- docs/ai/skills/$name.md
- docs/ai/risk_policy.md
- docs/ai/protected_paths.txt
EOF
    echo "✓ 生成: $target"
  else
    echo "  スキップ (既存): $target"
  fi
done

echo ""
echo "同期完了。新しいスキルは docs/ai/skills/ に追加後に再実行してください。"
