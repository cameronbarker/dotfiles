#!/usr/bin/env bash
# Symlink dotfiles into ~/.config, install zsh, create ~/.zshrc, and append a source hook.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WITH_GIT=false
NO_APT=false
# On Linux, Neovim comes from the official extracted AppImage under /opt/nvim (no FUSE).
NVIM_APPIMAGE=true
# Atuin shell history binary; hooks live in .terminal, not duplicated in rc.
ATUIN_INSTALL=true
# Tailscale VPN client only; authenticate per machine with: tailscale up
TAILSCALE_INSTALL=true
# vim-plug plugins via headless Neovim (needs git + network on first run).
NVIM_PLUG_INSTALL=true

for arg in "$@"; do
  case "$arg" in
    --git) WITH_GIT=true ;;
    --no-apt) NO_APT=true ;;
    --no-nvim-appimage) NVIM_APPIMAGE=false ;;
    --nvim-appimage) ;; # default; kept for old scripts / docs
    --no-atuin) ATUIN_INSTALL=false ;;
    --no-tailscale) TAILSCALE_INSTALL=false ;;
    --no-plug-install) NVIM_PLUG_INSTALL=false ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0 [--git] [--no-apt] [--no-nvim-appimage] [--no-plug-install] [--no-atuin] [--no-tailscale]" >&2
      exit 1
      ;;
  esac
done

# Archive/bootstrap installs extract to a temp dir; publish to ~/.dotfiles so symlinks survive cleanup.
publish_from_extract_if_needed() {
  if [[ -d "${SCRIPT_DIR}/.git" ]]; then
    return 0
  fi
  if [[ -n "${DOTFILES_SKIP_PUBLISH:-}" ]]; then
    return 0
  fi

  local publish_dir="${HOME}/.dotfiles"
  if [[ -d "${publish_dir}/.git" ]]; then
    return 0
  fi
  if [[ "${SCRIPT_DIR}" == "${publish_dir}" ]]; then
    return 0
  fi

  echo "Publishing dotfiles from archive extract to ${publish_dir}..."
  mkdir -p "${publish_dir}"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "${SCRIPT_DIR}/" "${publish_dir}/"
  else
    cp -a "${SCRIPT_DIR}/." "${publish_dir}/"
  fi

  export DOTFILES_SKIP_PUBLISH=1
  exec bash "${publish_dir}/install.sh" "$@"
}

publish_from_extract_if_needed "$@"

MARKER='# pb-configs dotfiles'
SOURCE_LINE="source \"${SCRIPT_DIR}/.terminal\""
NVIM_PATH_MARKER='# pb-configs: Neovim AppImage on PATH'
RC_FILE="${HOME}/.zshrc"
BASH_RC_FILE="${HOME}/.bashrc"
LOCAL_BIN="${HOME}/.local/bin"

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

