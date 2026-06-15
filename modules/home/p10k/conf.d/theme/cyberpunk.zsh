# ============================================================
# Cyberpunk Theme Palette
# ============================================================

# Base
local -r C_DARK=236      # #303030 dark gray
local -r C_WHITE=255     # #EEEEEE near white
local -r C_BLACK=0       # #000000 black

# Primary
local -r C_PRIMARY=57    # #5F00FF deep purple (dir)
local -r C_ACCENT=93     # #8700FF neon violet (vcs modified)

# Semantic
local -r C_SUCCESS=48    # #00FF87 neon green
local -r C_SUCCESS_ALT=37  # #00AFAF cyan
local -r C_WARNING=220   # #FFD700 neon yellow
local -r C_ERROR=198     # #FF0087 hot pink
local -r C_LANG_WARM=198 # #FF0087 hot pink (Ruby/Scala/Erlang/Laravel)

# VCS
typeset -g C_VCS_CLEAN_FG=0
typeset -g C_VCS_MODIFIED_FG=255
typeset -g C_VCS_UNTRACKED_FG=255
typeset -g C_VCS_CONFLICTED_FG=255
