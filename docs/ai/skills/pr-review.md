# PR-review

PRをレビューして問題点を報告します。

## 手順

1. `git diff main...HEAD` で変更全体を確認する
2. `docs/ai/review_checklist.md` の全項目をチェックする
3. `bash scripts/ai/risk-check.sh` を実行する
4. `bash scripts/ai/secret-scan.sh` を実行する
5. 問題点を以下のフォーマットで報告する:

```
## レビュー結果

### 必須対応
- [ ] #1: path/to/file.nix L42 — 問題の説明

### 推奨対応
- [ ] #2: path/to/file.nix L10 — 改善案

### 確認済み
- [x] protected_paths チェック: 問題なし
- [x] secret スキャン: 問題なし
- [x] nix flake check: 通過
```

6. `docs/decisions/` に意思決定記録があるか確認する（非自明な変更の場合）
