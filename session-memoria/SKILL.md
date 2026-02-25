---
name: session-memoria
version: 1.2.0
description: Capture, store, and recall conversations, decisions, insights, and ideas across all sessions
command: /memoria
aliases: [/memory, /save]
---

# Session Memoria - Xavier's Second Brain

**Version:** 1.2.0
**Purpose:** Capture, store, and recall conversations, decisions, insights, and ideas across all sessions
**Language:** Portuguese triggers / English documentation

---

## Overview

Session Memoria is Jimmy's permanent knowledge repository. Every important conversation, decision, insight, or idea can be captured and recalled later. This skill turns ephemeral chat into permanent, searchable knowledge.

### Core Capabilities
1. **Capture:** Save conversations with rich metadata
2. **Search:** Multi-index search (date, category, tag)
3. **Recall:** Retrieve full entries with context
4. **Update:** Change status, resolution, and tracking fields of existing entries
5. **Recap:** Summarize recent entries with status overview
6. **Monitor:** Track growth and alert on thresholds
7. **Sync:** Automatic Git commits and push

---

## Trigger Detection

### Save Triggers (Portuguese)
Listen for these phrases:
- "Xavier, registre isso"
- "X, salve essa conversa"
- "registre isso"
- "salvar essa decisão"
- "guarde essa informação"
- "quero salvar isso"

### Search Triggers (Portuguese)
Listen for these phrases:
- "Xavier, já falamos sobre X?"
- "X, busca tema Y"
- "procure na memoria"
- "o que já conversamos sobre X?"
- "recall X"

### Update Triggers (Portuguese)
Listen for these phrases:
- "Xavier, marca como resolvido"
- "X, fecha o tema"
- "atualiza o status de"
- "marca esse assunto como"
- "resolve o entry"
- "Xavier, atualiza o desfecho"

### Recap Triggers (Portuguese)
Listen for these phrases:
- "Xavier, resume os últimos registros"
- "X, resume os últimos N registros"
- "quais assuntos registramos"
- "o que temos em aberto na memoria"
- "recap session-memoria"
- "X, quais temas estão abertos"
- "resume a session-memoria"
- "o que ainda falta discutir"

### Stats Trigger
- `/session-memoria stats`

---

## Step 0: Git Sync (Mandatory Before Any Read Operation)

**CRITICAL:** Before executing ANY read operation (search, recap, update, stats), Xavier MUST sync from Git to ensure local data matches the repository (our single source of truth).

### Sync Workflow
```
1. Navigate to claude-intelligence-hub directory
2. Run: git fetch origin main
3. Run: git pull origin main
4. Verify no merge conflicts
5. If conflicts exist → Alert Jimmy and stop
6. Proceed with the requested operation
```

