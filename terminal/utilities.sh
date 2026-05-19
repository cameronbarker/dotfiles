# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

export AI_CLI="${AI_CLI:-codex}"
ai() { command "${AI_CLI}" "$@"; }

_ai_kit_command() {
  local cmd repo_root repo_cmd
  cmd="$1"

  if repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    repo_cmd="${repo_root}/ai-kit/bin/${cmd}"
    if [ -x "${repo_cmd}" ]; then
      command "${repo_cmd}" "${@:2}"
      return
    fi
  fi

  if command -v "${cmd}" >/dev/null 2>&1; then
    command "${cmd}" "${@:2}"
    return
  fi

  echo "AI kit command not found: ${cmd}" >&2
  echo "Hint: expected repo-local command at ai-kit/bin/${cmd} or install ${cmd} on PATH." >&2
  return 1
}

aictx() { _ai_kit_command "ai-context" "$@"; }
airisk() { _ai_kit_command "ai-risk" "$@"; }
aifail() { _ai_kit_command "ai-failure" "$@"; }
aiprompt() { _ai_kit_command "ai-codex-prompt" "$@"; }

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
