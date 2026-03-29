#!/usr/bin/env bash
# Symlink dotfiles into ~/.config and append a one-line source hook to ~/.bashrc (or ~/.zshrc).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USE_ZSH=false
WITH_GIT=false
NO_APT=false

for arg in "$@"; do
  case "$arg" in
    --zsh) USE_ZSH=true ;;
    --git) WITH_GIT=true ;;
    --no-apt) NO_APT=true ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0 [--zsh] [--git] [--no-apt]" >&2
      exit 1
      ;;
  esac
done

MARKER='# pb-configs dotfiles'
SOURCE_LINE="source \"${SCRIPT_DIR}/.terminal\""

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
  local packages=(neovim bat fzf xclip wl-clipboard git curl)

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

install_apt_packages

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
