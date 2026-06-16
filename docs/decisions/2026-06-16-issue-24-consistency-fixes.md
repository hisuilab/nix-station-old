# 意思決定の記録: issue-24-consistency-fixes

> 記録日: 2026-06-16

---

| # | 判断 | 優先度 | 理由・備考 |
|---|---|---|---|
| 1 | 実装済み（#7・#8 実装に伴い解消） | — | darwin.homebrew から brews/casks を除去したためバリデーションバイパスは発生しなくなった。makeHostConfigWith でテスト側の構造も修正済み |
| 2 | | | |
| 3 | DEVELOPMENT.md を更新する（#8 で対象範囲が拡大） | 中 | 当初の managed tool 追加手順（host-registry.nix 更新）に加え、#8 の決定により Brewfile 運用手順（common + host 差分構造・brew bundle 2段階コマンド・brew bundle cleanup の手動実行）と README.md の Apply Configuration 手順の更新も対象に含める |
| 4 | DEVELOPMENT.md の autoMigrate / mutableTaps 記述を削除する | 中 | #7 の実装で autoMigrate・mutableTaps をコードから除去したため、設定可能として更新するのではなく記述ごと削除する |
| 5 | | | |
| 6 | | | |
| 7 | brewfileで別管理する 手動でbrew bundle管理にする | 高 | nix管理にbrewが入っているとnix-stationの管理対象が混乱するのと、brewの長時間実行によるブロックを回避したい |
| 8 | hosts/common/Brewfile を新設し各ホストは固有差分のみ管理する（案 A） | 高 | laptop と desktop で共通アプリが多いため重複を避ける。role 単位より hostId 単位の差分のほうがシンプルで現状のホスト数に合っている |
