# Session Memoria - Xavier's Second Brain

**Version:** 1.0.0
**Purpose:** Capture, store, and recall conversations, decisions, insights, and ideas across all sessions
**Language:** Portuguese (pt-BR)

---

## Overview

Session Memoria is Jimmy's permanent knowledge repository. Every important conversation, decision, insight, or idea can be captured and recalled later. This skill turns ephemeral chat into permanent, searchable knowledge.

### Core Capabilities
1. **Capture:** Save conversations with rich metadata
2. **Search:** Multi-index search (date, category, tag)
3. **Recall:** Retrieve full entries with context
4. **Monitor:** Track growth and alert on thresholds
5. **Sync:** Automatic Git commits and push

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

### Stats Trigger
- `/session-memoria stats`

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

### Step 3: Confirm with Jimmy
Present suggestion in this format:

```
Vou registrar na Session Memoria:

📁 Categoria: [category]
🏷️  Tags: [tag1, tag2, tag3]
📝 Resumo: [summary]

Confirma? (ou sugira alterações)
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
  **[YYYY-MM-DD-NNN]** HH:MM | Category | Summary
  Tags: tag1, tag2, tag3
  → [Read entry](../entries/YYYY/MM/YYYY-MM-DD_topic-slug.md)
  ```

#### by-category.md
- Find or create section: `## Category Name`
- Add entry (chronological within category)
- Same format as by-date

#### by-tag.md
- Update tag cloud with frequencies
- For each tag in entry:
  - Find or create section: `## #tag-name`
  - Add entry reference
  - Same format as by-date

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
✅ Registrado na Session Memoria!

📋 Entry ID: YYYY-MM-DD-NNN
📂 Localização: knowledge/entries/YYYY/MM/YYYY-MM-DD_topic-slug.md
📊 Total de entradas: N

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
🔍 Encontrei N resultados para "[query]":

1. [YYYY-MM-DD-NNN] | Category | Summary
   Tags: tag1, tag2, tag3
   📅 DD/MM/YYYY

2. [YYYY-MM-DD-NNN] | Category | Summary
   Tags: tag1, tag2, tag3
   📅 DD/MM/YYYY

Quer ver algum completo? (digite o número ou entry ID)
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

### Proactive Recall
When Jimmy asks about a topic you recognize:
- "Já conversamos sobre isso! Busco na Session Memoria?"
- Reference previous entry: "Em [YYYY-MM-DD-NNN] você decidiu X porque Y"

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

## Portuguese Language Support

### Metadata Fields
- All frontmatter in English (YAML standard)
- Content in Portuguese (titles, context, details)

### Date Formatting
- File names: YYYY-MM-DD (ISO standard)
- Display to Jimmy: DD/MM/YYYY (Brazilian format)

### Category Names
- "Gestão" (not "Management" in files)
- "Pessoal" (not "Personal" in files)

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
- Start with verb (Decidido, Criado, Aprendido, etc.)
- Be specific, not generic
- Examples:
  - ✅ "Decidido usar DAX variables para melhorar performance de medidas"
  - ❌ "Conversa sobre DAX"

---

## Version History

### v1.0.0 (2026-02-10)
- Initial release
- Save workflow with Git integration
- Triple index system (date, category, tag)
- Search with multiple modifiers
- Growth monitoring and alerts
- Portuguese language support

---

## Future Enhancements (v1.1.0+)

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
