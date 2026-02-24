# CIH-ROADMAP — Navigation Guide

> **Not sure where to start?** This is the document you read first. It will tell you exactly which file to open next, in what order, and when you are done.

**Version:** 1.0.1 · **Last Updated:** 2026-02-24

---

## Start Here

Read `README.md` (you may have just come from there). Then answer this:

```
Where are you?

├─ A. Fresh machine — installing everything from scratch
│     → PATH 1: Full Setup

├─ B. Already installed — exploring skills or adding new ones
│     → PATH 2: Skill Discovery

├─ C. Working with Power BI (PBIP projects)
│     → PATH 3: Power BI Specialist

├─ D. Want to contribute or understand the architecture
│     → PATH 4: Developer

└─ E. Something broke, or you need to restore context
      → PATH 5: Recovery
```

---

## The Two Categories You Must Know

Before any path, internalize this distinction. It governs every decision in the hub.

| Category | Skills | Rule |
|----------|--------|------|
| **Mandatory** | jimmy-core-preferences, session-memoria, x-mem, gdrive-sync-memoria, claude-session-registry, conversation-memoria, agent-orchestration-protocol | Install all seven. Always. In this order. |
| **À La Carte** | pbi-claude-skills, context-guardian, repo-auditor | Install only if you need them. |

---

## PATH 1 — Full Setup

**For:** New user on a fresh machine.
**End state:** All five mandatory skills installed, memory linked, first session initialized.

---

**Step 1 — Read first**

| File | Why |
|------|-----|
| `README.md` | What the hub is |
| `EXECUTIVE_SUMMARY.md` | Complete system picture |
| `WINDOWS_JUNCTION_SETUP.md` | Windows users only — understand junction points before anything else |

---

**Step 2 — Verify prerequisites**

| Requirement | Check |
|-------------|-------|
| Git 2.30+ | `git --version` |
| Claude Code CLI | `claude --version` |
| PowerShell 5.1+ | Windows only |
| Bash 4.0+ | macOS/Linux only |

---

**Step 3 — Clone**

```bash
git clone https://github.com/mrjimmyny/claude-intelligence-hub.git
cd claude-intelligence-hub
```

---

**Step 4 — Run automated setup**

```powershell
# Windows
.\scripts\setup_local_env.ps1

# macOS/Linux
bash scripts/setup_local_env.sh
```

This installs the five mandatory skills in order, creates junction points / symlinks, and runs an integrity check. Expect ~15 minutes.

When prompted for optional skills: answer based on whether you work with Power BI. If yes, say yes. If no, say no.

---

**Step 5 — Link memory (Windows only)**

```batch
xavier-memory\setup_memory_junctions.bat
```

Creates hard links so `xavier-memory/MEMORY.md` is automatically available in every Claude project — one file, zero drift.

macOS/Linux: the setup script handles this with symlinks.

---

**Step 6 — Set up Google Drive backup (recommended)**

Read `gdrive-sync-memoria/SETUP_INSTRUCTIONS.md`.

Required if you use ChatLLM Teams (ABACUS.AI). Optional but strongly recommended otherwise — this is your cloud backup layer.

---

**Step 7 — Open Claude Code**

Start a session in the repository directory. The initialization protocol in `.claude/project-instructions.md` runs automatically: git pull, branch check, merge alert if needed.

✅ **PATH 1 complete.** You are production-ready.

---

## PATH 2 — Skill Discovery

**For:** Already installed. Want to understand what you have, add more, or learn triggers.
**End state:** You know what every skill does and can invoke any of them.

---

**Step 1 — Read the routing map**

Open `HUB_MAP.md`. Do not read it top to bottom — use it as a reference. Find the skill you are curious about and read its entry.

Each skill entry in HUB_MAP.md tells you:
- What it does
- What phrases trigger it
- What it depends on
- Which loading tier it belongs to

---

**Step 2 — Understand loading tiers**

