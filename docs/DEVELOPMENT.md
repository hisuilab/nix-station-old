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

| 項目                                      | 今回の設定値                 | 用途・有効にする場面                                     |
| ----------------------------------------- | ---------------------------- | -------------------------------------------------------- |
| Ruleset Name                              | `Protect main`               | Rulesets一覧で対象と目的を識別                           |
| Enforcement status                        | `Active`                     | ルールを実際に適用。検証だけの場合は`Evaluate`を使用     |
| Bypass list                               | 空                           | 緊急対応者や自動化Appへ例外を許可する場合のみ追加        |
| Target branches                           | Default branch               | デフォルトブランチを保護。固定名ならpatternで`main`指定  |
| Restrict creations                        | 無効                         | 特定名のブランチ作成を管理者などに限定する場合に有効     |
| Restrict updates                          | 無効                         | 対象ブランチの更新者をBypass対象だけに限定する場合に有効 |
| Restrict deletions                        | 有効                         | `main`など重要ブランチの誤削除を防止                     |
| Require linear history                    | 無効                         | merge commitを禁止し、履歴を直線化する場合に有効         |
| Require deployments to succeed            | 無効                         | stagingやproductionへのデプロイ成功をマージ条件に追加    |
| Require signed commits                    | 無効                         | コミット作成者の検証を厳格化する場合に有効               |
| Require a pull request before merging     | 有効                         | 直接pushを避け、レビューとCIを経由                       |
| Required approvals                        | `0`                          | チーム開発では`1`以上にして第三者承認を必須化            |
| Dismiss stale pull request approvals      | 無効                         | 承認後の追加変更で古い承認を無効化する場合に有効         |
| Require review from Code Owners           | 無効                         | 所有者ごとのレビューを必須化する場合に有効               |
| Require approval of most recent push      | 無効                         | 最後の変更をpushした本人以外の承認を必須化               |
| Require conversation resolution           | 無効                         | 未解決のレビューコメントがあるPRのマージを禁止           |
| Allowed merge methods                     | すべて                       | 履歴方針に応じてMerge、Squash、Rebaseを制限              |
| Require status checks to pass             | 有効                         | CIが成功するまでマージを禁止                             |
| Require branches to be up to date         | 無効                         | 最新の対象ブランチ上でCI成功を必須化する場合に有効       |
| Do not require status checks on creation  | 無効                         | 新規ブランチ作成時だけstatus checkを免除する場合に有効   |
| Required status checks                    | `macos-check`、`linux-check` | macOSとLinux両方のNix評価・build成功を必須化             |
| Block force pushes                        | 有効                         | 共有履歴の強制書き換えを防止                             |
| Require code scanning results             | 無効                         | CodeQLなどの脆弱性検査をマージ条件に追加                 |
| Require code quality results              | 無効                         | 静的解析や品質基準をマージ条件に追加                     |
| Automatically request Copilot code review | 無効                         | Copilotによる自動レビューを利用する場合に有効            |

`Default branch`を対象にすると、デフォルトブランチ名を変更した場合もRulesetの対象が追従します。

設定内容を確認し、`Create`でRulesetを保存します。
保存後、Rulesets一覧で`Protect main`が`Active`と表示されることを確認します。

> [!NOTE]
>
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

`guest.nix`、ローダーの`default.nix`、リポジトリテスト用の`test.nix`を除き、`user-profiles/*.nix`は`.gitignore`対象です。個人プロファイルはローカルで作成し、共有・CI用途のプロファイルだけ`.gitignore`へ例外を追加してGitで追跡します。Gitで追跡されないファイルはFlakeの入力方式によって評価対象外になるため、CIでは`user-profiles/test.nix`とテストfixtureを使用します。

## モジュール構成

システム設定とユーザー環境の責務を分離します。

### Home Managerモジュール

Home Managerで管理するユーザー環境は`modules/home/<tool>/default.nix`へ配置します。

```text
modules/home/
├── default.nix
├── platforms/
│   ├── darwin/default.nix
│   ├── ubuntu/default.nix
│   └── raspberry-pi-os/default.nix
├── environments/
│   ├── native/default.nix
│   └── wsl/default.nix
├── roles/
│   ├── desktop.nix
│   ├── laptop.nix
│   └── server.nix
├── gh/default.nix
├── ghostty/
│   ├── config
│   └── default.nix
├── git/default.nix
├── p10k/
│   ├── default.nix
│   └── p10k.zsh
├── cli-tools/default.nix
├── zed/
│   ├── default.nix
│   └── settings.json
└── zsh/default.nix
```

