# Transcript: Pre-Commit Secret Scanner Agent Creation

## Task
Create an agent that reviews a git diff before a commit and flags hardcoded secrets, API keys, or connection strings. It must never modify files — report only.

## Step 1: Read the skill file
Read `~/.claude/skills/agent-creator/SKILL.md` in full to understand the agent template, required sections, and quality rubric before starting.

## Step 2: Capture Intent (from user request)

Extracted answers to skill Step 1 questions:

1. **Recurring workflow**: Scan git diff for secrets before committing.
2. **Outcome**: A report listing file, line, pattern type, and redacted excerpt for any matches. A clean bill of health if nothing is found.
3. **Trigger**: User is about to commit, or wants to audit a diff before pushing.
4. **Inputs needed**: The git diff (staged, or HEAD if nothing staged). The agent should run `git diff --staged` and `git diff HEAD` automatically — no manual input required from the user.
5. **Access needed**: Read-only git diff output. No file writes, no edits, no staging.
6. **Must never change**: Any file. Must not stage, unstage, commit, or run any git command beyond `git diff`.
7. **Done state**: Report produced listing all matches by severity, or a clear "no findings" statement.
8. **Validation**: None needed — this is a pure read-only analysis agent. Post-report, it recommends the user manually remediate any findings.
9. **Mode**: Inspect Only — the user explicitly stated "never modify files, just report."

## Step 3: Decide Whether to Create

This workflow is:
- Repeated (every commit is a potential trigger)
- Easy to scope (diff input → pattern match → report)
- Easy to validate (did it find what was there? did it modify anything?)
- Risky if done wrong (missing a real secret, or falsely mutating files)

Decision: Yes, worth creating.

## Step 4: Choose Mode

**Inspect Only.** The user explicitly said "never modify files." No ambiguity. This is a pure read-analyze-report agent.

## Step 5: Draft the Agent File

Key decisions made during drafting:

**Pattern checklist**: Rather than leaving the agent to invent what counts as a "secret," I embedded a concrete pattern table covering the most common credential types: AWS keys, generic API key/token/secret variable names, JWTs, private key blocks, connection strings with embedded credentials, DB password variables, webhook URLs, GitHub PATs, and Stripe/SendGrid keys. This makes the agent's behavior predictable and auditable.

**Severity tiers**: Added CONFIRMED / LIKELY / INFO to handle the ambiguous case (e.g., `password = "changeme"`). Without this, the agent would either miss real secrets or spam the user with false positives on placeholder values. The test prompts specifically cover this boundary.

**Diff targeting**: Default to `git diff --staged`. Fall back to `git diff HEAD` if nothing staged. This matches the user's stated intent ("before I commit") and avoids silently missing unstaged changes.

**Redaction in output**: Report the first 4 chars of secret values followed by `****`. This gives enough context to confirm the finding is real without the report itself becoming a credential leak.

**Stop conditions**: Explicitly listed that the agent must stop before modifying files, staging anything, or running git commands beyond the two diff commands. This is belt-and-suspenders given the Inspect Only mode designation.

**Test prompts**: Included 5 prompts covering: normal use, a boundary case asking the agent to both find and remove a secret (should refuse), a targeted scan, the placeholder ambiguity case, and a request to rotate keys (should refuse).

## Step 6: Quality Check Against Rubric

- **Scope**: Narrow. Owns diff scanning and reporting. Explicitly does not own remediation, rotation, or any git mutations.
- **Triggering**: Clear — "before I commit," "scan staged changes," "check diff for secrets."
- **Inputs**: Minimal — the agent runs the diff commands itself; user needs to provide nothing.
- **Workflow**: Step-by-step process with numbered steps, no ambiguity about what commands to run.
- **Safety**: Explicit stop conditions. No file writes allowed.
- **Validation**: N/A for read-only agent, but post-report recommendations are included.
- **Output**: Structured format with summary line, diff scanned, per-finding entries, and next-step recommendation.

## Output
Agent file saved to: `~/.claude/skills/agent-creator-workspace/iteration-1/secret-scanner/with_skill/outputs/agent.md`
