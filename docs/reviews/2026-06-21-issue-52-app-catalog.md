# 設計レビュー: issue-52 App Catalog TOML スキーマ定義と Brewfile 生成

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-21 |
| 対象ブランチ / PR | `feat/issue-52-app-catalog` |
| レビュー担当 | Claude Sonnet 4.6 (自動) |
| レビュー種別 | 設計レビュー（実装前） |

---

## レビュー観点

issue-44 Decision #7 と [`docs/architecture/app-management.md`](../architecture/app-management.md) を基に、
以下の未決事項を確定します。

1. `install` フィールドの列挙値（`homebrew-cask` vs `cask`）
2. Catalog ファイルの分割方式（共通 vs ホスト固有）
3. この PR のスコープ（スキーマ + Validator のみ か、Host Template `apps`/`dock` 連携まで含めるか）
4. Brewfile 生成スクリプトの出力先とコマンド形式
5. `brew "mas"` の自動追加ルール
6. 既存 Brewfile の削除タイミング

---

## 現状（移行前）

| ファイル | 内容 |
|---|---|
| [`hosts/common/Brewfile`](../../hosts/common/Brewfile) | cask × 20、mas × 1、`brew "mas"` |
| [`hosts/macos-desktop/Brewfile`](../../hosts/macos-desktop/Brewfile) | cask × 4、mas × 2、davinci-resolve（manual コメント） |

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | `install` フィールドの値 | [`app-management.md` §3](../architecture/app-management.md#3-データモデル) は `homebrew-cask` を使用。issue-44 Decision #7 は `cask`/`mas` と省略形で記述しており表記が不一致 | どちらかに統一する。`homebrew-cask` は将来 `winget-cask` 等を追加したときに識別できる（推奨）。`cask` は短く書きやすい |
| 2 | Catalog ファイルの分割 | 共通アプリと macos-desktop 固有アプリを 1 ファイルにまとめるか、`hosts/common/apps.toml` + `hosts/macos-desktop/apps.toml` に分けるか未決 | 現行 Brewfile と対称に 2 ファイルに分割する（`common` + ホスト固有）。生成 Brewfile も同じ粒度で出力する |
| 3 | この PR のスコープ | [`app-management.md` §2](../architecture/app-management.md#2-判断) は Host Template が `apps` と `dock` を Catalog ID で参照する設計だが、Host Template TOML にはまだその仕組みがない | この PR は Catalog スキーマ + Validator + Brewfile 生成スクリプトに絞る。Host Template の `apps`/`dock` 参照は Wizard/CLI 実装時（次 issue）に含める |
| 4 | Brewfile 生成の出力先 | [`app-management.md` §4](../architecture/app-management.md#4-生成フロー) は `~/.config/nix-station/generated/Brewfile` を出力先とする。この PR で生成コマンドをどのレベルまで実装するか未決 | `scripts/service/generate_brewfile.py` を新設し、`hosts/common/apps.toml` と `hosts/<host>/apps.toml` を読んで `~/.config/nix-station/generated/Brewfile` を生成するスクリプトを実装する |
| 5 | `brew "mas"` の自動追加 | `mas` 型のアプリが 1 件以上ある場合、Brewfile に `brew "mas"` が必要。現行 Brewfile では `hosts/common/Brewfile` に手動追加されている | Brewfile 生成スクリプトが `mas` 型アプリの有無を判定し、必要なら `brew "mas"` を自動追加する |
| 6 | 既存 Brewfile の削除タイミング | [Decision #10](2026-06-21-issue-44-remaining-architecture.md) では App Catalog 実装完了後に削除とある。この PR が「完了」とみなせるか未決 | Brewfile 生成スクリプトが動作確認できた時点でこの PR で削除する。`~/.config/nix-station/generated/Brewfile` を正本とする |
| 7 | `davinci-resolve`（manual 型）の `manual_steps` | [`hosts/macos-desktop/Brewfile`](../../hosts/macos-desktop/Brewfile) にコメントで「公式サイトから手動インストール」と記載がある。TOML でどう表現するか | `install = "manual"` + `manual_steps = ["https://www.blackmagicdesign.com/products/davinciresolve から DaVinci Resolve をダウンロードしてインストールする"]` として移行する |

---

## 優先度まとめ

### 着手前に確定

- **#1**: `install` 値 — スキーマとバリデーターの基礎となる
- **#2**: Catalog ファイル分割方式 — ファイル構成全体に影響
- **#3**: PR スコープ — 実装量の境界を決める

### 実装中に判断

- **#4**: Brewfile 生成スクリプト配置 — `scripts/service/` の新設
- **#5**: `brew "mas"` 自動追加 — 生成ロジックで対応
- **#6**: 既存 Brewfile 削除タイミング — 動作確認後に判断
- **#7**: `davinci-resolve` manual_steps — Catalog ファイル作成時に記入

---

> 意思決定の記録 → [`docs/decisions/2026-06-21-issue-52-app-catalog.md`](../decisions/2026-06-21-issue-52-app-catalog.md)
