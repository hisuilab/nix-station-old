#!/usr/bin/env bash
set -euo pipefail

repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
cd "$repo"

bash scripts/ai/risk-check.sh
bash scripts/ai/secret-scan.sh
