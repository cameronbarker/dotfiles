# Integration Points

## Local System Integration

Observed in `install.sh` and `uninstall.sh`:

- Writes/edits shell rc markers in `~/.bashrc` or `~/.zshrc`.
- Manages symlinks into `~/.config`, `~/.screenrc`, `~/.gitconfig`, `~/.claude`, and `~/.codex`.
- Can install/remove Neovim under `/opt/nvim` on Linux.
- Can create/remove Atuin and vim-plug related files in `$HOME`.

## Network/Download Surfaces

Observed in `README.md`, `install.sh`, `.terminal`, `.vimrc`:

- Neovim AppImage download from GitHub releases.
- Atuin installer and bash-preexec download.
- vim-plug bootstrap download.
- Starship install script reference.
- fzf/rupa-z/manual plugin installs in docs.

## Tooling and Credential Surfaces

Observed in `.gitconfig`:

- `credential.helper = libsecret` (Linux-oriented default).
- URL shorthands for GitHub/Bitbucket/Gist.
- Git LFS filter configuration.

Observed in `.claude/settings.json`:

- Allowed command patterns for git/gh in Claude context.
- Notification hook uses `osascript` fallback to `notify-send`.

## AI Context Integration

Observed in `.ai/context`, `.codex/AGENTS.md`, `.codex/skills/generate-ai-context/SKILL.md`, `.codex/skills/maintain-agent-config/SKILL.md`, `.codex/skills/0-maintain-project-workflow/SKILL.md`:

- `ai-context/` is generated orientation data for GPT sources.
- Codex remains the execution and verification layer.
- For risky domains, inspect-only pass is required before action.
- Maintenance workflow skills enforce proposal/approval gates before guidance edits.
