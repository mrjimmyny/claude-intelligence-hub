# Round Protocol — Self-Improvement Framework

> **Purpose:** Orchestrates a single improvement round. Loaded at the start of each round during Phase 3 (Improvement Loop).

---

## Single Round Flow

### Step 1: SNAPSHOT

Record the current composite score as the round baseline before any changes are applied.

- Read the current composite score from `rounds-log.md` (last recorded entry) or from the scoring layer output.
- Store as `score_before` for this round.
- Do not proceed without a numeric baseline.

---

### Step 2: APPLY

Apply the thematic improvement package for this round.

1. Read ALL target files from disk (not from cache or prior context).
2. Identify all improvements aligned to this round's theme.
3. Apply the full set of changes as a coherent, atomic package.
4. Commit using the convention:

```
improvement(<target-slug>): <theme> - round N
```

Example: `improvement(prompt-library): clarity - round 3`

Do not apply partial packages. The commit must represent a complete, coherent improvement unit.

---

### Step 3: AUDIT GATE (Layer 1)

Dispatch a sub-agent loaded with `audit-layer.md`.

The audit layer performs structural validation: completeness, internal consistency, format compliance, and schema correctness.

| Result | Action |
|--------|--------|
| PASS   | Proceed to Step 4 (Simulation) |
| FAIL   | Trigger Atomic Decomposition Protocol (see below) |

**Rule:** Never skip this gate. If the audit fails, simulation does not run. This saves tokens and prevents compounding errors.

---

### Step 4: SIMULATION (Layer 2)

Dispatch a sub-agent loaded with `simulation-layer.md`.

The simulation layer performs functional validation: behavioral correctness, edge case handling, and real-world scenario testing.

| Result | Action |
|--------|--------|
| PASS   | Proceed to Step 5 (Decide) |
| FAIL   | Trigger Atomic Decomposition Protocol (see below) |

---

### Step 5: DECIDE

Compare the new composite score against the round baseline (`score_before`).

| Outcome | Condition | Action |
|---------|-----------|--------|
| KEEP | Score improved | Commit remains. Proceed to Step 6. |
| KEEP (lateral) | Score equal | Commit remains. Flag as "lateral" in rounds-log. A change that improves clarity without altering the composite score is still valuable. |
| DISCARD | Score worsened | Revert: `git reset --hard HEAD~1`. Proceed to Step 6. |

---

### Step 6: LOG

Record the completed round in `rounds-log.md`:

| Field | Value |
|-------|-------|
| Round | N |
| Theme | e.g., "clarity", "edge-case coverage", "schema compliance" |
| Score before | Numeric composite score at round start |
| Score after | Numeric composite score after changes |
| Delta | Percentage change (positive = improved) |
| Decision | KEEP / KEEP(lateral) / DISCARD |
| Reason | One sentence explaining the decision |

---

## Atomic Decomposition Protocol

Triggered when a thematic package FAILS the audit gate (Step 3) or the simulation gate (Step 4).

**When to invoke:** The full package as a unit cannot pass validation. Individual changes may still be valid.

**Procedure:**

1. Revert the package commit:
   ```
   git reset --hard HEAD~1
   ```

2. Decompose the package into individual, isolated changes.

3. Apply each change as a separate sub-round:
   - a. Apply the single change and commit using the sub-round convention:
     ```
     improvement(<target-slug>): <theme> - round N.M
     ```
     Example: `improvement(prompt-library): clarity - round 3.1`
   - b. Run the audit gate (Step 3) on this single change.
   - c. If audit PASS → run simulation (Step 4).
   - d. If simulation PASS → KEEP the sub-round commit.
   - e. If audit FAIL or simulation FAIL → revert: `git reset --hard HEAD~1`.

4. Repeat for all decomposed changes. Each sub-round is independent.

5. **Maximum attempts:** 2 decomposition attempts per package. After the second attempt, if any change still cannot pass, do not retry.

6. **Escalation:** If the package or its decomposed changes still fail after 2 attempts, register the failure as a finding in the findings index and move to the next theme. Do not stall the improvement loop.

---

## Between Rounds

Before starting the next round:

1. **Re-read ALL target files from disk.** Do not use cached content or context from the current session window. Accumulated changes from previous rounds must be reflected in what you read.
2. Retrieve the updated composite score from the most recent `rounds-log.md` entry.
3. This updated score becomes `score_before` for the next round (Step 1).

**Why this matters:** Each round builds on the previous. Reading stale content will cause the agent to re-apply changes already committed, creating conflicts and false deltas.

---

## Commit Conventions

| Type | Format |
|------|--------|
| Full improvement package | `improvement(<target-slug>): <theme> - round N` |
| Sub-round (atomic decomposition) | `improvement(<target-slug>): <theme> - round N.M` |
| Revert | Standard git revert message (auto-generated) |

---

## Round Rules

1. **Never skip the audit gate.** Audit FAIL blocks simulation. This is intentional — structural errors invalidate simulation results.

2. **Score equal = KEEP, flagged as lateral.** Clarity improvements, structural cleanups, and readability gains that do not move the composite score are still worth keeping. Lateral rounds accumulate value over time.

3. **Maximum 2 decomposition attempts.** If a package cannot pass after decomposition, register as a finding and move on. Do not enter an infinite retry loop.

4. **Each round is a commit.** Git is the memory of the improvement loop. Every round leaves a traceable record — whether kept or discarded.

5. **Revert is not failure.** A DISCARD decision with a clean revert is the correct behavior when a change worsens the composite score. The system is working as designed.
