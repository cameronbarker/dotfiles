# -----------------------------------------------------------------------------
# Prompt
# -----------------------------------------------------------------------------
export STARSHIP_CONFIG="${HOME}/.config/starship.toml"
if command -v starship &>/dev/null; then
  if [[ -n "${BASH_VERSION:-}" ]]; then
    eval "$(starship init bash)"
  elif [[ -n "${ZSH_VERSION:-}" ]]; then
    eval "$(starship init zsh)"
  fi
fi
