# ============================================================
# Dracula Theme Palette
# ============================================================
# https://draculatheme.com/

# Base
local -r C_DARK=235      # Background #282A36
local -r C_WHITE=255     # Foreground #F8F8F2
local -r C_BLACK=234     # Darker background

# Primary
local -r C_PRIMARY=61     # Comment #6272A4 (muted purple, dir)
local -r C_ACCENT=141  # Purple #BD93F9 (vcs modified)

# Semantic
local -r C_SUCCESS=84    # Green #50FA7B
local -r C_SUCCESS_ALT=78   # slightly deeper green
local -r C_WARNING=215   # Orange #FFB86C
local -r C_ERROR=203     # Red #FF5555

# VCS foreground (on top of semantic background colors)
typeset -g C_VCS_CLEAN_FG=234     # dark on bright green
typeset -g C_VCS_MODIFIED_FG=255  # white on purple
typeset -g C_VCS_UNTRACKED_FG=215  # orange on deeper green
typeset -g C_VCS_CONFLICTED_FG=255  # white on red
