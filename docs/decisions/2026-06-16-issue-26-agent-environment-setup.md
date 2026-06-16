# 意思決定の記録: issue-26-agent-environment-setup

> 記録日: 2026-06-16
> レビュー → `docs/reviews/2026-06-16-issue-26-agent-environment-setup.md`

---

| # | 判断 | 優先度 | 理由・備考 |
|---|---|---|---|
| 1 | 対応する | 高 | `CLAUDE.md` を作成。含める内容: セキュリティ制約（ユーザープロファイルコミット禁止）・ワークフロー概要（Option A: issue 先立て）・git 破壊的操作禁止・外部ライブラリ/CI 注意事項 |
| 2 | 対応する（このissueに含める） | 中 | `AGENTS.md` を作成。CLAUDE.md と同等の内容をエージェント非依存な形式で記載する |
| 3 | 対応する | 中 | `.claude/commands/` に `/review` / `/decide` / `/issue` / `/implement` の 4 コマンドを作成 |
| 4 | #1 に含める | — | CLAUDE.md のワークフロー概要セクションにセッション開始時の確認手順（`git log --oneline -10` と `docs/decisions/` 最新ファイルの確認）を明記 |
| 5 | #1 に含める | — | CLAUDE.md の git 禁止事項セクションに `git status` 確認＋ユーザー承認の手順を明記 |
| 6 | #1 に含める | — | CLAUDE.md の外部ライブラリ・CI 注意事項に「GitHub Action ハッシュは `gh release view` で取得し推測禁止」を明記 |
| 7 | #1 に含める | — | CLAUDE.md の外部ライブラリ・CI 注意事項に「nix-darwin / home-manager の API は nixpkgs リポジトリを `grep` で確認してから使う」を明記 |
| 8 | #3 に含める | — | `.claude/commands/` の各コマンドファイルにテンプレートの埋め方と実行順を手順として記述 |
