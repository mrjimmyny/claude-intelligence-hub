---
name: bi-datavizx
version: 1.0.0
description: Backend BI execution toolkit for Power BI ecosystem. Agent-neutral command surface covering data ingestion (BigQuery + SharePoint), desktop automation (pbi-cli + pbir-cli dual-backend), Fabric/Premium scanning, report formatting, DAX formatting/linting, and governance wires.
command: /bdvx
aliases: [/bi-datavizx]
category: BI & Data
status: production
dependencies:
  - pbi-cli (MinaSaad1/pbi-cli v3.10.10)
  - pbir-cli (maxanatsko/pbir.tools v0.9.7)
  - pbi-fixer v2 (Fabric BPA/IBCS/Vertipaq)
---

# bi-datavizx

**Version:** 1.0.0
**Status:** Production (v1 — Phases 1-6 CLOSED, 1280 tests PASS, SC1-SC12 ALL MET)
**Published:** 2026-04-12
**Maintained by:** Magneto (Claude Code)
**Project:** bi-datavizx
**Complement to:** [[bi-designerx]] (FRONTEND design via Paper.design + CEM pipeline)

---

## 1. Overview

bi-datavizx (bdvx) is the **backend** execution layer for the BI data-viz workflow on Jimmy's Power BI ecosystem. It provides an agent-neutral command surface for:

- **Data Ingestion** — BigQuery + SharePoint imports via Power Query/M
- **Desktop Automation** — pbi-cli (F1-F10) + pbir-cli (F11-F16) dual-backend for model CRUD, DAX, report editing, visual management
- **Fabric/Premium** — pbi-fixer v2 wrappers for BPA, IBCS, Vertipaq scan, perspectives, incremental refresh
- **Report Operations** — bi-designerx handoff, template engine, visual formatting, page management
- **DAX Formatting/Linting** — 6 built-in rules (DAX001-DAX006), configurable profiles
- **Model Operations** — Copilot polish, translations
- **Governance Wires** — findings, AOP dispatch, session-doc, CEM protection, locality rule, TB-01

**Architecture:** 10-module thin orchestration + adapter skill. JSON-first I/O (`bdvx-response/1` envelope). Agent-neutral (Claude Code, Codex, Gemini — zero branching).

---

## 2. 10-Module Architecture

| # | Module | Responsibility |
|---|---|---|
| 1 | `core-contract` | Agent-neutral CLI, JSON I/O, audit log, credential manager, config |
| 2 | `project-intel` | PBIP discovery, POWER_BI_INDEX.md generator, structural queries |
| 3 | `desktop-adapter` | pbi-cli + pbir-cli dual-backend wrap (F1-F16) |
| 4 | `fabric-adapter` | pbi-fixer v2 wrappers (BPA, IBCS, scan, Vertipaq, perspectives, incremental refresh) |
| 5 | `data-ingest` | BigQuery + SharePoint + Power Query/M + credential bridge |
| 6 | `report-ops` | Report formatting, handoff bridge, template engine, visual formatter |
| 7 | `model-ops` | DAX formatter/linter, Copilot polish, translations |
| 8 | `governance` | Approval workflows, destructive-op gates (R-43) |
| 9 | `docs` | Architecture exporter, model dictionary, change reporter, diagrams |
| 10 | `integration` | findings-wire, AOP dispatch, session-doc-wire, CEM protection, locality rule, TB-01 |

---

## 3. Key Design Rules (D1-D13)

| # | Rule |
|---|---|
| D1 | JSON-first I/O (`bdvx-response/1` envelope) |
| D4 | Context7 MCP for DAX validation (soft warn mode) |
| D5 | Agent-neutral — zero agent-specific branching |
| D6 | Structured measure request template |
| D9 | No default global mutation |
| D10 | Credential safety — never return secret values |
| D13 | BI Destructive Operation Safety Gate (R-43) |

---

## 4. Installation

```bash
cd C:/ai/_skills/bi-datavizx
pip install -e ".[dev]"
```

Windows credential commands require `pywin32>=306`.

---

## 5. Usage

All commands emit JSON to stdout. Use `--pretty` for human-readable output.

```bash
# Core
bdvx --json core version

# Credential management
bdvx credential set bdvx/myproject/bigquery/service-account --value "..."
bdvx credential get bdvx/myproject/bigquery/service-account
bdvx credential list

# Project intelligence
bdvx project discover --root C:/path/to/projects
bdvx project index-build --project-root C:/path/to/project
bdvx project query --project-root C:/path/to/project --kind measures
```

---

## 6. Governance

- **Contract:** `obsidian/CIH/projects/skills/bi-datavizx/01-manifesto-contract/bdvx-contract-v1.0.md` (v1.6)
- **SDD:** `obsidian/CIH/projects/skills/bi-datavizx/03-spec/bdvx-sdd-v1.0.md` (v6.0)
- **G-01..G-10 governance rules** — no improvisation, no deduction, Contract+SDD+Plan+Tests+Audit required per phase
- **TB-01** — Jimmy's tie-breaker principle for arbitration
- **R-43** — BI destructive operations require Jimmy's explicit written per-target authorization

---

## 7. Deferred Scope (Post-v1)

| Scope | Status |
|---|---|
| Phase 7 — Deployment Governance (Q5) | DEFER — Jimmy must elevate |
| DAX Authoring Standards (Contract v1.6 Section 14.1) | DEFER — dedicated future phase (9 items: DAX007-010 lint rules + SKILL.md operational directives) |
| pbi-claude-skills migration | Post-v1 gate |

---

## 8. Test Suite

```bash
cd C:/ai/_skills/bi-datavizx
pytest tests/ --no-cov -q    # 1280 passed, 49 skipped
```

---

## Wikilinks

[[bi-designerx]] | [[pbi-claude-skills]] | [[agent-orchestration-protocol]] | [[jimmy-core-preferences]]
