---
name: 0-maintain-project-workflow
description: Coordinate repository maintenance by proposing and sequencing maintain-agent-config, generate-ai-context, maintain-project-docs, and plan-and-commit-work with strict approval gates. Use when asked to maintain this repo, run project maintenance, refresh project workflow, update repo context and docs, run maintenance workflow, prepare repo for GPT, or sync agent config docs and commits.
---

# Maintain Project Workflow

Coordinate existing repo-maintenance skills in a safe, ordered workflow. Act as an orchestrator, not a replacement for underlying skills.

## Scope

- Inspect repo guidance and skill availability.
- Propose a step-by-step workflow before execution.
- Preserve every underlying skill's confirmation and safety gates.
- Never bypass approvals.
- Never auto-commit or push.
- Never run destructive commands.

## Underlying Skills

Use these skills when available:

- `maintain-agent-config`
- `generate-ai-context`
- `maintain-project-docs`
- `plan-and-commit-work`

## Required Guidance Pass

Read and summarize repository guidance before proposing workflow:

- `AGENTS.md` (if present)
- `.codex/AGENTS.md`
- `.ai/context`
- `ai-context/README.md` and `ai-context/generation-metadata.json` when present

Treat guidance as constraints for proposal and execution order.

## Default Execution Order

Use this default order unless a step is unavailable or clearly not applicable:

1. `maintain-agent-config`
2. `generate-ai-context`
3. `maintain-project-docs`
4. `plan-and-commit-work`

Apply these ordering rules:

- Run agent/config guidance before generating or refreshing `ai-context/`.
- If agent/config guidance changes, run `generate-ai-context` after that and before docs.
- If `ai-context/` or docs change, run `plan-and-commit-work` last.

## Proposal Phase (Mandatory)

Before running any step, provide a workflow proposal that includes:

- which steps will run and why each applies
- which steps will be skipped and why
- expected files each step may touch
- approval gates required at workflow level and inside each underlying skill
- risks, uncertainty, and assumptions

Then stop and request explicit approval before executing any step.

## Execution Phase (After Approval)

When approval is explicit:

1. Run one step at a time in default order.
2. Re-check applicability and skip with explanation when needed.
3. Preserve each underlying skill's approval requirements.
4. Stop immediately if a step raises risk, uncertainty, or asks for confirmation.
5. Continue only after user approval.

## Expected File Touch Map

Use this map in the workflow proposal:

- `maintain-agent-config`: `AGENTS.md` (if present), `.codex/AGENTS.md`, `.ai/context`, `.claude/**`, `.codex/skills/**` (as approved)
- `generate-ai-context`: `ai-context/**`
- `maintain-project-docs`: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`
- `plan-and-commit-work`: no file edits by default; may run git write commands only with explicit approval

## Hard Constraints

- Do not directly edit project files while orchestrating, except when an approved underlying skill performs its own scoped edits.
- Do not replace underlying skills with ad-hoc edits.
- Do not auto-run all steps without first proposing the workflow and receiving approval.
- Do not weaken, skip, or merge away underlying approval gates.
- Do not auto-commit, auto-push, or perform destructive operations.

## Trigger Phrases

- "maintain this repo"
- "run project maintenance"
- "refresh project workflow"
- "update repo context and docs"
- "run maintenance workflow"
- "prepare repo for GPT"
- "sync agent config docs and commits"
