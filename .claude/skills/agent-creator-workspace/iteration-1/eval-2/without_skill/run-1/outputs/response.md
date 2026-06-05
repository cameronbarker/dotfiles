This request is too broad to build an effective agent from. An agent that handles "all frontend and backend work" across code reviews, bug fixes, deployments, database migrations, performance tuning, and "whatever else" will:

1. **Perform poorly at everything** — agents with tightly scoped responsibilities outperform generalist ones because the context, prompting, and decision logic can be tuned to a specific problem shape
2. **Be impossible to evaluate** — there's no clear success criterion for "handles everything"
3. **Create unpredictable behavior** — broad scope means the agent will make judgment calls about what "needs doing," which leads to surprises

**What I'd recommend instead:**

Break this into focused agents for distinct work modes:

- `code-reviewer` — reviews PRs against a defined checklist (style, correctness, security surface)
- `bug-investigator` — takes a failing test or error report, traces it to root cause, proposes a fix
- `migration-writer` — generates database migration files from a schema diff or feature description
- `deploy-verifier` — runs pre-deploy checks, verifies environment parity, reports blockers
- `perf-analyzer` — profiles a specific endpoint or query, identifies bottlenecks, suggests fixes

Each of these has a clear input, a clear output, and a defined scope of authority. They can be composed into a workflow if needed.

**If you still want a single agent**, I'd need answers to:

1. What is the primary trigger — is this agent invoked on a PR? An issue? A deploy event? Something else?
2. What decisions is it allowed to make autonomously vs. flagging for human review?
3. What does "deployments" mean in your stack — what tooling, what environments?
4. What does success look like for a single run of this agent?

Without those constraints, I'd be writing a prompt that sounds impressive but won't reliably do useful work.
