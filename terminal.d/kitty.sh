# ----------------------------------------------------------------------------
# Kitty window controls (remote control over local Unix socket)
# ----------------------------------------------------------------------------
# Kitty "windows" are pane-like splits. These helpers control local Kitty UI
# only and are not a tmux/session persistence replacement.

krc() {
  local _kitty_to="${KITTY_LISTEN_ON:-unix:/tmp/kitty}"
  kitty @ --to "${_kitty_to}" "$@"
}

kls() { krc ls; }
kvsplit() { krc launch --location=vsplit "$@"; }
khsplit() { krc launch --location=hsplit "$@"; }
ktab() { krc new-tab "$@"; }
kfocus_left() { krc focus-window --match neighbor:left; }
kfocus_right() { krc focus-window --match neighbor:right; }
kfocus_up() { krc focus-window --match neighbor:top; }
kfocus_down() { krc focus-window --match neighbor:bottom; }
kclose() { krc close-window; }

# zsh supports slash-prefixed aliases; bash does not.
if [[ -n "${ZSH_VERSION:-}" ]]; then
  alias /v='kvsplit'
  alias /h='khsplit'
  alias /t='ktab'
  alias /ls='kls'
  alias /left='kfocus_left'
  alias /right='kfocus_right'
  alias /up='kfocus_up'
  alias /down='kfocus_down'
  alias /close='kclose'
fi
