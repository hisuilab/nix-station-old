# macOS セットアップ

## このガイドの範囲

| 管理対象 | 手段 | 補足 |
|---|---|---|
| macOS システム設定（Dock・Finder・入力など） | nix-darwin | システム全体の設定を Nix で宣言的に管理。`darwin-rebuild switch` で反映 |
| ユーザー環境（zsh・git・CLI ツール） | Home Manager | ユーザー単位のツール・設定ファイルを Nix で管理 |
| Homebrew バイナリのインストール | nix-homebrew | `darwin.homebrew.install = true` のホストのみ自動インストール |
| GUI / App Store アプリ | Brewfile（`brew bundle`） | `hosts/<host-id>/Brewfile` にまとめたアプリを一括インストール |

> [!NOTE]
> App Store アプリ（mas）は事前に App Store へのサインインが必要です。`setup.sh` 完了後にサインインして `brew bundle` を再実行してください。

## セットアップ

### 1. Nix をインストール

[Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer) を使用します。

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

インストール後、ターミナルを再起動してバージョンを確認します。

```bash
nix --version
```

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

起動するとホスト一覧が表示されるので番号で選択します。ユーザープロファイル入力・`darwin-rebuild switch`・`brew bundle` まで自動で実行します。

> [!TIP]
> 引数で直接指定することもできます: `bash setup.sh mac-mini`

> [!NOTE]
> スクリプト完了後はターミナルを再起動し、`direnv allow` を実行してください。→ [direnv の設定](../nix/direnv.md)

## 設定の適用

日常的な設定変更は `darwin-rebuild switch` で反映します（`setup.sh` は初回のみ）。

```bash
darwin-rebuild switch --flake path:.#<host-id>
```

> [!TIP]
> 設定適用後は Mac を再起動するとすべての変更が確実に反映されます。

> [!WARNING]
> **初回のみ（Determinate Nix 使用時）**: インストーラーが作成した `/etc/zshenv` が nix-darwin と競合します。初回 `darwin-rebuild switch` の前に実行してください:
> ```bash
> sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin
> ```

### Homebrew（Brewfile）の適用

```bash
brew bundle --file hosts/common/Brewfile
brew bundle --file hosts/<host-id>/Brewfile
```

> [!NOTE]
> **Dock の完全適用**: `darwin-rebuild switch` 実行時点で brew アプリが未インストールの場合、Dock へのアプリ追加がスキップされます。`brew bundle` 完了後に再度 `darwin-rebuild switch` を実行してください。

## Post-Setup

セットアップ完了後、GitHub との SSH 接続を設定します。詳細な手順は [../github-ssh.md](../github-ssh.md) を参照してください。
