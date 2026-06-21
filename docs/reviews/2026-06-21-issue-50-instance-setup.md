# 設計レビュー: issue-50 実環境 Instance セットアップ

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-21 |
| 対象ブランチ / PR | `feat/issue-50-instance-setup` |
| レビュー担当 | Claude Sonnet 4.6 (自動) |
| レビュー種別 | 実装前レビュー（設定ファイル作成） |

---

## 環境情報

| 項目 | 値 |
|---|---|
| hostname | `HisuiLab-Mac-mini` |
| macOS user | `hisuilab` |
| 対象 Host Template | `macos-desktop` |
| `~/.config/nix-station/` | 未作成 |

---

## レビュー観点

1. `instance.toml` の実際のフィールド値
2. `profiles/<name>.toml` のフィールド値とプロファイル名の命名
3. `~/.config/nix-station/` の作成手順と初回 `flake.lock` の生成
4. 初回 `darwin-rebuild switch` コマンドと実行前チェック
5. 既存 Homebrew インストールと nix-homebrew の競合リスク

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | `instance.toml` の `profile` フィールド | プロファイル名を何にするか未決（`guest` / `hisuilab` / 別名） | `hisuilab` を推奨。macOS ユーザー名と揃えると `users.users.${username}` や nix-homebrew の `user` が一貫する |
| 2 | `profiles/<name>.toml` の `git.user_name` | Git コミット表示名が未決 | ユーザーに確認が必要 |
| 3 | `~/.config/nix-station/` 作成方法 | テンプレートコピー → 値を編集 → `nix flake update` の手順が未文書 | この PR でコマンド手順を決定し実行する。`flake.lock` は `nix flake update` で生成する |
| 4 | 初回 `darwin-rebuild switch` の実行前チェック | Validator を事前に走らせる手順が未定 | `nix run nixpkgs#python3 -- scripts/validator/instance.py ~/.config/nix-station/instance.toml` と `profile.py` を実行してから `darwin-rebuild switch` を行う |
| 5 | nix-homebrew の競合リスク | `macos-desktop` の `darwin.homebrew.install = true` により nix-homebrew が Homebrew 本体を管理しようとする。既存インストールがある場合に競合する可能性がある | 初回は `darwin.homebrew.install = false` に相当するオプションで適用するか、nix-homebrew の migration モードを確認する。または `macos-desktop/template.toml` の `install = true` を一時的に上書きする方法を検討する |
| 6 | `darwin-rebuild switch` のターゲット指定 | `darwin-rebuild switch --flake ~/.config/nix-station` は `darwinConfigurations.$(hostname)` を参照する。`instance.hostname = "HisuiLab-Mac-mini"` と実機の `LocalHostName` が一致していることを確認する必要がある | `scutil --get LocalHostName` で一致確認済み: `HisuiLab-Mac-mini` ✅ |

---

## 優先度まとめ

### 着手前に確定

- **#1**: プロファイル名 — 以降の手順全体に影響
- **#2**: `git.user_name` — プロファイル TOML の必須フィールド
- **#5**: nix-homebrew 競合リスクの対処方針

### 実装中に確認

- **#3**: flake.lock 生成手順 — `nix flake update` 実行タイミング
- **#4**: Validator 事前実行の手順確認
- **#6**: hostname 一致確認（実施済み）

---

> 意思決定の記録 → [`docs/decisions/2026-06-21-issue-50-instance-setup.md`](../decisions/2026-06-21-issue-50-instance-setup.md)
