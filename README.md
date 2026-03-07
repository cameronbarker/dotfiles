# pb-configs

Personal config files for a cross-platform (macOS/Linux) dev environment.

## Files

| File | Description |
|------|-------------|
| `.gitconfig` | Git config — aliases, delta pager, credential helper |
| `.vimrc` | Neovim config with vim-plug |
| `.terminal` | Zsh aliases and shell functions (sourced from `~/.zshrc`) |
| `starship.toml` | [Starship](https://starship.rs) prompt config |
| `vscode.jsonc` | VSCode `settings.json` |

## Setup

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

2. Source `.terminal` from your `~/.zshrc`:
   ```sh
   echo 'source ~/projects/pb-configs/.terminal' >> ~/.zshrc
   ```

3. Symlink `starship.toml`:
   ```sh
   mkdir -p ~/.config && ln -s ~/projects/pb-configs/starship.toml ~/.config/starship.toml
   ```

### Git (`.gitconfig`)

1. Copy to home directory:
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

3. Symlink or copy the config:
   ```sh
   mkdir -p ~/.config/nvim
   ln -s ~/projects/pb-configs/.vimrc ~/.config/nvim/init.vim
   ```

4. Open Neovim and run `:PlugInstall`.

### VSCode (`vscode.jsonc`)

```sh
# Linux
cp vscode.jsonc /config/data/User/settings.json
```

Required extensions: `One Dark Pro`, `Prettier`, `Ruby LSP`, `Rails`.

