---
name: generate-ai-context
description: Generate or refresh concise repo-local ai-context documentation for GPT Project Sources while preserving GPT/Codex separation. Use when the user asks to generate ai-context, refresh ai-context, prepare GPT Project Sources context, create project context docs, update AI context docs, or summarize repo context for GPT.
---

# Generate AI Context

Generate or refresh a concise `ai-context/` folder at the target repository root for GPT planning and discussion. Treat the repository itself as source of truth; `ai-context/` is generated orientation material, not authoritative implementation documentation.

## Scope

- Inspect the current repository before writing.
- Generate or update only files under `ai-context/`.
- Do not modify application code, config, migrations, lockfiles, generated artifacts, or unrelated docs.
- Prefer static inspection and safe read-only commands.
- Never run app servers, migrations, deploys, destructive commands, or external network calls.
- Mark uncertainty explicitly when facts are not discoverable from inspected files.

## Required Inputs

Before generating docs, read any repo-local guidance that exists:

- `AGENTS.md`
- `.ai/context`
- Existing `ai-context/README.md` or `ai-context/generation-metadata.json`

Follow those instructions when they do not conflict with this skill or higher-priority user/system instructions.

## Safe Inspection

Use narrow, read-only inspection such as:

- `git status --short`
- `git rev-parse --show-toplevel`
- `git rev-parse --abbrev-ref HEAD`
- `git rev-parse HEAD`
- `find`, `ls`, `rg --files`, `sed`, `head`, `tail`, `wc`
- package/script inspection from files such as `package.json`, `Gemfile`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, `justfile`, Docker/CI config, route files, schemas, README files, and ADRs

Do not include secrets, env values, large code dumps, full lockfiles, build artifacts, or unsupported speculation in generated docs.

## Inspect-Only Risk Zones

For authentication, authorization, payments, secrets, infrastructure, databases, migrations, backups, production data, or destructive operations:

- Inspect first and summarize what is known.
- Do not make behavioral claims beyond inspected paths.
- Flag the area in `ai-context/risk-zones.md`.
- State that Codex must perform fresh repo inspection before execution work in that area.

## Files to Generate

Create whichever files are useful for the repository, usually:

- `ai-context/README.md`
- `ai-context/project-overview.md`
- `ai-context/architecture-map.md`
- `ai-context/commands.md`
- `ai-context/integration-points.md`
- `ai-context/risk-zones.md`
- `ai-context/generation-metadata.json`

Keep each Markdown file concise, path-referenced, and useful as GPT Project Sources context. Prefer short bullets and tables over prose. Include source paths for important claims.

## Content to Capture

Capture GPT-relevant context when discoverable:

- project purpose and boundaries
- stack, framework, runtime, package manager, and major dependencies
- major directories and responsibilities
- important entrypoints, routes, jobs, commands, and user/data flows
- domain models, entities, relationships, and persistence shape
- API, data, service, and third-party integration points
- dev, test, build, lint, format, and deploy commands
- coding conventions and naming patterns visible in the repo
- known risk zones and areas requiring Codex inspect-only
- paths to ADRs, README files, schemas, routes, migrations, and key config files

For generic or small repos such as libraries and dotfiles, adapt the documents to the actual structure instead of forcing web-app concepts.

## Metadata

Write `ai-context/generation-metadata.json` as valid JSON with:

- `repo_name`
- `branch`
- `commit_sha`
- `generated_at`
- `dirty_working_tree`
- `source_paths_inspected`

Use an ISO-8601 timestamp for `generated_at`. Set `dirty_working_tree` from `git status --short`; use a boolean plus optional summary when helpful. Include only paths actually inspected in `source_paths_inspected`.

## Output Guidelines

- Treat missing or unclear structure as partial coverage and say so.
- Prefer "Known from ..." or "Observed in ..." phrasing with paths.
- Avoid stale certainty: do not claim docs are complete if inspection was partial.
- Keep GPT/Codex separation visible: GPT uses `ai-context/` for planning; Codex must inspect live repo files before implementation decisions.
- After writing, summarize created/updated files and note any uncertainty or skipped areas.
