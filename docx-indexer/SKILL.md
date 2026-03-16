---
name: docx-indexer
description: Global document indexing system with append-only JSON index, UUID identity, SHA256 hashing, structural telemetry, semantic enrichment, and a Stage 2.5 Voyage-backed semantic search baseline. Agents use this skill to scan, validate, enrich, and query a persistent index of all files under a configured workspace root.
command: /docx-indexer
aliases: [/dxi]
---

# docx-indexer

**Version:** 1.4.0

## Objective

Provide a global, machine-level document index that allows any Elite League agent to locate files instantly without repeated path explanations. The index is append-only, UUID-identified, integrity-protected, and now supports semantic enrichment plus a validated `Stage 2.5` Voyage-backed semantic search baseline.

## Natural Language Triggers

When the user says any of these (in English or Portuguese), use the docx-indexer:

| User says | Action |
|-----------|--------|
| "find file X in the index" / "acha o arquivo X no indice" | Read `docx-index.json`, search by file_name or path |
| "scan the workspace" / "atualiza o indice" | Run `scan.py` (full scan) |
| "dry-run the index" / "roda um dry-run do indexer" | Run `scan.py --dry-run` |
| "validate the index" / "valida o indice" | Run `validate.py` |
| "how many files do we have?" / "quantos arquivos temos?" | Read `docx-index.json` metadata counters |
| "where is file X?" / "onde esta o arquivo X?" | Search index by file_name |
| "list all .md files" / "lista todos os arquivos .md" | Filter index entries by file_type |
| "check the document index" / "consulta o indice de documentos" | Read and query `docx-index.json` |
| "what changed since last scan?" / "o que mudou desde o ultimo scan?" | Run `scan.py --dry-run` and report diff |
| "how big is folder X?" / "qual o tamanho da pasta X?" | Look up directory telemetry in index |
| "show the summary of file X" / "mostra o summary do arquivo X" | Read `docx-index.json` and return stored `summary` |
| "what keywords do we have for file X?" / "quais keywords temos para o arquivo X?" | Read `docx-index.json` and return stored `keywords` |
| "enrich the index" / "enriquece o indice" | Run `enrich.py` for Stage 2.2 v1 |
| "semantic search in the index" / "busca semantica no indice" | Use the Stage 2.5 semantic layer and provider-compatible search baseline |

## When to Use

- You need to find files or directories in the workspace
- You need to verify what exists under `C:\ai`
- You need to update the index after significant file changes
- You need to enrich eligible textual entries with semantic metadata
- You need to validate index integrity
- You need the Obsidian-friendly markdown view of the index
- You need to inspect existing enrichment metadata (`summary`, `keywords`, entities, links)
- You need controlled semantic search over the validated `Voyage` shard baseline

## Invocation Judgment Rule

Mentioning `docx-indexer` is a strong routing signal, but not an unconditional command to use it blindly.

The agent must decide whether the real task benefits from index-driven discovery or retrieval.

### Mandatory

- target files are not already fixed
- workspace discovery is needed before action
- the request is to find, list, validate, enrich, or semantically search documents
- summaries, keywords, or semantic retrieval from the indexed corpus are needed
- significant workspace changes make index freshness relevant

### Optional

- the user mentioned `docx-indexer`, but the file set is mostly known already
- the index would be useful as a quick sanity check before editing
- the task mixes discovery with direct file edits

### Skip

- the target files are already explicit and closed
- the task is direct editing, patching, formatting, or bulk updates on known files
- using the index would add overhead without increasing correctness, coverage, or safety

### Required behavior

- If used: say explicitly that `docx-indexer` is being used and why.
- If skipped: say explicitly that it was considered and why it was not needed.

## When NOT to Use

- Local sparse / hybrid retrieval (`Stage 3.1`)
- Chunking or re-ranking
- Cross-machine merge operations (deferred)
- Real-time file watching (not supported)

## Technical Workspace

All scripts, configuration, and index files live at:

```text
C:\ai\_skills\docx-indexer\
|-- config\
|   |-- dxi-config.json          # Machine-specific configuration
|   `-- known-entities.json      # Known entity lists for extraction
|-- scripts\
|   |-- __init__.py              # Package init
|   |-- scan.py                  # Core scanner + diff engine + telemetry
|   |-- common.py                # Shared constants + atomic write + markdown export
|   |-- content_reader.py        # Text eligibility and content extraction
|   |-- enrich.py                # Semantic enrichment pipeline
|   |-- linker.py                # Semantic linker + link registry
|   |-- embedding_client.py      # Stage 2.5 provider abstraction
|   |-- search.py                # Stage 2.5 semantic search baseline (with CLI)
|   |-- smoke_test_voyage.py     # Controlled real-provider validation
|   |-- validate.py              # Index integrity validator
|   `-- export-md.py             # Markdown exporter
|-- index\
|   |-- docx-index.json          # Primary index (append-only)
|   |-- docx-index.json.bak      # Atomic backup
|   |-- docx-index.md            # Obsidian wikilink view
|   |-- entity-registry.json     # Entity registry (generated)
|   |-- link-registry.json       # Link registry (generated)
|   `-- embeddings.db            # Stage 2.5 vector storage
|-- test-results\                # Stage evidence artifacts
`-- tests\                       # 372 tests (all passing)
```

## Commands

### Full Scan (updates index)

```bash
python C:\ai\_skills\docx-indexer\scripts\scan.py --config C:\ai\_skills\docx-indexer\config\dxi-config.json
```

### Dry-Run (preview only, no writes)

```bash
python C:\ai\_skills\docx-indexer\scripts\scan.py --config C:\ai\_skills\docx-indexer\config\dxi-config.json --dry-run
```

### Validate Index Integrity

