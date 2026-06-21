# Windowsセットアップ

> [!IMPORTANT]
> この文書はWindows本体のwinget導入とWSL bootstrapを所有します。WSL内のNix環境構築は
> [`SETUP.md`](../SETUP.md)と[`Linux・WSLガイド`](../linux/setup.md)を参照してください。

## 目次

- [1. 管理範囲](#1-管理範囲)
- [2. リポジトリの取得](#2-リポジトリの取得)
- [3. Windowsアプリの導入](#3-windowsアプリの導入)
- [4. WSLの導入](#4-wslの導入)
- [5. 手動導入](#5-手動導入)

## 1. 管理範囲

| 管理対象 | 手段 | 管理対象外 |
|---|---|---|
| Windowsアプリ | winget | アプリ内部設定 |
| WSLディストリビューション | Windows・WSL公式機能 | WSL内のNix環境 |

Windowsのレジストリやシステム設定はNixで管理しません。

## 2. リポジトリの取得

ZIPを使用する場合：

```powershell
Invoke-WebRequest `
  -Uri https://github.com/hisuilab/nix-station/archive/refs/heads/main.zip `
  -OutFile "$env:USERPROFILE\Downloads\nix-station.zip"
cd "$env:USERPROFILE\Downloads"
Expand-Archive -Path nix-station.zip -DestinationPath .
cd nix-station-main
```

Gitを使用する場合：

```powershell
git clone https://github.com/hisuilab/nix-station.git
cd nix-station
```

## 3. Windowsアプリの導入

```powershell
PowerShell -ExecutionPolicy Bypass -File scripts\windows\setup.ps1
```

カテゴリを限定できます。

```powershell
PowerShell -ExecutionPolicy Bypass -File scripts\windows\setup.ps1 `
  -Categories gaming,hardware
```

| カテゴリ | 正本 |
|---|---|
| ブラウザ | [`browser.json`](../../hosts/windows-desktop/packages/browser.json) |
| 開発環境 | [`dev.json`](../../hosts/windows-desktop/packages/dev.json) |
| ゲーム | [`gaming.json`](../../hosts/windows-desktop/packages/gaming.json) |
| ハードウェア | [`hardware.json`](../../hosts/windows-desktop/packages/hardware.json) |

## 4. WSLの導入

Microsoft公式手順は[WSLのインストール](https://learn.microsoft.com/ja-jp/windows/wsl/install)を
参照してください。Ubuntuを導入する場合：

```powershell
wsl --install -d Ubuntu
```

再起動後にUbuntuを起動し、ユーザーを作成します。以降のNix導入とnix-station適用は
[`SETUP.md`](../SETUP.md#2-macoslinuxwsl)へ移動します。

## 5. 手動導入

wingetで自動導入できないツールは
[`hosts/windows-desktop/MANUAL.md`](../../hosts/windows-desktop/MANUAL.md)を参照してください。
