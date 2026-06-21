# macOSセットアップ

> [!IMPORTANT]
> 共通の初回導入手順は[`README.md`](README.md)を参照してください。この文書はmacOS固有の
> 管理範囲、制約、再適用方法だけを所有します。

## 目次

- [1. 管理範囲](#1-管理範囲)
- [2. macOS固有の前提](#2-macos固有の前提)
- [3. 設定の再適用](#3-設定の再適用)
- [4. HomebrewとDock](#4-homebrewとdock)

## 1. 管理範囲

| 管理対象 | 手段 |
|---|---|
| Dock、Finder、入力などのシステム設定 | nix-darwin |
| zsh、git、CLIツールなどのユーザー環境 | Home Manager |
| Homebrew本体 | nix-homebrew |
| GUI・App Storeアプリ | Brewfileと`brew bundle` |

## 2. macOS固有の前提

- MASアプリを導入する前にApp Storeへサインインします
- Homebrewをnix-stationで導入するかは、現行Hostの`darwin.homebrew.install`が決定します
- 初回Wizardの現行動作は[`setup.sh`](../../setup.sh)を正本とします

> [!NOTE]
> 現行Host設定の詳細は[`ホスト設定`](nix/hosts.md)を参照してください。

## 3. 設定の再適用

```bash
darwin-rebuild switch --flake path:.#<host-id>
```

## 4. HomebrewとDock

```bash
brew bundle --file hosts/common/Brewfile
brew bundle --file hosts/<host-id>/Brewfile
```

現行実装では、Brewアプリ導入後に`darwin-rebuild switch`を再実行すると、存在するアプリを
Dockへ反映できます。目標設計は[`App CatalogとDock設計`](../architecture/app-management.md)を
参照してください。
