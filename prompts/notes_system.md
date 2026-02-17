# Obsidian Vault - Cursor AI Rules (Base Template)

## Vault Overview

This vault uses the PARA method to **manage and organize information**—projects, areas of responsibility, and reference material. Use these rules to create, organize, and process notes consistently. Customize the "Subject / domain" section below for your specific use case.

### Subject / domain

- **Purpose:** _Describe what this vault is for (e.g. work, learning, personal)._
- **Users:** _Who uses this vault (solo, team, etc.)._
- **Capture sources:** _Where content comes from before Obsidian (e.g. email, voice memos, other apps)._

---

## PARA Folder Structure

| Folder | Purpose | When to Use |
|--------|---------|-------------|
| `01 Projects/` | Time-bound efforts with a clear end | Specific initiatives, events, one-off goals |
| `02 Areas/` | Ongoing topics and responsibilities | Topic-based notes (no project-specific content here) |
| `03 Resources/` | Reference material | Contacts, docs, templates, guides |
| `04 Archive/` | Completed or inactive items | Past projects, old resources |
| `Inbox/` | Landing zone for new content | Quick captures, unsorted notes |
| `Templates/` | Note templates | Do not store regular notes here |

### Filing Guidelines

- New content → `Inbox/` first, then file to Project or Area
- Project-related notes → `01 Projects/[Project Name]/`
- Topic-based notes → `02 Areas/[Topic]/`
- Notes about a specific person or entity → file under the topic they belong to
- Process Inbox on a schedule (e.g. daily or weekly)—triage and file or archive
- When a project completes → move folder to `04 Archive/`

---

## Frontmatter Standards

All notes should include YAML frontmatter. Use these properties consistently:

```yaml
---
type: transcript | project | meeting | note | resource
status: active | review | complete | archived
date: MM-DD-YYYY
project: "[[Project Name]]"
participants: ["Name 1", "Name 2"]
tags: []
---
```

### Property Definitions

- **type**: The kind of note (transcript, project, meeting, note, resource)
- **status**: Current state of the note/item
- **date**: Creation date or meeting date; use MM-DD-YYYY in frontmatter and filenames
- **project**: Wikilink to the related project (if applicable)
- **participants**: People involved (for meetings/transcripts)
- **tags**: Obsidian tags relevant to your domain

---

## Processing Conversations & Transcripts

When asked to process a conversation, meeting note, or transcript, follow this workflow:

### 1. Extract Key Information

- **Summary**: 2–3 sentence overview of the conversation
- **Action Items**: Tasks mentioned with owner if specified (use `- [ ]` checkboxes)
- **Decisions Made**: Agreements or conclusions reached
- **Key Points**: Important information discussed
- **Follow-ups Needed**: Questions to answer, items to clarify

### 2. Identify Linkable Entities

- People mentioned → check for existing notes in `02 Areas/` or `03 Resources/`
- Projects referenced → link to `01 Projects/`
- Reference topics → link to `03 Resources/` if they exist

### 3. Suggest Filing Location

Based on content, recommend:

- Which Project folder if it’s about a specific project
- Which Area folder (topic)
- Keep in Inbox if unclear

### 4. Format Output

Structure processed transcripts with clear sections:

```markdown
## Summary
[2-3 sentences]

## Action Items
- [ ] Task (@Owner if known)

## Decisions
- Decision made

## Key Points
- Important point

## Follow-ups
- Question or clarification needed

---
## Full Transcript
[Original transcript below the fold]
```

---

## Linking Conventions

### Wikilinks

- Use `[[Note Name]]` for internal links
- Use `[[Note Name|Display Text]]` when display text differs
- Prefer linking to existing notes over creating new ones

### When to Create Links

- People or entities who have (or should have) a note
- Projects referenced
- Topics that have a resource note
- Related meetings or conversations

### Suggesting New Notes

When a person, project, or concept is mentioned without an existing note:

- Suggest creating a new note
- Recommend the appropriate PARA folder
- Provide a starting template

---

## Naming Conventions

### Files

- **Projects**: `Project Name` (e.g. Q1 Initiative, Product Launch)
- **Transcripts**: `MM-DD-YYYY Transcript - Brief Description`
- **Meetings**: `MM-DD-YYYY Meeting - Topic`
- **Resources**: Descriptive title in title case

### Folders

- Use the PARA prefixes (`01`, `02`, `03`, `04`) for main folders
- Subfolders use plain names without numbers

---

## AI Assistant Behaviors

### When Creating Notes

1. Always include appropriate frontmatter
2. Use the correct template for the note type
3. Add links to related existing notes
4. Suggest the correct filing location

### When Organizing Notes

1. Check frontmatter for clues about proper location
2. Look for project or topic references
3. Consider the note type when suggesting folders (topic → Area, initiative/event → Project)
4. Ask for clarification if the destination is ambiguous

### When Summarizing or Extracting

1. Preserve important details and nuance
2. Use the owner's voice and terminology
3. Match the tone and language of the source material
4. Format action items as checkboxes
5. Link mentioned entities when possible

### General Guidelines

- Keep changes focused and manageable
- Explain reasoning for organizational suggestions
- Respect existing structure and conventions
- Ask before making bulk changes
- When in doubt about filing or structure, refer to vault-specific documentation (e.g. in `03 Resources/`).
