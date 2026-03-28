# Findings Integration — Self-Improvement Framework

> **Purpose:** Defines how to register FND-XXXX findings for issues discovered during self-improvement execution that are OUTSIDE the target scope and cannot be fixed within the current execution. Integrates with the global findings system at `obsidian/CIH/projects/_findings/`.

---

## When to Register a Finding

Register a finding when self-improvement execution discovers a real issue in a file or component that is **outside the target scope** (Gate 6 violation boundary). Do NOT attempt to fix it — register it and continue.

| Trigger | Description |
|---|---|
| **Gate 6 violation** | Improvement identified in a file outside the declared target scope |
| **Cross-reference issue** | Target file references an external file that has its own problems |
| **Dependency issue** | Target depends on something that is itself broken or inconsistent |
| **Quality issue** | Audit or simulation reveals a problem in a component outside scope |

**What findings are NOT:**
- Round discards (within scope, reverted by safety gate — not the same as findings)
- Style preferences (findings must be real problems: bugs, gaps, protocol drift, failures)
- Improvement ideas (findings describe existing problems, not future enhancements)

---

## How to Register a Finding

### Step 1 — Read Current Counter

Open `obsidian/CIH/projects/_findings/findings-master-index.md` and read the `total_findings` field from the YAML frontmatter. The next ID is `total_findings + 1` (zero-padded to 4 digits).

Example: if `total_findings: 50`, the next finding is `FND-0051`.

### Step 2 — Generate the Hash

```bash
echo -n "FND-XXXX-short-description-slug" | sha256sum | cut -c1-8
```

Use a lowercase hyphenated slug of the description. Example: `FND-0051-missing-wikilinks-in-safety-gates`.

### Step 3 — Create the Detail File

Create `obsidian/CIH/projects/_findings/FND-XXXX.md` using the structure below. Reference `findings-template.md` for the full canonical format.

```markdown
# FND-XXXX — Short Title

| Field | Value |
|---|---|
| **Ticket** | FND-XXXX |
| **Hash** | `xxxxxxxx` |
| **Type** | CP/PL/INT |
| **Severity** | CRITICAL/HIGH/MEDIUM/LOW |
| **Source Project** | self-improvement-framework |
| **Affected Skill** | <skill or component affected> |
| **Discovered** | YYYY-MM-DD |
| **Indexed** | YYYY-MM-DD |
| **Discovered By** | Self-Improvement Framework (<agent-model>) |
| **Session Doc** | [[session-doc-link]] |
| **Status** | pending |
| **Assigned To** | — |
| **Resolved** | — |
| **Resolved By** | — |

## Description
<What was found — enough for any agent to understand without reading the original session>

## Root Cause
<Why this exists>

## Resolution Instructions
<Step-by-step how to fix it>

## Verification Criteria
<How to confirm the fix works>

## Discovery Context
Found during self-improvement execution on `<target-path>`. Out of scope for Gate 6 — target scope limited to `<scope_path>`. Not fixed during this execution.

## Wikilinks
[[projects]] | [[findings-master-index]] | [[FND-XXXX]]
```

**Type values:**
- `CP` — Cross-Project: found in target X, affects skill/project Y
- `PL` — Project-Level: found and contained within the same project
- `INT` — Internal/Self: process failure, discipline failure, agent error

### Step 4 — Update findings-master-index.md

Two locations MUST be updated in the same edit (DH-16, FND-0018 — counter sync is mandatory):

**A. YAML frontmatter** — increment `total_findings` by 1. Update `open` count as well.

**B. Findings Registry table** — add a new row:

```markdown
| [[FND-XXXX]] | `hash8chr` | CP/PL/INT | CRITICAL/HIGH/MEDIUM/LOW | Short description | Affected component | YYYY-MM-DD | YYYY-MM-DD | — | pending | — | — |
```

Both the frontmatter counters AND the Summary table must be updated in the same operation. Updating only one is a hygiene violation (FND-0018).

### Step 5 — Reference in Execution Report

In the execution report's `## Findings (Out of Scope)` section, list every finding registered:

```markdown
## Findings (Out of Scope)

| Ticket | Severity | Description | Why Out of Scope |
|---|---|---|---|
| [[FND-XXXX]] | HIGH | Short description | Discovered in `path/outside/target`, Gate 6 boundary |
```

---

## Important Rules

| Rule | Detail |
|---|---|
| **Findings persist regardless of execution outcome** | Whether the improvement round is approved or rejected, findings registered during execution remain in the master index. They are not rolled back with the worktree. |
| **Do NOT fix findings during execution** | The framework registers findings and moves on. Jimmy decides when and how to address them. Attempting to fix out-of-scope issues violates Gate 6. |
| **Findings ≠ Round Discards** | Discards are within-scope changes that failed the quality bar and were reverted. Findings are out-of-scope problems that need separate attention. These are distinct tracking mechanisms. |
| **Counter sync is non-negotiable** | Frontmatter AND Summary table in master index must both be updated atomically. See DH-16 and FND-0018. |
| **Detail file is mandatory** | Every FND-XXXX registered in the master index MUST have a corresponding `FND-XXXX.md` detail file. A row without a detail file is an incomplete registration. |
| **Wikilinks required** | Detail file must include `## Wikilinks` with `[[projects]]`, `[[findings-master-index]]`, and `[[FND-XXXX]]`. This is required for all files under `obsidian/`. |

---

## Findings vs. Discards vs. Simulation Failures — Quick Reference

| Situation | Mechanism | Scope | Tracked In |
|---|---|---|---|
| Change fails Gate 3 (score regression) | Round Discard | Within target | `rounds-log.md` |
| Change fails Gate 5 (simulation) | Round Discard | Within target | `rounds-log.md` |
| Issue found outside target scope | Finding (FND-XXXX) | Outside target | `findings-master-index.md` + `FND-XXXX.md` |
| Safety gate violated during execution | Execution Halt | Framework-level | Execution report + finding if systemic |

---

## Reference Files

| File | Purpose |
|---|---|
| `obsidian/CIH/projects/_findings/findings-master-index.md` | Global findings registry — source of truth for all FND-XXXX IDs and counters |
| `obsidian/CIH/projects/_findings/findings-template.md` | Canonical template for detail files and session doc integration |
| `obsidian/CIH/projects/_findings/FND-XXXX.md` | Individual finding detail file (one per finding) |
| `self-improvement/references/safety-gates.md` | Gate 6 definition — the scope boundary that triggers out-of-scope findings |
| `self-improvement/references/round-protocol.md` | Round flow — where findings are registered relative to round steps |

---

## Wikilinks

[[projects]] | [[skills]] | [[findings-master-index]]
