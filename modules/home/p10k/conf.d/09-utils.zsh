# ============================================================
# plain-mode: p10k を一時的に無効化するトグル関数
# ============================================================
# 用途: ターミナル出力を LLM に貼り付ける際などに
#       描画文字・カラーコードを排除したいとき
#
# 使い方:
#   plain-mode   → シンプルな PS1 に切替え (p10k の precmd を除去)
#   plain-mode   → もう一度呼ぶと p10k を復帰 (p10k reload)

function plain-mode() {
  if (( ${precmd_functions[(I)_p9k_precmd]} )); then
    # p10k が有効 → 無効化
    precmd_functions=( ${precmd_functions[@]:#_p9k_precmd} )
    PS1='%~'$'\n''%# '
    RPROMPT=''
    print -P '%F{11}plain mode%f  (run plain-mode again to restore p10k)'
  else
    # p10k が無効 → 復帰
    p10k reload
    print -P '%F{10}p10k restored%f'
  fi
}
