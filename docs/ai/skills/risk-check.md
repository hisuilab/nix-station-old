# Risk-check

変更前にリスクを評価し、必要な承認を確認する。

## 手順

1. `git diff --staged --name-only` で変更ファイルを確認する
2. `bash scripts/ai/risk-check.sh` を実行して保護パスをチェックする
3. `bash scripts/ai/secret-scan.sh` を実行して秘密情報をチェックする
4. `docs/ai/risk_policy.md` に従って各変更のリスクを分類する
5. リスク評価を出力する:

```
変更ファイル: path/to/file.nix
リスク: High
理由: flake.nix の inputs 変更
必要な承認: ユーザーの明示的な承認
```

6. High リスクがあれば実装を止めてユーザーへ確認する
