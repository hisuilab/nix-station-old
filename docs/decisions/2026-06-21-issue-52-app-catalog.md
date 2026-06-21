# 意思決定の記録: issue-52-app-catalog

> 記録日: 2026-06-21

| # | 判断 | 理由・備考 |
|---|---|---|
| 1 | `install` フィールドの列挙値 | `homebrew-cask` / `mas` / `system` / `manual`。アーキテクチャ doc 準拠。将来 `winget-cask` 等を追加しても識別しやすい |
| 2 | Catalog ファイルの分割方式（共通 vs ホスト固有） | `hosts/common/apps.toml` + `hosts/macos-desktop/apps.toml` の 2 ファイル。現行 Brewfile と同じ粒度で管理する |
| 3 | この PR のスコープ | スキーマ定義 + Validator（`scripts/validator/app_catalog.py`）+ Brewfile 生成スクリプト（`scripts/service/generate_brewfile.py`）に絞る。Host Template の `apps`/`dock` 参照は Wizard/CLI issue へ |
| 4 | Brewfile 生成スクリプトの出力先とコマンド形式 | `scripts/service/generate_brewfile.py`。出力先は `~/.config/nix-station/generated/Brewfile`（Instance ディレクトリ内、手編集禁止） |
| 5 | `brew "mas"` の自動追加ルール | `mas` 型アプリが 1 件以上ある場合は生成 Brewfile の先頭に `brew "mas"` を自動追加する |
| 6 | 既存 Brewfile の削除タイミング | 生成スクリプトの動作確認後にこの PR で削除する。`~/.config/nix-station/generated/Brewfile` を正本とする |
| 7 | `davinci-resolve` の `manual_steps` 表現 | `install = "manual"` + `manual_steps = ["公式サイト (https://www.blackmagicdesign.com/products/davinciresolve) から DaVinci Resolve をダウンロードしてインストールする"]` として TOML へ移行する |
