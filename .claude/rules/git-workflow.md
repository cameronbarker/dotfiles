---
description: Git and GitHub workflow conventions
---

# Git Workflow

## Commits
- Use conventional commit format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore, ci
- Keep subject line under 72 characters
- No `--no-verify` or `--no-gpg-sign` unless explicitly asked
- Create new commits rather than amending unless explicitly asked to amend
- Ask for explicit approval before any git state-changing command (`git add`, `git commit`, `git stash`, `git push`, `git merge`, `git rebase`, `git reset`, `git clean`)

## Branching
- Ask before force-push, reset --hard, or any destructive git operation
- Never force-push to main or master

## Pull Requests
- Use `gh pr create` for all PR creation
- PR title under 70 characters
- Include a Summary section and Test plan in the body
- Ask for confirmation before pushing to remote

## Safety
- Stage specific files by name, not `git add -A` or `git add .`
- Do not commit `.env`, credentials, or large binaries
- Check `git status` and `git diff` before committing to understand what's staged
