# 意思決定の記録: issue-28-mac-mini-m4-fresh-setup

> 記録日: 2026-06-16
> ファイル名: `docs/decisions/2026-06-16-issue-28-mac-mini-m4-fresh-setup.md`

---

| # | 優先度 | 判断 | 理由・備考 |
|---|---|---|---|
| 1 | 中 | このissueに含める: darwin-rebuild 前に userProfile.name と username を表示・確認ステップを追加 | 設定漏れを起こしにくくしたい |
| 2 | 高 | このissueに含める: `nix.enable = false` を `core/default.nix` に追加する | Determinate 環境では必須。公式ドキュメント ([Use Determinate with nix-darwin](https://docs.determinate.systems/guides/nix-darwin/)) が明示的に推奨。より統合された方法として `determinateNix.enable = true`（Determinate の nix-darwin モジュールを使う）もあるが、現状は `nix.enable = false` の最小対応で十分。`nix.*` オプションが使えなくなる制約は Determinate の `customSettings` で代替可能。 |
| 3 | 高 | このissueに含める: README の Apply 手順に `/etc/zshenv` 移動ステップを追記 | Determinate 環境では必須の前処理 |
| 4 | 高 | このissueに含める: `mysides` を macOS 組み込みの `sfltool` に差し替える | Rosetta 不要・ARM ネイティブ動作。nixpkgs の mysides 依存を削除する |
| 5 | 高 | このissueに含める: `enableRosetta = false` に変更 | M chip 前提、Intel Homebrew prefix 不要。brew bundle の失敗原因を解消する |
| 6 | 中 | このissueに含める: `install.sh` を Linux + Mac 同時対応で実装 | OS 検出 → Nix インストール確認 → 前処理（`/etc/zshenv` 退避等）→ darwin-rebuild / home-manager → brew bundle → darwin-rebuild（2回目、#11）の順に実行 |
| 7 | 中 | このissueに含める: `input/default.nix` に日本語ライブ変換オフの設定を追加 | デフォルト ON のため初回適用後も手動でオフにする必要があり不便 |
| 8 | 中 | このissueに含める: README または `docs/` に SSH セットアップガイドを追記 | darwin-rebuild switch 後の次の手順として案内する |
| 9 | 中 | このissueに含める: Mac mini 向け電源管理設定モジュールを追加（ディスプレイオフ時スリープ抑止） | デスクトップ用途でディスプレイを切っても処理継続できる必要がある |
| 10 | 低 | このissueに含める: README の Setup セクションに `direnv allow` 実行ステップを追記 | install.sh にも組み込む |
| 11 | 高 | このissueに含める: `darwin-rebuild switch → brew bundle → darwin-rebuild switch` の2回パスを正式手順とする。README に明記し、install.sh（#6）で自動化する | nix-homebrew が Homebrew 自体をインストールするため brew を先行実行できない。2回パスが唯一の現実的解。README には「brew bundle 後に再度 darwin-rebuild switch が必要な理由（Dock アプリの存在チェック）」を補足として記載する |
