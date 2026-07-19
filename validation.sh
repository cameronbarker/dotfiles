#!/usr/bin/env bash
# Post-install health check: symlinks, shell hooks, and expected tools.
# Mirrors what install.sh installs/connects (pass matching --flags if you skipped pieces).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WITH_GIT=false
EXPECT_ATUIN=true
EXPECT_TAILSCALE=true
EXPECT_NVIM_APPIMAGE=true
EXPECT_APT=true
EXPECT_PLUG=true

for arg in "$@"; do
  case "$arg" in
    --git) WITH_GIT=true ;;
    --no-atuin) EXPECT_ATUIN=false ;;
    --no-tailscale) EXPECT_TAILSCALE=false ;;
    --no-nvim-appimage) EXPECT_NVIM_APPIMAGE=false ;;
    --no-apt) EXPECT_APT=false ;;
    --no-plug-install) EXPECT_PLUG=false ;;
    -h|--help)
      cat <<EOF
Usage: $0 [options]

Check that install.sh outputs are present and linked to this repo.

Options (match install.sh skips):
  --git                 Require ~/.gitconfig symlink
  --no-atuin            Skip Atuin checks
  --no-tailscale        Skip Tailscale checks
  --no-nvim-appimage    Do not require /opt/nvim (any nvim in PATH is OK)
  --no-apt              Soft-warn missing Debian apt packages instead of fail
  --no-plug-install     Skip vim-plug / plugged plugin checks
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0 [--git] [--no-atuin] [--no-tailscale] [--no-nvim-appimage] [--no-apt] [--no-plug-install]" >&2
      exit 1
      ;;
  esac
done

MARKER='# pb-configs dotfiles'
NVIM_PATH_MARKER='# pb-configs: Neovim AppImage on PATH'
SOURCE_LINE="source \"${SCRIPT_DIR}/.terminal\""
OS="$(uname -s)"
IS_DEBIAN=false
[[ -f /etc/debian_version ]] && IS_DEBIAN=true

PASS=0
FAIL=0
WARN=0
SKIP=0

if [[ -t 1 ]]; then
  C_OK=$'\033[32m'
  C_FAIL=$'\033[31m'
  C_WARN=$'\033[33m'
  C_SKIP=$'\033[90m'
  C_RST=$'\033[0m'
else
  C_OK='' C_FAIL='' C_WARN='' C_SKIP='' C_RST=''
fi

