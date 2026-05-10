# -----------------------------------------------------------------------------
# tmux slash commands (zsh only)
# -----------------------------------------------------------------------------
_tmux_cmd_available() {
  command -v tmux &>/dev/null
}

_tmux_required() {
  if ! _tmux_cmd_available; then
    echo "tmux not found in PATH." >&2
    return 1
  fi
  if [[ -z "${TMUX:-}" ]]; then
    echo "Not inside a tmux session." >&2
    return 1
  fi
}

_tmux_amount_or_default() {
  local amount="${1:-5}"
  if [[ "${amount}" =~ ^[0-9]+$ ]] && (( amount > 0 )); then
    echo "${amount}"
    return 0
  fi
  echo "Amount must be a positive integer." >&2
  return 1
}

tmux_split_v() { _tmux_required && tmux split-window -h -c '#{pane_current_path}'; }
tmux_split_h() { _tmux_required && tmux split-window -v -c '#{pane_current_path}'; }
tmux_kill_pane() { _tmux_required && tmux kill-pane; }
tmux_zoom_pane() { _tmux_required && tmux resize-pane -Z; }
tmux_new_window() { _tmux_required && tmux new-window -c '#{pane_current_path}'; }

tmux_rename_window() {
  _tmux_required || return 1
  if [[ -z "${1:-}" ]]; then
    echo "Usage: /rn <name>" >&2
    return 1
  fi
  tmux rename-window "$*"
}

tmux_focus_left() { _tmux_required && tmux select-pane -L; }
tmux_focus_right() { _tmux_required && tmux select-pane -R; }
tmux_focus_up() { _tmux_required && tmux select-pane -U; }
tmux_focus_down() { _tmux_required && tmux select-pane -D; }

tmux_resize_left() {
  _tmux_required || return 1
  local amount
  amount="$(_tmux_amount_or_default "${1:-5}")" || return 1
  tmux resize-pane -L "${amount}"
}
tmux_resize_right() {
  _tmux_required || return 1
  local amount
  amount="$(_tmux_amount_or_default "${1:-5}")" || return 1
  tmux resize-pane -R "${amount}"
}
tmux_resize_up() {
  _tmux_required || return 1
  local amount
  amount="$(_tmux_amount_or_default "${1:-5}")" || return 1
  tmux resize-pane -U "${amount}"
}
tmux_resize_down() {
  _tmux_required || return 1
  local amount
  amount="$(_tmux_amount_or_default "${1:-5}")" || return 1
  tmux resize-pane -D "${amount}"
}

tmux_list() {
  if ! _tmux_cmd_available; then
    echo "tmux not found in PATH." >&2
    return 1
  fi
  echo "Sessions:"
  tmux list-sessions -F '  #{session_name} (#{session_windows} windows, attached=#{?session_attached,yes,no})' 2>/dev/null || echo "  (none)"
  echo "Windows:"
  tmux list-windows -a -F '  #{session_name}:#{window_index} #{window_name}#{?window_active, [active],}' 2>/dev/null || echo "  (none)"
  echo "Panes:"
  tmux list-panes -a -F '  #{session_name}:#{window_index}.#{pane_index} #{pane_current_command}#{?pane_active, [active],}' 2>/dev/null || echo "  (none)"
}

tmux_sessions_pick_or_list() {
  if ! _tmux_cmd_available; then
    echo "tmux not found in PATH." >&2
    return 1
  fi
  if command -v fzf &>/dev/null; then
    local target
    target="$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --prompt='tmux session> ' --height=40% --reverse)"
    [[ -n "${target}" ]] && tmux switch-client -t "${target}"
  else
    tmux list-sessions
  fi
}

tmux_detach() { _tmux_required && tmux detach-client; }

tmux_run_split() {
  _tmux_required || return 1
  if [[ $# -eq 0 ]]; then
    echo "Usage: /run <cmd>" >&2
    return 1
  fi
  tmux split-window -v -c '#{pane_current_path}' "$*"
}

tmux_test_split() {
  _tmux_required || return 1
  if [[ $# -gt 0 ]]; then
    tmux split-window -v -c '#{pane_current_path}' "$*"
    return 0
  fi
  if [[ -f package.json ]]; then
    tmux split-window -v -c '#{pane_current_path}' "npm test"
    return 0
  fi
  echo "No default test command found. Usage: /test <cmd>" >&2
  return 1
}

tmux_logs_split() {
  _tmux_required || return 1
  if [[ $# -eq 0 ]]; then
    echo "Usage: /logs <cmd>" >&2
    return 1
  fi
  tmux split-window -v -c '#{pane_current_path}' "$*"
}

tmux_sync_toggle() {
  _tmux_required || return 1
  local state
  state="$(tmux show-window-options -v synchronize-panes 2>/dev/null)"
  if [[ "${state}" == "on" ]]; then
    tmux set-window-option synchronize-panes off
    echo "synchronize-panes: off"
  else
    tmux set-window-option synchronize-panes on
    echo "synchronize-panes: on"
  fi
}

tmux_capture() {
  _tmux_required || return 1
  local out_file="${1:-}"
  if [[ -z "${out_file}" ]]; then
    local session window pane ts
    session="$(tmux display-message -p '#S')"
    window="$(tmux display-message -p '#I')"
    pane="$(tmux display-message -p '#P')"
    ts="$(date +%Y%m%d-%H%M%S)"
    out_file="${TMPDIR:-/tmp}/tmux-capture-${session}-${window}-${pane}-${ts}.log"
  fi
  tmux capture-pane -p -S - > "${out_file}"
  echo "Captured pane to ${out_file}"
}

tmux_ctx() {
  _tmux_required || return 1
  tmux display-message -p 'session=#S window=#I:#W pane=#P tty=#{pane_tty} path=#{pane_current_path}'
}

# TODO: /dev is intentionally not implemented until a clear repo dev-layout convention exists.

if [[ -n "${ZSH_VERSION:-}" ]]; then
  alias /v='tmux_split_v'
  alias /h='tmux_split_h'
  alias /x='tmux_kill_pane'
  alias /z='tmux_zoom_pane'
  alias /t='tmux_new_window'
  alias /rn='tmux_rename_window'
  alias /left='tmux_focus_left'
  alias /right='tmux_focus_right'
  alias /up='tmux_focus_up'
  alias /down='tmux_focus_down'
  alias /rl='tmux_resize_left'
  alias /rr='tmux_resize_right'
  alias /ru='tmux_resize_up'
  alias /rd='tmux_resize_down'
  alias /ls='tmux_list'
  alias /s='tmux_sessions_pick_or_list'
  alias /d='tmux_detach'
  alias /run='tmux_run_split'
  alias /test='tmux_test_split'
  alias /logs='tmux_logs_split'
  alias /sync='tmux_sync_toggle'
  alias /capture='tmux_capture'
  alias /ctx='tmux_ctx'
fi
