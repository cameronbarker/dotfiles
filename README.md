# pb-configs

Personal config files for a cross-platform (macOS/Linux) dev environment.

## Bootstrap install (no git required)

[`bootstrap.sh`](bootstrap.sh) downloads a GitHub archive with **curl + tar only** (no `git` or `gh`), optionally verifies SHA-256, runs [`install.sh`](install.sh), and cleans up. On Debian/Ubuntu it installs missing `curl`/`ca-certificates` via `apt-get` (with `sudo` when not root).

**Security:** `curl … | bash` trusts whatever the remote script is *right now*. Without `--sha256`, you are accepting mutable content. That is convenient and common; it is not reproducible or tamper-evident. Prefer a **tag + `--sha256`** when you care about integrity.

### a) One-liner from `main` (mutable, not verified)

```sh
curl -fsSL https://raw.githubusercontent.com/cameronbarker/dotfiles/main/bootstrap.sh | bash
```

Same pattern as `curl -fsSL https://chatgpt.com/codex/install.sh | sh`: the script is piped in with no flags, so bootstrap assumes `--no-verify` and prints a warning. Use **`bash`**, not plain `sh` — this script needs Bash.

Proxmox / root: same command (bootstrap uses `apt-get` directly when uid 0).

After the shell helpers are installed, run the same bootstrap update through:

```sh
pb update
```

If the sourced dotfiles directory, or `~/.dotfiles`, is a git checkout, `pb update` runs `git -C <checkout> pull origin main` and then `<checkout>/install.sh`. Otherwise it falls back to the bootstrap one-liner above. Flags are passed to whichever path runs, for example `pb update --no-apt --no-atuin` for `install.sh`, or `pb update --clone` for the bootstrap fallback.

Install known external tools by short name:

```sh
pb install ai
```

`pb install ai` and `pb install codex` run the Codex CLI installer from `https://chatgpt.com/codex/install.sh`, then remind you to run `ai login --device-auth`. Run `pb install` to list available installers.

### b) Safer install from a tag with SHA-256

Compute the digest once on a trusted machine, then install with the same ref and hash:

```sh
curl -fsSL -o dotfiles.tar.gz \
  https://github.com/cameronbarker/dotfiles/archive/v1.0.0.tar.gz
shasum -a 256 dotfiles.tar.gz   # or: sha256sum dotfiles.tar.gz

curl -fsSL https://raw.githubusercontent.com/cameronbarker/dotfiles/main/bootstrap.sh \
  | bash -s -- --ref v1.0.0 --sha256 '<paste-64-char-hex-here>'
```

Use `--keep` to leave the temp download directory in place for debugging.

### c) Install with `--clone` (git checkout after bootstrap)

Bootstrap does not need git. Pass `--clone` to replace `~/.dotfiles` with a shallow git clone after the first install (requires git on `PATH` after `install.sh`):

```sh
curl -fsSL https://raw.githubusercontent.com/cameronbarker/dotfiles/main/bootstrap.sh \
  | bash -s -- --clone
```

Archive installs are published to `~/.dotfiles` before symlinks are created, so cleanup of the temp extract does not break your config.

## Quick install (git clone)

If you already have git and prefer a checkout:

```sh
sudo apt update && sudo apt install -y git && git clone https://github.com/cameronbarker/dotfiles.git && cd dotfiles && chmod +x install.sh && ./install.sh
```

Proxmox/root (no `sudo`):

```sh
apt update && apt install -y git && git clone https://github.com/cameronbarker/dotfiles.git && cd dotfiles && chmod +x install.sh && ./install.sh
```

