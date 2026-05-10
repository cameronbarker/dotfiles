---
name: maintain-project-docs
description: Keep project documentation accurate and up to date by inspecting the repository and proposing precise updates to README.md and, when present or explicitly requested, CHANGELOG.md and CONTRIBUTING.md, with a mandatory approval gate before edits. Use when asked to update docs, fix README, generate changelog updates, update contributing guidance, maintain project docs, or sync docs with repo state.
---

# Maintain Project Docs

Maintain high-quality project documentation with repository inspection as source of truth. Use git history and current diff only as supporting context.

## Scope

- Primary target: `README.md` (expected for most repos).
- Optional targets: `CHANGELOG.md`, `CONTRIBUTING.md` — inspect and update only when the file exists or the user explicitly asks to add one; creating a new optional file requires the same explicit approval as any doc edit (see Confirmation Gate).
- Default to minimal, precise edits; preserve existing formatting and structure.
- Prefer updating existing sections over rewriting large sections.
- Never invent commands, setup steps, workflows, or environment details.
- Never include secrets, credentials, or environment values.

## Required Guidance Pass

Read repository guidance before proposing any documentation edits:

- `AGENTS.md` (if present)
- `.codex/AGENTS.md` (if present)
- `.ai/context` (if present)

Follow repo-specific documentation conventions when they do not conflict with higher-priority instructions.

## Inspection Workflow

1. Inspect documentation files (skip missing optional files; note their absence in the plan if relevant):
- `README.md`
- `CHANGELOG.md` (if present)
- `CONTRIBUTING.md` (if present)

2. Inspect repository facts needed to validate docs:
- package/config files that define stack and scripts
- install scripts, entrypoints, and workflows
- related docs and automation files that docs reference

3. Inspect supporting git context:
- `git log --oneline -n 20`
- `git diff`

Treat repository files as source of truth. Use git history/diff as signal for what may have changed, not as authoritative behavior.

## Documentation Plan Output

Before editing, produce a clear plan with:

- what is stale, missing, or inconsistent
- proposed updates per file
- exact text changes (diff-style hunks or complete replacement sections)
- risks, uncertainty, and assumptions

If uncertainty remains, call it out explicitly and keep proposed edits conservative.

## Confirmation Gate

Do not edit documentation files until the user explicitly approves the proposed plan.

After approval:

1. Update only approved files/sections.
2. Keep changes minimal and precise.
3. Preserve style and structure.
4. Show resulting diff.

## File-Specific Rules

### README.md

- Ensure purpose, setup, usage, and key commands are present.
- Verify every documented command against actual scripts or tooling files.

### CHANGELOG.md

- Summarize changes using repository evidence and supporting git history.
- Group entries logically with headings such as `Added`, `Changed`, `Fixed`.
- Do not paste raw commit logs or dump commit messages.

### CONTRIBUTING.md

- Reflect actual contribution workflow used in the repository.
- Keep guidance simple unless repository complexity requires more detail.
- Align with real scripts, tools, and git practices in the repo.

## Documentation Quality Heuristics

### README.md should

- Clearly state purpose in the first section.
- Include setup and usage instructions when applicable.
- Include key commands or workflows when relevant.
- Avoid duplication and unnecessary verbosity.

### CHANGELOG.md should

- Summarize meaningful changes, not raw commits.
- Use grouped sections such as `Added`, `Changed`, `Fixed`.
- Focus on user-impacting changes.

### CONTRIBUTING.md should

- Reflect actual repository workflow, including real scripts, commands, and tools.
- Stay minimal for simple projects.
- Avoid generic or boilerplate contribution text.

### General

- Prefer clarity over completeness.
- Prefer accuracy over coverage.
- Keep docs concise and actionable.

## Safety Rules

- Never rely on git history alone for documentation content.
- Never overwrite large sections without clear, file-backed justification.
- Never run destructive commands while doing documentation maintenance.

## Trigger Phrases

- "update docs"
- "fix README"
- "generate changelog"
- "update contributing"
- "maintain project docs"
- "sync docs with repo"
