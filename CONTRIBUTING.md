# Contributing

This repo is personal dotfiles and tooling. Contributions are welcome when they match the project’s goals (cross-platform shell/editor/git setup, safe install/uninstall scripts, clear docs).

## Before you change anything

1. Read **[`AGENTS.md`](AGENTS.md)** — structure, commands, style, testing posture, PR and security expectations.
2. If you use **Codex** or other agents in this clone, read **[`.codex/AGENTS.md`](.codex/AGENTS.md)** — routing, inspect-first rules, and **no git writes** (add/commit/push/etc.) without explicit human approval.

## Local setup

- Clone and use the installer from the repo root; see **[`README.md`](README.md)** for flags (`./install.sh`, `./install.sh --zsh`, `--git`, `--no-apt`, etc.).
- Prefer validating script changes in a disposable environment (container or VM) before relying on them on your main machine.

## Validation (required for script/shell changes)

From the repo root (see `AGENTS.md`):

```sh
bash -n install.sh uninstall.sh
```

If `shellcheck` is installed:

```sh
shellcheck install.sh uninstall.sh .terminal terminal/*.sh
```

Also verify **idempotency**: running `./install.sh` twice should not duplicate shell marker blocks in `~/.bashrc` / `~/.zshrc`.

## Commits and pull requests

- Use **Conventional Commits** (e.g. `feat(install): …`, `docs(readme): …`, `fix(uninstall): …`).
- Keep the subject line concise and imperative.
- PRs should include:
  - A short summary of behavior and files touched
  - A **test plan** with the exact commands you ran (including `bash -n` / `shellcheck` when applicable)
  - **Platform notes** if behavior differs on macOS vs Debian/Ubuntu (or Linux without apt)

## Documentation and changelog

- User-facing behavior changes should eventually appear in **[`CHANGELOG.md`](CHANGELOG.md)** under `[Unreleased]` (or a dated release section when you version releases).
- Keep **[`README.md`](README.md)** aligned with real `install.sh` / `uninstall.sh` flags and paths; do not document commands that are not in the repo.

## Secrets and safety

- Do not commit secrets, tokens, machine-specific credentials, or large generated artifacts.
- Uninstall flags can remove user data or system paths (e.g. Neovim under `/opt/nvim`, `~/.vim/plugged`); document risky behavior in PRs when you touch those flows.
