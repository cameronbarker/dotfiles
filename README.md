# pb-configs

Personal config files for a cross-platform (macOS/Linux) dev environment.

## Quick install (Debian/Linux, bash)

Clone to any path, then run the installer from the repo root:

```sh
git clone <your-repo-url> ~/Dotfiles
cd ~/Dotfiles && ./install.sh
```

For a **current Neovim** on Linux (recommended over distro packages for Lua plugins), use the [official AppImage](https://github.com/neovim/neovim/releases):

```sh
cd ~/Dotfiles && ./install.sh --nvim-appimage
```

That downloads the latest AppImage, **extracts** it to `/opt/nvim` (real files under `/opt/nvim/usr/bin/nvim`), and prepends **`/opt/nvim/usr/bin`** to your `PATH` in `~/.bashrc`. Extraction avoids **FUSE**, which many **LXC / Proxmox / Jellyfin-style** hosts do not provide (`fuse: device not found`). It also **skips** the apt `neovim` package. If you installed before this behavior, re-run `./install.sh --nvim-appimage` so `/opt/nvim` is replaced and your `PATH` line is updated.

This symlinks `starship.toml` and `.vimrc` (as Neovim `init.vim`) into `~/.config`, and appends a guarded `source` line to `~/.bashrc`. Re-running is safe (skips duplicate shell hooks).

On **Debian/Ubuntu**, the script runs `apt-get update` and installs: `neovim` (unless `--nvim-appimage`), `bat`, `fzf`, `ripgrep`, `xclip`, `wl-clipboard`, `git`, `curl`. With `--git` it also installs `libsecret-tools` and `libsecret-1-dev` for the Git credential helper in `.gitconfig`. If you are **root** (e.g. Proxmox host, minimal server), it uses `apt-get` directly; otherwise it uses `sudo`. The apt `fzf` package is often too old for `fzf --bash`; `.terminal` skips that safely. For fuzzy history and Ctrl-T file search, install fzf from git (below) so `~/.fzf.bash` exists.

The script also downloads **vim-plug** into `~/.local/share/nvim/site/autoload/plug.vim` if missing. Run `nvim +PlugInstall +qall` once to fetch plugins.

- `./install.sh --zsh` — append the hook to `~/.zshrc` instead of `~/.bashrc`.
- `./install.sh --git` — also symlink `.gitconfig` into `~` (off by default so an existing config is not overwritten).
- `./install.sh --no-apt` — skip apt (macOS, containers without sudo, or you manage packages yourself).
- `./install.sh --nvim-appimage` — Linux only: install latest Neovim from the official GitHub AppImage under `/opt/nvim` and put it on `PATH` (implies no apt `neovim`).

Install **Starship** with its install script — not from apt (see below).

### Uninstall

From the repo root, [`uninstall.sh`](uninstall.sh) removes what `install.sh` added (only symlinks that still point at **this** clone):

```sh
cd ~/Dotfiles && ./uninstall.sh
```

- **`--git`** — also remove `~/.gitconfig` if it symlinks this repo’s `.gitconfig`.
- **`--nvim-appimage`** — remove `/opt/nvim` (extracted tree or old single-file install; needs root or `sudo`).
- **`--vim-plug`** — remove `~/.local/share/nvim/site/autoload/plug.vim`.
- **`--plugged`** — delete `~/.vim/plugged` (all vim-plug clones).

Shell blocks are removed from **both** `~/.bashrc` and `~/.zshrc` when present. **Apt packages are not removed.**

## Files

| File | Description |
|------|-------------|
| `.gitconfig` | Git config — aliases, delta pager, credential helper |
| `.vimrc` | Neovim config with vim-plug |
| `.terminal` | Bash/Zsh aliases and shell functions (sourced from `~/.bashrc` or `~/.zshrc`) |
| `starship.toml` | [Starship](https://starship.rs) prompt config |
| `vscode.jsonc` | VSCode `settings.json` |
| `install.sh` | Symlinks, shell hook, optional apt, optional Neovim AppImage |
| `uninstall.sh` | Reverse symlinks + rc markers; optional AppImage / vim-plug / plugged |

## Setup (manual / details)

### Shell (`.terminal` + `starship.toml`)

1. Install dependencies:
   ```sh
   # Starship prompt
   curl -sS https://starship.rs/install.sh | sh

   # fzf (fuzzy finder)
   git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

   # z (directory jumping)
   git clone https://github.com/rupa/z.git ~/.z-plugin

   # bat (cat with syntax highlighting) — Debian/Ubuntu
   sudo apt install bat
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

   # Or let the dotfiles installer do the above:
   # ./install.sh --nvim-appimage

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

4. Run `nvim +PlugInstall +qall` once (needs `git` and network). Telescope, **nvim-treesitter**, LSP, gitsigns, and lualine expect a **recent Neovim (0.10+)** — use `./install.sh --nvim-appimage` or the AppImage steps above if your distro package is older. Install language parsers with `:TSInstall <lang>` (or `:TSInstall all`) inside Neovim.

### VSCode (`vscode.jsonc`)

Paths differ by install (e.g. `~/.config/Code/User/settings.json` on Linux). Copy or merge `vscode.jsonc` into your editor’s `settings.json`.

Required extensions: `One Dark Pro`, `Prettier`, `Ruby LSP`, `Rails`.
