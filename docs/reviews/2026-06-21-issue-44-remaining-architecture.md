# 設計レビュー: issue-44 残項目（TOML化・App Catalog・Registry CI・Wizard/CLI）

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-21 |
| 対象ブランチ / PR | `feat/issue-44-remaining-architecture` |
| レビュー担当 | Claude Sonnet 4.6 (自動) |
| レビュー種別 | 設計レビュー（実装前） |

---

## レビュー観点

issue-36 の意思決定（Decision 1–4, 8, 10, 11, 13–15, 17–19）を実装に移す前に、
未解決の設計判断と実装上の前提条件を洗い出します。

> [!IMPORTANT]
> このレビューはコード変更のレビューではなく、実装着手前の設計レビューです。
> 指摘は「着手前に確定すべき事項」「実装中に判断すべき事項」に分類します。

---

## 設計

### Instance分離 — Host Templateの現状と目標のギャップ

- [x] `hosts/*/config.nix` に `meta.hostname`（実機固有値）が含まれる
- [x] `hosts/*/config.nix` に `userProfile.name`（適用時に選択する値）が含まれる
- [x] `lib/host-config.nix` で `userProfile.name` を必須フィールドとして検証している
- [ ] Instance移行後のHost Templateスキーマが未定義
- [ ] `meta.hostname` をHostから除いたあとの `networking.hostName` の取得元が未決

### TOML化 — 技術的前提条件

- [ ] `builtins.fromTOML` の利用可否（Nix 2.6+ が必要；`nix --version` 確認が必要）
- [ ] TOMLスキーマの `schema_version` バリデーション方式が未設計
- [ ] Nix側 Validator の入力型（attrset）と出力型の契約が未定義

### Local deploy flake — 未決事項

`instance-and-deployment.md` § 8 に明示された未決事項：

- [ ] WizardがInstanceを新規作成する対話フロー
- [ ] FrameworkのURLまたはpath参照方式（`github:hisuilab/nix-station` vs `path:...`）
- [ ] `flake.lock` のrevision固定と更新タイミング
- [ ] rollbackをWizardから提供する範囲

### App Catalog — スキーマと生成先の未定義

- [ ] App Catalog TOMLのフルスキーマが未定義（`app-management.md` はサンプルのみ）
- [ ] `darwin.dock`（現状HostにあるDock設定）がHostとInstanceのどちらに属するか未決
- [ ] 既存 `hosts/*/Brewfile` の扱い（移行期間維持 or 削除）が未決

### Registry拡張 — 機能定義の正本化

- [ ] `lib/host-registry.nix` にModule pathが存在しない
- [ ] README path、Test pathの導出規則が `testing.md` § 4 に記述されるが、Registry属性として未定義
- [ ] 孤立Testの検出方式（Test path → Registry逆引き）が未設計

### Wizard/CLI — 実装方式が未決

`user-workflow.md` § 3 に「実装方式は実装フェーズで決定」と明記：

- [ ] `nix-station` CLIの実装言語（zsh / Python / Rust）が未決
- [ ] Application Serviceの実装単位（シェル関数集 / プロセス境界）が未決
- [ ] `setup.sh` との責任分割が未定義

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | [`lib/host-config.nix` L78–81](../../lib/host-config.nix#L78) | `userProfile.name` を必須として検証しているため、Instance分離後はHost単体で評価できない | Instance移行後はHostからuserProfile要件を除き、deploy時の結合に移動する |
| 2 | [`hosts/macos-desktop/config.nix` L3](../../hosts/macos-desktop/config.nix#L3) | `meta.hostname` は実機固有値でありHost Templateに含めるべきでない | Instanceの `instance.toml` へ移動し、HostはIDのみ持つ |
| 3 | [`hosts/macos-desktop/config.nix` L10](../../hosts/macos-desktop/config.nix#L10) | `userProfile.name = "guest"` はProfile選択であり実機固有値 | Instance内で Profile を選択し、Host Templateから除去する |
| 4 | [`hosts/macos-laptop/config.nix` L11](../../hosts/macos-laptop/config.nix#L11) | 同上 | 同上 |
| 5 | [`lib/host-registry.nix`](../../lib/host-registry.nix) | Module pathを持たず、Registry駆動のStructural CI検査を実現できない | `modules` attrを追加し、Module path・説明・対応OSを登録する |
| 6 | [`instance-and-deployment.md` §8](../../docs/architecture/instance-and-deployment.md#8-未決事項) | Framework参照方式（github URL vs local path）が未決のため、local deploy flakeの生成テンプレートを書けない | Decision Recordで方式を確定させてから生成テンプレートを実装する |
| 7 | [`app-management.md` §3](../../docs/architecture/app-management.md#3-データモデル) | App Catalog TOMLのフルスキーマが未定義（サンプル2行のみ） | Validator実装前にTOMLスキーマ全体（必須/任意フィールド、列挙値）を確定する |
| 8 | [`hosts/macos-desktop/config.nix` L47–48](../../hosts/macos-desktop/config.nix#L47) | `darwin.dock` 設定がHostに存在するが、Dock順序は端末・個人の好みで変わるため Instance側が適切な場合がある | HostはDock機能の有無（`darwin.features.dock`）、順序と表示設定はInstanceへ分離する方針を決定する |
| 9 | [`user-workflow.md` §3](../../docs/architecture/user-workflow.md#3-セットアップ後の利用) | `nix-station` CLIの実装言語が「実装フェーズで決定」のまま。言語選択が後続の全Wizard/CLI実装に影響する | 保守コスト（依存なし: zsh、型安全: Python/Rust）の観点でDecisionに記録する |
| 10 | [`hosts/macos-desktop/Brewfile`](../../hosts/macos-desktop/Brewfile) | App Catalog移行後にBrewfileをHostディレクトリに置き続ける理由がなくなる | 移行期間中はそのまま維持し、App Catalog実装完了後に削除する方針を明示する |

---

## 優先度まとめ

### 着手前に確定（設計の前提）

- **#1, 2, 3**: Host Templateからの hostname・userProfile.name 除去方針 — ValidatorとSchemaの設計基準になる
- **#5**: Registry へのModule path追加方針 — CI検査設計の前提
- **#6**: Framework参照方式（github vs path） — local deploy flakeのテンプレート生成に必要
- **#7**: App Catalog TOMLフルスキーマ — Validator実装の前提
- **#9**: CLI実装言語 — Wizard/CLI全体のアーキテクチャに影響

### 実装中に判断（実装単位ごと）

- **#8**: `darwin.dock` のHost/Instance分離方針 — App Catalog実装時に決定
- **#10**: 既存Brewfileの移行期間維持方針 — App Catalog実装開始時に決定

### 機会があれば対応

- `testing.md` § 4 の孤立Test検出方式の詳細設計（Registry追加後）

---

> 意思決定の記録 → [`docs/decisions/2026-06-21-issue-44-remaining-architecture.md`](../decisions/2026-06-21-issue-44-remaining-architecture.md)
