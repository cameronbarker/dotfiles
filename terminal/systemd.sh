# -----------------------------------------------------------------------------
# systemd (Linux)
# -----------------------------------------------------------------------------
alias sc='systemctl'

# list services and the name to pass to sc (e.g. sc status nginx)
scl() {
  if ! command -v systemctl >/dev/null 2>&1; then
    echo 'scl: systemctl not found (Linux only)' >&2
    return 1
  fi

  systemctl list-units --type=service --all --no-pager --plain \
    | awk '
      NR == 1 { next }
      {
        full = $1
        state = $3
        name = full
        sub(/\.service$/, "", name)
        printf "%-32s %-10s  sc status %s\n", full, state, name
      }
    '
}