```bash
python C:\ai\_skills\docx-indexer\scripts\validate.py --index-path C:\ai\_skills\docx-indexer\index
```

### Export Markdown View

```bash
python C:\ai\_skills\docx-indexer\scripts\export-md.py --index-path C:\ai\_skills\docx-indexer\index
```

### Run Tests

```bash
cd C:\ai\_skills\docx-indexer && python -m pytest tests/ -v
```

372 tests covering scan, validation, enrichment, provider topology, and semantic search behavior. All must pass.

### Run Manual-First Enrichment

```bash
python C:\ai\_skills\docx-indexer\scripts\enrich.py --stage all
```

Enriches eligible textual files using the existing incremental `new/changed` logic and atomic index persistence.

## MASTER CRITICAL RULES (Non-Negotiable)

1. **APPEND-ONLY** - The index is NEVER rebuilt, reset, or truncated in normal operation
2. **UUID Permanence** - Once assigned to a path, a UUID NEVER changes
3. **Soft Delete Only** - Entries are marked `status: deleted` with `deleted_at` timestamp, NEVER removed
4. **Atomic Write** - temp file -> validate integrity -> rename to final
5. **Backup Before Write** - `.bak` is always created before any modification
6. **Human Override Required** - Only a human can authorize rebuild/reset of the index
7. **Directories: content_hash = null** - Directories never have content hashes
8. **Exclusions Are Technical Only** - Only `.git`, `node_modules`, `__pycache__`, `.venv`, `.claude`, etc.
9. **Provider-Compatible Semantic Search Only** - Vector comparisons must remain provider/model compatible; no cross-provider mixing in one ranking space

## Operational Flow

```text
Agent or Jimmy triggers scan
    -> Load config (dxi-config.json)
    -> Load existing index
    -> Backup index (.bak)
    -> Recursive filesystem scan
    -> Compute diff vs index
    -> Calculate structural telemetry (bottom-up)
    -> Update counters
    -> [if --dry-run: STOP here, print report]
    -> Write index (atomic)
    -> Export markdown
    -> Git sync
    -> Print scan report
```

Manual-first enrichment flow:

```text
Agent or Jimmy triggers enrichment
    -> Load existing index
    -> Identify eligible textual files
    -> Apply incremental new/changed filter
    -> Generate heuristic `summary`
    -> Generate heuristic `keywords`
    -> Persist enrichment fields atomically
    -> Validate index
    -> Save evidence artifacts
```

## Index Data Model

Each entry is keyed by absolute path and contains:

**Files:** uuid, file_name, machine_name, exact_path, entry_type, file_type, content_hash (SHA256), size_bytes, last_modified, indexed_at, status, tags, category, and optional enrichment fields such as `summary`, `keywords`, `enriched_at`, `enrichment_version`, `content_hash_at_enrichment`

**Directories:** Same as files plus direct_children_count, recursive_children_count, recursive_size_bytes. content_hash and size_bytes are always null.

## Configuration

`dxi-config.json` contains:

```json
{
  "machine_name": "BR-SPO-DCFC264",
  "root_path": "C:\\ai",
  "index_path": "C:\\ai\\_skills\\docx-indexer\\index",
  "max_file_size_mb": 500,
  "exclude_patterns": [".git", "node_modules", "__pycache__", "*.pyc", ".venv", "*.tmp", "*.swp"],
  "exclude_dirs": [".git", "node_modules", "__pycache__", ".venv", ".claude"]
}
```

## Known Limitations

| ID | Limitation |
|----|-----------|
| LK-01 | ~~No move detection~~ — resolved in Stage 2.4: UUID-based move tracking via moved_from/moved_to |
| LK-02 | Hash is partial for files > 500MB (first 1MB + last 1MB) |
| LK-03 | No local sparse/hybrid retrieval yet - semantic baseline exists, but Stage 3.1 remains future work |
| LK-04 | Single-machine - cross-machine merge requires manual merge.py (deferred) |
| LK-05 | No watch mode - batch scan only |
| LK-06 | ~~Telemetry O(D*E)~~ — resolved in W1 (CF-01): now O(N) single-pass |
| LK-07 | Full chunking/reranking stack not implemented - current semantic search is controlled baseline only |
| LK-08 | Some formats require future extractors (`pdf`, `docx`, `xlsx`, `pbip`, `pbix`) before deeper enrichment is possible |

## Deferred Items (Non-Blocking)

| Item | Classification |
|------|---------------|
| `scripts/merge.py` | P2-Complementar |
| `config/dxi-config.schema.json` | P2-Complementar |
| `tests/integration/test_sync.py` | P2-Complementar |
| `Stage 3.1` local sparse / hybrid retrieval | Future |
| chunking + re-ranking | Future |

## Audit Status

| Field | Value |
|-------|-------|
| Phase 1 Decision | **GO** |
| Stage 2.5 Decision | **GO - formally closed** |
| Audited by | Magneto (Claude Opus 4.6) + Xavier (Claude Sonnet 4.6) |
| Approved by | Emma (Codex) + Jimmy |
| Date | 2026-03-14 |
| Tests | 372/372 PASS |
| Critical Rules | 9/9 PASS |
| Scan Specs | 15/15 PASS |
| First Real Scan | 1,709 entries in 4.65s |
| Latest Indexed State | 3,987 dict entries / 3,970 active entries / 17 deleted - 2026-03-14 |
| Latest Enrichment State | 955 files with `summary` |
| Latest Semantic Validation | `Voyage` smoke tests PASS, `1024` dims, cost `$0.00` |

## Wikilinks

[[Skill]] | [[docx-indexer]] | [[claude-intelligence-hub]] | [[context-guardian]] | [[repo-auditor]]
