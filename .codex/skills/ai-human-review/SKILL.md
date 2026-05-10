---
name: ai-human-review
description: Run a generic human-in-the-loop review and approval workflow for AI-generated actions using tmux panes and vim-editable artifacts, with explicit machine-detectable approval before execution.
---

# AI Human Review

## Overview

Use this skill to enforce explicit human approval before side-effectful AI actions.

This skill is generic and domain-agnostic. Domain skills (for example Jira, docs, infra, data ops) should call this skill to gather approved items, then execute their own domain-specific actions.

## Workflow

1. Generate draft artifacts for review.
2. Open a tmux pane for human review/edit.
3. Wait for explicit machine-detectable approval.
4. Extract approved items only.
5. Execute side effects in the calling domain skill.
6. Persist run artifacts for auditability.

## Required Safety Rules

- Never treat visual display as approval.
- Never execute side effects unless approval fields are present and valid.
- If approval cannot be verified, abort with a non-zero exit code.
- Preserve artifacts on failure for troubleshooting.

## Run Artifacts

Default run root: `/tmp/ai-review-runs/<run-id>`.

Required files per run:

- `review.yaml`: machine-readable review + approval source of truth
- `preview.md`: human-readable summary
- `status.json`: workflow state metadata

## Approval Contract

Default approval method is file-token approval in `review.yaml`.

Required global approval fields:

- `approved_by`: non-empty string
- `approved_at`: ISO8601 timestamp string

Per-item approval field:

- `approved`: boolean

No approved items means no side effects.

## Script Interface

Scripts live in `scripts/`.

- `start-review.sh --out-dir <dir> [--run-id <id>] [--context <text>]`
- `open-review-pane.sh --review-file <path> --preview-file <path> [--editor nvim|vim]`
- `wait-for-approval.sh --review-file <path> [--timeout-sec <n>] [--poll-sec <n>]`
- `collect-approved.sh --review-file <path> [--format json]`

Exit codes:

- `0` success
- `10` no approved items
- `20` invalid schema/approval contract
- `30` timeout/cancel

## Integration Pattern for Domain Skills

1. Domain skill writes candidate `items` into `review.yaml`.
2. Domain skill writes corresponding `preview.md`.
3. Call `open-review-pane.sh`.
4. Call `wait-for-approval.sh`.
5. Call `collect-approved.sh`.
6. Execute domain actions only from collected approved output.

## Detectable Human Interaction

Reliable signals:

- edits saved to `review.yaml`
- explicit approval fields set
- schema-valid file state

Do not infer approval from cursor movement, pane focus, or the file being opened.
