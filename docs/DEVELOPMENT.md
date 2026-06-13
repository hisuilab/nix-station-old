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

#### Rulesetの作成

GitHubリポジトリで次の画面を開きます。

```text
Settings
└── Rules
    └── Rulesets
        └── New ruleset
            └── New branch ruleset
```

nix-stationでは次の値を設定します。

| 項目                                      | 今回の設定値   | 用途・有効にする場面                                     |
| ----------------------------------------- | -------------- | -------------------------------------------------------- |
| Ruleset Name                              | `Protect main` | Rulesets一覧で対象と目的を識別                           |
| Enforcement status                        | `Active`       | ルールを実際に適用。検証だけの場合は`Evaluate`を使用     |
| Bypass list                               | 空             | 緊急対応者や自動化Appへ例外を許可する場合のみ追加        |
| Target branches                           | Default branch | デフォルトブランチを保護。固定名ならpatternで`main`指定  |
| Restrict creations                        | 無効           | 特定名のブランチ作成を管理者などに限定する場合に有効     |
| Restrict updates                          | 無効           | 対象ブランチの更新者をBypass対象だけに限定する場合に有効 |
| Restrict deletions                        | 有効           | `main`など重要ブランチの誤削除を防止                     |
| Require linear history                    | 無効           | merge commitを禁止し、履歴を直線化する場合に有効         |
| Require deployments to succeed            | 無効           | stagingやproductionへのデプロイ成功をマージ条件に追加    |
| Require signed commits                    | 無効           | コミット作成者の検証を厳格化する場合に有効               |
| Require a pull request before merging     | 有効           | 直接pushを避け、レビューとCIを経由                       |
| Required approvals                        | `0`            | チーム開発では`1`以上にして第三者承認を必須化            |
| Dismiss stale pull request approvals      | 無効           | 承認後の追加変更で古い承認を無効化する場合に有効         |
| Require review from Code Owners           | 無効           | 所有者ごとのレビューを必須化する場合に有効               |
| Require approval of most recent push      | 無効           | 最後の変更をpushした本人以外の承認を必須化               |
| Require conversation resolution           | 無効           | 未解決のレビューコメントがあるPRのマージを禁止           |
| Allowed merge methods                     | すべて         | 履歴方針に応じてMerge、Squash、Rebaseを制限              |
| Require status checks to pass             | 有効           | CIが成功するまでマージを禁止                             |
| Require branches to be up to date         | 無効           | 最新の対象ブランチ上でCI成功を必須化する場合に有効       |
| Do not require status checks on creation  | 無効           | 新規ブランチ作成時だけstatus checkを免除する場合に有効   |
| Required status checks                    | `nix-check`    | GitHub ActionsのNix評価成功を必須化                      |
| Block force pushes                        | 有効           | 共有履歴の強制書き換えを防止                             |
| Require code scanning results             | 無効           | CodeQLなどの脆弱性検査をマージ条件に追加                 |
| Require code quality results              | 無効           | 静的解析や品質基準をマージ条件に追加                     |
| Automatically request Copilot code review | 無効           | Copilotによる自動レビューを利用する場合に有効            |

`Default branch`を対象にすると、デフォルトブランチ名を変更した場合もRulesetの対象が追従します。

設定内容を確認し、`Create`でRulesetを保存します。
保存後、Rulesets一覧で`Protect main`が`Active`と表示されることを確認します。

> [!NOTE]
> `Evaluate`はルール違反を記録しますが、ブランチ更新はブロックしません。既存リポジトリへ段階的に導入する場合の事前確認に利用できます。

> [!IMPORTANT]
> Bypass listが空の場合、管理者もRulesetの対象になります。CI障害時などの緊急対応方法を決めてから有効化してください。

#### プロジェクト別の設定例

| 設定                         | 個人開発 | 少人数チーム | 本番・大規模チーム   |
| ---------------------------- | -------- | ------------ | -------------------- |
| Pull Request必須             | 推奨     | 必須         | 必須                 |
| Required approvals           | `0`      | `1`          | `2`以上              |
| Dismiss stale approvals      | 任意     | 推奨         | 必須                 |
| Code Owners                  | 不要     | 任意         | 推奨                 |
| Most recent pushの第三者承認 | 不要     | 任意         | 推奨                 |
| Conversation resolution      | 任意     | 推奨         | 必須                 |
| Status checks                | 必須     | 必須         | 必須                 |
| Branch up to date            | 任意     | 任意         | 推奨                 |
| Deployment成功               | 不要     | 運用時のみ   | 推奨                 |
| Code scanning / quality      | 任意     | 推奨         | 必須                 |
| Signed commits               | 任意     | 任意         | セキュリティ要件次第 |
| Force push / deletion禁止    | 推奨     | 必須         | 必須                 |
| Bypass list                  | 原則空   | 管理者を限定 | 管理チーム・App限定  |

