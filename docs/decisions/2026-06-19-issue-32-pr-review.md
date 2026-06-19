# 意思決定の記録: issue-32-macbook-air-build PR レビュー

> 記録日: 2026-06-19
> ファイル名: `docs/decisions/2026-06-19-issue-32-pr-review.md`

---

| # | 優先度 | 判断 | 理由・備考 |
|---|---|---|---|
| 1 | 高 | このissueに含める: `setup.sh` L124 の `sed -i ''` を OS 判定で分岐する（macOS は `sed -i ''`、Linux は `sed -i`） | クロスプラットフォームバグ。`setup_user_profile()` は `setup_linux()` からも呼ばれるため今すぐ修正が必要 |
| 2 | 中 | このissueに含める: `hosts/macbook-air/config.nix` / `hosts/mac-mini/config.nix` のコメント内 `install.sh` を `setup.sh` に修正する | `setup.sh` へのリネーム後も `install.sh` のままで整合性が取れていない |
| 3 | 中 | このissueに含める: `setup.sh` の `setup_darwin()` で `config.nix` の `darwin.homebrew.brewBundle` を読み取り、`false` の場合は `brew_bundle()` をスキップする | `brewBundle = false` に設定しても現状は `brew bundle` が実行されてしまう。`brewBundle` フィールド名は issue-34 の影響を受けない |
| 4 | 中 | 見送り（issue-34 完了後に対応）: `select_host_id()` に OS / ホスト互換チェックを追加する。判定キーは `platform`（`"darwin"` / `"home-manager"`）、互換外ホストは選択不可で表示 | issue-34（`platform` → `builder` リネーム）完了後に `platform` の値が変わるため、今実装すると書き直しになる |
