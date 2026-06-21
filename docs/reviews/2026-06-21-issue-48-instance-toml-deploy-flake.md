# 設計レビュー: issue-48 Instance TOML スキーマ定義と local deploy flake 実装

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-21 |
| 対象ブランチ / PR | `feat/issue-48-instance-toml-deploy-flake` |
| レビュー担当 | Claude Sonnet 4.6 (自動) |
| レビュー種別 | 設計レビュー（実装前） |

---

## レビュー観点

issue-44 Decision #3, #6 の実装に着手する前に、次の設計判断を確定させます。

1. `instance.toml` スキーマのフィールド構成
2. `profiles/<name>.toml` スキーマと既存 Nix プロファイルとの対応
3. Framework が local deploy flake へ公開する API（export surface）
4. `framework_version` の必要性（`flake.lock` との重複確認）
5. `networking.hostName` の取得元変更
6. local deploy flake の `inputs` 管理方式
7. `lib/toml-loader.nix` の `userProfile.name = "guest"` プレースホルダーの解消時期
8. Python Validator のファイル構成

---

## 設計

### instance.toml スキーマ案

```toml
schema_version = "1"

hostname       = "HisuiLab-Mac-mini"   # 実機固有のhostname
host_id        = "macos-desktop"       # 使用するHost Template ID
profile        = "guest"               # 使用するUser Profile名
framework_path = "/Users/hisuilab/Projects/nix-station"
framework_version = "abc1234"          # git commit hash（追跡用）
```

### profiles/\<name\>.toml スキーマ案

現行 `user-profiles/*.nix` の必須フィールドに対応：

```toml
schema_version = "1"

username    = "hisuilab"
description = "Personal profile"      # 任意

[git]
user_name  = "hisuilab"
user_email = "hisuilab@example.com"
```

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | [`flake.nix` L67–108](../../flake.nix#L67) | `mkDarwinConfiguration` と `mkHomeConfiguration` は `let` バインディングであり、local deploy flake から参照できない | Framework の `outputs` に `lib.mkDarwinConfiguration` / `lib.mkHomeConfiguration` / `lib.loadHostTemplate` を追加してエクスポートする |
| 2 | `instance.toml` スキーマ | `host_id` の命名（`host`、`template`等と迷う可能性）と必須フィールドの確定が未決 | `host_id` を採用し、`hostname`・`profile`・`framework_path` を必須とする。`framework_version` の扱いは #4 で決定 |
| 3 | `profiles/<name>.toml` スキーマ | [`user-profiles/default.nix` L43–54](../../user-profiles/default.nix#L43) の `git.userName` / `git.userEmail` は camelCase。TOML では `git.user_name` / `git.user_email`（snake_case）が自然。変換が必要 | TOML 側を `user_name` / `user_email` とし、Profile Validator が正規化して Nix 側の `userName` / `userEmail` に変換する |
| 4 | `instance.toml` の `framework_version` | Framework を `github:` 参照に変更（issue-44 Decision #6 修正）したため、`flake.lock` が git revision を正式に記録する。`framework_version` は冗長 | `framework_version` と `framework_path` の両フィールドを `instance.toml` から除去する |
| 5 | [`modules/system/darwin/core/default.nix`](../../modules/system/darwin/core/default.nix) | `networking.hostName = hostConfig.meta.hostname` で Host Template の hostname を使っている。Instance 分離後は `instance.toml` の `hostname` を使うべきだが、local deploy flake 経由でどう渡すかが未決 | local deploy flake が `hostname` を `specialArgs` または `config` として `mkDarwinConfiguration` に渡す。`hostConfig.meta.hostname` は Host Template に含めない（issue-44 Decision #1） |
| 6 | local deploy flake の `inputs` 管理 | local deploy flake が `nixpkgs`、`nix-darwin`、`home-manager` を個別に宣言するか、Framework の inputs を `follows` で継承するかが未決 | Framework を `github:hisuilab/nix-station` で参照し、`follows` で Framework inputs を継承する。テンプレートが固定文字列になり、Wizard の生成処理もシンプルになる（issue-44 Decision #6 変更） |
| 7 | [`lib/toml-loader.nix` L53–55](../../lib/toml-loader.nix#L53) | `userProfile.name = "guest"` のプレースホルダーは、local deploy flake 実装後に削除する必要がある | この PR で local deploy flake が Instance から profile を取得する経路を実装したら、`toml-loader.nix` のプレースホルダーを削除する（この issue の完了条件に含める） |
| 8 | Python Validator のファイル構成 | Instance と Profile をどのファイルに実装するかが未決（統合 vs 分離） | `scripts/validator/instance.py` と `scripts/validator/profile.py` を別ファイルで作成する。将来 Application Service が import しやすいようモジュールとして分離する |

---

## 優先度まとめ

### 着手前に確定（設計の前提）

- **#1**: Framework export surface — local deploy flake の全設計に影響
- **#5**: `hostname` の渡し方 — `mkDarwinConfiguration` のインターフェース変更を伴う
- **#6**: local deploy flake の `inputs` 管理方式

### 実装中に判断

- **#2**: `instance.toml` フィールド名 — スキーマ実装時に確定
- **#3**: `git.user_name` vs `git.userName` — Profile Validator 実装時に確定
- **#4**: `framework_version` の必要性 — 任意フィールドとして実装

### 実装の完了条件として組み込む

- **#7**: `toml-loader.nix` プレースホルダー削除 — この PR 完了時に必須
- **#8**: Validator ファイル分割 — 実装開始時に構成確定

---

> 意思決定の記録 → [`docs/decisions/2026-06-21-issue-48-instance-toml-deploy-flake.md`](../decisions/2026-06-21-issue-48-instance-toml-deploy-flake.md)
