# nix-station — Claude 向けガイド

## セキュリティ制約

- `user-profiles/*.nix` は `default.nix` / `guest.nix` / `test.nix` 以外コミット禁止（`.gitignore` で管理）
- コミット前に `git diff --staged` でステージ内容を必ず確認する

## 開発ワークフロー（Option A: issue 先立て）

```
1. /issue  — gh issue create でissueを作成（タイトル＋概要のみ）→ ブランチ作成
2. /review — docs/reviews/YYYY-MM-DD-issue-N-topic.md を作成・記入
3. /decide — 指摘ごとにユーザーへ質問し意思決定を収集・記入
             issue 本文も更新する
4. /implement — 意思決定ファイルを読んで指摘ごとにコミットして実装
5. PR → マージ
```

**セッション開始時の確認（継続作業の場合）:**
```
git log --oneline -10
```
`docs/decisions/` の最新ファイルを読んで前セッションの判断を把握してから着手する。

**命名規則:**

| 対象 | 形式 |
|---|---|
| ブランチ | `type/issue-N-topic` |
| レビュー | `docs/reviews/YYYY-MM-DD-issue-N-topic.md` |
| 意思決定 | `docs/decisions/YYYY-MM-DD-issue-N-topic.md` |
| コミット | Conventional Commits（`feat` / `fix` / `refactor` / `docs` / `chore`） |

## git 禁止事項

以下を実行する前に **必ず `git status` で未コミット変更を確認し、ユーザーの承認を得る**:

- `git reset --hard`
- `git checkout .` / `git restore .`
- `git clean -f`
- `git push --force`

## 外部ライブラリ・CI の注意事項

- **GitHub Action のコミットハッシュ**: `gh release view <tag> --repo <owner/repo>` で取得する。推測・補完禁止
- **nix-darwin / home-manager の API**: 使用前に nixpkgs の対応モジュール定義を `grep` で存在確認する
- **CI 失敗時の調査**: `gh run view --log-failed` でログを確認する
