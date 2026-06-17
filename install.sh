#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# nix-station セットアップスクリプト
# 対応: macOS (nix-darwin) / Linux (Home Manager standalone)
# ---------------------------------------------------------------------------

HOST_ID="${1:-}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- ヘルパー ---------------------------------------------------------------

info()  { echo "[info]  $*"; }
warn()  { echo "[warn]  $*" >&2; }
error() { echo "[error] $*" >&2; exit 1; }

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux)  echo "linux"  ;;
    *)      error "未対応の OS: $(uname -s)" ;;
  esac
}

require_host_id() {
  if [[ -z "$HOST_ID" ]]; then
    echo "使用方法: $0 <host-id>"
    echo ""
    echo "登録済みホスト:"
    ls "$REPO_DIR/hosts/" | grep -v default.nix | sed 's|/||'
    exit 1
  fi
}

check_nix() {
  if ! command -v nix &>/dev/null; then
    error "Nix が見つかりません。Determinate Nix Installer でインストールしてください:
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
  fi
  info "Nix: $(nix --version)"
}

# --- macOS ------------------------------------------------------------------

darwin_prereqs() {
  # /etc/zshenv 競合解消（Determinate インストーラーが作成するファイル）
  if [[ -f /etc/zshenv && ! -f /etc/zshenv.before-nix-darwin ]]; then
    info "/etc/zshenv を退避します..."
    sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin
  fi
}

darwin_rebuild() {
  info "darwin-rebuild switch を実行します (host: $HOST_ID)..."
  sudo nix run github:LnL7/nix-darwin/nix-darwin-25.05#darwin-rebuild -- \
    switch --flake "path:${REPO_DIR}#${HOST_ID}"
}

brew_bundle() {
  info "brew bundle を実行します..."

  local common_brewfile="${REPO_DIR}/hosts/common/Brewfile"
  local host_brewfile="${REPO_DIR}/hosts/${HOST_ID}/Brewfile"

  if [[ -f "$common_brewfile" ]]; then
    /opt/homebrew/bin/brew bundle --file "$common_brewfile" || warn "common Brewfile の一部が失敗しました（mas 認証切れの可能性）"
  fi
  if [[ -f "$host_brewfile" ]]; then
    /opt/homebrew/bin/brew bundle --file "$host_brewfile" || warn "${HOST_ID} Brewfile の一部が失敗しました"
  fi
}

setup_darwin() {
  info "=== macOS セットアップ開始 (host: $HOST_ID) ==="

  darwin_prereqs

  # 1回目: Homebrew セットアップ + nix 設定適用
  darwin_rebuild

  # brew アプリのインストール
  brew_bundle

  # 2回目: brew アプリが揃った状態で Dock 等を完全適用
  info "Dock 設定を完全適用するため darwin-rebuild を再実行します..."
  darwin_rebuild

  info "=== macOS セットアップ完了 ==="
  echo ""
  echo "次のステップ:"
  echo "  1. App Store にサインインして brew bundle を再実行（mas アプリ）"
  echo "  2. SSH キーを設定: ssh-keygen -t ed25519"
  echo "  3. GitHub 認証: gh auth login"
}

# --- Linux ------------------------------------------------------------------

setup_linux() {
  info "=== Linux セットアップ開始 (host: $HOST_ID) ==="

  info "home-manager switch を実行します..."
  nix run github:nix-community/home-manager/release-25.05 -- \
    switch --flake "path:${REPO_DIR}#${HOST_ID}"

  info "=== Linux セットアップ完了 ==="
  echo ""
  echo "次のステップ:"
  echo "  1. SSH キーを設定: ssh-keygen -t ed25519"
  echo "  2. GitHub 認証: gh auth login"
}

# --- メイン -----------------------------------------------------------------

main() {
  require_host_id
  check_nix

  case "$(detect_os)" in
    darwin) setup_darwin ;;
    linux)  setup_linux  ;;
  esac
}

main "$@"
