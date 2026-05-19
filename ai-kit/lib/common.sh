#!/usr/bin/env bash
set -euo pipefail

ai_kit_repo_root() {
  if command -v git >/dev/null 2>&1; then
    git rev-parse --show-toplevel 2>/dev/null || pwd
  else
    pwd
  fi
}

ai_kit_now_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

ai_kit_json_escape() {
  local s="${1:-}"
  s=${s//\\/\\\\}
  s=${s//"/\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

ai_kit_unique_lines() {
  awk 'NF && !seen[$0]++'
}

ai_kit_trim() {
  local v="${1:-}"
  v="${v#${v%%[![:space:]]*}}"
  v="${v%${v##*[![:space:]]}}"
  printf '%s' "$v"
}
