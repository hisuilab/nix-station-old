# nix-station

[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![CI](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml/badge.svg)](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)


## 概要

Nix と nix-darwin を使い、ホスト・ユーザー・パッケージの設定を再現可能な形で管理するワークステーションです。
複数の PC・サーバーの設定をコードとして一元管理し、新しいマシンへ同じ環境を再現できます。

| OS | 管理方法 |
|---|---|
| macOS | nix-darwin + Home Manager |
| Linux（Ubuntu・WSL・Raspberry Pi OS・NixOS を含む） | standalone Home Manager |
| Windows | winget + PowerShell スクリプト |



## クイックセットアップ

Nix をインストールしてリポジトリを取得後、実行します（macOS・Linux）。

```bash
bash setup.sh
```

起動するとホスト一覧が表示されるので番号で選択します。ユーザープロファイル入力・`darwin-rebuild switch` / `home-manager switch`・`brew bundle` まで自動で実行します。

> [!TIP]
> 引数でホスト ID を直接指定することもできます: `bash setup.sh <host-id>`

詳細な手順・初回適用の注意事項は [OS ごとのガイドライン](#os-ごとのガイドライン) を参照してください。

## OS ごとのガイドライン

詳細な手順・初回適用の注意事項・Post-Setup は各ガイドを参照してください。

| OS | ガイド |
|---|---|
| macOS | [docs/mac/setup.md](docs/mac/setup.md) |
| Linux（Ubuntu・WSL・Raspberry Pi OS・NixOS を含む） | [docs/linux/setup.md](docs/linux/setup.md) |
| Windows | [docs/windows/setup.md](docs/windows/setup.md) |

> [!NOTE]
> Windows は `winget` による`WSL`を含む開発環境構築やアプリケーション一括インストールに対応しています。

## nix-station の使い方

### 設定の適用

`flake.nix` やモジュールを変更した後に設定を反映します。`<host-id>` は `hosts/` 以下のフォルダ名です。

**macOS:**

```bash
darwin-rebuild switch --flake path:.#<host-id>
```

Homebrew アプリ（Brewfile）を適用・更新する場合:

```bash
brew bundle --file hosts/common/Brewfile
brew bundle --file hosts/<host-id>/Brewfile
```

**Linux（Ubuntu・WSL・Raspberry Pi OS・NixOS を含む）:**

```bash
nix run github:nix-community/home-manager/release-25.05 -- \
  switch --flake path:.#<host-id>
```

### ドキュメント

- [ホスト設定](docs/nix/hosts.md) — platform・os・role ごとに適用内容を設定
- [ユーザープロファイル](docs/nix/user-profiles.md) — ユーザー名・Git 設定を管理（デフォルトで Git 追跡対象外）
- [direnv](docs/nix/direnv.md) — `direnv allow` による Nix flake 環境の自動読み込み
- [開発・検証](docs/DEVELOPMENT.md) — テスト・CI・コントリビューション

## License

[MIT License](LICENSE)
