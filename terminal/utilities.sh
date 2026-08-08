# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

export AI_CLI="${AI_CLI:-codex}"
# shellcheck disable=SC2034
PB_DESC_ai="run the configured AI CLI"
ai() { command "${AI_CLI}" "$@"; }

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

  case "${query}" in
    scaffold)
      if ! type scaffold >/dev/null 2>&1; then
        echo "pb: scaffold function is not loaded" >&2
        return 1
      fi

      shift
      if [ "$#" -eq 0 ]; then
        echo "Available scaffolds:"
        scaffold --list
      else
        scaffold "$@"
      fi
      return
      ;;
    scaffolds)
      if ! type scaffold >/dev/null 2>&1; then
        echo "pb: scaffold function is not loaded" >&2
        return 1
      fi

      scaffold --list
      return
      ;;
    update)
      shift
      pb_update "$@"
      return
      ;;
  esac

  {
    printf "%-12s - %s\n" "pb update" "download and run bootstrap.sh from main"

    for name in \
      pb ai \
      mkcd extract serve ff port scaffold gca scl scj \
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

# download the latest bootstrap script and run the installer
# shellcheck disable=SC2034
PB_DESC_pb_update="download and run bootstrap.sh from main"
pb_update() {
  local -a update_args=("$@")
  local url="https://raw.githubusercontent.com/cameronbarker/dotfiles/main/bootstrap.sh"

  if ! command -v curl >/dev/null 2>&1; then
    echo "pb update: curl is required" >&2
    return 1
  fi

  (
    set -o pipefail
    curl -fsSL "${url}" | bash -s -- "${update_args[@]}"
  )
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

# check whether a TCP port is reachable on a host
# shellcheck disable=SC2034
PB_DESC_port="check whether a TCP port is open on a host"
port() {
  local host="$1" port_num="$2"

  if [ -z "${host}" ] || [ -z "${port_num}" ]; then
    echo "Usage: port <host> <port>" >&2
    return 1
  fi

  if ! command -v nc >/dev/null 2>&1; then
    echo "port: nc (netcat) is required" >&2
    return 1
  fi

  case "$(uname -s)" in
    Darwin) nc -zv -G 3 "${host}" "${port_num}" ;;
    *)      nc -zv -w 3 "${host}" "${port_num}" ;;
  esac
}
