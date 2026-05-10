#!/usr/bin/env bash
# Reverse what install.sh added: symlinks, shell rc blocks, optional AppImage / Atuin / vim-plug / plugged.
# Does not remove apt packages (you may still want neovim, git, etc.).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WITH_GIT=false
REMOVE_APPIMAGE=false
REMOVE_VIM_PLUG=false
REMOVE_PLUGGED=false
REMOVE_ATUIN=false

for arg in "$@"; do
  case "$arg" in
    --git) WITH_GIT=true ;;
    --nvim-appimage) REMOVE_APPIMAGE=true ;;
    --vim-plug) REMOVE_VIM_PLUG=true ;;
    --plugged) REMOVE_PLUGGED=true ;;
    --atuin) REMOVE_ATUIN=true ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0 [--git] [--nvim-appimage] [--vim-plug] [--plugged] [--atuin]" >&2
      exit 1
      ;;
  esac
done

MARKER='# pb-configs dotfiles'
NVIM_PATH_MARKER='# pb-configs: Neovim AppImage on PATH'

remove_symlink_if_ours() {
  local link=$1 expected_target=$2
  if [[ ! -L "$link" ]]; then
    echo "Skip (not a symlink): $link"
    return 0
  fi
  local got
  got="$(readlink "$link")"
  if [[ "$got" == "$expected_target" ]]; then
    rm "$link"
    echo "Removed symlink $link"
  else
    echo "Skip $link (points elsewhere: $got)" >&2
  fi
}

strip_rc_blocks() {
  local f=$1
  [[ -f "$f" ]] || return 0
  local tmp
  tmp="$(mktemp)"
  while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ "$line" == "$MARKER" ]]; then
      if IFS= read -r next_line || true; then
        if [[ "$next_line" == "source \"${SCRIPT_DIR}/.terminal\"" ]]; then
          continue
        fi
        printf '%s\n' "$line" >>"$tmp"
        printf '%s\n' "$next_line" >>"$tmp"
      else
        printf '%s\n' "$line" >>"$tmp"
      fi
    elif [[ "$line" == "$NVIM_PATH_MARKER" ]]; then
      if IFS= read -r next_line || true; then
        if [[ "$next_line" == 'export PATH="/opt/nvim:$PATH"' ]] || [[ "$next_line" == 'export PATH="/opt/nvim/usr/bin:$PATH"' ]]; then
          continue
        fi
        printf '%s\n' "$line" >>"$tmp"
        printf '%s\n' "$next_line" >>"$tmp"
      else
        printf '%s\n' "$line" >>"$tmp"
      fi
    else
      printf '%s\n' "$line" >>"$tmp"
    fi
  done <"$f"
  if cmp -s "$tmp" "$f" 2>/dev/null; then
    rm -f "$tmp"
    echo "No matching install markers in $f"
  else
    mv "$tmp" "$f"
    echo "Removed install markers from $f"
  fi
}

remove_symlink_if_ours "${HOME}/.config/starship.toml" "${SCRIPT_DIR}/starship.toml"
remove_symlink_if_ours "${HOME}/.config/nvim/init.vim" "${SCRIPT_DIR}/.vimrc"
remove_symlink_if_ours "${HOME}/.screenrc" "${SCRIPT_DIR}/.screenrc"
remove_symlink_if_ours "${HOME}/.tmux.conf" "${SCRIPT_DIR}/.tmux.conf"
remove_symlink_if_ours "${HOME}/.codex/AGENTS.md" "${SCRIPT_DIR}/.codex/AGENTS.md"

if [[ "$WITH_GIT" == true ]]; then
  remove_symlink_if_ours "${HOME}/.gitconfig" "${SCRIPT_DIR}/.gitconfig"
fi

strip_rc_blocks "${HOME}/.bashrc"
strip_rc_blocks "${HOME}/.zshrc"

if [[ "$REMOVE_APPIMAGE" == true ]]; then
  if [[ "$(uname -s)" == Linux ]] && [[ -e /opt/nvim ]]; then
    if [[ "$(id -u)" -eq 0 ]]; then
      rm -rf /opt/nvim
      echo "Removed /opt/nvim"
    elif command -v sudo &>/dev/null; then
      sudo rm -rf /opt/nvim
      echo "Removed /opt/nvim"
    else
      echo "Cannot remove /opt/nvim: need root or sudo." >&2
    fi
  else
    echo "Skip: /opt/nvim not present or not Linux."
  fi
fi

if [[ "$REMOVE_VIM_PLUG" == true ]]; then
  plug="${XDG_DATA_HOME:-${HOME}/.local/share}/nvim/site/autoload/plug.vim"
  if [[ -f "$plug" ]]; then
    rm -f "$plug"
    echo "Removed $plug"
  else
    echo "Skip: vim-plug not at $plug"
  fi
fi

if [[ "$REMOVE_PLUGGED" == true ]]; then
  if [[ -d "${HOME}/.vim/plugged" ]]; then
    rm -rf "${HOME}/.vim/plugged"
    echo "Removed ~/.vim/plugged"
  fi
fi

if [[ "$REMOVE_ATUIN" == true ]]; then
  if [[ -d "${HOME}/.atuin" ]]; then
    rm -rf "${HOME}/.atuin"
    echo "Removed ~/.atuin"
  else
    echo "Skip: ~/.atuin not found"
  fi
  echo "Tip: remove ~/.bash-preexec.sh manually if you only used it for Atuin."
fi

echo "Done. Apt packages were not removed. Re-open your shell (or source ~/.bashrc)."
