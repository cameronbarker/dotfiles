# Project Overview

## Purpose

Known from `README.md`: this repository (`pb-configs`) manages personal dotfiles
for cross-platform macOS/Linux development setup.

## Scope and Boundaries

- Dotfiles + local bootstrap scripts; not an app/service runtime.
- Main execution surface is Bash automation in `install.sh` and `uninstall.sh`.
- Includes local AI tooling policy/config for Claude/Codex (`.claude/`, `.codex/`, `.ai/context`).
- Includes note-processing prompt template (`prompts/notes_system.md`).

## Stack Snapshot

| Area | Observed in |
| --- | --- |
| Shell automation | `install.sh`, `uninstall.sh`, `.terminal` |
| Shell/runtime config | `.terminal`, `.screenrc`, `starship.toml` |
| Editor config | `.vimrc`, `vscode.jsonc` |
| Git config | `.gitconfig` |
| AI config and policy | `.claude/*`, `.codex/AGENTS.md`, `.ai/context` |

## Repo Map

| Path | Responsibility |
| --- | --- |
| `README.md` | Primary setup/install/uninstall docs |
| `install.sh` | Package/tool bootstrap, symlinks, rc hooks, Claude/Codex symlink setup |
| `uninstall.sh` | Reverses repo-owned links/markers and optional cleanup flags |
| `.terminal` | Aliases + shell init for fzf, Atuin, zoxide/z fallback, bat, Starship |
| `.vimrc` | Neovim settings, keymaps, plugin declarations, Treesitter config |
| `.claude/` | Claude global settings, rules, agents, and skills |
| `.codex/` | Codex routing/usage guidance and local skill metadata |
| `prompts/notes_system.md` | Obsidian/PARA transcript-processing template |

## Conventions Observed

- Shell scripts use Bash with `set -euo pipefail` (`install.sh`, `uninstall.sh`).
- `.codex/AGENTS.md` states routing discipline: GPT for planning, Codex for repo execution.
- `.gitignore` currently ignores `tmp/` and `.DS_Store`.

## Coverage Note

Observed from a focused file set, not exhaustive deep inspection of every nested skill/rule file.
