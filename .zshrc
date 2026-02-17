# Basic aliases
alias ..='cd ../'
alias src='source ~/.zshrc'
alias c='clear'
alias help='alias | grep '
alias cwd='echo -n $PWD|pbcopy|echo "Copied current path to clipboard"'

# Git aliases
alias gb='git add --all'
alias gb='git branch'
alias gs='git status'
alias gr='git remote -v'
alias gf='git pull'
alias gt='git push'
# alias pfo='git pull origin main'
# alias pto='git push origin main'

# Enhanced zsh-specific aliases
alias ll='ls -la --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Rails specific
alias kill_rails='rm -rf tmp/pids/server.pid & lsof -ti:3000 | xargs kill -9'
alias rlint='bundle exec standardrb'
alias rails_secrets='EDITOR=vim rails credentials:edit'
alias bi='bundle install'
alias rc='rails console'
