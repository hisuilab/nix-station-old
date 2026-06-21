# 意思決定の記録: issue-36-system-architecture

> 記録日: 2026-06-21

| # | 判断 | 理由・備考 |
|---|---|---|
| 1 | Hostは共有Templateとする | 個人・組織で再利用し、Instance情報を混入させないため |
| 2 | Profileは適用時に選択する | Hostを変更せず、利用者との関連付けを明示するため |
| 3 | Device Instanceをリポジトリ外へ保存する | ZIP更新とFramework更新から個人設定を保護するため |
| 4 | 標準保存先を`~/.config/nix-station`とする | FrameworkとInstanceを物理的に分離するため |
| 5 | local deploy flakeを使用する | Root checksから個人Deploy Outputを分離するため |
| 6 | Roleを廃止する | 実際の責任が薄く、挙動の暗黙依存を作っているため |
| 7 | Template名を`<os>-<usage>[-<variant>]`とする | `laptop`、`desktop`、`server`を人間向け分類として残すため |
| 8 | Host、Profile、Instance、App CatalogをTOML化する | 非NixユーザーとWizardが安全に扱えるデータ形式にするため |
| 9 | Nix内部実装はNixで維持する | Module、path、関数、optionを自然に表現するため |
| 10 | App CatalogからBrewfileとDockを生成する | 標準・Brew・MAS・手動アプリを1つのID体系で扱うため |
| 11 | Registryを機能定義の正本とする | Router、機能一覧、Test対象の二重管理を防ぐため |
| 12 | Testは実装構造をミラーする | 対応Testをパスから発見可能にするため |
| 13 | Module、README、Testの存在をCIで検証する | 機能追加時の登録・文書・Test漏れを防ぐため |
| 14 | `docs/FEATURES.md`をRegistryから生成する | 機能一覧の手動同期を廃止するため |
| 15 | Runtime Brewfileはlocal生成物とする | App Catalogを正本とし、手編集による不整合を防ぐため |
| 16 | Nixは利用者が手動で導入する | Wizardによる不透明なシステム変更を避けるため |
| 17 | Wizard詳細は利用者フロー設計後に確定する | 実装都合ではなく利用体験から責任を決めるため |
| 18 | Wizardは初回導入の対話UIに限定する | 日常操作と検証・適用ロジックを重複させないため |
| 19 | WizardとCLIはApplication Serviceを共有する | 対話方法に依存しない検証、ビルド、適用を実現するため |
| 20 | 説明文は「です・ます調」に統一する | 非Nixユーザーにも読みやすい文書へ統一するため |
