# レビュー: fix/issue-32-macbook-air-build PR コードレビュー

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-19 |
| 対象ブランチ / PR | `fix/issue-32-macbook-air-build` |
| レビュー担当 | Claude Sonnet 4.6 (自動) |
| レビュー種別 | PR コードレビュー（`git diff main...HEAD`） |

---

## レビュー観点

`fix/issue-32-macbook-air-build` ブランチで実施した変更全体（`setup.sh` リネーム・対話式ホスト選択・`brewBundle` 再設計・ドキュメント整備）を `git diff main...HEAD` で確認し、実装上の不整合・クロスプラットフォーム動作・オプションの有効性を検査する。

---

## 指摘一覧

> 未適用項目のトラッキング → [issue #37](https://github.com/hisuilab/nix-station/issues/37)

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | [`setup.sh` L124](../../setup.sh#L124) | `sed -i ''` は BSD sed（macOS）専用の構文。`setup_user_profile()` は `setup_linux()` からも呼ばれるため、GNU sed（Linux）では `sed: invalid option -- ''` で失敗する | OS 判定で分岐する: macOS は `sed -i ''`、Linux は `sed -i` を使用する |
| 2 | [`hosts/macbook-air/config.nix` L41](../../hosts/macbook-air/config.nix#L41) / [`hosts/mac-mini/config.nix` L42](../../hosts/mac-mini/config.nix#L42) | `brewBundle = true: install.sh が brew bundle を実行する` というコメントが `setup.sh` へのリネーム後も `install.sh` のまま残っている | コメントを `setup.sh` に修正する |
| 3 | [`setup.sh` `brew_bundle()`](../../setup.sh) / [`docs/setup/nix/hosts.md` Homebrew セクション](../../docs/setup/nix/hosts.md) | `brewBundle` オプションは `config.nix`・`hosts.md`・`lib/host-config.nix` で「`setup.sh` が `brew bundle` を実行するかを制御する」と定義されているが、`setup.sh` はこのオプションを実際には読んでいない。現状は両ホストとも `brewBundle = true` のため動作上の問題はないが、`brewBundle = false` に設定しても `brew bundle` が実行されてしまう | `setup.sh` の `setup_darwin()` で `brewBundle` フラグを config.nix から読み取り、`false` の場合は `brew_bundle()` をスキップする |
| 4 | [`setup.sh` `select_host_id()`](../../setup.sh) | ホスト選択メニューが OS とホストの互換性を検証しない。Linux 上で darwin ホスト（`mac-mini` 等）を選択しても弾かれず、`darwin_rebuild` で cryptic なエラーになる | `select_host_id()` またはその後の OS 分岐で、選択ホストの `platform`（`darwin` / `home-manager`）と現在の OS を照合し、不一致の場合に早期エラーメッセージを出す |
| 5 | [`flake.nix`](../../flake.nix) / [`modules/system/darwin/core/default.nix`](../../modules/system/darwin/core/default.nix) | `darwinConfigurations.*` がユーザープロファイルを要求するため clone 直後の `nix flake check` が失敗する。`assertions` の guest チェックが評価時（`nix flake check` 含む）に発火し CI を壊す。OSS フレームワークとして `nix flake check` は常にグリーンであるべき | `darwinConfigurations` からパーソナルホストを外す・`assertions` の guest チェックを `activationScripts` へ移動・`user-profiles/*.nix` を `.gitignore` 化（詳細: [`docs/DESIGN.md`](../DESIGN.md)・[issue #36](https://github.com/hisuilab/nix-station/issues/36)） |
| 6 | [`flake.nix`](../../flake.nix) / [`tests/darwin/integration.nix`](../../tests/darwin/integration.nix) / `docs/**/*.md` / `hosts/windows-desktop/packages/*.json` | pre-commit フックが未適用のままコミットされたファイルが存在する。`nixpkgs-fmt` 対象: `flake.nix`・`tests/darwin/integration.nix`（2 件）。`prettier` 対象: Markdown 11 件・JSON 4 件（計 15 件） | `pre-commit run --files <対象ファイル>` を実行してフォーマットを適用してからコミットする |

---

## 優先度まとめ

### 今すぐ対応（バグ）

- **#1** `setup.sh` L124: Linux で `sed -i ''` が失敗する（クロスプラットフォームバグ）
- **#6** pre-commit 未適用: `nixpkgs-fmt`・`prettier` 対象ファイルにフォーマット違反

### 今すぐ対応（整合性）

- **#2** `hosts/macbook-air/config.nix` / `hosts/mac-mini/config.nix`: コメントの `install.sh` → `setup.sh` 修正
- **#3** `setup.sh` `brew_bundle()`: `brewBundle` オプションを実際に読み込んで制御する

### 設計対応（OSS 品質）

- **#5** `nix flake check` / `darwinConfigurations` / user profile の責務分離（[issue #36](https://github.com/hisuilab/nix-station/issues/36)）

### 近いうちに対応（UX 改善）

- **#4** `setup.sh` `select_host_id()`: OS / ホスト互換チェックの追加（issue-34 完了後）

---

> 意思決定の記録 → [docs/decisions/2026-06-19-issue-32-pr-review.md](../decisions/2026-06-19-issue-32-pr-review.md)
