# コードレビュー: refactor/issue-20-review-refactor 後の残件

> このレビューは [Claude Sonnet 4.6](https://claude.ai) によって 2026-06-16 に実施しました。
> 対象: PR #23 マージ後に発見された整合性・保守性の残件（issue #24）

---

## レビュー観点

- テスト — バリデーションの網羅性・実装変更との整合性
- 実装 — 対称性・DRY・不要なエクスポート
- ドキュメント — 手順の正確性・変更への追従

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | [`tests/darwin/integration.nix` L82-110](../../tests/darwin/integration.nix#L82) | `(makeHostConfig ...) // { darwin.homebrew = {...}; }` とバリデーション後に `//` マージしているため、`darwin.homebrew` が `validateHostConfig` を通らない。PR #23 の #5（`mkDarwinConfiguration` 内部バリデーション除去）により実際には未検証 | `darwin.homebrew` を raw config に含めて `makeHostConfig` に渡し、validation を通す |
| 2 | [`flake.nix` L246-262](../../flake.nix#L246) | Darwin MockEvals は `mapAttrs darwinHosts` で自動展開済みだが、Linux MockEvals（`raspberryPi5MockEval` / `ubuntuDesktopMockEval` / `ubuntuWslMockEval`）は hostId を直書き。新 Linux ホスト追加時に手動更新が必要 | `mapAttrs homeManagerHosts` + system でグループ化して自動展開 |
| 3 | [`docs/DEVELOPMENT.md` L306](../../docs/DEVELOPMENT.md#L306) | managed tool（attrset config を持つ ghostty/p10k/zed 相当）追加時に `lib/host-registry.nix` の `managedTools` 更新が必要だが未記載。PR #23 の #8 で一元化したが手順が未更新 | managed tool と boolean tool の違いを明記し、managed tool の場合に `host-registry.nix` も更新することを追記 |
| 4 | [`docs/DEVELOPMENT.md` L393](../../docs/DEVELOPMENT.md#L393) | `autoMigrate = true` を常時有効として記載しているが、PR #23 の #7 でホスト設定から上書き可能になった（デフォルト `true`）。`mutableTaps` も同様 | デフォルト値であること・ホスト設定で上書き可能であることを明記 |
| 5 | [`flake.nix` L190-222](../../flake.nix#L190) | `tests/darwin/integration.nix` を同じ引数で5回 `import` している（`darwinEnabledEval` / `darwinDisabledEval` / `darwinRoutingEval` / `darwinRoleRoutingEval` / `darwinHomebrewEval`）。Nix のキャッシュで実害はないが冗長 | `let darwinTests = import ./tests/darwin/integration.nix { ... }; in` で1度だけ bind し各フィールドを参照 |
| 6 | [`user-profiles/default.nix` L74](../../user-profiles/default.nix#L74) | `validateProfileName` と `validateUserProfile` がエクスポートされているが外部から使われていない。PR #23 の #12（`importUserProfile` 除去）と合わせて整理できる | 未使用エクスポートを削除し `loadUserProfile` に一本化 |
| 7 | [`modules/system/darwin/homebrew/default.nix` L26](../../modules/system/darwin/homebrew/default.nix#L26) | nix-darwin の activation-scripts は DAG ではなくハードコードされたテンプレート順（`homebrew.text` → `postUserActivation.text` 固定）。`brew bundle` はインストール・アップデート量が多い場合に長時間かかるため、後続の `postUserActivation`（Home Manager・Dock・Finder 設定）がブロックされる。順序の変更はテンプレートが固定のためできない | `system.activationScripts.homebrew.text = lib.mkForce ""` で自動実行を無効化し、`postUserActivation` の末尾へ移設するか、Brewfile を別ファイルで管理して `darwin-rebuild switch` 後に手動で `brew bundle` を実行する構成へ変更する |

---

## 優先度まとめ

### 高（バグ・バリデーション抜け）

- **#1** `tests/darwin/integration.nix`: homebrew テストが validation をバイパス

### 中（保守性・設計の対称性）

- **#2** Linux MockEvals の自動展開（darwin と非対称）
- **#3** DEVELOPMENT.md: managed tool 追加手順に `host-registry.nix` 更新が未記載
- **#4** DEVELOPMENT.md: `autoMigrate` / `mutableTaps` が設定可能になった旨が未記載
- **#7** darwin Homebrew activation 順序: `brew bundle` が `postUserActivation` をブロック

### 低（コードの整理）

- **#5** `flake.nix`: darwin integration test の重複 import
- **#6** `user-profiles/default.nix`: 未使用エクスポート


> 意思決定の記録 → `docs/decisions/2026-06-16-issue-24-consistency-fixes.md`
