---
name: plaid-cli
description: Safely use the Plaid CLI for production-focused data retrieval workflows with JSON-first output, least-privilege query patterns, and strict handling of sensitive financial data.
---

# Plaid CLI

Source of truth: `plaid-cli.md` in this repository.

## 1. Purpose

Provide reusable guidance for using the Plaid CLI safely and consistently across workflows.

This skill is for CLI usage only. It does not cover building applications with Plaid SDKs or direct API integrations.

Assumptions:

- Plaid CLI is already installed.
- Production access is already configured.
- Default environment is `production`.

## 2. When to use this skill

Use this skill when work requires inspecting or retrieving Plaid data from the terminal, including:

- Item discovery and targeted Item selection
- balances, transactions, investments, and liabilities queries
- incremental transaction sync workflows
- narrow production diagnostics for missing/ambiguous Item selection

Do not use this skill to design or implement Plaid SDK/API app code.

## 3. Safety rules

- Treat all financial data as sensitive.
- Never print, expose, log, commit, or summarize secrets.
- Never show full access tokens, client secrets, API keys, or credential file contents.
- Do not modify Plaid config, environment, credentials, teams, keys, or linked Items unless the user explicitly asks.
- Do not run destructive commands without explicit confirmation.
- `plaid item remove` always requires explicit confirmation.
- For browser-opening commands, explain what will open and why before execution:
  - `plaid link`
  - `plaid login`
  - `plaid register`
  - `plaid trial`
- For production data, avoid broad dumps; prefer narrow queries, counts, date ranges, and summaries.

## 4. Default command behavior

- Default to production context and avoid environment mutation commands unless explicitly requested.
- Prefer machine-readable output.
- Use `--json` by default whenever supported.
- When scripting, keep stdout JSON separate from stderr diagnostics.
- Prefer `jq` for inspecting JSON without dumping entire payloads.
- If a command fails, inspect the error and suggest the smallest useful next command.

Practical scripting pattern:

```bash
plaid <command> --json 1>result.json 2>error.log
```

Focused JSON inspection pattern:

```bash
jq '.items | length' result.json
```

## 5. Common commands

Use these as the default command set for routine workflows:

- `plaid --version`
- `plaid config`
- `plaid item list --json`
- `plaid item get --json`
- `plaid balance --json`
- `plaid transactions list --json`
- `plaid transactions sync --json`
- `plaid investments holdings --json`
- `plaid investments transactions --json`
- `plaid liabilities --json`

Selection guidance:

- Prefer explicit item targeting when possible (for example `--item <item-id-or-name>`).
- Use all-items mode only when the user asks for aggregate coverage (for example `--all`, if supported by that command).

## 6. Workflow examples

### Check CLI readiness

```bash
plaid --version
plaid config
```

### List linked production Items

```bash
plaid item list --json
```

### Get balances for all linked Items or a specific Item

```bash
plaid balance --all --json
plaid balance --item <item-selector> --json
```

### Pull recent transactions with a bounded count

```bash
plaid transactions list --item <item-selector> --count 25 --json
```

### Sync transactions incrementally

```bash
plaid transactions sync --item <item-selector> --json
```

### Get investment holdings

```bash
plaid investments holdings --item <item-selector> --json
```

### Get liabilities

```bash
plaid liabilities --item <item-selector> --json
```

### Diagnose missing/ambiguous Item selection

1. List Items with JSON:

```bash
plaid item list --json
```

2. Inspect only identifiers and display names with `jq`:

```bash
plaid item list --json | jq '.items[] | {item_id, institution_name}'
```

3. Re-run the target command with an explicit `--item` selector.

## 7. Troubleshooting

- Command fails with auth/config errors:
  - Read stderr first.
  - Run `plaid config`.
  - Suggest one minimal follow-up command based on the error.
- Ambiguous or missing Item:
  - Run `plaid item list --json`.
  - Choose a specific Item and retry with `--item`.
- Output too large for production review:
  - Add bounds (`--count`, date filters, targeted `--item`) and re-run.
- JSON parsing issues:
  - Re-run with `--json`.
  - Use narrow `jq` filters instead of full payload display.

## 8. Things not to do

- Do not use this skill for SDK/API application development.
- Do not run `plaid config set`, `plaid teams choose`, or `plaid keys fetch` unless explicitly requested.
- Do not run `plaid item remove` without explicit confirmation.
- Do not open browser-based flows (`plaid link`, `plaid login`, `plaid register`, `plaid trial`) without explanation first.
- Do not print or persist secrets in terminal output, logs, patches, or commits.
- Do not perform broad production data dumps when a narrow query answers the question.
