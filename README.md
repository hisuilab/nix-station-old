# nix-station

[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![CI](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml/badge.svg)](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Nixとnix-darwinを使い、ホスト・ユーザー・パッケージの設定を再現可能な形で管理するためのワークステーション構成です。

macOSはnix-darwin、Ubuntu、Ubuntu on WSL、Raspberry Pi OSはstandalone Home Managerで管理します。Windowsはwinget + PowerShellスクリプトで管理します。

## Requirements

- Nix（Flakesを有効化）
- macOS、Ubuntu、Ubuntu on WSL、またはRaspberry Pi OS
- 任意: direnv / nix-direnv
- 任意: pre-commit

Nixがインストールされていない場合は[Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer)の使用を推奨します。インストール後、`~/.config/nix/nix.conf`に`experimental-features = nix-command flakes`を追加してFlakesを有効化してください。

## Setup（macOS）

1. [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer) で Nix をインストールします。

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. ターミナルを再起動して `nix` コマンドが使えることを確認します。

3. このリポジトリを取得します。

```bash
git clone https://github.com/hisuilab/nix-station.git
cd nix-station
```

4. セットアップスクリプトを実行します。ユーザープロファイルの入力・`darwin-rebuild switch`・`brew bundle` まで自動で行います。

```bash
bash install.sh <host-id>
```

登録済みの `<host-id>` は `hosts/` ディレクトリ以下のフォルダ名です（`macbook-air`、`mac-mini` など）。

> Homebrew バイナリの自動インストール有無は `hosts/<host-id>/config.nix` の `darwin.homebrew.install` で制御します（デフォルト: `true`）。

## Setup（Linux）

```bash
bash install.sh <host-id>
```

Ubuntu / Ubuntu on WSL / Raspberry Pi OS で standalone Home Manager を適用します。

## Quick Start（開発・検証）

Flake出力と全テストを評価します（ビルドは行いません）:

```bash
nix flake check path:. --no-build --all-systems
```

システム構成をビルドだけ行い、現在のmacOSへ適用しない場合:

```bash
nix build path:.#darwinConfigurations.mac-mini.system --no-link
```

<details>
<summary>手動適用コマンド（上級者向け）</summary>

macOS:

```bash
# 初回のみ: Determinate インストーラーが作成した /etc/zshenv を退避
sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin

sudo nix run github:LnL7/nix-darwin/nix-darwin-25.05#darwin-rebuild -- \
  switch --flake path:.#<host-id>

# brew アプリを適用
brew bundle --file hosts/common/Brewfile
brew bundle --file hosts/<host-id>/Brewfile

# Dock を完全適用するため再度 rebuild
sudo nix run github:LnL7/nix-darwin/nix-darwin-25.05#darwin-rebuild -- \
  switch --flake path:.#<host-id>
```

Ubuntu / Ubuntu on WSL / Raspberry Pi OS:

```bash
nix run github:nix-community/home-manager/release-25.05 -- \
  switch --flake path:.#<host-id>
```

</details>

CLIツールはHome Manager (nix) が管理します。Brewfileには含めません。

## Post-Setup（初回適用後）

### SSH キーの設定

`install.sh` 完了後、GitHub との SSH 接続を設定します。詳細な手順は [docs/github-ssh.md](docs/github-ssh.md) を参照してください。

## Windows セットアップ

Nix を使わず winget でパッケージを一括インストールします。Git 未インストールの新規 PC でも実行できます。

1. このリポジトリを GitHub から ZIP でダウンロードして展開します。
2. PowerShell を開き、展開したフォルダへ移動して実行します。

```powershell
PowerShell -ExecutionPolicy Bypass -File scripts\windows\setup.ps1
```

カテゴリを絞ってインストールする場合:

```powershell
PowerShell -ExecutionPolicy Bypass -File scripts\windows\setup.ps1 -Categories gaming,hardware
```

パッケージはカテゴリ別に管理しています:

| カテゴリ | ファイル | 内容 |
|---|---|---|
| ゲーム | [`hosts/windows-desktop/packages/gaming.json`](hosts/windows-desktop/packages/gaming.json) | Steam, Epic Games, OBS 等 |
| 開発環境 | [`hosts/windows-desktop/packages/dev.json`](hosts/windows-desktop/packages/dev.json) | WSL, Docker, VSCode, Tailscale 等 |
| ハードウェア | [`hosts/windows-desktop/packages/hardware.json`](hosts/windows-desktop/packages/hardware.json) | Logitech, Yamaha, Nvidia 等 |
| ブラウザ | [`hosts/windows-desktop/packages/browser.json`](hosts/windows-desktop/packages/browser.json) | Chrome, Brave |

セットアップ完了後、WSL を開いて Linux 環境を構築します:

```bash
bash install.sh ubuntu-wsl
```

## Hosts

管理対象hostは[`hosts/default.nix`](hosts/default.nix)へ登録します。

```text
hosts/
├── default.nix
├── mac-mini/config.nix
├── macbook-air/config.nix
├── raspberry-pi-5/config.nix
├── ubuntu-desktop/config.nix
└── ubuntu-wsl/config.nix
```

小文字kebab-caseのディレクトリ名をflake出力のhost IDとして使用します。`meta.hostname`はOS・ネットワーク上の端末名で、省略時はhost IDを使用します。

- `platform = "darwin"`: nix-darwinとHome Managerを生成
- `platform = "home-manager"`: Ubuntu・Raspberry Pi OS向けstandalone Home Managerを生成
- `os`: `darwin`、`ubuntu`、`raspberry-pi-os`からHome ManagerのOS固有設定を選択
- `environment`: `native`または`wsl`から実行環境固有の設定を選択
- `role`: `desktop`、`laptop`、`server`から用途別モジュールを選択

`platform = "darwin"`では`meta.hostname`をmacOSへ反映します。standalone Home ManagerはOSのhostnameを変更しないため、Linux hostの`meta.hostname`は識別用メタデータです。

Home Managerは有効なツールがない場合も常に生成されます。ツールフラグは省略可能で、未指定値は`false`として扱います。未登録のツール名を指定した場合は評価エラーになります。

OS固有のユーザー設定は`modules/home/platforms/<os>/`、WSLなど実行環境固有の設定は`modules/home/environments/<environment>/`、共通ツール設定は`modules/home/<tool>/`で管理します。

`role`は端末名ではなく用途を表します。例えば、デスクトップPCでも常時稼働サービスを中心に管理する場合は`server`を選択できます。

標準hostではGitHub CLI、Devbox、Claude Codeなどの汎用CLIツールをHome Managerで有効化します。macOS hostではDocker DesktopをHomebrew経由で導入し、Linux hostではDocker CLIをHome Managerで導入します。GitHub認証は適用後に`gh auth login`で行います。

## User Profiles

ホストが使用するプロファイルは各`hosts/<host-id>/config.nix`で選択します。

```nix
userProfile = {
  name = "guest";
};
```

この例では[`user-profiles/guest.nix`](user-profiles/guest.nix)が読み込まれます。別のプロファイルを使用する場合は、同名のファイルを`user-profiles/`へ追加します。

```text
userProfile.name = "test"
        ↓
user-profiles/test.nix
```

`guest.nix`とリポジトリテスト用の`test.nix`を除き、`user-profiles/*.nix`はデフォルトでGitのコミット対象外です。個人情報を含むプロファイルはローカルで作成し、各hostの`userProfile.name`を任意の名前へ変更してください。

チームで共有するプロファイルやCIで評価するプロファイルは、`.gitignore`へ例外を追加してGitで追跡します。Flake評価に含まれるファイルは入力方式とGitの追跡状態に影響されるため、共有・CI用途では追跡を必須とします。

プロファイルの形式:

```nix
{
  username = "example";
  description = "Optional description";
  git = {
    userName = "example";
    userEmail = "example@example.com";
  };
}
```

必須項目は`username`、`git.userName`、`git.userEmail`です。未定義、空文字、型不正、または指定ファイルが存在しない場合は評価エラーになります。`description`は省略できます。

Flakeは通常、Gitで追跡されているファイルを入力として評価します。純粋な`nix flake check`やCIで使用するプロファイルはGitへ追加してください。`.gitignore`対象のローカルプロファイルはCIには含まれません。必要に応じて追加してください。

## Tests

テストは機能単位で管理し、[`tests/default.nix`](tests/default.nix)から集約します。

```text
tests/
├── default.nix
├── host-config/
│   └── default.nix
├── home/
│   ├── default.nix
│   ├── integration.nix
│   ├── app-configs/
│   ├── cli-tools/
│   ├── environments/
│   ├── gh/
│   ├── git/
│   ├── platforms/
│   ├── roles/
│   └── zsh/
├── darwin/
│   ├── features/
│   └── integration.nix
└── user-profile/
    ├── default.nix
    └── fixtures/
```

全チェック:

```bash
nix flake check path:. --no-build --all-systems
```

user-profileを含むテストderivationを実際にビルドする場合:

```bash
nix build path:.#checks.aarch64-darwin.tests --no-link
```

## Directory Structure

```text
.
├── .github/workflows/  # GitHub Actions
├── docs/               # 開発ドキュメント
├── hosts/              # ホスト別設定
├── modules/            # OS・Home Manager・共通モジュール
├── tests/              # 機能単位の評価テスト
├── user-profiles/      # 選択可能なユーザープロファイル
├── flake.lock
└── flake.nix
```

開発手順と規約は[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md)を参照してください。

## License

[MIT License](LICENSE)
