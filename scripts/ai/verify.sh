#!/usr/bin/env bash
# 共通 verification — 実装前に必ず実行する
set -euo pipefail

repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
cd "$repo"

echo "=== nix flake check ==="
nix flake check path:. --no-build --all-systems
