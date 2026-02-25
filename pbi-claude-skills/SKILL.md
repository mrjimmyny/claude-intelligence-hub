---
name: pbi-claude-skills
version: 1.3.0
description: Power BI PBIP project optimization - Token savings for large codebases
command: /pbi
aliases: [/powerbi]
---

# PBI Claude Skills - Skill Execution Instructions

**Version:** 1.3.0
**Type:** Project-Specific (Power BI PBIP)
**Auto-load:** Context-aware (when working in .pbip projects)

---

## Overview

PBI Claude Skills is a comprehensive skill system for Power BI PBIP projects that provides 50-97% token savings through smart indexing and context loading.

**Key Features:**
- ✅ 5 specialized skills (read-model, read-report, read-measures, list-objects, search-code)
- ✅ Auto-indexing system (caches structure, reuses across sessions)
- ✅ Smart context loading (only relevant code for tasks)
- ✅ Project detection (auto-finds .pbip files)
- ✅ Proven 50-97% token reduction

---

## Skills Available

1. **read-model:** Load semantic model structure (tables, relationships)
2. **read-report:** Load report pages and visuals
3. **read-measures:** Load DAX measures (with dependencies)
4. **list-objects:** Quick inventory (tables, measures, pages)
5. **search-code:** Find DAX patterns across project

---

## Triggers

**Context-based (Automatic):**
- Claude suggests when working in `.pbip` projects
- Auto-detection of Power BI project structure

**Manual Commands:**
- `/pbi-query` - Query structure
- `/pbi-discover` - Discover files
- `/pbi-add-measure` - Add DAX measure
- `/pbi-index-update` - Regenerate index
- `/pbi-context-check` - Check context usage

---

## How It Works

1. **Index Generation:**
   - First use: Creates `POWER_BI_INDEX.md` in project root
   - Caches: Tables, measures, relationships, report structure
   - Reuse: Index persists across sessions (no re-scanning)

2. **Smart Loading:**
   - Only loads relevant sections based on task
   - Example: "Add measure" → Loads only measures + dependencies
   - Avoids loading entire project (token savings)

3. **Token Optimization:**
   - Baseline: 40,000+ tokens for full project
   - With skills: 2,000 tokens average (95% reduction)
   - Scales to any project size

---

## Project Structure

```
pbi-claude-skills/
├── skills/                      # 5 individual skill implementations
│   ├── read-model/
│   ├── read-report/
│   ├── read-measures/
│   ├── list-objects/
│   └── search-code/
├── scripts/                     # Helper scripts
│   ├── generate-index.sh        # Create POWER_BI_INDEX.md
│   └── validate-project.sh      # Verify .pbip structure
├── templates/                   # Code templates
│   └── measure-template.dax     # DAX measure template
├── docs/                        # Documentation
│   ├── user-guide.md
│   └── test-results.md
├── EXECUTIVE_SUMMARY_PBI_SKILLS.md  # Complete documentation (43KB)
├── README.md                    # Quick start guide
├── SKILL.md                     # This file
└── .metadata                    # Skill configuration
```

---

## Usage Example

**Scenario:** Add a new DAX measure to a Power BI project

**Without PBI Skills:**
```
1. Load entire project structure (40K tokens)
2. Find measures table
3. Write DAX measure
4. Save and commit
Total: 40K+ tokens
```

**With PBI Skills:**
```
1. /pbi-add-measure "Total Sales"
2. Skills loads: POWER_BI_INDEX (500 tokens) + measures section (1K tokens)
3. Generates DAX measure using template
4. Saves to correct location
Total: 2K tokens (95% reduction)
```

---

## Test Results

**160 tests run (Feb 2026):**
- Pass rate: 99% (158/160)
- Token savings: 50-97% depending on project size
- Average context: 2,000 tokens (vs. 40,000+ baseline)
- Performance: < 2s load time (vs. 30s+ baseline)

---

## Dependencies

**Required:**
- Power BI project in PBIP format (.pbip files)
- POWER_BI_INDEX.md in project root (auto-created if absent)
- pbi_config.json (auto-created if absent)

**Optional:**
- Git repository (for version control)
- DAX formatter (for measure formatting)

---

## Loading Tier

**Tier 2: Context-Aware**
- Auto-suggests when `.pbip` project detected
- Does NOT auto-load globally
- Loads only when working on Power BI projects

---

## Documentation

**Complete documentation:** See `EXECUTIVE_SUMMARY_PBI_SKILLS.md` (43KB)
- Detailed architecture
- All 5 skills documented
- Test results and benchmarks
- Setup guide
- Troubleshooting

**Quick start:** See `README.md`

---

## Notes

- **Project-specific:** This skill is designed for Power BI PBIP projects only
- **Not global:** Does not auto-load for non-PBI work
- **Token efficient:** Proven 50-97% reduction in real projects
- **Production ready:** Tested with 160 test cases

---

**For complete execution instructions and detailed documentation, refer to:**
`EXECUTIVE_SUMMARY_PBI_SKILLS.md`
