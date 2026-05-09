#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --out-dir <dir> [--run-id <id>] [--context <text>]" >&2
}

OUT_DIR=""
RUN_ID=""
CONTEXT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out-dir)
      OUT_DIR="${2:-}"
      shift 2
      ;;
    --run-id)
      RUN_ID="${2:-}"
      shift 2
      ;;
    --context)
      CONTEXT="${2:-}"
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

if [[ -z "${OUT_DIR}" ]]; then
  usage
  exit 2
fi

if [[ -z "${RUN_ID}" ]]; then
  RUN_ID="run-$(date -u +%Y%m%dT%H%M%SZ)-$RANDOM"
fi

RUN_DIR="${OUT_DIR%/}/${RUN_ID}"
mkdir -p "${RUN_DIR}"

REVIEW_FILE="${RUN_DIR}/review.yaml"
PREVIEW_FILE="${RUN_DIR}/preview.md"
STATUS_FILE="${RUN_DIR}/status.json"

cat > "${REVIEW_FILE}" <<YAML
run_id: "${RUN_ID}"
created_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
context: "${CONTEXT//\"/\'}"
approved_by: ""
approved_at: ""
items: []
YAML

cat > "${PREVIEW_FILE}" <<MD
# Review Preview

Run ID: ${RUN_ID}

No items added yet. Populate \`review.yaml\` items and this preview from your domain workflow.
MD

cat > "${STATUS_FILE}" <<JSON
{
  "run_id": "${RUN_ID}",
  "state": "draft",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "review_file": "${REVIEW_FILE}",
  "preview_file": "${PREVIEW_FILE}"
}
JSON

printf '{"run_id":"%s","run_dir":"%s","review_file":"%s","preview_file":"%s","status_file":"%s"}\n' \
  "${RUN_ID}" "${RUN_DIR}" "${REVIEW_FILE}" "${PREVIEW_FILE}" "${STATUS_FILE}"
