# Transcript: Agent Improvement — Project Task Automation Agent

## Inputs

- Skill: `~/.claude/skills/agent-creator/SKILL.md`
- Weak agent: `~/.claude/skills/agent-creator/evals/files/weak-agent-sample.md`

---

## Step 1: Read and Diagnose the Weak Agent

The original agent file:

```markdown
# Agent: Project Automation Agent

## Purpose
I am a senior software engineer agent. I help with project tasks.

## When to Use
Use me when you need help with the project.

## Workflow
1. Look at the project
2. Figure out what needs to be done
3. Make the changes
4. Report back

## Output
Tell the user what happened.
```

### Diagnosis

The skill defines a good agent as an "operating contract" that tells the agent what it owns, what it does not own, when to stop, what inputs it needs, what tools or areas it may inspect, what changes it may make, how to validate work, and what final output proves completion.

Against that standard, the weak agent fails on every axis:

| Dimension | Status | Problem |
|---|---|---|
| Scope / Ownership | Missing | No `Owns` / `Does Not Own` sections. Agent has no boundary. |
| Mode | Missing | No default behavior (Inspect vs Edit vs Infra Cautious). |
| Stop conditions | Missing | Nothing tells the agent when to halt. This directly causes "keeps touching files it shouldn't." |
| Workflow | Vague | Four steps with no specificity. "Figure out what needs to be done" hands control entirely to the model, producing unbounded exploration. |
| Required inputs | Missing | No definition of what context the agent needs before starting. |
| Context to inspect | Missing | No guidance on which files to read, so the agent reads broadly. |
| Decision rules | Missing | No conditional logic for ambiguous situations. |
| Validation | Missing | No command to verify the work. |
| Output format | Minimal | "Tell the user what happened" produces no structured, verifiable report. |
| Persona language | Present | "I am a senior software engineer agent" is a persona, not an operating contract. Per skill guidance, this should be removed. |

The two stated user complaints map directly to missing structure:
- "Keeps touching files it shouldn't" → no `Does Not Own`, no stop conditions, no context-to-inspect constraint
- "Doesn't know when to stop" → no stop conditions, no decision rules, vague workflow step 2 ("figure out what needs to be done") encourages unlimited exploration

---

## Step 2: Determine Original Intent

The agent is called "Project Automation Agent" and its workflow describes: look at a project, figure out what needs doing, make changes, report. This is a general project task execution agent — the intent is to carry out scoped implementation work.

Per the skill's improving guidance: "Preserve the original intent unless the user asks to change it." The intent (executing project tasks) is kept. The improvements add the structure that makes that intent safe and reliable.

---

## Step 3: Apply Skill Guidance — Improving an Existing Agent

Skill instructions for improvement:
1. Preserve the original intent — done (project task execution)
2. Identify where the agent is too broad, too vague, or too risky — done (see diagnosis above)
3. Add missing ownership boundaries, stop conditions, validation, and output format — done
4. Remove generic persona language — done ("I am a senior software engineer agent" removed)

Skill guidance on generalizing fixes vs overfitting:

> Bad fix: `Never edit UserService.ts.`
> Better fix: `Do not edit domain service files unless the task explicitly requires behavior changes outside the API client layer.`

Applied: stop conditions are written as categories (auth, migrations, payments, infra, deletes, new dependencies) rather than specific file names.

---

## Step 4: Sections Added and Rationale

**Mode** — Added `Edit` as default with explicit conditions for switching to `Inspect Only`. This prevents the agent from silently editing risky areas.

**Scope: Owns / Does Not Own** — Added explicit ownership boundaries. "Does Not Own" covers the categories most likely to cause unintended side effects: auth, migrations, payments, infra, dependency upgrades, files outside stated scope.

**Required Inputs** — Added three inputs: task description, target files (if known), validation command. This prevents the agent from starting without a defined done state.

**Context to Inspect** — Added explicit guidance to read only files directly relevant to the task plus immediate-module patterns. Added "Do not read the entire repo" as a direct instruction.

**Workflow** — Replaced four vague steps with seven concrete steps. Key additions:
- Step 3: inspect existing pattern before writing code (prevents invented patterns)
- Step 5: run narrowest available validation
- Step 6: fix only the failing test, do not expand scope

**Decision Rules** — Added five conditional rules covering: ambiguous task (stop and ask), risky-area task (switch to Inspect Only), scope creep (stop if >3 unrelated files), no validation available (report the command), contradictory patterns (stop and report).

**Safety / Stop Conditions** — Added eight explicit stop conditions mapping to the skill's recommended categories: auth, migrations, payments, deletes, new dependencies, infra/CI, out-of-scope changes, invariant conflicts.

**Validation** — Added tiered validation preference (targeted test → typecheck → lint → build) with fallback instruction for when validation cannot run.

**Output Format** — Replaced "Tell the user what happened" with a seven-field structured report: summary, files inspected, files changed, commands run, findings, risks, recommended next step.

---

## Result

The improved agent preserves the original purpose (project task execution) while adding the full operating contract the weak agent was missing. The two user-reported failure modes are directly addressed:

- "Keeps touching files it shouldn't" — resolved by `Does Not Own`, `Context to Inspect`, stop conditions, and the decision rule for scope creep
- "Doesn't know when to stop" — resolved by stop conditions, decision rules, and a workflow that requires a defined done state before starting
