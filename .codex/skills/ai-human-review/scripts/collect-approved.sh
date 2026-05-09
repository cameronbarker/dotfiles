#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --review-file <path> [--format json]" >&2
}

REVIEW_FILE=""
FORMAT="json"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --review-file)
      REVIEW_FILE="${2:-}"
      shift 2
      ;;
    --format)
      FORMAT="${2:-}"
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

if [[ "${FORMAT}" != "json" ]]; then
  echo "unsupported format: ${FORMAT}" >&2
  exit 2
fi

if ! command -v ruby >/dev/null 2>&1; then
  echo "ruby is required for YAML parsing" >&2
  exit 20
fi

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
    STDERR.puts("approved_by is required")
    exit 20
  end
  unless approved_at.is_a?(String) && approved_at.match?(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/)
    STDERR.puts("approved_at must be ISO8601 UTC, e.g. 2026-05-08T22:15:00Z")
    exit 20
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

  approved_items = items.select { |it| it["approved"] == true }
  if approved_items.empty?
    exit 10
  end

  result = {
    run_id: data["run_id"],
    approved_by: approved_by,
    approved_at: approved_at,
    approved_count: approved_items.length,
    items: approved_items
  }
  puts JSON.generate(result)
' "${REVIEW_FILE}"
