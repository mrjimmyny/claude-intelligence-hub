---
name: docx-indexer
description: Global document indexing system with append-only JSON index, UUID identity, SHA256 hashing, structural telemetry, and Stage 2.2 v1 manual-first enrichment. Agents use this skill to scan, validate, enrich, and query a persistent index of all files under a configured workspace root.
command: /docx-indexer
aliases: [/dxi]
---

# docx-indexer

**Version:** 1.2.0

## Objective

Provide a global, machine-level document index that allows any Elite League agent to locate files instantly without repeated path explanations. The index is append-only, UUID-identified, integrity-protected, and now supports Stage 2.2 v1 manual-first enrichment with `summary` and `keywords` for eligible textual files.

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

## When to Use

- You need to find files or directories in the workspace
- You need to verify what exists under `C:\ai`
- You need to update the index after significant file changes
- You need to enrich eligible textual entries with `summary` and `keywords`
- You need to validate index integrity
- You need the Obsidian-friendly markdown view of the index
- You need to inspect existing enrichment metadata (`summary`, `keywords`, `enrichment_version`)

## When NOT to Use

- Full semantic search across file contents
- LLM/API-native enrichment (`Stage 2.2 v2` not implemented)
- Entity extraction, semantic linking, embeddings, or auto-tagging (`Stage 2.3+` not implemented)
- Cross-machine merge operations (deferred)
- Real-time file watching (not supported)

## Technical Workspace

All scripts, configuration, and index files live at:

```text
C:\ai\_skills\docx-indexer\
|-- config\dxi-config.json       # Machine-specific configuration
|-- scripts\
|   |-- scan.py                  # Core scanner
|   |-- common.py                # Shared Stage 2 helpers
|   |-- content_reader.py        # Text eligibility and content extraction
|   |-- enrich.py                # Stage 2.2 v1 manual-first enrichment
|   |-- validate.py              # Index integrity validator
|   `-- export-md.py             # Markdown exporter
|-- index\
|   |-- docx-index.json          # Primary index (append-only)
|   |-- docx-index.json.bak      # Atomic backup
|   `-- docx-index.md            # Obsidian markdown view
|-- test-results\                # Stage evidence artifacts
`-- tests\                       # 135 tests (all passing)
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

135 tests covering scan, validation, content reading, enrichment, and incremental behavior. All must pass.

### Run Manual-First Enrichment

```bash
python C:\ai\_skills\docx-indexer\scripts\enrich.py --stage all
```

Enriches eligible textual files with `summary` and `keywords`, using the existing incremental `new/changed` logic and atomic index persistence.

## MASTER CRITICAL RULES (Non-Negotiable)

1. **APPEND-ONLY** - The index is NEVER rebuilt, reset, or truncated in normal operation
2. **UUID Permanence** - Once assigned to a path, a UUID NEVER changes
3. **Soft Delete Only** - Entries are marked `status: deleted` with `deleted_at` timestamp, NEVER removed
4. **Atomic Write** - temp file -> validate integrity -> rename to final
5. **Backup Before Write** - `.bak` is always created before any modification
6. **Human Override Required** - Only a human can authorize rebuild/reset of the index
7. **Directories: content_hash = null** - Directories never have content hashes
8. **Exclusions Are Technical Only** - Only `.git`, `node_modules`, `__pycache__`, `.venv`, `.claude`, etc.
9. **Stage 2.2 v1 Only** - Manual-first `summary` and `keywords` are allowed for eligible textual files; API-native enrichment, embeddings, entities, semantic linking, and auto-tagging remain out of scope

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
| LK-01 | No move detection - moved file = soft delete + new entry |
| LK-02 | Hash is partial for files > 500MB (first 1MB + last 1MB) |
| LK-03 | No full semantic search - enriched metadata exists, but retrieval is still index-first/manual-first |
| LK-04 | Single-machine - cross-machine merge requires manual merge.py (deferred) |
| LK-05 | No watch mode - batch scan only |
| LK-06 | Telemetry calculation is O(D*E) - manageable at current scale |
| LK-07 | Tags and category remain manual - Stage 2.3 auto-classification/entity extraction not implemented |
| LK-08 | Some formats require future extractors (`pdf`, `docx`, `xlsx`, `pbip`, `pbix`) before enrichment is possible |

## Deferred Items (Non-Blocking)

| Item | Classification |
|------|---------------|
| `scripts/merge.py` | P2-Complementar |
| `config/dxi-config.schema.json` | P2-Complementar |
| `tests/integration/test_sync.py` | P2-Complementar |
| `Stage 2.2 v2` API-native enrichment | Future |
| `Stage 2.3` entity extraction / auto-tagging | Future |

## Audit Status

| Field | Value |
|-------|-------|
| Phase 1 Decision | **GO** |
| Stage 2.2 v1 Decision | **Stable with minor residual risks** |
| Audited by | Magneto (Claude Opus 4.6) + Xavier (Claude Sonnet 4.6) |
| Approved by | Emma (Codex) + Jimmy |
| Date | 2026-03-11 |
| Tests | 135/135 PASS |
| Critical Rules | 9/9 PASS |
| Scan Specs | 15/15 PASS |
| First Real Scan | 1,709 entries in 4.65s |
| Latest Indexed State | 1,784 dict entries / 1,770 active entries / 14 deleted - 2026-03-10 |
| Latest Enrichment State | 937 files enriched with `summary` + `keywords` |

## Wikilinks

[[Skill]] | [[docx-indexer]] | [[claude-intelligence-hub]] | [[context-guardian]] | [[repo-auditor]]
