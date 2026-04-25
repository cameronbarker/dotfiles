# pb-configs

Personal config files for a cross-platform (macOS/Linux) dev environment.

## Quick install (Debian/Linux, bash)

Clone to any path, then run the installer from the repo root:

```sh
git clone https://github.com/cameronbarker/dotfiles.git ~/Dotfiles
cd ~/Dotfiles && ./install.sh
```

On **Linux**, `./install.sh` installs Neovim from the [official AppImage](https://github.com/neovim/neovim/releases) by default: it **extracts** to `/opt/nvim` (binaries under `/opt/nvim/usr/bin/nvim`) and prepends **`/opt/nvim/usr/bin`** to your `PATH` in `~/.bashrc`. Extraction avoids **FUSE**, which many **LXC / Proxmox / Jellyfin** hosts lack. The apt **`neovim`** package is **not** installed unless you pass **`--no-nvim-appimage`**. On **macOS**, the AppImage step is skipped (install Neovim with Homebrew, etc.).

This symlinks `starship.toml` and `.vimrc` (as Neovim `init.vim`) into `~/.config`, **`~/.screenrc`**, and appends a guarded `source` line to `~/.bashrc`. Re-running is safe (skips duplicate shell hooks).

On **Debian/Ubuntu**, the script runs `apt-get update` and installs: `bat`, `fzf`, `ripgrep`, **`zoxide`**, **`screen`**, `xclip`, `wl-clipboard`, `git`, `curl`, and **`neovim` only if** `--no-nvim-appimage`. With `--git` it also installs `libsecret-tools` and `libsecret-1-dev` for the Git credential helper in `.gitconfig`. If you are **root** (e.g. Proxmox host, minimal server), it uses `apt-get` directly; otherwise it uses `sudo`. The apt `fzf` package is often too old for `fzf --bash`; `.terminal` skips that safely. For **Ctrl-T** file search, install fzf from git (below) so `~/.fzf.bash` exists.

By default the script also installs **[Atuin](https://atuin.sh)** (official binary to `~/.atuin/bin`, plus `~/.bash-preexec.sh` for Bash). Hooks run from `.terminal` only — **do not** use `https://setup.atuin.sh` (it appends duplicate `atuin init` lines to your rc). Pass **`--no-atuin`** to skip. Optional: `atuin register` / `atuin login` for sync ([docs](https://docs.atuin.sh)).

The script also downloads **vim-plug** into `~/.local/share/nvim/site/autoload/plug.vim` if missing. Run `nvim +PlugInstall +qall` once to fetch plugins.

- `./install.sh --zsh` — append the hook to `~/.zshrc` instead of `~/.bashrc`.
- `./install.sh --git` — also symlink `.gitconfig` into `~` (off by default so an existing config is not overwritten).
- `./install.sh --no-apt` — skip apt (macOS, containers without sudo, or you manage packages yourself).
- `./install.sh --no-nvim-appimage` — on Debian/Ubuntu, install **`neovim` from apt** instead of the extracted AppImage under `/opt/nvim` (ignored on non-Linux).
- `./install.sh --nvim-appimage` — no-op (AppImage is already the default); kept for compatibility.
- `./install.sh --no-atuin` — skip installing Atuin.

Install **Starship** with its install script — not from apt (see below).

### Uninstall

From the repo root, [`uninstall.sh`](uninstall.sh) removes what `install.sh` added (only symlinks that still point at **this** clone):

```sh
cd ~/Dotfiles && ./uninstall.sh --git --nvim-appimage --atuin --vim-plug --plugged
```

- **`--git`** — also remove `~/.gitconfig` if it symlinks this repo’s `.gitconfig`.
- **`--nvim-appimage`** — remove `/opt/nvim` (extracted tree or old single-file install; needs root or `sudo`).
- **`--atuin`** — remove `~/.atuin` (see script output about `~/.bash-preexec.sh`).
- **`--vim-plug`** — remove `~/.local/share/nvim/site/autoload/plug.vim`.
- **`--plugged`** — delete `~/.vim/plugged` (all vim-plug clones).

Shell blocks are removed from **both** `~/.bashrc` and `~/.zshrc` when present. **Apt packages are not removed.**

## Files

| File | Description |
|------|-------------|
| `.gitconfig` | Git config — aliases, delta pager, credential helper |
| `.vimrc` | Neovim config with vim-plug |
| `.terminal` | Bash/Zsh aliases, zoxide, fzf (files), Atuin when installed, Starship |
| `.screenrc` | GNU screen defaults (symlinked to `~`) |
| `starship.toml` | [Starship](https://starship.rs) prompt config |
| `vscode.jsonc` | VSCode `settings.json` |
| `install.sh` | Symlinks, shell hook, apt on Debian; Neovim AppImage + Atuin by default on Linux |
| `uninstall.sh` | Reverse symlinks + rc markers; optional AppImage / Atuin / vim-plug / plugged |

## Setup (manual / details)

### Shell (`.terminal` + `starship.toml`)

1. Install dependencies (or run **`./install.sh`**, which installs Atuin + Neovim on Linux and apt packages on Debian):
   ```sh
   # Starship prompt
   curl -sS https://starship.rs/install.sh | sh

   # Atuin — prefer ./install.sh (binary only; avoids setup.atuin.sh mutating .bashrc).
   # Manual: curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh | sh
   # macOS: brew install atuin
   # Optional: atuin register / atuin login for sync (https://docs.atuin.sh)

   # fzf (fuzzy finder)
   git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

   # z (directory jumping)
   git clone https://github.com/rupa/z.git ~/.z-plugin

   # bat (cat with syntax highlighting) — Debian/Ubuntu
   sudo apt install bat

   # zoxide + screen — also pulled in by ./install.sh on Debian/Ubuntu
   sudo apt install zoxide screen
   # macOS: brew install zoxide   (screen is usually preinstalled)
   ```

2. Prefer `./install.sh` (or `./install.sh --zsh`) for sourcing and symlinks; or add by hand:
   ```sh
   echo 'source /path/to/repo/.terminal' >> ~/.bashrc
   mkdir -p ~/.config && ln -s /path/to/repo/starship.toml ~/.config/starship.toml
   ```

### Git (`.gitconfig`)

1. Use `./install.sh --git` after clone, or copy:
   ```sh
   cp .gitconfig ~/.gitconfig
   ```

2. Install credential helper (Linux):
   ```sh
   sudo apt install libsecret-tools libsecret-1-dev
   ```

3. Update `[user]` name and email in the file.

### Neovim (`.vimrc`)

1. Install Neovim:
   ```sh
   # macOS
   brew install neovim

   # Linux — latest AppImage without FUSE (LXC-friendly): extract, then PATH to usr/bin
   curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
   chmod u+x nvim-linux-x86_64.appimage
   ./nvim-linux-x86_64.appimage --appimage-extract
   sudo rm -rf /opt/nvim && sudo mv squashfs-root /opt/nvim
   echo 'export PATH="/opt/nvim/usr/bin:$PATH"' >> ~/.bashrc
   # On arm64: use nvim-linux-arm64.appimage instead.

   # Default ./install.sh on Linux does this AppImage extract for you.

   # Ubuntu / Debian — older build from apt (fine for the bundled plugin set)
   sudo apt install neovim
   ```

2. [vim-plug](https://github.com/junegunn/vim-plug): `./install.sh` downloads `plug.vim` if it is missing. By hand:
   ```sh
   sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
   ```

3. `./install.sh` symlinks `~/.config/nvim/init.vim`; or:
   ```sh
   mkdir -p ~/.config/nvim
   ln -s /path/to/repo/.vimrc ~/.config/nvim/init.vim
   ```

4. Run `nvim +PlugInstall +qall` once (needs `git` and network). Telescope, **nvim-treesitter**, LSP, gitsigns, and lualine expect **Neovim 0.10+** — the default Linux install uses the AppImage; use **`--no-nvim-appimage`** only if you accept the older distro `neovim`. Install language parsers with `:TSInstall <lang>` (or `:TSInstall all`) inside Neovim.

### VSCode (`vscode.jsonc`)

Paths differ by install (e.g. `~/.config/Code/User/settings.json` on Linux). Copy or merge `vscode.jsonc` into your editor’s `settings.json`.

Required extensions: `One Dark Pro`, `Prettier`, `Ruby LSP`, `Rails`.
