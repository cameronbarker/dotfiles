# Agent policy notes (non-exec)

Human-readable workflow reminders for Codex and GPT. **Command enforcement** is installed globally under `~/.codex/rules/` from `.codex/rules/` (`git-safety.rules`, `destructive-commands.rules`, `secrets-safety.rules`). Test with `codex execpolicy check`.

## Default workflow

- Start with the smallest safe change.
- Prefer inspect-only passes when requirements are unclear.
- Document assumptions and validation results in final responses.

## Secrets safety

- Never print secrets in logs or responses.
- Use placeholders for credentials in examples.
- Flag potential secret exposure risks before applying changes.
- Shell commands that dump env files or credentials are blocked or prompted via `secrets-safety.rules`.

## Dependency changes

- Explain why each dependency change is needed.
- Prefer minimal version movement.
- Run relevant validation after dependency edits.
- Record follow-up risk checks when full validation is not possible.

## Infrastructure safety

- Require an inspect-only pass before infrastructure or environment changes.
- Call out potential impact to networking, backups, and security-sensitive setup.
- Avoid production-impacting actions without explicit approval.
