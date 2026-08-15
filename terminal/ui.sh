# shellcheck shell=bash

# -----------------------------------------------------------------------------
# Terminal UI helpers
# -----------------------------------------------------------------------------

ui_terminal_width() {
  local cols
  cols="${COLUMNS:-}"

  case "${cols}" in
    ''|*[!0-9]*)
      cols="$(tput cols 2>/dev/null || printf '80')"
      ;;
  esac

  case "${cols}" in
    ''|*[!0-9]*) cols=80 ;;
  esac

  printf '%s\n' "${cols}"
}

ui_is_tty() {
  [ -t 1 ]
}

ui_supports_color() {
  local colors mode

  mode="${PB_COLOR:-always}"
  [ "${_UI_ASSUME_TTY:-0}" = "1" ] || ui_is_tty || return 1

  case "${mode}" in
    never) return 1 ;;
    always) return 0 ;;
  esac

  [ -z "${NO_COLOR:-}" ] || return 1
  command -v tput >/dev/null 2>&1 || return 1

  colors="$(tput colors 2>/dev/null || printf '0')"
  [ "${colors:-0}" -ge 8 ] 2>/dev/null
}

ui_style() {
  local style mode
  style="${1:-reset}"
  mode="${PB_COLOR:-always}"

  ui_supports_color || return 0

  if [ "${mode}" = "always" ]; then
    case "${style}" in
      accent) printf '\033[1;96m' ;;
      pb)     printf '\033[1;93m' ;;
      ai)     printf '\033[1;95m' ;;
      files)  printf '\033[1;96m' ;;
      network) printf '\033[1;92m' ;;
      git)    printf '\033[1;94m' ;;
      muted)  printf '\033[90m' ;;
      bold)   printf '\033[1m' ;;
      reset)  printf '\033[0m' ;;
    esac
    return 0
  fi

  if command -v tput >/dev/null 2>&1; then
    case "${style}" in
      accent) { tput bold 2>/dev/null || true; tput setaf 14 2>/dev/null || tput setaf 6 2>/dev/null || printf '\033[1;96m'; } ;;
      pb)     { tput bold 2>/dev/null || true; tput setaf 11 2>/dev/null || tput setaf 3 2>/dev/null || printf '\033[1;93m'; } ;;
      ai)     { tput bold 2>/dev/null || true; tput setaf 13 2>/dev/null || tput setaf 5 2>/dev/null || printf '\033[1;95m'; } ;;
      files)  { tput bold 2>/dev/null || true; tput setaf 14 2>/dev/null || tput setaf 6 2>/dev/null || printf '\033[1;96m'; } ;;
      network) { tput bold 2>/dev/null || true; tput setaf 10 2>/dev/null || tput setaf 2 2>/dev/null || printf '\033[1;92m'; } ;;
      git)    { tput bold 2>/dev/null || true; tput setaf 12 2>/dev/null || tput setaf 4 2>/dev/null || printf '\033[1;94m'; } ;;
      muted)  tput setaf 8 2>/dev/null || tput setaf 7 2>/dev/null || printf '\033[90m' ;;
      bold)   tput bold 2>/dev/null || printf '\033[1m' ;;
      reset)  tput sgr0 2>/dev/null || printf '\033[0m' ;;
    esac
    return 0
  fi

  case "${style}" in
    accent) printf '\033[1;96m' ;;
    pb)     printf '\033[1;93m' ;;
    ai)     printf '\033[1;95m' ;;
    files)  printf '\033[1;96m' ;;
    network) printf '\033[1;92m' ;;
    git)    printf '\033[1;94m' ;;
    muted)  printf '\033[90m' ;;
    bold)   printf '\033[1m' ;;
    reset)  printf '\033[0m' ;;
  esac
}

_ui_help_category_style() {
  case "$1" in
    "PB Toolkit") ui_style pb ;;
    "AI") ui_style ai ;;
    "Files & Directories") ui_style files ;;
    "Network & Services") ui_style network ;;
    "Git") ui_style git ;;
    *) ui_style accent ;;
  esac
}

ui_repeat() {
  local char count out
  char="$1"
  count="$2"
  out=""

  while [ "${count}" -gt 0 ]; do
    out="${out}${char}"
    count=$((count - 1))
  done

  printf '%s' "${out}"
}

ui_truncate() {
  local text width limit
  text="$1"
  width="$2"

  [ "${width}" -gt 0 ] 2>/dev/null || return 0

  if [ "${#text}" -le "${width}" ]; then
    printf '%s' "${text}"
    return 0
  fi

  if [ "${width}" -le 3 ]; then
    printf '%.*s' "${width}" "${text}"
    return 0
  fi

  limit=$((width - 3))
  printf '%.*s...' "${limit}" "${text}"
}

