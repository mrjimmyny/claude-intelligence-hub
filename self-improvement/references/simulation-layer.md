# Simulation Layer — Self-Improvement Framework

**Version:** 1.0
**Layer:** 2 — Functional Simulation
**Phase:** Testing
**Scope:** Qualitative, deep testing. Runs ONLY when the Audit Layer (Layer 1) returns PASS.
**Loaded:** Before simulation begins.

---

## Purpose

The audit layer (Layer 1) verifies structural integrity — files exist, versions sync, schema is valid. It cannot judge whether a change actually works.

The simulation layer answers the question: *does the modified target perform better under real conditions?*

A sub-agent with fresh context reads the target, scores every dimension, and runs scenario tests. The sub-agent does not know what was changed or why. This eliminates confirmation bias from the orchestrator who made the improvement.

---

## Pre-Condition

This layer MUST NOT run unless the audit layer returned PASS for the current round.

**If audit layer returned FAIL:** Halt. Return FAIL to the orchestrator. Do not proceed to simulation.

---

## Sub-Agent Execution

### What the sub-agent receives

The orchestrator passes ONLY these three inputs to the sub-agent. Nothing else.

| Input | Description |
|---|---|
| Target files | The complete set of modified files, as they currently exist in the worktree |
| Scoring dimensions and weights | The full dimension table for the target type, from `scoring-model.md` |
| Baseline scores | The per-dimension scores established during theme-discovery, for comparison |

### What the sub-agent does NOT receive

The following are withheld deliberately. Providing any of these would invalidate the simulation.

- What was changed in this round
- Why the change was made
- The orchestrator's improvement rationale
- Any notes, summaries, or context from previous phases
- The round number or execution history

**Reason for isolation:** The sub-agent must read the target as a new agent encountering it for the first time. Prior context creates bias — the sub-agent might evaluate what was *intended* rather than what is *actually present*.

---

## Simulation Procedure

### Step 1 — Read the Target as if for the First Time

The sub-agent loads all files in the target scope. It reads the full content of each file without skimming.

**Rules:**
- Do NOT skip sections that appear routine or familiar.
- Do NOT carry assumptions from other projects or skills.
- Do NOT rely on memory of previous rounds.
- If a file references another file, load that file too and trace the reference.

**Goal:** Produce a first-impression understanding of what the target is, what it does, and how to use it — exactly as a new agent would.

---

### Step 2 — Score Each Dimension

For each dimension defined in `scoring-model.md` for this target type, the sub-agent:

1. Reads the dimension definition and its weight.
2. Evaluates the target content against that criterion.
3. Assigns a score from 0.0 to 10.0.
4. Writes a 1–2 sentence justification referencing specific content (file section, rule, phrase, or structural element that drove the score).

Scores must reflect the target as read — not what the sub-agent expects it to contain.

**Scoring scale:**

| Score | Meaning |
|---|---|
| 0.0 | Criterion entirely absent or actively violated |
| 2.5 | Criterion minimally addressed; major gaps remain |
| 5.0 | Criterion partially met; notable gaps present |
| 7.5 | Criterion mostly met; minor gaps present |
| 10.0 | Criterion fully and cleanly satisfied |

---

### Step 3 — Scenario Testing

After scoring, the sub-agent runs the scenario tests for the target type. Each scenario produces a binary result (PASS or FAIL) plus a brief finding if FAIL.

#### Skill Scenarios

| ID | Scenario | Pass Condition |
|---|---|---|
| S1 | Can a new agent follow the instructions to produce correct output? | Agent can execute the skill's primary purpose from instructions alone, without external guidance |
| S2 | What happens if the agent receives ambiguous input? | Instructions address ambiguous cases explicitly, or the behavior under ambiguity is predictable and safe |
| S3 | Do the instructions work for Claude? For Codex? For Gemini? | No instruction assumes a capability unique to one agent platform; cross-agent behavior is consistent |
| S4 | Are there situations where two rules contradict each other? | No two rules in scope produce conflicting required behaviors for the same situation |

#### Script Scenarios

| ID | Scenario | Pass Condition |
|---|---|---|
| S1 | Does the script handle missing input gracefully? | Script exits with a non-zero code and a human-readable error message when required input is absent |
| S2 | Does it work on Windows (Git Bash) and Linux? | No bash-isms, path separators, or commands that are platform-specific without explicit guards |
| S3 | What if a dependency is unavailable? | Script detects missing dependency and exits with a clear error before attempting execution |
| S4 | Does it handle edge cases (empty files, missing dirs, special characters)? | All three edge cases produce defined behavior; no silent corruption or unhandled errors |

