# ============================================================
# Powerlevel10k 設定エントリーポイント
# ============================================================
# フォント: MesloLGS NF (Nerd Font v3)
#
# 設定ファイル構成: conf.d/ を参照
# テーマ切替: theme コマンド (10-utils.zsh で定義)
# カラーマップ確認:
#   for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done

# ============================================================
# テーマ選択
# ============================================================
# 利用可能: cyberpunk / dracula / gruvbox / nord / tokyo-night
# ステートファイル ($XDG_DATA_HOME/p10k/theme) があればそれを使用、なければ tokyo-night。
typeset -g P10K_CONF_DIR="${HOME}/.p10k.d"
local _p10k_state="${XDG_DATA_HOME:-${HOME}/.local/share}/p10k/theme"
# state ファイルがあれば最優先。なければ環境変数、それもなければデフォルト。
if [[ -f "$_p10k_state" ]]; then
  typeset -g P10K_THEME="$(<"$_p10k_state")"
else
  typeset -g P10K_THEME="${P10K_THEME:-tokyo-night}"
fi

# オプションの一時変更
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # 設定リセット
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh 5.1以上が必要
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  local p10k_conf_dir="${P10K_CONF_DIR}"

  source "${p10k_conf_dir}/01-palette.zsh"    || return
  source "${p10k_conf_dir}/02-elements.zsh"
  source "${p10k_conf_dir}/03-layout.zsh"
  source "${p10k_conf_dir}/04-prompt-core.zsh"
  source "${p10k_conf_dir}/05-vcs.zsh"
  source "${p10k_conf_dir}/06-segments.zsh"
  source "${p10k_conf_dir}/07-devtools.zsh"
  source "${p10k_conf_dir}/08-cloud.zsh"
  source "${p10k_conf_dir}/09-behavior.zsh"
  source "${p10k_conf_dir}/10-utils.zsh"

  # 設定再読込
  (( ! $+functions[p10k] )) || p10k reload
}

# p10k configure が上書きするファイル
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
