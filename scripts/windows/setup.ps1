# Windows Desktop セットアップスクリプト
# 使用方法:
#   PowerShell -ExecutionPolicy Bypass -File scripts\windows\setup.ps1
#   PowerShell -ExecutionPolicy Bypass -File scripts\windows\setup.ps1 -Categories gaming,hardware
#
# カテゴリ: gaming / dev / hardware / browser (デフォルト: 全カテゴリ)
# 前提: Windows 11 (winget 標準搭載)
# ZIP ダウンロード展開後、リポジトリルートから実行してください

param(
    [string[]]$Categories = @("gaming", "dev", "hardware", "browser")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot | Split-Path | Split-Path
$PackagesDir = Join-Path $RepoRoot "hosts\windows-desktop\packages"

function Write-Info  { param($msg) Write-Host "[info]  $msg" }
function Write-Warn  { param($msg) Write-Host "[warn]  $msg" -ForegroundColor Yellow }
function Write-Err   { param($msg) Write-Host "[error] $msg" -ForegroundColor Red; exit 1 }

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Err "winget が見つかりません。Windows 11 以降、または Microsoft Store から 'App Installer' をインストールしてください。"
}

Write-Info "winget: $(winget --version)"
Write-Info "=== Windows Desktop セットアップ開始 ==="
Write-Info "カテゴリ: $($Categories -join ', ')"
Write-Host ""

$failed = @()

foreach ($category in $Categories) {
    $file = Join-Path $PackagesDir "$category.json"
    if (-not (Test-Path $file)) {
        Write-Warn "カテゴリ '$category' のファイルが見つかりません: $file (スキップ)"
        continue
    }
    Write-Info "[$category] インストール中..."
    winget import --import-file $file --ignore-versions --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        $failed += $category
        Write-Warn "[$category] 一部のパッケージのインストールに失敗しました"
    }
    Write-Host ""
}

Write-Info "=== セットアップ完了 ==="

if ($failed.Count -gt 0) {
    Write-Warn "失敗したカテゴリ: $($failed -join ', ')"
    Write-Warn "再実行: PowerShell -ExecutionPolicy Bypass -File scripts\windows\setup.ps1 -Categories $($failed -join ',')"
}

Write-Host ""
Write-Host "次のステップ:"
Write-Host "  1. WSL を開いて Linux 環境をセットアップしてください:"
Write-Host "       bash install.sh ubuntu-wsl"
Write-Host "  2. Docker Desktop を起動して初期設定を行ってください"
Write-Host "  3. Tailscale にサインインしてください"
