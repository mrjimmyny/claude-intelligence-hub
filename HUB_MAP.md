# 🗺️ Claude Intelligence Hub - Visual Skill Router

**Version:** 2.10.1
**Status:** 🟢 Active & Synchronized
**Registry:** 17 Production Skills

---

## 📊 Hub Statistics

| Metric | Count | Status |
| :--- | :--- | :--- |
| **Total Skills** | 17 | ✅ Verified |
| **Governance** | 100% | 🟢 Compliant |
| **Architecture** | 3-Tier | 🏗️ Structured |

---

## 🏗️ Skill Architecture (Tiers)

### 🔵 Tier 1: Always-Load (Mandatory)
*The foundation of the system. Loads at every session start.*

| # | Skill Name | Version | Command | Role |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **jimmy-core-preferences** | v2.0.1 | `/preferences` | Master AI Behavior |
| 14 | **token-economy** | v1.0.0 | `/token-economy` | Budget Enforcement |

### 🟢 Tier 2: Context-Aware (Suggested)
*Loads based on triggers or detected project type.*

| # | Skill Name | Version | Command | Triggers |
| :--- | :--- | :--- | :--- | :--- |
| 2 | **session-memoria** | v1.2.0 | `/memoria` | "registre isso", "busca na memoria" |
| 4 | **claude-session-registry** | v1.1.0 | `/registry` | "registra sessão", Golden Close |
| 5 | **pbi-claude-skills** | v1.3.0 | `/pbi` | `.pbip` project detection |
| 7 | **xavier-memory** | v1.1.0 | `/xavier-memory` | Cross-project sync |
| 12 | **agent-orchestration-protocol** | v2.0.0 | `/aop` | "orchestrate", "delegate" |

### 🟡 Tier 3: Explicit (On-Demand)
*Only loads when manually invoked by the user.*

| # | Skill Name | Version | Command | Usage |
| :--- | :--- | :--- | :--- | :--- |
| 3 | **gdrive-sync-memoria** | v1.0.0 | `/gdrive-sync` | Sync ChatLLM Team data |
| 6 | **x-mem** | v1.0.0 | `/xmem` | Failure/Success learning |
| 8 | **xavier-memory-sync** | v1.0.0 | `/xavier-sync` | GDrive Memory Backup |
| 9 | **context-guardian** | v1.1.0 | `/context-guardian` | Account switching (Xavier/Magneto) |
| 10 | **repo-auditor** | v2.0.0 | `/repo-auditor` | Manual repo integrity audit |
| 11 | **conversation-memoria** | v1.0.0 | `/conversation` | Save/Load session history |
| 13 | **core_catalog** | v1.0.0 | `/catalog` | Bootstrap system data |
| 15 | **codex-governance-framework** | v1.0.0 | `/governance` | Institutional governance docs |
| 16 | **daily-tasks-oih** | v1.0.0 | `/daily-tasks-oih` | Daily tasks pool and per-agent execution workflow |
| 17 | **docx-indexer** | v1.2.0 | `/docx-indexer` | Global document indexing + manual-first enrichment |

---

## 🔗 Detailed Routing Map

### 1. jimmy-core-preferences
- **Path:** `jimmy-core-preferences/`
- **Identity:** Global cross-agent operating framework for all agents working with Jimmy.
- **Rules:** Radical Honesty, Objectivity, Prompt Governance (English/file-first), Hybrid Session Governance, DAX Overlay, Cross-Agent Bootstrap.

### 2. session-memoria
- **Path:** `session-memoria/`
- **Identity:** Permanent searchable knowledge base.
- **Language:** Portuguese Triggers / English Metadata.

### 3. gdrive-sync-memoria
- **Path:** `gdrive-sync-memoria/`
- **Integration:** rclone + Google Drive auto-import.

### 4. claude-session-registry
- **Path:** `claude-session-registry/`
- **Automation:** Session ID tracking & GitHub backups.

### 5. pbi-claude-skills
- **Path:** `pbi-claude-skills/`
- **Optimization:** Power BI PBIP project token savings (50-97%).

### 6. x-mem
- **Path:** `x-mem/`
- **Learning:** Captures tool failures and proactively suggests fixes.

### 7. xavier-memory
- **Path:** `xavier-memory/`
- **Global:** Cross-project persistent memory (MEMORY.md).

### 8. xavier-memory-sync
- **Path:** `xavier-memory-sync/`
- **Cloud:** Syncs global memory to Google Drive.

### 9. context-guardian
- **Path:** `context-guardian/`
- **Switching:** Manages account state between Xavier and Magneto.

### 10. repo-auditor
- **Path:** `repo-auditor/`
- **Audit:** Mandatory proof-of-read and audit trails.

### 11. conversation-memoria
- **Path:** `conversation-memoria/`
- **Archive:** Persistent session storage for Elite League history.

### 12. agent-orchestration-protocol
- **Path:** `agent-orchestration-protocol/`
- **Workflow:** Multi-agent coordination framework (Seven Pillars).

### 13. core_catalog
- **Path:** `core_catalog/`
- **Data:** System initialization and compatibility data.

### 14. token-economy
- **Path:** `token-economy/`
- **Governance:** Budget enforcement and token reduction rules.

### 15. codex-governance-framework
- **Path:** `codex-governance-framework/`
- **Context:** Institutional bootstrap governance documentation.

### 16. daily-tasks-oih
- **Path:** `daily-tasks-oih/`
- **Workflow:** Pool capture, per-agent daily dispatch, execution tracking, and close protocol.

### 17. docx-indexer
- **Path:** `docx-indexer/`
- **Tool:** Global document indexing system. Append-only JSON index with UUID identity, SHA256 hashing, structural telemetry, and Stage 2.2 v1 manual-first enrichment (`summary` + `keywords`). Scripts at `C:\ai\_skills\docx-indexer\`.

---

## 📋 Roadmap (Planned Skills)

- **python-claude-skills (v1.8.0)**: Python workflow optimization.
- **git-claude-skills (v1.8.0)**: Advanced git automation.

---
*Generated by Forge for the Claude Intelligence Hub*
