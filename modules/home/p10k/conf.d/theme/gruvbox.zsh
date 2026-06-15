# ============================================================
# Gruvbox Theme Palette
# ============================================================

# Base
local -r C_DARK=235      # #262626 dark bg
local -r C_WHITE=223     # #FFD7AF warm cream fg
local -r C_BLACK=234     # #1C1C1C harder bg

# Primary
local -r C_PRIMARY=66    # #5F8787 muted teal (dir)
local -r C_ACCENT=95     # #875F5F muted mauve (vcs modified)

# Semantic
local -r C_SUCCESS=108   # #87AF87 muted green
local -r C_SUCCESS_ALT=142  # #AFAF5F yellow-green
local -r C_WARNING=136   # #AF8700 amber
local -r C_ERROR=167     # #D75F5F warm red
local -r C_LANG_WARM=167 # #D75F5F warm red (Ruby/Scala/Erlang/Laravel)

# VCS
typeset -g C_VCS_CLEAN_FG=234
typeset -g C_VCS_MODIFIED_FG=223
typeset -g C_VCS_UNTRACKED_FG=136
typeset -g C_VCS_CONFLICTED_FG=167
