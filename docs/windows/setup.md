# Windows セットアップ

## このガイドの範囲

| 管理対象 | 手段 | 補足 |
|---|---|---|
| アプリ一括インストール | winget（カテゴリ別） | Windows 標準のパッケージマネージャー。JSON ファイルで管理したアプリをコマンド一発で一括インストール |
| WSL 環境構築 | [Linux ガイド](../linux/setup.md)へ委譲 | WSL（Windows Subsystem for Linux）内の設定は Nix + Home Manager で管理 |

> [!NOTE]
> Windowsでは Nix でのレジストリやシステム設定・WSL ディストリビューション作成は管理対象外です。<br>
> その代わり`winget`でのアプリケーション一括インストールとWSLセットアップガイドラインを用意しています。[WSL のセットアップ](#wsl-のセットアップ)

## セットアップ

### 1. このリポジトリを取得

**ZIP でダウンロードする場合:**

```powershell
# ダウンロードフォルダへ保存
Invoke-WebRequest `
  -Uri https://github.com/hisuilab/nix-station/archive/refs/heads/main.zip `
  -OutFile "$env:USERPROFILE\Downloads\nix-station.zip"

# ダウンロードフォルダへ移動して展開
cd "$env:USERPROFILE\Downloads"
Expand-Archive -Path nix-station.zip -DestinationPath .
cd nix-station-main
```

**git clone を使う場合（Git インストール済みの場合）:**

```powershell
git clone https://github.com/hisuilab/nix-station.git
cd nix-station
```

### 2. セットアップスクリプトを実行

PowerShell を開き、リポジトリのフォルダへ移動して実行します。

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
| ブラウザ | [`hosts/windows-desktop/packages/browser.json`](../../hosts/windows-desktop/packages/browser.json) | Chrome, Brave |
| 開発環境 | [`hosts/windows-desktop/packages/dev.json`](../../hosts/windows-desktop/packages/dev.json) | WSL, Docker, VSCode, Tailscale 等 |
| ゲーム | [`hosts/windows-desktop/packages/gaming.json`](../../hosts/windows-desktop/packages/gaming.json) | Steam, Epic Games, OBS 等 |
| ハードウェア | [`hosts/windows-desktop/packages/hardware.json`](../../hosts/windows-desktop/packages/hardware.json) | Logitech, Yamaha, Nvidia 等 |

## WSL のセットアップ

WSL（Windows Subsystem for Linux）は Windows 上で Linux 環境を動かす仕組みです。

公式ドキュメント: [Microsoft Learn — WSL のインストール](https://learn.microsoft.com/ja-jp/windows/wsl/install)

### 1. WSL と Ubuntu をインストール

PowerShell を管理者として開き、実行します。

```powershell
wsl --install -d Ubuntu
```

インストール後は PC を再起動してください。

### 2. Ubuntu の初期設定

再起動後、PowerShell から Ubuntu を起動します。

```powershell
wsl -d Ubuntu
```

初回起動時にユーザー名とパスワードの入力を求められます。設定後、パッケージリストを更新します。

```bash
sudo apt update && sudo apt upgrade -y
```

### 3. nix-station の適用

Ubuntu 内でリポジトリへ移動し、セットアップスクリプトを実行します。

```bash
bash setup.sh
```

> [!TIP]
> 引数で直接指定することもできます: `bash setup.sh ubuntu-wsl`

> [!NOTE]
> スクリプト完了後はターミナルを再起動し、`direnv allow` を実行してください。→ [direnv の設定](../nix/direnv.md)

詳細な手順は [../linux/setup.md](../linux/setup.md) を参照してください。

## 手動インストールが必要なツール

`setup.ps1` では自動インストールできないツールがあります。詳細は [../../hosts/windows-desktop/MANUAL.md](../../hosts/windows-desktop/MANUAL.md) を参照してください。
