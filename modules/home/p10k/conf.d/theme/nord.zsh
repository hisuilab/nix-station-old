# ============================================================
# 🧊 Nord Theme Palette
# ============================================================
# https://www.nordtheme.com/
# Polar Night / Snow Storm / Frost / Aurora

# Base
local -r C_DARK=238      # Nord1 #3B4252
local -r C_WHITE=153     # Nord9 #81A1C1 (frost blue-white)
local -r C_BLACK=235     # Nord0 #2E3440

# Primary
local -r C_INDIGO=67     # Nord10 #5E81AC (frost dark blue, dir)
local -r C_NEON_PURPLE=110  # Nord8 #88C0D0 (frost cyan, vcs modified)

# Semantic
local -r C_SUCCESS=108   # Nord14 #A3BE8C (aurora green)
local -r C_SUCCESS_ALT=72   # slightly deeper green
local -r C_WARNING=222   # Nord13 #EBCB8B (aurora yellow)
local -r C_ERROR=131     # Nord11 #BF616A (aurora red)

# VCS foreground (on top of semantic background colors)
typeset -g C_VCS_CLEAN_FG=235      # dark on green
typeset -g C_VCS_MODIFIED_FG=235   # dark on cyan
typeset -g C_VCS_UNTRACKED_FG=222  # yellow on deeper green
typeset -g C_VCS_CONFLICTED_FG=253  # light on red
