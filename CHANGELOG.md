# Changelog

All notable changes to this repository are documented here. Summaries are grouped for readability (not a raw commit log).

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Root [`AGENTS.md`](AGENTS.md) — repository layout, script workflow, validation commands, PR expectations, and security notes.
- Codex skills under [`.codex/skills/`](.codex/skills/): `maintain-agent-config`, `maintain-project-docs`, `plan-and-commit-work`, `0-maintain-project-workflow` (orchestration).
- **zsh-z** — optional install to `~/.zsh-z` with `./install.sh --zsh` when missing; [`.terminal`](.terminal) prefers zsh-z on zsh, then zoxide, then rupa/z.
- Shell helper **`ai()`** — runs Codex CLI by default (`AI_CLI`, default `codex`) from [`.terminal`](.terminal).
- Shell helper **`pb update`** — updates a cloned `~/.dotfiles` checkout with `git pull origin main`, or falls back to the current [`bootstrap.sh`](bootstrap.sh) from `main`.
- Shell helper **`pb install`** — installs known external tools by short name, starting with `ai`/`codex` for the Codex CLI installer and login reminder.
- **unattended-upgrades** — installed on Debian/Ubuntu and enabled through systemd when available.

### Changed

- [`README.md`](README.md) — documents Claude/Codex symlinks from `install.sh`, zsh-z behavior, and clearer uninstall scope (including `~/.codex/AGENTS.md` vs `~/.claude`).
- [`.claude/skills/pr-summary/SKILL.md`](.claude/skills/pr-summary/SKILL.md) — compare against `master` instead of `main` for this repo’s default branch.
- [`.claude/rules/git-workflow.md`](.claude/rules/git-workflow.md) — require explicit approval before git state-changing commands.
- [`.claude/skills/fix-issue/SKILL.md`](.claude/skills/fix-issue/SKILL.md) — approval gate before git/gh state changes.
- [`.codex/AGENTS.md`](.codex/AGENTS.md) — **Git guidance**: allowed read-only git commands; no writes without explicit authorization.

### Removed

- Abandoned **AI kit** experiment: `ai-kit/`, `.codex/project.yml`, `.codex/risk-paths.yml`, `ai-context/` generation, and related Codex skills (`bootstrap-ai-context`, `generate-ai-context`).

### Fixed

- N/A for this section in the current draft; use for user-visible bugfixes in future entries.
