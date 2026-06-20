# レビュー: Mac mini M4 実機初期化セットアップで発見された課題

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-16 |
| 対象ブランチ / PR | `fix/issue-28-mac-mini-m4-fresh-setup` |
| レビュー担当 | Claude Sonnet 4.6 (自動) |
| レビュー種別 | 実機セットアップログ分析 |

---

## レビュー観点

Mac mini M4 を初期化して実際に `darwin-rebuild switch` → `brew bundle` を実行した際のログをもとに、
セットアップ手順の不備・コード上の設定漏れ・ドキュメントの不足を洗い出す。

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | [`hosts/mac-mini/config.nix` L11](../../hosts/mac-mini/config.nix#L11) | `userProfile.name` を `guest` から変更し忘れると `system.primaryUser = "guest"` になり activation 失敗 | `nix eval` による事前バリデーションを検討を追加。また使用するuserprofile,host情報をチェックするための情報を表示 実行確認も行うようにしたい |
| 2 | [`modules/system/darwin/core/default.nix` L12](../../modules/system/darwin/core/default.nix#L12) | Determinate Systems Nix インストーラーと nix-darwin の Nix 管理が競合。`nix.enable = false` を設定しないと `error: Determinate detected, aborting activation` で失敗 | `modules/system/darwin/core/default.nix` に `nix.enable = false;` を追加する（[公式ドキュメント推奨](https://docs.determinate.systems/guides/nix-darwin/)）。`nix.*` オプションが使えなくなるが、Nix 設定が必要な場合は `determinateNix.enable = true`（Determinate の nix-darwin モジュール）で代替可能 |
| 3 | [`README.md`](../../README.md) (Apply Configuration セクション) | Determinate インストーラーが作成した `/etc/zshenv`（SSH 接続時のみ nix-daemon.sh を読み込む内容）が nix-darwin の `/etc/zshenv` 管理と競合。`sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin` を手動実行しないと activation が失敗する | README の Apply Configuration 手順の直前に `/etc/zshenv` 退避ステップを追記する。`install.sh` 実装時（#6）には自動化も組み込む |
| 4 | [`modules/system/darwin/features/finder/default.nix` L6](../../modules/system/darwin/features/finder/default.nix#L6) | `mysides`（nixpkgs）が x86_64 バイナリのため Rosetta 2 未インストール時に `Bad CPU type in executable` でサイドバー設定が失敗。activation は続行されるがサイドバーが未設定になる（Rosetta インストール後の再実行で解消される） | activation script に Rosetta 2 の冪等インストールを追加する（`oahd` プロセス有無で判定）。sfltool は macOS 10.13 以降 add-item 削除済みで代替不可。nix-darwin のサイドバー宣言管理は未実装（issue #1663） |
| 5 | [`flake.nix` L101](../../flake.nix#L101) | `enableRosetta = true` により nix-homebrew が `/usr/local`（Intel prefix）にも Homebrew を設定する。実ログでは **cask インストールは全て成功**しており、Intel prefix 起因の失敗は確認されていない。実際の失敗（RunCat・Xcode・GarageBand）は mas（Mac App Store）の App Store 認証未実施が原因で Intel prefix とは無関係 | M chip 前提なら `enableRosetta = false` に変更して Intel prefix を無効化する（手動 `brew` 実行時の PATH 混在リスクを排除）。mas 失敗については README に「App Store にサインインしてから `brew bundle` を実行する」手順を追記する |
| 6 | [`install.sh`](../../install.sh) | Nix 環境構築のシェルスクリプトが空。初回セットアップ（Nix インストール・flake 適用・brew bundle）を手順通り実行するスクリプトがなく、README を読みながら手動実行が必要 | Linux / macOS 両対応のセットアップスクリプトを `install.sh` に実装する（OS 検出 → Nix インストール → 前処理 → darwin-rebuild / home-manager → brew bundle の順に実行） |
| 7 | [`modules/system/darwin/features/input/default.nix`](../../modules/system/darwin/features/input/default.nix) | 日本語入力のライブ変換（`NSGlobalDomain.NSAutomaticTextCompletionEnabled` 相当）を無効化する設定がない。ライブ変換はデフォルト ON のため初回適用後も手動でオフにする必要がある | `system.defaults.NSGlobalDomain` に `"NSAutomaticTextCompletionEnabled" = false` を追加する。または `CustomUserPreferences` でユーザードメインに書き込む |
| 8 | [`README.md`](../../README.md) | SSH 公開鍵の登録手順が未記載。`darwin-rebuild switch` 後に GitHub・各サーバーへの SSH 接続を手動で設定する必要があるが、最低限のセットアップガイド（鍵生成 → GitHub 登録 → `~/.ssh/config`）がない | README または `docs/` に SSH セットアップガイドを追加する |
| 9 | `modules/system/darwin/` (新規) | ディスプレイオフ時にシステムスリープさせない設定がない。Mac mini はサーバー用途を含むデスクトップのため、ディスプレイを切っても処理を継続できる必要がある（`systemsetup -setcomputersleep Off` 相当） | `system.defaults` の `systemsetup` または `powermanagement` オプションで `displaysleep`・`sleep` を設定するモジュールを追加する |
| 10 | [`README.md`](../../README.md) / [`install.sh`](../../install.sh) | `.envrc` はリポジトリに存在するが `direnv allow` が未実行の場合ブロックされる。初回クローン後にこのエラーが出ても原因が分かりにくい | README の Setup セクションに `direnv allow` 実行ステップを追記する。または `install.sh` に `direnv allow` を組み込む |
| 11 | [`README.md`](../../README.md) / [`modules/system/darwin/features/dock/default.nix` L39](../../modules/system/darwin/features/dock/default.nix#L39) | `darwin-rebuild switch` → `brew bundle` の順で実行すると、Dock への追加対象アプリ（Chrome・Slack・VSCode 等）が brew インストール前のため `if [ -e "$app" ]` チェックに引っかかりスキップされる。`brew bundle` 完了後に再度 `darwin-rebuild switch` を実行しないと Dock が正しく構成されない | README の手順に「`brew bundle` 後に再度 `darwin-rebuild switch` を実行する」ステップを追記する。`install.sh` 実装時（#6）にはこの2回実行を自動化する。根本対策として Dock 設定を brew 後に実行する独立スクリプトに分離する案も検討 |

| 12 | [`modules/system/darwin/core/default.nix`](../../modules/system/darwin/core/default.nix) / [`install.sh`](../../install.sh) | `userProfile.name = "guest"` のまま `darwin-rebuild switch` を実行すると、preActivation でホスト・ユーザーは表示されるが nix-darwin の cryptic なエラーで終了する。ユーザーは何を直せばいいか分かりにくい。また `user-profiles/<name>.nix` が存在しない場合は Nix 評価エラーで止まる | ① `preActivation` で username が "guest" の場合に早期 exit し、修正コマンドを明示する。② `install.sh` の darwin-rebuild 前に対話ウィザードを追加し、"guest" 検出時に username・git 情報を入力させてプロファイルファイルを自動生成する（darwin-rebuild 中はビルド済み設定の変更不可のため install.sh での対応が必須） |
| 13 | [`tests/darwin/features/default.nix`](../../tests/darwin/features/default.nix) / [`tests/user-profile/default.nix`](../../tests/user-profile/default.nix) | 今回追加・変更したモジュールに対するテストが不足している。未カバー: `input` のライブ変換オフ設定・`power` モジュール全体（feature 登録・desktop sleep 抑止・laptop sleep 許可）・`finder` の Rosetta 自動インストール・`user-profiles/default.nix` のセットアップウィザード案内文 | 各モジュールに対応するユニットテストを `tests/darwin/features/default.nix` と `tests/user-profile/default.nix` に追加する。throw メッセージのテストは `builtins.tryEval` では内容取得不可のため、ソースコードに文字列が含まれることを `builtins.readFile` で検証する |
| 14 | [`scripts/ai/verify.sh`](../../scripts/ai/verify.sh) / PR テスト計画 | `nix flake check path:. --no-build --all-systems` が `darwinConfigurations.mac-mini` / `darwinConfigurations.macbook-air` で ❌ になる。原因: `hosts/*/config.nix` の `userProfile.name = "guest"` に対して `core/default.nix` の assertions が Nix 評価時に発火する。これは設計上の想定動作（未設定ホストのシグナル）だが verify.sh と PR テスト計画が誤解を招く。guest → test 移行も検討したが assertions の意味が失われ install.sh のウィザード検出にもハックが必要になるため採用しない | `verify.sh` を `nix eval path:.#checks.SYSTEM.CHECK.drvPath` による明示的チェックに変更し `darwinConfigurations.*` を評価対象から除外する。PR テスト計画の `nix flake check` も `checks.*` 個別評価に差し替える |

---

## 優先度まとめ

### 今すぐ対応（バグ・セットアップ失敗）

- **#2** `modules/system/darwin/core/default.nix`: `nix.enable = false` がないと Determinate 環境で activation 不可
- **#5** `flake.nix`: `enableRosetta = true` による Intel prefix 混在（cask 失敗の直接原因ではないが PATH リスクあり）

### 近いうちに対応（ドキュメント・手順漏れ・機能追加）

- **#3** `README.md`: `/etc/zshenv` 競合の回避手順が未記載
- **#4** `README.md` / `finder/default.nix`: Rosetta 2 事前インストールの要件が未記載
- **#6** `install.sh`: Linux / macOS 対応の初回セットアップスクリプトが未実装
- **#7** `modules/system/darwin/features/input/default.nix`: 日本語ライブ変換オフの設定が未追加
- **#8** `README.md`: SSH セットアップガイドが未記載
- **#9** `modules/system/darwin/`: ディスプレイオフ時のスリープ抑止設定が未実装
- **#10** `README.md` / `install.sh`: `direnv allow` の実行手順が未記載
- **#11** `README.md` / `dock/default.nix`: `brew bundle` 後に再度 `darwin-rebuild switch` が必要だが手順に未記載

### 機会があれば対応（UX改善）

- **#1** `hosts/mac-mini/config.nix`: `userProfile.name` 変更漏れを起こしにくい仕組みの検討
- **#12** `core/default.nix` / `install.sh`: "guest" 検出時の早期エラー表示と対話セットアップウィザード
- **#13** `tests/`: input・power・finder Rosetta・ウィザード案内のテスト追加

---

> 意思決定の記録 → [docs/decisions/2026-06-16-issue-28-mac-mini-m4-fresh-setup.md](../decisions/2026-06-16-issue-28-mac-mini-m4-fresh-setup.md)
