# -----------------------------------------------------------------------------
# zsh-z / zoxide — smart directory jump.
# For zsh: prefer agkozak/zsh-z when installed.
# For bash (or when zsh-z is absent): use zoxide (then rupa/z fallback).
# -----------------------------------------------------------------------------
_pb_loaded_zsh_z=0
if [[ -n "${ZSH_VERSION:-}" ]] && [[ -f "${HOME}/.zsh-z/zsh-z.plugin.zsh" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.zsh-z/zsh-z.plugin.zsh"
  _pb_loaded_zsh_z=1
fi

if (( _pb_loaded_zsh_z == 0 )) && command -v zoxide &>/dev/null; then
  if [[ -n "${BASH_VERSION:-}" ]]; then
    eval "$(zoxide init bash)"
  elif [[ -n "${ZSH_VERSION:-}" ]]; then
    eval "$(zoxide init zsh)"
  fi
elif [[ -f ~/.z-plugin/z.sh ]]; then
  # shellcheck source=/dev/null
  source ~/.z-plugin/z.sh
fi
unset _pb_loaded_zsh_z
