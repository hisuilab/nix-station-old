# 意思決定の記録: issue-32-macbook-air-build

> 記録日: 2026-06-17
> ファイル名: `docs/decisions/2026-06-17-issue-32-macbook-air-build.md`

---

| # | 優先度 | 判断 | 理由・備考 |
|---|---|---|---|
| 1 | 中 | このissueに含める: `install.sh` の「次のステップ」を brew 再実行のみに絞り、`docs/github-ssh.md` を新規作成して SSH 手順を切り出す。README から `docs/github-ssh.md` へのリンクを追加する | install.sh 完了後に必須なのは brew（mas アプリ対応）のみ。SSH は任意タイミングのため並列表示は混乱を招く |
| 2 | 低 | ５の実装で解決させる | `darwin.homebrew.manageInstallation` を廃止 |
| 3 | 中 | このissueに含める: `modules/system/darwin/features/input/default.nix` に `com.apple.inputmethod.Kotoeri.RomajiTyping` ドメインの `"JIMPrefLiveConversionKey" = false` を追加する | `NSAutomaticTextCompletionEnabled` はテキスト補完候補の設定であり、日本語 IME のライブ変換とは別のキー。正しいドメイン・キーに修正して実機再検証が必要 |
| 4 | 中 | このissueに含める: `README.md` の Setup〜Apply Configuration セクションを `install.sh` を主経路として書き直す。手順は「① Nix インストール（Determinate Nix Installer）→ ② ターミナル再起動 → ③ リポジトリ取得 → ④ `bash install.sh <host-id>` 実行」の番号付きステップで記述する。手動コマンド（darwin-rebuild 直打ち等）は上級者向けとして折りたたみか別セクションに移動する。「Homebrew 本体も自動導入されます」の記述は `manageInstallation` の設定による旨に修正する | 実機テストで README → `install.sh` にたどり着けないことが判明した。README が旧手動方式のままでウィザードの存在が伝わらない。実際にユーザーが踏んだ手順をそのまま README に反映する |
| 8 | 中 | このissueに含める: スクリプト起動時に `hosts/` 以下の登録済みホスト一覧をインタラクティブメニューで表示し、番号入力で選択できるようにする。引数なし起動でメニューを表示し、`bash setup.sh mac-mini` のように引数を渡した場合は従来通り直接実行して後方互換を維持する | `bash install.sh mac-mini` の形式はユーザーが事前に host-id を知っていることが前提で、初回セットアップユーザーには不親切。スクリプト内で候補を提示することで README を読まなくても正しい host-id を選べるようになり、入力ミスも防げる |
| 7 | 中 | このissueに含める: `install.sh` を `setup.sh` にリネームする。README・docs 内の全参照（`bash install.sh <host-id>` 等）を `bash setup.sh <host-id>` に更新する | Nix インストールを外した後の実態はセットアップのオーケストレーションであり `install` という名前と乖離している。`scripts/windows/setup.ps1` との統一感もある。リネームは参照箇所が多いため意図的な一括変更として実施する |
| 6 | 高 | このissueに含める: `install.sh` から Nix の自動インストール処理を削除し、Nix インストール済みを前提とする。README に「① Nix インストール（Determinate Nix Installer）→ ② ターミナル再起動 → ③ `nix --version` で確認 → ④ リポジトリ取得 → ⑤ `bash install.sh <host-id>`」の順序を明示する | Nix インストール後はターミナル再起動が必須。スクリプト内で自動インストールすると再起動なしで続行されコマンド未検出エラーになるリスクがある。ユーザーが手動でインストール・確認してから `install.sh` を実行する流れのほうが、何が起きているかを把握しやすくエラー時の切り分けもしやすい |
| 5 | 高 | このissueに含める: `darwin.homebrew.manageInstallation` を廃止し、`install` と `brewBundle` の2オプションに再設計する。`install`（デフォルト true）= nix-homebrew が Homebrew バイナリを自動インストールする、`brewBundle`（デフォルト true）= install.sh が brew bundle を実行してアプリを一括導入する。変更箇所: `flake.nix`（`manageInstallation or true` → `install or true`）・`hosts/macbook-air/config.nix`（`manageInstallation = false` → `install = false; brewBundle = true;`）・`hosts/mac-mini/config.nix`（`install = true; brewBundle = true;` を明示）。他ホストのデフォルト動作は `or true` により維持される | `manageInstallation` は責任が曖昧。nix-station の担う責任は「Homebrew バイナリのインストール（`install`）」と「Brewfile によるアプリ一括導入（`brewBundle`）」の2つ。これを独立したオプションにすることで組み合わせの意図が一読できる: `install=true; brewBundle=true` = 初期化 Mac 完全セットアップ、`install=false; brewBundle=true` = Brew 導入済み環境での再適用 |
