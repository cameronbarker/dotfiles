# -----------------------------------------------------------------------------
# Terminal
# -----------------------------------------------------------------------------
alias c='clear'

# -----------------------------------------------------------------------------
# Editor
# -----------------------------------------------------------------------------
alias vim='nvim'
export EDITOR="vim"
alias edit="${EDITOR:-vim}"
export IDE="${IDE:-cursor}"
alias ide="${IDE}"

# -----------------------------------------------------------------------------
# Pager
# -----------------------------------------------------------------------------
if command -v moor &>/dev/null; then
  export PAGER="moor"
elif command -v moar &>/dev/null; then
  export PAGER="moar"
elif command -v less &>/dev/null; then
  export PAGER="less"
fi
export MANPAGER="${PAGER:-less}"
export BAT_PAGER="${PAGER:-less}"
