export ZSH=/Users/cameronbarker/.oh-my-zsh

ZSH_THEME="cameronbarker"

plugins=(git bundler brew gem heroku)


export PATH="/usr/local/bin:/Users/cameronbarker/.bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export GOPATH=$HOME/Dropbox/Development/Go
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH
source $ZSH/oh-my-zsh.sh
export PATH="$HOME/.bin:$PATH"
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.4/bin
export PATH="/usr/local/bin:$PATH"
eval "$(rbenv init - --no-rehash zsh)"


alias git=hub
alias ls='ls -aFhlG'
alias ll='ls -l'
alias ..='cd ..'
alias ...='cd ../..'
alias rpp='cd /Users/cameronbarker/Dropbox/Development/ruby/Production'
alias hpp='cd /Users/cameronbarker/Dropbox/Development/html/production'
alias ipp='cd /Users/cameronbarker/Dropbox/Development/ios/prodution'
alias cwd='echo -n $PWD|pbcopy|echo "current path copied to clipboard"'
alias ga='git add --all'
alias gb='git branch'
alias gs='git status'
alias src='source ~/.zshrc'
alias apple_desktop_images='cd /Library/Desktop\ Pictures'
alias pth='git push heroku master'
alias pto='git push origin master'
alias pts='rspec && pto && pth'
alias pfo='git pull origin master'
alias ppd='parse deploy'
alias hrc='heroku run --size=standard-2x rails c -r heroku'
alias hrcl='heroku run --size=performance-l rails c -r heroku'
alias hlog='heroku logs --ps web -t'
alias appname="heroku info -r heroku | head -1 | tr -d '=' | tr -d ' '"
alias gi='git browse -- issues'
alias rc='rails console'

des() { ~/Desktop ; }
dess() { git pull origin master ;
         git remote -v ; }
gta () {
  foo=$(heroku info -r heroku | head -1 | tr -d "=" | tr -d " ")
  open $(printf "https://dashboard.heroku.com/apps/%s" "$foo")
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
