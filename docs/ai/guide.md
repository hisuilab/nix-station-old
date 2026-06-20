# AI エージェント コントロールガイド

このガイドは AI エージェント（Claude / Codex 等）をプロジェクトで安全に活用するための運用リファレンスです。
他プロジェクトへの転用を想定した汎用テンプレートとして記述しています。

---

## アーキテクチャ概要

```
docs/ai/              ← Single Source of Truth（ルール・スキル本体）
scripts/ai/           ← 実行強制（hook から呼ぶだけ）
AGENTS.md             ← 汎用エージェント向け薄い入口
CLAUDE.md             ← Claude Code 向け薄い入口（@AGENTS.md + スラッシュコマンド）
.claude/              ← Claude adapter（settings / hooks / skills wrapper）
.agents/              ← Codex / 汎用エージェント adapter
```

**原則**: ルールを書く場所は `docs/ai/` だけ。`.claude/` や `.agents/` はそこを読む入口にすぎない。

---

## ワークフロー

### issue → 実装 → PR の全体フロー

```
1. /issue
   │  gh issue create でタイトル＋概要のみ作成
   │  ブランチを作成: type/issue-N-topic
   │
2. /review
   │  docs/reviews/YYYY-MM-DD-issue-N-topic.md を作成・記入
   │  docs/decisions/YYYY-MM-DD-issue-N-topic.md を空テンプレートで同時生成
   │
3. /decide
   │  指摘ごとにユーザーへ質問して判断を収集
   │  docs/decisions/ に記入・issue 本文を更新
   │
4. /implement
   │  意思決定ファイルを読んで指摘ごとに実装
   │  実装前に /plan-first でリスク確認（High リスクはユーザー承認を得る）
   │
5. /stage → /commit
   │  テーマ単位でステージ → コミット
   │  /stage: git add まで
   │  /commit: decisions 記入漏れ確認 → コミット名案提示 → git commit
   │
6. PR → マージ
```

### 継続セッション開始時

```bash
git log --oneline -10
# docs/decisions/ の最新ファイルを読んで前回の判断を把握してから着手する
```

---

## スキル・コマンド一覧

### スキル（呼ばれたときだけロード）

| スキル           | 呼び方            | 内容                                       |
| ---------------- | ----------------- | ------------------------------------------ |
| `plan-first`     | `/plan-first`     | 実装前に計画を立てる。ファイルは編集しない |
| `safe-implement` | `/safe-implement` | 計画に基づいて安全に実装する               |
| `risk-check`     | `/risk-check`     | 変更のリスクを評価し保護パスをチェックする |
| `pr-review`      | `/pr-review`      | PR をレビューして問題点を報告する          |

スキルの本体: `docs/ai/skills/<name>.md`
Claude adapter: `.claude/skills/<name>/SKILL.md`（thin wrapper）
Codex adapter: `.agents/skills/<name>/SKILL.md`（thin wrapper）

### ワークフローコマンド（Claude Code 専用）

| コマンド     | 役割                                             |
| ------------ | ------------------------------------------------ |
| `/issue`     | issue 作成・ブランチ作成                         |
| `/review`    | レビューファイル＋意思決定テンプレート作成       |
| `/decide`    | 意思決定収集・記入                               |
| `/implement` | 意思決定に基づく実装                             |
| `/stage`     | テーマ別ステージング（git add まで）             |
| `/commit`    | ステージ内容確認 → コミット名案提示 → git commit |

---

## リスク管理・保護パス

### リスク分類（`docs/ai/risk_policy.md` が唯一の定義）

| レベル     | 対応                             | 典型例                                                    |
| ---------- | -------------------------------- | --------------------------------------------------------- |
| **High**   | ユーザーの明示的な承認が必要     | `flake.nix` 変更 / CI ワークフロー変更 / 保護パスへの変更 |
| **Medium** | 変更内容をユーザーへ提示して確認 | ホスト設定変更 / パッケージ追加                           |
| **Low**    | 通常の実装として進めてよい       | ドキュメント / テスト / ユーザー環境モジュール            |

### 保護パス（`docs/ai/protected_paths.txt` が唯一の定義）

保護パスへの変更は以下の手順を踏む:

1. ユーザーへ変更内容と理由を提示する
2. 明示的な承認を得る
3. `bash scripts/ai/risk-check.sh` を実行してからコミットする

保護パスの定義を変更する場合も同様に承認が必要（定義自体が High リスク）。

---

## verification スクリプト

実装後・コミット前に実行する:

```bash
bash scripts/ai/verify.sh           # プロジェクト固有の検証（例: nix flake check）
bash scripts/ai/risk-check.sh       # 保護パスへの変更を検出
bash scripts/ai/secret-scan.sh      # 秘密情報のパターンを検出
bash scripts/ai/hidden-content-scan.sh  # 隠しファイル・バイナリを検出
```

hooks（`.claude/hooks/policy-gate.sh`）は `risk-check` と `secret-scan` を自動実行する。

---

## 新しいスキル・ルールの追加方法

### スキルを追加する

1. `docs/ai/skills/<name>.md` に本体を書く（ゴール・ルール・出力フォーマット）
2. `bash scripts/ai/sync-agent-adapters.sh` を実行する
   - `.claude/skills/<name>/SKILL.md` と `.agents/skills/<name>/SKILL.md` が自動生成される
3. wrapper の内容を必要に応じて調整する

```bash
# 例: debug というスキルを追加する
echo "# Debug\n\nデバッグ手順..." > docs/ai/skills/debug.md
bash scripts/ai/sync-agent-adapters.sh
```

### ポリシー・ルールを変更する

| 変更したい内容                         | 編集するファイル              |
| -------------------------------------- | ----------------------------- |
| 開発ワークフロー・git ルール・命名規則 | `docs/ai/policy.md`           |
| リスク分類基準                         | `docs/ai/risk_policy.md`      |
| レビュー観点                           | `docs/ai/review_checklist.md` |
| 保護パスの追加・削除                   | `docs/ai/protected_paths.txt` |
| 検証コマンドの変更                     | `scripts/ai/verify.sh`        |

**`.claude/` や `.agents/` 側は編集しない。** そちらは `docs/ai/` を読む入口にすぎない。

### 二重管理してよいもの・してはいけないもの

| 二重管理 OK                                               | 理由                               |
| --------------------------------------------------------- | ---------------------------------- |
| `.claude/settings.json`                                   | Claude Code 固有の仕様             |
| `.claude/skills/*/SKILL.md` / `.agents/skills/*/SKILL.md` | ツール discovery 用の thin wrapper |

| 二重管理 NG              | 理由                         |
| ------------------------ | ---------------------------- |
| 保護パスの定義           | ずれると危険                 |
| リスク分類基準           | 承認基準が割れる             |
| レビューチェックリスト   | AI と人間の観点がずれる      |
| verification コマンド    | 「片方では通った」が発生する |
| 秘密情報スキャンパターン | 検知漏れが発生する           |

---

## このプロジェクトへの転用方法

1. `docs/ai/` ディレクトリをコピーする
2. `docs/ai/policy.md` をプロジェクトのルール・ワークフローに書き換える
3. `docs/ai/risk_policy.md` をプロジェクトの技術スタックに合わせて書き換える
4. `docs/ai/protected_paths.txt` にプロジェクトの保護パスを列挙する
5. `scripts/ai/verify.sh` をプロジェクトの検証コマンドに書き換える
6. `AGENTS.md` / `CLAUDE.md` の参照先を確認する
7. `bash scripts/ai/sync-agent-adapters.sh` を実行して adapter を生成する