On **Linux**, `./install.sh` installs Neovim from the [official AppImage](https://github.com/neovim/neovim/releases) by default: it **extracts** to `/opt/nvim` (binaries under `/opt/nvim/usr/bin/nvim`) and prepends **`/opt/nvim/usr/bin`** to your `PATH` in `~/.zshrc`. Extraction avoids **FUSE**, which many **LXC / Proxmox / Jellyfin** hosts lack. The apt **`neovim`** package is **not** installed unless you pass **`--no-nvim-appimage`**. On **macOS**, the AppImage step is skipped (install Neovim with Homebrew, etc.).

This symlinks `starship.toml`, `.vimrc` (as Neovim `init.vim`) into `~/.config`, **`~/.screenrc`**, links Claude/Codex config into `~/.claude` and `~/.codex/AGENTS.md`, and appends a guarded `source` line to `~/.zshrc`. Re-running is safe (skips duplicate shell hooks).

On **Debian/Ubuntu**, the script runs `apt-get update` and installs: `bat`, `fzf`, `ripgrep`, **`zoxide`**, **`screen`**, `xclip`, `wl-clipboard`, `git`, `curl`, `unattended-upgrades`, and **`neovim` only if** `--no-nvim-appimage`. It enables `unattended-upgrades.service` and `apt-daily-upgrade.timer` when systemd is available, keeping apt packages updated from configured repositories. It also installs **`moor`** from the latest `walles/moor` GitHub release binary into `/usr/local/bin/moor`. With `--git` it also installs `libsecret-tools` and `libsecret-1-dev` for the Git credential helper in `.gitconfig`. If you are **root** (e.g. Proxmox host, minimal server), it uses `apt-get` directly; otherwise it uses `sudo`. The apt `fzf` package is often too old for `fzf --bash`; `.terminal` skips that safely. For **Ctrl-T** file search, install fzf from git (below) so `~/.fzf.bash` exists.

By default the script also installs **[Atuin](https://atuin.sh)** (official binary to `~/.atuin/bin`). Hooks run from `.terminal` only — **do not** use `https://setup.atuin.sh` (it appends duplicate `atuin init` lines to your rc). Pass **`--no-atuin`** to skip. Optional: `atuin register` / `atuin login` for sync ([docs](https://docs.atuin.sh)).

The script also downloads **vim-plug** into `~/.local/share/nvim/site/autoload/plug.vim` if missing. Run `nvim +PlugInstall +qall` once to fetch plugins.

- `./install.sh` is zsh-only: appends shell hook to `~/.zshrc`, removes this repo's managed hook block from `~/.bashrc`, installs `agkozak/zsh-z` when missing, and attempts to set your login shell to zsh.
- `./install.sh --git` — also symlink `.gitconfig` into `~` (off by default so an existing config is not overwritten).
- `./install.sh --no-apt` — skip apt (macOS, containers without sudo, or you manage packages yourself).
- `./install.sh --no-nvim-appimage` — on Debian/Ubuntu, install **`neovim` from apt** instead of the extracted AppImage under `/opt/nvim` (ignored on non-Linux).
- `./install.sh --nvim-appimage` — no-op (AppImage is already the default); kept for compatibility.
- `./install.sh --no-atuin` — skip installing Atuin.

Install **Starship** with its install script — not from apt (see below).

### Uninstall

From the repo root, [`uninstall.sh`](uninstall.sh) removes repo-owned symlinks/markers it explicitly manages (when links still point at **this** clone):

```sh
cd ~/Dotfiles && ./uninstall.sh --git --nvim-appimage --atuin --vim-plug --plugged
```

- **`--git`** — also remove `~/.gitconfig` if it symlinks this repo’s `.gitconfig`.
- **`--nvim-appimage`** — remove `/opt/nvim` (extracted tree or old single-file install; needs root or `sudo`).
- **`--atuin`** — remove `~/.atuin`.
- **`--vim-plug`** — remove `~/.local/share/nvim/site/autoload/plug.vim`.
- **`--plugged`** — delete `~/.vim/plugged` (all vim-plug clones).

Shell blocks are removed from **both** `~/.bashrc` and `~/.zshrc` when present. `~/.codex/AGENTS.md` is removed when it points at this clone. Claude symlinks under `~/.claude` are not currently removed by `uninstall.sh`. **Apt packages are not removed.**

## Files

| File | Description |
|------|-------------|
| `AGENTS.md` | Contributor/agent guidelines — layout, validation, PRs, security |
| `CHANGELOG.md` | Notable changes (grouped; not a raw commit log) |
| `CONTRIBUTING.md` | How to contribute — validation, PRs, docs, safety |
| `.gitconfig` | Git config — aliases, delta pager, credential helper |
| `.vimrc` | Neovim config with vim-plug |
| `.terminal` | Bash/Zsh aliases, pager defaults (`PAGER`/`MANPAGER` to `moor` when available), zsh-z (zsh), zoxide fallback, fzf (files), Atuin when installed, Starship |
| `.screenrc` | GNU screen defaults (symlinked to `~`) |
| `starship.toml` | [Starship](https://starship.rs) prompt config |
| `vscode.jsonc` | VSCode `settings.json` |
| `bootstrap.sh` | Download GitHub archive (curl/tar), verify SHA-256, run `install.sh` — no git required |
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

   # zsh-z (directory jumping for zsh; preferred in .terminal when present)
   git clone --depth 1 https://github.com/agkozak/zsh-z ~/.zsh-z

   # bat (cat with syntax highlighting) — Debian/Ubuntu
   sudo apt install bat

   # moor (default pager used by PAGER and MANPAGER in .terminal)
   # Installed by ./install.sh from GitHub releases on Debian/Ubuntu.

   # zoxide + screen — also pulled in by ./install.sh on Debian/Ubuntu
   sudo apt install zoxide screen
   # macOS: brew install zoxide   (screen is usually preinstalled)
   ```

2. Prefer `./install.sh` for sourcing and symlinks; or add by hand:
   ```sh
   echo 'source /path/to/repo/.terminal' >> ~/.zshrc
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
   echo 'export PATH="/opt/nvim/usr/bin:$PATH"' >> ~/.zshrc
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
