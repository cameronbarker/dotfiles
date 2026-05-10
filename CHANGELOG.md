# Changelog

All notable changes to this repository are documented here. Summaries are grouped for readability (not a raw commit log).

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Root [`AGENTS.md`](AGENTS.md) — repository layout, script workflow, validation commands, PR expectations, and security notes.
- [`.ai/context`](.ai/context) — policy for GPT vs Codex and how root [`ai-context/`](ai-context/) is generated and used with GPT Project Sources.
- [`ai-context/`](ai-context/) — generated orientation docs (`project-overview`, `architecture-map`, `commands`, `integration-points`, `risk-zones`, `generation-metadata.json`) for planning; refresh via the `generate-ai-context` Codex skill when repo facts change.
- Codex skills under [`.codex/skills/`](.codex/skills/): `maintain-agent-config`, `maintain-project-docs`, `plan-and-commit-work`, `0-maintain-project-workflow` (orchestration), alongside existing `generate-ai-context`.
- **zsh-z** — optional install to `~/.zsh-z` with `./install.sh --zsh` when missing; [`.terminal`](.terminal) prefers zsh-z on zsh, then zoxide, then rupa/z.
- Shell helper **`ai()`** — runs Codex CLI by default (`AI_CLI`, default `codex`) from [`.terminal`](.terminal).

### Changed

- [`README.md`](README.md) — documents Claude/Codex symlinks from `install.sh`, zsh-z behavior, and clearer uninstall scope (including `~/.codex/AGENTS.md` vs `~/.claude`).
- [`.claude/skills/pr-summary/SKILL.md`](.claude/skills/pr-summary/SKILL.md) — compare against `master` instead of `main` for this repo’s default branch.
- [`.claude/rules/git-workflow.md`](.claude/rules/git-workflow.md) — require explicit approval before git state-changing commands.
- [`.claude/skills/fix-issue/SKILL.md`](.claude/skills/fix-issue/SKILL.md) — approval gate before git/gh state changes.
- [`.codex/AGENTS.md`](.codex/AGENTS.md) — **Git guidance**: allowed read-only git commands; no writes without explicit authorization.

### Fixed

- N/A for this section in the current draft; use for user-visible bugfixes in future entries.
