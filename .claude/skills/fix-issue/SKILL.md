---
name: fix-issue
description: Fetch a GitHub issue by number, understand the problem, implement a fix, and open a PR
argument-hint: <issue-number>
allowed-tools: Bash, Read, Edit, Write, Agent
---

Fetch and fix GitHub issue #$ARGUMENTS.

1. Run `gh issue view $ARGUMENTS` to read the issue title, body, and comments
2. Explore the codebase to find the relevant code — use `rg` to search for symbols mentioned in the issue
3. Reproduce the problem if possible (run tests, check logs)
4. Implement the minimal fix required — no refactoring beyond the scope of the issue
5. Run existing tests to confirm nothing regresses
6. Create a commit: `fix: <issue title in lowercase>` referencing the issue
7. Open a PR with `gh pr create` — include "Closes #$ARGUMENTS" in the body
