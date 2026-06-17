#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# nix-station セットアップスクリプト
# 対応: macOS (nix-darwin) / Linux (Home Manager standalone)
# ---------------------------------------------------------------------------

HOST_ID="${1:-}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_EMAIL=""

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

setup_user_profile() {
  local host_config="${REPO_DIR}/hosts/${HOST_ID}/config.nix"

  # userProfile.name を取得（BSD sed は \s 非対応のため awk で抽出）
  local profile_name
  profile_name=$(awk -F'"' '/userProfile[.]name/{print $2}' "$host_config")

  if [[ "$profile_name" != "guest" ]]; then
    local profile_file="${REPO_DIR}/user-profiles/${profile_name}.nix"
    if [[ -f "$profile_file" ]]; then
      info "ユーザープロファイル '${profile_name}' を確認しました。"
      PROFILE_EMAIL=$(awk -F'"' '/userEmail/{print $2}' "$profile_file")
      return
    fi
    warn "user-profiles/${profile_name}.nix が見つかりません。新規作成します。"
  else
    echo ""
    echo "userProfile.name が 'guest' のままです。セットアップウィザードを開始します。"
    echo ""
  fi

  # 対話入力
  read -rp "username（macOS のログインユーザー名）: " username
  while [[ -z "$username" || "$username" == "guest" ]]; do
    echo "  有効な username を入力してください（'guest' は使用できません）"
    read -rp "username: " username
  done

  read -rp "Git 表示名（例: hisuilab）: " git_name
  while [[ -z "$git_name" ]]; do
    read -rp "Git 表示名: " git_name
  done

  read -rp "Git メールアドレス: " git_email
  while [[ -z "$git_email" ]]; do
    read -rp "Git メールアドレス: " git_email
  done
  PROFILE_EMAIL="$git_email"

  # プロファイルファイル生成
  local profile_file="${REPO_DIR}/user-profiles/${username}.nix"
  cat > "$profile_file" <<EOF
{
  username = "${username}";
  git = {
    userName = "${git_name}";
    userEmail = "${git_email}";
  };
}
EOF
  info "user-profiles/${username}.nix を作成しました。"

  # hosts/<host-id>/config.nix の userProfile.name を更新
  sed -i '' "s/userProfile\.name = \".*\"/userProfile.name = \"${username}\"/" "$host_config"
  info "hosts/${HOST_ID}/config.nix の userProfile.name を '${username}' に更新しました。"
  echo ""
}

confirm_setup() {
  local host_config="${REPO_DIR}/hosts/${HOST_ID}/config.nix"
  local profile_name
  profile_name=$(awk -F'"' '/userProfile[.]name/{print $2}' "$host_config")

  echo ""
  echo "============================================================"
  echo " 適用内容の確認"
  echo "   host    : ${HOST_ID}"
  echo "   user    : ${profile_name}"
  echo "   email   : ${PROFILE_EMAIL}"
  echo "============================================================"
  echo ""
  read -rp "この内容で続行しますか？ [y/N]: " answer
  case "$answer" in
    [yY]|[yY][eE][sS]) echo "" ;;
    *) echo "中止しました。"; exit 0 ;;
  esac
}

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

  setup_user_profile
  confirm_setup
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
  echo "  2. SSH キーを設定:"
  echo "       ssh-keygen -t ed25519 -C \"${PROFILE_EMAIL}\" -f ~/.ssh/github_ed25519"
  echo "  3. GitHub 認証: gh auth login"
}

# --- Linux ------------------------------------------------------------------

setup_linux() {
  info "=== Linux セットアップ開始 (host: $HOST_ID) ==="

  setup_user_profile
  confirm_setup
  info "home-manager switch を実行します..."
  nix run github:nix-community/home-manager/release-25.05 -- \
    switch --flake "path:${REPO_DIR}#${HOST_ID}"

  info "=== Linux セットアップ完了 ==="
  echo ""
  echo "次のステップ:"
  echo "  1. SSH キーを設定:"
  echo "       ssh-keygen -t ed25519 -C \"${PROFILE_EMAIL}\" -f ~/.ssh/github_ed25519"
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
