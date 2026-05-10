# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

export AI_CLI="${AI_CLI:-codex}"
ai() { command "${AI_CLI}" "$@"; }

# make a directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# extract common archive formats
extract() {
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.rar)     unrar x "$1" ;;
    *)         echo "Unknown format: $1" ;;
  esac
}

# quick HTTP server in current dir
serve() { python3 -m http.server "${1:-8000}"; }

# find file by name
ff() { find . -name "*$1*" 2>/dev/null; }
