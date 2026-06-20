# ============================================================
# Nord Theme Palette
# ============================================================

# Base
local -r C_DARK=236
local -r C_WHITE=254
local -r C_BLACK=0

# Primary
local -r C_PRIMARY=67
local -r C_ACCENT=110

# Semantic
local -r C_SUCCESS=151
local -r C_SUCCESS_ALT=110
local -r C_WARNING=180
local -r C_ERROR=174
local -r C_LANG_WARM=173

# VCS foreground (on top of semantic background colors)
typeset -g C_VCS_CLEAN_FG=0
typeset -g C_VCS_MODIFIED_FG=255
typeset -g C_VCS_UNTRACKED_FG=255
typeset -g C_VCS_CONFLICTED_FG=255
