---
name: deep-research
description: Research a topic or question in depth using web search and codebase exploration, then produce a structured report
argument-hint: <topic or question>
context: fork
allowed-tools: Bash, Read, WebSearch, WebFetch, Agent
---

Research the following topic in depth: $ARGUMENTS

1. Break the question into 3-5 sub-questions that together answer the whole
2. For each sub-question, search the web and/or explore the codebase as appropriate
3. Synthesize findings — don't just dump raw search results
4. Produce a structured report:
   - **Summary**: 2-3 sentence answer to the original question
   - **Findings**: one section per sub-question with evidence
   - **Recommendations**: concrete next steps if applicable
   - **Sources**: links to key references

Keep the report under 600 words. Cite sources inline.
