# -----------------------------------------------------------------------------
# bat — cat replacement with syntax highlighting
# -----------------------------------------------------------------------------
if command -v batcat &>/dev/null; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
elif command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
fi
