# Codex Usage

## Purpose

This document defines day-to-day expectations for using Codex in this repository.

## Defaults

- Prefer inspect-first on unclear tasks.
- Keep changes scoped and reviewable.
- Run relevant validation before handoff.
- Follow repository conventions in `AGENTS.md` and `.codex/AGENTS.md`.

## Dotfiles Validation Baseline

- `bash -n install.sh uninstall.sh`
- `shellcheck install.sh uninstall.sh .terminal terminal/*.sh` (if available)
