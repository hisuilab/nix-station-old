# nix-station

[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![CI](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml/badge.svg)](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Nixとnix-darwinを使い、ホスト・ユーザー・パッケージの設定を再現可能な形で管理するためのワークステーション構成です。

macOSはnix-darwin、Ubuntu、Ubuntu on WSL、Raspberry Pi OSはstandalone Home Managerで管理します。

## Requirements

- Nix（Flakesを有効化）
- macOS、Ubuntu、Ubuntu on WSL、またはRaspberry Pi OS
- 任意: direnv / nix-direnv
- 任意: pre-commit

## Quick Start

```bash
git clone https://github.com/hisuilab/nix-station.git
cd nix-station
nix flake check path:. --no-build --all-systems
```

システム構成をビルドだけ行い、現在のmacOSへ適用しない場合:

```bash
nix build path:.#darwinConfigurations.mac-mini.system --no-link
```

## Apply Configuration

適用前に、対象hostの`userProfile.name`を実際に利用するプロファイル名へ変更します。`guest`は評価・試用向けです。

macOS:

```bash
sudo nix run github:LnL7/nix-darwin/nix-darwin-24.11#darwin-rebuild -- \
  switch --flake path:.#mac-mini
```

Ubuntu:

```bash
nix run github:nix-community/home-manager/release-24.11 -- \
  switch --flake path:.#ubuntu-desktop
```

Ubuntu on WSL:

```bash
nix run github:nix-community/home-manager/release-24.11 -- \
  switch --flake path:.#ubuntu-wsl
```

Raspberry Pi OS:

```bash
nix run github:nix-community/home-manager/release-24.11 -- \
  switch --flake path:.#raspberry-pi-5
```

2回目以降も同じコマンドで更新します。Linux系hostではシステム全体ではなく、Home Managerが管理するユーザー環境だけを適用します。

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
│   ├── git/
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
