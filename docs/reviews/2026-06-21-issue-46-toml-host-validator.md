# 設計レビュー: issue-46 TOML Host Template スキーマ定義と Python Validator 実装

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-21 |
| 対象ブランチ / PR | `feat/issue-46-toml-host-validator` |
| レビュー担当 | Claude Sonnet 4.6 (自動) |
| レビュー種別 | 設計レビュー（実装前） |

---

## レビュー観点

issue-44 Decision #1–4, #7, #9 の実装に着手する前に、次の設計判断を確定させます。

1. TOML Host Templateのファイル名・配置場所
2. TOMLフィールドの命名規則（snake_case vs camelCase）
3. `configFile`（managed tool設定ファイルのパス）のTOML表現
4. TOMLパースの担当レイヤー（Python vs Nix `builtins.fromTOML`）
5. Python Validatorのコード配置場所
6. TOML Host TemplateをRoot flakeのchecksに組み込む方法

---

## 設計

### TOML Host Templateのスキーマ案

`schema_version`、`meta`、`home_manager`（snake_case）、`darwin`セクションで構成します。
`hostname` と Profile はInstanceの責任のため含めません。

```toml
schema_version = "1"

[meta]
system      = "aarch64-darwin"
builder     = "nix-darwin"
os          = "macos"
environment = "native"

[home_manager]
cli_tools = true
zsh       = true
gh        = true
git       = true

[home_manager.ghostty]
enable = true

[home_manager.starship]
enable = true

[darwin.features]
appearance = true
dock       = true
finder     = true
input      = true
power      = true

[darwin.dock]
autohide    = false
orientation = "left"

[darwin.power]
sleep = "never"

[darwin.homebrew]
enable      = true
install     = true
brew_bundle = true
```

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | TOML Host Templateのファイル配置 | `hosts/<name>/config.nix`（Nix）と並存させる場合のファイル名が未決。`template.toml` / `host.toml` など | `hosts/<name>/template.toml` を採用する（Brewfileと同ディレクトリにまとめる） |
| 2 | TOMLフィールド命名規則 | TOML慣行はsnake_case。既存NixコードはcamelCase。混在するとValidatorの変換コストが増える | TOML側はsnake_caseに統一し、NixへのValidatorが `cli_tools` → `cliTools` 等を変換する |
| 3 | `configFile` のTOML表現 | 現在 `hostConfig.homeManager.ghostty.configFile` はNix pathで渡している。TOMLで同等を表現する方法が未決 | TOML managed toolには `enable` のみを持ち、`configFile` はNix側Validatorがmodule-registryのpathから自動解決する |
| 4 | [`lib/host-config.nix` L32–33](../../lib/host-config.nix#L32) | `configFile` を `builtins.isPath` で型検査している。TOML経由ではpathではなくstringになるため型検査が失敗する | TOML Validator出力ではconfigFileをNix path（`/. + string`）に変換するか、Nix側の型検査を文字列も許容するように変更する |
| 5 | TOMLパースのレイヤー分担 | Python Validatorと `builtins.fromTOML`（Nix）で二重実装になるリスクがある | **Python**：Application Service層（CLI/Wizard）でのTOML読込・スキーマ検証・Instance生成。**Nix**：`builtins.fromTOML` でRoot flake checks用にTOMLを直接パース。処理の重複を避けるため役割を明示する |
| 6 | Python Validatorのコード配置 | Pythonコードの置き場所が未決。`scripts/`、`lib/`、`src/` など選択肢がある | `scripts/validator/` を新設し、`host_template.py`（スキーマ定義＋検証）を置く。Application Service全体の骨格は別issueとする |
| 7 | Root flake checksへのTOML組み込み方法 | 現在 `hostConfigs = import ./hosts;` はNix configをimportしている。TOML Hostをchecksに追加する方法が未決 | `hosts/default.nix` を拡張し `template.toml` が存在するHostは `builtins.fromTOML + validateHostConfig` を経由してロードする。移行期間中はNixとTOMLが並存する |
| 8 | `managedTools` とTOML Validatorの関係 | [`lib/host-registry.nix` L2](../../lib/host-registry.nix#L2) の `managedTools` リストは「attrsetコンフィグを持つtool」を区別するためにある。Python ValidatorもこのリストからTOML schemaを生成する必要がある | Python ValidatorはRegistryとは独立してtoolリストを持つか、`host-registry.nix` の内容をJSONでエクスポートしてPythonから読む |

---

## 優先度まとめ

### 着手前に確定（スキーマ設計の前提）

- **#1**: `template.toml` ファイル名と配置 — 全後続実装に影響
- **#2**: snake_case統一 — TOMLスキーマとValidatorの変換コードに影響
- **#3**: `configFile` のTOML表現 — managed toolの設計判断
- **#5**: Python vs Nix のレイヤー分担 — 実装スコープを確定させる

### 実装中に判断

- **#4**: `lib/host-config.nix` の型検査変更 — TOML Host追加時に実際の問題として現れる
- **#6**: `scripts/validator/` 配置 — コード作成時に確定
- **#7**: Root flake TOML組み込み方法 — `hosts/default.nix` 変更時に確定
- **#8**: `managedTools` とPython Validatorの関係 — Validator実装時に確定

---

> 意思決定の記録 → [`docs/decisions/2026-06-21-issue-46-toml-host-validator.md`](../decisions/2026-06-21-issue-46-toml-host-validator.md)
