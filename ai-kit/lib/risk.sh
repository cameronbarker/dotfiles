#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=ai-kit/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ai_risk_config_file() {
  local root="$1"
  printf '%s/.codex/risk-paths.yml' "$root"
}

ai_risk_levels_rank() {
  case "$1" in
    low) echo 1 ;;
    medium) echo 2 ;;
    high) echo 3 ;;
    critical) echo 4 ;;
    *) echo 2 ;;
  esac
}

ai_risk_is_blocking_action() {
  case "$1" in
    block_without_confirmation) return 0 ;;
    *) return 1 ;;
  esac
}

ai_risk_load_config() {
  local config="$1"
  AI_RISK_DEFAULT_LEVEL="medium"
  AI_RISK_DEFAULT_ACTION="inspect_only"
  AI_RISK_RULE_COUNT=0

  [[ -f "$config" ]] || return 0

  local in_defaults=0 in_rules=0 idx=-1
  while IFS= read -r line || [[ -n "$line" ]]; do
    local t
    t="$(ai_kit_trim "$line")"
    [[ -z "$t" || "$t" == \#* ]] && continue

    case "$t" in
      defaults:)
        in_defaults=1; in_rules=0; continue ;;
      rules:)
        in_defaults=0; in_rules=1; continue ;;
    esac

    if [[ $in_defaults -eq 1 ]]; then
      case "$t" in
        level:*) AI_RISK_DEFAULT_LEVEL="$(ai_kit_trim "${t#level:}")" ;;
        action:*) AI_RISK_DEFAULT_ACTION="$(ai_kit_trim "${t#action:}")" ;;
      esac
      continue
    fi

    if [[ $in_rules -eq 1 ]]; then
      if [[ "$t" == -* ]]; then
        idx=$((idx + 1))
        AI_RISK_RULE_COUNT=$((AI_RISK_RULE_COUNT + 1))
        AI_RISK_RULE_PATH[$idx]=""
        AI_RISK_RULE_LEVEL[$idx]="$AI_RISK_DEFAULT_LEVEL"
        AI_RISK_RULE_ACTION[$idx]="$AI_RISK_DEFAULT_ACTION"
        AI_RISK_RULE_REASON[$idx]=""
        local rest
        rest="$(ai_kit_trim "${t#-}")"
        if [[ "$rest" == path:* ]]; then
          AI_RISK_RULE_PATH[$idx]="$(ai_kit_trim "${rest#path:}" | sed -e 's/^"//' -e 's/"$//')"
        fi
        continue
      fi

      [[ $idx -lt 0 ]] && continue
      case "$t" in
        path:*) AI_RISK_RULE_PATH[$idx]="$(ai_kit_trim "${t#path:}" | sed -e 's/^"//' -e 's/"$//')" ;;
        level:*) AI_RISK_RULE_LEVEL[$idx]="$(ai_kit_trim "${t#level:}")" ;;
        action:*) AI_RISK_RULE_ACTION[$idx]="$(ai_kit_trim "${t#action:}")" ;;
        reason:*) AI_RISK_RULE_REASON[$idx]="$(ai_kit_trim "${t#reason:}" | sed -e 's/^"//' -e 's/"$//')" ;;
      esac
    fi
  done < "$config"
}

ai_risk_match_glob() {
  local path="$1"
  local pattern="$2"
  [[ -z "$pattern" ]] && return 1

  case "$pattern" in
    "**/*secret*")
      [[ "$path" == *secret* || "$path" == *SECRET* ]]
      return
      ;;
  esac

  if [[ "$pattern" == **/* ]]; then
    local prefix="${pattern%%/**}"
    [[ "$path" == "$prefix"/* || "$path" == "$prefix" ]]
    return
  fi

  [[ "$path" == $pattern ]]
}

ai_risk_eval_path() {
  local path="$1"
  local matched=0
  local level="$AI_RISK_DEFAULT_LEVEL"
  local action="$AI_RISK_DEFAULT_ACTION"
  local reason="default"

  local i
  for ((i = 0; i < AI_RISK_RULE_COUNT; i++)); do
    if ai_risk_match_glob "$path" "${AI_RISK_RULE_PATH[$i]}"; then
      matched=1
      level="${AI_RISK_RULE_LEVEL[$i]}"
      action="${AI_RISK_RULE_ACTION[$i]}"
      reason="${AI_RISK_RULE_REASON[$i]:-matched rule}"
      break
    fi
  done

  printf '%s\t%s\t%s\t%s\t%s\n' "$path" "$level" "$action" "$matched" "$reason"
}
