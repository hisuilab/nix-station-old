# レビューチェックリスト — nix-station

AI・人間レビュー共通の観点。このファイルが唯一の定義。

## 必須チェック（全変更共通）

- [ ] `docs/ai/protected_paths.txt` の対象ファイルを変更していないか（または承認済みか）
- [ ] `git diff --staged` でステージ内容を確認したか
- [ ] `user-profiles/*.nix` をコミット対象に含めていないか

## Nix / nix-darwin

- [ ] 使用する nix-darwin / home-manager オプションを `grep` で存在確認したか
- [ ] `nix flake check path:. --no-build --all-systems` が通るか
- [ ] `flake.lock` を意図せず更新していないか

## ドキュメント

- [ ] 新しい開発者がリポジトリをセットアップするのに必要な手順が揃っているか
- [ ] コメントが WHY（なぜこう書いたか）を説明しているか（WHAT のみは不要）

## 設計

- [ ] 既存パターンと一貫しているか（同じ問題を同じ方法で解いているか）
- [ ] 新しい抽象化・ヘルパーを導入する必然性があるか
- [ ] `docs/decisions/` に意思決定の記録があるか（非自明な変更の場合）

## テスト

- [ ] 新しい機能にテストがあるか
- [ ] CI (`nix flake check`) が通るか

## セキュリティ

- [ ] 秘密情報（トークン・パスワード・SSH 鍵）をコミットしていないか
- [ ] `scripts/ai/secret-scan.sh` を実行したか
