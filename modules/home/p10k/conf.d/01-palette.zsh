# ============================================================
# Theme Palette
# ============================================================
# テーマファイルは conf.d/theme/<name>.zsh で管理。
# 新テーマの追加: theme/ にファイルを置くだけでよい。

local theme_file="${p10k_conf_dir}/theme/${P10K_THEME}.zsh"

if [[ ! -f $theme_file ]]; then
  print -P "%F{red}[p10k] Unknown theme: ${P10K_THEME}%f" >&2
  print -P "%F{red}       Available: $(basename -a ${p10k_conf_dir}/theme/*.zsh .zsh | tr '\n' ' ')%f" >&2
  return 1
fi

source "$theme_file"
