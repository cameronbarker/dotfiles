# -----------------------------------------------------------------------------
# fzf — fuzzy finder (Ctrl-T file search; Ctrl-R stays fzf if Atuin is not installed)
# -----------------------------------------------------------------------------
# Debian/apt fzf is often too old for `fzf --bash` / `fzf --zsh` (prints "unknown option").
# Prefer ~/.fzf.bash from the git installer; otherwise use --bash/--zsh only if they work.
if command -v fzf &>/dev/null; then
  if [[ -n "${BASH_VERSION:-}" ]]; then
    if [[ -f "${HOME}/.fzf.bash" ]]; then
      # shellcheck source=/dev/null
      source "${HOME}/.fzf.bash"
    else
      _fzf_shell_init="$(fzf --bash 2>/dev/null)" || true
      [[ -n "${_fzf_shell_init}" ]] && eval "${_fzf_shell_init}"
      unset _fzf_shell_init
    fi
  elif [[ -n "${ZSH_VERSION:-}" ]]; then
    if [[ -f "${HOME}/.fzf.zsh" ]]; then
      # shellcheck source=/dev/null
      source "${HOME}/.fzf.zsh"
    else
      _fzf_shell_init="$(fzf --zsh 2>/dev/null)" || true
      [[ -n "${_fzf_shell_init}" ]] && eval "${_fzf_shell_init}"
      unset _fzf_shell_init
    fi
  fi
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
  # Use bat for fzf file previews if available
  if command -v batcat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --line-range :50 {}'"
  elif command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}'"
  fi
fi
