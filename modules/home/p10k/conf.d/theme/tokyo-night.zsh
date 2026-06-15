# ============================================================
# Tokyo Night Theme Palette
# ============================================================
# https://github.com/folke/tokyonight.nvim

# Base
local -r C_DARK=233      # Background #1a1b26
local -r C_WHITE=146     # Foreground #a9b1d6
local -r C_BLACK=232     # Darker #16161e

# Primary
local -r C_PRIMARY=61     # Dark Blue #3d59a1 (dir)
local -r C_ACCENT=97   # Purple #9d7cd8 (vcs modified)

# Semantic
local -r C_SUCCESS=107   # Green #9ece6a
local -r C_SUCCESS_ALT=65   # deeper green
local -r C_WARNING=179   # Yellow #e0af68
local -r C_ERROR=210     # Red/Pink #f7768e
local -r C_LANG_WARM=215 # orange #ff9e64 (Ruby/Scala/Erlang/Laravel)

# VCS foreground (on top of semantic background colors)
typeset -g C_VCS_CLEAN_FG=232     # dark on green
typeset -g C_VCS_MODIFIED_FG=255  # white on purple
typeset -g C_VCS_UNTRACKED_FG=232  # dark on alt green
typeset -g C_VCS_CONFLICTED_FG=255  # white on pink/red
