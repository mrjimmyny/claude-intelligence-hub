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

**Fallback: frontend-design plugin unavailable (P0 only):**

If the `frontend-design` plugin is not available during P0 concept generation:

1. **Do NOT block the entire pipeline.** P0 is the only phase that depends on `frontend-design`.
2. **Alternative path:** The agent generates HTML/CSS concepts manually (inline styles, no framework dependencies) and presents them to the user as local HTML files or rendered screenshots via Playwright.
3. **Quality gate remains the same:** User must still pick one concept before proceeding.
4. **Report the degradation:** Inform the user that concepts were generated without the design plugin and may lack the visual polish of plugin-generated options.
5. **P1 onwards is unaffected:** All subsequent phases use Paper MCP exclusively — `frontend-design` is never needed after P0.

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

**Note:** The CEM Spec v1.0 documents an older naming convention (`H-LOGO`, `B-ACT`) and a nested JSON schema (v1.0 with `sections` wrapper). Both are stale. **This SKILL.md is authoritative** for the current naming convention (Decision 15) and JSON schema (CEM v2.0, flat `elements` array). CEM Spec v1.1 is the current version and reconciles these (see Section 15 path table).

**Full-depth naming rule (FND-0068):** During P3 (Element Naming), the agent MUST rename ALL elements at ALL tree depths — not just top-level semantic containers. This includes:
- Child SVGs inside icon background frames (e.g., the SVG inside `card-leadership-icon-bg` must be named `card-leadership-icon-svg`, not left as auto-generated "SVG")
- Child rectangles inside row containers (e.g., year indicator dots must be named `card-acq-row-2026-dot`, not "Rectangle")
- Child text labels inside composite frames (e.g., year labels must be named `card-acq-row-2026-year`, not left as "2026")
- Any element Paper auto-names as "SVG", "Rectangle", "Frame", "Text", or a bare content value

**Exception:** SVGVisualElement children inside chart/icon SVG composites (Path, Circle, Line, Polyline, and SVG `<text>` data labels like "37%") are NOT independently renamed. These are rendering primitives of the parent SVG — they cannot be individually addressed or modified outside their SVG context. They are excluded from the CEM element count but their parent SVG IS counted and named.

**Decorative and non-semantic elements:** Some Paper elements serve a purely decorative purpose with no semantic role in the dashboard (e.g., decorative dots, gradient accent shapes, separator lines, background pattern fills). Handling rules:

| Category | Examples | Named? | In CEM JSON? | Notes |
|----------|----------|--------|--------------|-------|
| **Structural decorative** | Section dividers, card separators, header underlines | Yes — use `div_` or `underline_` type | Yes, `active: true` | These are part of the layout system |
| **Accent decorative** | Colored accent dots, gradient shapes, corner ornaments | Yes — use `dot_` or `bg_` type | Yes, `active: true` | Named for tracking, but marked with `"decorative": true` in JSON `notes` field if needed |
| **Background fill** | Full-canvas background rectangles, noise/texture layers | Yes — use `bg_` type | Yes, `active: true` | Part of the design even if not interactive |
| **Redundant/orphan** | Leftover elements from iterations, invisible decorations | No — delete from Paper | No | Clean up during P3; if in doubt, set `active: false` and flag for user review |

**Rule:** Every visible element in Paper MUST be named and tracked in CEM JSON. "Decorative" is not a reason to skip naming — it IS a reason to use a descriptive name that signals the element's role (e.g., `hd_dot_accent_left`, `bd_div_section_separator`).

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
| 3 | DRAFT-OWNER | `bidx-cem-*-v*-DRAFT-OWNER.md` | `obsidian/` | Free |
| 4 | Design Rationale | `bidx-cem-*-v*-rationale.md` | `obsidian/` | Immutable after lock |
| 5 | Screenshot | `bidx-cem-*-v*-screenshot.png` | `_skills/` | Immutable after lock |
| 6 | PDF Export | `bidx-cem-*-v*.0.pdf` | `_skills/` | Generated |
| 7 | HTML Package | `bidx-cem-*-v*.0-package.html` | `_skills/` | Generated |
| 8 | Excel Package | `bidx-cem-*-v*.xlsx` | `_skills/` | Generated |

> **Version notation:** In file patterns above, `v*` is a glob wildcard matching any version. In procedural instructions, `v[N]` represents a variable version number. Concrete references like `v1`, `v3` are real examples of specific versions.

