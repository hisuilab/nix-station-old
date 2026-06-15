# p10k module

Powerlevel10k のテーマ設定を管理するモジュール。

## ファイル構成

```
p10k/
├── p10k.zsh          # エントリーポイント。conf.d/ を順番に source する
├── default.nix       # Nix 設定。~/.p10k.zsh と ~/.p10k.d/ を配置する
└── conf.d/
    ├── 01-palette.zsh     # テーマファイルを source するだけ
    ├── 02-elements.zsh    # プロンプト要素 (左/右) の並び順
    ├── 03-layout.zsh      # 区切り文字・フレーム・ギャップなどのレイアウト
    ├── 04-prompt-core.zsh # os_icon / dir / status / prompt_char の設定
    ├── 05-vcs.zsh         # Git ステータス・カスタムフォーマッタ
    ├── 06-segments.zsh    # 汎用セグメント (時刻・コマンド実行時間など)
    ├── 07-devtools.zsh    # 言語・ランタイム系セグメント
    ├── 08-cloud.zsh       # クラウド・インフラ系セグメント
    ├── 09-behavior.zsh    # instant prompt / transient prompt などの挙動
    ├── 10-utils.zsh       # theme コマンド定義
    └── theme/
        ├── cyberpunk.zsh   # サイバーパンク
        ├── dracula.zsh     # ドラキュラ
        ├── gruvbox.zsh     # グルーブボックス
        ├── nord.zsh        # ノルド
        └── tokyo-night.zsh # トーキョーナイト
```

## theme コマンド

```zsh
theme              # トグル (p10k ↔ plain)
theme list         # 利用可能なテーマを一覧表示
theme cyberpunk    # サイバーパンクテーマに切替え
theme gruvbox      # グルーブボックステーマに切替え
theme plain        # プレーンな PS1 に切替え (LLM への貼り付け時など)
```

## テーマの追加

`conf.d/theme/` にカラーパレットファイルを置くだけで `theme` コマンドが自動認識する。

```zsh
# conf.d/theme/mytheme.zsh
local -r C_DARK=...
local -r C_WHITE=...
# ... (cyberpunk.zsh を参考に)
```

## Nix 適用

```zsh
darwin-rebuild switch --flake .
```
