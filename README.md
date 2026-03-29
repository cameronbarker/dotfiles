# pb-configs

Personal config files for a cross-platform (macOS/Linux) dev environment.

## Quick install (Debian/Linux, bash)

Clone to any path, then run the installer from the repo root:

```sh
git clone <your-repo-url> ~/Dotfiles
cd ~/Dotfiles && ./install.sh
```

This symlinks `starship.toml` and `.vimrc` (as Neovim `init.vim`) into `~/.config`, and appends a guarded `source` line to `~/.bashrc`. Re-running is safe (skips duplicate shell hooks).

On **Debian/Ubuntu**, the script runs `apt-get update` and installs: `neovim`, `bat`, `fzf`, `xclip`, `wl-clipboard`. With `--git` it also installs `libsecret-tools` and `libsecret-1-dev` for the Git credential helper in `.gitconfig`. If you are **root** (e.g. Proxmox host, minimal server), it uses `apt-get` directly; otherwise it uses `sudo`.

- `./install.sh --zsh` — append the hook to `~/.zshrc` instead of `~/.bashrc`.
- `./install.sh --git` — also symlink `.gitconfig` into `~` (off by default so an existing config is not overwritten).
- `./install.sh --no-apt` — skip apt (macOS, containers without sudo, or you manage packages yourself).

Install **Starship** and **vim-plug** separately — they are not Debian packages (see below).

## Files

| File | Description |
|------|-------------|
| `.gitconfig` | Git config — aliases, delta pager, credential helper |
| `.vimrc` | Neovim config with vim-plug |
| `.terminal` | Bash/Zsh aliases and shell functions (sourced from `~/.bashrc` or `~/.zshrc`) |
| `starship.toml` | [Starship](https://starship.rs) prompt config |
| `vscode.jsonc` | VSCode `settings.json` |
| `install.sh` | Symlinks + shell hook for a fresh machine |

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

   # Ubuntu
   sudo apt install neovim
   ```

2. Install [vim-plug](https://github.com/junegunn/vim-plug):
   ```sh
   sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
   ```

3. `./install.sh` already symlinks `~/.config/nvim/init.vim`; or:
   ```sh
   mkdir -p ~/.config/nvim
   ln -s /path/to/repo/.vimrc ~/.config/nvim/init.vim
   ```

4. Open Neovim and run `:PlugInstall`.

### VSCode (`vscode.jsonc`)

Paths differ by install (e.g. `~/.config/Code/User/settings.json` on Linux). Copy or merge `vscode.jsonc` into your editor’s `settings.json`.

Required extensions: `One Dark Pro`, `Prettier`, `Ruby LSP`, `Rails`.
