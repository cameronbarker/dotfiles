# Global Preferences

## Response Style
- Keep responses concise and direct
- No trailing summaries after completing tasks
- No emojis unless explicitly requested
- Use conventional commit format: `type(scope): description`

## Development Workflow
- Use `gh` CLI for all GitHub operations (issues, PRs, repos)
- Prefer running `git` commands to understand repo state before making changes
- Run tests before reporting a task complete when test commands are available
- Ask before running destructive operations even in auto mode

## Code Conventions
- No comments unless the WHY is non-obvious (hidden constraint, subtle invariant, workaround)
- No docstrings or multi-line comment blocks
- No TODO/FIXME comments unless asked
- Prefer editing existing files over creating new ones
- No features, abstractions, or error handling beyond what the task requires

## Shell & Tools
- Prefer `rg` (ripgrep) over `grep` when available
- Prefer `bat` over `cat` when available
- Use absolute paths in scripts for portability
