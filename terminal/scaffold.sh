# shellcheck shell=bash

# -----------------------------------------------------------------------------
# Scaffolds
# -----------------------------------------------------------------------------

export PB_SCAFFOLDS_DIR="${PB_SCAFFOLDS_DIR:-${_PB_TERMINAL_DIR}/snippets/scaffolds}"

# shellcheck disable=SC2034
PB_DESC_scaffold="copy a named scaffold into a destination directory"
scaffold() {
  local force scaffold_name dest src base conflicts
  force=0
  dest="."

  case "${1:-}" in
    ""|--help|-h)
      echo "Usage: scaffold [--force] <name> [destination]"
      echo "       scaffold --list"
      return 0
      ;;
    --list|-l)
      if [ ! -d "${PB_SCAFFOLDS_DIR}" ]; then
        echo "Scaffold directory not found: ${PB_SCAFFOLDS_DIR}" >&2
        return 1
      fi
      find "${PB_SCAFFOLDS_DIR}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
      return 0
      ;;
    --force|-f)
      force=1
      shift
      ;;
  esac

  scaffold_name="${1:-}"
  dest="${2:-.}"

  if [ -z "${scaffold_name}" ]; then
    echo "Usage: scaffold [--force] <name> [destination]" >&2
    return 2
  fi

  src="${PB_SCAFFOLDS_DIR}/${scaffold_name}"

  if [ ! -d "${src}" ]; then
    echo "Unknown scaffold: ${scaffold_name}" >&2
    echo "Run 'scaffold --list' to see available scaffolds." >&2
    return 1
  fi

  if [ -e "${dest}" ] && [ ! -d "${dest}" ]; then
    echo "Destination exists and is not a directory: ${dest}" >&2
    return 1
  fi

  mkdir -p "${dest}"

  if [ "${force}" -ne 1 ]; then
    conflicts=""
    while IFS= read -r base; do
      if [ -e "${dest}/${base}" ]; then
        conflicts="${conflicts}${dest}/${base}
"
      fi
    done < <(find "${src}" -mindepth 1 -maxdepth 1 -exec basename {} \;)

    if [ -n "${conflicts}" ]; then
      echo "Refusing to overwrite existing files:" >&2
      printf "%s" "${conflicts}" >&2
      echo "Re-run with --force to overwrite." >&2
      return 1
    fi
  fi

  cp -R "${src}/." "${dest}/"
}
