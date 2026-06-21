# プロジェクトコンテキスト読込ポリシー

このポリシーは、AIエージェントが変更前に読むプロジェクト固有情報の正本です。
全プロジェクト共通の規約はグローバル`AGENTS.md`、設計手順は
`$design-maintainable-system`から継承し、この文書では再定義しません。

## 目次

- [1. 常に読む文書](#1-常に読む文書)
- [2. 設計・実装前に読む文書](#2-設計実装前に読む文書)
- [3. 作業別の追加文書](#3-作業別の追加文書)

## 1. 常に読む文書

- [`policy.md`](policy.md)
- [`risk_policy.md`](risk_policy.md)
- [`review_checklist.md`](review_checklist.md)
- [`protected_paths.txt`](protected_paths.txt)
- 作業対象Issueの最新Decision Record

## 2. 設計・実装前に読む文書

設計または実装を計画する前に、次の順番で読みます。

1. [`../REQUIREMENTS.md`](../REQUIREMENTS.md)
2. [`../DESIGN.md`](../DESIGN.md)
3. [`../architecture/README.md`](../architecture/README.md)
4. 作業対象に対応する`docs/architecture/`の詳細設計
5. [`../DEVELOPMENT.md`](../DEVELOPMENT.md)
6. 変更対象ディレクトリのREADMEと対応Test

> [!IMPORTANT]
> 要件または設計と矛盾する実装を進めません。矛盾、未決事項、実装不能な前提を発見した場合は、
> コードより先に設計判断を提示し、Decision Recordへ記録します。

## 3. 作業別の追加文書

| 作業                                 | 追加で読む文書                                                                             |
| ------------------------------------ | ------------------------------------------------------------------------------------------ |
| 要件定義、システム設計、設計レビュー | `$design-maintainable-system`                                                              |
| Setup Wizard、初回導入、CLI          | [`../architecture/user-workflow.md`](../architecture/user-workflow.md)                     |
| Instance、Profile、適用、rollback    | [`../architecture/instance-and-deployment.md`](../architecture/instance-and-deployment.md) |
| Homebrew、MAS、Dock、アプリ          | [`../architecture/app-management.md`](../architecture/app-management.md)                   |
| Module、Registry、Test、CI           | [`../architecture/testing.md`](../architecture/testing.md)                                 |
| Markdownまたは利用者向け文書         | グローバル`AGENTS.md`の共通文書規約                                                        |

軽微な誤字修正や作業対象外の詳細設計まで無条件に読み込む必要はありません。作業の責任範囲に
応じて必要な文書を選び、コンテキストを過不足なく取得します。
