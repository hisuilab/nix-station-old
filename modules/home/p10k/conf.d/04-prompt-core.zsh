# ============================================================
# os_icon: OS アイコン
# ============================================================
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=$C_DARK

# ============================================================
# prompt_char: プロンプト記号
# ============================================================
typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
# 成功時: シアングリーン
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$C_SUCCESS
# 失敗時: エラーカラー
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$C_ERROR
# 各モードの記号
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

# ============================================================
# dir: カレントディレクトリ
# ============================================================
typeset -g POWERLEVEL9K_DIR_BACKGROUND=$C_INDIGO
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$C_WHITE
# フォルダアイコン (デフォルト + 右にスペース)
typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER} '
# 長いパスを短縮 (一意になる最短プレフィックスに)
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
# 短縮部分の色
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=189
# アンカー(短縮しない)部分の色
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

# アンカーファイル (これらを含むディレクトリは短縮しない)
local anchor_files=(
  .bzr
  .citc
  .git
  .hg
  .node-version
  .python-version
  .go-version
  .ruby-version
  .lua-version
  .java-version
  .perl-version
  .php-version
  .tool-versions
  .shorten_folder_marker
  .svn
  .terraform
  CVS
  Cargo.toml
  composer.json
  go.mod
  package.json
  stack.yaml
)
typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
# ハイパーリンク有効化 (クリックでファイルマネージャを開く)
typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
# 書き込み不可/存在しないディレクトリの表示
typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

# ============================================================
# status: 終了コード
# ============================================================
typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true

# 成功時
typeset -g POWERLEVEL9K_STATUS_OK=true
typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=$C_SUCCESS

# パイプの一部が失敗 (全体は成功) 例: 1|0
typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_BACKGROUND=$C_SUCCESS_ALT

# エラー時
typeset -g POWERLEVEL9K_STATUS_ERROR=true
typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=$C_ERROR

# シグナルで終了時
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_BACKGROUND=$C_ERROR

# パイプの一部が失敗 (全体も失敗) 例: 1|0
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_BACKGROUND=$C_ERROR