### When to Sync
- **Always before:** Search, Recap, Update, Stats
- **Not needed before:** Save (we're writing, not reading)
- **After Save:** Git commit + push (already in Save Workflow)

### Sync Failure Handling
- If network fails → Retry up to 4x with exponential backoff (2s, 4s, 8s, 16s)
- If merge conflict → Report to Jimmy, do NOT auto-resolve
- If pull succeeds → Proceed silently (no need to inform Jimmy unless asked)

---

## Entry Status & Tracking Fields

### Status Values
| Status | Description | When to Use |
|--------|-------------|-------------|
| `aberto` | Topic not yet discussed or resolved | Default for new entries |
| `em_discussao` | Currently being discussed across sessions | When topic spans multiple conversations |
| `resolvido` | Topic fully discussed and concluded | When decision is final or issue is fixed |
| `arquivado` | No longer relevant, kept for history | When topic becomes obsolete |

### Priority Values
| Priority | Description |
|----------|-------------|
| `alta` | Urgent, needs attention soon |
| `media` | Normal priority (default) |
| `baixa` | Can wait, nice to have |

### Resolution Field
Free-text field describing the outcome. Examples:
- "Decidido usar abordagem X por causa de Y"
- "Criado e implementado com sucesso"
- "Descartado - não faz mais sentido"
- "Em aberto - aguardando mais informações"
- "" (empty when not yet resolved)

### last_discussed Field
- Format: `YYYY-MM-DD`
- Updated automatically when an entry is referenced in a recap or update
- Helps track how recently a topic was revisited

---

## Save Workflow

When a save trigger is detected:

### Step 1: Analyze Context
- Review last 10 conversation turns
- Identify: topic, key decision/insight, keywords
- Determine content type: decision, insight, or idea

### Step 2: Extract Metadata
Generate suggestions for:
- **Category:** Choose from predefined list
  - Power BI
  - Python
  - Gestão (Management)
  - Pessoal (Personal)
  - Git
  - Other
- **Tags:** Extract 3-5 relevant keywords (kebab-case)
- **Summary:** Create one-line description (max 120 chars)
- **Title:** Create descriptive title
- **Status:** Default `aberto` (override only if Jimmy specifies)
- **Priority:** Default `media` (override only if Jimmy specifies)
- **last_discussed:** Set to today's date (YYYY-MM-DD)
- **Resolution:** Default empty `""` (will be filled on update)

### Step 3: Confirm with Jimmy
Present suggestion in this format:

```
About to save to Session Memoria:

📁 Category: [category]
🏷️  Tags: [tag1, tag2, tag3]
📝 Summary: [summary]

Confirm? (or suggest changes)
```

### Step 4: Generate Entry ID
1. Read `knowledge/metadata.json`
2. Get today's date: YYYY-MM-DD
3. Check `counters.daily[YYYY-MM-DD]`, default to 0
4. Increment counter: NNN = counter + 1 (zero-padded to 3 digits)
5. Entry ID: `YYYY-MM-DD-NNN`

### Step 5: Create Entry File
1. Generate slug from title: `topic-slug` (lowercase, hyphens)
2. Create directory if needed: `knowledge/entries/YYYY/MM/`
3. File path: `knowledge/entries/YYYY/MM/YYYY-MM-DD_topic-slug.md`
4. Use template from `templates/entry.template.md`
5. Fill in all metadata fields
6. Write content sections

### Step 6: Update Indices
Update all three index files:

#### by-date.md
- Find or create section: `## YYYY-MM`
- Add entry at top of section (newest first)
- Format:
  ```
  **[YYYY-MM-DD-NNN]** HH:MM | Category | Summary | Status: `aberto`
  Tags: tag1, tag2, tag3
  → [Read entry](../entries/YYYY/MM/YYYY-MM-DD_topic-slug.md)
  ```

#### by-category.md
- Find or create section: `## Category Name`
- Add entry (chronological within category)
- Same format as by-date (including status)

#### by-tag.md
- Update tag cloud with frequencies
- For each tag in entry:
  - Find or create section: `## #tag-name`
  - Add entry reference
  - Same format as by-date (including status)

### Step 7: Update Metadata
Update `knowledge/metadata.json`:
```json
{
  "stats": {
    "total_entries": +1,
    "total_size_bytes": +entry_size,
    "last_entry_id": "YYYY-MM-DD-NNN",
    "last_updated": "YYYY-MM-DD HH:MM:SS",
    "entries_by_category": { "category": +1 },
    "entries_by_tag": { "tag": +1 },
    "entries_by_month": { "YYYY-MM": +1 }
  },
  "counters": {
    "daily": { "YYYY-MM-DD": NNN }
  }
}
```

### Step 8: Check Growth Alerts
```javascript
if (total_entries >= 1000) {
  alert_level = "critical"
  message = "⚠️ CRITICAL: 1000+ entries. Consider archiving."
} else if (total_entries >= 500) {
  alert_level = "warning"
  message = "⚠️ WARNING: 500+ entries. Review recommended."
}
```

Update alerts in metadata.json if threshold crossed.

### Step 9: Git Commit
If `auto_push` is enabled in `.metadata`:

```bash
cd claude-intelligence-hub
git add session-memoria/knowledge/entries/YYYY/MM/YYYY-MM-DD_topic-slug.md
git add session-memoria/knowledge/index/*.md
git add session-memoria/knowledge/metadata.json
git commit -m "feat(session-memoria): add entry YYYY-MM-DD-NNN - [summary]

Category: [category]
Tags: [tag1, tag2, tag3]
Summary: [full summary]"
git push origin main
```

### Step 10: Confirm to Jimmy
```
✅ Saved to Session Memoria!

📋 Entry ID: YYYY-MM-DD-NNN
📂 Location: knowledge/entries/YYYY/MM/YYYY-MM-DD_topic-slug.md
📊 Total entries: N

[Growth alert if applicable]
```

---

## Search Workflow

When a search trigger is detected:

### Step 1: Parse Query
Extract:
- **Search terms:** Main keywords
- **Modifiers:**
  - `--category=X` or `-c X`
  - `--tag=X` or `-t X`
  - `--date=YYYY-MM` or `-d YYYY-MM`
  - `--recent` (last 7 days)

### Step 2: Execute Search
Use Grep tool to search across indices in parallel:

1. **by-date.md:** Search for terms in summaries
2. **by-category.md:** Search within specified category or all
3. **by-tag.md:** Search within specified tag or all

Search pattern: case-insensitive, partial matches OK

### Step 3: Aggregate Results
- Collect all matching entry IDs
- Remove duplicates
- Rank by:
  1. Relevance (keyword matches)
  2. Recency (newer first)

### Step 4: Display Previews
Show top 5-10 results:

```
🔍 Found N results for "[query]":

1. [YYYY-MM-DD-NNN] | Category | Summary
   Tags: tag1, tag2, tag3
   📅 DD/MM/YYYY

2. [YYYY-MM-DD-NNN] | Category | Summary
   Tags: tag1, tag2, tag3
   📅 DD/MM/YYYY

Want to read any in full? (type the number or entry ID)
```

### Step 5: Full Entry Display
When Jimmy requests full entry:

1. Read entry file: `knowledge/entries/YYYY/MM/YYYY-MM-DD_topic-slug.md`
2. Display with formatting:

```
═══════════════════════════════════════════════
📋 Entry: YYYY-MM-DD-NNN
📅 Date: DD/MM/YYYY HH:MM
📁 Category: [category]
🏷️  Tags: [tags]
═══════════════════════════════════════════════

[Full markdown content]

═══════════════════════════════════════════════
```

---

## Update Workflow

When an update trigger is detected:

### Step 1: Git Sync
Execute Step 0 (Git Sync) to ensure local data is current.

### Step 2: Parse Update Request
Extract:
- **Target:** Entry ID (YYYY-MM-DD-NNN) or search terms to identify the entry
- **Field to update:** status, resolution, priority, or combination
- **New value:** The new status, resolution text, or priority level

If Jimmy doesn't specify an entry ID, search for the entry first (use Search Workflow Steps 1-4) and confirm which entry to update.

### Step 3: Read Current Entry
1. Locate entry file: `knowledge/entries/YYYY/MM/YYYY-MM-DD_topic-slug.md`
2. Read current frontmatter
3. Display current values to Jimmy:

```
About to update entry [YYYY-MM-DD-NNN]:

📋 Title: [title]
📊 Current status: [current_status] → [new_status]
📝 Current resolution: [current_resolution] → [new_resolution]
🔢 Current priority: [current_priority] → [new_priority]

Confirm?
```

### Step 4: Update Entry File
1. Modify YAML frontmatter fields as requested
2. Update `last_discussed` to today's date (YYYY-MM-DD)
3. If resolution is being set, add a `## Resolution` section at the end of the entry content (before the `---` footer) if it doesn't exist:

```markdown
## Resolution
**Date:** DD/MM/YYYY
**Status:** [new_status]
**Outcome:** [resolution text]
```

### Step 5: Update Indices
Update status display in all three index files:
- Find the entry line in each index
- Update the status badge: `Status: \`new_status\``

### Step 6: Git Commit
```bash
cd claude-intelligence-hub
git add session-memoria/knowledge/entries/YYYY/MM/YYYY-MM-DD_topic-slug.md
git add session-memoria/knowledge/index/*.md
git commit -m "update(session-memoria): entry YYYY-MM-DD-NNN status → [new_status]

Resolution: [resolution text if provided]
Updated fields: [list of changed fields]"
git push origin main
```

### Step 7: Confirm to Jimmy
```
✅ Entry updated!

📋 Entry ID: YYYY-MM-DD-NNN
📊 Status: [old] → [new]
📝 Resolution: [resolution text]
📅 Last discussed: DD/MM/YYYY
```

---

## Recap Workflow

When a recap trigger is detected:

### Step 1: Git Sync
Execute Step 0 (Git Sync) to ensure local data is current.

### Step 2: Parse Recap Request
Extract:
- **Count:** How many entries to recap (default: 5)
- **Filter:** Optional filters:
  - `--status=aberto` (only open entries)
  - `--category=X` (specific category)
  - `--period=semana` or `--period=mes` (time period)
  - `--priority=alta` (specific priority)

Examples of natural language parsing:
- "resume os últimos 3 registros" → count=3, no filter
- "quais assuntos estão abertos" → no count limit, status=aberto
- "o que registramos na última semana" → period=last 7 days
- "temas de alta prioridade em aberto" → status=aberto, priority=alta

### Step 3: Fetch Entries
1. Read `knowledge/index/by-date.md` for chronological order
2. Read individual entry files to get full metadata (status, priority, resolution, last_discussed)
3. Apply filters from Step 2
4. Sort by date (newest first), then by priority (alta > media > baixa)

### Step 4: Build Recap Summary
For each entry, extract:
- Entry ID
- Date (Brazilian format DD/MM/YYYY)
- Category
- Summary (from frontmatter)
- Status (with visual indicator)
- Priority
- Last discussed date
- Resolution (if exists)

### Step 5: Display Recap
Present in this format:

```
📋 Recap Session Memoria - Last N entries

═══════════════════════════════════════════════
[Filter applied, if any]
═══════════════════════════════════════════════

1. [YYYY-MM-DD-NNN] | DD/MM/YYYY | Category
   📝 Summary text here
   📊 Status: 🔴 aberto | Priority: media
   📅 Last discussed: DD/MM/YYYY

2. [YYYY-MM-DD-NNN] | DD/MM/YYYY | Category
   📝 Summary text here
   📊 Status: 🟢 resolvido | Priority: alta
   📅 Last discussed: DD/MM/YYYY
   📌 Resolution: [resolution text]

═══════════════════════════════════════════════
📊 Summary: N open | N in discussion | N resolved
═══════════════════════════════════════════════

Want to read any in detail? (type the number or entry ID)
Want to update the status of any? (e.g. "marca o 1 como resolvido")
```

### Status Visual Indicators
| Status | Indicator |
|--------|-----------|
| `aberto` | 🔴 aberto |
| `em_discussao` | 🟡 em discussão |
| `resolvido` | 🟢 resolvido |
| `arquivado` | ⚪ arquivado |

### Step 6: Handle Follow-up
After displaying the recap, Jimmy may:
- Ask to see a full entry → Execute Search Workflow Step 5
- Ask to update a status → Execute Update Workflow
- Ask for more entries → Repeat with new count
- Move on → No action needed

---

## Stats Command

When `/session-memoria stats` is invoked:

Display comprehensive statistics:

```
📊 Session Memoria Statistics

═══════════════════════════════════════════════
General
═══════════════════════════════════════════════
Total Entries: N
Total Size: X.XX MB
Last Entry: YYYY-MM-DD-NNN (DD/MM/YYYY)
Alert Level: [info | warning | critical]

═══════════════════════════════════════════════
By Category
═══════════════════════════════════════════════
Power BI:    N entries (XX%)
Python:      N entries (XX%)
Gestão:      N entries (XX%)
Pessoal:     N entries (XX%)
Git:         N entries (XX%)
Other:       N entries (XX%)

═══════════════════════════════════════════════
By Month (Last 6 months)
═══════════════════════════════════════════════
YYYY-MM: N entries
YYYY-MM: N entries
...

═══════════════════════════════════════════════
Top Tags (10 most used)
═══════════════════════════════════════════════
#tag1: N entries
#tag2: N entries
...

═══════════════════════════════════════════════
Growth Projection
═══════════════════════════════════════════════
Avg. entries/day: X.XX
Est. 6-month total: ~N entries
Est. 6-month size: ~X.XX MB

[Growth recommendations if needed]
```

---

## File Paths

All paths relative to `claude-intelligence-hub/session-memoria/`:

- **Config:** `.metadata`
- **Templates:** `templates/entry.template.md`, `templates/index.template.md`
- **Indices:** `knowledge/index/by-date.md`, `knowledge/index/by-category.md`, `knowledge/index/by-tag.md`
- **Metadata:** `knowledge/metadata.json`
- **Entries:** `knowledge/entries/YYYY/MM/YYYY-MM-DD_topic-slug.md`

---

## Data Validation

### Before Saving
- Validate category is in predefined list
- Validate max 5 tags
- Validate tags are kebab-case
- Validate summary ≤ 120 chars
- Validate entry_id format: YYYY-MM-DD-NNN
- Validate status is one of: aberto, em_discussao, resolvido, arquivado
- Validate priority is one of: alta, media, baixa
- Validate last_discussed is valid date (YYYY-MM-DD)

### Before Updating
- Validate entry exists
- Validate new status is a valid value
- Validate new priority is a valid value
- Confirm changes with Jimmy before writing

### After Saving
- Verify all 3 indices updated
- Verify metadata.json updated
- Verify file created in correct path

### On Error
- Report to Jimmy with details
- Do not commit if validation fails
- Preserve existing indices

---

## Integration with jimmy-core-preferences

This skill works alongside Jimmy's core personality:

### Proactive Offering
When Jimmy shares:
- A significant decision → "Quer que eu registre essa decisão?"
- A valuable insight → "Isso parece importante. Salvo na memoria?"
- A project idea → "Posso guardar essa ideia para depois?"

> These prompts are intentionally in Portuguese — Jimmy's working language.

### Proactive Recall
When Jimmy asks about a topic you recognize:
- "Já conversamos sobre isso! Busco na Session Memoria?"
- Reference previous entry: "In [YYYY-MM-DD-NNN] you decided X because Y"

### Two-Tier Memory
- **MEMORY.md:** Short-term, patterns, learnings (< 200 lines)
- **Session Memoria:** Long-term, searchable, detailed archive

---

## Error Handling

### Common Errors

1. **Directory creation fails**
   - Check permissions
   - Report path to Jimmy

2. **Git commit fails**
   - Check git status
   - Ask Jimmy if manual commit needed

3. **Metadata.json corrupted**
   - Backup existing
   - Reconstruct from index files
   - Report issue to Jimmy

4. **Search returns no results**
   - Confirm query spelling
   - Suggest broader search
   - Offer to show recent entries

---

## Language Notes

### Metadata Fields
- All frontmatter in English (YAML standard)
- Entry content in Portuguese (titles, context, details) — Jimmy's working language

### Date Formatting
- File names: YYYY-MM-DD (ISO standard)
- Display to Jimmy: DD/MM/YYYY (Brazilian format)

### Category Names
- Use `"Gestão"` (not `"Management"`) in files
- Use `"Pessoal"` (not `"Personal"`) in files

---

## Best Practices

### When to Save
✅ **Do save:**
- Important decisions with reasoning
- Technical insights and learnings
- Project ideas (current or future)
- Problem-solving approaches
- Configuration discoveries
- Useful code patterns

❌ **Don't save:**
- Routine task completion
- Simple questions/answers
- Test/debug iterations
- Temporary notes

### Tag Guidelines
- Use existing tags when possible
- Max 5 tags per entry
- kebab-case format
- Prefer specific over general
- Examples: `dax-optimization`, `git-workflow`, `python-async`

### Summary Guidelines
- One line, max 120 chars
- Start with a verb (Decidido, Criado, Aprendido, etc. — entries are written in Portuguese)
- Be specific, not generic
- Examples (in Portuguese, as entries are):
  - ✅ "Decidido usar DAX variables para melhorar performance de medidas"
  - ❌ "Conversa sobre DAX"

---

## Version History

### v1.1.0 (2026-02-10)
- Entry tracking fields: status, priority, last_discussed, resolution
- Update Workflow (change status, resolution, priority of existing entries)
- Recap Workflow (summarize recent entries with status overview)
- Git Sync as mandatory Step 0 for all read operations
- Update and recap triggers in Portuguese
- Status visual indicators in indices and recap display
- Data validation for new fields

### v1.0.0 (2026-02-10)
- Initial release
- Save workflow with Git integration
- Triple index system (date, category, tag)
- Search with multiple modifiers
- Growth monitoring and alerts
- Portuguese language support

---

## Future Enhancements (v1.2.0+)

- Archive entries older than 6 months
- Entry merging (consolidate related entries)
- Tag consolidation and cleanup
- Entry summarization for large corpus
- Export to different formats (PDF, JSON)
- Advanced search (boolean operators, date ranges)
- Related entries suggestion (based on tags)

---

**Skill maintained by Xavier**
**Repository:** https://github.com/mrjimmyny/claude-intelligence-hub
**License:** MIT
