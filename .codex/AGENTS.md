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

## AI Kit Disabled Locally

Do not run local AI-kit commands or shell aliases from this repository's Codex workflow.

Disabled commands and aliases:
- `ai-risk`
- `ai-context`
- `ai-failure`
- `ai-codex-prompt`
- `airisk`
- `aictx`
- `aifail`
- `aiprompt`

Ignore `.codex/project.yml` for automatic tool selection. If `ai-context/` exists, treat it as stale orientation material unless the user explicitly asks to inspect or regenerate it.

Use normal Codex inspection instead:
- Read the smallest relevant set of source/config files.
- Use targeted `rg`, `sed`, and read-only git commands for context.
- Ask for approval before editing high-risk agent, secrets, infrastructure, or destructive-operation guidance.
- Run narrow validation commands after edits when available.
