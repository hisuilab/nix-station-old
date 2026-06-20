# Starship theme switching
# State : ~/.local/share/starship/theme  (local only, not in repo)
# Config: ~/.config/starship/current.toml (generated on apply)
# Themes: $STARSHIP_THEME_DIR/*.toml     (set by default.nix via Nix store)

function _starship_theme_apply() {
  local _state="${XDG_DATA_HOME:-${HOME}/.local/share}/starship/theme"
  local _src="${XDG_CONFIG_HOME:-${HOME}/.config}/starship.toml"
  local _out="${XDG_CONFIG_HOME:-${HOME}/.config}/starship/current.toml"
  local _theme
  _theme="$(cat "${_state}" 2>/dev/null)" || _theme="gruvbox_dark"

  mkdir -p "${_out:h}"
  sed "s|^palette = '.*'|palette = '${_theme}'|" "${_src}" > "${_out}"
  [[ -f "${STARSHIP_THEME_DIR}/${_theme}.toml" ]] && \
    cat "${STARSHIP_THEME_DIR}/${_theme}.toml" >> "${_out}"
  export STARSHIP_CONFIG="${_out}"
}

function theme() {
  local _state="${XDG_DATA_HOME:-${HOME}/.local/share}/starship/theme"
  local _current
  _current="$(cat "${_state}" 2>/dev/null)" || _current="gruvbox_dark"
  local _active=$(( ${precmd_functions[(I)prompt_starship_precmd]} > 0 ))

  case ${1:-} in
    list)
      print -P '%B available themes:%b'
      local -a _themes=( ${STARSHIP_THEME_DIR}/*.toml(N:t:r) )
      for _t in "${_themes[@]}"; do
        if (( _active )) && [[ $_t == $_current ]]; then
          print -P "  %F{10}${_t}%f %F{8}← current%f"
        else
          print -P "  %F{7}${_t}%f"
        fi
      done
      if (( !_active )); then
        print -P "  %F{10}plain%f %F{8}← current%f"
      else
        print -P "  %F{7}plain%f"
      fi
      ;;

    plain)
      if (( !_active )); then
        print -P '%F{11}already in plain mode%f'
        return
      fi
      precmd_functions=( ${precmd_functions[@]:#prompt_starship_precmd} )
      PS1='%~'$'\n''%# '
      RPROMPT=''
      print -P '%F{11}theme: plain%f  (run: theme to restore)'
      ;;

    '')
      if (( _active )); then
        theme plain
      else
        add-zsh-hook precmd prompt_starship_precmd
        _starship_theme_apply
        print -P "%F{10}theme: ${_current}%f"
      fi
      ;;

    *)
      if [[ ! -f "${STARSHIP_THEME_DIR}/${1}.toml" ]]; then
        print -P "%F{1}unknown theme: %f${1}" >&2
        print -P "%F{8}run: theme list%f" >&2
        return 1
      fi
      mkdir -p "${_state:h}"
      print -n "${1}" > "${_state}"
      _starship_theme_apply
      (( _active )) || add-zsh-hook precmd prompt_starship_precmd
      print -P "%F{10}theme: ${1}%f"
      ;;
  esac
}

function _theme_complete() {
  local -a _themes
  _themes=( list plain ${STARSHIP_THEME_DIR}/*.toml(N:t:r) )
  _arguments "1:theme:(${_themes[*]})"
}
compdef _theme_complete theme

_starship_theme_apply
