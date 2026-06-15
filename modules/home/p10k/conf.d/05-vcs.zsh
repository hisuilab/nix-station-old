# ============================================================
# vcs: Git ステータス
# ============================================================
# GitHub ロゴアイコン
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=$' '

# 前景色 (アイコン・テキスト) - 一元管理された色定義を参照
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$C_VCS_CLEAN_FG
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$C_VCS_MODIFIED_FG
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$C_VCS_UNTRACKED_FG
typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=$C_VCS_CONFLICTED_FG
typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=$C_VCS_CLEAN_FG

# 背景色 (状態別)
typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$C_SUCCESS
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$C_NEON_PURPLE
typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$C_SUCCESS_ALT
typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=$C_ERROR
typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=$C_DARK

# ブランチアイコン
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
# 未追跡ファイルアイコン
typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

# ============================================================
# Git ステータスフォーマッタ
# ============================================================
# 出力例: master wip ⇣42⇡42 *42 merge ~42 +42 !42 ?42
function my_git_formatter() {
  emulate -L zsh

  local text_color
  if (( ${VCS_STATUS_NUM_STAGED:-0} > 0 )) || \
     (( ${VCS_STATUS_NUM_UNSTAGED:-0} > 0 )) || \
     (( ${VCS_STATUS_NUM_UNTRACKED:-0} > 0 )) || \
     (( ${VCS_STATUS_NUM_CONFLICTED:-0} > 0 )); then
    text_color="%${C_VCS_MODIFIED_FG}F"
  else
    text_color="%${C_VCS_CLEAN_FG}F"
  fi

  local       meta="$text_color"
  local      clean="$text_color"
  local   modified="$text_color"
  local  untracked="$text_color"
  local conflicted="$text_color"

  local res

  # ブランチ名 (32文字超は省略)
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
    (( $#branch > 32 )) && branch[13,-13]="…"
    res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
  fi

  # タグ名 (ブランチがない場合のみ)
  if [[ -n $VCS_STATUS_TAG && -z $VCS_STATUS_LOCAL_BRANCH ]]; then
    local tag=${(V)VCS_STATUS_TAG}
    (( $#tag > 32 )) && tag[13,-13]="…"
    res+="${meta}#${clean}${tag//\%/%%}"
  fi

  # コミットハッシュ (ブランチもタグもない場合)
  [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
    res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

  # リモートブランチ名 (ローカルと異なる場合)
  if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
    res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
  fi

  # WIP
  if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
    res+=" ${modified}wip"
  fi

  # リモートとの差分
  if (( VCS_STATUS_COMMITS_AHEAD || VCS_STATUS_COMMITS_BEHIND )); then
    (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
    (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
    (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
  fi

  # プッシュリモートとの差分
  (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
  (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
  (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"

  (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
  [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
  (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
  (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
  (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
  (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
  (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"

  typeset -g my_git_format=$res
}
functions -M my_git_formatter 2>/dev/null

# 大規模リポジトリでのダーティチェック上限 (負数=無制限)
typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
# Git ステータスを無効化するディレクトリパターン
typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
# カスタムフォーマッタを使用
typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter()))+${my_git_format}}'
typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
# 対応 VCS (git のみ推奨 / svn, hg は遅くなる)
typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
