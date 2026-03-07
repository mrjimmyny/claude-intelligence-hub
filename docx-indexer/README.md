# docx-indexer (v1.0.0)

Global document indexing system for the Claude Intelligence Hub.

## Purpose

`docx-indexer` maintains a persistent, append-only JSON index of all files and directories under a configured workspace root. It enables any Elite League agent to locate files instantly without repeated path explanations.

## Slash Command

- Primary: `/docx-indexer`
- Alias: `/dxi`

## Core Operations

| Operation | Command |
|-----------|---------|
| Full scan | `python scripts/scan.py --config config/dxi-config.json` |
| Dry-run | `python scripts/scan.py --config config/dxi-config.json --dry-run` |
| Validate | `python scripts/validate.py --index-path index` |
| Export MD | `python scripts/export-md.py --index-path index` |
| Run tests | `python -m pytest tests/ -v` |

All commands run from `C:\ai\_skills\docx-indexer\`.

## Critical Rules

1. APPEND-ONLY — index never rebuilt/reset/truncated
2. UUID permanence — once assigned, never changes
3. Soft delete only — entries marked deleted, never removed
4. Atomic write — temp → validate → rename
5. Backup before write — `.bak` always created first
6. Human override required for rebuild/reset

## Technical Workspace

Scripts, config, index, and tests live at: `C:\ai\_skills\docx-indexer\`

## Documentation Workspace

Contracts, plans, reviews, and audits live at: `C:\ai\obsidian\CIH\projects\skills\docx-indexer\`

## Current State

- Phase 1 (Core Index): **GO** — operationally validated and audited
- Phase 2 (Knowledge Enrichment): not started, requires explicit Jimmy authorization
- Index: 1,709 entries (1,068 files + 641 directories)
- Tests: 47/47 PASS

## Reference

- Full operational guide: see `SKILL.md`
- Audit report: `04-tests/docx-indexer-phase1-operational-validation-audit-magneto-v1.0.md`
- Implementation testament: `05-final/docx-indexer-phase1-implementation-testament-xavier-v1.0.md`
- Contract: `01-manifesto-contract/docx-indexer-contract-jimmy-2026-03-05-v1.0.md`
