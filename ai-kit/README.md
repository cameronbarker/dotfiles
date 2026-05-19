# AI Kit (Minimal v1)

Reusable Bash-first AI/Codex helpers that can be shared across repositories while keeping policy and context local to each project.

## Global vs project-local split

Global/reusable (this kit):
- `ai-kit/bin/ai-risk`
- `ai-kit/bin/ai-context`
- `ai-kit/bin/ai-failure`
- `ai-kit/bin/ai-codex-prompt`
- `ai-kit/lib/*.sh`
- `ai-kit/templates/*.example`

Project-local:
- `.codex/project.yml`
- `.codex/risk-paths.yml`
- generated `ai-context/*`

## Install/symlink suggestions (not executed)

```bash
chmod +x ai-kit/bin/*
mkdir -p ~/.local/bin
ln -sf "$PWD/ai-kit/bin/ai-risk" ~/.local/bin/ai-risk
ln -sf "$PWD/ai-kit/bin/ai-context" ~/.local/bin/ai-context
ln -sf "$PWD/ai-kit/bin/ai-failure" ~/.local/bin/ai-failure
ln -sf "$PWD/ai-kit/bin/ai-codex-prompt" ~/.local/bin/ai-codex-prompt
```

## Usage examples

```bash
ai-kit/bin/ai-risk --json .codex/AGENTS.md terminal/path.sh install.sh
ai-kit/bin/ai-context --force
ai-kit/bin/ai-failure -- bash -n install.sh uninstall.sh
ai-kit/bin/ai-codex-prompt inspect "assess dotfiles shell startup risk"
```

## Notes

- `ai-risk` exits non-zero only for critical/blocking outcomes.
- `ai-context` emits orientation-only documents; source files stay authoritative.
- `ai-context` refuses to overwrite non-empty `ai-context/` unless `--force` is provided.
- `ai-codex-prompt` only prints a prompt; it does not invoke Codex.
