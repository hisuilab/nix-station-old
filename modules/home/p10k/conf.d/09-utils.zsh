# ============================================================
# theme: プロンプトテーマ切替えコマンド
# ============================================================
# 使い方:
#   theme              → トグル (p10k ↔ plain)
#   theme list         → 利用可能なテーマを表示
#   theme plain        → シンプル PS1 に切替え (LLM 共有時など)
#   theme cyberpunk    → p10k サイバーパンクテーマに切替え
#   theme gruvbox      → p10k グルーブボックステーマに切替え
#
# 新テーマの追加: conf.d/theme/<name>.zsh を置くだけでよい

function theme() {
  local p10k_active=$(( ${precmd_functions[(I)_p9k_precmd]} > 0 ))
  local p10k_conf_dir="${HOME}/.p10k.d"

  case ${1:-} in
    list)
      local -a p10k_themes=( ${p10k_conf_dir}/theme/*.zsh(N:t:r) )
      print -P '%B available themes:%b'
      if (( !p10k_active )); then
        print -P "  %F{10}plain%f %F{8}← current%f"
      else
        print -P "  %F{7}plain%f"
      fi
      for t in $p10k_themes; do
        if (( p10k_active )) && [[ $t == $P10K_THEME ]]; then
          print -P "  %F{10}${t}%f %F{8}← current%f"
        else
          print -P "  %F{7}${t}%f"
        fi
      done
      ;;
    plain)
      if (( !p10k_active )); then
        print -P '%F{11}already in plain mode%f'
        return
      fi
      precmd_functions=( ${precmd_functions[@]:#_p9k_precmd} )
      PS1='%~'$'\n''%# '
      RPROMPT=''
      print -P '%F{11}theme: plain%f  (run: theme to restore)'
      ;;
    '')
      # 引数なし → トグル
      if (( p10k_active )); then
        theme plain
      else
        # _p9k_precmd を precmd_functions へ戻してから reload する。
        # reload は _p9k__force_must_init=1 を立てるだけで、
        # 実際の再初期化は次回の _p9k_precmd 実行時に行われるため。
        add-zsh-hook precmd _p9k_precmd
        p10k reload
        print -P "%F{10}theme: ${P10K_THEME}%f"
      fi
      ;;
    *)
      # p10k サブテーマ (cyberpunk / gruvbox / …)
      if [[ ! -f "${p10k_conf_dir}/theme/${1}.zsh" ]]; then
        print -P "%F{1}unknown theme: %f$1" >&2
        local -a available=( ${p10k_conf_dir}/theme/*.zsh(N:t:r) )
        print "available: plain ${available[*]}" >&2
        return 1
      fi
      typeset -g P10K_THEME=$1
      # plain mode 中でも呼ばれる可能性があるため、未登録なら追加
      (( ${precmd_functions[(I)_p9k_precmd]} )) || add-zsh-hook precmd _p9k_precmd
      p10k reload
      print -P "%F{10}theme: $1%f"
      ;;
  esac
}

# Tab 補完: conf.d/theme/ のファイルを動的に列挙 + plain を追加
function _theme_complete() {
  local p10k_conf_dir="${HOME}/.p10k.d"
  local -a themes=( list plain ${p10k_conf_dir}/theme/*.zsh(N:t:r) )
  _arguments "1:theme:(${themes[*]})"
}
compdef _theme_complete theme
