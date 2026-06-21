# セットアップガイド

> [!IMPORTANT]
> この文書は初回導入の共通手順を所有します。OS固有の制約と日常的な再適用方法は、
> 対応するOS別ガイドを参照してください。

## 目次

- [1. 対応する導入経路](#1-対応する導入経路)
- [2. macOS・Linux・WSL](#2-macoslinuxwsl)
- [3. Windows](#3-windows)
- [4. セットアップ後](#4-セットアップ後)

## 1. 対応する導入経路

| 環境 | 初回入口 | OS固有ガイド |
|---|---|---|
| macOS | `setup.sh` | [`mac/setup.md`](mac/setup.md) |
| Linux | `setup.sh` | [`linux/setup.md`](linux/setup.md) |
| WSL | `setup.sh` | [`linux/setup.md`](linux/setup.md) |
| Windows本体 | `setup.ps1` | [`windows/setup.md`](windows/setup.md) |

## 2. macOS・Linux・WSL

### 2.1. Nixを手動で導入する

[Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer)の公式手順で
Nixをインストールします。NixOSではこの手順は不要です。

```bash
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install
```

ターミナルを再起動して確認します。

```bash
nix --version
```

### 2.2. リポジトリを取得する

Gitを使用する場合：

```bash
git clone https://github.com/hisuilab/nix-station.git
cd nix-station
```

ZIPを使用する場合：

```bash
curl -L https://github.com/hisuilab/nix-station/archive/refs/heads/main.zip \
  -o ~/Downloads/nix-station.zip
cd ~/Downloads
unzip nix-station.zip
cd nix-station-main
```

### 2.3. Setup Wizardを起動する

```bash
bash setup.sh
```

引数で現行Host IDを指定することもできます。

```bash
bash setup.sh <host-id>
```

Wizardの目標責任と将来の利用フローは
[`ユーザーワークフロー設計`](architecture/user-workflow.md)を参照してください。

## 3. Windows

Windows本体のアプリとWSL導入はPowerShellで行います。Windows固有の取得・実行手順は
[`Windowsセットアップ`](windows/setup.md)を参照してください。Nixによる環境構築は、
WSL内で[macOS・Linux・WSLの共通手順](#2-macoslinuxwsl)を実行します。

## 4. セットアップ後

- OS固有の再適用方法は、対象のOS別ガイドを参照します
- direnvを有効化する場合は[`direnvの設定`](nix/direnv.md)を参照します
- GitHub SSHを設定する場合は[`GitHub SSH設定`](github-ssh.md)を参照します
