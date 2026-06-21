#!/usr/bin/env bash
# Thin entrypoint for the nix-station Setup Wizard.
# Requires: Nix (https://nixos.org/download)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec nix run nixpkgs#python3 -- "$REPO_ROOT/scripts/service/wizard.py" "$@"
