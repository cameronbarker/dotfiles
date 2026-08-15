# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

export AI_CLI="${AI_CLI:-codex}"
PB_DOTFILES_DIR="${PB_DOTFILES_DIR:-${_PB_TERMINAL_DIR:-}}"
# shellcheck disable=SC2034
PB_DESC_ai="run the configured AI CLI"
ai() { command "${AI_CLI}" "$@"; }

unalias size 2>/dev/null || true
# shellcheck disable=SC2034
PB_DESC_size="show the human-readable size of files or directories"
size() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: size <file-or-directory> [...]" >&2
    return 1
  fi

  command du -sh "$@"
}

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

_pb_help_records() {
  local category description name

  printf "%s\t%s\t%s\n" "PB Toolkit" "pb update" "${PB_DESC_pb_update:-update dotfiles from git checkout or bootstrap}"
  printf "%s\t%s\t%s\n" "PB Toolkit" "pb install" "${PB_DESC_pb_install:-install known tools by name}"
  printf "%s\t%s\t%s\n" "PB Toolkit" "pb rm_screenshots" "delete screenshots from the Desktop"

  for name in \
    pb \
    ai \
    size mkcd extract ff scaffold \
    serve port scl scj \
    gca \
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
    case "${name}" in
      pb) category="PB Toolkit" ;;
      ai) category="AI" ;;
      size|mkcd|extract|ff|scaffold) category="Files & Directories" ;;
      serve|port|scl|scj) category="Network & Services" ;;
      gca) category="Git" ;;
      *) category="Other" ;;
    esac
    eval "description=\${PB_DESC_${name}:-}"
    printf "%s\t%s\t%s\n" "${category}" "${name}" "${description}"
  done
}

_pb_filter_help_records() {
  local query
  query="${1:-}"

  if [ -n "${query}" ]; then
    grep -i -- "${query}" || true
  else
    cat
  fi
}

_pb_render_help() {
  local query
  query="${1:-}"

  if type ui_help_table >/dev/null 2>&1; then
    _pb_help_records \
      | _pb_filter_help_records "${query}" \
      | ui_help_table \
          "PB" \
          "Dotfiles Toolkit" \
          "Manage, search, and automate your dotfiles" \
          "Tip: \`pb <command> --help\` for command-specific help"
  else
    _pb_help_records \
      | _pb_filter_help_records "${query}" \
      | while IFS="$(printf '\t')" read -r _category name description; do
          [ -n "${name}" ] || continue
          if [ -n "${description}" ]; then
            printf "%-18s %s\n" "${name}" "${description}"
          else
            printf "%s\n" "${name}"
          fi
        done
  fi
}

# shellcheck disable=SC2034
PB_DESC_pb="list public dotfiles functions"
pb() {
  local query
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
    install)
      shift
      pb_install "$@"
      return
      ;;
    rm_screenshots)
      shift
      _pb_rm_screenshots "$@"
      return
      ;;
  esac

  _pb_render_help "${query}"
}

# update the dotfiles checkout when present, otherwise run the remote bootstrap installer
# shellcheck disable=SC2034
PB_DESC_pb_update="update dotfiles from git checkout or bootstrap"
pb_update() {
  local -a update_args=("$@")
  local checkout
  local url="https://raw.githubusercontent.com/cameronbarker/dotfiles/main/bootstrap.sh"

  for checkout in "${PB_DOTFILES_DIR}" "${HOME}/.dotfiles"; do
    [ -n "${checkout}" ] || continue
    if [ -d "${checkout}/.git" ]; then
      if ! command -v git >/dev/null 2>&1; then
        echo "pb update: git is required to update ${checkout}" >&2
        return 1
      fi
      if [ ! -x "${checkout}/install.sh" ]; then
        echo "pb update: ${checkout}/install.sh is not executable" >&2
        return 1
      fi

      git -C "${checkout}" pull origin main
      "${checkout}/install.sh" "${update_args[@]}"
      return
    fi
  done

  if ! command -v curl >/dev/null 2>&1; then
    echo "pb update: curl is required" >&2
    return 1
  fi

  (
    set -o pipefail
    curl -fsSL "${url}" | bash -s -- "${update_args[@]}"
  )
}

# install known external tools by short name
# shellcheck disable=SC2034
PB_DESC_pb_install="install known tools by name"
pb_install() {
  local -a install_args=()
  local name="${1:-}"

  if [ -z "${name}" ]; then
    cat <<'EOF'
Available installers:
  ai      - Codex CLI
  codex   - Codex CLI
  tailscale - Tailscale
EOF
    return 0
  fi

  shift
  install_args=("$@")

  case "${name}" in
    ai|codex)
      if ! command -v curl >/dev/null 2>&1; then
        echo "pb install ${name}: curl is required" >&2
        return 1
      fi

      (
        set -o pipefail
        curl -fsSL https://chatgpt.com/codex/install.sh | sh -s -- "${install_args[@]}"
      ) || return

      echo "Codex installed. Next run: ai login --device-auth"
      ;;
    tailscale)
      if ! command -v curl >/dev/null 2>&1; then
        echo "pb install ${name}: curl is required" >&2
        return 1
      fi

      (
        set -o pipefail
        curl -fsSL https://tailscale.com/install.sh | sh -s -- "${install_args[@]}"
      ) || return

      echo "Tailscale installed. Next run: tailscale up"
      ;;
    *)
      echo "pb install: unknown installer '${name}'" >&2
      echo "Run 'pb install' to list available installers." >&2
      return 1
      ;;
  esac
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

_pb_rm_screenshots() {
  local desktop count
  desktop="${HOME}/Desktop"

  if [ ! -d "${desktop}" ]; then
    echo "pb rm_screenshots: ${desktop} does not exist" >&2
    return 1
  fi

  count="$(
    find "${desktop}" -maxdepth 1 -type f \
      \( -name 'Screenshot *' -o -name 'Screen Shot *' \) \
      | wc -l
  )"
  count="${count##*[!0-9]}"

  find "${desktop}" -maxdepth 1 -type f \
    \( -name 'Screenshot *' -o -name 'Screen Shot *' \) \
    -exec rm -f {} +

  echo "Deleted ${count:-0} screenshot(s) from ${desktop}."
}

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
