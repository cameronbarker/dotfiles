#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --review-file <path> [--timeout-sec <n>] [--poll-sec <n>]" >&2
}

REVIEW_FILE=""
TIMEOUT_SEC=1800
POLL_SEC=2

while [[ $# -gt 0 ]]; do
  case "$1" in
    --review-file)
      REVIEW_FILE="${2:-}"
      shift 2
      ;;
    --timeout-sec)
      TIMEOUT_SEC="${2:-}"
      shift 2
      ;;
    --poll-sec)
      POLL_SEC="${2:-}"
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

if [[ -z "${REVIEW_FILE}" || ! -f "${REVIEW_FILE}" ]]; then
  usage
  exit 2
fi

if ! command -v ruby >/dev/null 2>&1; then
  echo "ruby is required for YAML parsing" >&2
  exit 20
fi

START_EPOCH="$(date +%s)"

validate_review() {
  ruby -ryaml -rjson -e '
    p = ARGV[0]
    data = YAML.safe_load(File.read(p), permitted_classes: [], aliases: false)
    unless data.is_a?(Hash)
      STDERR.puts("review.yaml must be a mapping")
      exit 20
    end

    approved_by = data["approved_by"]
    approved_at = data["approved_at"]
    items = data["items"]

    unless approved_by.is_a?(String) && !approved_by.strip.empty?
      exit 1
    end
    unless approved_at.is_a?(String) && approved_at.match?(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/)
      exit 1
    end
    unless items.is_a?(Array)
      STDERR.puts("items must be an array")
      exit 20
    end

    invalid_item = items.find { |it| !it.is_a?(Hash) || !it.key?("id") || !it.key?("approved") }
    if invalid_item
      STDERR.puts("each item must include id and approved")
      exit 20
    end

    approved_count = items.count { |it| it["approved"] == true }
    if approved_count == 0
      exit 10
    end

    puts({status: "approved", approved_count: approved_count}.to_json)
  ' "${REVIEW_FILE}"
}

while true; do
  NOW_EPOCH="$(date +%s)"
  ELAPSED=$((NOW_EPOCH - START_EPOCH))

  if [[ "${ELAPSED}" -ge "${TIMEOUT_SEC}" ]]; then
    echo "approval wait timed out" >&2
    exit 30
  fi

  set +e
  OUT="$(validate_review 2>/tmp/ai-human-review-validate.err)"
  CODE=$?
  set -e

  case "${CODE}" in
    0)
      printf '%s\n' "${OUT}"
      exit 0
      ;;
    1|10)
      sleep "${POLL_SEC}"
      ;;
    20)
      cat /tmp/ai-human-review-validate.err >&2 || true
      exit 20
      ;;
    *)
      sleep "${POLL_SEC}"
      ;;
  esac
done
