# /review — レビューファイルの作成

現在のブランチ・コード・課題をレビューし、指摘一覧を記録する。

## 手順

1. 現在の issue 番号とトピックを確認する（ブランチ名 or ユーザーに確認）
2. `git diff main...HEAD` と関連ファイルを読んで対象を把握する
3. ファイルを作成する:
   ```
   docs/reviews/YYYY-MM-DD-issue-N-topic.md
   ```
4. `docs/reviews/template.md` の構成に沿って記入する:
   - **レビュー観点**: 今回の対象に応じた観点を列挙
   - **指摘一覧**: 箇所（ファイルパス＋行番号リンク）・問題・対処案
   - **優先度まとめ**: 高 / 中 / 低 に分類
5. ファイル末尾に意思決定ファイルへのリンクを記載する:
   ```
   > 意思決定の記録 → `docs/decisions/YYYY-MM-DD-issue-N-topic.md`
   ```
6. コミットする: `docs(review): add review for issue-N topic`

## 注意

- 箇所のリンク形式: [`path/to/file.nix` L42](../../path/to/file.nix#L42)
- レビューファイルを作成する前に issue が存在すること（/issue を先に実行）
