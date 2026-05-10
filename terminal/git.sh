# -----------------------------------------------------------------------------
# Git
# -----------------------------------------------------------------------------
alias ga='git add --all'
alias gb='git branch'
alias gc='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gf='git pull'
alias gl='git log --oneline --graph --decorate'
alias gr='git remote -v'
alias gs='git status'
alias gt='git push'
alias gst='git stash'
alias gstp='git stash pop'

# git commit with staged changes
gca() { git commit --amend --no-edit "$@"; }
