#!/usr/bin/env bash
# pb.template — generic project/workspace CLI for multiple repos and languages
# Set variables in env or in a repo .pb.env; copy and rename (e.g. pb, wk, proj) as needed.
#
# When installed in /bin or ~/bin: project is resolved from the directory you
# run the command from (PWD). So run "pb" from inside a repo, or set PROJECT_ROOT
# in your shell/profile.
#
# ------------------------------------------------------------------------------
# EXTENDING
# ------------------------------------------------------------------------------
#
# 1. Adding a new command
#    Add a new branch in the "case $cmd" block. Use run_in_project for commands
#    that must run inside WORK_DIR:
#      mycmd)
#        run_in_project npm run build "$@"
#        ;;
#    To run a per-repo script only when it exists:
#      mycmd)
#        if [[ -x "$PROJECT_ROOT/scripts/mycmd.sh" ]]; then
#          "$PROJECT_ROOT/scripts/mycmd.sh" "$@"
#        else
#          echo "No scripts/mycmd.sh in this project."
#          exit 1
#        fi
#        ;;
#
# 2. Per-repo config (.pb.env)
#    In the project root, create .pb.env and export any of:
#      PROJECT_ROOT=/path/to/root     # e.g. monorepo root
#      WORK_DIR=$PROJECT_ROOT/apps/api # where "pb run" runs
#      SERVICE_NAME=myapp.service
#      SERVICE_MANAGER=systemctl       # or launchctl
#      LOG_FILE=$PROJECT_ROOT/log/app.log
#    Only PROJECT_ROOT is required; the rest are optional. .pb.env is sourced
#    when you run pb from that directory or any subdirectory (resolution walks up).
#
# 3. Alternative project root (.pb_root)
#    If you don't want a full .pb.env, create a file .pb_root containing a single
#    path (the project root). Resolution walks up from PWD and uses the first
#    .pb_root or .pb.env found.
#
# 4. Adding a new service manager
#    In service_available(), add a check for your manager (e.g. docker).
#    In service_run(), add a case that runs the right commands for status/start/
#    stop/restart. You can use a different action set (e.g. docker start/stop).
#
# 5. New helpers
#    Define functions above the "case $cmd" block and call them from command
#    branches. run_in_project is the pattern: ( cd "$WORK_DIR" && "$@" ). For
#    multiple work dirs, set WORK_DIR in .pb.env per repo, or add commands that
#    take a subdir argument and cd there before running.
#
# 6. Shell alias for "cd to project"
#    Because "pb cd" runs in a subshell, your shell won't change. Use:
#      alias pcd='cd "$(pb root)"'
#    (or source a wrapper that runs "cd $(pb root)" in the current shell).

set -e

# ------------------------------------------------------------------------------
# Resolve "current project" root (override for different workflows)
# ------------------------------------------------------------------------------
# Order: PROJECT_ROOT env → .pb.env in cwd or parents → .pb_root file → $PWD

resolve_project_root() {
  if [[ -n "${PROJECT_ROOT:-}" ]]; then
    echo "$PROJECT_ROOT"
    return
  fi
  local dir="${1:-$PWD}"
  while [[ -n "$dir" ]] && [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.pb.env" ]]; then
      # Source and re-check PROJECT_ROOT (or PROJECT_ROOT set inside .pb.env)
      local root
      root=$(grep -E '^PROJECT_ROOT=' "$dir/.pb.env" 2>/dev/null | head -1 | cut -d= -f2- | tr -d '"' | tr -d "'")
      if [[ -n "$root" ]]; then
        echo "$root"
        return
      fi
      # .pb.env exists but no PROJECT_ROOT — use its directory
      echo "$dir"
      return
    fi
    if [[ -f "$dir/.pb_root" ]]; then
      cat "$dir/.pb_root"
      return
    fi
    dir="${dir%/*}"
  done
  echo "${PWD}"
}

# Load optional per-repo config (only PROJECT_ROOT and other vars)
if [[ -f "${PWD}/.pb.env" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${PWD}/.pb.env" 2>/dev/null || true
  set +a
fi
PROJECT_ROOT="${PROJECT_ROOT:-$(resolve_project_root)}"

# Optional: subdirectory to run commands in (e.g. frontend/, backend/, core/)
# Leave empty to use PROJECT_ROOT
WORK_DIR="${WORK_DIR:-$PROJECT_ROOT}"

# Optional: service (systemd/launchd). Leave SERVICE_NAME empty to disable.
SERVICE_NAME="${SERVICE_NAME:-}"
SERVICE_MANAGER="${SERVICE_MANAGER:-systemctl}"

# Optional: log file for "logs" command. Leave empty to disable.
LOG_FILE="${LOG_FILE:-}"

# Export for subshells
export PROJECT_ROOT
export WORK_DIR

# ------------------------------------------------------------------------------
# Helpers (extend for other systems or languages)
# ------------------------------------------------------------------------------

run_in_project() {
  ( cd "$WORK_DIR" && "$@" )
}

service_available() {
  [[ -n "$SERVICE_NAME" ]] || return 1
  case "$SERVICE_MANAGER" in
    systemctl)  command -v systemctl >/dev/null 2>&1 ;;
    launchctl)  command -v launchctl >/dev/null 2>&1 ;;
    *)          false ;;
  esac
}

