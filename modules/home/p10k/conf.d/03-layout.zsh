# ============================================================
# 基本設定
# ============================================================
typeset -g POWERLEVEL9K_MODE=nerdfont-v3
# アイコンパディング: none=なし / moderate=少し余白
typeset -g POWERLEVEL9K_ICON_PADDING=none
# アイコン位置: 空=左は前/右は後 / true=両方前 / false=両方後
typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=

# ============================================================
# 余白設定 (Whitespace)
# ============================================================
# グローバル余白（左プロンプト）
typeset -g POWERLEVEL9K_LEFT_LEFT_WHITESPACE=' '
typeset -g POWERLEVEL9K_LEFT_RIGHT_WHITESPACE=' '
# グローバル余白（右プロンプト）
typeset -g POWERLEVEL9K_RIGHT_LEFT_WHITESPACE=' '
typeset -g POWERLEVEL9K_RIGHT_RIGHT_WHITESPACE=' '

# セグメント内部の余白
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_{LEFT,RIGHT}_WHITESPACE=' '
typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_WHITESPACE=' '
typeset -g POWERLEVEL9K_PYENV_{LEFT,RIGHT}_WHITESPACE=' '
typeset -g POWERLEVEL9K_ANACONDA_{LEFT,RIGHT}_WHITESPACE=' '
typeset -g POWERLEVEL9K_NODENV_{LEFT,RIGHT}_WHITESPACE=' '
typeset -g POWERLEVEL9K_NVM_{LEFT,RIGHT}_WHITESPACE=' '
typeset -g POWERLEVEL9K_GOENV_{LEFT,RIGHT}_WHITESPACE=' '
typeset -g POWERLEVEL9K_RBENV_{LEFT,RIGHT}_WHITESPACE=' '
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_{LEFT,RIGHT}_WHITESPACE=' '
typeset -g POWERLEVEL9K_TIME_{LEFT,RIGHT}_WHITESPACE=' '

# ============================================================
# プロンプトレイアウト
# ============================================================
# 各プロンプトの前に空行を追加
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# 左プロンプトの行接続記号
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
# 右プロンプトの行接続記号
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=

# 左右プロンプト間の埋め文字 (' ', '·', '─')
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_BACKGROUND=
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_GAP_BACKGROUND=
if [[ $POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR != ' ' ]]; then
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=$C_NEUTRAL_700
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL='%{%}'
  typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'
fi

# ============================================================
# セグメント区切り記号
# ============================================================
# 同色セグメント間の区切り (シャープ)
typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''
# 異色セグメント間の区切り (シャープ)
typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''

# プロンプト端の記号 (シャープ + 端は丸み)
typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
