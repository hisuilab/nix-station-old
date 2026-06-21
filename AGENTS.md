# AGENTS.md

このリポジトリは共通 AI 開発ポリシーを使用しています。

全プロジェクト共通の文書・設計規約は、グローバル`AGENTS.md`と
`$design-maintainable-system`から継承します。このファイルでは再定義しません。

実装に着手する前に必ず読んでください:

- [`docs/ai/policy.md`](docs/ai/policy.md)
- [`docs/ai/context_policy.md`](docs/ai/context_policy.md)
- [`docs/ai/risk_policy.md`](docs/ai/risk_policy.md)
- [`docs/ai/review_checklist.md`](docs/ai/review_checklist.md)
- [`docs/ai/protected_paths.txt`](docs/ai/protected_paths.txt)

## 絶対ルール（セッション開始時に必ず守る）

**自動コミット禁止**: `/stage → /commit` を呼ぶまで `git commit` しない

**git 禁止事項（事前に `git status` + ユーザー承認が必要）**:
`git reset --hard` / `git checkout .` / `git restore .` / `git clean -f` / `git push --force`

**コミットメッセージ**: Conventional Commits 形式・英語 / **ブランチ**: `type/issue-N-topic`

詳細は [`docs/ai/policy.md`](docs/ai/policy.md) を参照。

---

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