`modules/home/default.nix`が`meta.os`、`meta.environment`、`meta.role`、`homeManager`設定から有効なモジュールを選択します。Home Managerはツールフラグがすべて無効でも生成され、OS、実行環境、roleの基本設定を適用します。

ツール追加時は`modules/home/<tool>/default.nix`を作成し、`modules/home/default.nix`の`toolModules`へ登録します。host validatorは`homeManager`配下の任意のbooleanフラグを受け付けるため、既存host configの更新は不要です。未登録のツール名はHome Manager評価時にエラーになります。

OS固有設定は次の責任で管理します。

- `platforms/darwin/`: macOSユーザー固有設定
- `platforms/ubuntu/`: Ubuntuユーザー固有設定
- `platforms/raspberry-pi-os/`: Raspberry Pi OSユーザー固有設定
- `environments/native/`: 通常のOS環境向け設定
- `environments/wsl/`: WSL統合設定
- `roles/`: OSに依存しない用途別設定
- `<tool>/`: OS共通のツール設定

### Platformとの統合

macOSはnix-darwinとHome Managerを統合し、UbuntuとRaspberry Pi OSはstandalone Home Managerを使用します。

```text
flake.nix
├── modules/system/darwin/default.nix
│   ├── modules/system/darwin/core/default.nix
│   ├── modules/system/darwin/features/default.nix
│   ├── modules/system/darwin/roles/<role>.nix
│   └── Home Manager
│       └── modules/home/default.nix
└── standalone Home Manager
    └── modules/home/default.nix
        ├── modules/home/platforms/<os>/default.nix
        ├── modules/home/environments/<environment>/default.nix
        ├── modules/home/roles/<role>.nix
        └── modules/home/<tool>/default.nix
```

責務:

- `hosts/default.nix`: 管理対象hostの登録
- `lib/host-registry.nix`: platform、OS、environment、roleと対応モジュールの登録
- `flake.nix`: platform別のnix-darwin・Home Manager構成の生成
- `lib/host-config.nix`: host設定の必須項目、platform、os、environment、role、systemの検証
- `modules/system/darwin/default.nix`: nix-darwinとHome Managerの統合
- `modules/system/darwin/core/default.nix`: Nix設定、タイムゾーン、stateVersion
- `modules/system/darwin/features/<feature>/`: macOS defaultsなど機能単位の設定
- `modules/system/darwin/homebrew/default.nix`: Homebrewパッケージとactivation方針
- `modules/system/darwin/roles/<role>.nix`: macOSの用途別システム設定
- `modules/home/default.nix`: roleと機能フラグに応じたHome Managerモジュールの選択
- `modules/home/platforms/<os>/`: OS固有のユーザー設定
- `modules/home/environments/<environment>/`: native、WSLなど実行環境固有の設定
- `modules/home/roles/<role>.nix`: OSに依存しない用途別ユーザー設定
- `modules/home/<tool>/`: GitやZshなど、ユーザー環境の機能単位の設定

nix-darwinモジュールから`modules/home/<tool>/`を直接importせず、Home Managerを経由します。モジュールの選択処理は`modules/home/default.nix`に集約します。

HomebrewやログインシェルなどmacOSシステム固有の設定は`modules/system/darwin/`へ配置します。`modules/common/`は使用せず、OSに依存しないユーザー設定はHome Managerへ配置します。

macOS defaultsは次の単位で管理します。

```text
modules/system/darwin/features/
├── default.nix
├── appearance/default.nix
├── dock/default.nix
├── finder/default.nix
└── input/default.nix
```

各featureの`default.nix`に設定例コメントを用意しています。実装時は対象featureへ設定を追加し、host側で有効化します。

```nix
darwin.features = {
  appearance = true;
  finder = true;
};
```

Finderサイドバーの初期化や`killall`を伴うactivation scriptなど、既存ユーザー環境へ影響する処理は通常のFinder defaultsと分離し、明示的に有効化する独立featureとして追加します。

Homebrew本体はnix-homebrewで導入し、formula・cask・Mac App Storeアプリはnix-darwinの`homebrew`設定で管理します。macOS hostでは初期状態から有効です。

```nix
darwin.homebrew = {
  enable = true;
  brews = [ "wget" ];
  casks = [ "ghostty" ];
  taps = [ ];
  masApps = { };
};
```

新規環境ではHomebrewを標準prefixへ導入します。既存Homebrewは`autoMigrate = true`で管理下へ移行します。Apple SiliconではRosetta用Homebrewも有効化し、`brew`ランチャーがアーキテクチャに応じたprefixを選択します。

