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
alias cwd='echo -n $PWD | pbcopy && echo "Copied current path to clipboard"'

if [[ -n "${BASH_VERSION:-}" ]]; then
  alias src='source ~/.bashrc'
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  alias src='source ~/.zshrc'
fi
