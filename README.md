# nix-station

[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![CI](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml/badge.svg)](https://github.com/hisuilab/nix-station/actions/workflows/ci.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Nixとnix-darwinを使い、ホスト・ユーザー・パッケージの設定を再現可能な形で管理するためのワークステーション構成です。

現在は、macOSサーバー構成の評価、ユーザープロファイルの選択と検証、GitHub Actionsによる`nix flake check`を中心に整備しています。

## Requirements

- Nix（Flakesを有効化）
- macOS（現在の主要な評価対象は`aarch64-darwin`）
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
nix build path:.#darwinConfigurations.server.system --no-link
```

## User Profiles

ホストが使用するプロファイルは[`hosts/server/config.nix`](hosts/server/config.nix)で選択します。

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
├── home/
│   ├── default.nix
│   ├── integration.nix
│   ├── git/
│   └── zsh/
├── macOS/
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
