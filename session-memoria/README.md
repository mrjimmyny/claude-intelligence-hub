# Session Memoria - Xavier's Second Brain 🧠

**Version:** 1.2.0
**Status:** Active
**Language:** Portuguese triggers / English documentation

---

## What is it?

Session Memoria is Jimmy's permanent knowledge management system. It transforms ephemeral conversations into durable, searchable, and organized knowledge.

### Core Features

- 💾 **Capture:** Saves conversations, decisions, insights, and ideas with rich metadata
- 🔍 **Search:** Triple-index system (by date, category, and tag)
- 📊 **Monitor:** Tracks growth and alerts on size thresholds
- 🔄 **Sync:** Automatic Git integration (commit + push)
- 🗂️ **Organization:** Year/month directory structure with multiple indexes

---

## How to Use

### Saving Information

Tell Xavier (in Portuguese — these are the recognized triggers):
- "Xavier, registre isso"
- "X, salve essa conversa"
- "Registre isso"
- "Salvar essa decisão"

Xavier will:
1. Analyze the conversation context
2. Suggest category, tags, and summary
3. Ask for confirmation
4. Create an entry with a unique ID
5. Update all indexes
6. Commit and push to Git

### Searching Information

Tell Xavier (Portuguese triggers):
- "Xavier, já falamos sobre X?"
- "X, busca tema Y"
- "Procure na memoria"
- "O que já conversamos sobre X?"

Xavier will display:
- Top 5–10 relevant results
- Preview (ID, date, category, summary, tags)
- Option to read the full entry

### Viewing Statistics

Type: `/session-memoria stats`

Displays:
- Total entries and total size
- Distribution by category
- Distribution by month
- Top 10 tags
- Growth projection

---

## File Structure

```
session-memoria/
├── .metadata                      # Skill configuration
├── SKILL.md                        # Instructions for Claude
├── README.md                       # This documentation
├── CHANGELOG.md                    # Version history
├── SETUP_GUIDE.md                  # Installation guide
├── templates/
│   ├── entry.template.md           # Entry template
│   └── index.template.md           # Index template
└── knowledge/                      # Knowledge repository
    ├── index/
    │   ├── by-date.md              # Chronological index
    │   ├── by-category.md          # Category index
    │   └── by-tag.md               # Tag index
    ├── entries/
    │   └── YYYY/
    │       └── MM/
    │           └── YYYY-MM-DD_topic-slug.md
    └── metadata.json               # Statistics and counters
```

---

## Entry Format

Each entry contains:

### Frontmatter (YAML)
```yaml
---
entry_id: YYYY-MM-DD-NNN          # Auto-generated unique ID
date: YYYY-MM-DD
time: HH:MM
category: Power BI                # Predefined category
tags: [dax, optimization, perf]   # Max 5 tags
project: optional
conversation_id: optional
summary: One-line summary (max 120 chars)
---
```

### Body (Markdown)
- **Context:** What led to this conversation
- **Decision/Insight/Idea:** The main point
- **Key Details:** Technical details, examples, code
- **Next Steps:** Optional follow-up tasks
- **References:** Links and references

---

## Triple-Index System

### 1. by-date.md (Primary Index)
- Chronological organization by YYYY-MM
- Most used (people remember "last week")
- Most recent entries first

### 2. by-category.md
- Grouped by domain
- Categories:
  - Power BI
  - Python
  - Gestão (Management)
  - Pessoal (Personal)
  - Git
  - Other

### 3. by-tag.md
- Cross-domain themes
- Tag cloud (by frequency)
- Enables cross-domain searching

**All indexes self-update** on every save.

---

## Growth Monitoring

### Alert Thresholds

| Level    | Entries   | Size     | Action                      |
|----------|-----------|----------|-----------------------------|
| Info     | < 500     | < 5MB    | None                        |
| Warning  | 500–1000  | 5–10MB   | Review and consolidate      |
| Critical | > 1000    | > 10MB   | Archiving recommended       |

### Projection
- **Expected usage:** 3–7 entries/day
- **6 months:** ~540–1260 entries (~3–6 MB)
- **Automatic alert** when thresholds are reached

---

## Git Integration

### Automatic Commit
After each save:
```bash
git add knowledge/entries/YYYY/MM/YYYY-MM-DD_slug.md
git add knowledge/index/*.md
git add knowledge/metadata.json
git commit -m "feat(session-memoria): add entry YYYY-MM-DD-NNN - [summary]"
git push origin main
```

### Commit Format
```
feat(session-memoria): add entry YYYY-MM-DD-NNN - [summary]

Category: [category]
Tags: [tag1, tag2, tag3]
Summary: [full summary]
```

---

## Categories and Tags

### Predefined Categories
- **Power BI:** DAX, modeling, reports, performance
- **Python:** Scripts, automation, libraries, patterns
- **Gestão:** Decisions, processes, planning, people
- **Pessoal:** Learnings, reflections, goals
- **Git:** Workflows, commands, strategies
- **Other:** Anything that doesn't fit above

### Tag Best Practices
- Reuse existing tags when possible
- Max 5 tags per entry
- Format: kebab-case (`dax-optimization`, `git-workflow`)
- Prefer specific over generic
- Examples:
  - ✅ `power-query`, `python-async`, `dax-time-intelligence`
  - ❌ `code`, `work`, `important`

---

## What to Save?

