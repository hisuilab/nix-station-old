# Nix Station: 開発プロセス・CI/CD・チーム規律

## 1. 開発サイクルと命名規則 (GitHub & Git Flow)

GitHub Issue を起点とし、完全なトレーサビリティ（追跡可能性）を確保する。

1. **Issue起票:** `gh issue create --title "feat: [Pkg名] の追加" --body "..."` で機能単位のIssueを作成。
2. **Branch作成:** 以下の命名規則を徹底し、ローカル環境へチェックアウトする。
   - **規則:** `feat/issue-[Issue番号]-[機能を表す英単語]` または `fix/issue-[番号]-[修正対象]`
   - **例:** `feat/issue-12-zsh-setup`, `fix/issue-45-homebrew-zap`
3. **テスト作成:** `tests/[機能名].nix` に期待する構成のテスト（最初は失敗する状態）を記述。
4. **実装 & パス:** コードを実装し、ローカルテストおよび pre-commit をパスさせる。
5. **PR & マージ:** PRを作成し、GitHub Actions（CI）がグリーンになったら `Squash and merge`。

## 2. コミット規律 (Conventional Commits)

すべてのコミットメッセージは **Conventional Commits 1.0.0** に準拠する。プレコミット時に Linter で強制チェックをかける。

- **基本フォーマット:** `<type>(<scope>): <description>` （※scopeは任意）
- **主要タイプ（Type）:**
  - `feat`: 新しいパッケージの追加、新しい設定の導入
  - `fix`: バグ修正（ビルドエラー、タイポ、設定漏れの修正）
  - `test`: テストコードの追加・修正
  - `infra`: CI/CD、pre-commit、justfile などの開発基盤整備
  - `docs`: ドキュメント（README、仕様書など）の更新
  - `refactor`: 機能変更を伴わないコードの整理・リファクタリング
- **コミット例:** `feat(zsh): p10k.zshの読み込みとテーマ設定を追加`

## 3. CI/CD & テスト自動化設計 (GitHub Actions)

- **トリガー:** `main` ブランチへのPR、および `main` へのマージ時。
- **テスト環境:** `x86_64-linux` と `aarch64-darwin` のマルチランナー。
- **検証内容:**
  1. `nix flake check`: 全テストコード（`checks/`）の実行。
  2. ドライランビルド: 実際にシステムを変更せず `darwin-rebuild build --flake .#[ホスト名]` 等が通るか検証。

## 4. pre-commit による品質担保（ローカル自動チェック）

`git commit` を実行した瞬間、以下のツールが走り、違反がある場合はコミットをブロックする。

- `alejandra` / `nixpkgs-fmt`: Nixコードの自動整形。
- `statix` / `deadnix`: Nixのアンチパターン検知、未使用変数の自動削除。
- `commitlint`: コミットメッセージが Conventional Commits に準拠しているかの検証。
- `actionlint`: GitHub Actions（YAML）の構文チェック。

## 5. 最小構成（MVP）構築用ファイル

```text
.
├── .github/workflows/ci.yml   # GitHub Actions 定義
├── flake.nix                   # 総司令塔（pre-commit / テスト統合）
├── hosts/laptop/host-config.nix # テスト用の最小限のトグル（例: shell = true;）
└── tests/laptop-test.nix       # 期待通りの型や設定が返るかの評価テスト
```