> **Obsidian Mirror Rule (FND-0062):** For PBI projects, all `.md` pack artifacts (Skin baseline, DRAFT-OWNER, Rationale) MUST be copied to `obsidian/CIH/projects/[PROJECT-NAME]/05-final/artifacts/<page-name>/` in addition to `projects/[PROJECT-NAME]/artifacts/<page-name>/`. This ensures Obsidian graph visibility for documental artifacts. JSON, PNG, PDF, HTML, and XLSX stay only in the technical layer.

> **Interactive HTML Package is MANDATORY.** The HTML Package (artifact #7) MUST be generated for every locked CEM version. It provides an interactive visual map of all elements with search, filtering, hover tooltips, and click-to-highlight. This is a non-negotiable deliverable — not optional, not agent-discretionary. Generated via a self-contained HTML file with inline CSS/JS, zero external dependencies. Reference: `bidx-cem-workforce-view-v1.0-package.html`.

> **PDF Generation Method:** Use Playwright `page.pdf()` to convert the Skin print HTML to PDF. No LaTeX/wkhtmltopdf/weasyprint required. See FND-0064.

> **Excel Script — Dynamic Sections (FND-0065):** `generate-cem-excel.js` auto-discovers sections from JSON elements. Do NOT hardcode section names. Color palette cells include visual color swatches.

### 6.4 DRAFT-OWNER Template Requirements (FND-0063)

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

### 6.5 Version Lock Protocol

When the user says "lock v[N]" (or "fechamos a v[N]"):
1. Set `locked: true` in JSON
2. Generate all 8 CEM Package artifacts (including screenshot — see 6.6)
3. JSON and Skin become **immutable** — no agent may modify
4. Any changes require a new version (vN+1) on a new artboard

### 6.5.1 Modifying a Locked Version (Revert/Resume)

Once a version is locked (`locked: true`), it is immutable. If the user wants to modify something from a locked version, a **new version** must be created. The locked version is never changed.

**Step-by-step procedure:**

1. **User signals intent:** "I want to change X in v3" / "reopen v3" / "fix v3" / "modify the locked version"
2. **Agent clarifies:** "v3 is locked and immutable. I'll create v[N+1] with your changes. Confirm?"
3. **User confirms.**
4. **Duplicate the artboard:**
   - Call `duplicate_nodes` on the locked version's artboard
   - Perform the mandatory Post-Duplication Element Audit (Section 8.1)
   - Register new artboard ownership in `artboard-locks.json`
5. **Create new JSON:**
   - Copy the locked version's JSON as the starting point for v[N+1]
   - Set `locked: false`, update `version` to `v[N+1]`, update `artboard_id`
6. **Apply modifications:** Make the requested changes in the new artboard
7. **Resume pipeline:** The new version enters the pipeline at the appropriate phase:
   - Visual changes → resume at P2 (Paper Design)
   - Element additions/removals → resume at P3 (Element Naming)
   - Metadata-only changes → resume at P4 (CEM JSON)
8. **Complete the pipeline** through P5 and P6 (lock) as normal

**What NOT to do:**
- Never set `locked: false` on an existing locked JSON — create a new file
- Never modify the locked version's artboard — duplicate first
- Never skip the post-duplication audit — FND-0029 still applies

### 6.6 Screenshot Export — Autonomous Procedure (FND-0066)

Paper MCP `get_screenshot` returns base64 inline — it does NOT save to file. Agents MUST use the Playwright + Paper UI Export method to generate screenshot artifacts autonomously. **Do NOT ask Jimmy to export manually.**

**Prerequisites:**
- Paper app must be open (session init requirement per FND-0060)
- Paper file URL must be stored in the project's `PROJECT_CONTEXT.md` under `Paper File URL:`
- Playwright MCP must be available

**Autonomous procedure (step-by-step):**

1. **Get artboard node ID:** Call Paper MCP `get_basic_info` → read `artboards[].id` for target artboard
2. **Get Paper file URL:** Read `PROJECT_CONTEXT.md` → extract `Paper File URL:` value
3. **Construct full URL:** `{paper_file_url}?node={artboard_id}`
4. **Navigate Playwright:** `browser_navigate` to the constructed URL
5. **Wait for load:** Paper UI renders the file with artboard selected
6. **Take snapshot:** `browser_snapshot` to find the Export button ref
7. **Click Export:** `browser_click` on the Export button (`Export Ctrl + Shift + E`)
8. **File downloads:** Playwright reports the downloaded file path
9. **Copy to pack:** Copy downloaded PNG to `projects/[PROJECT-NAME]/artifacts/<page-name>/bidx-cem-<page-name>-v[N]-screenshot.png`
10. **Cleanup:** Remove temp file from `.playwright-mcp/`

**If Paper file URL is missing from PROJECT_CONTEXT.md:**
- Navigate Playwright to `https://app.paper.design` (Jimmy must be logged in)
- Use `browser_evaluate` → `window.location.href` to capture the URL after Jimmy navigates to the file
- Store the URL in PROJECT_CONTEXT.md for future use

**What NOT to do:**
- Do NOT ask Jimmy to export manually — this procedure is 100% autonomous
- Do NOT rely on Paper MCP `get_screenshot` for file artifacts — it returns base64 only
- Do NOT skip storing the Paper file URL in PROJECT_CONTEXT.md — it's needed for all future exports

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
└── decisoes.md           # Decision log (D1-D21)
```

### Per-Project Structure (PBI Projects)

```
projects/[PROJECT-NAME]/
├── pbip/                 # PBI .pbip project files (Power BI Project format)
├── user-start-input/     # P0 inputs (screenshots, links, descriptions)
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
│           ├── *-v*-DRAFT-OWNER.md
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

### 11.1 Cross-Agent Handoff Protocol

When one agent completes work on a pipeline phase and a different agent will continue (e.g., Magneto finishes P3, Emma picks up P4), the outgoing agent MUST commit a handoff block to the session doc and ensure all state is persisted. The incoming agent MUST read this block before starting work.

**Handoff state — required fields:**

```markdown
## bi-designerx Handoff

| Field | Value |
|-------|-------|
| **Pipeline phase completed** | P3 (Element Naming) |
| **Next phase** | P4 (CEM JSON Creation) |
| **Artboard lock status** | `magneto` holds `19L-0` (v5) — release/transfer needed |
| **Last CEM JSON path** | `_skills/bi-designerx/canvas-maps/people-overview/bidx-cem-people-overview-v5.json` |
| **JSON locked?** | No (`locked: false`) |
| **Modified elements** | `bd_icon_turnover` renamed, `hd_tab_analytics` added, `ft_lbl_draft` set `active: false` |
| **Pending user decisions** | User has not confirmed color palette for v5 header tabs |
| **Paper MCP verified** | Yes — last scan at 2026-04-03 14:30 |
| **Commit hash** | `a1b2c3d` (all changes committed and pushed) |
```

**Outgoing agent responsibilities:**
1. Commit ALL changes (JSON, lock file, session doc) before handoff
2. Release or explicitly note artboard lock status — the incoming agent must know if a takeover is needed
3. List every element modified during the session (additions, renames, deletions, active flag changes)
4. Flag any pending user decisions that block the next phase

**Incoming agent responsibilities:**
1. Read the handoff block and verify the commit hash matches HEAD
2. Verify artboard lock — assume or request takeover as needed
3. Verify Paper MCP is responsive before starting work
4. Do NOT rely on session memory from the outgoing agent — only committed artifacts and the handoff block are authoritative

### 11.2 Codex Loading Example

When dispatching bi-designerx work to Codex (headless), include the operational sections of SKILL.md in the `<INSTRUCTIONS>` block. Codex does not have `/bidx` slash command access.

**What to include (operational — required for execution):**
- Section 2: Quick Reference — Pipeline Phases
- Section 3: Design Principles (Non-Negotiable)
- Section 6.1-6.2: Naming Convention + JSON Schema
- Section 7: Multi-Agent Paper Protocol (Q2)
- Section 11: Agent-Specific Notes (this section)
- Section 12: Operational Constraints

**What to omit (reference — load only if needed):**
- Section 16: Decision Summary (historical context, not operational)
- Section 17: Version History (changelog, not operational)
- Section 14: Known Limitations (useful but not required for task execution)
- Section 15: File Locations (provide only the paths relevant to the specific task)

**Example `<INSTRUCTIONS>` block for a P4 task:**

```
<INSTRUCTIONS>
You are executing bi-designerx Phase 4 (CEM JSON Creation) for the people-overview page.

## Pipeline Context
- Current phase: P4 (CEM JSON Creation)
- Input: P3 output — all elements named on artboard 19L-0
- Output: CEM JSON file at _skills/bi-designerx/canvas-maps/people-overview/bidx-cem-people-overview-v5.json
- Gate: JSON must be reviewed and validated before P5

## Key Rules (from SKILL.md)
[Paste Section 3: Design Principles verbatim]
[Paste Section 6.1-6.2: Naming Convention + JSON Schema verbatim]
[Paste Section 7.1-7.4: Multi-Agent Paper Protocol verbatim]

## Artboard Lock
You are assigned to artboard 19L-0 (v5). Check artboard-locks.json before writing.

## Write Guard
Codex has NO system-level write guard. You MUST check artboard-locks.json manually before every Paper write call. This is prompt-enforced discipline — there is no hook to stop you.
</INSTRUCTIONS>
```

### 11.3 Gemini Context Window Guidance

SKILL.md is 670+ lines. When loading it into Gemini (which may have tighter effective context utilization than Claude), split it into primary and on-demand sections.

**Primary load (Sections 1-8 + 11-13) — operational core:**
- Sections 1-8: Overview, pipeline, principles, prerequisites, P0, CEM system, Q2 protocol, Paper constraints
- Sections 11-13: Agent notes, operational constraints, error handling

**On-demand load (Sections 9-10, 14-17) — reference material:**
- Section 9: Layer Ordering (load only during P2 Paper Design work)
- Section 10: Folder Structure (load only when creating files or navigating the project)
- Sections 14-17: Limitations, file paths, decisions, version history (load only for debugging or historical context)

**Practical approach:** The AOP dispatch prompt should include the primary sections inline and reference on-demand sections by file path, instructing Gemini to read them only when the task requires it.

### 11.4 Post-Session Verification Checklist (Codex/Gemini)

Claude Code has system-level hooks (PreToolUse) that prevent unauthorized writes. Codex and Gemini rely on prompt-based discipline, which is weaker. After any Codex or Gemini session that touched bi-designerx, the orchestrator (or the next Claude Code session) MUST run this verification checklist.

**Post-session verification — 5 checks:**

| # | Check | How to verify | Failure action |
|---|-------|---------------|----------------|
| V-01 | No locked artboards were modified | Compare `artboard-locks.json` timestamps; run `get_tree_summary` on locked artboards and diff against last known state | Revert unauthorized changes via Paper MCP; file FND ticket |
| V-02 | `artboard-locks.json` integrity | Read the lock file; verify all entries have valid `agent`, `artboard_id`, `version`, and `timestamp` fields; no orphan locks for non-existent artboards | Fix or remove invalid entries |
| V-03 | No CEM JSON modified without approval | `git diff` on all `bidx-cem-*-v*.json` files; any changes to `locked: true` files are violations | `git checkout` the violated file; file FND ticket |
| V-04 | No Skin baseline modified without approval | `git diff` on all `bidx-cem-*-v*.0.md` files; same rule as V-03 | `git checkout` the violated file; file FND ticket |
| V-05 | Pipeline phase consistency | Read session doc handoff; verify the declared "phase completed" matches actual artifact state (e.g., if P4 claimed complete, JSON must exist and pass schema validation) | Correct the session doc; re-run incomplete phase |

**When to run:** After every headless Codex or Gemini session. Before starting any new phase that depends on the headless session's output. This is non-negotiable — trust but verify.

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
| **E-08: Playwright PDF timeout** | `page.pdf()` hangs or returns empty | Restart Playwright browser context, verify Skin print HTML renders correctly, retry with `--no-sandbox` if permission error |

### 13.1 Partial Pipeline Failure Recovery

When a pipeline phase fails midway, follow these recovery procedures to avoid corrupted or orphaned state.

**P4 — JSON scan interrupted mid-element:**

| State | What exists | Recovery |
|-------|------------|----------|
| Scan started, no JSON written yet | Nothing to clean up | Restart P4 from scratch — re-scan all elements |
| JSON partially written (some elements mapped) | Incomplete JSON file | Delete the partial JSON file entirely. Never resume from a partial JSON — Principle 1 requires a complete scan. Restart P4 |
| Scan complete, validation failed | Complete but invalid JSON | Fix validation errors in the JSON (missing fields, wrong coordinates). Re-scan only the failed elements via targeted `get_node_info` + `get_computed_styles` |

**P5 — Generation fails midway (some artifacts created, some not):**

| State | What exists | Recovery |
|-------|------------|----------|
| Skin baseline created, DRAFT failed | `.0.md` file exists | Keep the Skin baseline. Regenerate DRAFT-OWNER from the JSON — it is derived, not authoritative |
| DRAFT created, Rationale failed | `.0.md` + DRAFT-OWNER exist | Keep both. Generate Rationale independently — it has no dependency on DRAFT |
| Excel script crashed | JSON + `.md` artifacts exist | Fix the script error. Re-run `generate-cem-excel.js` with the same JSON input. Excel is stateless — safe to retry |
| Playwright PDF timed out | HTML/Skin exist, no PDF | Retry PDF generation. If Playwright is unresponsive, restart the browser context and retry. See E-08 |
| HTML Package template error | Partial or broken HTML file | Delete the broken HTML file. Regenerate from JSON — the HTML package is fully derived from JSON data |

**General rule:** No P5 artifact depends on another P5 artifact. They all derive from the P4 JSON. If any single artifact fails, the others remain valid. Fix and regenerate only the failed artifact.

**P6 — Lock fails after some artifacts generated:**

If the lock process fails midway (e.g., 5 of 8 artifacts created):
1. Do NOT set `locked: true` — the version is not complete
2. Identify which artifacts are missing from the 8-artifact checklist (Section 6.3)
3. Generate only the missing artifacts
4. Once all 8 exist and pass validation, proceed with lock

### 13.2 CEM Package Generation Failures

Artifact-specific recovery for CEM Package (Section 6.3) generation errors:

| # | Artifact | Common Failure | Recovery |
|---|----------|---------------|----------|
| 1 | **JSON** | Paper MCP timeout during scan | Wait 30s, retry. If persistent, verify Paper app is responsive. Restart Paper MCP if needed (E-01) |
| 2 | **Skin Baseline** | Markdown rendering error | Regenerate from JSON. Skin is a deterministic transformation of JSON data |
| 3 | **DRAFT-OWNER** | Template mismatch (missing sections) | Regenerate using the template requirements (Section 6.4). Validate all 6 required sections |
| 4 | **Rationale** | Agent context loss (long session) | Read the JSON + Skin baseline to reconstruct design decisions. Cross-reference with `decisoes.md` |
| 5 | **Screenshot** | Playwright navigation timeout / Paper not loaded | Retry with longer timeout. Ensure Paper file URL is correct in PROJECT_CONTEXT.md. If Paper UI is slow, wait for full render before export (Section 6.6) |
| 6 | **PDF Export** | Playwright `page.pdf()` crash / empty PDF | Restart Playwright browser context. Verify the Skin print HTML renders correctly in browser before PDF conversion. Retry with `--no-sandbox` if permission error |
| 7 | **HTML Package** | Template syntax error / missing element data | Validate JSON has all required fields (`id`, `label`, `type`, `section`, `x`, `y`, `w`, `h`, `active`). Regenerate HTML from corrected JSON |
| 8 | **Excel Package** | `generate-cem-excel.js` crash / Node.js error | Check Node.js version compatibility. Run with `--verbose` flag for detailed error. Common cause: JSON has unexpected null values in coordinate fields |

**Pre-generation checklist (run before starting P5/P6):**
- Verify Paper MCP is responsive: `get_basic_info` should return within 5s
- Verify Playwright MCP is available: `browser_snapshot` should not error
- Verify JSON file exists and passes schema validation
- Verify all file paths in PROJECT_CONTEXT.md are current

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
| CEM artifacts (PBI projects) | `C:\ai\projects\[PROJECT-NAME]\artifacts\<page-name>\` |
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
| D4 | Front-end agnostic architecture | PBI-specific integrations are separate modules, not core dependencies |
| D5 | Reference notebooklmx 03-spec materials | Shared references, no duplication |
| D6 | Test-first approach | Phase 00 validates workflow before formal skill development |
| D7 | Version B (Modern Minimal) as base template | All refinement focuses on Modern Minimal 1280x720 |
| D8 | Flat architecture, no frames | Absolute positioning mandatory |
| D9 | SVG icons via clone only | Maintain reference artboard as icon library |
| D10 | Paper Pro subscription | Unlimited MCP calls, no rate-limit blocking |
| D11 | CEM v1 deprecated — flat rebuild (v2/v3) | Frame-based designs discarded, flat architecture established |
| D12 | Version Lock Protocol | Locked versions are immutable |
| D13 | Sequential Pipeline with gates | P3→P4 is hard-blocked |
| D14 | Global Knowledge Base deferred | Discoveries go to Findings (FND-XXXX), KB is a future project |
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
| 0.1.0 | 2026-03-24 | Initial publication. CEM system (v1-v4), 7-phase pipeline (P0-P6), Multi-Agent Paper Protocol (Q2), 21 decisions, 8 CEM Package artifacts. Phase 00 validated. |

---

*Maintained by Magneto (Claude Code). Project: bi-designerx. Publication authorized by Jimmy.*