ok()   { PASS=$((PASS + 1)); printf '%sPASS%s  %s\n' "${C_OK}" "${C_RST}" "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '%sFAIL%s  %s\n' "${C_FAIL}" "${C_RST}" "$1"; }
warn() { WARN=$((WARN + 1)); printf '%sWARN%s  %s\n' "${C_WARN}" "${C_RST}" "$1"; }
skip() { SKIP=$((SKIP + 1)); printf '%sSKIP%s  %s\n' "${C_SKIP}" "${C_RST}" "$1"; }

section() {
  printf '\n== %s ==\n' "$1"
}

# True if link exists and resolves to expected (exact or canonical).
symlink_points_to() {
  local link=$1 expected=$2
  [[ -L "${link}" ]] || return 1
  local got
  got="$(readlink "${link}")"
  [[ "${got}" == "${expected}" ]] && return 0
  if command -v realpath >/dev/null 2>&1; then
    local got_r exp_r
    got_r="$(realpath "${link}" 2>/dev/null || true)"
    exp_r="$(realpath "${expected}" 2>/dev/null || true)"
    [[ -n "${got_r}" && -n "${exp_r}" && "${got_r}" == "${exp_r}" ]] && return 0
  fi
  return 1
}

check_symlink() {
  local link=$1 expected=$2 label=${3:-$1}
  if [[ ! -e "${expected}" && ! -L "${expected}" ]]; then
    fail "${label}: repo source missing (${expected})"
    return
  fi
  if [[ ! -e "${link}" && ! -L "${link}" ]]; then
    fail "${label}: missing (${link})"
    return
  fi
  if [[ ! -L "${link}" ]]; then
    fail "${label}: exists but is not a symlink (${link})"
    return
  fi
  if symlink_points_to "${link}" "${expected}"; then
    ok "${label} → ${expected}"
  else
    fail "${label}: points to $(readlink "${link}") (expected ${expected})"
  fi
}

check_cmd() {
  local name=$1
  local severity=${2:-fail} # fail | warn
  local extra=${3:-}
  if command -v "${name}" >/dev/null 2>&1; then
    ok "${name}: $(command -v "${name}")${extra:+ (${extra})}"
    return 0
  fi
  if [[ "${severity}" == warn ]]; then
    warn "${name}: not found in PATH"
  else
    fail "${name}: not found in PATH"
  fi
  return 0
}

check_cmd_any() {
  local label=$1
  shift
  local c
  for c in "$@"; do
    if command -v "${c}" >/dev/null 2>&1; then
      ok "${label}: $(command -v "${c}")"
      return 0
    fi
  done
  fail "${label}: none of [$*] found in PATH"
  return 0
}

check_file() {
  local path=$1 label=${2:-$1}
  if [[ -f "${path}" ]]; then
    ok "${label}"
  else
    fail "${label}: missing (${path})"
  fi
}

# --- Symlinks ---
section "Symlinks"

check_symlink "${HOME}/.config/starship.toml" "${SCRIPT_DIR}/starship.toml" "starship.toml"
check_symlink "${HOME}/.config/nvim/init.vim" "${SCRIPT_DIR}/.vimrc" "nvim init.vim"
check_symlink "${HOME}/.screenrc" "${SCRIPT_DIR}/.screenrc" ".screenrc"
check_symlink "${HOME}/.tmux.conf" "${SCRIPT_DIR}/.tmux.conf" ".tmux.conf"

if [[ -f "${SCRIPT_DIR}/.codex/AGENTS.md" ]]; then
  check_symlink "${HOME}/.codex/AGENTS.md" "${SCRIPT_DIR}/.codex/AGENTS.md" "Codex AGENTS.md"
else
  skip "Codex AGENTS.md: not in this clone"
fi

if [[ -d "${SCRIPT_DIR}/.codex/skills" ]]; then
  local_skill_count=0
  for src in "${SCRIPT_DIR}/.codex/skills"/*; do
    [[ -d "${src}" && -f "${src}/SKILL.md" ]] || continue
    name="$(basename "${src}")"
    check_symlink "${HOME}/.codex/skills/${name}" "${src}" "Codex skill ${name}"
    local_skill_count=$((local_skill_count + 1))
  done
  if [[ "${local_skill_count}" -eq 0 ]]; then
    skip "Codex skills: none with SKILL.md in repo"
  fi
else
  skip "Codex skills: not in this clone"
fi

if [[ -d "${SCRIPT_DIR}/.claude" ]]; then
  for item in CLAUDE.md settings.json rules skills agents; do
    src="${SCRIPT_DIR}/.claude/${item}"
    [[ -e "${src}" ]] || continue
    check_symlink "${HOME}/.claude/${item}" "${src}" "Claude ${item}"
  done
else
  skip "Claude config: not in this clone"
fi

if [[ "${WITH_GIT}" == true ]]; then
  check_symlink "${HOME}/.gitconfig" "${SCRIPT_DIR}/.gitconfig" ".gitconfig"
else
  if [[ -L "${HOME}/.gitconfig" ]] && symlink_points_to "${HOME}/.gitconfig" "${SCRIPT_DIR}/.gitconfig"; then
    ok ".gitconfig → ${SCRIPT_DIR}/.gitconfig (optional; linked)"
  else
    skip ".gitconfig: not required (pass --git to require)"
  fi
fi

# --- Shell hooks ---
section "Shell hooks"

RC_FILE="${HOME}/.zshrc"
if [[ ! -f "${RC_FILE}" ]]; then
  fail "$HOME/.zshrc missing"
else
  if grep -qF "${MARKER}" "${RC_FILE}" && grep -qF "${SOURCE_LINE}" "${RC_FILE}"; then
    ok "$HOME/.zshrc has pb-configs marker + source ${SCRIPT_DIR}/.terminal"
  elif grep -qF "${MARKER}" "${RC_FILE}"; then
    fail "$HOME/.zshrc has marker but source line mismatch (expected: ${SOURCE_LINE})"
  else
    fail "$HOME/.zshrc missing pb-configs source hook"
  fi
fi

if [[ -f "${HOME}/.bashrc" ]] && grep -qF "${MARKER}" "${HOME}/.bashrc"; then
  warn "$HOME/.bashrc still has pb-configs marker (install.sh should strip it; zsh-only)"
else
  ok "$HOME/.bashrc has no pb-configs hook (zsh-only)"
fi

if [[ ! -f "${SCRIPT_DIR}/.terminal" ]]; then
  fail "Repo .terminal missing"
else
  ok "Repo .terminal present"
  if bash -n "${SCRIPT_DIR}/.terminal" 2>/dev/null; then
    ok ".terminal syntax (bash -n)"
  else
    fail ".terminal failed bash -n"
  fi
fi

# --- Neovim ---
section "Neovim"

if command -v nvim >/dev/null 2>&1; then
  ok "nvim: $(command -v nvim)"
elif [[ -x /opt/nvim/usr/bin/nvim ]]; then
  ok "nvim: /opt/nvim/usr/bin/nvim (not yet on PATH in this shell)"
else
  fail "nvim: not found"
fi

if [[ "${OS}" == Linux ]]; then
  if [[ "${EXPECT_NVIM_APPIMAGE}" == true ]]; then
    if [[ -x /opt/nvim/usr/bin/nvim ]]; then
      ok "Neovim AppImage extract: /opt/nvim/usr/bin/nvim"
    else
      fail "Neovim AppImage extract missing (/opt/nvim/usr/bin/nvim)"
    fi
    if [[ -f "${RC_FILE}" ]] && grep -qF "${NVIM_PATH_MARKER}" "${RC_FILE}" && \
      grep -qF 'export PATH="/opt/nvim/usr/bin:$PATH"' "${RC_FILE}"; then
      ok "$HOME/.zshrc Neovim PATH marker (/opt/nvim/usr/bin)"
    elif [[ -f "${RC_FILE}" ]] && grep -qF "${NVIM_PATH_MARKER}" "${RC_FILE}"; then
      warn "$HOME/.zshrc has Neovim PATH marker but not export PATH=\"/opt/nvim/usr/bin:\$PATH\""
    else
      fail "$HOME/.zshrc missing Neovim AppImage PATH block"
    fi
  else
    skip "Neovim AppImage checks (--no-nvim-appimage)"
  fi
else
  skip "Neovim AppImage: Linux-only (OS=${OS})"
fi

plug_vim="${XDG_DATA_HOME:-${HOME}/.local/share}/nvim/site/autoload/plug.vim"
if [[ "${EXPECT_PLUG}" == true ]]; then
  check_file "${plug_vim}" "vim-plug (plug.vim)"
  if [[ -d "${HOME}/.vim/plugged" ]] && [[ -n "$(ls -A "${HOME}/.vim/plugged" 2>/dev/null || true)" ]]; then
    ok "Neovim plugins: ~/.vim/plugged"
  else
    warn "Neovim plugins: ~/.vim/plugged empty/missing (run: nvim --headless +PlugInstall +qall)"
  fi
else
  skip "vim-plug / plugged (--no-plug-install)"
fi

# --- Prompt / history / VPN ---
section "Prompt, history, VPN"

if [[ -d "${HOME}/.local/bin" ]]; then
  ok "$HOME/.local/bin exists"
else
  warn "$HOME/.local/bin missing (Starship often installs here)"
fi

check_cmd starship

if [[ "${EXPECT_ATUIN}" == true ]]; then
  if command -v atuin >/dev/null 2>&1; then
    ok "atuin: $(command -v atuin)"
  elif [[ -x "${HOME}/.atuin/bin/atuin" ]]; then
    ok "atuin: ${HOME}/.atuin/bin/atuin"
  else
    fail "atuin: not found (PATH or ~/.atuin/bin)"
  fi
else
  skip "Atuin (--no-atuin)"
fi

if [[ "${EXPECT_TAILSCALE}" == true ]]; then
  if command -v tailscale >/dev/null 2>&1; then
    ok "tailscale: $(command -v tailscale)"
    if tailscale status >/dev/null 2>&1; then
      ok "tailscale: authenticated (status OK)"
    else
      warn "tailscale: installed but not up (run: tailscale up)"
    fi
  else
    warn "tailscale: not found in PATH"
  fi
else
  skip "Tailscale (--no-tailscale)"
fi

# --- Shell / directory jump ---
section "Shell & navigation"

check_cmd zsh
if [[ "${SHELL:-}" == *zsh* ]]; then
  ok "Login SHELL is zsh (${SHELL})"
else
  warn "Login SHELL is '${SHELL:-unset}' (expected zsh; containers often cannot chsh)"
fi

if [[ -f "${HOME}/.zsh-z/zsh-z.plugin.zsh" ]]; then
  ok "zsh-z plugin: ~/.zsh-z"
else
  fail "zsh-z plugin missing (~/.zsh-z/zsh-z.plugin.zsh)"
fi

# --- CLI tools (apt on Debian; elsewhere soft) ---
section "CLI tools"

apt_severity=fail
if [[ "${EXPECT_APT}" != true ]] || [[ "${IS_DEBIAN}" != true ]]; then
  apt_severity=warn
  if [[ "${IS_DEBIAN}" != true ]]; then
    skip "Debian apt package strictness (OS not Debian/Ubuntu; warnings only)"
  elif [[ "${EXPECT_APT}" != true ]]; then
    skip "Debian apt strictness (--no-apt; warnings only)"
  fi
fi

check_cmd git "${apt_severity}"
check_cmd curl "${apt_severity}"
check_cmd fzf "${apt_severity}"
check_cmd rg "${apt_severity}"
check_cmd zoxide "${apt_severity}"
check_cmd screen "${apt_severity}"
check_cmd tmux "${apt_severity}"
check_cmd jq "${apt_severity}"
check_cmd rsync "${apt_severity}"
check_cmd_any "bat (or batcat)" bat batcat

if [[ "${OS}" == Linux ]]; then
  check_cmd moor warn
else
  skip "moor: Linux install path only (OS=${OS})"
fi

if [[ "${IS_DEBIAN}" == true ]] && [[ "${WITH_GIT}" == true ]]; then
  check_cmd secret-tool warn
fi

# --- Summary ---
section "Summary"
printf 'pass=%d  fail=%d  warn=%d  skip=%d\n' "${PASS}" "${FAIL}" "${WARN}" "${SKIP}"

if [[ "${FAIL}" -gt 0 ]]; then
  printf '\n%sValidation failed.%s Fix the FAIL lines (or re-run ./install.sh), then ./validation.sh again.\n' "${C_FAIL}" "${C_RST}"
  exit 1
fi

printf '\n%sValidation passed.%s' "${C_OK}" "${C_RST}"
if [[ "${WARN}" -gt 0 ]]; then
  printf ' (%d warning(s) — review WARN lines)\n' "${WARN}"
else
  printf '\n'
fi
exit 0
