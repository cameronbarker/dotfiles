# -----------------------------------------------------------------------------
# Git
# -----------------------------------------------------------------------------
export GH_TOKEN=REPLACE

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

# pfo/pto operate on the current branch by default (not just main)
alias pfo='git pull origin'
alias pto='git push origin'

# git commit with staged changes
# shellcheck disable=SC2034
PB_DESC_gca="amend the last commit without editing its message"
gca() { git commit --amend --no-edit "$@"; }
