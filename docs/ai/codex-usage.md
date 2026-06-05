# Codex Usage

## Purpose

This document defines day-to-day expectations for using Codex. **Global** Codex config is sourced from this repo’s `.codex/` directory and installed to `~/.codex/` via `./install.sh` (see `.codex/README.md`).

## Defaults

- Prefer inspect-first on unclear tasks.
- Keep changes scoped and reviewable.
- Run relevant validation before handoff.
- Follow repository conventions in `AGENTS.md` and `.codex/AGENTS.md` (symlinked to `~/.codex/AGENTS.md`).

## Exec policy rules (global)

Managed Starlark rules install to `~/.codex/rules/`:

| File | Purpose |
|------|---------|
| `git-safety.rules` | Allow read-only git; prompt on writes |
| `destructive-commands.rules` | Forbid hard reset, force push, dangerous `rm` |
| `secrets-safety.rules` | Forbid/prompt secret-dumping commands |

`~/.codex/rules/default.rules` is owned by Codex (TUI approvals). Review it periodically — `allow` entries can weaken `prompt` rules.

Validate after editing rules and re-running `./install.sh`:

```shell
codex execpolicy check --pretty \
  --rules ~/.codex/rules/git-safety.rules \
  --rules ~/.codex/rules/destructive-commands.rules \
  --rules ~/.codex/rules/secrets-safety.rules \
  -- git status

codex execpolicy check --pretty \
  --rules ~/.codex/rules/secrets-safety.rules \
  -- cat .env

codex execpolicy check --pretty \
  --rules ~/.codex/rules/destructive-commands.rules \
  -- git reset --hard HEAD~1
```

Human workflow notes (non-exec): `docs/ai/agent-policy-notes.md`.

## Dotfiles Validation Baseline

- `bash -n install.sh uninstall.sh`
- `shellcheck install.sh uninstall.sh .terminal terminal/*.sh` (if available)
