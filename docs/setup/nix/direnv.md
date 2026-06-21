# direnv の設定

このリポジトリのルートに `.envrc`（`use flake`）があり、[direnv](https://direnv.net/) + [nix-direnv](https://github.com/nix-community/nix-direnv) を使うと `cd` するたびに Nix flake 環境が自動で読み込まれます。

direnv は `homeManager.cliTools = true` のホストで Home Manager によって自動インストールされます。

## 初回設定

`direnv allow` を実行していない状態でリポジトリに移動すると、以下のエラーが表示されます。

```
direnv: error /path/to/nix-station/.envrc is blocked. Run `direnv allow` to approve its content
```

`setup.sh` 完了後、ターミナルを再起動してからリポジトリルートで実行します。

```bash
direnv allow
```

以後 `cd nix-station` するたびに自動で環境が読み込まれます。

## 確認

```bash
direnv status
```

`Found RC allowed true` と表示されれば有効です。
