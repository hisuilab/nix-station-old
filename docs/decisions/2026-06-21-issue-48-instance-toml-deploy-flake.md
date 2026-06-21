# 意思決定の記録: issue-48-instance-toml-deploy-flake

> 記録日: 2026-06-21

| # | 判断 | 理由・備考 |
|---|---|---|
| 1 | Framework export surface（`mkDarwinConfiguration` 等） | `flake.nix` の `outputs` に `lib.mkDarwinConfiguration` / `lib.mkHomeConfiguration` / `lib.loadHostTemplate` を追加してエクスポートする |
| 2 | `instance.toml` 必須フィールドと命名 | `schema_version`・`hostname`・`host_id`・`profile` の 4 フィールドのみ。`framework_path` / `framework_version` は除去（Decision #4） |
| 3 | `profiles/<name>.toml` スキーマと snake_case 変換 | TOML は `user_name` / `user_email`（snake_case）。Profile Validator が Nix 側の `userName` / `userEmail`（camelCase）へ変換する |
| 4 | `framework_version` の必要性（任意 vs 不要） | 不要。GitHub 参照に変更したため `flake.lock` が git revision を記録する。`instance.toml` への記録は冗長となる |
| 5 | `networking.hostName` の取得元変更（Instance vs Host Template） | `mkDarwinConfiguration` のシグネチャを `{ hostConfig, hostId, hostname, userProfile }` に拡張し、`hostname` を別引数として渡す。`darwin/core/default.nix` の `networking.hostName` は `hostConfig.meta.hostname` から `hostname` 引数に切り替える |
| 6 | local deploy flake の `inputs` 管理（GitHub URL + `follows` vs 独立） | `github:hisuilab/nix-station` を Framework URL とする（issue-44 Decision #6 を変更）。`follows` で nixpkgs 等を Framework から継承し、バージョン不一致を防ぐ |
| 7 | `lib/toml-loader.nix` プレースホルダー削除の完了条件 | この PR の完了条件に含める。local deploy flake が Instance から profile を取得する経路を実装したタイミングで同じコミットに含める |
| 8 | Python Validator ファイル分割（`instance.py` / `profile.py`） | `scripts/validator/instance.py` と `scripts/validator/profile.py` を別ファイルで実装する。将来の Application Service（`scripts/service/`）が import しやすい構造にする |
