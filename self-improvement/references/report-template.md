# Report Template — Self-Improvement Framework

> **Purpose:** Template for the detailed execution report generated at the end of each execution run (Phase 4). The agent fills this template from the accumulated rounds-log, scoring data, and findings registered during the run. Saved to: `_skills/self-improvement/history/<target>/<YYYY-MM-DD>/report.md`

---

## Frontmatter

```yaml
---
title: "Self-Improvement Report — <target-name>"
date: <YYYY-MM-DD>
target: <target-path>
target_type: <skill|project|script|protocol>
rounds: <N>
score_before: <X.X>
score_after: <X.X>
delta: <+X.X%>
status: <pending-approval>
session_id: <session-uuid>
agent: <agent-name>
---
```

**Agent instructions — frontmatter:**
- `target`: full relative path from `C:\ai\` (e.g., `_skills/prompt-library`)
- `target_type`: one of `skill | project | script | protocol`
- `rounds`: total number of rounds executed (include discarded rounds in the count)
- `score_before`: composite score from the baseline snapshot (Phase 1 output)
- `score_after`: composite score after the final kept round
- `delta`: formatted as `+X.X%` (positive) or `-X.X%` (negative), calculated as `((score_after - score_before) / score_before) * 100`
- `status`: always `pending-approval` at report generation; updated to `approved` or `discarded` after Jimmy's decision
- `session_id`: UUID from the AOP session that executed this run
- `agent`: name of the orchestrator agent (e.g., `magneto`)

---

## 1. Executive Summary

> Fill this section last, after all other sections are complete. It is a compact overview of the entire run.

| Field | Value |
|-------|-------|
| Target | `<target-path>` |
| Target type | `<skill\|project\|script\|protocol>` |
| Rounds executed | `<N total>` (`<N kept>` kept, `<N discarded>` discarded, `<N lateral>` lateral) |
| Score change | `<score_before>` → `<score_after>` (`<delta>`) |
| Themes refined | `<comma-separated list of themes from rounds-log>` |
| Changes kept | `<count of KEEP decisions>` |
| Changes discarded | `<count of DISCARD decisions>` |
| Lateral rounds | `<count of KEEP(lateral) decisions>` |
| Findings registered | `<count>` (see Section 5) |
| Branch | `self-improvement/<slug>-<YYYY-MM-DD>` |
| Recommendation | `<see Recommendation Logic below>` |

**Recommendation Logic:**

| Condition | Recommendation |
|-----------|---------------|
| `delta > 5%` | **Recommend: Approve merge** |
| `0% < delta <= 5%` | **Recommend: Approve merge (marginal improvement)** |
| `delta == 0%` (all lateral or no changes kept) | **Recommend: Discard branch (no improvement)** |
| `delta < 0%` | Should not occur — rounds that worsen the score are reverted. If this appears, report a framework anomaly. |

---

## 2. Baseline Snapshot

> Transcribe the per-dimension scores recorded during Phase 1 (Baseline Scoring). These values must NOT change throughout the report — they are the immutable starting point.

| Dimension | Baseline Score | Weight | Weighted Score |
|-----------|---------------|--------|---------------|
| `<dimension-1>` | `<0.0–10.0>` | `<X%>` | `<calculated>` |
| `<dimension-2>` | `<0.0–10.0>` | `<X%>` | `<calculated>` |
| `<dimension-3>` | `<0.0–10.0>` | `<X%>` | `<calculated>` |
| `<dimension-4>` | `<0.0–10.0>` | `<X%>` | `<calculated>` |
| `<dimension-5>` | `<0.0–10.0>` | `<X%>` | `<calculated>` |
| **Composite** | — | 100% | **`<score_before>`** |

**Agent instructions — baseline snapshot:**
- Copy dimension names and weights from `scoring-model.md` for the detected target type.
- Weighted Score = `score × (weight / 100)`. Composite = sum of all weighted scores.
- If a dimension is not applicable to this target type, mark it `N/A` and redistribute weights per the scoring model rules.

---

## 3. Round Details

> One sub-section per round executed. Include every round — kept, discarded, and lateral. Sub-rounds from atomic decomposition are listed under their parent round.

---

### Round `<N>`

| Field | Value |
|-------|-------|
| Theme | `<theme name from theme-discovery>` |
| Score before | `<composite score at round start>` |
| Score after | `<composite score after changes>` |
| Delta | `<+X.X% or -X.X%>` |
| Audit gate | `PASS \| FAIL` |
| Simulation result | `PASS \| FAIL \| SKIPPED (audit failed)` |
| Decision | `KEEP \| KEEP(lateral) \| DISCARD` |
| Reason | `<one sentence: why this decision was made>` |

**Changes applied:**

- `<file-path>`: `<brief description of what was changed>`
- `<file-path>`: `<brief description of what was changed>`

**Agent instructions — round details:**
- Transcribe from `rounds-log.md`. Each entry in the log maps to one sub-section here.
- "Changes applied" must list every file modified in this round's commit.
- If the round triggered Atomic Decomposition, expand into sub-rounds (3.N.1, 3.N.2, etc.) using the same table structure.
- If the round was fully discarded (DISCARD decision with clean revert), still document it — discarded rounds are valuable audit trail.

---

## 4. Final Scores

> Per-dimension comparison between baseline (Phase 1) and final state (after last kept round). Discarded rounds do not affect final scores.

| Dimension | Baseline | Final | Delta | Movement |
|-----------|---------|-------|-------|----------|
| `<dimension-1>` | `<X.X>` | `<X.X>` | `<+/-X.X>` | `↑ \| → \| ↓` |
| `<dimension-2>` | `<X.X>` | `<X.X>` | `<+/-X.X>` | `↑ \| → \| ↓` |
| `<dimension-3>` | `<X.X>` | `<X.X>` | `<+/-X.X>` | `↑ \| → \| ↓` |
| `<dimension-4>` | `<X.X>` | `<X.X>` | `<+/-X.X>` | `↑ \| → \| ↓` |
| `<dimension-5>` | `<X.X>` | `<X.X>` | `<+/-X.X>` | `↑ \| → \| ↓` |
| **Composite** | **`<score_before>`** | **`<score_after>`** | **`<delta>`** | `↑ \| → \| ↓` |

**Agent instructions — final scores:**
- Re-score each dimension after all rounds complete, using the same scoring rubric as Phase 1.
- Movement arrows: `↑` = improved, `→` = unchanged, `↓` = worsened.
- A dimension that worsened in the final state indicates a round that was kept despite a trade-off. Document the reason in the relevant Round Detail (Section 3).

---

## 5. Findings (Out of Scope)

> Issues discovered during the improvement run that fall OUTSIDE the target scope. These are registered in the findings index and linked here. Do NOT act on them during this run — they are deferred.

| FND ID | Summary | File / Location | Severity |
|--------|---------|-----------------|----------|
| `[[FND-XXXX]]` | `<one-line description>` | `<file-path or component>` | `low \| medium \| high` |

**If no out-of-scope findings were registered:**

> No out-of-scope findings registered during this run.

**Agent instructions — findings:**
- Only register findings that are outside the target scope. Issues within the target are fixed directly.
- Each FND-XXXX must be registered in `obsidian/CIH/projects/_findings/findings-master-index.md` before listing here.
- Use the `[[FND-XXXX]]` wikilink format for all finding IDs.
- Severity guide: `low` = cosmetic/optional, `medium` = functional gap, `high` = blocking or data-loss risk.

---

## 6. Files Modified

> Complete list of all files changed across all kept rounds. Discarded round changes are NOT included (they were reverted).

| File | Change Type | Summary |
|------|------------|---------|
| `<relative-path-from-C:\ai\>` | `modified \| added \| deleted` | `<one-line summary of what changed>` |

**Agent instructions — files modified:**
- Build this list from the git log of the improvement branch: `git log --name-status self-improvement/<slug>-<date>` filtered to non-reverted commits.
- Group by file if the same file was modified in multiple rounds.
- Change type: `modified` = existing file changed, `added` = new file created, `deleted` = file removed.

---

## 7. Approval Gate

> This section is presented to Jimmy as a decision prompt. Do not fill in the decision — leave it blank for Jimmy to complete.

---

**Review summary:**

- Branch: `self-improvement/<slug>-<YYYY-MM-DD>`
- Score change: `<score_before>` → `<score_after>` (`<delta>`)
- Files modified: `<count>`
- Findings registered: `<count>`

**Recommendation: `<from Section 1 Recommendation Logic>`**

---

Do you want to approve the merge of branch `self-improvement/<slug>-<YYYY-MM-DD>` into main?

- **Approve** — merge branch, update target files in main, archive this report
- **Discard** — delete branch, no changes applied to main, archive this report with status `discarded`
- **Partial** — review individual round commits before deciding (agent will list them)

**Decision:** `<Jimmy fills this in>`

---

## Agent Instructions — General

1. **Generate this report at the end of Phase 3**, after all rounds complete and the final scoring is done.
2. **Fill every placeholder.** A report with unfilled `<placeholder>` markers is incomplete and must not be presented to Jimmy.
3. **Do not summarize or abbreviate round details.** Every round — kept, discarded, and lateral — must appear in Section 3.
4. **Section 5 (Findings) is mandatory even when empty.** Use the "no findings" note if applicable.
5. **Save path is fixed:** `_skills/self-improvement/history/<target-slug>/<YYYY-MM-DD>/report.md` where `<target-slug>` is the last path component of the target (e.g., `prompt-library` for `_skills/prompt-library`).
6. **After saving, present Section 7 to Jimmy** as the approval prompt. Do not ask for approval in chat — point Jimmy to the report file.
