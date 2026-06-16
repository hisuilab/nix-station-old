# /implement — 意思決定に基づく実装

意思決定ファイルを読んで、対応する指摘を順に実装する。

## 手順

1. `docs/decisions/` の現在の issue に対応するファイルを読む
2. 「対応する」判断の指摘を優先度順（高→中→低）に並べる
3. 各指摘を**1件ずつ**実装し、コミットする:
   ```
   git add <変更ファイル>
   git commit -m "type(scope): 変更内容の要約"
   ```
4. すべての指摘の実装が完了したら `git log --oneline` で一覧を確認する
5. ユーザーに実装完了を報告し、PR 作成の確認を取る

## コミットのルール

- **1指摘 = 1コミット**（複数ファイルにまたがっても指摘単位でまとめる）
- Conventional Commits 形式: `feat` / `fix` / `refactor` / `docs` / `chore`
- コミットメッセージ末尾に `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>` を付ける

## 注意事項

- 実装前に `git status` で未コミット変更がないことを確認する
- `git reset --hard` などの破壊的操作は **`git status` 確認＋ユーザー承認なしに実行しない**
- nix-darwin / home-manager の API を使う場合は nixpkgs を `grep` で存在確認してから実装する
- GitHub Action のハッシュは `gh release view` で取得する（推測禁止）
