# ============================================================
# Tokyo Night Theme Palette
# ============================================================
# https://github.com/folke/tokyonight.nvim

# Base
local -r C_DARK=235
local -r C_WHITE=255
local -r C_BLACK=0

# Primary
local -r C_PRIMARY=069
local -r C_ACCENT=099

# Semantic
local -r C_SUCCESS=079
local -r C_SUCCESS_ALT=081
local -r C_WARNING=215
local -r C_ERROR=211
local -r C_LANG_WARM=209

# VCS foreground (on top of semantic background colors)
typeset -g C_VCS_CLEAN_FG=0
typeset -g C_VCS_MODIFIED_FG=255
typeset -g C_VCS_UNTRACKED_FG=255
typeset -g C_VCS_CONFLICTED_FG=255
