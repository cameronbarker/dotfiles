# Architecture Map

## Primary Operational Flow

1. User runs `./install.sh` from repo root (`README.md`, `install.sh`).
2. Script parses flags (`--zsh`, `--git`, `--no-apt`, `--no-nvim-appimage`, `--no-atuin`).
3. On Debian/Ubuntu, apt packages may be installed unless `--no-apt` (`install.sh`).
4. On Linux by default, Neovim AppImage is downloaded/extracted to `/opt/nvim` and PATH line is managed in rc (`install.sh`).
5. Repo files are symlinked into home targets and shell source marker is added (`install.sh`).
6. `uninstall.sh` removes only repo-owned symlinks/markers and optional assets by flag.

## Install Targets (Observed)

| Destination | Source |
| --- | --- |
| `~/.config/starship.toml` | `starship.toml` |
| `~/.config/nvim/init.vim` | `.vimrc` |
| `~/.screenrc` | `.screenrc` |
| `~/.codex/AGENTS.md` | `.codex/AGENTS.md` |
| `~/.claude/{CLAUDE.md,settings.json,rules,skills,agents}` | `.claude/` |
| `~/.gitconfig` (with `--git`) | `.gitconfig` |
| `~/.bashrc` or `~/.zshrc` marker block | `.terminal` source line |

## Runtime Composition

Observed in `.terminal`:

- Aliases for shell, git, rails, listing, search.
- Clipboard helper fallback order: `pbcopy` -> `xclip` -> `wl-copy`.
- fzf initialization uses `~/.fzf.{bash,zsh}` when present; otherwise guarded `fzf --bash/--zsh`.
- Atuin initialization is loaded after fzf (so Atuin owns Ctrl-R).
- zoxide preferred; rupa/z fallback if zoxide missing.
- `batcat`/`bat` can replace `cat`.
- Starship initializes from `~/.config/starship.toml`.

## Editor Surface

Observed in `.vimrc`:

- Two-space default indentation with filetype overrides.
- vim-plug plugins for Telescope, Treesitter, LSP config, cmp, fugitive, gitsigns, lualine, catppuccin.
- Treesitter setup guarded via Lua `pcall`.

Observed in `vscode.jsonc`:

- One Dark Pro theme, Prettier defaults, Ruby LSP + Rails-oriented settings.

## AI Workflow Surface

Observed in `.ai/context` and `.codex/AGENTS.md`:

- `ai-context/` is generated orientation docs for GPT.
- Codex should re-inspect live repo before implementation/execution decisions.
