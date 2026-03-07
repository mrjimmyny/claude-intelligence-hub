# 📂 docx-indexer (v1.1.0)

> **Your workspace's memory** — A global document index that knows where every file lives.

---

## 🎯 What Is This?

The **docx-indexer** is like an inventory system for your entire workspace. It scans all files and folders under a root directory (e.g., `C:\ai`) and builds a persistent catalog with:

- 🔑 A **unique ID (UUID)** for every file and folder — permanent, never changes
- 🔒 A **fingerprint (SHA256 hash)** of each file's content — detects changes instantly
- 📊 **Structural telemetry** for folders — how many children, total size
- 📝 An **Obsidian-friendly markdown view** — browse the index visually

**Think of it as:** A phone book for your files. Instead of navigating folders or explaining paths, just ask the agent to look it up.

---

## ⚡ Quick Start

| Command | Alias |
|---------|-------|
| `/docx-indexer` | `/dxi` |

**Three things you can do right now:**

```bash
# 1. Preview what changed (safe, no writes)
python scripts/scan.py --config config/dxi-config.json --dry-run

# 2. Update the index for real
python scripts/scan.py --config config/dxi-config.json

# 3. Verify everything is consistent
python scripts/validate.py --index-path index
```

All commands run from `C:\ai\_skills\docx-indexer\`.

---

## 💬 How to Interact — Real Examples

You don't need to memorize commands. Just ask naturally — the agent knows what to do.

### 🔍 Finding Files

> **PT:** "Magneto, consulta o índice de documentos e acha o arquivo `contract-jimmy`"
> **EN:** "Magneto, check the document index and find the file `contract-jimmy`"

The agent searches the index, finds the full path, and can then read or edit the file for you.

> **PT:** "Onde está o arquivo de audit summary do docx-indexer?"
> **EN:** "Where is the docx-indexer audit summary file?"

> **PT:** "Lista todos os arquivos .py no índice"
> **EN:** "List all .py files in the index"

### 📊 Getting Information

> **PT:** "Quantos arquivos temos indexados?"
> **EN:** "How many files do we have indexed?"

> **PT:** "Qual o tamanho da pasta obsidian/CIH?"
> **EN:** "How big is the obsidian/CIH folder?"

> **PT:** "Mostra os 10 maiores arquivos no índice"
> **EN:** "Show the 10 largest files in the index"

### 🔄 Updating the Index

> **PT:** "Roda um dry-run do docx-indexer pra ver o que mudou"
> **EN:** "Run a dry-run of the docx-indexer to see what changed"

> **PT:** "Atualiza o índice de documentos"
> **EN:** "Update the document index"

> **PT:** "Valida o índice do docx-indexer, quero saber se está tudo ok"
> **EN:** "Validate the docx-indexer index, I want to know if everything is ok"

### 🧩 Combining with Other Tasks

> **PT:** "De acordo com nosso índice de arquivos, acha todos os daily reports de fevereiro/26 e cria um documento executivo consolidado"
> **EN:** "Using our file index, find all daily reports from February/26 and create a consolidated executive document"

> **PT:** "Procura no índice o arquivo `contract-jimmy` e atualiza o status dele para `closed`"
> **EN:** "Search the index for `contract-jimmy` and update its status to `closed`"

> **PT:** "Encontra no índice todos os arquivos que tenham `audit` no nome e me faz um resumo de cada um"
> **EN:** "Find all files with `audit` in the name from the index and give me a summary of each one"

---

## ❓ Q&A — Frequently Asked Questions

### Do I need to say "docx-indexer" every time?
No. You can say things like "consulta o índice de documentos" or "check the document index" — the agent is configured to recognize these phrases and use the docx-indexer automatically.

### Does the index search inside file contents?
No. The index knows **where files are** and **what they're called**, but not **what they say inside**. It's structural, not semantic. Content search is planned for Phase 2.

### What happens if I delete a file?
The index marks it as "deleted" with a timestamp — it never removes the entry. This preserves the history of what existed. On the next scan, the deletion is detected automatically.

### Can the index break or get corrupted?
It's designed to be extremely safe: atomic writes (temp file → validate → rename), automatic backup before every change, and an append-only rule that prevents accidental data loss. If something does go wrong, the `.bak` file is your safety net.

### Does the scan run automatically?
No. You need to ask for it explicitly — either through natural language ("atualiza o índice") or via the scan command. There is no background watcher.

### How fast is a scan?
The first scan of `C:\ai` (1,709 entries) took 4.65 seconds. Subsequent scans are faster because unchanged files are skipped.

### Can I use this across multiple machines?
Not yet. Phase 1 is single-machine only. Cross-machine merge (`merge.py`) is a deferred complementary feature.

### What files does the scan exclude?
Technical/cache directories only: `.git`, `node_modules`, `__pycache__`, `.venv`, `.claude`. No content-based exclusions — every real file gets indexed.

### Can any agent use this skill?
Yes. It's a Global Skill available to all Elite League agents (Xavier, Magneto, Emma, Forge, Ciclope) via `/docx-indexer` or `/dxi`.

---

## 🏗️ Architecture Overview

```
C:\ai\_skills\docx-indexer\
├── config/
│   └── dxi-config.json          # Machine-specific configuration
├── scripts/
│   ├── scan.py                  # Core scanner (804 lines)
│   ├── validate.py              # Index validator (252 lines)
│   └── export-md.py             # Markdown exporter (50 lines)
├── index/
│   ├── docx-index.json          # Primary index (append-only)
│   ├── docx-index.json.bak      # Automatic backup
│   └── docx-index.md            # Obsidian markdown view
└── tests/                       # 47 tests (all passing)
```

---

## 🛡️ Critical Rules

These rules are **non-negotiable** and apply to every agent:

| # | Rule | Why |
|---|------|-----|
| 1 | **APPEND-ONLY** — never rebuild/reset/truncate | Preserves complete history |
| 2 | **UUID permanence** — once assigned, never changes | Stable references across sessions |
| 3 | **Soft delete only** — mark as deleted, never remove | Audit trail for everything |
| 4 | **Atomic write** — temp → validate → rename | Prevents corruption |
| 5 | **Backup before write** — `.bak` always first | Safety net |
| 6 | **Human override for rebuild** — only a human can reset | Prevents accidental destruction |

---

## 📈 Current Stats

| Metric | Value |
|--------|-------|
| Total entries | 1,709 |
| Files | 1,068 |
| Directories | 641 |
| Last scan | 4.65s |
| Tests | 47/47 PASS |
| Critical rules | 9/9 PASS |
| Audit decision | **GO** (2026-03-06) |

---

## 🔗 Key Paths

| Resource | Path |
|----------|------|
| Technical workspace | `C:\ai\_skills\docx-indexer\` |
| Documentation | `C:\ai\obsidian\CIH\projects\skills\docx-indexer\` |
| CIH skill directory | `C:\ai\claude-intelligence-hub\docx-indexer\` |
| Index (JSON) | `C:\ai\_skills\docx-indexer\index\docx-index.json` |
| Index (Markdown) | `C:\ai\_skills\docx-indexer\index\docx-index.md` |
| Configuration | `C:\ai\_skills\docx-indexer\config\dxi-config.json` |

---

## 🚫 What It Does NOT Do

- Search file **contents** (structural indexing only)
- Provide summaries, keywords, or semantic search (Phase 2)
- Sync across machines (single-machine scope)
- Watch files in real-time (batch scan only)
- Auto-classify or auto-tag entries

---

## 📚 Reference

| Document | Location |
|----------|----------|
| Full operational guide | `SKILL.md` (this skill directory) |
| Contract | `01-manifesto-contract/docx-indexer-contract-jimmy-2026-03-05-v1.0.md` |
| Implementation testament | `05-final/docx-indexer-phase1-implementation-testament-xavier-v1.0.md` |
| Audit report | `04-tests/docx-indexer-phase1-operational-validation-audit-magneto-v1.0.md` |
| Usage guide | `06-operationalization/docx-indexer-global-skill-usage-guide-brain-v1.0.md` |
| Operational handoff | `06-operationalization/docx-indexer-global-skill-handoff-brain-v1.0.md` |
