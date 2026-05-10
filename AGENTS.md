# Repository Guidelines

## Project Structure & Module Organization
This repository is a dotfiles/tooling setup, not an application service.
- Root config files: `.terminal`, `.vimrc`, `.gitconfig`, `.screenrc`, `starship.toml`, `vscode.jsonc`
- Automation scripts: `install.sh`, `uninstall.sh`
- Prompt/docs support: `prompts/`, `ai-context/`
- Agent tooling/config: `.codex/`, `.claude/`, `.ai/`

Keep new files close to their owning concern and prefer extending existing scripts/docs over adding parallel variants.

## Build, Test, and Development Commands
Primary workflow is script-driven:
- `./install.sh` installs/symlinks managed dotfiles and shell hooks
- `./install.sh --git` links Git config and keeps shell setup zsh-only
- `./install.sh --no-apt --no-atuin` skips package-manager and Atuin setup
- `./uninstall.sh --git --nvim-appimage --atuin` removes managed links and optional installed components
- `nvim +PlugInstall +qall` installs Neovim plugins after setup

Validation commands before PR:
- `bash -n install.sh uninstall.sh` (syntax check)
- `shellcheck install.sh uninstall.sh .terminal` (if available)

## Coding Style & Naming Conventions
- Prefer Bash for repository automation; keep scripts POSIX-aware unless Bash features are needed.
- Start scripts with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Quote variable expansions (`"${VAR}"`) and use descriptive function names (`install_nvim_appimage` style).
- Keep comments brief and focused on non-obvious behavior.
- Preserve existing file names and dotfile conventions; do not rename user-facing config paths without strong reason.

## Testing Guidelines
There is no formal unit test suite currently. Testing is operational:
- Run syntax/lint checks above.
- Execute install/uninstall paths in a safe environment (container/VM recommended).
- Verify idempotency: re-running `./install.sh` should not duplicate shell markers.
- Confirm symlink targets with `ls -l ~/.config` and related paths.

## Commit & Pull Request Guidelines
- Follow Conventional Commits used in history: `feat(scope): ...`, `docs(scope): ...`, `fix(scope): ...`.
- Keep subject lines concise and imperative.
- PRs should include:
  - Summary of changed files/behavior
  - Test plan with exact commands run
  - Notes on platform impact (macOS vs Debian/Ubuntu)

## Security & Configuration Tips
- Never commit secrets, tokens, or machine-specific credentials.
- Review destructive flags (`--nvim-appimage`, `--plugged`, etc.) before running uninstall options.
- When editing shell init behavior, ensure both `~/.bashrc` and `~/.zshrc` handling remains predictable.

## Related guidance
- `.codex/AGENTS.md` — GPT vs Codex routing, inspect-first habits, and **agent** git rules (no writes without explicit approval).
- `.ai/context` — how `ai-context/` is used with GPT Project Sources.
