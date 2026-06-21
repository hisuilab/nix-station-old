# 意思決定の記録: issue-50-instance-setup

> 記録日: 2026-06-21

| # | 判断 | 理由・備考 |
|---|---|---|
| 1 | プロファイル名 | `hisuilab`。macOS ユーザー名・GitHub アカウントと一致させる |
| 2 | `git.user_name`（Git コミット表示名） | `hisuilab` |
| 3 | `~/.config/nix-station/` 作成手順と `flake.lock` 生成タイミング | ディレクトリを手動作成 → テンプレートからファイルをコピー・編集 → `nix flake update` で `flake.lock` を生成 → Validator を実行 → `darwin-rebuild switch` の順で進める |
| 4 | Validator 事前実行の手順 | `darwin-rebuild switch` の直前に `scripts/validator/instance.py` と `scripts/validator/profile.py` を実行してスキーマを確認する |
| 5 | nix-homebrew 競合リスクの対処方針 | 初回は `install = false` 相当で適用する。`instance.toml` では `host_id = "macos-desktop"` を使いつつ、`~/.config/nix-station/` に Host Template を上書きする `override.toml` は設けない方針のため、Host Template の `install` フィールド自体を一時変更して対応する（詳細は実装で決定） |
| 6 | `darwin-rebuild switch` ターゲット指定 | `scutil --get LocalHostName` = `HisuiLab-Mac-mini`、`instance.hostname` と一致確認済み ✅ |
