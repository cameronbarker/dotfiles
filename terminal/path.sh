# -----------------------------------------------------------------------------
# PATH additions (add project-specific paths here)
# -----------------------------------------------------------------------------
if [[ -d "${HOME}/.local/bin" ]] && [[ ":${PATH}:" != *":${HOME}/.local/bin:"* ]]; then
  export PATH="${HOME}/.local/bin:${PATH}"
fi
