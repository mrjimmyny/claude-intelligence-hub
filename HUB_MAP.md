# 🗺️ Claude Intelligence Hub - Visual Skill Router

**Version:** 2.28.0
**Status:** 🟢 Active & Synchronized
**Registry:** 24 Production Skills

---

## 📊 Hub Statistics

| Metric | Count | Status |
| :--- | :--- | :--- |
| **Total Skills** | 24 | ✅ Verified |
| **Governance** | 100% | 🟢 Compliant |
| **Architecture** | 3-Tier | 🏗️ Structured |

---

## 🏗️ Skill Architecture (Tiers)

### 🔵 Tier 1: Always-Load (Mandatory)
*The foundation of the system. Loads at every session start.*

| # | Skill Name | Version | Command | Role |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **jimmy-core-preferences** | v3.8.0 | `/preferences` | Master AI Behavior |
| 14 | **token-economy** | v1.0.0 | `/token-economy` | Budget Enforcement |

### 🟢 Tier 2: Context-Aware (Suggested)
*Loads based on triggers or detected project type.*

| # | Skill Name | Version | Command | Triggers |
| :--- | :--- | :--- | :--- | :--- |
| 2 | **session-memoria** | v1.2.0 | `/memoria` | "registre isso", "busca na memoria" |
| 4 | **claude-session-registry** | v1.1.0 | `/registry` | "registra sessão", Golden Close |
| 5 | **pbi-claude-skills** | v1.3.0 | `/pbi` | `.pbip` project detection |
| 7 | **xavier-memory** | v1.1.0 | `/xavier-memory` | Cross-project sync |
| 12 | **agent-orchestration-protocol** | v4.3.0 | `/aop` | "orchestrate", "delegate" |
| 18 | **codex-task-notifier** | v1.2.0 | `/codex-task-notifier` | "email me when done", "me manda um email" |
| 22 | **microsoft-mail-deliver** | v1.2.0 | `/microsoft-mail-deliver` | "via Microsoft", "manda email pelo Microsoft", saved Microsoft recipient workflows |
| 24 | **security-reviewx** | v1.0.0 | `/security-reviewx` | "scan for secrets", "security review", "check before publishing" |
| 19 | **daily-doc-information** | v1.7.1 | `/daily-doc-information` | Session docs, daily reports, and project governance automation |
| 20 | **notebooklmx** | v1.2.0 | `/notebooklmx` | "create a podcast", "generate infographic", "notebooklm", NotebookLM content generation |

### 🟡 Tier 3: Explicit (On-Demand)
*Only loads when manually invoked by the user.*

| # | Skill Name | Version | Command | Usage |
| :--- | :--- | :--- | :--- | :--- |
| 3 | **gdrive-sync-memoria** | v1.0.0 | `/gdrive-sync` | Sync ChatLLM Team data |
| 6 | **x-mem** | v1.0.0 | `/xmem` | Failure/Success learning |
| 8 | **xavier-memory-sync** | v1.0.0 | `/xavier-sync` | GDrive Memory Backup |
| 9 | **context-guardian** | v1.1.0 | `/context-guardian` | Account switching (Xavier/Magneto) |
| 10 | **repo-auditor** | v2.2.0 | `/repo-auditor` | Manual repo integrity audit |
| 11 | **conversation-memoria** | v1.0.0 | `/conversation` | Save/Load session history |
| 13 | **core_catalog** | v1.0.0 | `/catalog` | Bootstrap system data |
| 15 | **codex-governance-framework** | v1.0.0 | `/governance` | Institutional governance docs |
| 16 | **daily-tasks-oih** | v1.0.0 | `/daily-tasks-oih` | Daily tasks pool and per-agent execution workflow |
| 17 | **docx-indexer** | v1.4.0 | `/docx-indexer` | Global document indexing + semantic enrichment + semantic search baseline |
| 21 | **bi-designerx** | v0.2.0 | `/bidx` | BI dashboard design for non-designers (Paper.design + CEM system) |
| 23 | **self-improvement** | v1.0.0 | `/self-improvement` | Iterative refinement framework (audit + simulation, worktree isolation, scoring) |

---

## 🔗 Detailed Routing Map

