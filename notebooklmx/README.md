# notebooklmx

> Unified programmatic interface for Google NotebookLM — content generation, infographic design system, and multi-agent orchestration.

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](SKILL.md)
[![Status](https://img.shields.io/badge/status-production-success.svg)]()
[![Tests](https://img.shields.io/badge/tests-20%2F20%20PASS-brightgreen.svg)]()

---

## What It Does

**notebooklmx** turns Google NotebookLM into a fully programmable content factory. Create notebooks, ingest sources, and generate production-ready artifacts — all from the command line or via MCP tools.

```
Sources (URLs, PDFs, YouTube, Drive)
        |
        v
   [ NotebookLM ]
        |
        +---> Audio Podcasts (deep-dive, debate, critique)
        +---> Video Explainers (whiteboard, anime, watercolor)
        +---> Infographics (30 styles: PDF catalog + Havas brand + built-in)
        +---> Slide Decks (with per-slide revision)
        +---> Reports (briefing, study guide, blog post)
        +---> Quizzes & Flashcards
        +---> Mind Maps & Data Tables
```

---

## Authentication (First-Time Setup)

The `nlm` and `notebooklm` CLIs live inside a Python virtual environment, not globally on PATH. You have **three options** to authenticate:

**Option A: Use the full path (no activation needed)**
```bash
# From any terminal (Git Bash, PowerShell, CMD):
C:/ai/_skills/notebooklmx/.venv/Scripts/nlm.exe login    # Browser opens → Google OAuth
bash C:/ai/_skills/notebooklmx/nblmx.sh sync              # Sync cookies
bash C:/ai/_skills/notebooklmx/nblmx.sh check             # Verify auth
```

**Option B: Activate the venv first**
```bash
# Git Bash:
source C:/ai/_skills/notebooklmx/.venv/Scripts/activate
nlm login           # Now works without full path
nblmx.sh sync
nblmx.sh check
deactivate          # When done
```

**Option C: Install globally via uv (permanent)**
```bash
# One-time setup — makes nlm available everywhere:
pip install uv
uv tool install notebooklm-mcp-cli
# Now 'nlm login' works from any terminal, any directory
```

> **Common error:** Running `nlm login` in PowerShell without activation → `CommandNotFoundException`. This happens because `nlm` is in the venv, not on the system PATH. Use Option A, B, or C above.

---

## Quick Start

```bash
# 1. Authenticate (see section above for details)
nlm login                          # Opens browser for Google OAuth
nblmx.sh sync                     # Syncs cookies to Python SDK
nblmx.sh check                    # Verifies both tools are ready

# 2. Create a notebook and add sources
notebooklm create "My Research"
notebooklm source add "https://example.com/article"
notebooklm source add ./report.pdf

# 3. Generate content
notebooklm generate audio "deep dive on key findings" --format deep-dive --wait
notebooklm generate infographic "executive summary" --style professional --wait
nblmx.sh generate pdf-minimalist --wait --retry 3

# 4. Download results
notebooklm download audio ./podcast.mp3
notebooklm download infographic ./infographic.png
```

---

## Workflow

```
  [1] AUTHENTICATE          [2] CREATE & SOURCE          [3] GENERATE            [4] DOWNLOAD
  +-----------------+       +-------------------+       +-----------------+     +----------------+
  | nlm login       |  -->  | create notebook   |  -->  | generate audio  | --> | download audio |
  | nblmx.sh sync   |       | add URLs/PDFs     |       | generate infog. |     | download infog |
  | nblmx.sh check  |       | add YouTube/Drive |       | generate video  |     | download video |
  +-----------------+       +-------------------+       | generate slides |     | download slides|
                                                        | generate quiz   |     | download quiz  |
                                                        +-----------------+     +----------------+
                                                              |
                                                              v
                                                     [SPACED PROTOCOL]
                                                     1 artifact at a time
                                                     wait for completion
                                                     pause 1-2 min
                                                     then next artifact
```

---

## Infographic Style Library (30 Styles)

### Category A — PDF Catalog (15 custom styles)

Designed by Karine Lago with Clarity-First preamble. All tested and validated.

| # | Style | Best For | Command |
|---|-------|----------|---------|
| 01 | Neon / Vaporwave | Tech, gaming | `nblmx.sh generate pdf-neon-vaporwave` |
| 02 | Dashboard / Statistics | Business KPIs | `nblmx.sh generate pdf-dashboard` |
| 03 | Retro / Vintage | Heritage, history | `nblmx.sh generate pdf-retro-vintage` |
| 04 | Chalkboard | Education | `nblmx.sh generate pdf-chalkboard` |
| 05 | Magazine Editorial | Thought leadership | `nblmx.sh generate pdf-editorial` |
| 06 | 3D / Isometric | Architecture, systems | `nblmx.sh generate pdf-3d-isometric` |
| 07 | Minimalist / Clean | Executive, modern | `nblmx.sh generate pdf-minimalist` |
| 08 | Collage / Cutouts | Creative briefs | `nblmx.sh generate pdf-collage` |
| 09 | Corporate / Institutional | Annual reports | `nblmx.sh generate pdf-corporate` |
| 10 | Illustrative / Cartoon | Training, youth | `nblmx.sh generate pdf-cartoon` |
| 11 | Technological / Digital | AI, cybersecurity | `nblmx.sh generate pdf-tech-digital` |
| 12 | Handwritten / Manuscript | Personal, brainstorm | `nblmx.sh generate pdf-handwritten` |
| 13 | Art Deco / Gatsby | Luxury, events | `nblmx.sh generate pdf-art-deco` |
| 14 | Timeline | Roadmaps, milestones | `nblmx.sh generate pdf-timeline` |
| 15 | Blueprint / Technical | Engineering specs | `nblmx.sh generate pdf-blueprint` |

### Category B — Built-in NotebookLM (10 presets)

Native Google styles via `--style` flag. No prompt engineering needed.

| Style | Flag | Best For |
|-------|------|----------|
| Professional | `--style professional` | Corporate, executive |
| Instructional | `--style instructional` | Education, tutorials |
| Sketch-Note | `--style sketch-note` | Brainstorming |
| Scientific | `--style scientific` | Research, academic |
| Editorial | `--style editorial` | Magazine, journalism |
| Bento Grid | `--style bento-grid` | Modular, dashboard |
| Bricks | `--style bricks` | Stacked, structural |
| Clay | `--style clay` | 3D, playful |
| Kawaii | `--style kawaii` | Cute, youth |
| Anime | `--style anime` | Creative, entertainment |

### Category C — Havas Brand (5 corporate templates)

Brand-aligned with Havas visual identity (Red #E60000, Blue #B3DAE0, Baikal font).

| Template | Purpose | Command |
|----------|---------|---------|
| H01: Corporate Overview | Stakeholder reports | `nblmx.sh generate havas-corporate` |
| H02: Data Dashboard | KPI performance | `nblmx.sh generate havas-dashboard` |
| H03: Process Flow | Workflow docs | `nblmx.sh generate havas-process` |
| H04: Intelligence Report | Market insights | `nblmx.sh generate havas-intelligence` |
| H05: Converged Ecosystem | Service offerings | `nblmx.sh generate havas-ecosystem` |

---

## Best Practices

### Generation

1. **Always use the spaced protocol** — 1 artifact at a time, 1-2 min gap between each. This prevents rate limits.
2. **Use `--wait` or `artifact wait`** — Don't guess when generation is done. Let the CLI poll.
3. **Use `--retry 3`** — Automatic exponential backoff on transient failures.
4. **Specify notebook ID with `-n`** — Especially in multi-agent workflows to avoid context conflicts.

### Infographics

5. **Custom styles > built-in** — The PDF catalog templates include Clarity-First preamble that dramatically improves readability.
6. **Match style to audience** — Corporate/Minimalist for executives, Cartoon/Chalkboard for training, Dashboard for data.
7. **One notebook per topic** — Keep sources focused. NotebookLM generates better content from cohesive source material.

### Authentication

8. **Keep sessions alive** — Use `nblmx-keepalive.bat` (pings every 15 min) or expect to re-login after ~20 min idle.
9. **After re-login, always sync** — `nlm login` then `nblmx.sh sync` ensures both tools share the same session.

---

## FAQ

**Q: How many infographics can I generate per day?**
A: Safely 5-6 with the spaced protocol (1-2 min gap between each). We've tested 9 in a single session across 3 agents with zero rate limits. Batch generation (many at once) triggers a 24h+ block.

**Q: Can multiple agents generate simultaneously?**
A: Yes. Use explicit notebook IDs (`-n`) instead of `notebooklm use`. We've proven 3-agent parallel orchestration (Magneto + 2 Codex) via AOP dispatch.

**Q: What if I get a rate limit error?**
A: Switch to non-infographic tasks immediately. Audio, video, slides, reports, quizzes work independently of infographic limits. Wait 5+ minutes before retrying infographics.

**Q: Which generation types are most reliable?**
A: Mind maps, reports, and data tables are instant/near-instant and never fail. Audio and video take longer (5-20 min) but are reliable. Infographics and quizzes are the most rate-limited.

**Q: Do I need the MCP server AND the CLI?**
A: For most use cases, the CLI (`notebooklm` + `nblmx.sh`) is sufficient. The MCP server (35 tools) provides native integration for Claude Code, Gemini, and Codex — useful for automated workflows and chat-based generation.

**Q: How do I add my own custom style?**
A: Create a `.prompt` file in `_skills/notebooklmx/templates/` with your full prompt text (include the Clarity-First preamble from existing templates as a starting point). Then use `nblmx.sh generate your-template-name`.

---

## Two Tools, One Skill

| Tool | Role | Installed As |
|------|------|--------------|
| **notebooklm-py** (v0.3.4) | Python SDK + CLI for content generation, download, and management | `notebooklm` command in venv |
| **notebooklm-mcp-cli** (v0.5.4) | 35 MCP tools for native IDE/agent integration | `nlm` command in venv |
| **nblmx.sh** | Wrapper unifying both + template library + cookie sync | `_skills/notebooklmx/nblmx.sh` |

---

## File Structure

```
_skills/notebooklmx/
  .venv/                    # Python virtual environment
  nblmx.sh                  # Unified wrapper script
  SKILL.md                  # Full operational protocol
  sync-cookies.py           # Auth cookie converter (nlm -> notebooklm-py)
  templates/                # 20 .prompt files (15 PDF + 5 Havas)
  test-output/              # Generated test artifacts
    phase03-batch2/         # Styles 06-09, H01-H02
    phase03-batch3/         # Styles 10-15, H03-H05
```

---

## Design Principles

1. **On-Demand Only** — Generate ONLY what the user explicitly requests. Never batch. Never add extras.
2. **Clarity-First** — Max 6-8 elements per section, 15% whitespace, readable text, logical flow.
3. **Text Quality Guards** — No squished/overlapping text. Generous spacing. Consistent hierarchy.
4. **Responsible Usage** — Spaced protocol for all artifacts. 1-2 min gap. No rushing.

---

## Links

- [SKILL.md](SKILL.md) — Full operational protocol with all commands, flags, and constraints
- [Claude Intelligence Hub](https://github.com/mrjimmyny/claude-intelligence-hub) — Parent repository
- [notebooklm-py](https://github.com/teng-lin/notebooklm-py) — Python SDK
- [notebooklm-mcp-cli](https://github.com/nicholasgriffintn/notebooklm-mcp-cli) — MCP CLI

---

*Part of the [Claude Intelligence Hub](https://github.com/mrjimmyny/claude-intelligence-hub) — Skill #20*
