---
name: tmux-workflow
description: Configure, tune, and troubleshoot tmux behavior with minimal, safe changes focused on day-to-day usability. Use when editing or reviewing `.tmux.conf`, adding keybindings, improving pane/window UX, validating tmux config loads, wiring dotfiles install/uninstall symlinks for tmux, or debugging why bindings are not taking effect.
---

# Tmux Workflow

## Overview

Use an inspect-first, minimal-change workflow for tmux so usability improves without fragile overconfiguration.

## Workflow

1. Inspect current tmux setup before editing.
2. Make the smallest change set that meets the requested behavior.
3. Validate by loading tmux with the target config.
4. Report exact bindings/options changed and how to reload.

## Invocation Modes

- `silent` mode: execute requested tmux actions and return no narrative/status text.
- `normal` mode: include findings and validation details.

Default to `silent` mode when the caller says they want no response, "just run it", or when this skill is being used as an internal helper by another skill.

## Inspect First

Check only the smallest relevant set of files:

- `.tmux.conf` or `tmux.conf`
- install/bootstrap scripts that symlink dotfiles (for example `install.sh`, `uninstall.sh`)

Use fast discovery commands:

```bash
rg --files | rg 'tmux|install\\.sh|uninstall\\.sh'
rg -n 'tmux|\\.tmux\\.conf|ln -sf|remove_symlink_if_ours' install.sh uninstall.sh README.md
```

Summarize what exists before edits:

- where tmux config lives
- whether install scripts manage `~/.tmux.conf`
- conflict behavior (`ln -sf`, backup-aware logic, or guarded removal)

## Minimal Edit Rules

Prefer compact, high-signal options. Avoid plugin frameworks or heavy theming unless explicitly requested.

Use these defaults when relevant:

- `set -g mouse on`
- `set -g focus-events on`
- `setw -g mode-keys vi`
- cwd-preserving splits via `split-window -c '#{pane_current_path}'`
- optional direct pane navigation with `bind -n M-h/j/k/l ...`
- conservative color/clipboard options compatible with iTerm2

Keep comments brief and only for non-obvious behavior.

## Safe Validation

Validate with the target file explicitly:

```bash
tmux -f .tmux.conf start-server \\; source-file .tmux.conf \\; display-message ok
```

If tmux socket access fails in a sandboxed environment, rerun with appropriate approval.

For script changes, run syntax checks:

```bash
sh -n install.sh
sh -n uninstall.sh
```

## Dotfile Linking Safety

When adding tmux install support, avoid clobbering user files.

Preferred install behavior for `~/.tmux.conf`:

1. If destination is a symlink, refresh it.
2. If destination is a real file/dir, move to timestamped backup, then symlink.
3. If destination is missing, create symlink.

Preferred uninstall behavior:

- remove only symlinks that point to this repo (`remove_symlink_if_ours`).

## Troubleshooting Checklist

If bindings do not work:

1. Confirm loaded file path (`~/.tmux.conf` may not exist).
2. Source the intended config path directly.
3. Check active bindings:

```bash
tmux list-keys -T prefix
tmux list-keys -T root
```

4. Verify terminal Meta/Alt behavior in iTerm2 when using `M-` bindings.

## Response Checklist

In `normal` mode, return:

- files changed
- exact options/bindings added or modified
- validation command result
- reload command (`tmux source-file ~/.tmux.conf` or explicit path)
- any manual iTerm2 setting to verify (Meta/Alt handling, clipboard access)

In `silent` mode, do not return narrative output.
