# コードレビュー: feat/config-improvements

> このレビューは [Claude Sonnet 4.6](https://claude.ai) によって 2026-06-16 に自動生成されました。
> 対象ブランチ: `feat/config-improvements` (main からの差分)

---

## レビュー観点

- ドキュメント — 完全性・正確性・コメントの質
- 設計 — 関心の分離・拡張性・一貫性
- テスト — カバレッジ・独立性・CI との対応
- 実装 — 一貫性・堅牢性・慣用表現

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 | 意思決定 |
|---|---|---|---|---|
| 1 | `README.md` L39/43/47/51/59 | コマンド例が `24.11` 参照、flake.nix は `25.05` 済み | `25.05` に全置換 | |
| 2 | `README.md` | `hisuilab.nix` の手動作成が必要なことが未記載 | セットアップ手順セクションを追加 | |
| 3 | `README.md` | Nix インストール・Flakes 有効化手順なし | 前提条件セクションを追加 | |
| 4 | `p10k/README.md` | Linux 環境での適用コマンドなし | `home-manager switch` コマンドを追記 | |
| 5 | `flake.nix:74-78` | `validatedHostConfigs` 経由で渡しているのに `mkDarwinConfiguration` / `mkHomeConfiguration` 内で `validateHostConfig` を再実行（二重バリデーション） | MockEval 呼び出し側は検証済み値を直接使うよう関数を分割 | |
| 6 | `flake.nix:46-56` | `filterHosts` が `listToAttrs(map(filter(...)))` と迂回、`lib.filterAttrs` で1行化できる | `let lib = nixpkgs.lib;` を追加して `lib.filterAttrs` に置換 | |
| 7 | `flake.nix:102-109` | `autoMigrate = true` / `mutableTaps = true` が flake にハードコード。ホストごとに変えられない | `hosts/*/config.nix` の `darwin.homebrew` に移譲 | |
| 8 | `host-config.nix:103` / `modules/home/default.nix` | `managedTools` リストが2箇所に存在、新ツール追加時に両方の修正が必要 | `host-registry.nix` に一元化 | |
| 9 | `p10k.zsh:20` | `[[ -f ]]` で空ファイルを通過させると `P10K_THEME=""` になり `theme//.zsh` というパスになる | `[[ -s "$_p10k_state" ]]`（空でないファイルか確認）に変更 | |
| 10 | `10-utils.zsh:43,69` | `echo` を使用。zsh では `print` が慣用表現 | `echo plain` → `print plain` に統一 | |
| 11 | `01-palette.zsh:9` vs `10-utils.zsh:63` | カラー指定が `%F{red}` と `%F{1}` で混在 | どちらかに統一（`%F{1}` 推奨） | |
| 12 | `user-profiles/default.nix:73-77` | `importUserProfile` が `loadUserProfile` の薄いラッパーで用途の違いが不明 | 削除して `loadUserProfile` に一本化、またはコメントで使い分けを明記 | |
| 13 | `.github/workflows/ci.yml` | `aarch64-linux.raspberryPi5MockEval` がどのジョブにも対応していない（評価のみ、実ビルドなし） | `linux-check` または専用ジョブで実ビルドを追加 | |
| 14 | `flake.nix:238-247` | `macMiniMockEval` / `macbookAirMockEval` がホスト名直書きで、ホスト追加のたびに手動更新が必要 | `darwinHosts` を `mapAttrs` で自動展開するパターンに変更 | |
| 15 | `darwin/integration.nix` | 複数アサーションを1つの `if` に詰め込んでおり失敗箇所の特定が困難、他テストと `lib.runTests` スタイルが不統一 | `lib.runTests` ベースに統一 | |
| 16 | `home/integration.nix` | ghostty / p10k / zed フラグを統合レベルで未検証（`app-configs` 単体テスト止まり） | 統合テストにアプリ設定フラグのケースを追加 | |

---

## 優先度まとめ

### 今すぐ対応（バグ・誤情報）

- **#1** `README.md` バージョン不一致（`24.11` → `25.05`）
- **#9** `p10k.zsh` 空 state ファイル未ガード（`-f` → `-s`）
- **#13** `raspberryPi5MockEval` がCI未実行

### 近いうちに対応（保守性・設計）

- **#5** 二重バリデーション
- **#6** `filterHosts` を `lib.filterAttrs` 化
- **#8** `managedTools` リスト二重管理
- **#14** Darwin MockEval のホスト名直書き

### 機会があれば対応（品質向上）

- **#2/#3** README セットアップ手順
- **#4** p10k README Linux 手順
- **#7** Homebrew ポリシーの hosts 移譲
- **#10/#11** zsh 慣用表現・カラー指定の統一
- **#12** `importUserProfile` の整理
- **#15/#16** テストスタイル統一・統合テスト拡充

---

## 意思決定の記録

> 指摘に対してどう判断したか、背景・理由とともに記録します。

| # | 判断 | 理由・備考 |
|---|---|---|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |
| 7 | | |
| 8 | | |
| 9 | | |
| 10 | | |
| 11 | | |
| 12 | | |
| 13 | | |
| 14 | | |
| 15 | | |
| 16 | | |
