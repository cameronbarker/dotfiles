# -----------------------------------------------------------------------------
# systemd (Linux)
# -----------------------------------------------------------------------------
alias sc='systemctl'

# list services and the name to pass to sc (e.g. sc status nginx)
# default: notable running/failed services and container-style exited services; scl -a for all loaded units
# shellcheck disable=SC2034
PB_DESC_scl="list systemd services with sc status commands"
scl() {
  if ! command -v systemctl >/dev/null 2>&1; then
    echo 'scl: systemctl not found (Linux only)' >&2
    return 1
  fi

  local -a cmd=(systemctl list-units --type=service --no-pager --plain --no-legend)
  local show_all=0

  case "${1:-}" in
    -a|--all)
      shift
      cmd+=(--all)
      show_all=1
      ;;
    *)
      cmd+=(--state=running,exited,failed)
      ;;
  esac

  "${cmd[@]}" \
    | awk -v show_all="${show_all}" '
      $1 ~ /\.service$/ {
        full = $1
        state = $4
        description = ""
        for (i = 5; i <= NF; i++) {
          description = description (description == "" ? "" : " ") $i
        }
        if (!show_all && full ~ /^(console-getty|container-getty@.*|cron|dbus|systemd-(journald|logind|networkd))\.service$/) {
          next
        }
        if (!show_all && state == "exited" && description !~ /(podman|podman-compose|docker|compose|container)/) {
          next
        }
        name = full
        sub(/\.service$/, "", name)
        printf "%-32s %-10s  sc status %s\n", full, state, name
      }
    '
}

# follow journal logs for a service (e.g. scj frigate)
# shellcheck disable=SC2034
PB_DESC_scj="follow journal logs for a systemd service"
scj() {
  if ! command -v journalctl >/dev/null 2>&1; then
    echo 'scj: journalctl not found (Linux only)' >&2
    return 1
  fi
  if [[ -z "${1:-}" ]]; then
    echo 'usage: scj <service> [lines]' >&2
    return 1
  fi

  local unit="$1"
  local lines="${2:-50}"
  [[ "${unit}" == *.service ]] || unit="${unit}.service"
  journalctl -u "${unit}" -n "${lines}" -f
}

# reuse systemctl/journalctl completion for sc and scj
_pb_sc_completion() {
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    (( $+functions[compdef] )) || return 0

    local registered=0
    autoload -Uz _systemctl 2>/dev/null
    if (( $+functions[_systemctl] )); then
      compdef _systemctl sc
      registered=1
    fi
    autoload -Uz _journalctl 2>/dev/null
    if (( $+functions[_journalctl] )); then
      compdef _journalctl scj
      registered=1
    fi

    if (( registered )); then
      autoload -Uz add-zsh-hook 2>/dev/null
      (( $+functions[add-zsh-hook] )) && add-zsh-hook -D precmd _pb_sc_completion
      unfunction _pb_sc_completion 2>/dev/null
    fi
    return 0
  fi

  if [[ -n "${BASH_VERSION:-}" ]]; then
    if ! declare -f _systemctl &>/dev/null; then
      local _pb_bash_completion
      for _pb_bash_completion in \
        /usr/share/bash-completion/completions/systemctl \
        /etc/bash_completion.d/systemctl; do
        if [[ -r "${_pb_bash_completion}" ]]; then
          # shellcheck source=/dev/null
          source "${_pb_bash_completion}"
          break
        fi
      done
    fi
    if ! declare -f _journalctl &>/dev/null; then
      for _pb_bash_completion in \
        /usr/share/bash-completion/completions/journalctl \
        /etc/bash_completion.d/journalctl; do
        if [[ -r "${_pb_bash_completion}" ]]; then
          # shellcheck source=/dev/null
          source "${_pb_bash_completion}"
          break
        fi
      done
      unset _pb_bash_completion
    fi
    if declare -f _systemctl &>/dev/null; then
      complete -F _systemctl sc 2>/dev/null
    fi
    if declare -f _journalctl &>/dev/null; then
      complete -F _journalctl scj 2>/dev/null
    fi
    unset -f _pb_sc_completion 2>/dev/null
  fi
}

if command -v systemctl >/dev/null 2>&1; then
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    autoload -Uz add-zsh-hook 2>/dev/null
    (( $+functions[add-zsh-hook] )) && add-zsh-hook -D precmd _pb_sc_completion
    if (( $+functions[compdef] )); then
      _pb_sc_completion
    elif (( $+functions[add-zsh-hook] )); then
      add-zsh-hook precmd _pb_sc_completion
    fi
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    _pb_sc_completion
  fi
fi
