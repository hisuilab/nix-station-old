# コードレビュー: issue-54-setup-wizard

> 設計レビュー。このブランチには実装がなく、設計判断の収集が目的です。

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-21 |
| 対象ブランチ / PR | `feat/issue-54-setup-wizard` |
| レビュー担当 | Claude Sonnet 4.6 (自動) |
| レビュー種別 | 設計レビュー（実装前） |

---

## レビュー観点

今回は新規実装前の設計レビューです。以下の観点で判断が必要な箇所を洗い出します。

- **スコープ境界**: このissueに含める機能と次のissueに送る機能の分離
- **エントリーポイント設計**: `setup.sh` + Python の接続方法
- **Host ID 発見方法**: 静的リストと動的発見の選択
- **既存Instance検出**: `~/.config/nix-station/` が既にある場合の挙動
- **ファイル生成の安全性**: アトミック書き込み、テンプレートコピー
- **OS適用範囲**: 初版でサポートするOS

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | [`scripts/validator/instance.py` L28–34](../../scripts/validator/instance.py#L28) | `VALID_HOST_IDS` が `hosts/` ディレクトリの実態と独立したハードコードリストになっている。`hosts/` に新しいテンプレートを追加しても validator が自動追従しない | Wizardで `hosts/` を動的にスキャンして Host ID を取得するか、静的リストのままにするかを決定する |
| 2 | [`docs/architecture/user-workflow.md` L26–43](../../docs/architecture/user-workflow.md#L26) | Wizard が「評価とビルド（`darwin-rebuild switch`）」まで担当するフローが設計されているが、このissueで実装するか次のissueに送るかが未決 | スコープ決定：このissue = ファイル生成のみ、apply は次issue |
| 3 | [`docs/architecture/user-workflow.md` L85–99](../../docs/architecture/user-workflow.md#L85) | `setup.sh` を薄いエントリーポイントとすることは決まっているが、`setup.sh → Python` の起動方法（`nix run nixpkgs#python3`、`python3` 直接、シバン付きスクリプト）が未決 | 起動方法を決定する。他のスクリプトの実行パターンに合わせる |
| 4 | [`lib/templates/deploy-flake.nix` L1](../../lib/templates/deploy-flake.nix#L1) | Wizardが生成する `~/.config/nix-station/flake.nix` のテンプレートは既に `lib/templates/deploy-flake.nix` にある。Wizardがこのテンプレートをコピーするのか、文字列で動的生成するのかが未決 | テンプレートファイルをコピーする（動的生成は変更箇所が増えるため避ける） |
| 5 | [`docs/architecture/instance-and-deployment.md` L89](../../docs/architecture/instance-and-deployment.md#L89) | TOMLのアトミック書き込み（一時ファイル → rename）が設計で要求されているが、実装パターンが未決 | `tempfile.NamedTemporaryFile` + `os.replace()` を使う。標準Pythonで実現可能 |
| 6 | [`scripts/service/generate_brewfile.py`](../../scripts/service/generate_brewfile.py) | 初回セットアップ後に `generate_brewfile.py` を実行して Brewfile を生成する必要があるが、Wizard がこれを呼ぶかどうかが未決 | Wizardの完了時に `generate_brewfile.py` を呼び、生成済みの Brewfile パスを案内する |
| 7 | `scripts/service/wizard.py` (未作成) | 既存validator（`instance.py`, `profile.py`, `host_template.py`）はそれぞれ独立したエラークラスを持つ（`InstanceValidationError`, `ProfileValidationError`, `ValidationError`）。Wizardが複数を組み合わせる際のエラー統一が未決 | Wizardレイヤーで共通 `WizardError` に包むか、各エラーをそのまま catch して表示するかを決定する |
| 8 | `scripts/service/wizard.py` (未作成) | Wizardが対応するOSの範囲が未決。macOS（nix-darwin）のみか、Linux（ubuntu-desktop, ubuntu-wsl, raspberry-pi-5）も初版に含めるか | 初版の対応OS範囲を決定する |

---

## 優先度まとめ

### 今すぐ対応（スコープ確定・設計必須）

- **#2 スコープ境界**: ファイル生成のみかapplyまで含めるかでモジュール構成が変わる
- **#3 エントリーポイント起動方法**: 実装の出発点となる

### 近いうちに対応（実装前に決定）

- **#1 Host ID発見方法**: Wizard の選択肢UIに直結する
- **#4 flake.nixテンプレート扱い**: ファイル生成ロジックに影響する
- **#5 アトミック書き込み**: 安全性設計に必要
- **#8 OS適用範囲**: 対応Host IDと診断ロジックのスコープが変わる

### 機会があれば対応（品質向上）

- **#6 Brewfile生成タイミング**: Wizard完了体験に影響するが後から追加可能
- **#7 エラークラス統一**: 実装しながら決定できる

> 意思決定の記録 → `docs/decisions/2026-06-21-issue-54-setup-wizard.md`