#### Project Scenarios

| ID | Scenario | Pass Condition |
|---|---|---|
| S1 | Can a new agent understand the project status in under 60 seconds? | `status-atual.md` alone conveys current phase, last action, and blockers without requiring cross-file reading |
| S2 | Are all cross-references valid and navigable? | Every wikilink, file path, and FND-XXXX reference in scope points to a file that exists |
| S3 | Is there any stale information? | No dates, versions, or status labels contradict the current state of the target files |
| S4 | Can an outsider find the next action without reading everything? | `next-step.md` or equivalent contains a clear, unambiguous next action |

#### Protocol Scenarios

| ID | Scenario | Pass Condition |
|---|---|---|
| S1 | Can an agent follow the protocol without creative interpretation? | Every step has a defined input, defined output, and defined success condition — no step requires judgment not grounded in the protocol text |
| S2 | Are all edge cases covered? | Every conditional path described in the protocol leads to a defined outcome; no branch ends with undefined behavior |
| S3 | Is the flow logically sequential with no circular references? | Steps are ordered; no step depends on a later step; no two steps mutually depend on each other |
| S4 | Would two different agents interpret this the same way? | Ambiguous phrases ("as appropriate", "if needed", "usually") are absent or explicitly scoped |

---

### Step 4 — Determine Result

#### Calculate New Composite Score

Using the per-dimension scores from Step 2 and the weights from `scoring-model.md`:

```
composite_score = sum(dimension_score * weight) for all dimensions
```

#### Calculate Delta

```
delta = new_composite_score - baseline_composite_score
```

#### Apply Pass/Fail Rule

| Condition | Result |
|---|---|
| `new_composite_score >= baseline_composite_score` | PASS |
| `new_composite_score < baseline_composite_score` | FAIL |

**Note on scenario failures:** Individual scenario failures (Step 3) are reported as findings but do not automatically override the composite score comparison. However, if a scenario failure represents a regression — the target now fails a scenario it previously passed — that finding must be flagged explicitly in the output. The orchestrator may treat a regression finding as a FAIL even if the composite score passed.

---

## Output Format

The sub-agent returns a single structured report to the orchestrator.

```
## Simulation Layer — Round <N> Result

Result: PASS | FAIL

### Scores

| Dimension | Baseline | New Score | Delta |
|---|---|---|---|
| <dimension-1> | <baseline> | <new> | <+/-> |
| <dimension-2> | <baseline> | <new> | <+/-> |
| ...           | ...        | ...   | ...   |

Composite: <baseline> → <new> (delta: <+/->)

### Dimension Justifications

**<dimension-1> — <new score>**
<1–2 sentence justification referencing specific content.>

**<dimension-2> — <new score>**
<1–2 sentence justification referencing specific content.>

[repeat for all dimensions]

### Scenario Results

| ID | Scenario | Result | Finding |
|---|---|---|---|
| S1 | <scenario text> | PASS / FAIL | <brief finding if FAIL, else —> |
| S2 | <scenario text> | PASS / FAIL | <brief finding if FAIL, else —> |
| S3 | <scenario text> | PASS / FAIL | <brief finding if FAIL, else —> |
| S4 | <scenario text> | PASS / FAIL | <brief finding if FAIL, else —> |

### Regressions

[List any scenario that previously passed and now fails. If none: "None."]

### Additional Findings

[Issues observed during simulation that are not captured in scores or scenarios.
These may be in-scope weaknesses or out-of-scope observations.
If none: "None."]
```

---

## Failure Handling

| Failure Mode | Behavior |
|---|---|
| Audit layer returned FAIL | Do not run simulation. Return FAIL immediately. |
| Sub-agent cannot read all target files | STOP. Report which files were inaccessible. Do not produce partial scores. |
| Scoring is incomplete (one or more dimensions missing) | STOP. Report missing dimensions. Do not calculate composite from partial set. |
| Sub-agent receives context about what was changed (isolation breach) | STOP. Flag isolation breach. Results from this sub-agent invocation are invalid. |
| Composite score is lower than baseline | Return FAIL. Include full scores, delta, and findings in the report. |

---

## Reference

- Scoring model and dimension tables: `self-improvement/references/scoring-model.md`
- Audit layer (Layer 1): `self-improvement/references/audit-layer.md`
- Safety gates: `self-improvement/references/safety-gates.md`
- Framework design spec: `self-improvement/design-spec.md`
