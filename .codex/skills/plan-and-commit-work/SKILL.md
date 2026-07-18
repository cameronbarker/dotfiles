---
name: plan-and-commit-work
description: Review completed local git changes, propose a safe commit plan, and only execute git write actions after explicit user approval. Use when asked to plan commits, commit this work, make the commit, create commits from current changes, review changes and commit, split this work into commits, or prepare commit messages.
---

# Plan And Commit Work

Plan clean, reviewable commits from current local changes. Default to planning first, then require explicit approval before any git write action.

## Required Guidance Pass

Read repository guidance before planning commits:

- `AGENTS.md` (if present)
- `.codex/AGENTS.md` (if present)
- repo-specific git workflow docs when present (for example `.claude/rules/git-workflow.md`)

If guidance files conflict, follow higher-priority system/developer/user instructions first, then repo guidance.

## Read-Only Inspection Commands

Inspect git state with read-only commands only:

- `git status --short`
- `git branch --show-current`
- `git diff`
- `git diff --staged`
- `git log --oneline -n 10`

Use additional read-only commands only when needed to clarify uncertainty (for example `git ls-files` or targeted file reads).

## Commit Plan Output

Produce a commit plan that includes:

- current branch
- staged vs unstaged summary
- changed files grouped by intent
- recommended commit grouping (one or multiple commits)
- recommended commit message(s)
- exact git commands that would be run
- risks, uncertainty, and assumptions

When work is cross-cutting or non-trivial, recommend a branch name and explain why.

If diff is large, mixed, or unclear, stop after planning and ask for confirmation before any git write action.

## Confirmation Gate (Mandatory)

Before any git write action, stop and ask for explicit approval.

Never run these commands without explicit approval:

- `git switch` / `git checkout`
- `git add`
- `git commit`
- `git push`
- `git stash`
- `git reset`
- `git clean`
- `git merge`
- `git rebase`
- `git cherry-pick`

Explicitly state what command(s) will run and which files are included before executing.

## Execution After Approval

If user approval is explicit:

1. Stage only approved files and hunks.
2. Create only the approved commit(s) with approved message(s).
3. Show resulting `git status --short`.
4. Do not push unless separately approved.

## Safety Rules

- Never commit secrets, `.env` files, credentials, tokens, private keys, or generated junk.
- Never rewrite history unless explicitly authorized.
- Never run destructive git commands without explicit confirmation.
- Never push unless explicitly authorized.
- Recommend the narrowest relevant test command before commit when applicable, but do not invent commands that are not discoverable from the repo.

## Trigger Phrases

This skill should trigger for requests like:

- "plan commits"
- "commit this work"
- "make the commit"
- "create commits from current changes"
- "review changes and commit"
- "split this work into commits"
- "prepare commit messages"
