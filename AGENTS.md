# AGENTS.md

このリポジトリは共通 AI 開発ポリシーを使用しています。

実装に着手する前に必ず読んでください:

- [`docs/ai/policy.md`](docs/ai/policy.md)
- [`docs/ai/risk_policy.md`](docs/ai/risk_policy.md)
- [`docs/ai/review_checklist.md`](docs/ai/review_checklist.md)
- [`docs/ai/protected_paths.txt`](docs/ai/protected_paths.txt)

必須ワークフロー:

1. 計画を立てる（ファイルを編集する前に）
2. リスクを分類する（`docs/ai/risk_policy.md` 基準）
3. 保護パスを変更する場合はユーザーの明示的な承認を得る
4. 以下を実行する:

```bash
bash scripts/ai/verify.sh
bash scripts/ai/risk-check.sh
bash scripts/ai/secret-scan.sh
```

---

`docs/ai/` 配下が Single Source of Truth。このファイルは Codex / 汎用エージェント向けの入口にすぎない。
