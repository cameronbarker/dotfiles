#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --review-file <path> --preview-file <path> [--editor nvim|vim]" >&2
}

REVIEW_FILE=""
PREVIEW_FILE=""
EDITOR_BIN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --review-file)
      REVIEW_FILE="${2:-}"
      shift 2
      ;;
    --preview-file)
      PREVIEW_FILE="${2:-}"
      shift 2
      ;;
    --editor)
      EDITOR_BIN="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "${REVIEW_FILE}" || -z "${PREVIEW_FILE}" ]]; then
  usage
  exit 2
fi

if [[ ! -f "${REVIEW_FILE}" || ! -f "${PREVIEW_FILE}" ]]; then
  echo "review/preview file missing" >&2
  exit 2
fi

if [[ -z "${EDITOR_BIN}" ]]; then
  if command -v nvim >/dev/null 2>&1; then
    EDITOR_BIN="nvim"
  else
    EDITOR_BIN="vim"
  fi
fi

if ! command -v "${EDITOR_BIN}" >/dev/null 2>&1; then
  echo "editor not found: ${EDITOR_BIN}" >&2
  exit 2
fi

if [[ -z "${TMUX:-}" ]]; then
  echo "not running inside tmux" >&2
  exit 2
fi

# Open a right-hand pane for editable review.yaml and keep preview in current pane.
tmux split-window -h -c "#{pane_current_path}" "${EDITOR_BIN} '${REVIEW_FILE}'"
tmux send-keys -t ! "clear" C-m
tmux send-keys -t ! "echo 'Preview file: ${PREVIEW_FILE}'" C-m
tmux send-keys -t ! "echo 'Review file:  ${REVIEW_FILE}'" C-m
tmux send-keys -t ! "echo 'Use explicit approval fields in review.yaml before apply.'" C-m
