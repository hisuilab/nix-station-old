# レビュー: MacBook Air M1 実機セットアップテストで発見された課題

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-17 |
| 対象ブランチ / PR | `fix/issue-32-macbook-air-build` |
| レビュー担当 | Claude Sonnet 4.6 (自動) |
| レビュー種別 | 実機セットアップログ分析 |

---

## レビュー観点

MacBook Air M1 の実機で `bash install.sh macbook-air` を初めて実行し、ウィザード案内からセットアップ完了まで追ったログをもとに、
`install.sh` の動作上の不備・ドキュメントの不足・設定の効果不確認を洗い出す。

セットアップの流れ（ユーザー実施）:
1. Nix を Determinate Nix Installer で先にインストール
2. HisuiLab/nix-station の README を確認
3. ターミナル再起動後、`cd Downloads/nix-station-main` で移動
4. `bash install.sh macbook-air` を実行 → ウィザード案内に従い適用成功を確認

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | [`install.sh` L172–175](../../install.sh#L172) | `setup_darwin` 完了後の「次のステップ」に brew と SSH キー設定が並列で案内されている。初回ユーザーにはどちらを優先すべきか・どちらが必須かが伝わりにくい（brew は必須、SSH は任意タイミング） | `install.sh` の「次のステップ」は brew 再実行（mas アプリ対応）のみに絞る。SSH セットアップは `docs/github-ssh.md` に独立ガイドとして切り出し、README から参照させる |
| 2 | [`install.sh` `brew_bundle()`](../../install.sh#L139) / [`hosts/macbook-air/config.nix` L34](../../hosts/macbook-air/config.nix#L34) | macbook-air は `darwin.homebrew.manageInstallation = false` のため `flake.nix` で `nix-homebrew.enable = false` となり、`darwin-rebuild switch` 中に Homebrew は**インストールされない**。にもかかわらず `brew_bundle()` が `/opt/homebrew/bin/brew bundle` を直接呼び出すため `zsh: command not found: brew` で失敗する | `darwin_prereqs()` に brew の存在チェックを追加し、未インストール時は公式インストーラー（`/bin/bash -c "$(curl -fsSL …)"` 相当）を自動実行する。または `README.md` の「Apply Configuration」前提条件に「Homebrew を事前にインストールしてください（`manageInstallation = false` の host の場合）」を明記する |
| 3 | [`modules/system/darwin/features/input/default.nix` L5](../../modules/system/darwin/features/input/default.nix#L5) | `CustomUserPreferences.NSGlobalDomain."NSAutomaticTextCompletionEnabled" = false` はテキスト補完候補の抑制設定であり、日本語ライブ変換（Japanese IME の Live Conversion）のキーとは異なる。実機で `darwin-rebuild switch` を適用してもライブ変換がオフにならなかった | 日本語ライブ変換は `com.apple.inputmethod.Kotoeri.RomajiTyping` ドメインの `"JIMPrefLiveConversionKey"` で制御される。`system.defaults.CustomUserPreferences."com.apple.inputmethod.Kotoeri.RomajiTyping"."JIMPrefLiveConversionKey" = false` を追加する。または `postActivation` スクリプトで `defaults write` を直接実行し、`killall -HUP cfprefsd` でキャッシュを更新する |
| 5 | [`hosts/macbook-air/config.nix` L44](../../hosts/macbook-air/config.nix#L44) / [`flake.nix` L100](../../flake.nix#L100) | `darwin.homebrew.manageInstallation` は「何のインストール管理か」が不明瞭で、`enable` との責任の違いも伝わらない。nix-station が担う責任は ① Homebrew バイナリ自体のインストール と ② Brewfile によるアプリ一括導入 の2つだが、現状は前者だけがオプション化されており後者は install.sh に暗黙的に組み込まれている | `darwin.homebrew` を以下の3オプションに再設計する: `enable`（Homebrew 連携を使うか）・`install`（nix-homebrew が Homebrew バイナリを `/opt/homebrew` に自動インストールするか、デフォルト true）・`brewBundle`（install.sh が brew bundle を実行してアプリを一括導入するか、デフォルト true）。`install = true; brewBundle = true;` が初期化 Mac の完全セットアップ、`install = false; brewBundle = true;` が Homebrew 導入済み環境での再適用、と組み合わせの意図が一読できる。`flake.nix` の `manageInstallation or true` → `install or true`、`hosts/macbook-air/config.nix` の `manageInstallation = false` → `install = false` に変更し、`brewBundle = true` を明示的に追加する |
| 4 | [`README.md`](../../README.md) Setup〜Apply Configuration セクション | README のセットアップ手順が `install.sh` 導入前の手動コマンド方式（`cp guest.nix`・`darwin-rebuild switch` 直打ち等）のまま。実機テストで辿った実際のフロー（① Nix インストール → ② ターミナル再起動 → ③ `cd` でリポジトリへ移動 → ④ `bash install.sh <host-id>` でウィザード起動）と乖離しており、README を読んで `install.sh` にたどり着けない。また「Homebrew 本体も自動導入されます」という記述が `manageInstallation = false` のホストでは誤りになっている | README の Setup セクションを `install.sh` を主経路として書き直す。手順: ① Nix インストール（Determinate Nix Installer リンク明示）→ ② ターミナル再起動 → ③ リポジトリ取得 → ④ `bash install.sh <host-id>` 実行（ウィザードが user-profile 作成〜darwin-rebuild〜brew bundle を自動実行）。手動コマンドは「高度な操作」として折りたたみ or 別セクションへ移動する |
| 6 | [`install.sh`](../../install.sh) / [`README.md`](../../README.md) | `install.sh` が Nix を自動インストールしている場合、インストール直後にターミナル再起動なしでスクリプトが続行される。Nix インストール後は `nix` コマンドをシェルが認識するためにターミナル再起動が必須であり、再起動なしで続行するとコマンド未検出エラーになる | `install.sh` から Nix 自動インストール処理を削除し、Nix インストール済みを前提とする。README に「① Nix インストール → ② ターミナル再起動 → ③ `nix --version` で確認 → ④ `bash install.sh`」の順序を明示し、ユーザーが手動で確認してから実行する流れに変更する |
| 7 | [`install.sh`](../../install.sh) | スクリプト名 `install.sh` は「インストールする」という動作を示すが、Nix インストールを外した後の実態はユーザープロファイル入力・`darwin-rebuild switch`・`brew bundle` の一括オーケストレーションであり名前と責務が乖離している。Windows 側が `scripts/windows/setup.ps1` であることとも不統一 | `install.sh` を `setup.sh` にリネームする。README・docs 内の全参照も合わせて更新する |
| 8 | [`install.sh`](../../install.sh) | `bash install.sh mac-mini` のように host-id をコマンドライン引数で渡す方式は、ユーザーが事前に `hosts/` 以下のフォルダ名を把握していないと実行できない。初回セットアップのユーザーには UX が悪い | スクリプト起動時に `hosts/` 以下の登録済みホスト一覧を表示し、番号または矢印キーで選択できるインタラクティブメニューを実装する。引数なしで起動した場合にメニューを表示し、引数ありの場合は従来通り直接実行できるようにして後方互換を維持する |

---

## 優先度まとめ

### 今すぐ対応（バグ・セットアップ失敗）

- **#2** `install.sh` / `hosts/macbook-air/config.nix`: `manageInstallation = false` のとき Homebrew が未インストールのまま `brew bundle` を実行しようとして失敗する

### 今すぐ対応（設計変更）

- **#6** `install.sh` / `README.md`: Nix 自動インストールを `install.sh` から削除し、README で手動インストール → ターミナル再起動 → `nix --version` 確認の手順を明示する
- **#7** `install.sh`: `install.sh` を `setup.sh` にリネームし、README・docs の全参照を更新する
- **#8** `install.sh`: 引数なし起動時に登録済みホスト一覧をインタラクティブメニューで表示し、ユーザーが選択できるようにする

### 近いうちに対応（ドキュメント・UX）

- **#5** `hosts/macbook-air/config.nix` / `flake.nix`: `darwin.homebrew` を `install` + `brewBundle` の2オプション構成に再設計
- **#3** `modules/system/darwin/features/input/default.nix`: 日本語ライブ変換に対応する正しいドメイン・キーへの修正
- **#4** `README.md`: Setup〜Apply Configuration セクションを `install.sh` 主経路に書き直す。「Homebrew 自動導入」の誤記を修正する
- **#1** `install.sh` / `README.md`: セットアップ後の「次のステップ」の整理と SSH ガイドの `docs/github-ssh.md` への分離

---

> 意思決定の記録 → [docs/decisions/2026-06-17-issue-32-macbook-air-build.md](../decisions/2026-06-17-issue-32-macbook-air-build.md)
