# /decide — 意思決定の収集と記録

レビューファイルの指摘一覧を元に、ユーザーへ質問して判断を収集し、意思決定ファイルに記入する。

## 手順

1. `docs/reviews/` の最新ファイル（または現在の issue に対応するファイル）を読む
2. 指摘をグループ化する:
   - 複数の指摘が同じ対処案（例: 「CLAUDE.md に記載」）に収束する場合は1つの質問にまとめる
   - 独立した判断が必要なものは個別に質問する
3. AskUserQuestion ツールで質問し、判断を収集する（一度に3〜4問まで）
4. ファイルを作成する:
   ```
   docs/decisions/YYYY-MM-DD-issue-N-topic.md
   ```
5. `docs/decisions/template.md` の構成に沿って記入する（全指摘番号を行として記載）
6. issue 本文を `gh issue edit N --body "..."` で更新する（レビューの内容を反映）
7. コミットする: `docs(decisions): record decisions for issue-N topic`

## 質問の構成

- **multiSelect** を活用して「含める内容」を一括で選ばせる
- 優先度・スコープの判断（このissueに含める / 別issueに分ける / 見送る）を明示する
- 判断が `#N に含める` の場合は decisions テーブルにその旨を明記する