> [!TIP]
> 最初からすべてを必須化せず、個人開発ではPRとCIから開始し、参加人数や本番影響が増えた段階で承認、Code Owners、セキュリティ検査を追加すると運用負荷を抑えられます。

#### Ruleset運用のTips

1. CIのjob名を変更した場合は、RulesetのRequired status checksも更新
2. CI実績がない新しいcheckは候補に表示されないため、一度GitHub Actionsを実行
3. Required approvalsを`1`以上にすると、個人開発では自分のPRを自分で承認できずマージ不能になる場合あり
4. Bypass listを空にすると管理者も通常フローへ従うため、緊急対応方法を事前に決定
5. `Restrict updates`は直接pushだけでなく通常の更新も強く制限するため、PR必須化だけが目的なら無効を維持
6. Required status checksにはworkflow名ではなく、GitHub上に表示されるcheck名を指定
7. Ruleset変更後はテスト用PRで、CI完了前にマージできず、成功後にマージ可能になることを確認

> [!IMPORTANT]
> 必須checkを削除または改名したままRulesetへ残すと、成功結果を生成できずマージ不能になる可能性があります。GitHub Actions変更とRuleset変更は同時に確認してください。

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
nix build path:.#darwinConfigurations.mac-mini.system --no-link
```

## User Profileの開発

ホストが使用するプロファイルは`hosts/<host-id>/config.nix`で選択します。

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
├── roles/
│   ├── desktop.nix
│   ├── laptop.nix
│   └── server.nix
├── git/default.nix
└── zsh/default.nix
```

`modules/home/default.nix`が`meta.role`と`homeManager`設定から有効なモジュールを選択します。各ツールのモジュールはHome Managerのオプションを使用し、ユーザー単位のインストールと設定を管理します。

### Platformとの統合

macOSはnix-darwinとHome Managerを統合し、UbuntuとRaspberry Pi OSはstandalone Home Managerを使用します。

```text
flake.nix
├── modules/darwin/default.nix
│   ├── modules/darwin/roles/<role>.nix
│   └── Home Manager
│       └── modules/home/default.nix
└── standalone Home Manager
    └── modules/home/default.nix
        ├── modules/home/roles/<role>.nix
        └── modules/home/<tool>/default.nix
```

責務:

- `hosts/default.nix`: 管理対象hostの登録
- `flake.nix`: platform別のnix-darwin・Home Manager構成の生成
- `lib/host-config.nix`: host設定の必須項目、platform、role、systemの検証
- `modules/darwin/default.nix`: nix-darwinとHome Managerの統合
- `modules/darwin/roles/<role>.nix`: macOSの用途別システム設定
- `modules/home/default.nix`: roleと機能フラグに応じたHome Managerモジュールの選択
- `modules/home/roles/<role>.nix`: OSに依存しない用途別ユーザー設定
- `modules/home/<tool>/`: GitやZshなど、ユーザー環境の機能単位の設定

nix-darwinモジュールから`modules/home/<tool>/`を直接importせず、Home Managerを経由します。モジュールの選択処理は`modules/home/default.nix`に集約します。

Homebrew、ログインシェル、システムデフォルトなどmacOS固有の設定は`modules/darwin/`へ配置します。Raspberry Pi OSのブート、ディスク、ネットワーク、システムサービスは今回のNix管理対象外です。

### Host設定

`hosts/<host-id>/config.nix`の`meta`で生成方式と用途を指定します。

```nix
meta = {
  hostname = "HisuiLab-Mac-mini";
  system = "aarch64-darwin";
  platform = "darwin";
  role = "desktop";
};
```

host IDは小文字kebab-caseのディレクトリ名と`hosts/default.nix`の登録キーです。`meta.hostname`は任意で、省略時はhost IDを使用します。

| platform | 対象 | flake出力 |
|---|---|---|
| `darwin` | macOS | `darwinConfigurations.<host-id>` |
| `home-manager` | Ubuntu・Raspberry Pi OS | `homeConfigurations.<host-id>` |

`role`は`desktop`、`laptop`、`server`から選択します。platformとroleは独立しており、Mac miniのdesktop、Ubuntuのserverなどを表現できます。

### Home Manager設定

各hostの`config.nix`でユーザー環境の機能を選択します。

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
- nix-darwinからHome Managerまでの統合テストを`tests/darwin/integration.nix`で管理
- `darwinConfigurations.mac-mini.system`とstandalone Home Manager構成を評価

完成形:

```text
tests/
├── default.nix
├── host-config/
│   └── default.nix
├── home/
│   ├── default.nix
│   ├── integration.nix
│   ├── git/default.nix
│   ├── roles/default.nix
│   └── zsh/default.nix
├── darwin/
│   └── integration.nix
└── user-profile/
    ├── default.nix
    └── fixtures/
```

host追加時は`hosts/<host-id>/config.nix`を作成し、`hosts/default.nix`へ登録します。

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
