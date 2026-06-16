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
        ├── cyberpunk.zsh
        ├── dracula.zsh
        ├── gruvbox.zsh
        ├── nord.zsh
        └── tokyo-night.zsh
```

## theme コマンド

```zsh
theme              # トグル (p10k ↔ plain)
theme list         # 利用可能なテーマを一覧表示
theme cyberpunk    # cyberpunkテーマに切替え
theme gruvbox      # gruvboxテーマに切替え
theme plain        # プレーンな PS1 に切替え (LLM への貼り付け時など)
```

## テーマの追加

`conf.d/theme/` にカラーパレットファイルを置くだけで `theme` コマンドが自動認識する。

```zsh
# conf.d/theme/mytheme.zsh

# Base
local -r C_DARK=...          # 背景色
local -r C_WHITE=...         # 前景色
local -r C_BLACK=...         # 暗めの背景色

# Primary
local -r C_PRIMARY=...       # ディレクトリ・主要セグメント背景
local -r C_ACCENT=...        # VCS 変更中・アクセントセグメント背景

# Semantic
local -r C_SUCCESS=...       # 成功・正常状態
local -r C_SUCCESS_ALT=...   # 成功の補助色
local -r C_WARNING=...       # 警告状態
local -r C_ERROR=...         # エラー・危険状態
local -r C_LANG_WARM=...     # Ruby/Scala/Erlang/Laravel 系の背景色

# VCS foreground (on top of semantic background colors)
typeset -g C_VCS_CLEAN_FG=...       # クリーン時の文字色
typeset -g C_VCS_MODIFIED_FG=...    # 変更あり時の文字色
typeset -g C_VCS_UNTRACKED_FG=...   # 未追跡ファイルありの文字色
typeset -g C_VCS_CONFLICTED_FG=...  # コンフリクトありの文字色
```

## Nix 適用

```zsh
darwin-rebuild switch --flake .
```
