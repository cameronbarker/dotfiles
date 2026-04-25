---
description: Code style and quality conventions
---

# Code Style

## Comments
- Only comment when the WHY is non-obvious: hidden constraints, subtle invariants, workarounds for specific bugs
- No docstrings or multi-line comment blocks
- No "what the code does" comments — well-named identifiers already do that
- No task/PR/issue references in code comments (those belong in commit messages)

## Structure
- Prefer editing existing files over creating new ones
- No abstractions, helpers, or generalization unless the task explicitly requires it
- Three similar lines is better than a premature abstraction
- No half-finished implementations or stubs

## Safety
- No added error handling for scenarios that cannot happen
- Only validate at system boundaries (user input, external APIs)
- Trust internal code and framework guarantees
- No backwards-compatibility shims when the code can just be changed

## Features
- No features beyond what the task requires
- No feature flags unless asked
- No optional parameters or fallbacks for hypothetical future use
