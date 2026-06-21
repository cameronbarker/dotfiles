#!/usr/bin/env bash
# Download and install dotfiles from a GitHub archive (no git/gh required).
set -euo pipefail

readonly REPO="cameronbarker/dotfiles"
readonly DEFAULT_REF="main"

REF="${DEFAULT_REF}"
SHA256=""
NO_VERIFY=false
KEEP=false
CLONE=false

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [OPTIONS]

Download cameronbarker/dotfiles from GitHub and run install.sh.
Requires only bash, curl, tar, and CA certificates (no git or gh).

Options:
  --ref REF       Branch, tag, or commit SHA (default: main)
  --sha256 HASH   Verify downloaded archive against SHA-256 hex digest
  --no-verify     Skip SHA-256 verification (required if --sha256 omitted)
  --keep          Preserve the temporary download directory on exit
  --clone         After install, clone the repo to ~/.dotfiles when git exists
  -h, --help      Show this help

Verification:
  Without --sha256 you must pass --no-verify (fail closed), except when
  piped from curl with no arguments (then --no-verify is assumed with a warning).

Examples:
  curl -fsSL https://raw.githubusercontent.com/cameronbarker/dotfiles/main/bootstrap.sh | bash
  curl -fsSL .../bootstrap.sh | bash -s -- --ref v1.0.0 --sha256 <hash>
EOF
}

die() {
  echo "bootstrap.sh: $*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)
      [[ $# -ge 2 ]] || die "--ref requires a value"
      REF="$2"
      shift 2
      ;;
    --sha256)
      [[ $# -ge 2 ]] || die "--sha256 requires a value"
      SHA256="$2"
      shift 2
      ;;
    --no-verify) NO_VERIFY=true; shift ;;
    --keep) KEEP=true; shift ;;
    --clone) CLONE=true; shift ;;
    -h | --help)
      usage
      exit 0
      ;;
    --) shift; break ;;
    -*)
      die "unknown option: $1 (try --help)"
      ;;
    *)
      die "unexpected argument: $1 (try --help)"
      ;;
  esac
done

