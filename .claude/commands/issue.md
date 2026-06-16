# /issue — issue 作成とブランチ作成

新しい作業の起点。issue を最小限の内容で先に作成して番号を確定し、ブランチを切る。

## 手順

1. ユーザーに **タイトル** と **作業の種類**（feat / fix / refactor / docs / chore）を確認する
2. `gh issue create` で issue を作成（タイトル＋1〜2行の概要のみ。詳細は /review 後に更新）
3. 発行された issue 番号を確認する
4. ブランチを作成する:
   ```
   git checkout main && git pull
   git checkout -b type/issue-N-topic
   ```
5. ブランチ名・issue URL をユーザーに報告する

## 命名規則

- ブランチ: `type/issue-N-topic`（例: `feat/issue-26-agent-environment-setup`）
- topic は kebab-case・英語
