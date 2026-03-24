# bi-designerx

> End-to-end BI dashboard design workflow for non-designers.

## What It Does

bi-designerx generates professional BI dashboard backgrounds in Paper.design using AI — from zero (just your references and descriptions) to a locked, production-ready design asset. No design skills required.

## Key Features

- **P0 Kickstart** — Give references (screenshots, links, descriptions), get 2-3 design concepts rendered in Paper.design
- **CEM System** — Canvas Element Map: structured JSON registry of every visual element, with automated Skin baselines and DRAFT-OWNER documents
- **7-Phase Pipeline** — P0 (Kickstart) → P1 (Pre-Paper) → P2 (Design) → P3 (Naming) → P4 (JSON) → P5 (Markdown) → P6 (Lock)
- **Multi-Agent Protocol** — Multiple agents can work on different design versions simultaneously with artboard-level write protection
- **CEM Package** — 7 artifacts per locked version: JSON, Skin, DRAFT, Rationale, Screenshot, PDF, HTML Package
- **Front-End Agnostic** — Works with Power BI, Tableau, Looker, or any platform supporting background images

## Quick Start

```
/bidx
```

Then describe what you need: "I need an HR dashboard with headcount, turnover, and diversity cards."

## Prerequisites

- Paper.design account (Pro recommended)
- Paper MCP running at `http://127.0.0.1:29979/mcp`
- `frontend-design` plugin (for P0 Kickstart)

## Architecture

Two-layer model:
1. **Design layer:** AI-generated PNG/SVG background (Paper.design)
2. **Data layer:** BI-native elements (charts, KPIs, slicers) on top

## Documentation

- **SKILL.md** — Full operational reference (this directory)
- **CEM Spec** — `obsidian/CIH/projects/skills/bi-designerx/03-spec/bidx-cem-design-spec-v1.0.md`
- **Q2 Protocol Spec** — `obsidian/CIH/projects/skills/bi-designerx/03-spec/bidx-multi-agent-paper-protocol-spec-v1.0.md`
- **Decision Log** — `obsidian/CIH/projects/skills/bi-designerx/decisoes.md` (20 decisions)

## Status

Phase 00 (Pre-Project/Testing) validated. CEM system production-ready (v2, v3, v4 locked). Multi-Agent Protocol implemented and tested (7/7). P0 Kickstart designed (Decision 20), implementation pending validation.
