# 意思決定の記録: issue-44-remaining-architecture

> 記録日: 2026-06-21

| # | 判断 | 理由・備考 |
|---|---|---|
| 1 | Host Templateから `meta.hostname` を除去する | TOMLスキーマとValidatorの実装完了後に移行する |
| 2 | Host Templateから `userProfile.name` を除去する | 同上。移行完了まで既存Nixホストに暫定維持する |
| 3 | `meta.hostname` と `userProfile.name` の取得元をInstanceとする | `~/.config/nix-station/instance.toml`（instance-and-deployment.md §4に準拠） |
| 4 | Instance移行後の `lib/host-config.nix` における `userProfile` 検証の扱い | TOML Validator完成後に `validateHostConfig` を削除し、Root flakeのchecksもTOML Hostを読み込む形へ置き換える |
| 5 | Registryに追加するModule path属性の構造 | `lib/module-registry.nix` を新設してModule path・説明・対応OSを管理する。`host-registry.nix` はbuilders/OS/environments定義に限定する |
| 6 | local deploy flakeのFramework参照方式（github URL vs local path） | ~~`path:` でローカルパスを参照する。Frameworkパスは `instance.toml` の `framework_path` に記録し、Wizardが書き換えられるようにする。~~  **issue-48で変更**: `github:hisuilab/nix-station` に変更。`framework_path` および `framework_version` フィールドは `instance.toml` から除去。`flake.lock` が git revision を正式に記録するため追跡方式もシンプルになる。local deploy flake のテンプレートは固定文字列となり Wizard の生成処理も単純化される |
| 7 | App Catalog TOMLのフルスキーマ（必須/任意フィールド、列挙値） | install（必須）、package（cask/mas必須）、macos_path（system必須、他任意）、manual_steps（manual任意、文字列リスト）、schema_version（ファイル先頭に必須、Validator互換性検査に使用）。display_nameは不要（macos_pathから導出する） |
| 8 | `darwin.dock` 設定のHost/Instance分離方針 | 全Dock設定をHost Templateに置く。端末ごとに用途が決まっており個人差は小さいという前提 |
| 9 | `nix-station` CLI実装言語の選択 | Python。Nixが前提なので `nix run nixpkgs#python3` で実質依存なし。TOML解析（tomllib標準ライブラリ）、テスト容易性、Wizard・CLIの共通Service実現を優先する |
| 10 | 既存 `hosts/*/Brewfile` の移行期間維持方針 | App Catalog実装完了まで維持し、TOML移行予定である旨のコメントを追記する。移行完了後に削除する |
