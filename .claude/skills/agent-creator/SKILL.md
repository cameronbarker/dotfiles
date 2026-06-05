---
name: agent-creator
description: Create, improve, evaluate, and optimize AI agent markdown files. Use this skill whenever the user wants to create a new agent, write an agent .md file, improve an existing agent, define agent scope, design agent workflows, create agent eval prompts, compare agent effectiveness, or turn a recurring workflow into a reusable agent. Trigger when the user says things like "create an agent for X", "write me an agent that does Y", "I want an agent to handle Z", "help me design an agent", "make a reusable agent", or "turn this workflow into an agent".
---

# Agent Creator

A skill for creating focused AI agent markdown files that accomplish meaningful work within a specific scope.

A good agent file is not a broad persona. It is an operating contract that tells the agent:

- what it owns
- what it does not own
- when it should be used
- what inputs it needs
- what workflow it should follow
- what tools or repo areas it may inspect
- what changes it may make
- when it must stop and report
- how to validate the work
- what final output proves the work is complete

The process:

1. Capture the user's intended workflow.
2. Decide whether the workflow should become an agent.
3. Define the agent's scope and boundaries.
4. Draft the agent `.md` file.
5. Create realistic test prompts.
6. Evaluate whether the agent produces useful, scoped work.
7. Revise based on failures, ambiguity, or overreach.
8. Repeat until reliable.

