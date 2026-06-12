## GPT Routing / Usage Discipline

I use ChatGPT Desktop as my planning and reasoning layer, and Codex CLI as my repo execution layer.

Before doing significant work, classify the request:

Use ChatGPT Desktop when the task is:
- Architecture brainstorming
- Comparing approaches
- Learning or explanation
- Vague or underspecified
- Product/design thinking
- Writing high-level plans
- Drafting prompts, docs, or decision records
- Discussing home server, Proxmox, Docker, networking, backups, or security strategy before execution

Use Codex when the task requires:
- Reading local files
- Editing code
- Running tests or commands
- Debugging concrete failures
- Reviewing local diffs
- Inspecting repo-specific implementation details

If the request is better for ChatGPT Desktop:
1. Do not inspect the repo unless needed to answer.
2. Do not edit files.
3. Briefly say this is better handled in ChatGPT Desktop.
4. Provide a concise prompt I can paste into ChatGPT.
5. Ask me to return with the resulting plan if Codex execution is needed.

If the task is repo-grounded but unclear:
- Use inspect-only mode first.
- Summarize findings.
- Do not edit until the implementation goal is clear.

For existing codebases, use Codex inspect-only when the answer depends on current repo facts such as:
- Models, callbacks, routes, auth, database structure, migrations, dependencies, tests, or project conventions
- Current Docker, deployment, CI, service, or local development setup
- Existing file organization or naming patterns

When repo facts matter:
- Do not infer project-specific architecture from framework defaults.
- Inspect the smallest relevant set of files first.
- State what is known, what is missing, and whether edits are appropriate.
- Prefer summaries, error output, schema snippets, and narrow file reads over broad exploration.

For risky areas, prefer an inspect-only pass before execution unless I explicitly authorize changes. Risky areas include:
- Authentication and authorization
- Database schema and migrations
- Docker, Proxmox, networking, backups, or security-sensitive infrastructure
- Secrets, credentials, payments, destructive shell commands, or production data

When generating a ChatGPT handoff prompt:
- State the goal and the decision needed from ChatGPT.
- Include only the smallest useful context.
- Mention that ChatGPT does not have direct repo access.
- Ask ChatGPT to return a scoped Codex prompt if execution is needed.

If I explicitly say "Codex, handle this here", proceed in Codex even if ChatGPT could help.

## Git Guidance

Codex may use read-only git commands for context:
- `git status`
- `git diff`
- `git diff --staged`
- `git log --oneline -n 10`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git ls-files`

Codex must not perform git state changes unless I explicitly authorize them. This includes:
- Creating or switching branches
- Staging files
- Committing
- Pushing
- Merging
- Rebasing
- Resetting
- Cleaning
- Stashing

For cross-cutting or structural changes, Codex may recommend branch names, commit messages, and exact commands, but must not execute them without approval.

Before any destructive or history-rewriting git operation, Codex must stop and ask for confirmation.

## Secrets and credentials

- Never print secrets, tokens, keys, or credential file contents in responses or command output.
- Use placeholders in examples (for example `REDACTED`, `***`).
- Do not run commands that dump `.env`, credential JSON, private keys, keychains, or full environment listings unless I explicitly authorize it.
- Exec policy for high-risk secret commands lives in `~/.codex/rules/secrets-safety.rules` (installed from this repo via `./install.sh`).
- Before staging or committing, check for `.env`, `credentials.*`, and `*secret*` paths; do not commit them.

## Language Preferences

When writing one-off scripts, automation, or local tooling:

- Prefer Bash for shell automation, file operations, and simple orchestration.
- Prefer Ruby for general-purpose scripting when structure/readability is needed beyond Bash.
- Use Python when the task benefits from its ecosystem (data processing, CSV/JSON at scale, ML, plotting, or existing Python tooling).
- In an existing project, always default to the project's primary language, framework, and conventions.
- Do not introduce a new language/runtime into a project without a clear reason.
- If multiple languages are viable, choose the one with the smallest dependency footprint.

## Repo Tools First (AI Kit)

If `.codex/project.yml` exists, treat the repository as AI-kit bootstrapped and prefer deterministic repo tools before broad manual exploration when they are available on `PATH`.

At session or task start:
- Check for `.codex/project.yml`.
- Check command availability:
  - `command -v ai-risk`
  - `command -v ai-context`
  - `command -v ai-failure`
  - `command -v ai-codex-prompt`
- If `ai-context/` exists, read relevant generated files only for orientation.
- Do not generate or overwrite context automatically.

Tool-use policy:
- Use the smallest relevant tool for the task.
- Do not run all AI-kit commands for every prompt.
- If a tool is unavailable, continue with normal workflow and report AI kit was unavailable.

Inspect mode:
- When target paths are known, run `ai-risk --json <paths>`.
- Use existing `ai-context/` docs when present.
- Avoid broad repo exploration unless requested or needed.

Debug mode:
- For failing commands, prefer `ai-failure -- <command>`.
- Use the failure summary before deeper manual inspection.

Edit mode:
- Before editing known target files, run `ai-risk --json <paths>`.
- If risk is critical/blocking, stop and ask for explicit approval.
- If risk is high, inspect first and state risk before editing.
- Run narrow validation after changes.

Review mode:
- Run `ai-risk --json` on changed files when possible.
- Use risk output to structure severity and recommendations.

Context generation:
- Only run `ai-context --force` when explicitly requested by the user or when an edit prompt explicitly allows generated artifacts.
- Generated context is orientation-only; source files are authoritative.
