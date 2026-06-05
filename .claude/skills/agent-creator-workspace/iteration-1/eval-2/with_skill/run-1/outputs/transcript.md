# Transcript

## Eval Prompt
"Create a full-stack engineering agent that handles all frontend and backend work — code reviews, bug fixes, deployments, database migrations, performance tuning, and whatever else is needed."

## Step 1: Read Skill File
Read `~/.claude/skills/agent-creator/SKILL.md` completely.

Key guidance extracted:
- Skill explicitly names "Full Stack Senior Engineer Agent" as a bad idea
- Step 2 says: do not create an agent when the workflow is too broad to validate
- Skill says: "If the request is too broad, propose narrower agents"
- A good agent has one recurring workflow with a measurable done state

## Step 2: Assess the Request

The prompt asks for an agent that:
- Does code reviews
- Fixes bugs
- Handles deployments
- Runs database migrations
- Does performance tuning
- Does "whatever else is needed"

This fails every check in Step 2:
- Too vague: "whatever else is needed" is not a workflow
- Too broad to validate: no test prompt could exercise this without being equally broad
- No measurable done state: each sub-task has a different success criterion
- Mode conflict: deployments/migrations need Infra Cautious; reviews need Inspect Only; bug fixes need Debug

Decision: Do not create the agent. Apply scope-narrowing guidance.

## Step 3: Apply Scope-Narrowing Guidance

Proposed five focused alternatives, each with:
- A single recurring workflow
- A clear default mode
- A measurable done state
- Defined ownership boundary

1. PR Code Review Agent — Inspect Only
2. Bug Fix Agent — Debug
3. Database Migration Agent — Infra Cautious
4. Deployment Readiness Agent — Inspect Only
5. Performance Audit Agent — Inspect Only

## Step 4: Recommend Path Forward

Rather than producing five half-complete agent files, the response asks the user to pick one workflow so the full agent file, test prompts, and validation commands can be produced for it.

## Output Written
`~/.claude/skills/agent-creator-workspace/iteration-1/scope-narrowing/with_skill/outputs/response.md`
