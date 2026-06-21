# 意思決定の記録: issue-46-toml-host-validator

> 記録日: 2026-06-21

| # | 判断 | 理由・備考 |
|---|---|---|
| 1 | TOML Host Templateのファイル名と配置場所 | `hosts/<name>/template.toml`。既存のBrewfile・config.nixと同ディレクトリに置く |
| 2 | TOMLフィールドの命名規則（snake_case vs camelCase） | `snake_case` に統一。Nix側のローダーが `cli_tools` → `cliTools` 等を変換する |
| 3 | `configFile` のTOML表現（omit vs 明示） | 相対パス文字列として明示する（例: `config_file = "modules/home/ghostty/config"`） |
| 4 | `lib/host-config.nix` の `configFile` 型検査の変更方針 | Nix TOMLローダー内で `/. + string` によりNix pathへ変換してから渡す。`validateHostConfig` は変更しない |
| 5 | TOMLパースのレイヤー分担（Python Application Service vs Nix `builtins.fromTOML`） | Python（tomllib）= CLI/Wizard Application Service層。Nix（`builtins.fromTOML`）= Root flake checks。役割を分担し二重実装を避ける |
| 6 | Python Validatorのコード配置場所 | `scripts/validator/` を新設。将来の Application Service（`scripts/service/`）への拡張履歴が明確になる |
| 7 | Root flake checksへのTOML Host組み込み方法 | `lib/toml-loader.nix` を新設してTOMLロード責任を分離。`hosts/default.nix` はシンプルに保つ |
| 8 | `managedTools` リストとPython Validatorの関係 | Python内に複製して持つ。変更頻度が低く実装がシンプル。`host-registry.nix` との同期はコードレビューで担保する |
