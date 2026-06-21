# レビュー: issue-36 システムアーキテクチャ

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-21 |
| 対象 | nix-station全体構造とissue #36 |
| レビュー担当 | Codex |
| レビュー種別 | 設計レビュー |

## 確認した課題

| # | 課題 | 影響 | 対応方針 |
|---|---|---|---|
| 1 | HostがProfile名と個人hostnameを保持し、共有できない | 個人・組織での再利用ができない | Hostを共有Templateとし、インスタンス情報をRuntime Targetへ移す |
| 2 | ProfileがHostに固定され、利用者との関連付けが静的になる | 同一HostをProfile切替で使えない | Profileを適用時に選択する構造にする |
| 3 | 個人設定がフレームワークリポジトリ内に混在する | ZIP更新時に個人設定が上書きされる | Device Instanceをリポジトリ外へ保存する |
| 4 | Instance保存先が未定義でFrameworkと物理的に分離できない | 保存場所が実装依存になる | 標準保存先を`~/.config/nix-station`と定める |
| 5 | `darwinConfigurations`が個人ProfileをRoot flakeから読む | Framework checkがDeploy状態に依存し、CIと実機で評価結果が変わる | local deploy flakeでRoot checksとDeploy Outputを分離する |
| 6 | RoleがDock・power・hostnameを暗黙に切り替える | Hostを読んでも実際の挙動が分からない | Roleを廃止し、挙動をTemplateへ明示する |
| 7 | Role廃止後のTemplate命名規則が未定義 | 用途がTemplate名から判断できない | Template名を`<os>-<usage>[-<variant>]`形式とする |
| 8 | Nix設定をShellで文字列解析する | schema変更に弱く、安全な更新が難しい | 利用者設定をTOML化し、構造化して処理する |
| 9 | TOML化の範囲が曖昧で内部Nixコードまで置換しようとする | Module・path・関数・optionの表現力が失われる | Nix内部実装はNixで維持し、利用者設定のみTOML化する |
| 10 | BrewfileとDock定義が分離しアプリIDと配置が重複する | アプリ追加・削除時に複数箇所を修正する必要がある | App Catalogを正本としてBrewfileとDockを生成する |
| 11 | Module・機能一覧・Testが個別管理で連動しない | 追加漏れと文書の陳腐化が起きる | Registryを機能定義の正本とし、一覧・Testを導出する |
| 12 | TestとImplementationの対応関係に規則がない | 実装に対応するTestをパスから発見できない | Testは実装ディレクトリ構造をミラーする |
| 13 | 機能追加時のModule登録・README・Testの漏れを検出できない | 陳腐化と未テストの機能が蓄積する | Module・README・Testの存在をCIで検証する |
| 14 | `docs/FEATURES.md`が手動管理でRegistryと乖離する | 機能一覧の同期コストが高く内容が古くなる | `docs/FEATURES.md`をRegistryから生成する |
| 15 | Runtime BrewfileがリポジトリにコミットされApp Catalogと不整合が生じる | 手編集による差分が蓄積し正本が不明確になる | Runtime Brewfileはローカル生成物とし、コミットしない |
| 16 | WizardがNixインストールを担当するとシステム変更が不透明になる | 利用者がシステムへの影響を把握できない | Nixは利用者が手動で導入する |
| 17 | Wizardの実装範囲が利用体験より先に設計される | 責任が実装都合になり、利用者視点の導線が壊れる | Wizard詳細は利用者フロー設計後に確定する |
| 18 | Wizardが初回導入と日常運用を両方担当する | 初回導線と日常操作が混在し、各フローが複雑になる | Wizardは初回導入の対話UIに限定する |
| 19 | WizardとCLIが独立実装され検証・適用ロジックが重複する | 対話方法ごとに挙動が乖離するリスクがある | WizardとCLIはApplication Serviceを共有する |
| 20 | 文書の文体が「である調」と「です・ます調」で混在する | 利用者向け文書のトーンが統一されていない | 利用者向け文書を「です・ます調」に統一する |

## 設計評価

- Host Template、Profile、Device Instanceの分離で個人・組織利用を両立できる
- local deploy flakeにより、Issue #36のFramework/Deploy責任分離が可能になる
- TOMLは非Nixユーザー向け入力、Nixは内部構成生成という境界が明確になる
- Role廃止後もTemplate名で用途を示し、挙動は明示設定として保持できる
- Registry駆動の構造検査でModule、README、Testの追加漏れをCIで検出できる

## 残る設計作業

- 初回利用、再適用、Template/Profile追加のユーザーワークフロー
- Wizardが担当する必須操作と、高度な利用者へ委譲する操作
- 既存Nix形式からTOMLへのmigration仕様
- local deploy flakeの生成・更新・rollback仕様

> 意思決定の記録 →
> [`docs/decisions/2026-06-21-issue-36-system-architecture.md`](../decisions/2026-06-21-issue-36-system-architecture.md)
