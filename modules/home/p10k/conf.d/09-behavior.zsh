# ============================================================
# カスタムセグメント例
# ============================================================
function prompt_example() {
  p10k segment -b $C_ERROR -f $C_WHITE -i '⭐' -t 'hello, %n'
}

# instant prompt 用
function instant_prompt_example() {
  prompt_example
}

typeset -g POWERLEVEL9K_EXAMPLE_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_EXAMPLE_BACKGROUND=$C_ERROR

# ============================================================
# Transient Prompt
# ============================================================
# off: 無効 / always: 常に / same-dir: ディレクトリ変更時以外
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

# ============================================================
# Instant Prompt
# ============================================================
# off: 無効 / quiet: 警告なし / verbose: 警告あり
typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

# ============================================================
# Hot Reload
# ============================================================
# true: 無効 (1-2ms 高速化)
typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