### 1. jimmy-core-preferences
- **Path:** `jimmy-core-preferences/`
- **Identity:** Global cross-agent operating framework for all agents working with Jimmy.
- **Rules:** Radical Honesty, Objectivity, Prompt Governance (English/file-first), Documentation Language Standard, Hybrid Session Governance, DAX Overlay, Cross-Agent Bootstrap.

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
- **Tool:** Global document indexing system. Append-only JSON index with UUID identity, SHA256 hashing, structural telemetry, semantic enrichment layers, and a validated `Stage 2.5` Voyage-backed semantic search baseline. Scripts at `C:\ai\_skills\docx-indexer\`.
- **Routing rule:** use when discovery, retrieval, or index-aware understanding is needed; skip when the file set is already explicit and the task is only direct editing.

### 18. codex-task-notifier
- **Path:** `codex-task-notifier/`
- **Notification:** Local Windows-first email notifier for Codex task completion. Sends explicit task-end emails through HTTPS pipeline (Resend -> Mailgun) without altering the Codex native UI.
- **Triggers:** "email me when done", "send completion email", "me manda um email", "mande um email quando terminar"

### 22. microsoft-mail-deliver
- **Path:** `microsoft-mail-deliver/`
- **Notification:** Microsoft-native email delivery protocol for CIH agents. Owns the `via Microsoft` transport path, the frozen outbound business-email contract, and the known-recipient registry with `all` resolution.
- **Triggers:** "via Microsoft", "do Microsoft", "manda email pelo Microsoft", "manda email do up4a", recipient add/list/delete/send-to-all workflows

### 19. daily-doc-information
- **Path:** `daily-doc-information/`
- **Version:** v1.6.0
- **Tier:** 2 (Active skill)
- **Command:** `/daily-doc-information`
- **Description:** Automates creation, update, and closure of session documents, daily executive reports, and project documentation (PROJECT_CONTEXT, status-atual, next-step, decisoes). Cross-agent (Claude, Codex, Gemini) and cross-machine compatible.
- **Operations:** create-session, update-session, close-session, create-daily-report, create-project, update-project-status, register-decision, update-next-step
- **Dependencies:** None (self-contained with embedded templates)

### 20. notebooklmx
- **Path:** `notebooklmx/`
- **Version:** v1.1.0
- **Tier:** 2 (Context-Aware)
- **Command:** `/notebooklmx`
- **Description:** Unified programmatic interface for Google NotebookLM. Content generation (audio, video, infographics, slides, quizzes, flashcards, mind maps, data tables, reports), Clarity-First design system, 15 PDF catalog + 5 Havas brand infographic templates, spaced generation protocol, cross-tool auth (nlm + notebooklm-py), MCP integration.
- **Triggers:** "create a podcast", "generate infographic", "notebooklm", "make a quiz", "summarize these URLs"

### 21. bi-designerx
- **Path:** `bi-designerx/`
- **Version:** v0.1.0
- **Tier:** 3 (Explicit/On-Demand)
- **Command:** `/bidx`
- **Aliases:** `/bi-designerx`
- **Description:** End-to-end BI dashboard design workflow for non-designers. AI-driven design generation in Paper.design with Canvas Element Map (CEM) management system. 7-phase pipeline (P0 Kickstart → P6 Version Lock), Multi-Agent Paper Protocol for concurrent artboard access, 7-artifact CEM Package per locked version, front-end agnostic (PBI, Tableau, Looker).
- **Dependencies:** Paper MCP (`http://127.0.0.1:29979/mcp`), `frontend-design` plugin
- **Key files:** `_skills/bi-designerx/` (technical), `obsidian/CIH/projects/skills/bi-designerx/` (documental)

### 23. self-improvement
- **Path:** `self-improvement/`
- **Version:** v1.0.0
- **Tier:** 3 (Explicit/On-Demand)
- **Command:** `/self-improvement`
- **Description:** Agent-agnostic iterative refinement framework for skills, projects, scripts, and protocols. Two-layer testing (audit gate + functional simulation), worktree isolation, weighted scoring per target type, historical tracking, and explicit approval gate. Sub-agents mandatory (Opus 4.6 only).
- **Triggers:** "self-improvement", "improve this skill", "refine this", "run self-improvement on"
- **Key files:** `_skills/self-improvement/` (technical — history/reports), `obsidian/CIH/projects/skills/self-improvement/` (documental)

### 24. security-reviewx
- **Path:** `security-reviewx/`
- **Version:** v1.0.0
- **Tier:** 2 (Context-Aware)
- **Command:** `/security-reviewx`
- **Description:** Comprehensive security review skill — scans repositories for exposed secrets, PII, dangerous files, hardcoded paths, config vulnerabilities, and code vulnerabilities. 7 modules (SECRET, PII, FILE, PATH, CONFIG, CODE, GIT_HISTORY), 3 modes (QUICK, STANDARD, DEEP), 76 patterns. Cross-agent, cross-machine validated.
- **Triggers:** "scan for secrets", "security review", "check for exposed data", "run security scan", "check before publishing"
- **Key files:** `security-reviewx/patterns/` (pattern library), `security-reviewx/SKILL.md` (protocol)

---

## 📋 Roadmap (Planned Skills)

- **python-claude-skills (v1.8.0)**: Python workflow optimization.
- **git-claude-skills (v1.8.0)**: Advanced git automation.

---
*Generated by Forge for the Claude Intelligence Hub*
