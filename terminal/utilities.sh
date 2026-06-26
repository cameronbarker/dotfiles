# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

export AI_CLI="${AI_CLI:-codex}"
# shellcheck disable=SC2034
PB_DESC_ai="run the configured AI CLI"
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

# shellcheck disable=SC2034
PB_DESC_aictx="run ai-context from this repo or PATH"
aictx() { _ai_kit_command "ai-context" "$@"; }
# shellcheck disable=SC2034
PB_DESC_airisk="run ai-risk from this repo or PATH"
airisk() { _ai_kit_command "ai-risk" "$@"; }
# shellcheck disable=SC2034
PB_DESC_aifail="run ai-failure from this repo or PATH"
aifail() { _ai_kit_command "ai-failure" "$@"; }
# shellcheck disable=SC2034
PB_DESC_aiprompt="run ai-codex-prompt from this repo or PATH"
aiprompt() { _ai_kit_command "ai-codex-prompt" "$@"; }

_pb_function_ignored() {
  local name ignored
  name="$1"

  for ignored in \
    tmux_split_v tmux_split_h tmux_kill_pane tmux_zoom_pane \
    tmux_new_window tmux_rename_window \
    tmux_focus_left tmux_focus_right tmux_focus_up tmux_focus_down \
    tmux_resize_left tmux_resize_right tmux_resize_up tmux_resize_down \
    tmux_list tmux_sessions_pick_or_list tmux_detach \
    tmux_run_split tmux_test_split tmux_logs_split \
    tmux_sync_toggle tmux_capture tmux_ctx
  do
    [ "${name}" = "${ignored}" ] && return 0
  done

  return 1
}

# shellcheck disable=SC2034
PB_DESC_pb="list public dotfiles functions"
pb() {
  local description name query
  query="${1:-}"

  {
    for name in \
      pb ai aictx airisk aifail aiprompt \
      mkcd extract serve ff scaffold gca scl scj \
      tmux_split_v tmux_split_h tmux_kill_pane tmux_zoom_pane \
      tmux_new_window tmux_rename_window \
      tmux_focus_left tmux_focus_right tmux_focus_up tmux_focus_down \
      tmux_resize_left tmux_resize_right tmux_resize_up tmux_resize_down \
      tmux_list tmux_sessions_pick_or_list tmux_detach \
      tmux_run_split tmux_test_split tmux_logs_split \
      tmux_sync_toggle tmux_capture tmux_ctx
    do
      _pb_function_ignored "${name}" && continue
      type "${name}" >/dev/null 2>&1 || continue
      eval "description=\${PB_DESC_${name}:-}"
      if [ -n "${description}" ]; then
        printf "%-12s - %s\n" "${name}" "${description}"
      else
        printf "%s\n" "${name}"
      fi
    done
  } | if [ -n "${query}" ]; then
    grep -i -- "${query}" || true
  else
    cat
  fi
}

# make a directory and cd into it
# shellcheck disable=SC2034
PB_DESC_mkcd="make a directory and cd into it"
mkcd() { mkdir -p "$1" && cd "$1" || return; }

# extract common archive formats
# shellcheck disable=SC2034
PB_DESC_extract="extract common archive formats"
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
# shellcheck disable=SC2034
PB_DESC_serve="start a Python HTTP server in the current directory"
serve() { python3 -m http.server "${1:-8000}"; }

# find file by name
# shellcheck disable=SC2034
PB_DESC_ff="find files by name under the current directory"
ff() { find . -name "*$1*" 2>/dev/null; }
