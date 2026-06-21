# nix-station 開発ガイド

> [!IMPORTANT]
> このガイドは現行実装で使用できるコマンドと、目標設計へ移行するための開発規約を
> 分けて記載します。目標設計のパスを、実装済みの機能として扱わないでください。

## 目次

- [1. この文書の責任](#1-この文書の責任)
- [2. nix-station固有の開発制約](#2-nix-station固有の開発制約)
- [3. 開発フロー](#3-開発フロー)
- [4. 移行状況の参照](#4-移行状況の参照)
- [5. 現行実装の拡張手順](#5-現行実装の拡張手順)
  - [5.1. Host](#51-host)
  - [5.2. User Profile](#52-user-profile)
  - [5.3. Home Manager tool](#53-home-manager-tool)
  - [5.4. nix-darwin feature](#54-nix-darwin-feature)
- [6. ローカル検証](#6-ローカル検証)
- [7. レビューとPull Request](#7-レビューとpull-request)

## 1. この文書の責任

この文書は、安全に変更・検証・レビューする方法を定義します。

| 知りたいこと | 参照先 |
|---|---|
| プロダクト要件 | [`REQUIREMENTS.md`](REQUIREMENTS.md) |
| 目標アーキテクチャ | [`DESIGN.md`](DESIGN.md) |
| 設計文書の索引 | [`architecture/README.md`](architecture/README.md) |
| 現行のHost設定 | [`setup/nix/hosts.md`](setup/nix/hosts.md) |
| 現行のProfile設定 | [`setup/nix/user-profiles.md`](setup/nix/user-profiles.md) |
| AI開発ポリシー | [`ai/policy.md`](ai/policy.md) |

## 2. nix-station固有の開発制約

- 個人Profileと秘密情報をコミットしない
- 現行実装と未実装の目標設計を混同しない
- Framework Qualityの検証へ個人Profileや実機状態を持ち込まない
- nix-darwinとHome Managerのoptionは使用前に存在を確認する
- protected pathを変更する前に承認を得る

汎用的な設計、文書、ディレクトリ責任、Test構造の規約は、グローバル`AGENTS.md`と
`$design-maintainable-system`から継承します。

## 3. 開発フロー

1. Issueへ背景、目的、要件、完了条件を記載する
2. `type/issue-N-topic`形式でブランチを作成する
3. `docs/reviews/`へ調査結果を記録する
4. `docs/decisions/`へ設計判断を記録する
5. 変更対象、リスク、検証、rollbackを計画する
6. 失敗を再現するTestまたは検証方法を用意する
7. 責務単位で実装する
8. 必須検証とセルフレビューを実行する
9. 明示的な指示後にstage、commitする
10. Draft Pull Requestを作成し、CI成功後にreadyへ変更する

コミットはConventional Commits形式の英語メッセージを使用します。

```text
feat(setup): add host selection flow
fix(flake): isolate deploy outputs from checks
docs(design): explain runtime profile selection
```

## 4. 移行状況の参照

現行実装と目標設計の差分、実装状況は
[`アーキテクチャ索引の移行状況`](architecture/README.md#3-移行状況)を正本とします。
移行完了までは、この文書の現行実装手順を使用します。

## 5. 現行実装の拡張手順

### 5.1. Host

1. `hosts/<host-id>/config.nix`を作成する
2. `hosts/default.nix`へ登録する
3. `builder`、`os`、`system`、`environment`の互換性を確認する
4. Home Manager toolとDarwin featureを選択する
5. `scripts/ai/verify.sh`でHost checkを確認する

### 5.2. User Profile

個人Profileは`user-profiles/<name>.nix`へ作成します。標準ではGit管理対象外です。
必須値は`username`、`git.userName`、`git.userEmail`とします。

### 5.3. Home Manager tool

1. `modules/home/<tool>/default.nix`を追加する
2. `modules/home/default.nix`のrouterへ登録する
3. managed toolの場合はRegistryへ登録する
4. 対応するUnit Testと必要なIntegration Testを追加する

### 5.4. nix-darwin feature

1. `modules/system/darwin/features/<feature>/default.nix`を追加する
2. feature routerへ登録する
3. Hostで明示的に有効化する
4. defaultsとactivationのTestを追加する

実機状態を変更するactivationは、通常のdefaultsから分離します。

## 6. ローカル検証

Test責任と階層は[`TestとCI設計`](architecture/testing.md)を正本とします。

```bash
# 全Host、Module、Unit Testの評価
bash scripts/ai/verify.sh

# Unit Testの実ビルド
nix build path:.#checks.aarch64-darwin.tests --no-link

# Host構成の実ビルド例
nix build path:.#checks.aarch64-darwin.mac-mini --no-link
nix build path:.#checks.x86_64-linux.ubuntu-wsl --no-link

# 静的検査
pre-commit run --all-files

# 共通ポリシー検査
bash scripts/ai/risk-check.sh
bash scripts/ai/secret-scan.sh
```

Framework Qualityの最終基準は`nix flake check path:. --no-build --all-systems`とします。
個人Profileや実機条件を要求してはいけません。

## 7. レビューとPull Request

Pull Request前に次を確認します。

- 要件と完了条件を満たす
- 変更が1つの責任に限定されている
- protected pathの変更が承認済みである
- 個人Profile、秘密情報、意図しない`flake.lock`変更を含まない
- 新機能と回帰に対応するTestがある
- `git diff`とstage対象を確認した
- 必須検証が成功している
- 要件、設計、README、利用手順を更新した

Draft Pull RequestにはIssue、設計判断、完了条件、検証結果、リスク、rollbackを記載します。
詳細は[`ai/review_checklist.md`](ai/review_checklist.md)を参照します。
