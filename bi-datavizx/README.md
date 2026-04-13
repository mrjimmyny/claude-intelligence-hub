# bi-datavizx

> Backend BI execution toolkit for Power BI ecosystem

**Version:** 1.1.0 | **Status:** Production | **Published:** 2026-04-12 | **Tests:** 1,296 passed

---

## What Is bi-datavizx?

bi-datavizx (bdvx) is a skill that automates the **backend** of working with Microsoft Power BI projects. Instead of clicking through menus, editing JSON files by hand, or switching between multiple tools, you give commands to an AI agent (Claude Code, Codex, or Gemini) and bi-datavizx handles everything behind the scenes.

It covers the full Power BI backend workflow:

- **Connect to data sources** — BigQuery and SharePoint, fully automated
- **Build and manage data models** — tables, columns, measures, relationships, DAX calculations
- **Format and lint DAX code** — 10 documented rules enforced automatically
- **Edit reports** — pages, visuals, themes, filters, backgrounds, bookmarks
- **Publish to the cloud** — Microsoft Fabric and Power BI Premium workspaces
- **Enforce governance** — every destructive action requires your explicit approval before it runs

Its companion skill, [bi-designerx](../bi-designerx/), handles the **frontend** (visual design: colors, backgrounds, layouts). Together, they cover the entire Power BI workflow from raw data to published dashboard.

---

## How It Works

bi-datavizx wraps two powerful external engines:

| Engine | What it controls | When it is used |
|---|---|---|
| **pbi-cli** | Power BI Desktop (the application) | Model operations: tables, measures, DAX, relationships, TMDL |
| **pbir-cli** | PBIR report files (no Desktop needed) | Report operations: pages, visuals, themes, filters, backgrounds |

You never interact with these engines directly. You use `bdvx` commands, and bi-datavizx routes each request to the correct engine automatically. All commands produce JSON output by default, making them easy to chain and automate.

### Architecture at a Glance

bi-datavizx is organized into **10 modules**, each with a specific job:

| # | Module | What it does |
|---|---|---|
| 1 | **core-contract** | Command surface, JSON I/O, audit log, credential management, configuration |
| 2 | **project-intel** | Finds Power BI projects on disk, builds a structural index, answers structural queries |
| 3 | **desktop-adapter** | Wraps pbi-cli + pbir-cli — routes commands to the correct engine |
| 4 | **fabric-adapter** | Wraps pbi-fixer v2 + sempy-labs for cloud operations (Fabric/Premium) |
| 5 | **data-ingest** | BigQuery + SharePoint import, Power Query/M code generation, schema drift detection |
| 6 | **report-ops** | Report formatting, bi-designerx design pack handoff, visual management |
| 7 | **model-ops** | DAX formatting/linting (10 rules), calculation groups, time intelligence |
| 8 | **governance** | Destructive-op gates, scan-first defaults, diff-before-write, rollback hooks |
| 9 | **docs** | Auto-generates model dictionaries, source summaries, change reports, diagrams |
| 10 | **integration** | Findings tracking, session doc wiring, CEM protection, locality enforcement |

### Agent Compatibility

bi-datavizx is **agent-neutral**. The same commands work identically on any supported AI agent — no branching, no agent-specific code.

| Provider | Agent | Status |
|---|---|---|
| Anthropic | Claude Code (Sonnet / Opus) | Tested |
| OpenAI | Codex | Tested |
| Google | Gemini | Tested |
| Any | Any LLM with file I/O | Compatible |

---

## What It Does NOT Do

Understanding the boundaries is as important as understanding the features:

- **Does NOT design dashboards** — visual design (colors, backgrounds, layout, typography) is handled by [bi-designerx](../bi-designerx/). bi-datavizx consumes design packs; it does not create them.
- **Does NOT replace Power BI Desktop** — it automates Desktop via pbi-cli. You still need Desktop installed on your machine for model operations.
- **Does NOT store or process real customer data** — it generates Power Query/M expressions and model structures. Your actual data stays in your data sources (BigQuery, SharePoint, etc.) and in Power BI's own storage.
- **Does NOT make decisions for you** — every destructive action (deleting a table, removing a page, publishing to Fabric) requires your explicit written approval.
- **Does NOT connect to the internet on its own** — all external connections (BigQuery, SharePoint, Fabric) go through your machine's existing authenticated sessions and stored credentials.

