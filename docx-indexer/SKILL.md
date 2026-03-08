---
name: docx-indexer
description: Global document indexing system — append-only JSON index with UUID identity, SHA256 hashing, and structural telemetry. Agents use this skill to scan, validate, and export a persistent index of all files under a configured workspace root.
command: /docx-indexer
aliases: [/dxi]
---

# docx-indexer

**Version:** 1.1.1

## Objective

Provide a global, machine-level document index that allows any Elite League agent to locate files instantly without repeated path explanations. The index is append-only, UUID-identified, and integrity-protected.

## Natural Language Triggers

When the user says any of these (in English or Portuguese), use the docx-indexer:

| User says | Action |
|-----------|--------|
| "find file X in the index" / "acha o arquivo X no índice" | Read `docx-index.json`, search by file_name or path |
| "scan the workspace" / "atualiza o índice" | Run `scan.py` (full scan) |
| "dry-run the index" / "roda um dry-run do indexer" | Run `scan.py --dry-run` |
| "validate the index" / "valida o índice" | Run `validate.py` |
| "how many files do we have?" / "quantos arquivos temos?" | Read `docx-index.json` metadata counters |
| "where is file X?" / "onde está o arquivo X?" | Search index by file_name |
| "list all .md files" / "lista todos os arquivos .md" | Filter index entries by file_type |
| "check the document index" / "consulta o índice de documentos" | Read and query `docx-index.json` |
| "what changed since last scan?" / "o que mudou desde o último scan?" | Run `scan.py --dry-run` and report diff |
| "how big is folder X?" / "qual o tamanho da pasta X?" | Look up directory telemetry in index |

## When to Use

- You need to find files or directories in the workspace
- You need to verify what exists under `C:\ai`
- You need to update the index after significant file changes
- You need to validate index integrity
- You need the Obsidian-friendly markdown view of the index

## When NOT to Use

- Searching file contents (this is structural indexing only, not semantic)
- Knowledge enrichment, summaries, embeddings, or tagging (Phase 2 — not implemented)
- Cross-machine merge operations (deferred)
- Real-time file watching (not supported)

## Technical Workspace

All scripts, configuration, and index files live at:

```
C:\ai\_skills\docx-indexer\
├── config\dxi-config.json       # Machine-specific configuration
├── scripts\
│   ├── scan.py                  # Core scanner (804 lines)
│   ├── validate.py              # Index integrity validator (251 lines)
│   └── export-md.py             # Markdown exporter (50 lines)
├── index\
│   ├── docx-index.json          # Primary index (append-only)
│   ├── docx-index.json.bak      # Atomic backup
│   └── docx-index.md            # Obsidian markdown view
└── tests\                       # 47 tests (all passing)
```

## Commands

### Full Scan (updates index)

```bash
python C:\ai\_skills\docx-indexer\scripts\scan.py --config C:\ai\_skills\docx-indexer\config\dxi-config.json
```

Scans the configured root path recursively, updates the index with new/modified/deleted entries, exports markdown view, and runs git sync.

### Dry-Run (preview only, no writes)

```bash
python C:\ai\_skills\docx-indexer\scripts\scan.py --config C:\ai\_skills\docx-indexer\config\dxi-config.json --dry-run
```

Executes the full scan pipeline but does NOT write to the index, export markdown, or trigger git sync. Use this to preview changes before committing.

### Validate Index Integrity

```bash
python C:\ai\_skills\docx-indexer\scripts\validate.py --index-path C:\ai\_skills\docx-indexer\index
```

Checks: UTF-8 encoding, JSON schema, no duplicate UUIDs, path consistency, entry_type correctness, counter accuracy, APPEND_ONLY header.

### Export Markdown View

```bash
python C:\ai\_skills\docx-indexer\scripts\export-md.py --index-path C:\ai\_skills\docx-indexer\index
```

Regenerates `docx-index.md` from `docx-index.json` for Obsidian visualization.

### Run Tests

```bash
cd C:\ai\_skills\docx-indexer && python -m pytest tests/ -v
```

47 tests: 7 hash + 5 uuid + 15 scan + 12 incremental + 8 integration. All must pass.

## MASTER CRITICAL RULES (Non-Negotiable)

1. **APPEND-ONLY** — The index is NEVER rebuilt, reset, or truncated in normal operation
2. **UUID Permanence** — Once assigned to a path, a UUID NEVER changes
3. **Soft Delete Only** — Entries are marked `status: deleted` with `deleted_at` timestamp, NEVER removed
4. **Atomic Write** — temp file → validate integrity → rename to final
5. **Backup Before Write** — `.bak` is always created before any modification
6. **Human Override Required** — Only a human can authorize rebuild/reset of the index
7. **Directories: content_hash = null** — Directories never have content hashes
8. **Exclusions Are Technical Only** — Only `.git`, `node_modules`, `__pycache__`, `.venv`, `.claude`, etc.
9. **No Phase 2 Features** — No enrichment, embeddings, summaries, keywords, entities, semantic linking, auto-tagging, watch mode, or cross-machine automation

## Operational Flow

```
Agent or Jimmy triggers scan
    → Load config (dxi-config.json)
    → Load existing index
    → Backup index (.bak)
    → Recursive filesystem scan
    → Compute diff vs index
    → Calculate structural telemetry (bottom-up)
    → Update counters
    → [if --dry-run: STOP here, print report]
    → Write index (atomic)
    → Export markdown
    → Git sync
    → Print scan report
```

## Index Data Model

Each entry is keyed by absolute path and contains:

**Files:** uuid, file_name, machine_name, exact_path, entry_type, file_type, content_hash (SHA256), size_bytes, last_modified, indexed_at, status, tags, category

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
| LK-01 | No move detection — moved file = soft delete + new entry |
| LK-02 | Hash is partial for files > 500MB (first 1MB + last 1MB) |
| LK-03 | No semantic search — structural indexing only |
| LK-04 | Single-machine — cross-machine merge requires manual merge.py (deferred) |
| LK-05 | No watch mode — batch scan only |
| LK-06 | Telemetry calculation is O(D*E) — manageable at current scale |
| LK-07 | Tags and category are manual — no auto-classification |

## Deferred Items (Non-Blocking)

| Item | Classification |
|------|---------------|
| `scripts/merge.py` | P2-Complementar |
| `config/dxi-config.schema.json` | P2-Complementar |
| `tests/integration/test_sync.py` | P2-Complementar |

## Audit Status

| Field | Value |
|-------|-------|
| Phase 1 Decision | **GO** |
| Audited by | Magneto (Claude Opus 4.6) |
| Approved by | Emma (Codex) |
| Date | 2026-03-06 |
| Tests | 47/47 PASS |
| Critical Rules | 9/9 PASS |
| Scan Specs | 15/15 PASS |
| First Real Scan | 1,709 entries in 4.65s |
| Latest Scan | 1,736 entries (1,092 files + 644 dirs) in 4.61s — 2026-03-08 |

## Wikilinks

[[Skill]] | [[docx-indexer]] | [[claude-intelligence-hub]] | [[context-guardian]] | [[repo-auditor]]
