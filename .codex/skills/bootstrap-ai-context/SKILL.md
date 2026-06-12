---
name: bootstrap-ai-context
description: Bootstrap repo-local AI kit configuration by inspecting a codebase and proposing `.codex/project.yml` plus `.codex/risk-paths.yml` without editing by default. Use when asked to initialize Codex AI kit config, scaffold project/risk YAML, assess repo commands and risk zones, or prepare safe inspect-first AI configuration for an existing repository.
---

# Bootstrap AI Context

Inspect a repository and bootstrap minimal, safe repo-local AI kit config for Codex.

## Scope

- Default to inspect-only mode.
- Inspect root and config files first; do not broaden discovery unless the user explicitly asks.
- Detect and summarize:
  - project name
  - project type
  - primary languages
  - package manager
  - test/lint/typecheck/build commands
  - existing AI instruction files
  - obvious risky paths
- Propose only:
  - `.codex/project.yml`
  - `.codex/risk-paths.yml`
- Do not edit unless the user explicitly asks to create/apply files.
- Do not run `ai-context` generation by default.
- Do not commit files.

## Required Workflow

1. Start inspect-only unless the user explicitly requests file creation.
2. Read the smallest useful set of root/config files, such as:
   - `README*`
   - `AGENTS.md`, `.codex/AGENTS.md`, `.ai/context`, `.claude/CLAUDE.md`
   - primary manifest/config candidates (`package.json`, `Gemfile`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Makefile`, `justfile`, `docker-compose.yml`, `Dockerfile`, CI config)
3. Infer project facts from inspected files only. Mark unknowns explicitly.
4. Identify likely risk paths from visible structure and config.
5. Produce proposed YAML for both target files.
6. Stop and request explicit confirmation before writing files.
7. If confirmed, create only `.codex/project.yml` and `.codex/risk-paths.yml` unless broader edits are explicitly authorized.
8. After editing, run:
   - `ai-risk --json README.md || true`
   - `ai-codex-prompt inspect assess repo bootstrap`
9. Report outputs, limitations, and next-step options.

## Discovery Rules

- Prefer narrow file reads and targeted path checks over broad scans.
- Keep include paths precise and useful.
- Do not use broad `**/*` includes unless explicitly justified in the report.
- Never include secrets or sensitive raw values in generated YAML.
- If coverage is partial, state exactly what was inspected and what was not.

## High-Risk Handling

Treat these areas as high risk and prefer strict inspect-only guidance unless explicitly authorized:

- authentication/authorization
- payments/billing
- secrets/credentials/key material
- infrastructure/production configuration
- database models, schema, migrations, backups
- Docker/networking
- destructive scripts/operations

When present, bias `.codex/risk-paths.yml` toward conservative review requirements.

## Output Contract

For inspect-only mode, return:

- detected facts
- proposed `.codex/project.yml`
- proposed `.codex/risk-paths.yml`
- risk notes and assumptions
- exact edit prompt the user can approve

For edit mode, return:

- files created
- validation commands run
- key command outputs
- limitations or unresolved unknowns
- recommended next step

## Proposal Templates

Use these structures as a starting point and adapt to inspected facts.

```yaml
# .codex/project.yml (proposed)
project:
  name: <detected-or-repo-name>
  type: <library|cli|web-app|service|dotfiles|unknown>
  languages:
    - <primary-language>
  package_manager: <npm|pnpm|yarn|bundler|pip|poetry|cargo|go|unknown>

commands:
  setup: []
  test: []
  lint: []
  typecheck: []
  build: []

ai_instructions:
  detected_files: []
  notes: []

discovery:
  inspected_paths: []
  unknowns: []
```

```yaml
# .codex/risk-paths.yml (proposed)
risk_paths:
  high:
    - path: <path>
      reason: <why high risk>
      guidance: inspect-only-until-approved
  medium:
    - path: <path>
      reason: <why medium risk>
      guidance: review-before-edit
  low: []

global_rules:
  secrets: never-include-raw-values
  destructive_ops: require-explicit-approval
  broad_includes: avoid-unless-justified
```

## Examples

### Ruby CLI or Library

- Detect from `Gemfile`, `*.gemspec`, `Rakefile`, `lib/`, `bin/`.
- Typical commands:
  - test: `bundle exec rspec` or `bundle exec rake test`
  - lint: `bundle exec rubocop`
  - typecheck: `bundle exec steep check` (if present)
- Typical high-risk paths:
  - `lib/**/auth*`, `config/credentials*`, `db/migrate/`

### Node Web App

- Detect from `package.json`, framework config (`next.config.*`, `vite.config.*`, etc.), `src/`, `app/`.
- Commands come from `package.json` scripts.
- Typical high-risk paths:
  - `src/auth/`, `pages/api/` or `app/api/`, `prisma/migrations/`, `docker/`, `.github/workflows/`

### Python Package

- Detect from `pyproject.toml`/`setup.cfg`/`requirements*.txt`, `src/`, package directory.
- Typical commands:
  - test: `pytest`
  - lint: `ruff check .`
  - typecheck: `mypy .`
  - build: `python -m build`
- Typical high-risk paths:
  - package auth modules, migration folders, deployment scripts, secrets config

### Generic Unknown Repo

- Keep type as `unknown` with explicit unknowns.
- Propose minimal, conservative YAML with empty command arrays when undiscoverable.
- Add only clearly evidenced risk paths and avoid speculative includes.

## Edit Prompt To Offer User

Use this exact style after inspect-only output:

`If you want me to apply this, say: "Create .codex/project.yml and .codex/risk-paths.yml using this proposal."`
