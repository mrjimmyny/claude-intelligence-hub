---
name: notebooklmx
version: 1.0.0
description: Unified programmatic interface for Google NotebookLM with Clarity-First design system, curated infographic style library, and brand template support
command: /notebooklmx
aliases: [/nblmx]
category: Content Generation & Research
status: production
---

# notebooklmx

**Version:** 1.0.0
**Status:** Production (Published to claude-intelligence-hub)
**Category:** Content Generation & Research

> **Published:** 2026-03-23. Authorized by Jimmy. All phases (01-05) complete. 20/20 infographic tests PASS.

---

## Overview

notebooklmx provides programmatic control over Google NotebookLM — enabling automated notebook management, source ingestion, and content generation through two complementary tools:

- **notebooklm-py** (v0.3.4) — Python SDK + CLI for content generation (audio, video, infographics, slides, quizzes, flashcards, mind maps, data tables, reports)
- **notebooklm-mcp-cli** (v0.5.4) — 35 MCP tools for native Claude Code / Gemini / Codex integration

### Core Capabilities

1. **Content Generation** — 11 generation commands (audio, video, cinematic-video, infographic, slide-deck, revise-slide, quiz, flashcards, mind-map, data-table, report)
2. **Infographic Style Library** — 10 built-in + 15 PDF catalog + 5 Havas brand templates with Clarity-First design system
3. **Notebook Management** — CRUD operations, source ingestion (URL, YouTube, text, file, Google Drive)
4. **Cross-Tool Auth** — Single login via `nlm login` with automated cookie sync to notebooklm-py
5. **MCP Integration** — 35 native tools available in Claude Code, Gemini CLI, and Codex CLI

---

## Quick Reference

| Operation | Tool | Command |
|---|---|---|
| Authenticate | nlm | `nlm login` then `nblmx.sh sync` |
| Check auth | nblmx | `nblmx.sh check` |
| List notebooks | nlm | `nlm notebook list` |
| Create notebook | nlm | `nlm notebook create "Title"` |
| Add URL source | nlm | `nlm source add <notebook_id> --url "https://..."` |
| Add text source | nlm | `nlm source add <notebook_id> --text "content"` |
| Generate infographic | notebooklm-py | `notebooklm generate infographic "description" -n <id> --style auto --wait` |
| Generate audio | notebooklm-py | `notebooklm generate audio -n <id> --format deep-dive --length short` |
| Generate video | notebooklm-py | `notebooklm generate video -n <id> --format explainer` |
| Generate cinematic video | notebooklm-py | `notebooklm generate cinematic-video -n <id>` (requires AI Ultra) |
| Generate slide deck | notebooklm-py | `notebooklm generate slide-deck -n <id>` |
| Revise slide | notebooklm-py | `notebooklm generate revise-slide "instruction" -n <id> -a <artifact_id> --slide 0` |
| Generate quiz | notebooklm-py | `notebooklm generate quiz -n <id>` |
| Generate flashcards | notebooklm-py | `notebooklm generate flashcards -n <id>` |
| Generate mind map | notebooklm-py | `notebooklm generate mind-map -n <id>` |
| Generate data table | notebooklm-py | `notebooklm generate data-table -n <id> --description "..."` |
| Generate report | notebooklm-py | `notebooklm generate report -n <id>` |
| Download artifact | notebooklm-py | `notebooklm download <type> [output_path] -n <id>` |
| Studio status | nlm | `nlm studio status <notebook_id>` |
| MCP infographic | MCP tool | `studio_create(notebook_id, artifact_type="infographic", confirm=True)` |

---

## Design Principles (Non-Negotiable)

### Principle 0: On-Demand Generation Only

**MANDATORY — Generation is NEVER automatic or batched.**

