# Commands

Known from `README.md`, `install.sh`, and `uninstall.sh`.

## Install

| Command | Effect |
| --- | --- |
| `./install.sh` | Default install flow (symlinks + optional apt + Neovim AppImage on Linux + Atuin + vim-plug + Claude/Codex config symlinks) |
| `./install.sh --zsh` | Write shell marker to `~/.zshrc` instead of `~/.bashrc` |
| `./install.sh --git` | Also symlink `~/.gitconfig` and include libsecret apt packages on Debian |
| `./install.sh --no-apt` | Skip apt package install |
| `./install.sh --no-nvim-appimage` | Skip default AppImage path and use apt `neovim` path on Debian/Ubuntu |
| `./install.sh --no-atuin` | Skip Atuin install |

## Uninstall

| Command | Effect |
| --- | --- |
| `./uninstall.sh` | Remove repo-owned symlinks and shell marker blocks |
| `./uninstall.sh --git` | Also remove `~/.gitconfig` symlink if it points to this repo |
| `./uninstall.sh --nvim-appimage` | Remove `/opt/nvim` on Linux |
| `./uninstall.sh --atuin` | Remove `~/.atuin` directory |
| `./uninstall.sh --vim-plug` | Remove `plug.vim` under XDG data path |
| `./uninstall.sh --plugged` | Remove `~/.vim/plugged` |

## Common Follow-Up Commands

| Command | Purpose |
| --- | --- |
| `nvim +PlugInstall +qall` | Install declared Neovim plugins |
| `atuin register` / `atuin login` | Optional Atuin sync setup |

## Safe Inspect-Only Commands

- `git status --short`
- `git rev-parse --abbrev-ref HEAD`
- `git rev-parse HEAD`
- `rg --files`
- `sed -n '1,220p' <path>`