### ✅ Save
- Important decisions with reasoning
- Technical insights and learnings
- Project ideas (current or future)
- Problem-solving approaches
- Configuration discoveries
- Useful code patterns

### ❌ Don't Save
- Completion of routine tasks
- Simple questions and answers
- Test/debug iterations
- Temporary notes

---

## Integration with jimmy-core-preferences

Session Memoria works together with Jimmy's core personality:

### Proactive Offering
Xavier will offer to save when you:
- Make a significant decision
- Share a valuable insight
- Mention a project idea

### Proactive Recall
Xavier will reference past memories when relevant:
- "We already discussed this on [YYYY-MM-DD-NNN]"
- "You decided X because Y"

### Two-Level Memory
- **MEMORY.md:** Short-term, patterns, learnings (< 200 lines)
- **Session Memoria:** Long-term, searchable, detailed archive

---

## Statistics (v1.2.0)

- **Total entries:** 11
- **Total size:** ~56KB
- **Last entry:** 2026-02-13-001
- **Status:** Active production (3-tier archiving system)
- **Tiers:** HOT (11), WARM (0), COLD (0)
- **Categories:** Projects, Power BI, Architecture, Security, Other
- **Cross-device:** Desktop + Mobile sync active
- **Performance:** O(1) incremental indexing, 97% token savings at scale

---

## Usage Examples

### Example 1: Saving a Technical Decision
```
You: "Decidi usar DAX variables ao invés de calculated columns para melhorar performance"
Xavier: "Quer que eu registre essa decisão?"
You: "Xavier, registre isso"
Xavier: [analyzes and suggests metadata]
You: "Confirma"
Xavier: ✅ Registered! Entry ID: 2026-02-10-001
```

### Example 2: Searching a Previous Conversation
```
You: "Xavier, já falamos sobre otimização de DAX?"
Xavier: 🔍 Found 3 results for "otimização de DAX":
1. [2026-02-10-001] | Power BI | Decision to use variables...
2. [2026-02-05-002] | Power BI | Insight about CALCULATE...
...
You: "Mostra o 1"
Xavier: [displays full entry]
```

### Example 3: Viewing Progress
```
You: /session-memoria stats
Xavier: [displays full statistics]
```

---

## Roadmap

### v1.0.0 (Released 2026-02-10)
- ✅ Save workflow with Git
- ✅ Triple index system
- ✅ Multi-index search
- ✅ Growth monitoring
- ✅ Portuguese support

### v1.1.0 (Released 2026-02-11)
- ✅ Entry status tracking (aberto, em_discussao, resolvido, arquivado)
- ✅ Priority levels (alta, media, baixa)
- ✅ Update triggers ("xavier, marca como resolvido")
- ✅ Recap triggers ("xavier, resume os últimos registros")
- ✅ Mobile support via MOBILE_SESSION_STARTER.md
- ✅ Cross-device sync (Desktop + Mobile)

### v1.2.0 (Released 2026-02-13)
- ✅ **3-Tier Archiving System:** HOT/WARM/COLD tiers based on age and status
- ✅ **Incremental Indexing:** O(1) constant-time performance (200x faster)
- ✅ **Token Budget Management:** 97% token savings at scale (8K vs 250K+ tokens)
- ✅ **Deep Search Protocol:** --deep and --full flags for archived content
- ✅ **Aggressive Tiering:** <30d HOT, 30-90d WARM, >90d COLD

### v1.3.0 (Planned Q2 2026)
- Entry merging & consolidation
- Tag cleanup tools
- Entry summarization
- Export (PDF, JSON, HTML)

---

## 📱 Mobile Usage (claude.ai app)

**Important:** The Claude mobile app doesn't load local skills automatically.

### Solution: Use MOBILE_SESSION_STARTER.md

**One-time setup:**
1. Download [MOBILE_SESSION_STARTER.md](MOBILE_SESSION_STARTER.md) to your mobile device
2. Save it in an accessible location

**Every mobile Code session:**
1. Start a new Claude Code session on mobile
2. Attach the MOBILE_SESSION_STARTER.md file
3. Claude will load all necessary context
4. Use session-memoria normally

**What MOBILE_SESSION_STARTER.md provides:**
- ✅ Complete session-memoria context
- ✅ Repository structure
- ✅ Entry templates and formats
- ✅ Git sync protocol
- ✅ Xavier identity and behavior
- ✅ All valid statuses, categories, and tags
- ✅ Step-by-step operation guides

**Mobile workflow:**
```
Mobile: Create/update entry → Commit + Push
   ↓
Desktop: Git pull (auto-sync via junction points)
   ↓
Desktop: Skills auto-updated with mobile changes ✅
```

**Limitations on mobile:**
- ❌ No auto-triggers ("xavier, registre isso")
- ❌ No automatic skill loading
- ✅ Manual operations work perfectly with the starter file
- ✅ Full Git sync with desktop

See [MOBILE_SESSION_STARTER.md](MOBILE_SESSION_STARTER.md) for complete mobile instructions.

---

## Support

- **Repository:** https://github.com/mrjimmyny/claude-intelligence-hub
- **Issues:** GitHub Issues
- **Skill directory:** `~/.claude/skills/user/session-memoria`

---

## License

MIT License — Feel free to use and modify.

---

**Created by Xavier for Jimmy**
**Date:** 2026-02-10
**Version:** 1.2.0
**Last updated:** 2026-02-19
