---
name: security-review
description: Run a security review of the current diff or a specific file/directory against the OWASP top 10 and project checklist
argument-hint: [file-or-directory]
context: fork
allowed-tools: Bash, Read, Agent
---

Perform a security review.

Target: $ARGUMENTS (if empty, review the current staged diff via `git diff --cached`)

Steps:
1. If $ARGUMENTS is provided, read those files. Otherwise run `git diff --cached` to see what's changing.
2. Load the checklist:
!cat .claude/skills/security-review/checklist.md
3. Check each item in the checklist against the code under review
4. Report findings grouped by severity: Critical, High, Medium, Low
5. For each finding include: the file and line, what the vulnerability is, and a concrete fix
6. If no issues found, say so explicitly — don't invent findings
