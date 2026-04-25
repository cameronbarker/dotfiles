# Risk Zones

Fresh inspect-only verification by Codex is required before execution work in these areas.

## Install/Uninstall Automation

Source paths: `install.sh`, `uninstall.sh`, `README.md`

- Scripts can install packages, download remote assets, edit shell rc files, and modify home-level symlinks.
- Optional uninstall flags can delete `/opt/nvim`, `~/.atuin`, and Neovim plugin directories.
- Treat as machine-impacting operations requiring current-file and local-state checks.

## Credentials and Local Identity

Source paths: `.gitconfig`, `.claude/settings.json`

- `.gitconfig` contains user identity fields and credential helper config.
- Claude settings include command permissions and notification hooks.
- Do not copy secrets/tokens into context docs; none intentionally included here.

## AI Policy/Permission Configuration

Source paths: `.ai/context`, `.codex/AGENTS.md`, `.claude/*`

- These files control agent behavior and safety boundaries.
- Small edits can materially change execution routing or allowed commands.
- Policy changes should be inspected narrowly and reviewed before rollout.

## External Supply Chain Inputs

Source paths: `install.sh`, `.terminal`, `.vimrc`, `README.md`

- Repo setup references external scripts, binaries, and plugin sources.
- Validate URL/asset expectations before modifying automation.

## Generated/Non-Authoritative Context

Source paths: `ai-context/*`, `.gitignore`

- `ai-context/` is generated and may be stale.
- `.gitignore` indicates ignored `tmp/`; ignored content was not treated as authoritative.
