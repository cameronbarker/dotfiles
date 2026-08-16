# -----------------------------------------------------------------------------
# Navigation
# -----------------------------------------------------------------------------
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias ~='cd ~'
alias -- -='cd -'

if command -v pbcopy &>/dev/null; then
  :
elif command -v xclip &>/dev/null; then
  pbcopy() { xclip -selection clipboard; }
elif command -v wl-copy &>/dev/null; then
  pbcopy() { wl-copy; }
fi

if ! command -v copy &>/dev/null; then
  copy() {
    if ! command -v pbcopy &>/dev/null; then
      echo "copy: no clipboard command found (pbcopy, xclip, or wl-copy)" >&2
      return 1
    fi

    if [[ $# -gt 0 ]]; then
      printf "%s" "$*" | pbcopy
    elif [[ -t 0 ]]; then
      echo "Usage: command | copy" >&2
      echo "   or: copy text to copy" >&2
      return 1
    else
      pbcopy
    fi
  }
fi

alias cwd='echo -n $PWD | pbcopy && echo "Copied current path to clipboard"'

if [[ -n "${BASH_VERSION:-}" ]]; then
  alias src='source ~/.bashrc'
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  alias src='source ~/.zshrc'
fi
