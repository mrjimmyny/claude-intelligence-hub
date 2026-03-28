# History Protocol — Self-Improvement Framework

**Phase:** 4 — Report
**Loaded:** End of every execution, after rounds are complete and approval decision is made.

---

## Purpose

Defines how execution history is recorded so that improvement trends are auditable across sessions and agents. Every execution leaves a trace — including rejections and zero-delta runs.

---

## Directory Structure

```
_skills/self-improvement/history/
  index.md                              # Dashboard across all targets
  <target-slug>/
    changelog.md                        # Executive: one line per execution
    <YYYY-MM-DD>/
      report.md                         # Detailed execution report
      scores.md                         # Per-dimension scores before/after
      rounds-log.md                     # Round-by-round log
```

`<target-slug>` is the kebab-case identifier of the target (e.g., `bi-designerx-gemini-prompt`).
`<YYYY-MM-DD>` is the execution date in Brazilian timezone (America/Sao_Paulo).

---

## Templates

### index.md

```markdown
# Self-Improvement Index

| Target | Type | Last Score | Trend | Last Run | Total Runs | Cumulative Delta |
|--------|------|-----------|-------|----------|------------|-----------------|
```

**Trend values:**
- `↑` — improving (last delta positive)
- `→` — stable (last delta zero)
- `↓` — regressing (last delta negative)

**Notes:**
- One row per target.
- `Last Score` = score after last approved execution (or last run if none approved).
- `Cumulative Delta` = sum of all approved deltas across all executions for this target.
- `Total Runs` = count of all executions including rejected and no-change.

---

### changelog.md

```markdown
# Self-Improvement History — <target-name>

| Date | Rounds | Version | Score Before | Score After | Delta | Status | Session |
|------|--------|---------|-------------|-------------|-------|--------|---------|
```

**Status values:**
- `Approved` — execution accepted and artifact updated.
- `Rejected` — execution completed but Jimmy rejected the changes.
- `No-Change` — execution completed, delta was 0, no artifact update needed.

**Notes:**
- This file is append-only. Never remove or edit existing rows.
- `Version` = artifact version after this execution (e.g., `v2.1`). For rejected runs, use the pre-execution version.
- `Session` = session doc date or identifier (e.g., `2026-03-28`).

---

### scores.md

```markdown
# Scores — <target-name> — <YYYY-MM-DD>

| Dimension | Weight | Before | After | Delta |
|-----------|--------|--------|-------|-------|
```

**Notes:**
- List all dimensions from the target's rubric.
- `Before` = score from the pre-execution eval (Phase 1).
- `After` = score from the post-execution eval (Phase 3).
- `Delta` = After − Before (can be negative).
- Include a `**Total**` row at the bottom with weighted aggregate scores.

---

### rounds-log.md

```markdown
# Rounds Log — <target-name> — <YYYY-MM-DD>

| Round | Theme | Score Before | Score After | Delta | Decision | Reason |
|-------|-------|-------------|-------------|-------|----------|--------|
```

**Notes:**
- One row per round attempted.
- `Theme` = the improvement focus for that round (e.g., "Clarity", "Completeness").
- `Decision` = `Kept` or `Reverted`.
- `Reason` = brief justification for the decision (one sentence max).

---

## Recording Rules

1. **Every execution is recorded** — including 0-delta runs and rejected executions.
2. **Rejected executions** use `Rejected` in the `Status` column of changelog.md; scores and rounds-log still reflect what was attempted.
3. **0-delta executions** use `No-Change` in the `Status` column of changelog.md.
4. **Findings persist regardless of approval status** — if a finding was raised during execution, it stays in the report.
5. **changelog.md is append-only** — never remove or modify existing rows. Only add new rows at the bottom.
6. **index.md is updated in-place** — update the target's row, or add a new row if the target is new.

---

## Procedure (Agent Step-by-Step)

Execute these steps after all rounds complete and the approval decision is received.

**Step 1 — Read templates**
Re-read this file to confirm template format before writing any files.

**Step 2 — Resolve paths**
- `HISTORY_ROOT` = `C:\ai\_skills\self-improvement\history\`
- `TARGET_DIR` = `HISTORY_ROOT/<target-slug>/`
- `DATE_DIR` = `TARGET_DIR/<YYYY-MM-DD>/`

**Step 3 — Create directories if needed**
- If `TARGET_DIR` does not exist, create it and create `changelog.md` using the template.
- Create `DATE_DIR` for this execution.

**Step 4 — Write execution files**
Write the following files inside `DATE_DIR`:
- `report.md` — full narrative: target, rubric used, rounds attempted, final outcome, findings (if any), decision rationale.
- `scores.md` — per-dimension scores table (before/after/delta for each dimension + weighted total).
- `rounds-log.md` — round-by-round table.

**Step 5 — Update changelog.md**
Append one row to `TARGET_DIR/changelog.md` with execution summary.

**Step 6 — Update index.md**
Update `HISTORY_ROOT/index.md`:
- If the target already has a row, update it in-place (Last Score, Trend, Last Run, Total Runs, Cumulative Delta).
- If the target is new, append a new row.

**Step 7 — Verify**
Confirm all 5 files exist (report.md, scores.md, rounds-log.md, changelog.md updated, index.md updated) before reporting Phase 4 complete.

---

## Wikilinks

[[self-improvement]] [[skills]]