- The agent generates ONLY what the user explicitly requests, nothing more
- If the user asks for 1 infographic, generate exactly 1 infographic — not 1 infographic + 1 audio + 1 slide deck
- If the user asks for 2 infographics and 1 audio, generate exactly 2 infographics and 1 audio
- NEVER assume "generate everything available" — each artifact type and quantity must be explicitly stated
- NEVER proactively generate additional artifacts "because they might be useful"
- This protects the user's rate limits and quota across all artifact types

**Examples:**

| User says | Agent does |
|---|---|
| "Generate an infographic about X" | 1 infographic. Nothing else. |
| "Create 2 infographics and 1 audio" | 2 infographics + 1 audio. Nothing else. |
| "I need a slide deck" | 1 slide deck. Nothing else. |
| "Generate all artifact types" | Only then: generate all types (still 1 of each unless quantity specified) |

### Principle 1: Clarity-First

Every generated artifact MUST prioritize cognitive clarity over visual decoration:

- Maximum 6-8 distinct visual elements per section
- At least 15% whitespace between major sections
- Clear typographic hierarchy: one primary headline, supporting subheads, readable body
- Logical storytelling flow (top-left to bottom-right)
- Anti-clutter: every element must serve an informational purpose

### Principle 2: Text Quality Guards

Every generation prompt MUST include explicit legibility directives:

- No squished, overlapping, or truncated text
- Generous spacing between text elements
- Consistent font sizing within hierarchy levels
- Text must be fully readable at normal viewing distance

### Principle 3: Responsible Usage

Respect Google's undocumented rate limits:

- **Infographic generation:** Max 5-6 per day with mandatory spacing between each. NEVER batch.
- **Infographic rate limit window:** Exceeds 24 hours (rolling, not calendar-based)
- **Other artifacts:** Less restrictive, but space requests reasonably
- **On rate limit error:** Switch to non-infographic tasks immediately. Do not retry.
- **Infographic testing:** SUSPENDED until Jimmy's explicit authorization

---

## Authentication

### Prerequisites

- Python venv at `C:\ai\_skills\notebooklmx\.venv\`
- notebooklm-py v0.3.4 + notebooklm-mcp-cli v0.5.4 installed
- Playwright + Chromium for browser-based auth
- Corporate SSL bypass (`sitecustomize.py`) if behind proxy

### Auth Flow

```
Step 1: nlm login                     → Browser opens, user authenticates with Google
Step 2: nblmx.sh sync                 → Converts nlm cookies to notebooklm-py format
Step 3: nblmx.sh check                → Verifies both tools are authenticated
```

**Detail:**

| Step | What Happens | Storage |
|---|---|---|
| `nlm login` | Opens Chrome, extracts 49 cookies via DevTools | `~/.notebooklm-mcp-cli/profiles/default/cookies.json` |
| `nblmx.sh sync` | Converts Chrome DevTools → Playwright format | `~/.notebooklm/storage_state.json` |
| Session keep-alive | `nblmx-keepalive.bat` pings every 15 min | N/A (prevents session expiry) |
| Quick re-login | `nblmx-login.bat` double-click shortcut | Same as above |

**Session expiry:** ~20 minutes without activity. Use keep-alive or re-login.

### Corporate Environment

If behind a corporate SSL inspection proxy:

```python
# sitecustomize.py in venv site-packages
import ssl
ssl._create_default_https_context = ssl._create_unverified_context
```

This file MUST be preserved during venv recreation.

---

## Content Generation

### Infographic

```bash
# Using a built-in style
notebooklm generate infographic "focus description" -n <notebook_id> --style professional --wait