# curl | bash one-liner: piped install with no flags (same UX as codex/install.sh).
if [[ $# -eq 0 && ! -t 0 && -z "${SHA256}" && "${NO_VERIFY}" != true ]]; then
  NO_VERIFY=true
fi

if [[ -z "${SHA256}" && "${NO_VERIFY}" != true ]]; then
  die "refusing to install without verification: pass --sha256 HASH or --no-verify"
fi

if [[ "${NO_VERIFY}" == true && ( "${REF}" == "main" || "${REF}" == "master" ) ]]; then
  cat >&2 <<'EOF'
WARNING: Installing from a mutable branch (main/master) without --sha256.
The archive contents can change at any time; this is not reproducible.
Prefer a tagged release with an explicit --sha256 digest when you can.
EOF
fi

apt_install() {
  local -a priv=()
  if [[ "$(id -u)" -eq 0 ]]; then
    priv=()
  elif command -v sudo >/dev/null 2>&1; then
    priv=(sudo)
  else
    return 1
  fi

  "${priv[@]}" apt-get update -qq
  if [[ ${#priv[@]} -eq 0 ]]; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
  else
    "${priv[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
  fi
}

ensure_minimal_deps() {
  local need_apt=()

  command -v curl >/dev/null 2>&1 || need_apt+=(curl)
  command -v tar >/dev/null 2>&1 || need_apt+=(tar)

  if [[ -f /etc/debian_version ]] && command -v apt-get >/dev/null 2>&1; then
    if [[ ${#need_apt[@]} -gt 0 ]]; then
      echo "Installing missing packages: ${need_apt[*]} ca-certificates"
      apt_install "${need_apt[@]}" ca-certificates || die "failed to install: ${need_apt[*]} ca-certificates"
    elif [[ ! -f /etc/ssl/certs/ca-certificates.crt && ! -d /etc/ssl/certs ]]; then
      echo "Installing ca-certificates"
      apt_install ca-certificates || die "failed to install ca-certificates"
    fi
  fi

  command -v curl >/dev/null 2>&1 || die "curl is required"
  command -v tar >/dev/null 2>&1 || die "tar is required"
}

archive_url_for_ref() {
  local ref="$1"
  local path="${ref}"

  case "${ref}" in
    refs/heads/* | refs/tags/*) ;;
    *)
      if [[ "${ref}" =~ ^[0-9a-fA-F]{7,40}$ ]]; then
        path="${ref}"
      fi
      ;;
  esac

  printf 'https://github.com/%s/archive/%s.tar.gz' "${REPO}" "${path}"
}

verify_archive_sha256() {
  local file="$1"
  local expected="$2"
  local actual=""

  expected="$(printf '%s' "${expected}" | tr '[:upper:]' '[:lower:]')"
  if [[ ! "${expected}" =~ ^[0-9a-f]{64}$ ]]; then
    die "--sha256 must be a 64-character hex digest"
  fi

  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "${file}" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "${file}" | awk '{print $1}')"
  else
    die "no SHA-256 tool found (need sha256sum or shasum -a 256)"
  fi

  if [[ "${actual}" != "${expected}" ]]; then
    die "SHA-256 mismatch (expected ${expected}, got ${actual})"
  fi
  echo "SHA-256 verified: ${actual}"
}

TEMP_DIR=""
ARCHIVE_PATH=""
EXTRACT_DIR=""
CLEANED_UP=false

on_exit() {
  if [[ "${CLEANED_UP}" == true ]]; then
    return 0
  fi
  CLEANED_UP=true

  if [[ "${KEEP}" == true && -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
    echo "Kept temporary directory: ${TEMP_DIR}" >&2
    return 0
  fi
  if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
    rm -rf "${TEMP_DIR}"
    TEMP_DIR=""
  fi
}

trap on_exit EXIT
trap 'on_exit; exit 130' INT
trap 'on_exit; exit 143' TERM

ensure_minimal_deps

TEMP_DIR="$(mktemp -d)"
ARCHIVE_PATH="${TEMP_DIR}/dotfiles.tar.gz"
EXTRACT_DIR="${TEMP_DIR}/extract"
mkdir -p "${EXTRACT_DIR}"

url="$(archive_url_for_ref "${REF}")"
echo "Downloading ${url}"
if ! curl --fail --location --retry 3 --connect-timeout 30 \
  --proto '=https' --tlsv1.2 \
  -o "${ARCHIVE_PATH}" "${url}"; then
  die "download failed for ref ${REF}"
fi

if [[ -n "${SHA256}" ]]; then
  verify_archive_sha256 "${ARCHIVE_PATH}" "${SHA256}"
fi

echo "Extracting archive"
if ! tar -xzf "${ARCHIVE_PATH}" -C "${EXTRACT_DIR}" --strip-components=1; then
  die "failed to extract archive"
fi

if [[ ! -f "${EXTRACT_DIR}/install.sh" ]]; then
  die "install.sh not found in extracted archive (ref ${REF}?)"
fi

echo "Running install.sh from extracted tree"
bash "${EXTRACT_DIR}/install.sh"

clone_dotfiles_repo() {
  local dest="${HOME}/.dotfiles"

  if ! command -v git >/dev/null 2>&1; then
    echo "Warning: --clone requested but git is not available; skipping." >&2
    return 0
  fi

  local staging
  staging="$(mktemp -d)"
  if ! git clone --depth 1 "https://github.com/${REPO}.git" "${staging}/repo"; then
    rm -rf "${staging}"
    echo "Warning: git clone failed; leaving non-git install in ${dest}." >&2
    return 0
  fi

  rm -rf "${dest}"
  mv "${staging}/repo" "${dest}"
  rm -rf "${staging}"

  echo "Cloned ${REPO} to ${dest}; re-running install.sh"
  bash "${dest}/install.sh"
}

if [[ "${CLONE}" == true ]]; then
  clone_dotfiles_repo
fi