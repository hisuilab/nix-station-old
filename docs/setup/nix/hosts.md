# ホスト設定

管理対象ホストは [`hosts/default.nix`](../../hosts/default.nix) へ登録します。

```text
hosts/
├── default.nix
├── mac-mini/config.nix
├── macbook-air/config.nix
├── raspberry-pi-5/config.nix
├── ubuntu-desktop/config.nix
└── ubuntu-wsl/config.nix
```

小文字 kebab-case のディレクトリ名が flake 出力のホスト ID になります。`meta.hostname` は OS・ネットワーク上の端末名で、省略時はホスト ID を使用します。

## 設定項目

- `platform = "darwin"`: nix-darwin と Home Manager を生成
- `platform = "home-manager"`: Ubuntu・Raspberry Pi OS 向け standalone Home Manager を生成
- `os`: `darwin`、`ubuntu`、`raspberry-pi-os` から Home Manager の OS 固有設定を選択
- `environment`: `native` または `wsl` から実行環境固有の設定を選択
- `role`: `desktop`、`laptop`、`server` から用途別モジュールを選択

`platform = "darwin"` では `meta.hostname` を macOS へ反映します。standalone Home Manager は OS の hostname を変更しないため、Linux ホストの `meta.hostname` は識別用メタデータです。

## 設定例

```nix
# hosts/macbook-air/config.nix
meta = {
  hostname = "HisuiLab-MacBook-Air";
  system = "aarch64-darwin";
  platform = "darwin";
  os = "darwin";
  environment = "native";
  role = "laptop";
};
```

```nix
# hosts/ubuntu-wsl/config.nix
meta = {
  hostname = "ubuntu-wsl";
  system = "x86_64-linux";
  platform = "home-manager";
  os = "ubuntu";
  environment = "wsl";
  role = "desktop";
};
```

## Home Manager の設定

各ホストの `config.nix` でユーザー環境の機能を選択します。`homeManager` 配下の各フラグは省略可能で、未指定値は `false` として扱います。

```nix
homeManager = {
  git = true;
  zsh = true;
  gh = true;
  cliTools = true;
  p10k = { enable = true; configFile = null; };
  ghostty = { enable = true; configFile = null; };
  zed = { enable = true; configFile = null; };
};
```

| フラグ | 内容 |
|---|---|
| `git` | userProfile の git 設定を反映 |
| `zsh` | 最小限の Zsh 設定 |
| `p10k.enable` | Powerlevel10k テーマ |
| `ghostty.enable` | Ghostty 設定管理 |
| `zed.enable` | Zed 設定管理 |
| `gh` | GitHub CLI |
| `cliTools` | Devbox、Claude Code、CLI ツール群 |

## Homebrew の設定（macOS のみ）

`darwin.homebrew` で Homebrew の導入方法とアプリ管理を制御します。GUI アプリ・App Store アプリは `hosts/<host-id>/Brewfile` で管理します。

```nix
darwin.homebrew = {
  enable = true;
  install = true;
  brewBundle = true;
};
```

| オプション | デフォルト | 内容 |
|---|---|---|
| `enable` | `true` | Homebrew 連携を使うか |
| `install` | `true` | nix-homebrew が Homebrew バイナリを `/opt/homebrew` に自動インストールするか |
| `brewBundle` | `true` | `setup.sh` が `brew bundle` を実行してアプリを一括導入するか |

**組み合わせの例:**

| `install` | `brewBundle` | 用途 |
|---|---|---|
| `true` | `true` | 初期化済みの Mac（Homebrew 未インストール）への完全セットアップ |
| `false` | `true` | すでに Homebrew が入っている Mac での再適用 |
| `true` | `false` | Homebrew だけ導入してアプリは手動管理 |

> [!NOTE]
> `install = false` のホストでは `setup.sh` 実行前に Homebrew を手動でインストールしてください。未インストールの場合 `brew bundle` をスキップして続行します。

## ホストの追加

1. `hosts/<host-id>/config.nix` を作成します。
2. `hosts/default.nix` へ登録します。
3. ユーザープロファイルを `user-profiles/<name>.nix` に用意します（[user-profiles.md](user-profiles.md) 参照）。

モジュール構成の詳細は [`docs/DEVELOPMENT.md`](../../DEVELOPMENT.md) を参照してください。
