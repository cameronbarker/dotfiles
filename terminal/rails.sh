# -----------------------------------------------------------------------------
# Rails
# -----------------------------------------------------------------------------
alias bi='bundle install'
alias rc='rails console'
alias rs='rails server'
alias rdb='rails db:migrate'
alias rdbs='rails db:migrate:status'
alias rlint='bundle exec standardrb'
alias rails_secrets='EDITOR=vim rails credentials:edit'
alias kill_rails='rm -rf tmp/pids/server.pid && lsof -ti:3000 | xargs kill -9'
