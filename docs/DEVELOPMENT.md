# 開発ガイド

## 開発フロー

1. GitHub Issueに目的、期待する挙動、完了条件を記載する。
2. Issueに対応するブランチを作成する。
3. 変更対象の機能テストを追加し、必要に応じて実装前の失敗を確認する。
4. 実装後にローカルチェックを実行する。
5. Conventional Commits形式でコミットする。
6. Pull Requestを作成し、CI成功後にmainへマージする。
7. マージ後はローカルmainを更新する。

```bash
git switch main
git pull --ff-only origin main
```

## ブランチ命名

Issue番号と目的が分かる名前を使用します。

```text
feat/issue-12-zsh-setup
fix/issue-45-homebrew-zap
infra/issue-1-ci-base-setup
```

## Conventional Commits

コミットメッセージは次の形式を使用します。

```text
<type>(<scope>): <description>
```

scopeは任意です。

| Type       | 用途                       |
| ---------- | -------------------------- |
| `feat`     | 新機能や新しい設定         |
| `fix`      | 不具合修正                 |
| `test`     | テストの追加・修正         |
| `refactor` | 挙動を変えない構造整理     |
| `docs`     | ドキュメント更新           |
| `chore`    | その他の保守作業           |
| `ci`       | GitHub ActionsなどのCI変更 |

例:

```text
feat: validate selectable user profiles
refactor: organize tests by feature
docs: update development workflow
```

Issueを参照する場合:

```text
Refs #12
```

マージ時にIssueを閉じる場合:

```text
Closes #12
```

## テスト構成

[`tests/default.nix`](../tests/default.nix)を全テストのエントリーポイントとし、機能単位のディレクトリへ分割します。

```text
tests/
├── default.nix
└── user-profile/
    ├── default.nix
    └── fixtures/
```

新しい機能テストを追加する場合:

1. `tests/<feature>/default.nix`を追加する。
2. 必要なfixtureを`tests/<feature>/fixtures/`へ置く。
3. `tests/default.nix`から機能テストをimportする。

例:

```nix
{ pkgs }:

builtins.concatLists [
  (import ./user-profile { inherit pkgs; })
  (import ./new-feature { inherit pkgs; })
]
```

## ローカル検証

Flake出力と全テストを評価します。

```bash
nix flake check path:. --no-build --all-systems
```

テストderivationを実際にビルドします。

```bash
nix build path:.#checks.aarch64-darwin.tests --no-link
```

nix-darwinのシステム構成を適用せずにビルドします。

```bash
nix build path:.#darwinConfigurations.server.system --no-link
```

## User Profileの開発

ホストが使用するプロファイルは`hosts/server/config.nix`で選択します。

```nix
userProfile = {
  name = "guest";
};
```

`name = "guest"`は`user-profiles/guest.nix`を読み込みます。

必須項目:

- `username`
- `git.userName`
- `git.userEmail`

任意項目:

- `description`

必須項目の未定義、空文字、型不正、またはプロファイルファイル不在は評価エラーです。

個人用の`user-profiles/hisuilab*`は`.gitignore`対象です。Gitで追跡されないファイルは通常の純粋なFlake入力やCIに含まれないため、CIで検証する用途には`user-profiles/test.nix`とテストfixtureを使用します。

## CI

GitHub Actionsは次のタイミングで実行されます。

- mainへのPull Request
- mainへのpush

現在のCI:

- Runner: `macos-latest`
- Nix: `DeterminateSystems/nix-installer-action`
- Command: `nix flake check`

定義は[`.github/workflows/ci.yml`](../.github/workflows/ci.yml)にあります。

## pre-commit

設定は[`.pre-commit-config.yaml`](../.pre-commit-config.yaml)にあります。

現在の主なチェック:

- trailing whitespace
- ファイル末尾改行
- ファイル名の大文字・小文字競合
- merge conflict marker
- `nixpkgs-fmt`
- Ruff
- Prettier

初回セットアップ:

```bash
pre-commit install
```

全ファイルへ手動実行:

```bash
pre-commit run --all-files
```