service_run() {
  local action="$1"
  if [[ -z "$SERVICE_NAME" ]]; then
    echo "No service configured (set SERVICE_NAME in env or .pb.env)."
    return 1
  fi
  if ! service_available; then
    echo "\`$SERVICE_MANAGER\` not available on this system."
    return 1
  fi
  case "$SERVICE_MANAGER" in
    systemctl)  sudo systemctl "$action" "$SERVICE_NAME" ;;
    launchctl)  launchctl "$action" "$SERVICE_NAME" ;;
    *)          echo "Unknown SERVICE_MANAGER: $SERVICE_MANAGER"; return 1 ;;
  esac
}

# ------------------------------------------------------------------------------
# Commands (add more case branches or source per-repo scripts)
# ------------------------------------------------------------------------------

cmd="${1:-help}"
shift 2>/dev/null || true

case "$cmd" in
  help|-h|--help)
    cat <<EOF
pb — generic project CLI

Usage: pb <command> [args]

Commands:
  pb help     — this message
  pb env      — show project root, work dir, and optional config
  pb root     — print project root (e.g. cd \$(pb root) in your shell)
  pb cd       — cd to project root (only inside this script; use cd \$(pb root) for your shell)
  pb run CMD  — run CMD inside WORK_DIR (e.g. pb run npm start, pb run make)
  pb status   — service status (if SERVICE_NAME set)
  pb start    — start service (if configured)
  pb stop     — stop service (if configured)
  pb restart  — restart service (if configured)
  pb logs [N] — tail log file (if LOG_FILE set)

Config:
  Set PROJECT_ROOT, WORK_DIR, SERVICE_NAME, LOG_FILE in env or in .pb.env
  in the project root. Use .pb_root (file containing one path) as fallback.

Extending:
  See the EXTENDING comment block at the top of this script.
EOF
    ;;
  env)
    echo "Project environment"
    echo "-------------------"
    printf "%-16s %s\n" "PROJECT_ROOT:" "$PROJECT_ROOT"
    printf "%-16s %s\n" "WORK_DIR:"     "$WORK_DIR"
    printf "%-16s %s\n" "SERVICE_NAME:" "${SERVICE_NAME:-<not set>}"
    printf "%-16s %s\n" "SERVICE_MGR:"  "$SERVICE_MANAGER"
    printf "%-16s %s\n" "LOG_FILE:"     "${LOG_FILE:-<not set>}"
    if service_available; then
      printf "%-16s %s\n" "Service:"     "available"
    else
      printf "%-16s %s\n" "Service:"     "not configured or not available"
    fi
    ;;
  root)
    echo "$PROJECT_ROOT"
    ;;
  cd)
    cd "$PROJECT_ROOT" || exit 1
    ;;
  run)
    if [[ $# -eq 0 ]]; then
      echo "Usage: pb run <command> [args...]" >&2
      exit 1
    fi
    run_in_project "$@"
    ;;
  status)
    service_run status
    ;;
  start)
    service_run start
    ;;
  stop)
    service_run stop
    ;;
  restart)
    service_run restart
    ;;
  logs)
    if [[ -z "${LOG_FILE:-}" ]]; then
      echo "No LOG_FILE set (in env or .pb.env)."
      exit 1
    fi
    if [[ ! -f "$LOG_FILE" ]]; then
      echo "Log file not found: $LOG_FILE"
      exit 1
    fi
    lines="${1:-100}"
    shift 2>/dev/null || true
    tail -n "$lines" "$LOG_FILE" "$@"
    ;;
  *)
    echo "pb: unknown command: $cmd" >&2
    echo "Run 'pb help' for usage." >&2
    exit 1
    ;;
esac
