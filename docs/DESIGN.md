# nix-station 設計原則

nix-station は **OSS フレームワーク**として設計する。
フレームワーク自体の品質とユーザー固有の設定を明確に分離することが基本方針。

---

## フレームワークの責務とユーザーの責務

```
nix-station リポジトリ
├── Framework（コミット対象）
│   ├── modules/         モジュール定義
│   ├── lib/             バリデーション・ユーティリティ
│   ├── tests/           フレームワークテスト
│   ├── hosts/           ホストスキーマ定義
│   └── user-profiles/   guest.nix・test.nix のみ
│
└── Instance（コミットしない）
    └── user-profiles/<name>.nix  個人プロファイル（gitignore）
```

**フレームワーク**が保証するもの: モジュールのスキーマ、ロジック、ルーティングの正しさ
**ユーザー**が責任を持つもの: 自分のプロファイルの作成、ホストへの紐付け、デプロイ

---

## 品質保証の3層構造

### Layer 1: Framework Quality — `nix flake check`

**責任**: このリポジトリのコードは正しいか

- モジュールのスキーマ・型が正しいか
- ルーティングロジック（role / platform / feature フラグ）が正しいか
- ホスト設定の構造が正しいか

**実装**: `checks.*` に `testUserProfile` を使ったテストを配置する
**原則**: ユーザー固有データを一切必要としない。clone 直後から `nix flake check` が通ること

```
checks.aarch64-darwin.tests              # ユニットテスト（純粋 Nix）
checks.aarch64-darwin.darwinEnabledEval  # モジュール統合（testUserProfile）
checks.aarch64-darwin.macbook-air        # ホストスキーマ（testUserProfile）
```

### Layer 2: Profile Quality — `loadUserProfile`

**責任**: このプロファイルは完全か

- `username` が存在・非空か
- `git.userName` が存在・非空か
- `git.userEmail` が存在・非空か

**実装**: `user-profiles/default.nix` の `validateUserProfile` が担う
**発火タイミング**: `darwin-rebuild switch` 時（`nix flake check` 時ではない）

### Layer 3: Deploy Quality — `setup.sh` / `activationScripts`

**責任**: このマシンはデプロイ準備ができているか

| チェック内容 | 実装場所 | 発火タイミング |
|---|---|---|
| guest プロファイルでないか | `activationScripts` | `darwin-rebuild switch` 時 |
| プロファイルファイルが存在するか | `setup.sh` | セットアップ対話時 |
| ホスト名・プラットフォームが一致するか | `setup.sh` | セットアップ対話時 |

---

## `nix flake check` の責任範囲

`nix flake check` は以下を検証する:

| 対象 | 検証内容 |
|---|---|
| `checks.*` | 明示的なテストスイートをビルド・実行する |
| その他の output | 評価可能か（型・構文レベル）を確認する |

`nix flake check` が責任を持たないもの:

- ユーザーがプロファイルを設定済みかどうか
- そのホストがデプロイ可能な状態かどうか

これらは Layer 3 の責任であり、`setup.sh` と `activationScripts` が担う。

---

## Nix の評価時 vs 適用時

nix-darwin の `assertions` は**評価時**に発火する。`nix flake check` も評価を行うため、`assertions` に運用上の条件（「guest のままデプロイしないか」等）を置くと `nix flake check` が壊れる。

| 仕組み | 発火タイミング | 適切な用途 |
|---|---|---|
| `assertions` | 評価時（`nix flake check` 含む） | スキーマ違反・型エラー（必ずビルド不能なもの） |
| `activationScripts` | 適用時（`darwin-rebuild switch` のみ） | デプロイ前提条件（ユーザー設定済みか等） |

**原則**: 運用上の条件チェックは `activationScripts` に置く。

---

## `darwinConfigurations` の扱い

`darwinConfigurations` はデプロイ用成果物であり、CI テストターゲットではない。
ユーザープロファイルをリポジトリにコミットしない方針のため、パーソナルホストを `darwinConfigurations` に含めると `nix flake check` が失敗する。

**方針**: パーソナルホストは `darwinConfigurations` から外す。

```
darwinConfigurations に含めるもの:
└── （なし、またはデモ用の完全コミット済みホストのみ）

checks に含めるもの:
├── checks.aarch64-darwin.macbook-air  # スキーマ検証（testUserProfile）
└── checks.aarch64-darwin.mac-mini    # スキーマ検証（testUserProfile）
```

デプロイは `setup.sh` 経由で行う。`setup.sh` が `darwin-rebuild switch --impure --flake` を内部で呼び出す。

---

## ユーザープロファイルの管理方針

| ファイル | git 管理 | 用途 |
|---|---|---|
| `user-profiles/guest.nix` | コミット | デフォルト・未設定状態のテンプレート |
| `user-profiles/test.nix` | コミット | フレームワークテスト専用モック |
| `user-profiles/<name>.nix` | **gitignore** | 個人プロファイル（コミットしない） |

個人プロファイルは `setup.sh` が対話形式で生成する。
Nix 評価では `--impure` フラグを使いローカルファイルを参照する。

---

## OSS フレームワークとしての原則

1. **clone 直後から `nix flake check` が通ること** — フレームワーク品質の最低保証
2. **個人情報をリポジトリにコミットしないこと** — ユーザープロファイルは gitignore
3. **`setup.sh` が唯一のユーザー向け導線であること** — Nix の知識がなくても使える
4. **責務の層を越えないこと** — Layer 1 が Layer 3 の仕事をしない
