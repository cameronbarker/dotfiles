---
name: maintain-agent-config
description: Inspect and maintain repository-local AI agent/config guidance by proposing safe, minimal updates to AGENTS.md, .codex/AGENTS.md, .ai/context, and Claude/Codex agent rule/skill folders. Use when asked to maintain agent config, update AGENTS.md, review agent guidance, align AI instructions, update Codex guidance, update Claude agents, check agent config, or reconcile AI tooling docs.
---

# Maintain Agent Config

Inspect agent/config guidance, identify conflicts or drift, and propose narrow updates with explicit approval before any edit.

## Scope

- Primary files and folders to inspect when present:
  - `AGENTS.md`
  - `.codex/AGENTS.md`
  - `.ai/context`
  - `.claude/CLAUDE.md`
  - `.claude/agents/`
  - `.claude/rules/`
  - `.claude/skills/`
  - `.codex/skills/`
- Supporting context only:
  - `README.md`
  - `ai-context/`
- Treat agent/config files as high-risk workflow configuration.
- Do not modify application code.

## Required Guidance Pass

Before proposing changes, read and summarize applicable repo guidance:

- `AGENTS.md`
- `.codex/AGENTS.md`
- `.ai/context`
- `.claude/CLAUDE.md` (if present)

If guidance conflicts, follow higher-priority system/developer/user instructions first, then preserve stricter safety rules from repo files.

## Inspection Workflow

1. Read existing guidance files and rule documents.
2. Inspect repository structure for relevant agent/rule/skill locations.
3. Compare instructions across files for:
  - outdated or stale guidance
  - duplicated directives
  - conflicting workflows
  - missing safety guardrails
  - broken path references
4. Build a proposal with exact, minimal changes.
5. Stop and request explicit approval before editing any guidance/config file.
6. After approval, edit only approved files and sections.
7. Show resulting diff.

## Proposal Format (Before Any Edit)

Provide a concise proposal including:

- findings grouped by file/path
- why each item is a risk or inconsistency
- exact recommended edits (small diff hunks or targeted replacement blocks)
- assumptions and open questions

Prefer additions and targeted line edits over broad rewrites.

## Mandatory Approval Gate

Never edit guidance/config files until the user explicitly approves the proposed changes.

Never auto-edit:

- `AGENTS.md`
- `.codex/AGENTS.md`
- `.ai/context`
- `.claude/CLAUDE.md`
- `.claude/agents/**`
- `.claude/rules/**`
- `.claude/skills/**`

Without explicit approval, stay inspect-only.

## Edit Constraints (After Approval)

- Edit only approved files and approved sections.
- Never rewrite entire files unless explicitly approved.
- Preserve existing structure, tone, and stricter safety rules.
- Never invent workflows not grounded in repository files.
- Prefer minimal, reversible edits.

## Inspect-Only Risk Zones

Treat the following as inspect-only unless the user gives explicit authorization and scope:

- authentication and authorization
- secrets, credentials, tokens, keys
- infrastructure and networking
- databases, migrations, backups
- payments
- destructive operations
- git history rewrites or destructive git actions

When these areas appear in guidance, prioritize preserving or strengthening safety constraints.

## Safety Rules

- Never weaken safety rules already present.
- Never run destructive commands.
- Never claim a file has guidance that was not inspected.
- Never change unrelated files while maintaining agent/config guidance.

## Trigger Phrases

- "maintain agent config"
- "update AGENTS.md"
- "review agent guidance"
- "align AI instructions"
- "update Codex guidance"
- "update Claude agents"
- "check agent config"
- "reconcile AI tooling docs"
