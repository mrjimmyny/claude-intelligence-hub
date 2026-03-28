# Theme Discovery — Self-Improvement Framework

**Version:** 1.0
**Scope:** Identifies improvement themes ordered by priority for the active target. Executed once in Phase 2 (Discovery), before any round begins.
**Loaded by:** Orchestrator agent at Phase 2 entry, after target detection is complete.

---

## Overview

Theme discovery converts raw target analysis into an ordered list of actionable improvement themes. The output of this procedure is the sole input the orchestrator uses to schedule rounds.

---

## Step 1 — Read Target

Read ALL files within the target scope. Do not rely on session memory, prior context, or cache.

For **directory targets:** enumerate every file in the directory tree. Read each file in full.

For **file targets:** read the single target file in full.

While reading, note the following for each file:

- **Content quality observations** — what is clear, complete, and well-structured.
- **Potential issues** — ambiguous language, missing sections, contradictions, error-prone patterns.
- **Strengths** — what is already working well (these dimensions may score 9.0+ and be skipped in rounds).

Do not score during this step. Reading and observation only.

---

## Step 2 — Calculate Baseline Score

Using the scoring dimensions from `scoring-model.md` for the detected target type, evaluate each dimension against what was read in Step 1.

**For each dimension:**

1. Evaluate the criterion against the target content. Ask: does the target satisfy this criterion fully, partially, or not at all?
2. Assign a score from **0.0 to 10.0**.
   - `0.0` = criterion is entirely absent or violated
   - `5.0` = criterion is partially met with notable gaps
   - `10.0` = criterion is fully and cleanly satisfied
3. Write a 1–2 sentence justification that references specific file sections, content, or behaviors observed.

**Calculate composite score:**

```
composite_score = sum(dimension_score × weight) for all dimensions
```

Use the weights defined in `scoring-model.md` for the detected target type.

Record the result as the **baseline snapshot**:

```
Baseline Snapshot
-----------------
Target:     <path>
Type:       <skill | script | project | protocol>
Date:       <YYYY-MM-DD>

Dimensions:
  <dimension-name>: <score> — <1–2 sentence justification>
  ...

Composite: <X.X>
Label:     <Poor | Below Average | Needs Work | Good | Very Good | Excellent>
```

This snapshot becomes the `baseline_score` referenced in every subsequent round log.

---

## Step 3 — Read History (if exists)

Check for a history file at:

```
_skills/self-improvement/history/<target-slug>/changelog.md
```

Where `<target-slug>` is the slugified target path (same format as the branch slug from target detection).

**If the file exists:**

- Identify all themes previously refined and their round outcomes.
- Note the historical score trend (improving, plateauing, regressing).
- Flag any dimension that reached **9.0 or above** in a prior run. These dimensions are candidates for skip in the current run.

**If the file does not exist:**

- This is the first execution for this target. No history to load. Proceed to Step 4.

**Skip rule:** A dimension scoring 9.0+ in the baseline calculated in Step 2 is automatically excluded from the theme list, regardless of history. Do not schedule a round for a dimension that is already excellent.

---

## Step 4 — Identify Themes by Gap

For each dimension scoring **below 9.0** in the baseline, map the dimension to its theme name using the catalog for the detected target type (see Theme Catalogs below). Calculate the gap:

```
gap = 10.0 − dimension_score
```

---

## Step 5 — Order by Priority

Sort all identified themes by gap, largest gap first. This is the round schedule. Ties are broken by the dimension weight defined in `scoring-model.md` — the higher-weighted dimension is scheduled first.

**Output the ordered theme list** in this format:

```
- T1: <theme-name> (score: X.X, gap: Y.Y)
- T2: <theme-name> (score: X.X, gap: Y.Y)
- ...
- Baseline composite: X.X
```

This list is the sole input the orchestrator uses to schedule rounds. Do not add commentary, caveats, or alternative orderings. The list is definitive.

---

## Theme Catalogs

### Skill Themes

| Dimension | Theme Name | What to Improve |
|---|---|---|
| Structural integrity | `structure` | Missing files, broken refs, version drift |
| Instruction clarity | `clarity` | Ambiguous instructions, unclear flow |
| Edge case coverage | `edge-cases` | Unhandled scenarios, missing error guidance |
| Internal consistency | `consistency` | Contradictions, conflicting rules |
| Cross-agent compatibility | `cross-agent` | Platform-specific assumptions, missing adaptations |

### Script Themes

| Dimension | Theme Name | What to Improve |
|---|---|---|
| Clean execution | `execution` | Exit codes, silent errors, output format |
| Error handling | `error-handling` | Missing traps, unclear error messages |
| Cross-platform | `portability` | Windows/Linux differences, path handling |
| Maintainability | `readability` | Variable names, comments, structure |
| Integration | `integration` | Context assumptions, dependency handling |

### Project Themes

| Dimension | Theme Name | What to Improve |
|---|---|---|
| Documental completeness | `completeness` | Missing docs, empty sections |
| Cross-doc consistency | `consistency` | Status mismatches across docs |
| Traceability | `traceability` | Missing wikilinks, broken references |
| Status clarity | `status-clarity` | Unclear current state |
| Hygiene | `hygiene` | Orphans, drafts, stale content |

### Protocol Themes

| Dimension | Theme Name | What to Improve |
|---|---|---|
| Clarity | `clarity` | Ambiguous language, unclear steps |
| Completeness | `completeness` | Missing scenarios, gaps |
| Consistency | `consistency` | Contradictions, conflicting rules |
| Applicability | `applicability` | Requires creative interpretation |

---

## Output Example

For a Skill target after evaluation:

```
- T1: edge-cases (score: 5.5, gap: 4.5)
- T2: cross-agent (score: 6.0, gap: 4.0)
- T3: clarity (score: 7.0, gap: 3.0)
- T4: structure (score: 8.5, gap: 1.5)
[consistency skipped — score 9.2, above threshold]
- Baseline composite: 7.1
```

Themes are consumed by the orchestrator in T1 → TN order. Each theme maps to one round. The orchestrator does not reorder themes after this point.

---

## Edge Cases

**All dimensions at 9.0+:** If every dimension scores 9.0 or above, output:

```
No themes identified — all dimensions at 9.0+.
Baseline composite: X.X
Recommendation: target is at excellent baseline. No rounds scheduled.
```

The orchestrator halts Phase 2 and reports to Jimmy. No rounds are created.

**Single-dimension target:** Protocols have four dimensions; any target type may produce a one-theme list. A one-item theme list is valid — proceed with a single round.

**Unknown target type:** Do not attempt discovery. Theme catalogs are type-specific. If the target type is Unknown (from target detection), this procedure is blocked. Resolution must come from the operator before discovery runs.

---

## Reference

- Target detection procedure: `self-improvement/references/target-detection.md`
- Scoring model and dimension weights: `self-improvement/references/scoring-model.md`
- Improvement plan schema: `self-improvement/references/improvement-plan-schema.md`
- Rounds log format: `self-improvement/references/rounds-log-schema.md`
- Framework design spec: `self-improvement/design-spec.md`