| Tier | Behavior | Who |
|------|----------|-----|
| **Tier 1: Always-Load** | Runs at every session start, no trigger needed | `jimmy-core-preferences`, `xavier-memory` |
| **Tier 2: Context-Aware** | Auto-suggested on trigger detection or explicit command | `session-memoria`, `x-mem`, `claude-session-registry`, `pbi-claude-skills` |
| **Tier 3: Explicit** | Only loads when you say so | `gdrive-sync-memoria`, `xavier-memory-sync`, `context-guardian` |

---

**Step 3 — Learn any skill**

For any skill you want to use or verify:

```
<skill-name>/
├── README.md       ← What it is and why (start here)
├── SKILL.md        ← Exact triggers and workflows (then here)
├── SETUP_GUIDE.md  ← If you need to install it
└── CHANGELOG.md    ← What changed recently
```

---

**Step 4 — Verify installation**

```bash
bash scripts/integrity-check.sh
```

Checks for: orphaned directories, ghost skills, missing `.metadata`, missing `SKILL.md`, version drift.

✅ **PATH 2 complete.** You know your skills and your installation is verified.

---

## PATH 3 — Power BI Specialist

**For:** You work with Power BI PBIP projects and want 50–97% token savings.
**End state:** `pbi-claude-skills` installed in your Power BI project. All five slash commands working.

---

**Step 1 — Read first**

| File | Time |
|------|------|
| `pbi-claude-skills/README.md` | 2 min |
| `pbi-claude-skills/SKILL.md` | 5 min |

Key fact: `pbi-claude-skills` is **project-specific**. It installs into each Power BI project separately, not into `~/.claude/skills/user/`.

---

**Step 2 — Install into your project**

```powershell
cd claude-intelligence-hub\pbi-claude-skills
.\scripts\setup_new_project.ps1 -ProjectPath "C:\path\to\your\pbi-project"
```

Configuration reference: `pbi-claude-skills/docs/CONFIGURATION.md`
Migration guide (existing projects): `pbi-claude-skills/docs/MIGRATION.md`

---

**Step 3 — Your five commands**

| Command | What It Does | Savings |
|---------|-------------|---------|
| `/pbi-discover` | Map entire project structure | 50–70% |
| `/pbi-query` | Query tables, measures, relationships | 85–97% |
| `/pbi-add-measure "Name" "DAX"` | Add DAX measure with validation | 27–50% |
| `/pbi-index-update` | Regenerate POWER_BI_INDEX.md | 60–80% |
| `/pbi-context-check` | Check context window usage | — |

---

**Step 4 — Keep updated**

```powershell
cd claude-intelligence-hub
git pull

cd pbi-claude-skills
.\scripts\update_all_projects.ps1
```

✅ **PATH 3 complete.** Your Power BI sessions now run at a fraction of the token cost.

---

## PATH 4 — Developer / Contributor

**For:** You want to understand the architecture, extend a skill, or contribute a new one.
**End state:** You understand hub governance and can build and release skills correctly.

---

**Step 1 — Read in order**

1. `README.md`
2. `EXECUTIVE_SUMMARY.md`
3. `HUB_MAP.md`
4. `CHANGELOG.md` — understand why decisions were made
5. `.claude/project-instructions.md` — mandatory session and Git rules
6. `docs/FEATURE_RELEASE_CHECKLIST.md` — required before any release

---

**Step 2 — Understand skill structure**

Every skill in the hub follows this layout:

```
<skill-name>/
├── .metadata        ← REQUIRED: JSON — name, version, type, triggers, settings
├── SKILL.md         ← REQUIRED: Execution instructions for Claude
├── README.md        ← Recommended
├── CHANGELOG.md     ← Recommended
└── SETUP_GUIDE.md   ← Optional
```

To bump a version consistently across `.metadata`, `SKILL.md`, and `HUB_MAP.md`:

```bash
bash scripts/update-skill.sh <skill-name> <patch|minor|major>
```

---

**Step 3 — Understand governance**

