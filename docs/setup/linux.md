# Linux・WSLセットアップ

> [!IMPORTANT]
> 共通の初回導入手順は[`README.md`](README.md)を参照してください。この文書はLinux・WSL
> 固有の管理範囲、制約、再適用方法だけを所有します。

## 目次

- [1. 管理範囲](#1-管理範囲)
- [2. 環境別の前提](#2-環境別の前提)
- [3. 設定の再適用](#3-設定の再適用)

## 1. 管理範囲

| 管理対象 | 手段 | 管理対象外 |
|---|---|---|
| zsh、git、CLIツール | Home Manager | Linuxシステム設定 |
| Docker CLI | Home Manager | daemon、ユーザー権限 |
| WSL内のユーザー環境 | Home Manager | Windows本体、WSL作成 |

ホスト名、ブート、ネットワーク、Docker daemonなどのシステム管理は対象外です。

## 2. 環境別の前提

- NixOSはNix導入済みのため、共通SetupのNix導入を省略します
- WindowsからWSLを作成する手順は[`Windowsセットアップ`](windows.md)を参照します
- WSL上でNixOSを使う場合は[NixOS-WSL](https://github.com/nix-community/NixOS-WSL)を参照します

## 3. 設定の再適用

```bash
nix run github:nix-community/home-manager/release-25.05 -- \
  switch --flake path:.#<host-id>
```

現行Host設定は[`ホスト設定`](nix/hosts.md)を参照してください。
