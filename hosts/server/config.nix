{ ... }:

{
  # ホストのメタデータ（M4 Mac mini サーバー想定）
  meta = {
    hostname = "server";
    system = "aarch64-darwin"; # アーキテクチャ構成
    os = "macOS"; # モジュール分流用
  };

  # マシンに紐付けるユーザープロファイル
  userProfile = {
    name = "guest";
  };

  # 各パッケージの有効化フラグ（初期ビルドを通すため一度すべてfalse）
  packages = {
    devbox = false;
    ghostty = false;
    git = false;
    homebrew = false;
    vim = false;
    zed = false;
    zsh = false;
  };

  # シークレット処理（秘密ファイルがないCI環境等では空セットにフォールバック）
  secrets =
    let
      secretPath = ./secrets/secret.nix;
    in
    if builtins.pathExists secretPath then
      import secretPath
    else
      { };
}
