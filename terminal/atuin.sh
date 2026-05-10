# -----------------------------------------------------------------------------
# Atuin — shell history (Ctrl-R); load after fzf so Atuin wins over fzf’s Ctrl-R.
# Ctrl-T remains fzf file search. Binary: ~/.atuin/bin (see ./install.sh).
# -----------------------------------------------------------------------------
if [[ -d "${HOME}/.atuin/bin" ]] && [[ ":${PATH}:" != *":${HOME}/.atuin/bin:"* ]]; then
  export PATH="${HOME}/.atuin/bin:${PATH}"
fi
if command -v atuin &>/dev/null; then
  if [[ -n "${BASH_VERSION:-}" ]]; then
    if [[ ! -f "${HOME}/.bash-preexec.sh" ]] && command -v curl &>/dev/null; then
      curl -fsSL -o "${HOME}/.bash-preexec.sh" \
        https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh 2>/dev/null || true
    fi
    if [[ -f "${HOME}/.bash-preexec.sh" ]]; then
      # shellcheck source=/dev/null
      source "${HOME}/.bash-preexec.sh"
    fi
    eval "$(atuin init bash)"
  elif [[ -n "${ZSH_VERSION:-}" ]]; then
    eval "$(atuin init zsh)"
  fi
fi
