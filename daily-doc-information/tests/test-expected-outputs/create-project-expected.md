# Expected Output: create-project (T-CP-01)

**Test:** T-CP-01
**Operation:** create-project
**Input fixture:** `test-fixtures/valid-create-project-input.md`
**project_type:** `skill`

---

## Output Location

**Base path:** `{BASE}/obsidian/CIH/projects/skills/test-new-project/`

For skill projects: target root = `projects/skills/{project_name}/`

---

## Required Folder Structure (skill project)

All of the following directories must be created:

| Directory | Required | Notes |
|---|---|---|
| `00_prompts_agents/` | Yes | All projects |
| `01-manifesto-contract/` | Yes | All projects |
| `02-planning/` | Yes | All projects |
| `03-spec/` | Yes | Skill projects only |
| `04-tests/` | Yes | All projects |
| `05-audits/` | Yes | Skill projects use 05-audits/ (not 05-final/) |
| `06-operationalization/` | Yes | All projects |
| `07-templates/` | Yes | Skill projects only |
| `ai-sessions/2026-03/` | Yes | Skill projects only — month from timestamp_local |
| `daily-reports/` | Yes | Skill projects only |

**Note:** Skill projects use `05-audits/` instead of `05-final/`.

---

## Required Operational Documents (5 docs)

All must exist at the project root:

| File | Required | Notes |
|---|---|---|
| `PROJECT_CONTEXT.md` | Yes | Project identity — read-only after creation |
| `status-atual.md` | Yes | Project status tracker |
| `next-step.md` | Yes | Current next action |
| `decisoes.md` | Yes | Decision log |
| `README.md` | Yes | Project overview |

---

## Required Project Notes File

| File | Required Path | Notes |
|---|---|---|
| `ddi-pjt-gi-notes-ans-jimmy-orquestrator.md` | `00_prompts_agents/` | All threads and Q&A |

---

## Template Variable Substitutions

In all 5 operational docs, verify:

| Placeholder | Expected Value |
|---|---|
| `{{PROJECT_NAME}}` | `test-new-project` |
| `{{PROJECT_OBJECTIVE}}` | `Validate the create-project operation of the daily-doc-information skill` |
| `{{CURRENT_PHASE}}` | `Phase 1 - Setup` |
| `{{YYYY-MM-DD}}` | `2026-03-17` |
| `{{IN_PROGRESS_ITEM_1}}` | `"Project kickoff and initial structure"` |
| `{{IMMEDIATE_ACTION}}` | `"Read PROJECT_CONTEXT.md and confirm project scope with Jimmy."` |

---

## Wikilinks (DH-13)

All 5 operational docs must contain wikilinks to each other and to `[[projects]]`:

- `PROJECT_CONTEXT.md` → wikilinks to: `[[status-atual]]`, `[[next-step]]`, `[[decisoes]]`, `[[README]]`, `[[projects]]`
- `status-atual.md` → wikilinks to: `[[PROJECT_CONTEXT]]`, `[[next-step]]`, `[[decisoes]]`, `[[projects]]`
- `next-step.md` → wikilinks to: `[[PROJECT_CONTEXT]]`, `[[status-atual]]`, `[[projects]]`
- `decisoes.md` → wikilinks to: `[[PROJECT_CONTEXT]]`, `[[status-atual]]`, `[[projects]]`
- `README.md` → wikilinks to: `[[PROJECT_CONTEXT]]`, `[[status-atual]]`, `[[projects]]`

---

## What Must NOT Be Present

| Prohibited Element | Reason |
|---|---|
| `{{...}}` markers in any doc | DH-06, FM-10 |
| `TODO`, `TBD`, `FIXME` | PB-04 |
| Missing docs (partial structure) | FM-14 |
| Pre-existing files overwritten | PB-14 (NO_PROJECT_OVERWRITE) |

---

## Required Evidence Block

```
=== EVIDENCE: create-project ===
Operation: create-project
Timestamp: 2026-03-17 14:00
Agent: TestAgent (testagent)
Machine: TEST-MACHINE-001
Project Name: test-new-project
Project Type: skill
Target Path: {BASE}/obsidian/CIH/projects/skills/test-new-project/
Checks:
  - Target folder did not exist before: YES
  - All subfolders created: YES (10/10)
  - All 5 operational docs created: YES
  - Project notes file created in 00_prompts_agents/: YES
  - No residual placeholders: YES
  - Wikilinks present in all docs: YES
  - Folder structure matches project_type: YES (skill)
Result: PASS
=== END EVIDENCE ===
```

---

## Hygiene Checks

- [ ] DH-01: Evidence block produced
- [ ] DH-06: No placeholders in any of the 5 docs or project notes file
- [ ] DH-13: All 5 docs have wikilinks to each other and to `[[projects]]`
- [ ] FM-14: All folders and docs confirmed created (no partial structure)