# Using a custom style prompt (Clarity-First preamble included in template)
notebooklm generate infographic "<FULL_TEMPLATE_PROMPT>" -n <notebook_id> --style auto --wait --retry 3
```

**Options:**

| Flag | Values | Default |
|---|---|---|
| `--style` | auto, sketch-note, professional, bento-grid, editorial, instructional, bricks, clay, anime, kawaii, scientific | auto |
| `--orientation` | landscape, portrait, square | landscape |
| `--detail` | concise, standard, detailed | standard |
| `--language` | BCP-47 code (en, pt-BR, etc.) | en |
| `--wait / --no-wait` | Wait for completion | no-wait |
| `--retry N` | Retry N times with exponential backoff | 0 |

**Download:**

```bash
notebooklm download infographic [output_path] -n <notebook_id> --latest
notebooklm download infographic --all ./output_dir/ -n <notebook_id>
```

### Audio (Podcast)

```bash
notebooklm generate audio "deep dive focusing on key themes" -n <notebook_id> --format deep-dive --length short --language pt-BR --wait
```

| Flag | Values | Default |
|---|---|---|
| `--format` | deep-dive, brief, critique, debate | deep-dive |
| `--length` | short, default, long | default |
| `--language` | BCP-47 code | en |
| `-s, --source` | Limit to specific source IDs | all |

**Constraint:** 1 active audio per notebook at a time.

### Video

```bash
notebooklm generate video "a funny explainer for kids" -n <notebook_id> --format explainer --style whiteboard --wait
```

| Flag | Values | Default |
|---|---|---|
| `--format` | explainer, brief, cinematic | explainer |
| `--style` | auto, classic, whiteboard, kawaii, anime, watercolor, retro-print, heritage, paper-craft | auto |

**Timing:** 5-15 minutes per video. Cinematic format requires AI Ultra (~30-40 min).

### Slide Deck

```bash
notebooklm generate slide-deck "include speaker notes" -n <notebook_id> --format detailed --wait
```

| Flag | Values | Default |
|---|---|---|
| `--format` | detailed, presenter | detailed |
| `--length` | default, short | default |

### Revise Slide

Revise an individual slide in an existing slide deck:

```bash
notebooklm generate revise-slide "Move the title up" -n <notebook_id> -a <slide_deck_artifact_id> --slide 0 --wait
```

| Flag | Values | Required |
|---|---|---|
| `-a, --artifact` | Slide deck artifact ID | Yes |
| `--slide` | Zero-based index (0 = first slide) | Yes |

### Quiz

```bash
notebooklm generate quiz "focus on vocabulary terms" -n <notebook_id> --quantity more --difficulty hard --wait
```

| Flag | Values | Default |
|---|---|---|
| `--quantity` | fewer, standard, more | standard |
| `--difficulty` | easy, medium, hard | medium |

### Flashcards

```bash
notebooklm generate flashcards "key concepts" -n <notebook_id> --quantity more --difficulty easy --wait
```

| Flag | Values | Default |
|---|---|---|
| `--quantity` | fewer, standard, more | standard |
| `--difficulty` | easy, medium, hard | medium |

### Mind Map

```bash
notebooklm generate mind-map -n <notebook_id> --json
```

**Note:** Mind map does not support `--wait`. Use `notebooklm artifact poll` to check status.

### Data Table

```bash
notebooklm generate data-table "Comparison of features" -n <notebook_id> --wait
```

**Note:** `DESCRIPTION` is required (not optional).

### Report

```bash
notebooklm generate report "focus on AI trends" -n <notebook_id> --format briefing-doc --wait
notebooklm generate report --format study-guide --append "Target audience: beginners" -n <notebook_id> --wait
notebooklm generate report "Create a white paper on..." -n <notebook_id> --format custom --wait
```

| Flag | Values | Default |
|---|---|---|
| `--format` | briefing-doc, study-guide, blog-post, custom | briefing-doc |
| `--append` | Extra instructions for non-custom formats | — |

### Cinematic Video (AI Ultra)

```bash
notebooklm generate cinematic-video "documentary about quantum physics" -n <notebook_id> --wait
```

Alias for `generate video --format cinematic`. Uses Veo 3 AI. Requires Google AI Ultra. Takes ~30-40 min.

---

## Infographic Style Library

### Category A — PDF Catalog Styles (15 by Karine Lago)

Custom style prompts with Clarity-First preamble embedded. Used via the `DESCRIPTION` parameter:

| # | ID | Style | Best For | Tested |
|---|---|---|---|---|
| 01 | nblmx-neon-vaporwave | Neon / Vaporwave | Tech, gaming, entertainment | Yes |
| 02 | nblmx-dashboard | Dashboard / Statistics | Business reports, KPIs | Yes |
| 03 | nblmx-retro-vintage | Retro / Vintage | Historical, heritage | Yes |
| 04 | nblmx-chalkboard | Chalkboard | Educational, tutorials | Yes |
| 05 | nblmx-editorial | Magazine Editorial | Brand content, thought leadership | Yes |
| 06 | nblmx-3d-isometric | 3D / Isometric | Architecture, systems | Yes |
| 07 | nblmx-minimalist | Minimalist / Clean | Executive, modern brands | Yes |
| 08 | nblmx-collage | Collage / Cutouts | Creative briefs, art | Yes |
| 09 | nblmx-corporate | Corporate / Institutional | Annual reports, governance | Yes |
| 10 | nblmx-cartoon | Illustrative / Cartoon | Training, youth content | Pending |
| 11 | nblmx-tech-digital | Technological / Digital | Tech, cybersecurity, AI | Pending |
| 12 | nblmx-handwritten | Handwritten / Manuscript | Personal, brainstorming | Pending |
| 13 | nblmx-art-deco | Art Deco / Gatsby | Luxury, events, awards | Pending |
| 14 | nblmx-timeline | Timeline | Project timelines, roadmaps | Pending |
| 15 | nblmx-blueprint | Blueprint / Technical | Technical specs, engineering | Pending |

Full prompts: `obsidian/CIH/projects/skills/notebooklmx/07-templates/nblmx-infographic-style-templates-v1.0.md`

### Template Selection (Wrapper Command)

The `nblmx.sh` wrapper provides automated template resolution — no need to manually copy prompts:

```bash
# Generate infographic using a template (resolves prompt automatically)
nblmx.sh generate pdf-minimalist --wait --retry 3
nblmx.sh generate havas-corporate --wait