---

## Prerequisites

Before installing bi-datavizx, make sure your machine has the following software installed. All dependencies are free or included with your existing licenses.

### Required Software

| # | Software | Version | Why it is needed | How to install |
|---|---|---|---|---|
| 1 | **Python** | **3.11.x** | Runtime for bi-datavizx and all its modules. Version 3.11 is specifically required for Fabric/Premium features (sempy-labs). | `winget install Python.Python.3.11` |
| 2 | **pywin32** | >= 306 | Provides access to Windows Credential Manager for secure credential storage (DPAPI encryption). | `py -3.11 -m pip install "pywin32>=306"` |
| 3 | **Node.js** | >= 18 | Required by pbi-cli at runtime. | `winget install OpenJS.NodeJS` |
| 4 | **Power BI Desktop** | Latest | Required for model operations (pbi-cli connects to it). Must be installed and runnable on the same machine. | [Download from Microsoft](https://powerbi.microsoft.com/desktop/) or install via Microsoft Store |
| 5 | **pbi-cli** | 3.10.10 (locked) | Controls Power BI Desktop for model operations (tables, measures, DAX, relationships). | `py -3.11 -m pip install "pbi-cli-tool @ git+https://github.com/MinaSaad1/pbi-cli.git@v3.10.10"` |
| 6 | **pbir-cli** | 0.9.7 (locked) | Controls PBIR report files directly without Desktop. | Download MSI from [GitHub releases](https://github.com/maxanatsko/pbir.tools/releases/tag/v0.9.7) and run the installer |
| 7 | **semantic-link-labs** | >= 0.14.0 | Enables Fabric/Premium features: Best Practice Analyzer, IBCS compliance, Vertipaq analysis. | `py -3.11 -m pip install semantic-link-labs` |

### Required for BigQuery Data Sources

If you plan to import data from Google BigQuery (Module 5: data-ingest), the Google Cloud SDK is **required**. Without it, BigQuery import operations will not work.

| # | Software | Version | How to install |
|---|---|---|---|
| 1 | **Google Cloud SDK** (`gcloud`) | Latest | `winget install Google.CloudSDK` |

#### BigQuery Authentication — Step by Step

After installing the Google Cloud SDK, you must authenticate with the Google account that has access to your BigQuery project. This is a one-time setup (tokens are cached locally).

**Step 1: Authenticate your Google account**

Open PowerShell or your terminal and run:
```powershell
gcloud auth login
```
This opens your default browser. Sign in with the Google account that has access to BigQuery (usually your corporate email). After login, the browser shows "You are now authenticated" and you can close it.

**Step 2: Set application-default credentials (required for Python libraries)**

```powershell
gcloud auth application-default login
```
Same flow — opens browser, you sign in, token is saved locally.

**Step 3: Verify authentication**

```powershell
gcloud auth list
# Should show your account with an asterisk (*) as ACTIVE

gcloud config set project YOUR_GCP_PROJECT_ID
# Sets the default project for BigQuery queries
```

**Step 4: Store credentials in bi-datavizx**

```bash
bdvx credential set bdvx/myproject/bigquery/service-account
```
The skill stores the credential reference in Windows Credential Manager (DPAPI encrypted). The actual Google OAuth token is managed by `gcloud` — bi-datavizx reads it at runtime, never stores the raw token.

#### Important Security Notes

- **Your password is never shared with the AI agent.** Authentication happens in YOUR browser on YOUR machine. The agent never sees your Google credentials.
- **Tokens are stored locally by gcloud** in `~/.config/gcloud/` (encrypted by Windows).
- **bi-datavizx only reads tokens at runtime** via the `gcloud` Python libraries. Tokens are decrypted in memory, used for the current operation, and released immediately.
- **No tokens are logged, displayed, or transmitted.** The audit log records that a BigQuery operation ran, but never the credential value.

### Optional Software

| Software | Why you might need it |
|---|---|
| **Git** | Recommended for version-controlling your Power BI projects in PBIP/TMDL format. |

### Operating System

- **Windows 10 or Windows 11** — required. bi-datavizx uses Windows Credential Manager (DPAPI) for secure credential storage and wraps Windows-native tools (Power BI Desktop, pbi-cli). It does not run on macOS or Linux.

### Python Version Note

Python 3.14 works for local Desktop operations, but `semantic-link-labs` (Fabric features) requires Python >= 3.10 and < 3.13. Use **Python 3.11** for full compatibility with all features.

---

## Installation — Step by Step

Follow these steps in order. Each step includes a verification command so you know it worked.

### Step 1: Install Python 3.11

```bash
winget install Python.Python.3.11
```

Verify:
```bash
py -3.11 --version
# Expected: Python 3.11.x
```

### Step 2: Install pywin32

```bash
py -3.11 -m pip install "pywin32>=306"
```

Verify:
```bash
py -3.11 -c "import win32cred; print('OK')"
# Expected: OK
```

### Step 3: Install Node.js (if not already installed)

```bash
winget install OpenJS.NodeJS
```

Verify:
```bash
node --version
# Expected: v18.x.x or higher
```

### Step 4: Install pbi-cli

```bash
py -3.11 -m pip install "pbi-cli-tool @ git+https://github.com/MinaSaad1/pbi-cli.git@v3.10.10"
```

Verify:
```bash
py -3.11 -m pbi_cli --version
# Expected: pbi-cli, version 3.10.10
```

### Step 5: Install pbir-cli

Download the MSI installer from: [https://github.com/maxanatsko/pbir.tools/releases/tag/v0.9.7](https://github.com/maxanatsko/pbir.tools/releases/tag/v0.9.7)

Run the MSI and follow the prompts.

Verify:
```bash
pbir --version
# Expected: pbir 0.9.7
```

### Step 6: Install semantic-link-labs (for Fabric/Premium features)

```bash
py -3.11 -m pip install semantic-link-labs
```

Verify:
```bash
py -3.11 -c "import sempy_labs; print('OK')"
# Expected: OK
```

### Step 7: Install bi-datavizx itself

```bash
cd C:/ai/_skills/bi-datavizx
py -3.11 -m pip install -e ".[dev]"
```

Verify:
```bash
py -3.11 -c "from bdvx.core.dispatcher import dispatch; r = dispatch('core', 'version', {}, 'test'); print(r)"
# Expected: JSON output with version information
```

### Step 8: Run the test suite

```bash
cd C:/ai/_skills/bi-datavizx
pytest tests/ --no-cov -q
# Expected: 1296 passed, 47 skipped, 0 failed
```

If all steps pass, your installation is complete and ready for use.

---

## Usage

### Invoking the Skill

Through an AI agent (recommended):
```
/bdvx
```
Or use the alias:
```
/bi-datavizx
```

You can also use natural language with any supported agent. Just describe what you want:
- "Discover all Power BI projects in C:/projects/finance"
- "Build the structural index for my HR dashboard"
- "Show me all measures with 'revenue' in the name"
- "Import the monthly_revenue table from BigQuery"

### Command-Line Usage

All commands emit JSON to stdout by default. Add `--pretty` for human-readable output.

#### Core

```bash
# Check version and installation
bdvx --json core version
bdvx --pretty core version
```

#### Credential Management

```bash
# Store a credential securely in Windows Credential Manager
bdvx credential set bdvx/myproject/bigquery/service-account --value "..."

# Check if a credential exists (never shows the actual value)
bdvx credential get bdvx/myproject/bigquery/service-account

# List all stored credential keys
bdvx credential list

# Delete a credential (irreversible — requires confirmation)
bdvx credential delete bdvx/myproject/bigquery/service-account --confirm
```

#### Project Intelligence

```bash
# Find all Power BI projects in a folder
bdvx project discover --root C:/path/to/projects

# Build or rebuild the structural index
bdvx project index-build --project-root C:/path/to/project
bdvx project index-build --project-root C:/path/to/project --rebuild

# Query the index (reads from POWER_BI_INDEX.md — fast, no Desktop needed)
bdvx project query --project-root C:/path/to/project --kind measures
bdvx project query --project-root C:/path/to/project --kind tables
```

#### Python API

```python
from pathlib import Path
from bdvx.project_intel.discover import discover
from bdvx.project_intel.index import index_build
from bdvx.project_intel.query import query
from bdvx.project_intel.validate import validate

root = Path("C:/path/to/project")

# Discover all PBIP artifacts
projects = discover(root)

# Build or rebuild the structural index
index_path = index_build(root, rebuild=True)

# Query by kind: tables, measures, relationships, roles, perspectives, pages
measures = query(root, "measures")

# Validate index health (auto-regenerates if stale)
report = validate(root)
```

---

## Operations Catalog

bi-datavizx provides approximately **70 operations** across **11 categories**. Here is what each category covers:

### 1. Project Discovery and Intelligence (5 operations)

Find Power BI projects on disk, build a structural index that saves 50-97% of tokens on queries, ask questions about your project structure, validate index integrity, and watch for real-time file changes.

### 2. Credential and Security Management (6 operations)

Store credentials in Windows Credential Manager (encrypted, never in plain text), retrieve them at runtime, list stored keys (never values), rotate with 30-day archive, revoke with confirmation, and probe validity without running full operations.

### 3. Data Ingestion (10 operations)

Import from BigQuery and SharePoint with zero manual steps. Create, update, preview, diff, and rollback Power Query/M expressions. Set refresh policies. Detect schema drift (new columns, type changes, dropped columns). Check data source health and latency.

### 4. Semantic Model Operations (20 operations)

Connect to the live model in Power BI Desktop. Execute DAX queries. Validate DAX syntax. Consult latest DAX documentation via Context7 before writing measures. Create and modify tables, measures, relationships, calculation groups, and hierarchies. Export, import, and diff TMDL files. Manage row-level security. Configure incremental refresh. Run diagnostics. Format and lint DAX with 10 rules (DAX001-DAX010).

### 5. Report Operations (17 operations)

Create reports from scratch. Validate report structure. Add, rename, reorder, duplicate, and remove pages. Add and configure any of 32 native visual types. Bulk-modify visuals by pattern. Bind visuals to data fields. Apply themes with preview diffs. Configure filters at report, page, and visual level. Set backgrounds. Manage bookmarks. Apply conditional formatting and visual-level formatting.

### 6. bi-designerx Handoff (3 operations)

Validate a design pack from bi-designerx. Preview what it would change (dry run). Apply it to the report — the bridge between "how it looks" and "how it works."

### 7. Fabric / Premium Operations (7 operations)

Scan Fabric/Premium workspaces. Run Best Practice Analyzer. Check IBCS compliance (opt-in). Run Vertipaq analysis for memory optimization. Manage perspectives. Publish to and download from Fabric workspaces.

### 8. Documentation and Reporting (5 operations)

Generate model dictionaries (every table, column, measure, relationship). Generate source summaries. Generate change reports. Export model diagrams as SVG. Export architecture as JSON.

### 9. Governance and Safety (7 operations)

Destructive action gate (blocks deletes until you approve). Scan-first default (preview before write). Audit log (append-only trail of every command). CEM protection (blocks writes to design files). Locality enforcement (prevents file dumping in wrong directories). Regression test pack. Automatic change logging.

### 10. Integration (5 operations)

Create formal finding tickets (FND-XXXX). Dispatch CODEX reviews via AOP. Update session documents. Update project operational docs. Render TB-01 arbitration verdicts.

### 11. Migration and Setup (3 operations)

Migrate from the older pbi-claude-skills (now removed from Hub — fully superseded by bi-datavizx). Check version of all components. Sync configuration across machines.

For detailed descriptions with examples of every operation, see [SKILL.md](./SKILL.md).

---

## Security and Privacy

This section explains how bi-datavizx handles sensitive data, credentials, and access control. The skill was designed with security as a first-class requirement.

### No Customer Data Is Stored or Processed by the Skill

bi-datavizx **does not store, copy, cache, or process your actual business data**. Here is what it does and does not touch:

| What the skill does | What it does NOT do |
|---|---|
| Generates Power Query/M expressions (code that tells Power BI *how* to fetch data) | Does not fetch, store, or cache the actual data rows |
| Reads model metadata (table names, column names, measure definitions) | Does not read the data values inside those tables |
| Modifies report structure (pages, visuals, filters) | Does not access or transmit the data displayed in visuals |
| Sends structural commands to pbi-cli / pbir-cli | Does not intercept or log data flowing between Power BI and your data sources |

Your actual business data lives in your data sources (BigQuery, SharePoint, SQL Server, etc.) and in Power BI's own in-memory engine. bi-datavizx never sees it.

### Credential Safety

All credentials (passwords, API keys, OAuth tokens) are managed through **Windows Credential Manager** (DPAPI encryption):

- **Credentials are never stored in plain text** — not in config files, not in logs, not in chat messages, not in environment variables.
- **Credential values are never returned or displayed** — the `credential get` command confirms a key exists but never shows its value. The `credential list` command shows key names only.
- **Credentials are encrypted by Windows itself** — DPAPI ties encryption to the Windows user profile. A credential stored on your machine can only be decrypted by your Windows user account on that machine.
- **Credential rotation includes 30-day archive** — when you rotate a credential, the old value is archived for 30 days in case you need to roll back.
- **Revocation requires explicit confirmation** — deleting a credential is irreversible and requires you to type a confirmation.

### Sandbox and Controlled Environment

bi-datavizx operates in a **sandboxed, controlled environment**:

- **Local execution only** — all operations run on your local machine. The skill does not connect to external servers except through your own authenticated sessions (BigQuery, SharePoint, Fabric).
- **No telemetry or phone-home** — the skill does not send any data, logs, or usage statistics to external servers.
- **No network listeners** — the skill does not open ports or listen for incoming connections.
- **File write boundaries** — the skill can only write files to authorized project directories. The locality rule prevents accidental file creation in the wrong folder.
- **Audit trail** — every command is logged in an append-only audit trail with timestamps, agent identity, and result. You always know what happened and when.

### Destructive Action Safety Protocol

Every operation that deletes, removes, or overwrites something follows a **6-step safety protocol**:

1. **STOP** — the skill pauses before executing the destructive operation.
2. **INFORM** — it tells you exactly what will be affected, what will break, and whether it can be undone.
3. **WAIT** — it waits for your explicit written authorization for that specific item.
4. **EXECUTE** — only after your authorization, it runs the approved operation and nothing else.
5. **CONFIRM** — it reports the result after execution.
6. **RESET** — the next destructive operation requires fresh authorization. No blanket approvals. No carry-over.

This protocol applies to: tables, columns, measures, relationships, pages, visuals, bookmarks, filters, files, workspace items, credentials, and any bulk/recursive operation.

### What Happens If Something Goes Wrong?

- **Model changes** can be rolled back via TMDL transactions (atomic commit/rollback).
- **M expression changes** can be reverted to the previous version.
- **Credential rotations** keep the old value for 30 days.
- **Report edits** operate on local `.pbip` files — your git history preserves every previous state.
- **Fabric publications** require your explicit authorization and can be reversed by re-publishing a previous version.

---

## Relationship with bi-designerx

bi-datavizx and bi-designerx are **intentionally paired as complementary skills**:

| Aspect | bi-designerx (frontend) | bi-datavizx (backend) |
|---|---|---|
| **Domain** | Visual design | Data, models, reports, governance |
| **Tool** | Paper.design + CEM pipeline | pbi-cli + pbir-cli + pbi-fixer |
| **Output** | Design pack (backgrounds, layouts, style tokens) | Working Power BI report with data |
| **Input** | References, descriptions, design briefs | Design packs, data source specs, DAX templates |

**How they connect:** bi-designerx produces a design pack (backgrounds, visual placements, style tokens). bi-datavizx consumes that design pack through the **handoff bridge** (Module 6) and applies it to the actual Power BI report. Neither skill owns the other — they are peers connected by a single handoff contract.

---

## Limitations

- **Windows only** — requires Windows 10/11. Power BI Desktop, pbi-cli, and Windows Credential Manager are Windows-native.
- **Power BI Desktop must be installed** — model operations (pbi-cli) require a running Desktop instance on the same machine.
- **Python 3.11 for full features** — Fabric/Premium features (sempy-labs) require Python >= 3.10 and < 3.13. Python 3.14 works for Desktop-only workflows.
- **Two data sources supported for ingestion** — BigQuery and SharePoint. Other sources (SQL Server, REST APIs, Excel) can be used through Power BI's native connectors but are not automated by bi-datavizx.
- **Phase 7 (Deployment Governance) was dropped** — automated deployment pipelines and environment promotion are not in scope for v1. Publication to Fabric is supported as a manual (authorized) operation.
- **No real-time collaboration** — the skill operates on local `.pbip` files. Concurrent editing by multiple users on the same project requires git-based coordination.

---

## Frequently Asked Questions

**Q: Do I need to know DAX to use this skill?**
A: No. You can describe what you want in plain language (e.g., "create a measure that calculates year-over-year revenue growth") and the agent will write the DAX for you, formatted according to the 10-rule standard. If you already know DAX, you can paste your own code and the skill will format and lint it.

**Q: Can I use this with Power BI reports that were not created as .pbip projects?**
A: The skill works best with `.pbip` (Power BI Project) format, which is the modern, git-friendly format. If you have a `.pbix` file, you would need to convert it to `.pbip` first using Power BI Desktop (File > Save as > Power BI Project).

**Q: Does this work with Fabric/Premium workspaces?**
A: Yes. Module 4 (fabric-adapter) wraps pbi-fixer v2 and semantic-link-labs for workspace scanning, Best Practice Analyzer, IBCS compliance, Vertipaq analysis, and publish/download operations. Requires `semantic-link-labs` and Python 3.11.

**Q: What if I do not use BigQuery or SharePoint?**
A: That is fine. BigQuery and SharePoint are the two automated data ingestion sources. For any other data source (SQL Server, Excel, REST APIs, etc.), you use Power BI's native connectors as usual. bi-datavizx still helps you with everything else: model building, DAX, report formatting, governance, and publishing.

**Q: Can I run this on macOS or Linux?**
A: No. bi-datavizx requires Windows because Power BI Desktop, pbi-cli, pbir-cli, and Windows Credential Manager are Windows-native. There is no cross-platform alternative at this time.

**Q: Is my data sent to any AI model or external service?**
A: No. bi-datavizx runs entirely on your local machine. The AI agent (Claude Code, Codex, Gemini) reads your project metadata (table names, measure definitions, report structure) to understand what to do, but your actual business data rows are never sent to any AI model. Credentials are stored in Windows Credential Manager and never leave your machine.

**Q: What happens if I run a command that would break my report?**
A: Every write operation shows you a preview/diff of what will change before applying. Every destructive operation (delete, remove, overwrite) is blocked until you give explicit written authorization. If a change does break something, model changes can be rolled back via TMDL transactions and report edits can be reversed via git history.

**Q: How is this different from the old pbi-claude-skills?**
A: bi-datavizx fully supersedes pbi-claude-skills (which has been removed from the Hub). bi-datavizx covers the same functionality plus: BigQuery/SharePoint data ingestion, DAX formatting/linting, Fabric/Premium operations, bi-designerx design handoff, and a comprehensive governance layer. A migration command (`bdvx migrate from-pbi-claude-skills`) is available to transition existing projects.

---

## Troubleshooting

### pbi-cli cannot connect to Power BI Desktop

Make sure Power BI Desktop is running and has a report open. pbi-cli connects to Desktop via a local protocol (TOM/ADOMD) — Desktop must be active.

### pytest shows import errors

Make sure you installed bi-datavizx in dev mode:
```bash
cd C:/ai/_skills/bi-datavizx
py -3.11 -m pip install -e ".[dev]"
```

### sempy-labs import fails

This typically means you are using a Python version outside the supported range (>= 3.10, < 3.13). Verify:
```bash
py -3.11 --version
```

### Credential operations fail with access denied

Windows Credential Manager (DPAPI) ties credentials to your Windows user account. Make sure you are running the command as the same user who stored the credential.

### pbir-cli not found

pbir-cli is installed via MSI, not pip. Make sure you ran the MSI installer and that the installation directory is on your system PATH.

---

## CI/CD

bi-datavizx is part of the [Claude Intelligence Hub](../) and follows its CI/CD pipeline:

| Workflow | File | Trigger | What it checks |
|---|---|---|---|
| **Integrity Check** | `ci-integrity.yml` | Push / PR | Version sync across `.metadata`, `SKILL.md`, `HUB_MAP.md`, `README.md`, `CHANGELOG.md` |
| **Security Review** | `security-review.yml` | Push / PR | Scans for exposed secrets, PII, hardcoded paths, dangerous files |

### Running Integrity Check Locally

```bash
cd C:/ai/claude-intelligence-hub
bash scripts/integrity-check.sh
# Expected: Passed: 6 | Failed: 0
```

---

## Project Structure

```
claude-intelligence-hub/bi-datavizx/
  README.md           # This file — comprehensive user documentation
  SKILL.md            # Full operational reference (10 modules, commands, governance rules)
  CHANGELOG.md        # Version history
  .metadata           # Version and metadata (JSON, source of truth for version sync)

_skills/bi-datavizx/          # Technical layer (code, tests, scripts)
  bdvx/                       # Python package (10 modules, 83 source files)
    core/                     # Module 1: core-contract
    project_intel/            # Module 2: project-intel
    desktop_adapter/          # Module 3: desktop-adapter (pbi-cli + pbir-cli)
    fabric_adapter/           # Module 4: fabric-adapter (pbi-fixer v2)
    data_ingest/              # Module 5: data-ingest (BigQuery + SharePoint)
    report_ops/               # Module 6: report-ops (bi-designerx handoff)
    model_ops/                # Module 7: model-ops (DAX formatter/linter)
    governance/               # Module 8: governance
    docs/                     # Module 9: docs
    integration/              # Module 10: integration
  tests/                      # 105 test files, 1296 tests
  scripts/                    # Utility and verification scripts
  pyproject.toml              # Package configuration
  pytest.ini                  # Test configuration (85% coverage threshold)
```

---

## Key Statistics

| Metric | Value |
|---|---|
| Total operations | ~70 across 11 categories |
| Modules | 10 |
| Python source files | 83 |
| Test files | 105 |
| Tests passed | 1,296 |
| Tests skipped | 47 |
| Tests failed | 0 |
| Backend engines | 2 (pbi-cli v3.10.10, pbir-cli v0.9.7) |
| DAX linter rules | 10 (DAX001-DAX010) |
| Token savings (structural index) | 50-97% on a 37-table, 618-measure project |
| Contract version | v1.6 |
| SDD version | v6.0 (final) |
| Governance rules | 10 (G-01 through G-10) |
| Project decisions | 71 (D1 through D71) |

---

## Version History

| Version | Date | Changes |
|---|---|---|
| 1.1.0 | 2026-04-12 | Initial v1 release. Phases 1-6 CLOSED + DAX Authoring Standards (DAX007-010). Phase 7 permanently dropped. 1,296 tests PASS. SC1-SC12 ALL MET. 10-module architecture. Contract v1.6 finalized. pbi-claude-skills removed from Hub (superseded). |

---

## Documentation

- **[SKILL.md](./SKILL.md)** — Full operational reference (commands, modules, governance rules, DAX standards)
- **[CHANGELOG.md](./CHANGELOG.md)** — Detailed version history

For the complete documental layer (contracts, specs, planning, tests, audits):

```
obsidian/CIH/projects/skills/bi-datavizx/
  01-manifesto-contract/    — Contract v1.6
  02-planning/              — Phase DEPs (execution plans)
  03-spec/                  — SDD v6.0 (technical specification)
  04-tests/                 — Acceptance criteria and exit gate reports
  06-operationalization/    — Operations guide, catalog, and NotebookLM-optimized guide
```

---

*Developed by Magneto (Claude Code — Opus 4.6) for Jimmy*
*Published in Claude Intelligence Hub v2.29.12*
