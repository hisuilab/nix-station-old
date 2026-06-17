#!/usr/bin/env bash
# 共通 verification — 実装前に必ず実行する
set -euo pipefail

repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
cd "$repo"

# darwinConfigurations.* は hosts/*/config.nix の userProfile.name = "guest"（未設定ホスト）のため
# Nix 評価時に失敗するが、これは設計上の想定動作。
# CI で担保すべき検証は checks.* で行う。
# 詳細: docs/decisions/2026-06-16-issue-28-mac-mini-m4-fresh-setup.md

eval_check() {
  local attr="path:.#${1}"
  if nix eval "${attr}.drvPath" > /dev/null 2>&1; then
    echo "  ✓ ${1}"
  else
    echo "  ✗ ${1}"
    return 1
  fi
}

echo "=== checks.aarch64-darwin ==="
eval_check "checks.aarch64-darwin.tests"
eval_check "checks.aarch64-darwin.mac-mini"
eval_check "checks.aarch64-darwin.macbook-air"
eval_check "checks.aarch64-darwin.homeModulesEval"
eval_check "checks.aarch64-darwin.homeAppConfigsEval"
eval_check "checks.aarch64-darwin.darwinEnabledEval"
eval_check "checks.aarch64-darwin.darwinDisabledEval"
eval_check "checks.aarch64-darwin.darwinRoutingEval"
eval_check "checks.aarch64-darwin.darwinRoleRoutingEval"
eval_check "checks.aarch64-darwin.darwinHomebrewEval"

echo "=== checks.aarch64-linux ==="
eval_check "checks.aarch64-linux.raspberry-pi-5"

echo "=== checks.x86_64-linux ==="
eval_check "checks.x86_64-linux.ubuntu-desktop"
eval_check "checks.x86_64-linux.ubuntu-wsl"