# List all available templates
nblmx.sh templates

# Filter templates by keyword
nblmx.sh templates havas
nblmx.sh templates pdf
```

Template files are stored as `.prompt` files in `_skills/notebooklmx/templates/`. Each file contains the full prompt text (Clarity-First preamble + style description). The `generate` command reads the file and passes it to `notebooklm generate infographic`.

### Category B — Built-in NotebookLM Styles (10 presets)

Native presets accessed via `--style` flag. All tested and validated.

| ID | Flag | Best For |
|---|---|---|
| nblmx-bi-professional | `--style professional` | Corporate, executive |
| nblmx-bi-instructional | `--style instructional` | Education, tutorials |
| nblmx-bi-sketch-note | `--style sketch-note` | Brainstorming, notes |
| nblmx-bi-scientific | `--style scientific` | Research, academic |
| nblmx-bi-editorial | `--style editorial` | Magazine, journalism |
| nblmx-bi-bento-grid | `--style bento-grid` | Modular, dashboard |
| nblmx-bi-bricks | `--style bricks` | Stacked, structural |
| nblmx-bi-clay | `--style clay` | 3D, playful |
| nblmx-bi-kawaii | `--style kawaii` | Cute, youth |
| nblmx-bi-anime | `--style anime` | Creative, entertainment |

### Category C — Havas Converged Brand Templates (5)

Custom brand-aligned templates with Havas visual identity.

| ID | Template | Best For | Tested |
|---|---|---|---|
| nblmx-havas-corporate | H01: Corporate Overview | Company presentations, stakeholder reports | Yes |
| nblmx-havas-dashboard | H02: Data Dashboard | KPI reports, performance metrics | Yes |
| nblmx-havas-process | H03: Process Flow | Workflow docs, methodology | Pending |
| nblmx-havas-intelligence | H04: Intelligence Report | Market intelligence, insights | Pending |
| nblmx-havas-ecosystem | H05: Converged Ecosystem | Service offerings, capability maps | Pending |

Brand spec: Red #E60000, Blue #B3DAE0, Black, White. Baikal font. Circles + pill shapes.

Full prompts: `obsidian/CIH/projects/skills/notebooklmx/07-templates/nblmx-havas-brand-templates-v1.0.md`

---

## MCP Integration

When the MCP server is connected, 35 tools are available natively in Claude Code, Gemini CLI, and Codex CLI.

### Key MCP Tools

| Tool | Purpose |
|---|---|
| `notebook_create` | Create a new notebook |
| `notebook_list` | List all notebooks |
| `notebook_get` | Get notebook details |
| `notebook_delete` | Delete a notebook |
| `source_add` | Add source (URL, text, Drive, file) |
| `source_list_drive` | List Google Drive sources |
| `studio_create` | Create any artifact type |
| `studio_status` | Check artifact generation status |
| `download_artifact` | Download generated artifacts |
| `notebook_query` | Chat with notebook sources |
| `cross_notebook_query` | Query across multiple notebooks |
| `pipeline` | Multi-step automated workflows |
| `batch` | Batch operations across notebooks |
| `research_start` | Start web research |
| `research_status` | Check research status |

### MCP Server Configuration

| Agent | Method | Status |
|---|---|---|
| Claude Code | `nlm setup add claude-code` | Configured |
| Gemini CLI | `nlm setup add gemini` | Configured |
| Codex CLI | `nlm setup add codex` | Configured |

---

## Operational Constraints

| Constraint | Limit | Action |
|---|---|---|
| On-demand only | Generate ONLY what user explicitly requests | Never assume batch. Never add extras. Exact type + quantity as stated. |
| Infographic daily quota | Max 5-6/day, spaced | Never batch. 1 at a time. Switch tasks on limit. |
| Infographic rate limit window | >24h rolling | Do not retry. Wait for Jimmy's authorization. |
| Other artifacts | Less restrictive | Space requests reasonably |
| Audio generation | 1 active per notebook | Wait for completion before next |
| Video generation | 5-15 min per video | Use `--wait` or poll status |
| Session expiry | ~20 minutes | Use keep-alive or re-login |
| Source types | URL, YouTube, text, file, Drive | Full UUID required for operations |

---

## File Locations

| Item | Path |
|---|---|
| Virtual environment | `C:\ai\_skills\notebooklmx\.venv\` |
| Wrapper script | `C:\ai\_skills\notebooklmx\nblmx.sh` |
| Template prompt files | `C:\ai\_skills\notebooklmx\templates\` (20 `.prompt` files) |
| Cookie sync utility | `C:\ai\_skills\notebooklmx\sync-cookies.py` |
| Style templates (PDF) | `obsidian/CIH/projects/skills/notebooklmx/07-templates/nblmx-infographic-style-templates-v1.0.md` |
| Havas brand templates | `obsidian/CIH/projects/skills/notebooklmx/07-templates/nblmx-havas-brand-templates-v1.0.md` |
| Test outputs | `C:\ai\_skills\notebooklmx\test-output\` |
| Login shortcut | `C:\ai\nblmx-login.bat` |
| Keep-alive script | `C:\ai\nblmx-keepalive.bat` |
| SSL bypass | `C:\ai\_skills\notebooklmx\.venv\Lib\site-packages\sitecustomize.py` |
| Design spec | `obsidian/CIH/projects/skills/notebooklmx/03-spec/nblmx-skill-design-spec-v1.0.md` |
| PDF styles catalog | `obsidian/CIH/projects/skills/notebooklmx/03-spec/01_notebooklm_infographics_styles.pdf` |
| Havas brand guidelines | `obsidian/CIH/projects/skills/notebooklmx/03-spec/havas/ConvergedAI_Guidelines.pdf` |

---

## Error Handling

### E-01: Authentication Expired

**Symptom:** `Authentication expired or invalid. Redirected to accounts.google.com`
**Recovery:**
1. Run `nlm login` — authenticate in browser
2. Run `nblmx.sh sync` — convert cookies
3. Run `nblmx.sh check` — verify both tools

### E-02: Infographic Rate Limit

**Symptom:** `RATE_LIMITED` from notebooklm-py or generic `Could not create infographic` from nlm
**Recovery:**
1. STOP all infographic generation immediately
2. Switch to non-infographic tasks
3. Do NOT retry — wait for Jimmy's authorization
4. Other artifact types (audio, video, slides, quiz, etc.) remain available

### E-03: SSL Certificate Error

**Symptom:** `ssl.SSLCertVerificationError` or `CERTIFICATE_VERIFY_FAILED`
**Recovery:**
1. Verify `sitecustomize.py` exists in venv site-packages
2. If missing, recreate: `import ssl; ssl._create_default_https_context = ssl._create_unverified_context`

### E-04: MCP Server Not Connected

**Symptom:** MCP tools not available in Claude Code
**Recovery:**
1. Run `nlm setup add claude-code`
2. Restart Claude Code
3. Verify: `claude mcp get notebooklm-mcp`

### E-05: Unicode Encoding Error (Windows)

**Symptom:** `UnicodeEncodeError: 'charmap' codec` in console output
**Recovery:** Always set `PYTHONIOENCODING=utf-8` before running CLI commands. The `nblmx.sh` wrapper does this automatically.

---

## Known Limitations

1. All unofficial solutions depend on undocumented Google internal APIs — if Google changes endpoints, tools may break
2. `nlm infographic create` CLI and MCP `studio_create(infographic)` return generic errors instead of proper RATE_LIMITED messages (use `notebooklm-py` for infographic generation)
3. `notebooklm login` fails to save `storage_state.json` — use `nlm login` + `sync-cookies.py` instead
4. Infographic rate limit is significantly stricter than other artifact types
5. Style template testing is incomplete (9/15 PDF styles tested, 2/5 Havas tested — testing paused)

---

## Version History

### v0.1.2-draft (2026-03-23)
- Template selection logic implemented: `nblmx.sh generate <template-id>` + `templates` command
- 20 `.prompt` files created (15 PDF + 5 Havas) in `templates/` directory
- Tested styles #08 (Collage/Cutouts) and Havas H01 (Corporate), H02 (Dashboard) — all PASS
- Test score: 9/15 PDF + 2/5 Havas validated. Testing PAUSED.
- Reference bank structure approved as future feature
- Decision: extra wrapper commands (auth, notebook, status) NOT implemented — passthrough via `nblmx.sh nb` / `nblmx.sh nlm` is sufficient

### v0.1.1-draft (2026-03-22)
- Added Principle 0: On-Demand Generation Only (mandatory, non-negotiable)
- Tested styles #06 (3D/Isometric), #07 (Minimalist), #09 (Corporate) — all PASS
- Updated nlm CLI to v0.5.4
- Test score: 8/15 PDF styles validated (5 from batch 1 + 3 from batch 2)

### v0.1.0-draft (2026-03-21)
- Initial SKILL.md structure
- Auth workflow documented (nlm login + cookie sync)
- 9 generation types documented with CLI syntax
- Style library cataloged (10 built-in + 15 PDF + 5 Havas)
- MCP integration documented (35 tools)
- Error handling for 5 known issues
- Rate limit guidance formalized (FND-0008)
- NOT PUBLISHED — Phase 04 draft

---

**Maintained by:** Magneto (Opus 4.6)
**Project:** notebooklmx
**Publication status:** NOT PUBLISHED — requires Jimmy's express authorization
