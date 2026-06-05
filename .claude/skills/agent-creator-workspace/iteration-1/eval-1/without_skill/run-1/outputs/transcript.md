# Transcript: Secret Scanner Agent Creation

## Task

Create an agent .md file for a workflow that reviews a git diff before a commit and flags hardcoded secrets, API keys, or connection strings. The agent must never modify files — only report findings.

## Approach

The task is straightforward: define a read-only agent with clear pattern coverage, an unambiguous output format, and explicit constraints preventing any file or git state changes.

The main design decisions were:

1. **What to scan**: I expanded from the bare minimum (API keys) to a practical set covering the most common real-world secret leaks — AWS/GCP/GitHub tokens, generic credential variable assignments, database connection strings with embedded credentials, PEM private key headers, and high-entropy strings in credential-named variables.

2. **How to handle false positives**: A scanner with no false positive guidance becomes noise. I added explicit rules to skip env var references, placeholder strings, and to downgrade test fixture hits to low severity rather than hard failures.

3. **Output format**: Two clearly differentiated states — findings present (with file, line, severity, and description) vs. clean scan. The clean state includes a disclaimer that pattern matching has limits.

4. **Constraints section**: Explicitly listing what the agent must NOT do (write files, run state-changing git commands) is the most important part for a read-only audit agent. It prevents accidental "helpfulness" from breaking the safety guarantee.

## What was not included

- No fuzzy entropy scoring beyond the high-entropy string heuristic — that would require tooling beyond a simple agent prompt.
- No integration with external secret scanning services (e.g., truffleHog, gitleaks) — the agent is self-contained.
- No auto-remediation suggestions beyond pointing to the line — the agent's job is detection, not fixing.

## Output

Agent saved to: `~/.claude/skills/agent-creator-workspace/iteration-1/secret-scanner/without_skill/outputs/agent.md`
