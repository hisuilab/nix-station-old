# Risky Change 定義 — nix-station

この定義が唯一の基準。`.claude` / `.agents` 側で独自に定義しない。

## リスク分類

### High — ユーザーの明示的な承認が必要

- `flake.nix` の inputs / outputs 変更（ビルド破壊の可能性）
- `flake.lock` の更新（依存バージョン変更）
- `user-profiles/*.nix` の変更（個人情報・認証情報を含む可能性）
- `.github/workflows/*.yml` の変更（CI パイプライン・secrets 操作）
- `modules/system/darwin/` のコア設定変更（darwin-rebuild switch が必要）
- `docs/ai/protected_paths.txt` の変更（保護範囲の変更）

### Medium — 実行前にユーザーへ変更内容を提示する

- `hosts/*/config.nix` の変更（ホスト設定の変更）
- `modules/` 配下の新規モジュール追加
- `Brewfile` の変更（パッケージ追加・削除）
- `.claude/settings.json` の変更

### Low — 通常の実装として進めてよい

- `docs/` 配下のドキュメント変更
- `tests/` 配下のテスト追加・修正
- `modules/home/` の設定追加（ユーザー環境のみ影響）
- `README.md` の更新

## 判断フロー

```
変更対象を特定
  │
  ├─ protected_paths.txt に一致？ → High: ユーザー承認を得る
  │
  ├─ flake.nix / flake.lock？ → High: ユーザー承認を得る
  │
  ├─ hosts / modules / Brewfile？ → Medium: 変更内容を提示して確認
  │
  └─ docs / tests / home modules？ → Low: 進めてよい
```
