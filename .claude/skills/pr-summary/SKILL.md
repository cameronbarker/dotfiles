---
name: pr-summary
description: Generate a PR title, summary, and test plan from the current branch's commits and diff
allowed-tools: Bash
---

Generate a pull request summary for the current branch.

1. Run `git log master...HEAD --oneline` to list commits on this branch
2. Run `git diff master...HEAD --stat` to see which files changed
3. Run `git diff master...HEAD` to read the full diff
4. Produce:
   - A PR title (under 70 characters, conventional commit style)
   - A Summary section with 2-4 bullet points explaining what changed and why
   - A Test plan section with a checklist of what to verify before merging
5. Output the result as markdown — ready to paste into `gh pr create --body`
