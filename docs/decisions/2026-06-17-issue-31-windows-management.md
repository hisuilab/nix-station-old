# 意思決定の記録: issue-31-windows-management

> 記録日: 2026-06-17
> ファイル名: `docs/decisions/2026-06-17-issue-31-windows-management.md`

---

| # | 優先度 | 判断 | 理由・備考 |
|---|---|---|---|
| 1 | 高 | スコープを「Windows 側のみ（winget によるパッケージ一括インストール）」に限定する | 今回の目的はゲーム用 Windows 環境の構築と WSL の使用可能化まで。WSL 内の home-manager セットアップは既存の `./install.sh ubuntu-wsl` フローを使う |
| 2 | 高 | 初回セットアップ方式を「GitHub から ZIP ダウンロード → 展開 → PowerShell で実行」とする | Git が未インストールの新規 Windows PC でも実行できるようにするため。`irm \| iex` 方式は採用しない |
| 3 | 高 | WSL ホスト紐付け（`meta.wslHost`）は今回スコープ外とする | 実装コストに対してユーザー体験向上が小さい。WSL セットアップは別フローとして案内するだけで十分 |
| 4 | 高 | `tmp/packages.json` を `hosts/windows-gaming/packages.json` に移動して正式管理する | `tmp/` はリポジトリに含めるべき永続データの置き場所ではない `.gitignore`に除外対象として明記 |
| 5 | 高 | `hosts/windows-gaming/` には `packages.json` のみ置き、`config.nix` は作らない | `config.nix` を Nix で評価しないため `setup.ps1` から読めず機能的に不要。`hosts/default.nix` への誤追加リスクもなくなる。`packages.json` だけで `setup.ps1` は完結する |
| 6 | 中 | darwin.homebrew 相当の `windows.winget` オプション構造は作らない | winget は Windows 11 標準搭載のため `enable` / `install` に相当するオプションが不要。`config.nix` を Nix 評価しないため設定を書いても `setup.ps1` が読めない。オプションが必要になれば `setup.ps1` のコマンドライン引数で対応する |
| 7 | 中 | `scripts/windows/setup.ps1` は `winget import --ignore-versions` を使い冪等に実行できるようにする | 再実行時に既インストール済みパッケージをスキップするため |
| 8 | 低 | 実行ポリシー回避は `-ExecutionPolicy Bypass` を README に記載するだけにとどめる | スクリプト内でポリシーを変更するのはセキュリティ上適切でない |
| 9 | 中 | `install.sh` を薄いエントリポイントとして残し、OS・機能ごとのロジックを `scripts/` 以下に分割管理する。構成: `scripts/common/` (共通ヘルパー・ユーザープロファイル処理)、`scripts/darwin/` (darwin-rebuild・brew bundle)、`scripts/linux/` (home-manager switch)、`scripts/windows/` (winget import・PS1)。`install.sh` は OS 検出のみ行い対応スクリプトに委譲する | Windows スクリプト追加を機に `install.sh` が肥大化することを防ぐ。各 OS のロジックが独立してテスト・修正しやすくなる。darwin 側の brew 再設計（macair issue-32）のマージ後に分割着手する |