ui_pad_right() {
  local text width truncated padding
  text="$1"
  width="$2"

  truncated="$(ui_truncate "${text}" "${width}")"
  padding=$((width - ${#truncated}))

  printf '%s' "${truncated}"
  ui_repeat ' ' "${padding}"
}

_ui_help_table_plain() {
  local category command description current_category
  current_category=""

  while IFS="$(printf '\t')" read -r category command description; do
    [ -n "${command}" ] || continue
    if [ "${category}" != "${current_category}" ]; then
      [ -z "${current_category}" ] || printf '\n'
      printf '%s\n' "${category}"
      current_category="${category}"
    fi
    if [ -n "${description}" ]; then
      printf '  %-18s %s\n' "${command}" "${description}"
    else
      printf '  %s\n' "${command}"
    fi
  done
}

_ui_help_table_count_records() {
  local category command description count
  count=0

  while IFS="$(printf '\t')" read -r category command description; do
    [ -n "${command}" ] || continue
    count=$((count + 1))
  done

  printf '%s\n' "${count}"
}

_ui_help_table_compact() {
  local title subtitle records cols command_width description_width accent muted reset bold
  local category command description heading command_style current_category
  title="$1"
  subtitle="$2"
  records="$3"
  current_category=""

  cols="$(ui_terminal_width)"
  command_width=14
  [ "${cols}" -lt 52 ] && command_width=12
  description_width=$((cols - command_width - 2))
  [ "${description_width}" -lt 10 ] && description_width=10

  accent="$(ui_style accent)"
  muted="$(ui_style muted)"
  reset="$(ui_style reset)"
  bold="$(ui_style bold)"
  heading="${title} ${subtitle}"

  printf '%s%s%s\n\n' "${accent}" "$(ui_truncate "${heading}" "${cols}")" "${reset}"
  printf '%s' "${muted}"
  ui_pad_right "COMMAND" "${command_width}"
  printf '  '
  ui_pad_right "DESCRIPTION" "${description_width}"
  printf '%s\n' "${reset}"

  printf '%s\n' "${records}" | while IFS="$(printf '\t')" read -r category command description; do
    [ -n "${command}" ] || continue
    if [ "${category}" != "${current_category}" ]; then
      [ -z "${current_category}" ] || printf '\n'
      printf '%s%s%s\n' "${muted}${bold}" "$(ui_truncate "${category}" "${cols}")" "${reset}"
      current_category="${category}"
    fi
    command="$(ui_truncate "${command}" "${command_width}")"
    description="$(ui_truncate "${description}" "${description_width}")"
    command_style="$(_ui_help_category_style "${category}")"
    printf '%s%s%s' "${command_style}" "${command}" "${reset}"
    ui_repeat ' ' $((command_width - ${#command} + 2))
    printf '%s\n' "${description}"
  done
}

_ui_help_table_print_row() {
  local border muted reset category command description command_width description_width line_width command_style
  border="$1"
  muted="$2"
  reset="$3"
  category="$4"
  command="$5"
  description="$6"
  command_width="$7"
  description_width="$8"
  line_width="$9"

  command="$(ui_truncate "${command}" "${command_width}")"
  description="$(ui_truncate "${description}" "${description_width}")"
  command_style="$(_ui_help_category_style "${category}")"

  printf '%s│%s  %s%s%s' "${muted}" "${reset}" "${command_style}" "${command}" "${reset}"
  ui_repeat ' ' $((command_width - ${#command} + 2))
  ui_pad_right "${description}" "${description_width}"
  ui_repeat ' ' $((line_width - command_width - description_width - 2))
  printf '  %s│%s\n' "${muted}" "${reset}"
}

_ui_help_table_print_section() {
  local border muted reset bold category line_width
  border="$1"
  muted="$2"
  reset="$3"
  bold="$4"
  category="$5"
  line_width="$6"

  category="$(ui_truncate "${category}" "${line_width}")"
  printf '%s│%s  %s%s%s' "${border}" "${reset}" "${muted}${bold}" "${category}" "${reset}"
  ui_repeat ' ' $((line_width - ${#category}))
  printf '  %s│%s\n' "${border}" "${reset}"
}

_ui_help_table_tty() {
  local title subtitle description tip records cols panel_width inner_width line_width
  local command_width description_width count border muted reset accent bold
  local top_rule separator bottom_rule tip_prefix tip_command tip_suffix tip_text count_label
  local category command row_description current_category
  local _UI_ASSUME_TTY
  title="$1"
  subtitle="$2"
  description="$3"
  tip="$4"
  records="$5"
  _UI_ASSUME_TTY=1

  cols="$(ui_terminal_width)"
  if [ "${cols}" -lt 72 ]; then
    _ui_help_table_compact "${title}" "${subtitle}" "${records}"
    return 0
  fi

  panel_width=$((cols - 2))
  [ "${panel_width}" -gt 100 ] && panel_width=100
  [ "${panel_width}" -lt 58 ] && panel_width=58
  inner_width=$((panel_width - 2))
  line_width=$((inner_width - 4))

  if [ "${panel_width}" -lt 76 ]; then
    command_width=14
  else
    command_width=18
  fi
  description_width=$((line_width - command_width - 2))
  [ "${description_width}" -lt 10 ] && description_width=10

  count="$(printf '%s\n' "${records}" | _ui_help_table_count_records)"
  border="$(ui_style muted)"
  muted="$(ui_style muted)"
  reset="$(ui_style reset)"
  accent="$(ui_style accent)"
  bold="$(ui_style bold)"
  current_category=""

  top_rule="$(ui_repeat '─' "${inner_width}")"
  separator="$(ui_repeat '─' "${line_width}")"
  bottom_rule="${top_rule}"

  printf '%s╭%s╮%s\n' "${border}" "${top_rule}" "${reset}"
  printf '%s│%s' "${border}" "${reset}"
  ui_repeat ' ' "${inner_width}"
  printf '%s│%s\n' "${border}" "${reset}"

  printf '%s│%s  %s%s%s  %s' "${border}" "${reset}" "${accent}${bold}" "${title}" "${reset}" "${subtitle}"
  ui_repeat ' ' $((inner_width - 4 - ${#title} - 2 - ${#subtitle}))
  printf '  %s│%s\n' "${border}" "${reset}"

  printf '%s│%s      ' "${border}" "${reset}"
  ui_pad_right "${description}" $((inner_width - 6))
  printf '%s│%s\n' "${border}" "${reset}"

  printf '%s│%s' "${border}" "${reset}"
  ui_repeat ' ' "${inner_width}"
  printf '%s│%s\n' "${border}" "${reset}"

  printf '%s│%s  %s' "${border}" "${reset}" "${muted}"
  ui_pad_right "COMMAND" "${command_width}"
  printf '  '
  ui_pad_right "DESCRIPTION" "${description_width}"
  ui_repeat ' ' $((line_width - command_width - description_width - 2))
  printf '%s  %s│%s\n' "${reset}" "${border}" "${reset}"

  printf '%s│%s  %s%s%s  %s│%s\n' "${border}" "${reset}" "${muted}" "${separator}" "${reset}" "${border}" "${reset}"

  printf '%s\n' "${records}" | while IFS="$(printf '\t')" read -r category command row_description; do
    [ -n "${command}" ] || continue
    if [ "${category}" != "${current_category}" ]; then
      [ -z "${current_category}" ] || _ui_help_table_print_section "${border}" "${muted}" "${reset}" "${bold}" "" "${line_width}"
      _ui_help_table_print_section "${border}" "${muted}" "${reset}" "${bold}" "${category}" "${line_width}"
      current_category="${category}"
    fi
    _ui_help_table_print_row "${border}" "${muted}" "${reset}" "${category}" "${command}" "${row_description}" "${command_width}" "${description_width}" "${line_width}"
  done

  printf '%s│%s' "${border}" "${reset}"
  ui_repeat ' ' "${inner_width}"
  printf '%s│%s\n' "${border}" "${reset}"

  tip_prefix="${tip%%\`*}"
  tip_text="${tip#*\`}"
  tip_command="${tip_text%%\`*}"
  tip_suffix="${tip_text#*\`}"
  if [ "${tip_text}" = "${tip}" ]; then
    tip_prefix="${tip}"
    tip_command=""
    tip_suffix=""
  fi

  if [ "${count}" -eq 1 ] 2>/dev/null; then
    count_label="${count} command"
  else
    count_label="${count} commands"
  fi

  printf '%s│%s  %s%s%s%s%s%s' "${border}" "${reset}" "${muted}" "${tip_prefix}" "${reset}" "${accent}" "${tip_command}" "${reset}"
  printf '%s' "${muted}${tip_suffix}${reset}"
  ui_repeat ' ' $((inner_width - 4 - ${#tip_prefix} - ${#tip_command} - ${#tip_suffix} - ${#count_label}))
  printf '%s%s%s  %s│%s\n' "${muted}" "${count_label}" "${reset}" "${border}" "${reset}"

  printf '%s╰%s╯%s\n' "${border}" "${bottom_rule}" "${reset}"
}

ui_help_table() {
  local title subtitle description tip records
  title="$1"
  subtitle="$2"
  description="$3"
  tip="$4"
  records="$(cat)"

  if ui_is_tty; then
    _ui_help_table_tty "${title}" "${subtitle}" "${description}" "${tip}" "${records}"
  else
    printf '%s\n' "${records}" | _ui_help_table_plain
  fi
}
