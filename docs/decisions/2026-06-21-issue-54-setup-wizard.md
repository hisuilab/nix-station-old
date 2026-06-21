# 意思決定の記録: issue-54-setup-wizard

> 記録日: 2026-06-21

| # | 判断 | 理由・備考 |
|---|---|---|
| 1 | `hosts/` を動的スキャンして Host ID を取得する | `instance.py` の `VALID_HOST_IDS` との二重管理を解消するため |
| 2 | Wizard スコープ: Doctor + ファイル生成のみ（apply は手動） | `darwin-rebuild switch` はWizard完了メッセージで案内するにとどめる |
| 3 | 起動方法: `nix run nixpkgs#python3 -- scripts/service/wizard.py` | 他のスクリプトと統一。`setup.sh` はこのコマンドを呼ぶ薄いラッパーにする |
| 4 | `flake.nix` は `lib/templates/deploy-flake.nix` をコピーして生成 | 動的文字列生成は変更箇所が増えるため避ける |
| 5 | TOML の書き込みは `tempfile.NamedTemporaryFile` + `os.replace()` でアトミックに行う | 検証成功後に rename することで不完全なファイルが残らないようにする |
| 6 | Wizard 完了時に `generate_brewfile.py` を呼び出して Brewfile を生成し、パスを案内する | 初回セットアップで App Catalog → Brewfile まで完結させるため |
| 7 | エラークラスは各 validator のものをそのまま catch して Wizard レイヤーで整形表示する | 共通 `WizardError` 導入は将来の CLI 統合フェーズで検討する |
| 8 | 初版対応 OS: macOS + Linux（ubuntu-desktop / ubuntu-wsl / raspberry-pi-5 含む） | Doctor チェックは OS 別に分岐（macOS: nix-darwin, Linux: home-manager の有無） |
