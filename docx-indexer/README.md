# docx-indexer (v1.3.0)

> Your workspace's memory - a global document index that knows where every file lives, stores semantic enrichment, and now has a controlled Voyage-backed semantic search baseline.

---

## What Is This?

The **docx-indexer** scans all files and folders under a root directory (for example `C:\ai`) and builds a persistent catalog with:

- A unique ID (UUID) for every file and folder - permanent, never changes
- A SHA256 fingerprint of each file's content - detects changes instantly
- Structural telemetry for folders - child counts and recursive size
- An Obsidian-friendly markdown view - browse the index visually
- Semantic enrichment - `summary`, `keywords`, entity/linking layers, and a Voyage-backed semantic search baseline

Think of it as a phone book for your files plus a semantic enrichment layer and a controlled semantic retrieval baseline for the textual corpus you already trust.

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

Semantic search baseline is available through the skill/runtime layer after `Stage 2.5`, but it is not exposed as a simple standalone CLI command yet.

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

> PT: "faz uma busca semantica no indice por documentos sobre embeddings"
> EN: "run a semantic search in the index for documents about embeddings"

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
Yes, in a controlled baseline form. The system still works primarily as a structural catalog, but Phase 2 now includes summaries, keywords, entities/linking layers, and a `Stage 2.5` vector embedding + semantic search baseline validated with `Voyage`. It is not yet a local sparse/hybrid retrieval system.

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
|   |-- enrich.py                # Enrichment pipeline
|   |-- embedding_client.py      # Stage 2.5 embedding provider abstraction
|   |-- search.py                # Stage 2.5 semantic search baseline
|   |-- smoke_test_voyage.py     # Controlled real-provider validation
|   |-- validate.py              # Index validator
|   `-- export-md.py             # Markdown exporter
|-- index\
|   |-- docx-index.json          # Primary index (append-only)
|   |-- docx-index.json.bak      # Automatic backup
|   `-- docx-index.md            # Obsidian markdown view
|   `-- embeddings.db            # Stage 2.5 vector storage
|-- test-results\                # Evidence artifacts
`-- tests\                       # 372 tests (all passing)
```

---

## Current Stats

| Metric | Value |
|--------|-------|
| Total dict entries | 3,987 |
| Active entries | 3,970 |
| Files | 3,044 |
| Directories | 926 |
| Deleted entries | 17 |
| Enriched files | 955 |
| Tests | 372/372 PASS |
| Current decision | Stage 2.5 closed with GO; Voyage semantic baseline validated |

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

- Local sparse/hybrid retrieval (`Stage 3.1`)
- Chunking and re-ranking
- Cross-machine sync/merge in production flow
- Real-time file watching
- Multi-provider production routing beyond the validated Voyage baseline

---

## Reference

| Document | Location |
|----------|----------|
| Full operational guide | `SKILL.md` (this skill directory) |
| Contract | `01-manifesto-contract/docx-indexer-contract-jimmy-2026-03-05-v1.0.md` |
| Stage 2.5 Round 3 report | `05-final/docx-indexer-phase2-stage2.5-round3-voyage-smoke-latency-close-report-xavier-v1.0.md` |
| Stage 2.5 final audit gate | `05-final/docx-indexer-phase2-stage2.5-round3-audit-gate-emma-v1.0.md` |
| Stage 2.5 post-close reinforcement | `05-final/docx-indexer-phase2-stage2.5-postclose-reinforcement-report-magneto-v1.0.md` |
| Usage guide | `06-operationalization/docx-indexer-global-skill-usage-guide-brain-v1.0.md` |
| Operational handoff | `06-operationalization/docx-indexer-global-skill-handoff-brain-v1.0.md` |
