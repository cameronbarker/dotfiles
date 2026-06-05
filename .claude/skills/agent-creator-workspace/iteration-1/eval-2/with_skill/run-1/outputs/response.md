# Scope Narrowing Required

The request describes a "Full Stack Senior Engineer Agent" — a broad persona, not a workflow. This is exactly the pattern the skill explicitly calls out as a bad idea:

> Bad idea: `Full Stack Senior Engineer Agent`

An agent needs a specific recurring workflow, a measurable done state, and clear ownership boundaries. "Handles all frontend and backend work" fails all three criteria — it cannot be validated, cannot have meaningful stop conditions, and cannot be tested for overreach.

## Why This Cannot Be One Agent

- No single done state: code reviews, deployments, and migrations each have different success criteria
- No ownership boundary: "whatever else is needed" explicitly invites scope creep
- No safe default mode: some workflows (deployments, migrations) require Infra Cautious mode; others (code review) are Inspect Only; others (bug fixes) are Debug or Edit
- Cannot be validated: there is no test prompt that exercises this agent without being equally broad

## Proposed Focused Agents

Each of these represents a real, repeatable workflow with a measurable done state:

### 1. PR Code Review Agent
Inspect Only. Reviews a pull request diff, identifies bugs, pattern violations, and risk zones. Stops before suggesting architectural changes. Produces a structured review with file-level findings.

### 2. Bug Fix Agent
Debug mode. Given a failing test, stack trace, or reproduction case — traces the root cause, makes the minimal fix, runs targeted validation, and reports what changed and what remains risky.

### 3. Database Migration Agent
Infra Cautious. Given a schema change requirement, inspects existing migration patterns, generates the migration file following project conventions, and stops before running it. Never runs destructive operations without explicit approval.

### 4. Deployment Readiness Agent
Inspect Only. Checks a branch for deployment blockers: failing CI, unreviewed migrations, unresolved lint errors, missing env vars, or dependency issues. Produces a go/no-go report with blockers listed.

### 5. Performance Audit Agent
Inspect Only. Given a slow endpoint, query, or component — profiles the relevant code path, identifies N+1 queries, missing indexes, unnecessary re-renders, or oversized payloads. Reports findings with severity and recommended fix. Does not edit without explicit confirmation.

---

## Recommendation

Pick the workflow you run most often and start there. The Bug Fix Agent and PR Code Review Agent are the safest starting points — they have clear inputs (a failing test or a diff), a clear done state, and low risk of destructive behavior.

If you want to proceed, tell me which workflow to build first and I will produce the full agent file, test prompts, and validation commands.
