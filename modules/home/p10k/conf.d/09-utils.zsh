# ============================================================
# theme: プロンプトテーマ切替えコマンド
# ============================================================
# 使い方:
#   theme         → トグル (p10k ↔ plain)
#   theme p10k    → p10k を有効化
#   theme plain   → シンプル PS1 に切替え (LLM 共有時など)

function theme() {
  local p10k_active=$(( ${precmd_functions[(I)_p9k_precmd]} > 0 ))

  case ${1:-} in
    p10k)
      if (( p10k_active )); then
        print -P '%F{10}already using p10k%f'
        return
      fi
      p10k reload
      print -P '%F{10}theme: p10k%f'
      ;;
    plain)
      if (( !p10k_active )); then
        print -P '%F{11}already in plain mode%f'
        return
      fi
      precmd_functions=( ${precmd_functions[@]:#_p9k_precmd} )
      PS1='%~'$'\n''%# '
      RPROMPT=''
      print -P '%F{11}theme: plain%f  (run: theme p10k to restore)'
      ;;
    '')
      # 引数なし → トグル
      if (( p10k_active )); then
        theme plain
      else
        theme p10k
      fi
      ;;
    *)
      print -P '%F{1}unknown theme: %f'"$1" >&2
      print 'usage: theme [p10k|plain]' >&2
      return 1
      ;;
  esac
}

# Tab 補完
compdef '_arguments "1:theme:(p10k plain)"' theme
