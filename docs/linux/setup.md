# Linux セットアップ（Ubuntu / Ubuntu on WSL / Raspberry Pi OS / NixOS）

## このガイドの範囲

| 管理対象 | 手段 | 補足 |
|---|---|---|
| ユーザー環境（zsh・git・CLI ツール） | Home Manager | ユーザー単位のツール・設定ファイルを Nix で管理。`home-manager switch` で反映 |
| Docker CLI | Home Manager | CLI ツールのみ管理。daemon の起動・ユーザー権限はシステム側で別途設定が必要 |

> [!NOTE]
> システムレベルの設定・ホスト名変更・Docker daemon の起動とユーザー権限・Raspberry Pi OS のブートやネットワーク設定は管理対象外です。

## セットアップ

### 1. Nix をインストール

> [!NOTE]
> **NixOS をお使いの場合**: Nix はプリインストール済みです。このステップをスキップして[ステップ 2](#2-このリポジトリを取得) へ進んでください。

**Ubuntu / Raspberry Pi OS:**

[Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer) を使用します。

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

インストール後、ターミナルを再起動してバージョンを確認します。

```bash
nix --version
```

**NixOS:**

Nix はプリインストール済みです。バージョンを確認します。

```bash
nix --version
```

> [!TIP]
> WSL 上で NixOS を使う場合は [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) を参照してください。

### 2. このリポジトリを取得

**git clone を使う場合:**

```bash
git clone https://github.com/hisuilab/nix-station.git
cd nix-station
```

**ZIP でダウンロードする場合:**

```bash
# ダウンロードフォルダへ保存
curl -L https://github.com/hisuilab/nix-station/archive/refs/heads/main.zip \
  -o ~/Downloads/nix-station.zip

# ダウンロードフォルダへ移動して展開
cd ~/Downloads
unzip nix-station.zip
cd nix-station-main
```

### 3. セットアップスクリプトを実行

```bash
bash setup.sh
```

起動するとホスト一覧が表示されるので番号で選択します。ユーザープロファイル入力・`home-manager switch` まで自動で実行します。

> [!TIP]
> 引数で直接指定することもできます: `bash setup.sh ubuntu-wsl`

> [!NOTE]
> スクリプト完了後はターミナルを再起動し、`direnv allow` を実行してください。→ [direnv の設定](../nix/direnv.md)

## 設定の適用

日常的な設定変更は以下のコマンドで反映します（`setup.sh` は初回のみ）。

```bash
nix run github:nix-community/home-manager/release-25.05 -- \
  switch --flake path:.#<host-id>
```

> [!NOTE]
> CLI ツールは Home Manager（Nix）が管理します。Brewfile には含めません。

## Post-Setup

セットアップ完了後、GitHub との SSH 接続を設定します。詳細な手順は [../github-ssh.md](../github-ssh.md) を参照してください。
