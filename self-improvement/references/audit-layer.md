# Audit Layer — Self-Improvement Framework

> **Layer 1 of 2.** This is the mechanical gate. It runs BEFORE simulation and is a hard prerequisite. If any audit check fails, the simulation layer does NOT run. There is no bypass, no exception, and no partial pass.

---

## Purpose

The audit layer validates that a proposed improvement is structurally and syntactically sound before any behavioral testing occurs. It catches objective failures — missing files, syntax errors, broken references, version mismatches — that would make simulation results meaningless.

**What this layer tests:** Structure, presence, syntax, consistency.
**What this layer does NOT test:** Behavioral correctness, semantic quality, runtime behavior. That is the simulation layer's job.

---

## Sub-Agent Execution — MANDATORY

This layer MUST be executed by a sub-agent with fresh context. The sub-agent is spawned by the orchestrator after the improvement phase completes.

### What the sub-agent receives

The sub-agent receives ONLY:
- The modified files (post-improvement, from the worktree)
- The audit checklist for the detected target type (one of the four below)

### What the sub-agent does NOT receive

The sub-agent does NOT receive:
- The improvement rationale
- The orchestrator's reasoning or analysis
- Any context from the improvement phase
- The original (pre-improvement) file contents
- Any scoring or simulation results from prior rounds

**Why:** Fresh context eliminates confirmation bias. An auditor that knows WHY a change was made is more likely to rationalize failures as acceptable. The sub-agent must evaluate only what is in front of it.

---

## Gate Behavior

- ALL checks in the applicable checklist must pass for an overall PASS result.
- ANY single check failure = overall FAIL. There is no partial pass, no weighted scoring, no "mostly ok."
- A FAIL result triggers atomic decomposition in the round protocol: the orchestrator breaks the improvement into smaller units and re-runs from the improvement phase.
- A PASS result gates entry to the simulation layer. The orchestrator proceeds to Layer 2.

---

## Audit Checklists

Run the checklist that matches the target type. Target type is determined by `target-detection.md` before this layer executes.

---

### Checklist A — Skill

Apply when the target type is `skill`.

| ID | Check | How to Verify | PASS Condition |
|----|-------|---------------|----------------|
| A1 | SKILL.md exists | File presence check | File exists and is non-empty |
| A2 | .metadata exists | File presence check | File exists and is valid JSON |
| A3 | Version sync | Compare `version` field in `.metadata` with the `**Version:**` line in SKILL.md | Values match exactly |
| A4 | References exist | Read all filenames listed in SKILL.md under `references/` or any file-list section; check filesystem presence | All listed files present in `references/` |
| A5 | No broken wikilinks | Scan all modified `.md` files for `[[...]]` patterns; resolve each target relative to `obsidian/` | All targets resolve to existing files |
| A6 | No internal contradictions | Scan SKILL.md for conflicting instructions (e.g., two rules that cannot both be true, a step that contradicts a later step) | No conflicts found |
| A7 | Markdown valid | Parse all modified `.md` files: check for unclosed code fences (` ``` `), broken table rows (column count mismatch), orphan headers (no content between H2s) | Clean parse — no malformed constructs |

---

### Checklist B — Script

Apply when the target type is `script`.

| ID | Check | How to Verify | PASS Condition |
|----|-------|---------------|----------------|
| A1 | Syntax valid | Run language-appropriate syntax check: `bash -n <file>` for shell scripts, `python -m py_compile <file>` for Python, `node --check <file>` for JavaScript | Exit code 0 |
| A2 | No hardcoded paths | Grep for absolute paths (e.g., `/c/ai/`, `C:\ai\`, `/Users/`) that are not assigned to a clearly named variable | None found, or each instance is justified by a comment |
| A3 | Exit codes used | Grep for `exit`, `return`, `sys.exit`, or `process.exit` statements | At least one present |
| A4 | Error handling present | Grep for `set -e`, `set -o errexit`, `try/except`, `trap`, `.catch(`, `|| exit` | At least one error-handling construct present |
| A5 | No TODO/FIXME markers | Grep for `TODO`, `FIXME`, `HACK`, `XXX` (case-insensitive) | None found |
| A6 | Consistent style | Scan for mixed indentation (tabs vs. spaces in the same file); scan for naming convention violations (e.g., camelCase mixed with snake_case in the same scope) | Consistent throughout |

---

### Checklist C — Project

Apply when the target type is `project`.

| ID | Check | How to Verify | PASS Condition |
|----|-------|---------------|----------------|
| A1 | PROJECT_CONTEXT.md exists | File presence check | Exists and is non-empty |
| A2 | status-atual.md exists | File presence check | Exists and is non-empty |
| A3 | next-step.md exists | File presence check | Exists and is non-empty |
| A4 | decisoes.md exists | File presence check | Exists and is non-empty |
| A5 | Wikilinks section present | Scan each of the four required docs for a `## Wikilinks` section | All four docs contain the section |
| A6 | No broken wikilinks | Scan all `[[...]]` patterns in all four docs; resolve each target relative to `obsidian/` | All targets resolve to existing files |
| A7 | No stale dates | Read `Last Update:` or `updated:` frontmatter fields in all four docs | All dates are within 30 days of today |

---

### Checklist D — Protocol

Apply when the target type is `protocol`.

| ID | Check | How to Verify | PASS Condition |
|----|-------|---------------|----------------|
| A1 | File is non-empty | File presence and size check | File exists and contains at least one non-whitespace character |
| A2 | Headers properly structured | Parse heading hierarchy: H1 must appear exactly once (at the top); H2s may appear multiple times; no heading level skips (e.g., H1 → H3 with no H2) | Valid hierarchy — no skips, exactly one H1 |
| A3 | No broken internal links | Scan for cross-references within the file (Markdown links `[text](#anchor)`, wikilinks `[[...]]`); verify all anchors and targets exist | All internal references resolve |
| A4 | No TODO/FIXME markers | Grep for `TODO`, `FIXME`, `TBD`, `PLACEHOLDER` (case-insensitive) | None found |
| A5 | Markdown valid | Check for unclosed code fences, broken table rows (column count mismatch), orphan headers | Clean parse — no malformed constructs |

---

## Output Format

The sub-agent returns a structured result to the orchestrator. No other format is accepted.

### On PASS

```
RESULT: PASS
All <N> checks passed. Proceed to simulation layer.
```

### On FAIL

```
RESULT: FAIL
Failed checks:
- <ID>: <description of failure>
- <ID>: <description of failure>

Simulation layer: BLOCKED
```

**Failure description format:** Must name the check ID, state what was found, and (where applicable) state what was expected.

Examples of well-formed failure descriptions:
- `A3: version mismatch — .metadata says 4.2.0, SKILL.md says 4.1.0`
- `A1: syntax error — bash -n returned exit code 1 on line 47: unexpected token 'fi'`
- `A5: broken wikilink — [[agent-orchestration-protocol]] not found under obsidian/`
- `A7: no stale date check possible — decisoes.md has no Last Update field`

---

## Relationship to Other Layers

| Layer | Name | Runs When |
|-------|------|-----------|
| Layer 1 | Audit (this file) | Always first. Blocks Layer 2 on failure. |
| Layer 2 | Simulation | Only if Layer 1 PASS. |

If the audit passes and simulation fails, the orchestrator uses simulation results to guide the next improvement attempt. The audit does not re-run between simulation rounds unless files change.

See `safety-gates.md` for execution isolation rules that apply to both layers.

---

## Wikilinks

[[self-improvement]]
[[skills]]