現在のnix-homebrewはnix-darwin 24.11と互換性のあるrevisionへ固定しています。nix-darwinを更新する際はnix-homebrewの固定revisionも更新し、`nix flake check path:.`でHomebrew本体のbuildまで確認します。

`enable = true`の場合、未指定のactivation方針は`autoUpdate = true`、`upgrade = true`、`cleanup = "none"`です。宣言外パッケージを削除する場合だけ、host側で`cleanup = "uninstall"`または`"zap"`を明示します。

Raspberry Pi OSのブート、ディスク、ネットワーク、システムサービスは今回のNix管理対象外です。

### Host設定

`hosts/<host-id>/config.nix`の`meta`で生成方式と用途を指定します。

```nix
meta = {
  hostname = "HisuiLab-Mac-mini";
  system = "aarch64-darwin";
  platform = "darwin";
  os = "darwin";
  environment = "native";
  role = "desktop";
};
```

host IDは小文字kebab-caseのディレクトリ名と`hosts/default.nix`の登録キーです。`meta.hostname`は任意で、省略時はhost IDを使用します。

`darwin`では`meta.hostname`を`networking.hostName`へ反映します。standalone Home ManagerはOSのhostnameを変更できないため、Linuxの`meta.hostname`はhost識別用のメタデータです。

| platform       | 対象                                   | flake出力                        |
| -------------- | -------------------------------------- | -------------------------------- |
| `darwin`       | macOS                                  | `darwinConfigurations.<host-id>` |
| `home-manager` | Ubuntu・Ubuntu on WSL・Raspberry Pi OS | `homeConfigurations.<host-id>`   |

`platform`は構成の生成方式、`os`はHome ManagerのOS固有モジュール、`environment`は実行環境固有モジュール、`role`は用途別モジュールを選択します。

| 項目          | 例       | 責任                                             |
| ------------- | -------- | ------------------------------------------------ |
| `platform`    | `darwin` | nix-darwinまたはstandalone Home Managerの選択    |
| `os`          | `ubuntu` | `modules/home/platforms/<os>/`の選択             |
| `environment` | `wsl`    | `modules/home/environments/<environment>/`の選択 |
| `role`        | `server` | `modules/home/roles/<role>.nix`の選択            |

`platform = "darwin"`では`os = "darwin"`かつ`environment = "native"`を指定します。`platform = "home-manager"`では`os = "ubuntu"`または`raspberry-pi-os`を指定します。現在の`environment = "wsl"`は`os = "ubuntu"`のみ対応します。

利用可能なOS、environment、roleと対応モジュールは`lib/host-registry.nix`へ集約します。新しいOSを追加する場合はregistryへ互換system、environment、Home Managerモジュールを登録し、対応するテストとFlake checkを追加します。

### Roleの用途

`role`はハードウェア種別やhost名ではなく、端末へ適用する用途別ポリシーです。

| role      | 想定用途               | 設定例                                      |
| --------- | ---------------------- | ------------------------------------------- |
| `desktop` | GUI中心の常用端末      | GUIツール、デスクトップ向け環境変数         |
| `laptop`  | 持ち運ぶ常用端末       | 省電力、モバイル向け設定、desktop設定の一部 |
| `server`  | 常時稼働・遠隔操作中心 | GUI依存を避けたCLI、サービス運用向け設定    |

host名とroleは一致する必要がありません。例えば`ubuntu-desktop`をサーバー用途で使う場合は`role = "server"`が適切です。現在のroleモジュールは分類値の設定が中心ですが、今後role固有ツールやポリシーを追加する受け口として使用します。

### Home Directoryの拡張例

現在のstandalone Home Managerは`/home/<username>`を使用します。独自パスが必要になった場合は、次のようにhost設定で任意指定できる形へ拡張します。

```nix
meta = {
  homeDirectory = "/custom/home/example";
};
```

Flake側の実装例:

```nix
home.homeDirectory =
  hostConfig.meta.homeDirectory or "/home/${userProfile.username}";
```

validatorでは、指定時に空でない絶対パスであることを検証します。通常利用では設定項目を増やさないため、必要になるまで実装しません。

Ubuntu on WSLのhost例:

```nix
meta = {
  hostname = "ubuntu-wsl";
  system = "x86_64-linux";
  platform = "home-manager";
  os = "ubuntu";
  environment = "wsl";
  role = "desktop";
};
```

