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
# 失敗時: ホットピンク
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
# vcs: Git ステータス
# ============================================================
# GitHub ロゴアイコン
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=$' '

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
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
# 未追跡ファイルアイコン
typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

# Git ステータスのフォーマッタ
# 出力例: master wip ⇣42⇡42 *42 merge ~42 +42 !42 ?42
function my_git_formatter() {
  emulate -L zsh

  # 色設定 - 状態に応じて色を決定（一元管理）
  # グローバル変数C_VCS_*_FGを参照
  local text_color

  # 変更がある場合は白、クリーンな場合は黒
  # 算術評価で確実にチェック
  if (( ${VCS_STATUS_NUM_STAGED:-0} > 0 )) || \
     (( ${VCS_STATUS_NUM_UNSTAGED:-0} > 0 )) || \
     (( ${VCS_STATUS_NUM_UNTRACKED:-0} > 0 )) || \
     (( ${VCS_STATUS_NUM_CONFLICTED:-0} > 0 )); then
    # 変更あり → カラーパレットから取得
    text_color="%${C_VCS_MODIFIED_FG}F"
  else
    # クリーン → カラーパレットから取得
    text_color="%${C_VCS_CLEAN_FG}F"
  fi

  # 全ての要素に同じ色を適用（アイコンとテキストを統一）
  local       meta="$text_color"   # メタ情報
  local      clean="$text_color"   # クリーン状態
  local   modified="$text_color"   # 変更あり
  local  untracked="$text_color"   # 未追跡
  local conflicted="$text_color"   # コンフリクト

  local res

  # ブランチ名 (32文字超は省略)
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
    (( $#branch > 32 )) && branch[13,-13]="…"
    res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
  fi

  # タグ名 (ブランチがない場合のみ表示)
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

  # WIP 表示 (コミットメッセージに wip/WIP を含む場合)
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
  # スタッシュ数
  (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
  # マージ/リベース中などの特殊状態
  [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
  # コンフリクト数
  (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
  # ステージ済み変更数
  (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
  # 未ステージ変更数
  (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
  # 未追跡ファイル数
  (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
  # 不明 (インデックスが大きすぎる場合)
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

# ============================================================
# status: 終了コード
# ============================================================
typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true

# 成功時 - シアングリーン
typeset -g POWERLEVEL9K_STATUS_OK=true
typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=$C_SUCCESS

# パイプの一部が失敗 (全体は成功) 例: 1|0
typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_BACKGROUND=$C_SUCCESS_ALT

# エラー時 - ホットピンク
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
