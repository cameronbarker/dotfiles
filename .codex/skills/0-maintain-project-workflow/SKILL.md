---
name: 0-maintain-project-workflow
description: Coordinate repository maintenance by proposing and sequencing maintain-agent-config, maintain-project-docs, and plan-and-commit-work with mode-aware approval gates. Use when asked to maintain this repo, run project maintenance, refresh project workflow, update repo context and docs, run maintenance workflow, prepare repo for GPT, or sync agent config docs and commits.
---

# Maintain Project Workflow

Coordinate existing repo-maintenance skills in a safe, ordered workflow. Act as an orchestrator, not a replacement for underlying skills.

## Scope

- Inspect repo guidance and skill availability.
- Propose a step-by-step workflow before execution, including execution mode.
- Support two modes:
  - `optimistic` (default): after workflow approval, continue through low-risk steps without stopping between each stage unless risk or uncertainty appears.
  - `conservative`: stop for proposal/approval before each stage.
- Preserve safety gates and never bypass required approvals.
- Never auto-commit or push.
- Never run destructive commands.

## Underlying Skills

Use these skills when available:

- `maintain-agent-config`
- `maintain-project-docs`
- `plan-and-commit-work`

## Required Guidance Pass

Read and summarize repository guidance before proposing workflow:

- `AGENTS.md` (if present)
- `.codex/AGENTS.md`
- `.ai/context`
- `ai-context/README.md` and `ai-context/generation-metadata.json` when explicitly requested

Treat guidance as constraints for proposal and execution order.

## Default Execution Order

Use this default order unless a step is unavailable or clearly not applicable:

1. `maintain-agent-config`
2. `maintain-project-docs`
3. `plan-and-commit-work`

Apply these ordering rules:

- Do not generate or refresh `ai-context/` as part of local maintenance unless the user explicitly asks for that generated artifact.
- If docs change, run `plan-and-commit-work` last.

## Proposal Phase (Mandatory)

Before running any step, provide a workflow proposal that includes:

- selected mode (`optimistic` by default, unless user asks for `conservative`)
- which steps will run and why each applies
- which steps will be skipped and why
- expected files each step may touch
- low-risk actions allowed to continue automatically in optimistic mode
- approval gates required at workflow level and inside each underlying skill
- risks, uncertainty, and assumptions

Then stop and request explicit approval before executing any step.

## Execution Modes (After Workflow Approval)

When approval is explicit:

### Conservative Mode

1. Run one step at a time in default order.
2. Re-check applicability and skip with explanation when needed.
3. Stop before each stage and request explicit approval.
4. Preserve each underlying skill's approval requirements.
5. Stop immediately if a step raises risk, uncertainty, or asks for confirmation.

### Optimistic Mode (Default)

1. Run one step at a time in default order.
2. Re-check applicability and skip with explanation when needed.
3. After initial workflow approval, continue across low-risk steps without additional stage-by-stage stops.
4. Preserve each underlying skill's approval requirements for high-risk edits and git writes.
5. Stop immediately when risk/uncertainty appears or a protected approval gate is reached.
6. Request explicit approval before continuing past that gate.

In optimistic mode, the orchestrator may proceed without re-asking between low-risk stages when no edits outside allowed low-risk scopes are needed, including:

- running `maintain-agent-config` inspection/proposal
- running `maintain-project-docs` inspection/proposal
- continuing from one low-risk step to the next

## Expected File Touch Map

Use this map in the workflow proposal:

- `maintain-agent-config`: `AGENTS.md` (if present), `.codex/AGENTS.md`, `.ai/context`, `.claude/**`, `.codex/skills/**` (as approved)
- `maintain-project-docs`: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`
- `plan-and-commit-work`: no file edits by default; may run git write commands only with explicit approval

## Low-Risk Allowed Scopes (After Workflow Approval)

In `optimistic` mode, these are allowed without additional stage-by-stage approval:

- small `README.md` updates that only correct documented commands or references
- proposing doc updates without editing
- final commit planning without git writes

## Explicit Approval Gates (Always Required)

Always stop and request explicit approval before:

- editing `AGENTS.md`, `.codex/AGENTS.md`, `.ai/context`, `.claude/**`, or `.codex/skills/**`
- creating `CHANGELOG.md` or `CONTRIBUTING.md` if absent
- making large `README.md` rewrites
- staging files
- committing
- pushing
- destructive or history-changing git commands
- any work touching auth, secrets, infra, databases, payments, migrations, or backups

## Hard Constraints

- Do not directly edit project files while orchestrating, except when an approved underlying skill performs its own scoped edits.
- Do not replace underlying skills with ad-hoc edits.
- Do not auto-run any step without first proposing the workflow and receiving workflow approval.
- Do not weaken, skip, or merge away required approval gates.
- Do not auto-commit, auto-push, or perform destructive operations.

## Required Output Summary

Every workflow run must clearly state:

- mode used
- steps completed
- steps skipped
- changes made
- approvals still needed

## Trigger Phrases

- "maintain this repo"
- "run project maintenance"
- "refresh project workflow"
- "update repo context and docs"
- "run maintenance workflow"
- "prepare repo for GPT"
- "sync agent config docs and commits"
