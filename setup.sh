#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# nix-station セットアップスクリプト
# 対応: macOS (nix-darwin) / Linux (Home Manager standalone)
# Windows: scripts/windows/setup.ps1 を使用してください
# ---------------------------------------------------------------------------

HOST_ID="${1:-}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_USERNAME=""
GIT_NAME=""
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

select_host_id() {
  if [[ -n "$HOST_ID" ]]; then
    return
  fi

  local hosts=()
  while IFS= read -r dir; do
    local platform
    platform=$(grep -m1 'platform\s*=' "$dir/config.nix" 2>/dev/null | grep -o '"[^"]*"' | tr -d '"') || true
    [[ -n "$platform" ]] && hosts+=("$(basename "$dir")")
  done < <(find "$REPO_DIR/hosts" -mindepth 1 -maxdepth 1 -type d | sort)

  if [[ ${#hosts[@]} -eq 0 ]]; then
    error "hosts/ にホストが登録されていません。"
  fi

  echo "登録済みホスト:"
  for i in "${!hosts[@]}"; do
    echo "  $((i+1)). ${hosts[$i]}"
  done
  echo ""

  local selection
  while true; do
    read -rp "ホストを番号で選択してください [1-${#hosts[@]}]: " selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#hosts[@]} )); then
      HOST_ID="${hosts[$((selection-1))]}"
      info "ホスト '${HOST_ID}' を選択しました。"
      echo ""
      break
    fi
    echo "  無効な選択です。1〜${#hosts[@]} の番号を入力してください。"
  done
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
      PROFILE_USERNAME="$profile_name"
      GIT_NAME=$(awk -F'"' '/userName/{print $2}' "$profile_file")
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
  PROFILE_USERNAME="$username"
  GIT_NAME="$git_name"
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
  perl -pi -e "s/userProfile\\.name = \".*\"/userProfile.name = \"${username}\"/" "$host_config"
  info "hosts/${HOST_ID}/config.nix の userProfile.name を '${username}' に更新しました。"
  echo ""
}

confirm_setup() {
  echo ""
  echo "============================================================"
  echo " 適用内容の確認"
  echo "   host          : ${HOST_ID}"
  echo "   username      : ${PROFILE_USERNAME}"
  echo "   git.userName  : ${GIT_NAME}"
  echo "   git.userEmail : ${PROFILE_EMAIL}"
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
  if ! command -v brew &>/dev/null; then
    warn "brew コマンドが見つかりません。Homebrew をインストールしてから brew bundle を手動で実行してください:"
    warn "  brew bundle --file hosts/common/Brewfile"
    warn "  brew bundle --file hosts/${HOST_ID}/Brewfile"
    return
  fi

  info "brew bundle を実行します..."

  local common_brewfile="${REPO_DIR}/hosts/common/Brewfile"
  local host_brewfile="${REPO_DIR}/hosts/${HOST_ID}/Brewfile"

  if [[ -f "$common_brewfile" ]]; then
    brew bundle --file "$common_brewfile" || warn "common Brewfile の一部が失敗しました（mas 認証切れの可能性）"
  fi
  if [[ -f "$host_brewfile" ]]; then
    brew bundle --file "$host_brewfile" || warn "${HOST_ID} Brewfile の一部が失敗しました"
  fi
}

setup_darwin() {
  info "=== macOS セットアップ開始 (host: $HOST_ID) ==="

  setup_user_profile
  confirm_setup
  darwin_prereqs

  # 1回目: Homebrew セットアップ + nix 設定適用
  darwin_rebuild

  # brew アプリのインストール（brewBundle = false の場合はスキップ）
  local host_config="${REPO_DIR}/hosts/${HOST_ID}/config.nix"
  local brew_bundle_flag
  brew_bundle_flag=$(grep -m1 'brewBundle\s*=' "$host_config" | grep -o 'true\|false' || echo "true")
  if [[ "$brew_bundle_flag" == "true" ]]; then
    brew_bundle
  else
    info "brewBundle = false のため brew bundle をスキップします"
  fi

  # 2回目: brew アプリが揃った状態で Dock 等を完全適用
  info "Dock 設定を完全適用するため darwin-rebuild を再実行します..."
  darwin_rebuild

  info "=== macOS セットアップ完了 ==="
  echo ""
  echo "次のステップ:"
  echo "  App Store にサインイン後、mas アプリを適用するために brew bundle を再実行してください:"
  echo "    brew bundle --file hosts/common/Brewfile"
  echo "    brew bundle --file hosts/${HOST_ID}/Brewfile"
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
}

# --- メイン -----------------------------------------------------------------

main() {
  select_host_id
  check_nix

  case "$(detect_os)" in
    darwin) setup_darwin ;;
    linux)  setup_linux  ;;
  esac
}

main "$@"