| File | What it governs |
|------|----------------|
| `token-economy/README.md` | Token budget discipline |
| `token-economy/budget-rules.md` | File loading rules and response size limits |
| `docs/FEATURE_RELEASE_CHECKLIST.md` | Pre-release validation steps |
| `scripts/validate-readme.sh` | README consistency — run before every release |
| `.github/workflows/ci-integrity.yml` | 5-job CI/CD: integrity · version sync · mandatory skills · breaking changes · summary |

---

**Step 4 — Contribute**

1. Fork the repo
2. `git checkout -b feature/your-skill`
3. Build your skill following the structure in Step 2
4. Add it to `HUB_MAP.md`
5. Run `bash scripts/integrity-check.sh` locally
6. Run `bash scripts/validate-readme.sh` locally
7. Open a PR — CI/CD validates automatically

✅ **PATH 4 complete.** You can build, version, and release skills confidently.

---

## PATH 5 — Recovery & Emergency

**For:** Something broke, or you need to restore context.
**Approach:** Diagnose first, act second.

---

**Diagnose your situation**

| Symptom | Go to |
|---------|-------|
| Skills not loading / junction points broken | Step 5.A |
| MEMORY.md missing or out of sync | Step 5.B |
| Setting up on a new machine | Step 5.C |
| Switching Claude accounts (Xavier ↔ Magneto) | Step 5.D |
| CI/CD pipeline failing | Step 5.E |

---

**5.A — Fix junction points**

```powershell
# Windows
.\scripts\setup_local_env.ps1 -Force

# macOS/Linux
bash scripts/setup_local_env.sh --force
```

Then verify: `bash scripts/integrity-check.sh`

---

**5.B — Restore memory**

Say: `"Xavier, restore memory"`

Xavier will list available backups (local + Google Drive) and let you choose. If Google Drive is unavailable, local snapshots are at `xavier-memory/backups/`.

---

**5.C — New machine setup**

1. Follow PATH 1 (Full Setup)
2. If you have a context-guardian backup on Google Drive:
   - Download `bootstrap-magneto.ps1` from Google Drive
   - Run `.\bootstrap-magneto.ps1` and follow the interactive menu
3. Restore memory (Step 5.B)

Reference: `docs/HANDOVER_GUIDE.md`

---

**5.D — Account switch (Xavier ↔ Magneto)**

**Before switching:** "backup global config" · "backup this project"

**After switching:**
- Download `bootstrap-magneto.ps1` from Google Drive
- Run `.\bootstrap-magneto.ps1`
- To fix symlinks after: `.\bootstrap-magneto.ps1 --fix-symlinks`

Reference: `context-guardian/SKILL.md`

---

**5.E — Fix CI/CD**

| Failing job | Fix |
|-------------|-----|
| `integrity-check` | `bash scripts/integrity-check.sh` → fix reported issues |
| `version-sync-check` | `bash scripts/sync-versions.sh <skill>` for each drifted skill |
| `mandatory-skills-check` | Ensure all 5 mandatory skills have `.metadata` + `SKILL.md` |
| `breaking-change-detection` | Update `CHANGELOG.md` (warning only — does not block merge) |

✅ **PATH 5 complete.** Systems operational.

---

## Glossary

| Term | Meaning |
|------|---------|
| **Junction point** | Windows directory link that keeps an installed skill auto-synced with the repo on `git pull` |
| **Hard link** | NTFS link making MEMORY.md in all projects point to the same master file — one edit, everywhere updated |
| **Tier 1** | Skill that auto-loads at every session start, no trigger required |
| **Tier 2** | Skill that loads on trigger detection or explicit command |
| **Tier 3** | Skill that only loads when you explicitly invoke it |
| **Golden Close** | Mandatory 7-step end-of-session checklist: sync · HUB_MAP check · git status · CHANGELOG · registry backup · push · summary |
| **Ciclope Rules** | 5 routing enforcement rules in `jimmy-core-preferences` — auto-detect skill needs, block duplicate implementations, maintain integrity |

---

*Generated by Magneto (Claude Code) · 2026-02-17*
*Based on full analysis of the `claude-intelligence-hub` repository (147 files)*