install_zsh() {
  if command -v zsh &>/dev/null; then
    echo "zsh already available: $(command -v zsh)"
    return 0
  fi

  local -a priv=()

  if [[ -f /etc/debian_version ]] && command -v apt-get &>/dev/null; then
    if [[ "$(id -u)" -eq 0 ]]; then
      priv=()
    elif command -v sudo &>/dev/null; then
      priv=(sudo)
    else
      echo "Skipping zsh install: not root and sudo not found." >&2
      return 0
    fi
    echo "Installing zsh via apt..."
    "${priv[@]}" apt-get update -qq
    if [[ ${#priv[@]} -eq 0 ]]; then
      DEBIAN_FRONTEND=noninteractive apt-get install -y zsh
    else
      "${priv[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y zsh
    fi
  elif [[ "$(uname -s)" == Darwin ]] && command -v brew &>/dev/null; then
    echo "Installing zsh via Homebrew..."
    brew install zsh
  elif command -v dnf &>/dev/null; then
    if [[ "$(id -u)" -eq 0 ]]; then
      priv=()
    elif command -v sudo &>/dev/null; then
      priv=(sudo)
    else
      echo "Skipping zsh install: not root and sudo not found." >&2
      return 0
    fi
    echo "Installing zsh via dnf..."
    "${priv[@]}" dnf install -y zsh
  elif command -v yum &>/dev/null; then
    if [[ "$(id -u)" -eq 0 ]]; then
      priv=()
    elif command -v sudo &>/dev/null; then
      priv=(sudo)
    else
      echo "Skipping zsh install: not root and sudo not found." >&2
      return 0
    fi
    echo "Installing zsh via yum..."
    "${priv[@]}" yum install -y zsh
  elif command -v apk &>/dev/null; then
    if [[ "$(id -u)" -eq 0 ]]; then
      priv=()
    elif command -v sudo &>/dev/null; then
      priv=(sudo)
    else
      echo "Skipping zsh install: not root and sudo not found." >&2
      return 0
    fi
    echo "Installing zsh via apk..."
    "${priv[@]}" apk add --no-cache zsh
  else
    echo "Could not install zsh automatically. Install zsh manually, then re-run install.sh." >&2
    return 0
  fi

  if command -v zsh &>/dev/null; then
    echo "Installed zsh: $(command -v zsh)"
  else
    echo "zsh install attempted but zsh not found in PATH." >&2
  fi
}

ensure_zshrc() {
  if [[ ! -f "${RC_FILE}" ]]; then
    {
      printf '# ~/.zshrc — pb-configs dotfiles (managed by install.sh)\n'
    } >"${RC_FILE}"
    echo "Created ${RC_FILE}"
  fi

  if grep -qF "$MARKER" "${RC_FILE}"; then
    echo "Shell hook already present in ${RC_FILE}"
  else
    {
      printf '\n%s\n%s\n' "$MARKER" "$SOURCE_LINE"
    } >>"${RC_FILE}"
    echo "Appended source hook to ${RC_FILE}"
  fi
}

ensure_local_bin() {
  if [[ ! -d "${LOCAL_BIN}" ]]; then
    mkdir -p "${LOCAL_BIN}"
    echo "Created ${LOCAL_BIN}"
  fi
}

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
  # moor — pager binary is installed from GitHub releases (not Debian apt)
  # xclip, wl-clipboard — clipboard for cwd alias (X11 and Wayland)
  # git, curl — vim-plug and :PlugInstall clone plugins
  # neovim from apt only with --no-nvim-appimage (default is extracted AppImage on Linux)
  local packages=(bat fzf ripgrep zoxide screen tmux unzip xclip wl-clipboard git curl zsh rsync jq gawk)
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

install_unrar() {
  if command -v unrar &>/dev/null; then
    return 0
  fi
  if [[ "$NO_APT" == true ]] || [[ ! -f /etc/debian_version ]]; then
    return 0
  fi

  local -a priv=()
  if [[ "$(id -u)" -eq 0 ]]; then
    priv=()
  elif command -v sudo &>/dev/null; then
    priv=(sudo)
  else
    echo "Skipping unrar install: not root and sudo not found." >&2
    return 0
  fi

  echo "Installing unrar (fallback to unrar-free if needed)..."
  if [[ ${#priv[@]} -eq 0 ]]; then
    if ! DEBIAN_FRONTEND=noninteractive apt-get install -y unrar; then
      DEBIAN_FRONTEND=noninteractive apt-get install -y unrar-free || {
        echo "Skipping unrar install: neither unrar nor unrar-free could be installed." >&2
      }
    fi
  else
    if ! "${priv[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y unrar; then
      "${priv[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y unrar-free || {
        echo "Skipping unrar install: neither unrar nor unrar-free could be installed." >&2
      }
    fi
  fi
}

install_nvim_appimage() {
  [[ "$NVIM_APPIMAGE" == true ]] || return 0
  if [[ "$(uname -s)" != Linux ]]; then
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
  if [[ -x /opt/nvim/usr/bin/nvim ]]; then
    echo "Neovim already installed at /opt/nvim/usr/bin/nvim; skipping AppImage download."
  else
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
  fi

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
install_zsh
ensure_zshrc
ensure_local_bin
install_unrar

install_moor() {
  if command -v moor &>/dev/null; then
    return 0
  fi
  if [[ "$(uname -s)" != Linux ]]; then
    return 0
  fi
  if ! command -v curl &>/dev/null; then
    echo "Skipping moor install: curl not found." >&2
    return 0
  fi

  local arch_pattern
  case "$(uname -m)" in
    x86_64) arch_pattern='(x86_64|amd64)' ;;
    aarch64|arm64) arch_pattern='(aarch64|arm64)' ;;
    *)
      echo "Skipping moor install: unsupported architecture $(uname -m)." >&2
      return 0
      ;;
  esac

  local release_json asset_url
  if ! release_json="$(curl -fsSL https://api.github.com/repos/walles/moor/releases/latest)"; then
    echo "Skipping moor install: failed to query latest release metadata." >&2
    return 0
  fi

  asset_url="$(
    printf '%s\n' "${release_json}" |
      grep -Eo 'https://[^"]+' |
      grep '/walles/moor/releases/download/' |
      grep -E '/moor-' |
      grep -E "${arch_pattern}" |
      grep -E 'linux|unknown-linux' |
      grep -Ev '\.(sha256|sha256sum|txt|sig)$' |
      head -n 1
  )"
  if [[ -z "${asset_url}" ]]; then
    echo "Skipping moor install: no Linux binary asset found for architecture $(uname -m)." >&2
    return 0
  fi

  local -a priv=()
  if [[ "$(id -u)" -eq 0 ]]; then
    priv=()
  elif command -v sudo &>/dev/null; then
    priv=(sudo)
  else
    echo "Skipping moor install: need root or sudo to install /usr/local/bin/moor." >&2
    return 0
  fi

  local work asset_path
  work="$(mktemp -d)"
  asset_path="${work}/moor"

  echo "Downloading moor binary: ${asset_url}"
  if ! curl -fL --retry 3 -o "${asset_path}" "${asset_url}"; then
    rm -rf "${work}"
    echo "Skipping moor install: download failed." >&2
    return 0
  fi
  chmod a+x "${asset_path}"

  if [[ ${#priv[@]} -eq 0 ]]; then
    mv "${asset_path}" /usr/local/bin/moor
  else
    "${priv[@]}" mv "${asset_path}" /usr/local/bin/moor
  fi
  rm -rf "${work}"
  echo "Installed moor to /usr/local/bin/moor"
}

install_moor
install_nvim_appimage

set_login_shell_to_zsh() {
  local zsh_path current_shell
  zsh_path="$(command -v zsh 2>/dev/null || true)"
  if [[ -z "${zsh_path}" ]]; then
    echo "Could not find zsh in PATH. Install zsh and run: chsh -s /path/to/zsh $(id -un)" >&2
    return 0
  fi

  current_shell="${SHELL:-}"
  if [[ "${current_shell}" == "${zsh_path}" ]]; then
    echo "Login shell already set to ${zsh_path}"
    return 0
  fi

  if [[ -f /etc/shells ]] && ! grep -qFx "${zsh_path}" /etc/shells; then
    echo "Adding ${zsh_path} to /etc/shells..."
    if [[ "$(id -u)" -eq 0 ]]; then
      echo "${zsh_path}" >>/etc/shells
    elif command -v sudo &>/dev/null; then
      echo "${zsh_path}" | sudo tee -a /etc/shells >/dev/null || {
        echo "Warning: could not add ${zsh_path} to /etc/shells; chsh may fail." >&2
      }
    else
      echo "Warning: ${zsh_path} is not listed in /etc/shells; chsh may fail." >&2
    fi
  fi

  if chsh -s "${zsh_path}" "$(id -un)" >/dev/null 2>&1; then
    echo "Set login shell to ${zsh_path} for user $(id -un)"
  else
    echo "Could not set login shell automatically (common in containers)." >&2
    echo "Run manually: chsh -s \"${zsh_path}\" \"$(id -un)\"" >&2
  fi
}

install_starship() {
  ensure_local_bin

  if command -v starship &>/dev/null; then
    echo "Starship already available: $(command -v starship)"
  elif ! command -v curl &>/dev/null; then
    echo "Skipping Starship install: curl not found." >&2
  else
    echo "Installing Starship to ${LOCAL_BIN}"
    if curl -sS https://starship.rs/install.sh | sh -s -- -y -b "${LOCAL_BIN}"; then
      echo "Installed Starship: ${LOCAL_BIN}/starship"
    else
      echo "Starship install failed." >&2
    fi
  fi

  ln -sf "${SCRIPT_DIR}/starship.toml" "${HOME}/.config/starship.toml"
  echo "Symlinked starship.toml to ${HOME}/.config/starship.toml"
}

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

resolve_nvim_bin() {
  if command -v nvim &>/dev/null; then
    command -v nvim
    return 0
  fi
  if [[ -x /opt/nvim/usr/bin/nvim ]]; then
    echo /opt/nvim/usr/bin/nvim
    return 0
  fi
  return 1
}

install_nvim_plugins() {
  [[ "$NVIM_PLUG_INSTALL" == true ]] || return 0

  local plug_vim="${XDG_DATA_HOME:-${HOME}/.local/share}/nvim/site/autoload/plug.vim"
  if [[ ! -f "${plug_vim}" ]]; then
    return 0
  fi

  if ! command -v git &>/dev/null; then
    echo "Skipping Neovim plugin install: git not found." >&2
    return 0
  fi

  local nvim_bin plugged
  nvim_bin="$(resolve_nvim_bin || true)"
  if [[ -z "${nvim_bin}" ]]; then
    echo "Skipping Neovim plugin install: nvim not found." >&2
    return 0
  fi

  plugged="${HOME}/.vim/plugged"
  if [[ -d "${plugged}" ]] && [[ -n "$(ls -A "${plugged}" 2>/dev/null)" ]]; then
    echo "Neovim plugins already present in ${plugged}; skipping PlugInstall."
    return 0
  fi

  echo "Installing Neovim plugins (headless: ${nvim_bin} --headless +PlugInstall +qall)..."
  if ! "${nvim_bin}" --headless +PlugInstall +qall; then
    echo "Neovim plugin install failed; run manually: nvim --headless +PlugInstall +qall" >&2
    return 0
  fi
  echo "Neovim plugins installed."
}

mkdir -p "${HOME}/.config"
install_starship
ln -sf "${SCRIPT_DIR}/.screenrc" "${HOME}/.screenrc"
mkdir -p "${HOME}/.config/nvim"
ln -sf "${SCRIPT_DIR}/.vimrc" "${HOME}/.config/nvim/init.vim"

install_vim_plug
install_nvim_plugins

install_zsh_z() {
  if [[ -f "${HOME}/.zsh-z/zsh-z.plugin.zsh" ]]; then
    return 0
  fi
  if ! command -v git &>/dev/null; then
    echo "Skipping zsh-z install: git not found." >&2
    return 0
  fi
  echo "Installing zsh-z to ${HOME}/.zsh-z"
  git clone --depth 1 https://github.com/agkozak/zsh-z "${HOME}/.zsh-z" || {
    echo "zsh-z install failed." >&2
    return 0
  }
}

install_atuin() {
  [[ "$ATUIN_INSTALL" == true ]] || return 0
  if command -v atuin &>/dev/null || [[ -x "${HOME}/.atuin/bin/atuin" ]]; then
    return 0
  fi
  if ! command -v curl &>/dev/null; then
    echo "Skipping Atuin: curl not found." >&2
    return 0
  fi
  echo "Installing Atuin (binary to ~/.atuin/bin; hooks via .terminal — not setup.atuin.sh)"
  if ! curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh | sh; then
    echo "Atuin installer failed." >&2
    return 0
  fi
  if [[ -x "${HOME}/.atuin/bin/atuin" ]]; then
    "${HOME}/.atuin/bin/atuin" import auto 2>/dev/null || true
  fi
}

install_tailscale() {
  [[ "$TAILSCALE_INSTALL" == true ]] || return 0
  if command -v tailscale &>/dev/null; then
    echo "Tailscale already available: $(command -v tailscale)"
    return 0
  fi

  if [[ "$(uname -s)" == Darwin ]] && command -v brew &>/dev/null; then
    echo "Installing Tailscale via Homebrew (authenticate per machine: tailscale up)"
    if ! brew install tailscale; then
      echo "Tailscale install failed." >&2
      return 0
    fi
    if command -v tailscale &>/dev/null; then
      echo "Tailscale installed: $(command -v tailscale) — run: tailscale up"
    else
      echo "Tailscale install finished but tailscale not in PATH." >&2
    fi
    return 0
  fi

  if [[ "$(uname -s)" != Linux ]]; then
    echo "Skipping Tailscale: unsupported platform (install manually)." >&2
    return 0
  fi

  if ! command -v curl &>/dev/null; then
    echo "Skipping Tailscale: curl not found." >&2
    return 0
  fi

  # Run the official installer as root (not curl | sh) so sudo can prompt if needed.
  local -a priv=()
  if [[ "$(id -u)" -eq 0 ]]; then
    priv=()
  elif command -v sudo &>/dev/null; then
    priv=(sudo)
  else
    echo "Skipping Tailscale: not root and sudo not found." >&2
    return 0
  fi

  local installer
  installer="$(mktemp)"
  trap "rm -f '${installer}'" RETURN

  echo "Installing Tailscale via tailscale.com/install.sh (authenticate per machine: tailscale up)"
  if ! curl --proto '=https' --tlsv1.2 -fsSL -o "${installer}" https://tailscale.com/install.sh; then
    echo "Tailscale: failed to download installer." >&2
    return 0
  fi

  if ! "${priv[@]}" sh "${installer}"; then
    echo "Tailscale installer failed (check sudo, network, and /etc/os-release)." >&2
    return 0
  fi

  if command -v tailscale &>/dev/null; then
    echo "Tailscale installed: $(command -v tailscale)"
    if [[ ${#priv[@]} -eq 0 ]]; then
      echo "Authenticate: tailscale up"
    else
      echo "Authenticate: sudo tailscale up"
    fi
  else
    echo "Tailscale installer finished but 'tailscale' not in PATH; try: sudo tailscale version" >&2
  fi
}

strip_rc_blocks "${BASH_RC_FILE}"
set_login_shell_to_zsh
install_zsh_z
install_atuin
install_tailscale

install_claude_config() {
  local claude_src="${SCRIPT_DIR}/.claude"
  local claude_dest="${HOME}/.claude"

  if [[ ! -d "${claude_src}" ]]; then
    return 0
  fi

  mkdir -p "${claude_dest}"

  # Symlink config files and directories. Skip runtime data dirs (sessions, transcripts, etc.)
  local items=(CLAUDE.md settings.json rules skills agents)
  for item in "${items[@]}"; do
    local src="${claude_src}/${item}"
    local dest="${claude_dest}/${item}"

    [[ -e "${src}" ]] || continue

    if [[ -L "${dest}" ]]; then
      # Already a symlink — update it
      ln -sf "${src}" "${dest}"
    elif [[ -e "${dest}" ]]; then
      # Real file/dir exists — back it up before symlinking
      local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
      echo "Backing up existing ${dest} to ${backup}"
      mv "${dest}" "${backup}"
      ln -sf "${src}" "${dest}"
    else
      ln -sf "${src}" "${dest}"
    fi
  done

  echo "Symlinked Claude Code config from ${claude_src} to ${claude_dest}"
}

install_claude_config

install_codex_config() {
  local codex_src="${SCRIPT_DIR}/.codex/AGENTS.md"
  local codex_dest_dir="${HOME}/.codex"
  local codex_dest="${codex_dest_dir}/AGENTS.md"

  if [[ ! -f "${codex_src}" ]]; then
    return 0
  fi

  mkdir -p "${codex_dest_dir}"

  if [[ -L "${codex_dest}" ]]; then
    ln -sf "${codex_src}" "${codex_dest}"
  elif [[ -e "${codex_dest}" ]]; then
    local backup="${codex_dest}.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing ${codex_dest} to ${backup}"
    mv "${codex_dest}" "${backup}"
    ln -sf "${codex_src}" "${codex_dest}"
  else
    ln -sf "${codex_src}" "${codex_dest}"
  fi

  echo "Symlinked Codex AGENTS.md from ${codex_src} to ${codex_dest}"
}

install_codex_skills() {
  local codex_skills_src_dir="${SCRIPT_DIR}/.codex/skills"
  local codex_skills_dest_dir="${HOME}/.codex/skills"

  [[ -d "${codex_skills_src_dir}" ]] || return 0

  mkdir -p "${codex_skills_dest_dir}"

  local src
  for src in "${codex_skills_src_dir}"/*; do
    [[ -e "${src}" ]] || continue
    [[ -d "${src}" ]] || continue
    [[ -f "${src}/SKILL.md" ]] || continue

    local name dest
    name="$(basename "${src}")"
    dest="${codex_skills_dest_dir}/${name}"

    if [[ -L "${dest}" ]]; then
      echo "Skip ${dest}: symlink already exists."
    elif [[ -e "${dest}" ]]; then
      echo "Skip ${dest}: path exists and is not a symlink."
    else
      ln -sf "${src}" "${dest}"
    fi
  done

  echo "Symlinked Codex skills from ${codex_skills_src_dir} to ${codex_skills_dest_dir}"
}

install_codex_config

install_codex_skills

install_ai_kit_bins() {
  local kit_bin_dir="${SCRIPT_DIR}/ai-kit/bin"

  [[ -d "${kit_bin_dir}" ]] || return 0
  ensure_local_bin

  local commands=(ai-context ai-risk ai-failure ai-codex-prompt)
  for cmd in "${commands[@]}"; do
    local src="${kit_bin_dir}/${cmd}"
    local dest="${LOCAL_BIN}/${cmd}"

    [[ -x "${src}" ]] || continue

    if [[ -L "${dest}" ]]; then
      ln -sf "${src}" "${dest}"
    elif [[ -e "${dest}" ]]; then
      echo "Skip ${dest}: exists and is not a symlink." >&2
    else
      ln -sf "${src}" "${dest}"
    fi
  done
}

install_ai_kit_bins

install_tmux_config() {
  local tmux_src="${SCRIPT_DIR}/.tmux.conf"
  local tmux_dest="${HOME}/.tmux.conf"

  if [[ ! -f "${tmux_src}" ]]; then
    return 0
  fi

  if [[ -L "${tmux_dest}" ]]; then
    ln -sf "${tmux_src}" "${tmux_dest}"
  elif [[ -e "${tmux_dest}" ]]; then
    local backup="${tmux_dest}.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing ${tmux_dest} to ${backup}"
    mv "${tmux_dest}" "${backup}"
    ln -sf "${tmux_src}" "${tmux_dest}"
  else
    ln -sf "${tmux_src}" "${tmux_dest}"
  fi
}

install_tmux_config

if [[ "$WITH_GIT" == true ]]; then
  ln -sf "${SCRIPT_DIR}/.gitconfig" "${HOME}/.gitconfig"
fi

echo "Symlinked nvim init.vim, .screenrc, Claude Code config, and Codex config from ${SCRIPT_DIR}"
if [[ "$WITH_GIT" != true ]]; then
  echo "Tip: run with --git to symlink .gitconfig (skipped by default)."
fi
if [[ "$NVIM_PLUG_INSTALL" != true ]] && command -v nvim &>/dev/null && [[ -f "${XDG_DATA_HOME:-${HOME}/.local/share}/nvim/site/autoload/plug.vim" ]]; then
  echo "Tip: run 'nvim --headless +PlugInstall +qall' once to install plugins (needs git + network)."
fi
echo ""
if command -v zsh &>/dev/null && [[ -t 0 ]]; then
  echo "=== Starting zsh ==="
  exec zsh -l
elif command -v zsh &>/dev/null; then
  echo "=== Next step: start zsh ==="
  echo "Run: exec zsh -l"
  echo "Or open a new SSH session / terminal tab (full login)."
else
  echo "=== Next step: install zsh ==="
  echo "zsh was not installed — fix that first, then re-run ./install.sh."
fi
