#!/usr/bin/env bash
# Symlink dotfiles into ~/.config and append a one-line source hook to ~/.bashrc (or ~/.zshrc).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USE_ZSH=false
WITH_GIT=false
NO_APT=false
NVIM_APPIMAGE=false

for arg in "$@"; do
  case "$arg" in
    --zsh) USE_ZSH=true ;;
    --git) WITH_GIT=true ;;
    --no-apt) NO_APT=true ;;
    --nvim-appimage) NVIM_APPIMAGE=true ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0 [--zsh] [--git] [--no-apt] [--nvim-appimage]" >&2
      exit 1
      ;;
  esac
done

MARKER='# pb-configs dotfiles'
SOURCE_LINE="source \"${SCRIPT_DIR}/.terminal\""
NVIM_PATH_MARKER='# pb-configs: Neovim AppImage on PATH'

if [[ "$USE_ZSH" == true ]]; then
  RC_FILE="${HOME}/.zshrc"
else
  RC_FILE="${HOME}/.bashrc"
fi

install_apt_packages() {
  if [[ "$NO_APT" == true ]]; then
    return 0
  fi
  if [[ ! -f /etc/debian_version ]]; then
    return 0
  fi

  # Proxmox and some servers: logged in as root, no sudo. Desktops: usually non-root + sudo.
  local -a priv=()
  if [[ "$(id -u)" -eq 0 ]]; then
    priv=()
  elif command -v sudo &>/dev/null; then
    priv=(sudo)
  else
    echo "Skipping apt: not root and sudo not found (install packages manually or use --no-apt)." >&2
    return 0
  fi

  # neovim — .terminal aliases vim to nvim; .vimrc is for Neovim
  # bat — syntax-highlighted cat (.terminal); Debian binary is batcat
  # fzf — fuzzy finder (Ctrl-R / Ctrl-T); available on recent Debian/Ubuntu
  # xclip, wl-clipboard — clipboard for cwd alias (X11 and Wayland)
  # git, curl — vim-plug and :PlugInstall clone plugins
  # neovim omitted when --nvim-appimage (official AppImage under /opt/nvim)
  local packages=(bat fzf ripgrep xclip wl-clipboard git curl)
  if [[ "$NVIM_APPIMAGE" != true ]]; then
    packages=(neovim "${packages[@]}")
  fi

  if [[ "$WITH_GIT" == true ]]; then
    # .gitconfig uses credential.helper = libsecret on Linux
    packages+=(libsecret-tools libsecret-1-dev)
  fi

  if [[ ${#priv[@]} -eq 0 ]]; then
    echo "Running: apt-get update && apt-get install -y ${packages[*]} (as root)"
  else
    echo "Running: sudo apt-get update && sudo apt-get install -y ${packages[*]}"
  fi
  "${priv[@]}" apt-get update -qq
  if [[ ${#priv[@]} -eq 0 ]]; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
  else
    "${priv[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
  fi
}

install_nvim_appimage() {
  [[ "$NVIM_APPIMAGE" == true ]] || return 0
  if [[ "$(uname -s)" != Linux ]]; then
    echo "Neovim AppImage is Linux-only; skipped." >&2
    return 0
  fi

  local asset
  case "$(uname -m)" in
    x86_64) asset=nvim-linux-x86_64.appimage ;;
    aarch64|arm64) asset=nvim-linux-arm64.appimage ;;
    *)
      echo "Neovim AppImage: unsupported architecture $(uname -m); skipped." >&2
      return 0
      ;;
  esac

  if ! command -v curl &>/dev/null; then
    echo "Neovim AppImage: curl not found. Install curl or run without --no-apt." >&2
    return 0
  fi

  local -a priv=()
  if [[ "$(id -u)" -eq 0 ]]; then
    priv=()
  elif command -v sudo &>/dev/null; then
    priv=(sudo)
  else
    echo "Neovim AppImage: need root or sudo to install under /opt/nvim." >&2
    return 0
  fi

  local url work
  url="https://github.com/neovim/neovim/releases/latest/download/${asset}"
  work="$(mktemp -d)"
  echo "Downloading Neovim AppImage: ${url}"
  if ! curl -fL --retry 3 -o "${work}/${asset}" "${url}"; then
    rm -rf "${work}"
    echo "Neovim AppImage download failed." >&2
    return 0
  fi
  chmod u+x "${work}/${asset}"

  # Extract instead of running the AppImage directly — no FUSE (needed for many LXCs / minimal hosts).
  echo "Extracting AppImage to /opt/nvim (works without FUSE)..."
  if ! (cd "${work}" && "./${asset}" --appimage-extract); then
    rm -rf "${work}"
    echo "Neovim AppImage --appimage-extract failed." >&2
    return 0
  fi
  if [[ ! -f "${work}/squashfs-root/usr/bin/nvim" ]]; then
    rm -rf "${work}"
    echo "Neovim AppImage layout missing squashfs-root/usr/bin/nvim" >&2
    return 0
  fi

  if [[ ${#priv[@]} -eq 0 ]]; then
    rm -rf /opt/nvim
    mv "${work}/squashfs-root" /opt/nvim
  else
    "${priv[@]}" rm -rf /opt/nvim
    "${priv[@]}" mv "${work}/squashfs-root" /opt/nvim
  fi
  rm -rf "${work}"

  local path_line='export PATH="/opt/nvim/usr/bin:$PATH"'
  local tmpf
  if [[ -f "${RC_FILE}" ]] && grep -qF "${NVIM_PATH_MARKER}" "${RC_FILE}"; then
    if grep -qF "${path_line}" "${RC_FILE}"; then
      echo "Neovim PATH already uses /opt/nvim/usr/bin in ${RC_FILE}"
    elif grep -qF 'export PATH="/opt/nvim:$PATH"' "${RC_FILE}"; then
      tmpf="$(mktemp)"
      while IFS= read -r line || [[ -n "${line}" ]]; do
        if [[ "$line" == 'export PATH="/opt/nvim:$PATH"' ]]; then
          printf '%s\n' "${path_line}"
        else
          printf '%s\n' "$line"
        fi
      done <"${RC_FILE}" >"${tmpf}"
      mv "${tmpf}" "${RC_FILE}"
      echo "Updated ${RC_FILE} for extracted Neovim (was FUSE-style PATH)"
    else
      echo "Note: add to ${RC_FILE}: ${path_line}" >&2
    fi
  else
    {
      printf '\n%s\n' "${NVIM_PATH_MARKER}"
      printf '%s\n' "${path_line}"
    } >>"${RC_FILE}"
    echo "Appended PATH for /opt/nvim/usr/bin/nvim to ${RC_FILE}"
  fi
  echo "Neovim installed under /opt/nvim — open a new shell or: source ${RC_FILE}"
}

install_apt_packages
install_nvim_appimage

install_vim_plug() {
  local dest="${XDG_DATA_HOME:-${HOME}/.local/share}/nvim/site/autoload/plug.vim"
  if [[ -f "${dest}" ]]; then
    return 0
  fi
  if ! command -v curl &>/dev/null; then
    echo "Install curl, then re-run or fetch vim-plug manually — see README." >&2
    return 0
  fi
  echo "Installing vim-plug to ${dest}"
  mkdir -p "$(dirname "${dest}")"
  curl -fLo "${dest}" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

mkdir -p "${HOME}/.config"
ln -sf "${SCRIPT_DIR}/starship.toml" "${HOME}/.config/starship.toml"
mkdir -p "${HOME}/.config/nvim"
ln -sf "${SCRIPT_DIR}/.vimrc" "${HOME}/.config/nvim/init.vim"

install_vim_plug

if [[ "$WITH_GIT" == true ]]; then
  ln -sf "${SCRIPT_DIR}/.gitconfig" "${HOME}/.gitconfig"
fi

if [[ -f "$RC_FILE" ]] && grep -qF "$MARKER" "$RC_FILE"; then
  echo "Shell hook already present in ${RC_FILE}"
else
  {
    printf '\n%s\n%s\n' "$MARKER" "$SOURCE_LINE"
  } >>"$RC_FILE"
  echo "Appended source hook to ${RC_FILE}"
fi

echo "Symlinked starship.toml and nvim init.vim from ${SCRIPT_DIR}"
if [[ "$WITH_GIT" != true ]]; then
  echo "Tip: run with --git to symlink .gitconfig (skipped by default)."
fi
if [[ "$NO_APT" != true ]] && [[ -f /etc/debian_version ]]; then
  echo "Tip: install Starship with its curl script — see README."
fi
if command -v nvim &>/dev/null && [[ -f "${XDG_DATA_HOME:-${HOME}/.local/share}/nvim/site/autoload/plug.vim" ]]; then
  echo "Tip: run 'nvim +PlugInstall +qall' once to install plugins (needs git + network)."
fi
