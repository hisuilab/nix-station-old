# レビュー: Windows 環境管理機能の追加

## 基本情報

| 項目 | 内容 |
|---|---|
| 日付 | 2026-06-17 |
| 対象ブランチ / PR | `feat/issue-31-windows-management` |
| レビュー担当 | Claude Sonnet 4.6 (自動) |
| レビュー種別 | 設計分析（実装前コードリーディング） |

---

## レビュー観点

既存の Nix 評価・検証フローを壊さずに Windows ホストを追加できるか、コードを読んで阻害要因を洗い出す。

---

## 指摘一覧

| # | 箇所 | 問題 | 対処案 |
|---|---|---|---|
| 1 | [`lib/host-registry.nix` L5-8](../../lib/host-registry.nix#L5) | `platforms` に `"darwin"` と `"home-manager"` しか登録されていない。`windows-gaming` を `hosts/default.nix` に追加して `meta.platform = "windows"` を設定すると、`validateHostConfig`（`host-config.nix` L63-66）が `"unsupported meta.platform 'windows'"` で throw する | `windows-gaming` を `hosts/default.nix` に含めず Nix 評価対象外とする。registry への追加は不要 |
| 2 | [`hosts/default.nix`](../../hosts/default.nix) | `flake.nix` L37-43 で `hosts/default.nix` の全エントリを `validateHostConfig` に通している。ここに `windows-gaming` を追加すると #1 の throw が発生し flake 全体の評価が止まる（CI 破壊） | `windows-gaming` はこのファイルに追加しない。`hosts/windows-gaming/` は `packages.json` のみを置き `setup.ps1` が直接参照する。`config.nix` は作らない（Nix 評価しないため機能せず、誤追加リスクだけ生む） |
| 3 | [`scripts/ai/verify.sh` L24-40](../../scripts/ai/verify.sh#L24) | verify.sh は `checks.*` を個別評価しているため、Windows ホストが `hosts/default.nix` に含まれなければ影響を受けない。ただし将来誤って追加された場合に気づきにくい | `verify.sh` の先頭コメントに「Windows ホストは Nix 評価対象外・このスクリプトには追加しない」を明記する |
| 4 | [`install.sh` L5-6](../../install.sh#L5) | コメントに「対応: macOS (nix-darwin) / Linux (Home Manager standalone)」とあり Windows への言及がない。WSL 内から `./install.sh ubuntu-wsl` を実行する手順が Windows セットアップの続きとして存在するが、入口となるスクリプトが別（`scripts/windows/setup.ps1`）であることがどこにも書かれていない | `install.sh` のコメントに「Windows は `scripts/windows/setup.ps1` を参照」を追記する |
| 5 | [`README.md` L9](../../README.md#L9) | 管理対象 OS の説明に Windows が含まれていない。winget + PowerShell による Windows 管理と、その後の WSL セットアップへの導線が README から辿れない | README に Windows セクションを追加する。ZIP ダウンロード → `setup.ps1` 実行 → WSL へ続く手順を記載する |
| 6 | [`tmp/packages.json`](../../tmp/packages.json) | winget export で生成したパッケージリストが `tmp/` に置かれている。`tmp/` は一時ファイル置き場として慣習的に使われており、バージョン管理すべき設定ファイルの置き場所として適切でない | `hosts/windows-gaming/packages.json` に移動して正式管理する |

---

## 優先度まとめ

### 今すぐ対応（CI 破壊リスク）

- **#2** `hosts/default.nix`: `windows-gaming` を追加しない・`config.nix` を作らない（最重要。誤追加で flake 全体が止まる）

### 近いうちに対応（ドキュメント・構成整備）

- **#4** `install.sh`: Windows は `setup.ps1` を使う旨のコメント追記
- **#5** `README.md`: Windows セットアップセクションの追加
- **#6** `tmp/packages.json`: `hosts/windows-gaming/packages.json` への移動

### 機会があれば対応（防衛的）

- **#1** `lib/host-registry.nix`: 将来 Windows を Nix 管理に含める場合に必要になる変更（今回は対象外）
- **#3** `scripts/ai/verify.sh`: Windows ホスト誤追加を防ぐコメント明記

---

> 意思決定の記録 → `docs/decisions/2026-06-17-issue-31-windows-management.md`
