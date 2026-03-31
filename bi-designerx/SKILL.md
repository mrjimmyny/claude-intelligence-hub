---
name: bi-designerx
version: 0.1.0
description: End-to-end BI dashboard design workflow for non-designers. Generates professional backgrounds in Paper.design via AI, manages designs through the Canvas Element Map (CEM) system, and exports multi-format packages. From blank canvas to locked production asset — zero design skills required.
command: /bidx
aliases: [/bi-designerx]
category: Design & BI
status: production
dependencies:
  - paper-mcp (http://127.0.0.1:29979/mcp)
  - frontend-design (claude-plugins-official)
---

# bi-designerx

**Version:** 0.1.0
**Status:** Production (Phase 00 validated — CEM system production-ready, 3 locked versions)
**Published:** 2026-03-24
**Maintained by:** Magneto (Claude Code)
**Project:** bi-designerx

---

## 1. Overview

bi-designerx is a skill for creating professional BI dashboard backgrounds using AI-driven design generation in Paper.design. It targets **non-designers** who need production-quality visual backgrounds for Power BI, Tableau, Looker, or any BI front-end — without touching a design tool manually.

**Core value proposition:** You provide references (screenshots, links, descriptions). The AI generates design options. You pick one. The system manages everything from there: element naming, JSON mapping, markdown documentation, version locking, and multi-format export.

**Two-layer architecture:**
- **Design layer:** PNG/SVG background generated in Paper.design (AI-controlled)
- **Data layer:** BI-native elements (charts, slicers, KPIs) positioned on top (BI tool-controlled)

**Front-end agnostic:** While Power BI is the primary target, the design backgrounds work with any BI platform that supports background images.

---

## 2. Quick Reference — Pipeline Phases

| Phase | Name | Input | Output | Gate |
|-------|------|-------|--------|------|
| **P0** | **Kickstart** | References, screenshots, descriptions | 2-3 concept options in Paper | User picks one |
| **P1** | Pre-Paper | Curated materials, brand guidelines | Refined reference set | User validates sufficiency |
| **P2** | Paper Design | P1 output or P0 selected concept | Artboard with all elements | User validates visual design |
| **P3** | Element Naming | P2 output | Every element has unique semantic name | User validates ALL names (HARD BLOCK) |
| **P4** | CEM JSON Creation | P3 output (named elements) | CEM JSON with all elements mapped | JSON reviewed and validated |
| **P5** | Markdown Generation | P4 output (validated JSON) | Skin baseline + DRAFT-OWNER + Package artifacts | Documents derived from JSON |
| **P6** | Version Lock | P5 output + user approval | `locked: true`, immutable JSON + full CEM Package | Only user triggers lock |

**Critical gate:** P3 to P4 is HARD-BLOCKED. JSON creation is impossible until every Paper element has a validated unique name.

**Iteration sub-cycle** (during active development within P2-P5):
```
User edits DRAFT → Agent applies to Paper → Agent updates JSON (with approval) → Agent updates Skin → Agent refreshes DRAFT
```

---

## 3. Design Principles (Non-Negotiable)

These rules are absolute. No agent may override them regardless of context.

### Principle 0: Flat Architecture Only
All elements in Paper.design use absolute positioning directly on the artboard root. No nested flex frames. Every element is freely movable by pixel coordinates. Frames cause alignment issues and block free movement (validated through FND-0015).

### Principle 1: Paper MCP Scan Mandatory
CEM JSON files MUST be generated exclusively via real-time Paper MCP scan. NEVER from memory, mental models, cached data, or manually compiled element lists. Every element's `active` flag must reflect actual visibility (`isVisible` from `get_node_info`). If Paper MCP is unavailable, JSON generation is BLOCKED (FND-0023).

### Principle 2: CEM Protection
Any modification to a CEM JSON file (`bidx-cem-*-v*.json`) or Skin baseline (`bidx-cem-*-v*.0.md`) is a **destructive action** requiring the user's explicit approval for each individual change. DRAFT-OWNER files remain freely editable (Decision 16).

### Principle 3: Sequential Pipeline
Pipeline phases are sequential with mandatory validation gates. No phase may be skipped. No phase reversal without user's explicit decision (Decision 13).

### Principle 4: One Agent Per Artboard
Each agent owns exactly one artboard for writing. All artboards are readable. Ownership tracked in `artboard-locks.json`. Unauthorized writes are blocked by system hook (Claude Code) or prompt discipline (Codex/Gemini) (Decision 19).

---

## 4. Prerequisites

| Requirement | Details |
|-------------|---------|
| **Paper.design account** | Paper Pro recommended ($20/mo for ~1M MCP calls/week) |
| **Paper MCP** | Running at `http://127.0.0.1:29979/mcp` |
| **Paper MCP registration** | `claude mcp add paper --transport http http://127.0.0.1:29979/mcp --scope user` |
| **frontend-design plugin** | Required for P0 Kickstart concept generation |
| **Paper sandbox** | Active file in Paper.design with at least one page |

**Current sandbox:** `https://app.paper.design/file/01KM5XES71P7BK5ZG2W99576NN`

---

## 5. P0 — Kickstart (From Zero to First Draft)

P0 is the entry point for non-designers. It eliminates "blank canvas paralysis" by generating visual concepts from references.

### 5.1 User Inputs

Place all reference materials in `user-start-input/`:

| Input Type | Examples | Purpose |
|------------|----------|---------|
| Screenshots | `.png`, `.jpg` of existing dashboards | Visual reference patterns |
| Links | URLs to design inspiration, Dribbble, Behance | Aesthetic direction |
| Descriptions | Text file or conversation | What KPIs, what audience, what feeling |
| PBI files | `.pbix`, `.pbip` project | Data model, existing visuals, KPI structure |
| Brand assets | Logos, color codes, font names | Corporate identity |

**Folder paths:**
- Skill-level template: `_skills/bi-designerx/user-start-input/`
- Per-project: `projects/[PROJECT-NAME]/user-start-input/` (technical layer)
- Per-project docs: `obsidian/CIH/projects/[PROJECT-NAME]/` (documental layer)

### 5.2 Agent Workflow

```
Step 1: Analyze inputs
  - Extract visual patterns (card layouts, color schemes, typography)
  - Identify KPI structure from PBI data model (if provided)
  - Build reference analysis summary

Step 2: Generate concepts
  - Use frontend-design skill to create 2-3 HTML/CSS options at 1280x720
  - Each concept follows a different aesthetic approach
  - Present concepts to user with rationale

Step 3: User picks one

Step 4: Render to Paper
  - Create artboard via Paper MCP create_artboard (1280x720)
  - Write HTML into artboard via write_html
  - Auto-register artboard ownership (Q2 Protocol)

Step 5: Pipeline continues at P2 (Paper Design refinement)
```

### 5.3 Aesthetic Defaults

Unless the user specifies otherwise, use:
- **Primary:** Corporate Clean + Modern Minimal (light backgrounds, flat colors, strong geometry, subtle card shadows)
- **Dimensions:** 1280x720 (standard PBI report size)
- **Typography:** DM Sans (available in Paper via Google Fonts)

---

## 6. CEM System (Canvas Element Map)

The CEM is the structured registry of every visual element on a Paper.design canvas. It enables precise communication during design iteration via semantic IDs.

### 6.1 Naming Convention

Pattern: `{section}_{type}_{identity}`

| Segment | Position | Values |
|---------|----------|--------|
| Section | 1st (2 chars) | `hd` (header), `bd` (body), `ft` (footer) |
| Type | 2nd | `bg`, `tab`, `lbl`, `icon`, `iconbg`, `lgd`, `sub`, `dot`, `img`, `num`, `bar`, `badge`, `underline`, `div`, `ind` |
| Identity | 3rd | Descriptive name |

**Examples:** `hd_tab_overview`, `bd_bg_actives`, `bd_icon_turnover`, `ft_lbl_confidential`

Names are synchronized across Paper layers, JSON IDs, DRAFT tables, and Skin baselines (Decision 15).

**Important:** The type segment (`bg`, `tab`, `lbl`, etc.) identifies the element's **semantic role** in the naming convention. The JSON `type` field reflects the **Paper.design node type** (`text`, `frame`, `svg`, `image`, `badge`). These are different — `bd_bg_actives` has naming type `bg` but JSON type `frame`.

**Note:** The CEM Spec v1.0 documents an older naming convention (`H-LOGO`, `B-ACT`) and a nested JSON schema (v1.0 with `sections` wrapper). Both are stale. **This SKILL.md is authoritative** for the current naming convention (Decision 15) and JSON schema (CEM v2.0, flat `elements` array). A CEM Spec v1.1 is planned to reconcile these.

### 6.2 JSON Schema

```json
{
  "cem_version": "2.0",
  "locked": false,
  "page": {
    "id": "PG-PEOPLE-OVERVIEW",
    "slug": "people-overview",
    "dimensions": { "w": 1280, "h": 720 },
    "artboard_id": "19L-0",
    "source": "paper.design",
    "version": "v4",
    "architecture": "flat"
  },
  "elements": [
    {
      "id": "hd_img_logo",
      "label": "Company Logo",
      "type": "image",
      "section": "header",
      "paper_node_id": "1CP-0",
      "x": 30, "y": 34, "w": 91, "h": 19,
      "active": true
    }
  ]
}
```

**Key fields:**
- `id` — unique semantic name (global within page)
- `paper_node_id` — Paper.design node reference
- `x, y, w, h` — absolute artboard coordinates
- `active` — boolean from Paper's `isVisible` (Principle 1)

### 6.3 CEM Package (8 Artifacts per Locked Version)

| # | Artifact | File Pattern | Layer | Protection |
|---|----------|-------------|-------|------------|
| 1 | JSON | `bidx-cem-*-v*.json` | `_skills/` | Destructive |
| 2 | Skin Baseline | `bidx-cem-*-v*.0.md` | `obsidian/` | Destructive |
| 3 | DRAFT-OWNER | `bidx-cem-*-DRAFT-OWNER.md` | `obsidian/` | Free |
| 4 | Design Rationale | `bidx-cem-*-v*-rationale.md` | `obsidian/` | Immutable after lock |
| 5 | Screenshot | `bidx-cem-*-v*-screenshot.png` | `_skills/` | Immutable after lock |
| 6 | PDF Export | `bidx-cem-*-v*.0.pdf` | `_skills/` | Generated |
| 7 | HTML Package | `bidx-cem-*-v*.0-package.html` | `_skills/` | Generated |
| 8 | Excel Package | `bidx-cem-*-v*.xlsx` | `_skills/` | Generated |

> **Obsidian Mirror Rule (FND-0062):** For PBI projects, all `.md` pack artifacts (Skin baseline, DRAFT-OWNER, Rationale) MUST be copied to `obsidian/CIH/projects/[PROJECT-NAME]/05-final/artifacts/<page-name>/` in addition to `projects/[PROJECT-NAME]/artifacts/<page-name>/`. This ensures Obsidian graph visibility for documental artifacts. JSON, PNG, PDF, HTML, and XLSX stay only in the technical layer.

> **Interactive HTML Package is MANDATORY.** The HTML Package (artifact #7) MUST be generated for every locked CEM version. It provides an interactive visual map of all elements with search, filtering, hover tooltips, and click-to-highlight. This is a non-negotiable deliverable — not optional, not agent-discretionary. Generated via a self-contained HTML file with inline CSS/JS, zero external dependencies. Reference: `bidx-cem-workforce-view-v1.0-package.html`.

> **PDF Generation Method:** Use Playwright `page.pdf()` to convert the Skin print HTML to PDF. No LaTeX/wkhtmltopdf/weasyprint required. See FND-0064.

> **Excel Script — Dynamic Sections (FND-0065):** `generate-cem-excel.js` auto-discovers sections from JSON elements. Do NOT hardcode section names. Color palette cells include visual color swatches.

### 6.5 DRAFT-OWNER Template Requirements (FND-0063)

Every DRAFT-OWNER file MUST include:

1. **"How to Edit" guide** with examples (before/after, removing elements)
2. **Per-section comment blocks** — after every section's tables, include:
   ```
   **[Section] notes/instructions:**
   <!-- Write any [section]-specific instructions here -->
   ```
3. **`Changes` column** in all element tables for per-element annotations
4. **Visual Properties table** split per section (not a single monolithic table)
5. **General Notes** section at the end with `<!-- -->` placeholder
6. **Global Overrides** section with its own comment block

Reference template: `obsidian/CIH/projects/skills/bi-designerx/05-canvas-maps/bidx-cem-people-overview-v1-DRAFT-OWNER.md`

### 6.6 Version Lock Protocol

When the user says "lock v[N]" (or "fechamos a v[N]"):
1. Set `locked: true` in JSON
2. Generate all 7 CEM Package artifacts
3. JSON and Skin become **immutable** — no agent may modify
4. Any changes require a new version (vN+1) on a new artboard

---

## 7. Multi-Agent Paper Protocol (Q2)

Enables multiple agents to work on different design versions (artboards) within the same Paper page.

### 7.1 Rules

- **1 agent per artboard** (writes). All artboards readable by any agent.
- **User assigns explicitly** — natural language ("work on v4", "assume v3").
- **Write guard** — Claude Code: system-level PreToolUse hook blocks unauthorized writes. Codex/Gemini: prompt-enforced discipline.
- **Lock file** — `_skills/bi-designerx/canvas-maps/artboard-locks.json` tracks ownership.

### 7.2 Commands

| Command | Trigger | Effect |
|---------|---------|--------|
| **Assume** | "work on v4", "assume v3", "continue v2" | Agent resolves artboard ID, checks lock, registers or takes over |
| **Release** | "release v4", "done with v3" | Agent removes lock entry |
| **Auto-register** | Agent creates new artboard | Automatic lock registration |

### 7.3 Daily Flow (Stale Lock Takeover)

```
Agent: "v4 is held by magneto from yesterday. Can I take over?"
User: "go ahead" / "libera" / any confirmation
Agent: overwrites lock → work begins
```

No artboard IDs needed. Agent resolves version names from Paper + lock file.

### 7.4 Write Guard — Paper MCP Tools Classification

| Category | Tools | Lock Required |
|----------|-------|---------------|
| **Write** (blocked) | `write_html`, `delete_nodes`, `set_text_content`, `rename_nodes`, `update_styles` | Yes |
| **Special** (allowed) | `create_artboard`, `duplicate_nodes` | No (register after) |
| **Read** (always) | `get_basic_info`, `get_children`, `get_node_info`, `get_screenshot`, `get_computed_styles`, `get_jsx`, `get_tree_summary`, `get_fill_image`, `get_font_family_info`, `get_guide` | No |
| **Housekeeping** | `finish_working_on_nodes` | No |

---

## 8. Paper.design Constraints

These are platform-level limitations discovered during Phase 00 testing.

| Constraint | Detail | Workaround |
|------------|--------|------------|
| No nested flex frames | Frames lock child positioning, cause overflow (FND-0015) | Flat architecture only (Principle 0) |
| SVG via clone only | `write_html` with inline SVG renders blank 0x0 nodes | Clone from reference artboard (Decision 9) |
| Relative coordinates | `get_computed_styles` returns child-relative positions | Conversion: `absolute = parent_pos + child_relative` (FND-0022) |
| No layer reorder API | No MCP tool for "bring to front" / "send to back" | Create elements in z-order: bg first, text last (Decision 17) |
| Working indicator | Auto-set on write, clears on inactivity | Visual safety net, no enforcement power |
| Unreliable descendant map | `duplicate_nodes` can return swapped ID mappings in `descendantIdMap` (FND-0029) | Mandatory post-duplication audit (see below) |

### 8.1 Post-Duplication Element Audit (MANDATORY)

After ANY artboard duplication via `duplicate_nodes`, the agent MUST perform a full element audit before any design modifications. The `descendantIdMap` returned by Paper MCP is **unreliable** — adjacent elements with consecutive original IDs can have their new IDs swapped in the map.

**Mandatory steps:**

1. Run `get_tree_summary` (depth 4+) on the new artboard
2. Verify ALL element names match actual positions via `get_computed_styles`
3. Cross-reference the descendant map against the tree summary — **tree is authoritative**
4. Fix any misplacements BEFORE proceeding with design modifications
5. Text elements can be verified by content match (self-identifying)

**This audit is non-negotiable.** Skipping it risks silent element misplacement that is invisible until manual visual inspection reveals wrong colors, overlapping elements, or misplaced content.

**Reference:** FND-0029 — In the v4-to-v5 duplication, `bd_iconbg_women` and `bd_iconbg_compensation` had their v5 IDs swapped, causing the purple women icon background to appear on the turnover card.

---

## 9. Layer Ordering (Z-Order)

Elements render by **creation order**, not by name. Create in this sequence:

```
CREATE FIRST (renders behind):
  1. bg_       — card/section backgrounds
  2. iconbg_   — icon background tints
  3. div_      — dividers

CREATE LAST (renders in front):
  4. ind_/lgd_ — indicators, legend items
  5. icon_/img_ — icons, images
  6. lbl_/txt_/sub_/tab_ — text elements
```

When adding elements to existing designs, manual "Bring to front" in Paper UI may be needed.

---

## 10. Folder Structure

### Technical Layer (`_skills/bi-designerx/`)

```
_skills/bi-designerx/
├── canvas-maps/
│   ├── artboard-locks.json          # Q2 artboard ownership
│   ├── .paper-agent-id              # Session agent identity (gitignored)
│   └── people-overview/             # Per-page CEM files
│       ├── bidx-cem-*-v*.json       # CEM JSON (source of truth)
│       ├── bidx-cem-*-v*.0.pdf      # PDF exports
│       ├── bidx-cem-*-v*.0-package.html  # HTML packages
│       └── bidx-cem-*-v*-screenshot.png  # Design screenshots
├── scripts/
│   ├── paper-write-guard.sh         # PreToolUse hook
│   └── generate-cem-excel.js        # Excel package generator
├── user-start-input/                # P0 reference inputs (skill-level template)
├── assets/                          # Shared design assets (logos, icons)
└── exemples/                        # Reference PBI projects
```

### Documental Layer (`obsidian/CIH/projects/skills/bi-designerx/`)

```
obsidian/CIH/projects/skills/bi-designerx/
├── 00-research/          # Deep research reports
├── 02-planning/          # Implementation plans, rationale specs
├── 03-spec/              # CEM spec, Q2 protocol spec
├── 04-tests/             # Test plans
├── 05-canvas-maps/       # Skin baselines, DRAFTs, rationales, Page Cards
├── 06-operationalization/ # Deployment docs
├── PROJECT_CONTEXT.md    # Project charter
├── README.md             # Project overview
├── status-atual.md       # Current phase and progress
├── next-step.md          # Immediate action items
└── decisoes.md           # Decision log (D1-D20)
```

### Per-Project Structure (PBI Projects)

```
projects/[PROJECT-NAME]/
├── pbip/                 # PBI .pbip project files (Power BI Project format)
├── user-inputs/          # P0 inputs (screenshots, links, descriptions)
├── artifacts/            # ALL CEM package files (8 artifacts per locked version)
│   └── <page-name>/      # One subfolder per dashboard page
│       ├── *.json        # CEM JSON
│       ├── *.md          # Skin baseline, DRAFT-OWNER, Rationale
│       ├── *.png         # Screenshots
│       ├── *.pdf         # PDF exports
│       ├── *.html        # HTML packages
│       └── *.xlsx        # Excel packages
└── README.md

obsidian/CIH/projects/[PROJECT-NAME]/
├── 05-final/
│   └── artifacts/
│       └── <page-name>/     # Mirror of .md artifacts from technical layer
│           ├── *-DRAFT-OWNER.md
│           ├── *-v*.0.md    # Skin baseline
│           └── *-rationale.md
└── (standard documental structure: PROJECT_CONTEXT, status-atual, next-step, decisoes)
```

> **Note:** `canvas-maps/` exists ONLY in the skill's own technical layer (`_skills/bi-designerx/canvas-maps/`) for skill development and testing. PBI projects use `artifacts/` per PROJECT_TYPES.md convention.

---

## 11. Agent-Specific Notes

| Agent | Loading | Paper MCP | Write Guard | AOP Role |
|-------|---------|-----------|-------------|----------|
| **Claude Code** | `/bidx` (auto from `~/.claude/skills/` symlink) | Native MCP connection | PreToolUse hook (enforced) | Orchestrator or executor |
| **Codex** | `<INSTRUCTIONS>` block with SKILL.md content | Paper MCP HTTP endpoint | Prompt-based discipline | Executor (headless) |
| **Gemini** | File read of SKILL.md | Paper MCP HTTP endpoint | Prompt-based discipline | Executor (headless) |

**All agents** must:
1. Check `artboard-locks.json` before any Paper write
2. Follow the sequential pipeline (Principle 3)
3. Never generate CEM JSON from memory (Principle 1)
4. Treat JSON/Skin edits as destructive actions (Principle 2)

---

## 12. Operational Constraints

| Constraint | Limit | Action |
|------------|-------|--------|
| CEM JSON modification | Destructive action | Explicit user approval per change |
| Skin baseline modification | Destructive action | Explicit user approval per change |
| Pipeline phase skip | Forbidden | Complete current phase before next |
| Artboard concurrent write | 1 agent per artboard | Check lock file, assume command |
| JSON from memory | Forbidden | Always scan Paper MCP in real-time |
| Files in repo root | Forbidden | Route to `_skills/` or `obsidian/` |
| Frame-based layout | Forbidden | Flat architecture, absolute positioning |

---

## 13. Error Handling

| Error | Symptom | Recovery |
|-------|---------|----------|
| **E-01: Paper MCP down** | Connection refused at localhost:29979 | Start Paper.design app, verify MCP is running |
| **E-02: Stale artboard lock** | "Artboard held by [agent] from [date]" | User confirms takeover ("go ahead") |
| **E-03: JSON corruption** | Element mismatch between Paper and JSON | Re-scan Paper MCP: `get_children` + `get_computed_styles` + `get_node_info` for all elements |
| **E-04: SVG render blank** | write_html with SVG produces 0x0 node | Clone SVG from reference artboard instead |
| **E-05: Layer ordering wrong** | New element renders behind background | User manually "Bring to front" in Paper UI |
| **E-06: Rate limit (Paper free)** | MCP calls blocked | Upgrade to Paper Pro ($20/mo) |
| **E-07: No lock file** | "No artboard lock file found" | Create empty lock file or run assume command |

---

## 14. Known Limitations

1. **Paper.design is in Alpha** — unexpected behaviors may occur. The flat architecture workaround (Principle 0) mitigates most issues.
2. **No layer reorder API** — elements can only be reordered manually in Paper UI. Agents must create elements in correct z-order.
3. **SVG clone only** — inline SVGs via write_html are broken. Must clone from existing reference artboards.
4. **P0 Kickstart is new** — the frontend-design → Paper pipeline is designed but not yet stress-tested across multiple projects.
5. **Single Paper file** — all artboards live in one Paper file. Large projects with many versions may hit performance limits.
6. **Cross-agent write guard** — only Claude Code has system-level enforcement (PreToolUse hook). Codex and Gemini rely on prompt-based discipline.

---

## 15. File Locations

| Resource | Absolute Path |
|----------|---------------|
| Skill (hub) | `C:\ai\claude-intelligence-hub\bi-designerx\` |
| Technical layer | `C:\ai\_skills\bi-designerx\` |
| Documental layer | `C:\ai\obsidian\CIH\projects\skills\bi-designerx\` |
| CEM JSON files (skill) | `C:\ai\_skills\bi-designerx\canvas-maps\people-overview\` |
| CEM artifacts (PBI projects) | `C:\ai\projects\[PROJECT-NAME]\artifacts\[page-name]\` |
| Lock file | `C:\ai\_skills\bi-designerx\canvas-maps\artboard-locks.json` |
| Agent identity | `C:\ai\_skills\bi-designerx\canvas-maps\.paper-agent-id` |
| Write guard hook | `C:\ai\_skills\bi-designerx\scripts\paper-write-guard.sh` |
| Excel generator | `C:\ai\_skills\bi-designerx\scripts\generate-cem-excel.js` |
| CEM Spec | `C:\ai\obsidian\CIH\projects\skills\bi-designerx\03-spec\bidx-cem-design-spec-v1.1.md` (v1.0 preserved as historical) |
| Q2 Protocol Spec | `C:\ai\obsidian\CIH\projects\skills\bi-designerx\03-spec\bidx-multi-agent-paper-protocol-spec-v1.0.md` |
| Decision Log | `C:\ai\obsidian\CIH\projects\skills\bi-designerx\decisoes.md` |
| Paper Sandbox | `https://app.paper.design/file/01KM5XES71P7BK5ZG2W99576NN` |

---

## 16. Decision Summary

21 decisions govern this skill. Key ones:

| # | Decision | Impact |
|---|----------|--------|
| D1 | Paper.design as primary platform | All design flows through Paper MCP |
| D2 | Corporate Clean + Modern Minimal aesthetic | Default visual direction |
| D3 | Two-layer architecture (design bg + BI native) | Skill generates backgrounds only |
| D8 | Flat architecture, no frames | Absolute positioning mandatory |
| D9 | SVG icons via clone only | Maintain reference artboard as icon library |
| D12 | Version Lock Protocol | Locked versions are immutable |
| D13 | Sequential Pipeline with gates | P3→P4 is hard-blocked |
| D15 | Unified naming convention | Same names in Paper, JSON, DRAFT, Skin |
| D16 | CEM edits = destructive actions | Explicit approval per modification |
| D17 | Layer ordering by creation position | Create bg first, text last |
| D18 | CEM Design Rationale artifact | Part of CEM Package (WHY document + technical record) |
| D19 | Multi-Agent Paper Protocol | 1 agent/artboard, lock file, write guard |
| D20 | P0 Kickstart | Non-designer entry point via frontend-design + Paper |
| D21 | Post-Duplication Element Audit | Mandatory audit after duplicate_nodes (FND-0029) |

Full decision log: `obsidian/CIH/projects/skills/bi-designerx/decisoes.md`

---

## 17. Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.1.0 | 2026-03-24 | Initial publication. CEM system (v1-v4), 7-phase pipeline (P0-P6), Multi-Agent Paper Protocol (Q2), 20 decisions, 8 CEM Package artifacts. Phase 00 validated. |

---

*Maintained by Magneto (Claude Code). Project: bi-designerx. Publication authorized by Jimmy.*
