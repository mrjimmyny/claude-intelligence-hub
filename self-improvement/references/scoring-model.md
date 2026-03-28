# Scoring Model — Self-Improvement Framework

**Version:** 1.0
**Scope:** Defines how improvement is measured across all target types.
**Loaded:** Before rounds begin and during each round for score calculation.

---

## Scoring Dimensions by Target Type

### Skill

| Dimension | Weight | What it evaluates |
|---|---|---|
| Structural integrity | 20% | Required files, version sync, .metadata |
| Instruction clarity | 25% | Agent can execute without ambiguity? |
| Edge case coverage | 20% | Invalid inputs, unforeseen scenarios |
| Internal consistency | 15% | Contradictions between sections, conflicting rules |
| Cross-agent compatibility | 20% | Works equally in Claude, Codex, Gemini? |

Total: 100%

---

### Script

| Dimension | Weight | What it evaluates |
|---|---|---|
| Clean execution | 25% | Correct exit codes, no silent errors |
| Error handling | 25% | Failures handled, clear messages |
| Cross-platform | 20% | Windows (Git Bash) + Linux |
| Maintainability | 15% | Readability, comments where needed |
| Integration | 15% | Works in the context where it's called |

Total: 100%

---

### Project

| Dimension | Weight | What it evaluates |
|---|---|---|
| Documental completeness | 30% | All operational docs exist and are filled |
| Cross-doc consistency | 25% | status-atual matches next-step, decisoes, portfolio |
| Traceability | 20% | Wikilinks, session refs, findings linked |
| Status clarity | 15% | Outsider can understand where the project stands? |
| Hygiene | 10% | No orphan files, no abandoned drafts |

Total: 100%

---

### Protocol

| Dimension | Weight | What it evaluates |
|---|---|---|
| Clarity | 30% | Unambiguous instructions, logical flow |
| Completeness | 25% | Covers all expected scenarios |
| Consistency | 25% | No internal contradictions |
| Applicability | 20% | Agent can follow without creative interpretation |

Total: 100%

---

## Score Calculations

### Composite Score

```
composite_score = sum(dimension_score * weight) for all dimensions
```

- Each `dimension_score` is a value from **0.0 to 10.0**
- Weights are the decimals defined above (e.g., 25% = 0.25)
- Final `composite_score` range: **0.0 to 10.0**

**Example (Skill target):**

```
composite_score =
  (structural_integrity * 0.20) +
  (instruction_clarity  * 0.25) +
  (edge_case_coverage   * 0.20) +
  (internal_consistency * 0.15) +
  (cross_agent_compat   * 0.20)
```

---

### Improvement Percentage

```
delta_percent = ((final_score - baseline_score) / baseline_score) * 100
```

**Edge case — baseline is zero:**

```
if baseline_score == 0:
    report "N/A — absolute improvement to {final_score}"
```

---

## Score Interpretation Guide

| Range | Label | Meaning |
|---|---|---|
| 0.0 – 3.0 | Poor | Fundamental issues; needs immediate attention |
| 3.1 – 5.0 | Below Average | Significant gaps; multiple rounds likely needed |
| 5.1 – 7.0 | Needs Work | Functional but with clear room for improvement |
| 7.1 – 8.0 | Good | Solid foundation; minor improvements possible |
| 8.1 – 9.0 | Very Good | Well-built; only refinements needed |
| 9.1 – 10.0 | Excellent | Mature target; marginal gains expected |

---

## Lateral Changes

A **lateral change** occurs when a round produces a composite score delta of exactly 0.

**Rules:**

- **Decision:** KEEP — the round did not worsen the target
- **Flag:** Mark the round entry as `lateral: true` in the rounds-log
- **Report:** Highlight the lateral result for Jimmy's review during the approval step
- A lateral round still counts as a completed round (no automatic retry)
- If two or more consecutive rounds are lateral, the improvement plan should flag diminishing returns

---

## Scoring Protocol for Agents

Follow these steps for every dimension in a round:

1. **Read the target.** Load the file(s) that constitute the target in full. Do not rely on session memory or prior context.

2. **Read the dimension definition.** Use the table above for the target type to identify the exact criterion being evaluated.

3. **Evaluate the criterion against the target content.** Ask: does the target satisfy the criterion fully, partially, or not at all?

4. **Assign a score (0.0 – 10.0).**
   - 0.0 = criterion is entirely absent or violated
   - 5.0 = criterion is partially met with notable gaps
   - 10.0 = criterion is fully and cleanly satisfied

5. **Write a 1–2 sentence justification.** State what was found (or missing) that drove the score. Be specific — reference file sections, line content, or behaviors observed.

6. **Record in the round log.** Each dimension must have: `dimension`, `score`, `justification`.

7. **Calculate composite score** using the formula above after all dimensions are scored.

8. **Calculate delta** against the baseline score from the improvement plan.

9. **Apply the interpretation label** from the guide above.

10. **Flag lateral if delta == 0** and mark accordingly in the round log.

---

## Reference

- Improvement plan schema: `self-improvement/references/improvement-plan-schema.md`
- Rounds log format: `self-improvement/references/rounds-log-schema.md`
- Framework design spec: `self-improvement/design-spec.md`
