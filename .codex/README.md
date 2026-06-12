# Codex configuration (global source)

This directory is the **source of truth** for Codex settings used across all repos. `./install.sh` publishes selected files into `~/.codex/`.

## What installs globally

| Source | Installed to | Role |
|--------|----------------|------|
| `AGENTS.md` | `~/.codex/AGENTS.md` | Routing, inspect-first habits, git/secrets guidance |
| `rules/*.rules` | `~/.codex/rules/` | Exec policy (`prefix_rule`) for commands outside the sandbox |

`~/.codex/rules/default.rules` is **not** managed here — Codex writes TUI approvals there. Audit it periodically; `allow` entries can override `prompt` rules.

## Repo-only (not installed globally)

| File | Role |
|------|------|
| `project.yml` | Dotfiles project metadata for ai-context |
| `risk-paths.yml` | Path-based risk for this repo (`ai-kit`) |
| `config.toml` | Example defaults; live config is `~/.codex/config.toml` |
| `hooks.json` | Project hooks when working in this repo |
| `skills/` | Optional; install does not symlink skills (avoids clobbering `~/.codex/skills`) |

## Exec policy files

- `rules/git-safety.rules` — read-only git allow; writes prompt
- `rules/destructive-commands.rules` — forbid hard reset, force push, dangerous `rm`
- `rules/secrets-safety.rules` — forbid/prompt commands that dump credentials

After changing rules, re-run `./install.sh` and validate:

```shell
codex execpolicy check --pretty \
  --rules ~/.codex/rules/git-safety.rules \
  --rules ~/.codex/rules/destructive-commands.rules \
  --rules ~/.codex/rules/secrets-safety.rules \
  -- cat .env
```

Human workflow notes (non-exec): `docs/ai/agent-policy-notes.md`.