Figure out where the user is in that process and help them move forward. If starting from scratch, begin at Step 1. If the user brings an existing agent for review or improvement, skip to [Improving an Existing Agent](#improving-an-existing-agent). If they've run it and got poor results, diagnose the failure using the [Agent Review Rubric](#agent-review-rubric).

---

## Communicating with the user

Use direct, practical language. Prefer:

- "test prompts" over "evals" when the user seems non-technical
- "done criteria" over "completion contract"
- "what the agent is allowed to touch" over "permissions boundary"

Be candid. If the requested agent is too broad, say so and narrow it.

Bad idea: `Full Stack Senior Engineer Agent`

Better: `API Contract Agent that compares backend OpenAPI changes against frontend usage and updates typed client methods`

The right abstraction is one agent per recurring workflow with a measurable done state.

---

## Step 1: Capture Intent

Extract from context before asking questions. Answer:

1. What recurring workflow should this agent perform?
2. What specific outcome should it produce?
3. When should this agent be used? What triggers it?
4. What inputs does it need?
5. What files, folders, systems, or tools does it need access to?
6. What should it never change?
7. What counts as "done"?
8. What validation should it run?
9. Should the agent inspect first, edit directly, debug, review, or operate cautiously?

Ask only for the smallest useful missing information.

---

## Step 2: Decide Whether an Agent Is Worth Creating

Create an agent when the workflow is:

- repeated often
- specialized enough to need dedicated instructions
- easy to scope and validate
- likely to benefit from consistent behavior
- risky enough that boundaries matter

Do not create an agent when the workflow is:

- a one-off task
- too vague or mostly brainstorming
- too broad to validate
- dependent on unknown project context
- better handled by a human decision

If the request fails these criteria: tell the user directly, then either decline, propose a narrower scoped alternative, or suggest handling it inline without an agent.

If the request is too broad, propose narrower agents. Example — user asks for "frontend agent", suggest:

- Angular API Integration Agent
- Frontend Test Coverage Agent
- Accessibility Review Agent
- Component Refactor Agent

---

## Step 3: Choose Agent Mode

Every agent should have a default mode.

**Inspect Only** — read, analyze, report without changes. Use for: risky areas, auth, payments, infra, database schemas, migrations, large refactors, architecture discovery.

**Edit** — may make scoped changes. Use for: small implementation tasks, docs updates, adding tests, following established patterns.

**Debug** — given a concrete failure. Use for: test failures, stack traces, broken commands, regression investigation.

**Review** — evaluate existing work. Use for: pull request review, diff review, architecture critique, refactor suggestions.

**Infra Cautious** — touches infra, secrets, deployments, networking, containers, databases, or destructive operations. Default: inspect first, stop and report before changing anything.

---

## Description Optimization

A good description includes:
- what the agent does
- when to use it
- the type of task it handles
- relevant keywords users might say
- boundaries that distinguish it from nearby agents

Example:
```
Use this agent to compare backend API contracts against frontend usage, identify missing
or stale client integrations, and implement typed API client methods when edits are allowed.
Trigger this agent when the user mentions OpenAPI, API contracts, endpoint usage, frontend
API clients, Angular services, backend endpoint changes, or checking whether a frontend
app already uses an endpoint.
```

Avoid: `Helps with frontend work.` — this triggers poorly and produces vague work.

---

## Agent File Template

```markdown
# Agent: <Agent Name>

## Purpose
A short description of the specific work this agent performs.

## When to Use
Use this agent when:
- ...

Do not use this agent when:
- ...

## Mode
Default mode: <Inspect Only | Edit | Debug | Review | Infra Cautious>

## Scope
### Owns
- ...

### Does Not Own
- ...

## Required Inputs
- ...

## Context to Inspect
- ...

## Workflow
1. ...
2. ...
3. ...

## Decision Rules
- ...

## Safety / Stop Conditions
Stop and report before:
- ...

## Validation
Run or recommend:
- ...

## Output Format
Return:
- Summary
- Files inspected
- Files changed (if edits are allowed)
- Commands run
- Findings
- Risks
- Recommended next step
```

---

## Writing Good Agent Instructions

- Mission: name the agent and its specific job, not a persona ("API Contract Agent" not "senior engineer")
- Ownership: list what it owns and what it does not own — be explicit on both sides
- Workflow: give it numbered steps; do not rely on the model to invent a process
- Safety / Stop Conditions: name the specific risky areas where it must pause and report
- Validation: prefer the narrowest command; if it can't be run, say so and give the exact command
- Output: require files inspected, files changed, commands run, and risks in every response

---

## Generating Evals

After drafting an agent, generate an `evals/evals.json` file alongside it. This turns the test prompts into runnable, gradeable assertions — the same infrastructure that can be used to benchmark the agent against a baseline.

Save it to `evals/evals.json` in the same directory as the agent `.md` file.

### Two tiers of assertions

Every eval has two types of assertions:

**Structural assertions** — verify the agent file itself is well-formed. Use these for every agent:
- "Agent file contains a ## Mode section"
- "Agent file contains a ## Scope section with ### Owns and ### Does Not Own subsections"
- "Agent file contains a ## Safety / Stop Conditions section"
- "Agent file contains a ## Validation section"
- "Agent file contains a ## Workflow section with numbered steps"
- "Agent file does not use generic persona language like 'senior engineer' or 'expert'"

**Behavioral assertions** — verify the agent does what it claims when run. Derive these from the agent's specific Purpose, Mode, Workflow, and Stop Conditions. They must be checkable by reading the output or transcript.

For an **Inspect Only** agent:
- "Agent does not create or modify any files during the run"
- "Output contains findings with file path and line number or location"
- "Agent runs only read-only commands"

For an **Edit** agent:
- "Agent edits only files within its declared scope"
- "Agent runs a validation command after making changes"
- "Agent reports what changed and what was not touched"

For a **Debug** agent:
- "Agent identifies the specific failing assertion or error message"
- "Agent makes only the smallest change needed to fix the failure"
- "Agent re-runs the failing test and reports the result"

For an **Infra Cautious** agent:
- "Agent stops and reports before making any changes to infrastructure config"
- "Agent does not run destructive commands without explicit confirmation"

### evals.json schema

```json
{
  "agent_name": "<agent-name>",
  "evals": [
    {
      "id": 1,
      "prompt": "A realistic task the agent would actually be given",
      "expected_output": "Description of the correct result",
      "files": [],
      "expectations": [
        "Structural: agent file contains a ## Mode section",
        "Structural: agent file contains a ## Stop Conditions section",
        "Behavioral: agent does not modify any files",
        "Behavioral: output contains at least one finding with file path and location"
      ]
    }
  ]
}
```

### Writing good assertions

Good assertions are specific and falsifiable — they pass when the agent works correctly and fail when it doesn't.

Weak (passes for any output):
- "Agent produces a useful report"
- "Agent does something with the input"

Strong:
- "Output contains at least one finding with a file path and line number"
- "No files in the working directory were modified during the run"
- "Agent reports the specific type of issue found (not just 'something is wrong')"

### Prompt selection

Create 2–5 prompts covering:
- The normal happy path
- A near-boundary case where the agent might overreach (e.g., asked to also fix what it found — tests that the agent refuses and stays in its mode)
- A trivial or empty input (e.g., a clean diff with nothing to flag)

Near-boundary prompts are the most valuable — they test whether stop conditions hold under pressure.

---

## Evaluating an Agent

Evaluate both behavior and restraint.

A good agent:
- stays inside scope
- inspects before editing
- avoids broad repo exploration
- follows existing patterns
- makes small changes
- validates the work
- stops before risky changes
- reports uncertainty clearly
- avoids inventing project facts
- produces a useful final summary

A bad agent:
- is too broad
- changes unrelated files
- invents architecture
- skips validation
- asks for too much context
- ignores existing conventions
- turns an inspect task into an edit task
- makes risky changes without approval
- reports vague success

---

## Agent Review Rubric

**Scope**: Is the job specific? Does it have a clear done state? Does it define what it owns and does not own?

**Triggering**: Is it clear when to use this agent? Are there examples of when to use it and when not to?

**Inputs**: Does it know what context it needs without asking for too much?

**Workflow**: Does it have a repeatable process? Does it inspect before editing? Does it follow existing conventions?

**Safety**: Does it stop before risky areas? Does it require confirmation for auth, payments, infra, migrations, secrets, or deletes?

**Validation**: Does it define what commands to run? Does it prefer narrow validation?

**Output**: Does it produce a useful final report with files inspected, files changed, commands run, and risks?

---

## Improving an Existing Agent

1. Preserve the original intent unless the user asks to change it.
2. Identify where the current agent is too broad, too vague, or too risky.
3. Add missing ownership boundaries, stop conditions, validation, and output format.
4. Remove generic persona language that does not improve behavior.

Generalize from failures — do not overfit to one example.

Bad fix:
```
Never edit UserService.ts.
```

Better fix:
```
Do not edit domain service files unless the task explicitly requires behavior changes
outside the API client layer.
```

---

## Final Response Format

When this skill creates or improves an agent, respond with:

```markdown
## Agent Created / Updated
<agent name>

## What It Is For
<brief explanation>

## Recommended Path
<path>

## Agent File
<full markdown>

## Evals File
Path: <path>/evals/evals.json
<full evals.json content>

## Notes
<any risks, limitations, or follow-up recommendations>
```

Always include the Evals File section. If the user did not ask for tests, include them anyway with a note that they can be removed — a new agent without assertions is harder to improve later.

---

## Packaging

Suggested path: `agents/<agent-name>.md`

For Codex-style projects: `.codex/agents/<agent-name>.md`

If the project already has agent files, follow its convention — check for existing `.md` files in agent-like directories before choosing a path. When unsure, prefer `.claude/agents/` for Claude Code projects and `agents/` otherwise.

---

## Core Principle

When scope is unclear, narrow it. One agent per workflow. One workflow per measurable done state. An agent that does less reliably is more useful than one that does more inconsistently.
