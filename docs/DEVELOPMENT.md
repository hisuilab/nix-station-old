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

## IssueとPull Requestの運用

### Issueの作成

GitHubの`Issues`から`New issue`を選択し、Featureフォームへ次を入力します。

- 概要
- 設計
- タスク
- 完了条件
- 関連Issue

タスクは実装作業、完了条件は検証可能な受け入れ基準として分けます。

### Pull Requestの作成

作業開始後、早めにDraft Pull Requestを作成します。

```bash
gh pr create --draft
```

Pull Request本文では次を確認します。

- `Closes #<issue-number>`の形式でIssueを関連付け
- Issueの完了条件を転記し、実際の結果を確認してチェック
- 実行したテストコマンドと結果を記載
- `git diff`で変更全体をセルフレビュー
- 意図しない変更や秘密情報が含まれていないことを確認
- CI成功後にDraftを解除

### ブランチ保護

`main`への直接pushを禁止し、Pull RequestとCI成功を必須とします。
通常の変更は作業ブランチで実施し、Pull Requestを経由して`main`へマージします。

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

## モジュール構成

システム設定とユーザー環境の責務を分離します。

### Home Managerモジュール

Home Managerで管理するユーザー環境は`modules/home/<tool>/default.nix`へ配置します。

```text
modules/home/
├── default.nix
├── git/default.nix
└── zsh/default.nix
```

`modules/home/default.nix`が`homeManager`設定から有効なモジュールを選択します。各ツールのモジュールはHome Managerのオプションを使用し、ユーザー単位のインストールと設定を管理します。

### macOSとの統合

nix-darwinとHome Managerを次の経路で接続します。

```text
flake.nix
└── modules/macOS/default.nix
    ├── modules/macOS/server.nix
    └── Home Manager
        └── modules/home/default.nix
            └── modules/home/<tool>/default.nix
```

責務:

- `flake.nix`: inputsの統合、ホスト設定の読み込み、`specialArgs`の受け渡し、nix-darwin構成の生成
- `modules/macOS/default.nix`: macOSモジュールのエントリーポイント
- `modules/macOS/server.nix`: server固有のmacOS設定
- `modules/home/default.nix`: `homeManager`設定に応じたHome Managerモジュールの選択
- `modules/home/<tool>/`: GitやZshなど、ユーザー環境の機能単位の設定

macOSモジュールから`modules/home/<tool>/`を直接importせず、Home Managerを経由します。モジュールの選択処理は`modules/home/default.nix`に集約し、`flake.nix`やmacOSモジュールに重複させません。

Homebrew、ログインシェル、システムデフォルトなどmacOS固有の設定は`modules/macOS/`へ配置します。同じツールにユーザー設定とOS固有設定がある場合も、管理主体に応じて分離します。

### Home Manager設定

`hosts/server/config.nix`のフラグでユーザー環境の機能を選択します。

```nix
homeManager = {
  git = true;
  zsh = true;
};
```

- `homeManager.git = true`: `userProfile.git.userName`と`userProfile.git.userEmail`をGit設定へ反映
- `homeManager.zsh = true`: 最小限のZsh設定と関連ツールを有効化
- すべて`false`: ツール固有のHome Managerモジュールを読み込まない

macOS統合では、`userProfile.username`をmacOSのユーザーとホームディレクトリへ関連付けます。`homeManager.zsh = true`の場合はZshをログインシェルとして設定します。`guest`と`test`は評価・ビルドテスト用とし、実機への適用時は既存のmacOSユーザーに対応するプロファイルを指定します。

### テスト方針

- 各`homeManager`フラグの`true`と`false`を単体テスト
- Home Managerから`modules/home/default.nix`、`modules/home/<tool>/`までの読み込み経路を統合テスト
- 各ツールのテストを`tests/home/<tool>/default.nix`で管理
- Home Manager統合テストを`tests/home/integration.nix`で管理
- macOSモジュールからHome Managerまでの統合テストを`tests/macOS/integration.nix`で管理
- `darwinConfigurations.server.system`の評価とビルドを確認

完成形:

```text
tests/
├── default.nix
├── home/
│   ├── default.nix
│   ├── integration.nix
│   ├── git/default.nix
│   └── zsh/default.nix
├── macOS/
│   └── integration.nix
└── user-profile/
    ├── default.nix
    └── fixtures/
```

複数ホストや異なるsystemへの対応時は、構成生成関数へ`system`を引数として渡し、単一のグローバル値への依存を避けます。

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
