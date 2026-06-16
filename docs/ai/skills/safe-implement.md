# Safe-implement

計画に基づいて安全に実装する。

## ルール

- 計画（plan-first の出力）を読んでから着手する
- 1変更 = 1コミットを原則とする（`/stage` → `/commit`）
- High リスクの変更は必ずユーザーに確認してから実行する
- 実装後に `scripts/ai/verify.sh` を実行して検証する
- `docs/ai/protected_paths.txt` のパスを変更する前に承認を得る
- 変更途中でスコープが広がった場合はユーザーに報告してから続ける

## 手順

1. plan-first の出力を確認する
2. リスク分類を確認し High があればユーザーへ承認を求める
3. 変更予定ファイルを 1 つずつ実装する
4. 各ファイル変更後に `/stage` → `/commit` する
5. 全変更後に `bash scripts/ai/verify.sh` を実行する
6. CI が通ることを確認する
