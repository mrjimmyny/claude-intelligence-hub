# docx-indexer (v1.2.0)

> Your workspace's memory - a global document index that knows where every file lives and now stores first-layer enrichment for eligible textual files.

---

## What Is This?

The **docx-indexer** scans all files and folders under a root directory (for example `C:\ai`) and builds a persistent catalog with:

- A unique ID (UUID) for every file and folder - permanent, never changes
- A SHA256 fingerprint of each file's content - detects changes instantly
- Structural telemetry for folders - child counts and recursive size
- An Obsidian-friendly markdown view - browse the index visually
- Manual-first enrichment - `summary` and `keywords` for eligible textual files

Think of it as a phone book for your files plus a first semantic layer for the textual corpus you already trust.

---

## Quick Start

| Command | Alias |
|---------|-------|
| `/docx-indexer` | `/dxi` |

**Four things you can do right now:**

```bash
# 1. Preview what changed (safe, no writes)
python scripts/scan.py --config config/dxi-config.json --dry-run

# 2. Update the index for real
python scripts/scan.py --config config/dxi-config.json

# 3. Verify everything is consistent
python scripts/validate.py --index-path index

# 4. Enrich eligible textual files with summary + keywords
python scripts/enrich.py --stage all
```

All commands run from `C:\ai\_skills\docx-indexer\`.

---

## How to Interact - Real Examples

### Finding Files

> PT: "consulta o indice de documentos e acha o arquivo `contract-jimmy`"
> EN: "check the document index and find the file `contract-jimmy`"

> PT: "onde esta o arquivo de audit report do docx-indexer?"
> EN: "where is the docx-indexer audit report file?"

> PT: "lista todos os arquivos .py no indice"
> EN: "list all .py files in the index"

### Getting Information

> PT: "quantos arquivos temos indexados?"
> EN: "how many files do we have indexed?"

> PT: "qual o tamanho da pasta obsidian/CIH?"
> EN: "how big is the obsidian/CIH folder?"

> PT: "mostra o summary do arquivo `contract-jimmy`"
> EN: "show the summary for file `contract-jimmy`"

> PT: "quais keywords o indice tem para esse arquivo?"
> EN: "what keywords does the index have for this file?"

### Updating the Index

> PT: "roda um dry-run do docx-indexer pra ver o que mudou"
> EN: "run a dry-run of the docx-indexer to see what changed"

> PT: "atualiza o indice de documentos"
> EN: "update the document index"

> PT: "valida o indice do docx-indexer"
> EN: "validate the docx-indexer index"

> PT: "enriquece o indice com summary e keywords"
> EN: "enrich the index with summary and keywords"

---

## Q&A - Frequently Asked Questions

### Do I need to say "docx-indexer" every time?
No. You can say things like "consulta o indice de documentos" or "check the document index" and the agent should route to docx-indexer automatically.

### Does the index search inside file contents?
Not as full semantic search. The index still works primarily as a structural catalog, but `Stage 2.2 v1` now stores `summary` and `keywords` for eligible textual files. That gives you a first semantic layer without turning the system into a full content search engine yet.

### What happens if I delete a file?
The index marks it as deleted with a timestamp - it never removes the entry. This preserves the history of what existed.

### Can the index break or get corrupted?
It is designed to be safe: atomic writes, automatic backup before changes, append-only rules, and explicit validation.

### Does the scan run automatically?
No. You need to ask for it explicitly. There is no background watcher.

### Can any agent use this skill?
Yes. It is a Global Skill available to the Elite League agents via `/docx-indexer` or `/dxi`.

### What about files like `pdf`, `docx`, `xlsx`, `pbip`, or `pbix`?
Those formats still require extractor support before they can be enriched. The Stage 2.2 v1 pipeline classifies them correctly, but does not pretend they are already covered.

---

## Architecture Overview

```text
C:\ai\_skills\docx-indexer\
|-- config\
|   `-- dxi-config.json          # Machine-specific configuration
|-- scripts\
|   |-- scan.py                  # Core scanner
|   |-- common.py                # Shared helpers
|   |-- content_reader.py        # Text eligibility + extraction
|   |-- enrich.py                # Stage 2.2 v1 enrichment
|   |-- validate.py              # Index validator
|   `-- export-md.py             # Markdown exporter
|-- index\
|   |-- docx-index.json          # Primary index (append-only)
|   |-- docx-index.json.bak      # Automatic backup
|   `-- docx-index.md            # Obsidian markdown view
|-- test-results\                # Evidence artifacts
`-- tests\                       # 135 tests (all passing)
```

---

## Current Stats

| Metric | Value |
|--------|-------|
| Total dict entries | 1,784 |
| Active entries | 1,770 |
| Files | 1,122 |
| Directories | 648 |
| Deleted entries | 14 |
| Enriched files | 937 |
| Tests | 135/135 PASS |
| Current decision | Stage 2.2 v1 stable with minor residual risks |

---

## Key Paths

| Resource | Path |
|----------|------|
| Technical workspace | `C:\ai\_skills\docx-indexer\` |
| Documentation | `C:\ai\obsidian\CIH\projects\skills\docx-indexer\` |
| CIH skill directory | `C:\ai\claude-intelligence-hub\docx-indexer\` |
| Index (JSON) | `C:\ai\_skills\docx-indexer\index\docx-index.json` |
| Index (Markdown) | `C:\ai\_skills\docx-indexer\index\docx-index.md` |
| Configuration | `C:\ai\_skills\docx-indexer\config\dxi-config.json` |

---

## What It Does NOT Do

- Full semantic search or embeddings
- API-native enrichment (`Stage 2.2 v2`)
- Cross-machine sync/merge in production flow
- Real-time file watching
- Entity extraction or auto-tagging (`Stage 2.3+`)

---

## Reference

| Document | Location |
|----------|----------|
| Full operational guide | `SKILL.md` (this skill directory) |
| Contract | `01-manifesto-contract/docx-indexer-contract-jimmy-2026-03-05-v1.0.md` |
| Stage 2.2 implementation report | `05-final/docx-indexer-phase2-stage2.2-v1-implementation-report-xavier-v1.0.md` |
| Stage 2.2 audit report | `05-final/docx-indexer-phase2-stage2.2-v1-audit-report-xavier-v1.0.md` |
| Usage guide | `06-operationalization/docx-indexer-global-skill-usage-guide-brain-v1.0.md` |
| Operational handoff | `06-operationalization/docx-indexer-global-skill-handoff-brain-v1.0.md` |
