# ============================================================
# Theme Palette
# ============================================================

case "$P10K_THEME" in
  cyberpunk)
    # ========================================================
    # 🌃 Cyberpunk Theme
    # ========================================================

    # Base
    local -r C_DARK=236
    local -r C_WHITE=255
    local -r C_BLACK=0

    # Primary
    local -r C_INDIGO=57
    local -r C_NEON_PURPLE=93

    # Semantic
    local -r C_SUCCESS=48
    local -r C_SUCCESS_ALT=37
    local -r C_WARNING=93
    local -r C_ERROR=198

    # VCS
    typeset -g C_VCS_CLEAN_FG=0
    typeset -g C_VCS_MODIFIED_FG=255
    typeset -g C_VCS_UNTRACKED_FG=255
    typeset -g C_VCS_CONFLICTED_FG=255
    ;;

  gruvbox)
    # ========================================================
    # 🌿 Gruvbox Theme
    # ========================================================

    # Base
    local -r C_DARK=235
    local -r C_WHITE=223
    local -r C_BLACK=234

    # Primary
    local -r C_INDIGO=66
    local -r C_NEON_PURPLE=95

    # Semantic
    local -r C_SUCCESS=108
    local -r C_SUCCESS_ALT=142
    local -r C_WARNING=136
    local -r C_ERROR=167

    # VCS
    typeset -g C_VCS_CLEAN_FG=234
    typeset -g C_VCS_MODIFIED_FG=223
    typeset -g C_VCS_UNTRACKED_FG=136
    typeset -g C_VCS_CONFLICTED_FG=167
    ;;

  *)
    print -P "%F{red}[p10k] Unknown theme: $P10K_THEME%f"
    return 1
    ;;
esac