WSLでは`modules/home/platforms/ubuntu/`と`modules/home/environments/wsl/`の両方を読み込みます。現在は`wslu`と`BROWSER=wslview`を有効化します。Windows本体の設定やWSLディストリビューションの作成は管理対象外です。

### Home Manager設定

各hostの`config.nix`でユーザー環境の機能を選択します。`homeManager`自体と各フラグは省略可能で、未指定値は`false`として扱います。

```nix
homeManager = {
  git = true;
  zsh = true;
};
```

- `homeManager.git = true`: `userProfile.git.userName`と`userProfile.git.userEmail`をGit設定へ反映
- `homeManager.zsh = true`: 最小限のZsh設定を有効化
- `homeManager.p10k.enable = true`: Powerlevel10k本体とテーマを有効化
- `homeManager.p10k.configFile`: `~/.p10k.zsh`として配置する設定ファイル。`null`ならテーマのみ有効
- `homeManager.ghostty.enable = true`: Ghostty設定管理を有効化
- `homeManager.ghostty.configFile`: Ghosttyへ配置する設定ファイル。`null`なら配布しない
- `homeManager.zed.enable = true`: Zed設定管理を有効化
- `homeManager.zed.configFile`: Zedへ配置する設定ファイル。`null`なら配布しない
- `homeManager.gh = true`: GitHub CLIを有効化
- `homeManager.cliTools = true`: Devbox、Claude Code、ターミナル操作、検索などのCLIを導入
- すべて`false`: roleとHome Manager基盤のみ生成

すべてのhostで`p10k`、`ghostty`、`zed`を明示します。`server` roleではGUIアプリの
`ghostty`と`zed`を無効化し、`p10k.enable`は`zsh`が有効なhostでのみ有効化します。
これらのツールは共通して`enable`と`configFile`で構成し、hostごとに設定ファイルを
差し替えられます。

DockerはmacOSでは`docker-desktop` caskで管理します。Ubuntu、WSL、Raspberry Pi OSではDocker CLIをHome Managerで導入します。Docker daemonの起動とユーザー権限はシステム設定を伴うため、standalone Home Managerの管理対象外です。

macOS統合では、`userProfile.username`をmacOSのユーザーとホームディレクトリへ関連付けます。`homeManager.zsh = true`の場合はZshをログインシェルとして設定します。`guest`と`test`は評価・ビルドテスト用とし、実機への適用時は既存のmacOSユーザーに対応するプロファイルを指定します。

### テスト方針

- 各`homeManager`フラグの`true`と`false`を単体テスト
- Home Managerから`modules/home/default.nix`、`modules/home/<tool>/`までの読み込み経路を統合テスト
- 各ツールのテストを`tests/home/<tool>/default.nix`で管理
- Home Manager統合テストを`tests/home/integration.nix`で管理
- nix-darwinからHome Managerまでの統合テストを`tests/darwin/integration.nix`で管理
- macOS feature分流を`tests/darwin/features/default.nix`で管理
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
│   ├── environments/default.nix
│   ├── git/default.nix
│   ├── platforms/default.nix
│   ├── roles/default.nix
│   └── zsh/default.nix
├── darwin/
│   ├── features/default.nix
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

- `macos-check`: 全system評価とmacOS checksの実ビルド
- `linux-check`: Ubuntu native・WSL Home Manager構成の実ビルド
- Nix: Determinate Nix `v3.21.1`
- Action: `v3.21.1`の完全なcommit SHAへ固定

Raspberry Pi OSの`aarch64-linux`構成は`macos-check`の`--all-systems --no-build`で評価します。ARM64 self-hosted runnerやQEMUを利用者の前提にせず、Raspberry Pi OSへNixとHome Managerを導入すれば同じ構成を利用できる方針です。実機固有の問題はRaspberry Pi上での適用時に確認します。

WSLは`ubuntu-latest`上でHome Manager構成を実ビルドします。これはLinuxソフトウェアとしての依存関係と生成結果を保証しますが、Windowsアプリ起動や`wslview`の実動作までは保証しません。

Nixを更新する場合は、`.github/workflows/ci.yml`内のAction SHAと2箇所の`source-tag`を同じリリースへ更新します。通常はファイル1つの変更とCI再実行だけで済み、所要時間は数分程度です。Nixの挙動変更がFlake評価へ影響した場合のみ、警告や評価エラーへの対応が追加で必要です。`nixpkgs`、nix-darwin、Home Managerの更新は別管理であり、Nix本体の更新だけでは`flake.lock`の変更は不要です。

Rulesetでrequired status checksを設定する場合は、旧`nix-check`ではなく`macos-check`と`linux-check`を必須にします。

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
