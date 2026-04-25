# AI Context

Generated orientation docs for GPT Project Sources.

`ai-context/` is planning context, not source of truth. For implementation or execution,
Codex must inspect live repo files first.

## Files

| File | Purpose |
| --- | --- |
| `project-overview.md` | Purpose, scope, stack, and repo shape |
| `architecture-map.md` | Install/uninstall and runtime flow map |
| `commands.md` | Known commands and safe verification checks |
| `integration-points.md` | Local/external integration surfaces |
| `risk-zones.md` | Areas requiring fresh inspect-only review |
| `generation-metadata.json` | Freshness metadata and inspected source list |

## Usage

- Upload only `ai-context/` docs to GPT Project Sources.
- Regenerate when branch, commit, or working tree state changes.
- Keep GPT/Codex separation: GPT plans, Codex verifies in live files before execution.
