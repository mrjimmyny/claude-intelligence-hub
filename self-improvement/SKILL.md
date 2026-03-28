---
name: self-improvement
description: Agent-agnostic iterative refinement framework for skills, projects, scripts, and protocols. Two-layer testing (audit + simulation), worktree isolation, scoring with historical tracking.
version: 1.0.0
command: /self-improvement
aliases: [/improve, /refine, /self-improve]
triggers:
  - self-improvement
  - improve this skill
  - refine this
  - run self-improvement on
---

# Self-Improvement Framework

**Version:** 1.0.0
**Type:** Improvement Framework
**Tier:** On-Demand (Tier 3)
**Slash Command:** `/self-improvement`
**Owner:** Claude Intelligence Hub
**Author:** Magneto + Jimmy

---

## Invocation Syntax

```
/self-improvement <target-path> [--rounds N] [--theme <theme>]
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `<target-path>` | Yes | — | Relative path from `C:\ai\` to the target directory or file. Must resolve to an existing path on disk. |
| `--rounds N` | No | `5` | Maximum number of improvement rounds to execute. Each round addresses one theme. Range: 1–10. |
| `--theme <theme>` | No | `auto` | Force a specific theme (e.g., `clarity`, `edge-cases`). When set, this theme is prioritized first in the round schedule. When `auto`, themes are ordered by gap analysis. |

### Examples

**Skill (directory):**
```
/self-improvement claude-intelligence-hub/agent-orchestration-protocol
```

**Project (directory):**
```
/self-improvement obsidian/CIH/projects/hr_kpis_board --rounds 3
```

**Script (file):**
```
/self-improvement _skills/daily-doc-information/scripts/checkpoint-verify.sh --theme error-handling
```

**Protocol (file):**
```
/self-improvement claude-intelligence-hub/references/project-planning-methodology-guide-v1.0.md --rounds 3
```

---

## What This Framework Is (and Is NOT)

### IS

- An **iterative improvement engine** that refines any skill, project, script, or protocol through structured rounds of analysis, modification, and testing.
- **Isolated** — all work happens in a git worktree. Main is never touched until explicit approval.
- **Two-layer tested** — every change passes a mechanical audit gate (Layer 1) and a functional simulation gate (Layer 2), each executed by a separate sub-agent with fresh context.
- **Scored** — improvement is measured via weighted dimensions specific to each target type, producing a composite score before and after.
- **Approval-gated** — the framework presents results and STOPS. Merge requires explicit human authorization.
- **Agent-agnostic** — any LLM agent that can read markdown and execute git commands can run this framework.

### IS NOT

- **Not AutoResearch.** AutoResearch targets scalar performance metrics (accuracy, latency). This framework targets qualitative dimensions (clarity, structure, edge case coverage). Different problem, different approach.
- **Not automatic.** Every execution requires explicit approval before changes reach main. There is no "run and merge" mode.
- **Not a replacement for manual review.** The framework augments human review — it surfaces improvements and validates them, but the final decision always belongs to Jimmy.
- **Not Claude-only.** Sub-agents must be Opus 4.6 (1M context) for this version, but the orchestration protocol itself is written for any agent that meets the capability requirements below.

---

## Execution Model (Non-Negotiable)

### Platform Check

Before proceeding with any phase, verify that the current platform supports sub-agent dispatch (e.g., `claude -p` for Claude Code, `codex exec` for Codex, or equivalent).

**If the platform does NOT support sub-agent dispatch:**

```
STOP: "Platform does not support sub-agent dispatch. Cannot run self-improvement."
```

Do not proceed. Do not attempt to self-evaluate. Do not offer alternatives.

### Sub-Agent Mandate

```
MANDATORY: You MUST dispatch sub-agents for the audit layer and simulation layer.
Do NOT attempt to self-evaluate your own improvements in the same context.
The evaluator MUST be a separate sub-agent with fresh context.
If your platform does not support sub-agents, STOP and report:
"Platform does not support sub-agent dispatch. Cannot run self-improvement."
```

**Why this is non-negotiable:** An agent that generates an improvement and then evaluates that same improvement in the same context window has confirmation bias. The evaluator will rationalize flaws because it already "knows" the intent. Fresh context forces honest evaluation.

### Model Requirement

ALL sub-agent dispatches MUST use **Opus 4.6 (1M context)**. No exceptions.

- If Opus 4.6 is unavailable on the current platform, STOP with: `"Required model (Opus 4.6 1M context) is unavailable. Cannot run self-improvement."`
- Do NOT fall back to a smaller model. Do NOT use a different model family.
- The orchestrator itself may run on any model, but sub-agents MUST be Opus 4.6.

**Why:** Sub-agents must read entire target file sets in a single context window and produce structured evaluation output. Smaller context windows risk truncation or hallucinated evaluations. Weaker models risk unreliable scoring.

---

## Reference Loading Strategy

This skill uses 11 reference files stored in `references/`. Each file is loaded on-demand at specific phases to minimize context consumption. Only `safety-gates.md` remains loaded for the entire execution.

| # | File | Loaded When | Function |
|---|------|-------------|----------|
| 1 | `safety-gates.md` | **ALWAYS** (permanent) | 6 non-negotiable protection gates |
| 2 | `target-detection.md` | Phase 1 | Detects target type (skill/project/script/protocol) |
| 3 | `worktree-setup.md` | Phase 1 | Creates isolated git worktree |
| 4 | `theme-discovery.md` | Phase 2 | Identifies improvement themes by gap analysis |
| 5 | `scoring-model.md` | Phase 2 + each round | Scoring dimensions and weights per target type |
| 6 | `audit-layer.md` | Each round (Phase 3) | Layer 1 mechanical gate — dispatched to sub-agent |
| 7 | `simulation-layer.md` | Each round (Phase 3) | Layer 2 functional evaluation — dispatched to sub-agent |
| 8 | `round-protocol.md` | Each round (Phase 3) | Orchestrates a single improvement round |
| 9 | `history-protocol.md` | Phase 4 | Records execution history to disk |
| 10 | `report-template.md` | Phase 4 | Generates the detailed execution report |
| 11 | `findings-integration.md` | Phase 4 | Registers out-of-scope findings as FND-XXXX |

### How to Load a Reference

Read the file at `references/<name>.md` and follow its instructions exactly. Treat the reference content as authoritative — do not improvise, reinterpret, or skip steps defined in the reference.

### After Use

Unload the reference (drop from active context) unless it is marked **ALWAYS** in the table above. This keeps context clean and prevents stale instructions from interfering with later phases.

**Exception:** `scoring-model.md` is loaded in Phase 2 and retained through Phase 3 because every round needs the scoring dimensions and weights for evaluation.

---

## Phase 1 — Setup

**Goal:** Detect target type, create isolated worktree, gather prior history.

Execute these steps in order. Do not skip or reorder.

### Step 1.1 — Load Safety Gates (PERMANENT)

Read the file `references/safety-gates.md` in full. Internalize all 6 gates plus the Concurrent Execution Guard and Rejected Execution Handling rules.

**This reference stays loaded for the entire execution.** Do not unload it. Every subsequent step must comply with all gates at all times.

### Step 1.2 — Validate Target Path

Verify the target path resolves to an existing directory or file on disk.

```bash
ls "<target-path>"
```

If the path does not exist, STOP with:
```
Target path does not exist: <target-path>
Verify the path and try again.
```

### Step 1.3 — Detect Target Type

Read the file `references/target-detection.md` and execute the detection procedure.

**Input:** The validated target path from Step 1.2.

**Output (capture all four fields):**

| Field | Description |
|-------|-------------|
| `type` | One of: `skill`, `project`, `script`, `protocol` |
| `scope_path` | Directory or file defining the Gate 6 modification boundary |
| `branch_slug` | Full branch name for worktree creation |
| `key_files` | List of files to analyze within the target |

If detection returns `Unknown`, STOP. Present the diagnostic output from `target-detection.md` and ask the operator for clarification.

**After capturing output:** Unload `target-detection.md`.

### Step 1.4 — Create Worktree

Read the file `references/worktree-setup.md` and execute the full worktree creation procedure.

This includes:
1. Pre-creation check (branch conflict → STOP per Concurrent Execution Guard)
2. Worktree creation via `git worktree add`
3. Three-step verification (directory exists, correct branch, target files accessible)

If any step fails, STOP. Do not proceed without a verified worktree.

**After successful creation:** Record the worktree path. All subsequent file operations happen inside this worktree. Unload `worktree-setup.md`.

### Step 1.5 — Check X-MEM for Prior Failures

Read `_skills/x-mem/` for any prior failure records related to this target.

```bash
ls _skills/x-mem/
```

If records exist mentioning the target name or slug:
- Read the relevant failure entries.
- Note lessons learned (what failed, why, what to avoid).
- Carry these lessons into Phase 2 as context for theme prioritization.

If no records exist, proceed. This step is informational, not blocking.

### Step 1.6 — Check Execution History

Check for prior self-improvement executions on this target:

```bash
ls _skills/self-improvement/history/<target-slug>/changelog.md
```

Where `<target-slug>` is the kebab-case identifier from Step 1.3.

**If changelog.md exists:**
- Read it.
- Note the last composite score.
- Note which themes were previously refined and their outcomes.
- Note the historical trend (improving, plateauing, regressing).

**If changelog.md does not exist:**
- This is the first execution for this target. No history to load.

### Phase 1 Output

Before proceeding to Phase 2, confirm these artifacts are captured:

| Artifact | Value |
|----------|-------|
| Target type | `<skill / project / script / protocol>` |
| Scope path | `<path>` |
| Worktree path | `_worktrees/self-improvement-<slug>-<YYYY-MM-DD>/` |
| Branch name | `self-improvement/<slug>-<YYYY-MM-DD>` |
| Key files | `<list>` |
| Prior history | `<summary or "first execution">` |
| X-MEM lessons | `<summary or "none">` |

If any artifact is missing, do not proceed. Resolve the gap first.

---

## Phase 2 — Discovery

**Goal:** Calculate baseline scores, identify improvement themes, create round schedule.

### Step 2.1 — Load References

Read the following two files:
- `references/theme-discovery.md`
- `references/scoring-model.md`

Both must be loaded before proceeding. `scoring-model.md` stays loaded through Phase 3.

### Step 2.2 — Read All Target Files

Working inside the worktree, read ALL files within the target scope.

**For directory targets:** Enumerate every file in the directory tree. Read each file in full.

**For file targets:** Read the single target file in full.

Do NOT rely on session memory, prior context, or cache. Read from disk.

While reading, note:
- Content quality observations (what is clear, complete, well-structured)
- Potential issues (ambiguous language, missing sections, contradictions, error-prone patterns)
- Strengths (what is already working well)

Do not score during this step. Observation only.

### Step 2.3 — Calculate Baseline Score

Using the scoring dimensions and weights from `scoring-model.md` for the detected target type:

1. Evaluate each dimension against the target content.
2. Assign a score from 0.0 to 10.0 per dimension.
3. Write a 1-2 sentence justification per dimension referencing specific content.
4. Calculate the composite score: `composite = sum(dimension_score * weight)`.
5. Apply the interpretation label from the scoring model.

Record the result as the **Baseline Snapshot:**

```
Baseline Snapshot
-----------------
Target:     <scope_path>
Type:       <type>
Date:       <YYYY-MM-DD>

Dimensions:
  <dimension-name>: <score> -- <justification>
  <dimension-name>: <score> -- <justification>
  ...

Composite: <X.X>
Label:     <Poor | Below Average | Needs Work | Good | Very Good | Excellent>
```

This snapshot is immutable for the rest of the execution. It becomes the baseline reference for all round evaluations.

### Step 2.4 — Identify Themes by Gap

Follow the theme identification procedure from `theme-discovery.md`:

1. For each dimension scoring below 9.0, calculate the gap: `gap = 10.0 - score`.
2. Map each dimension to its theme name using the theme catalog for the target type.
3. Sort themes by gap (largest first). Break ties by dimension weight (higher weight first).
4. If `--theme` was specified, move that theme to position T1 regardless of its gap rank.

**Skip rule:** Dimensions scoring 9.0 or above are excluded from the theme list.

### Step 2.5 — Map Themes to Rounds

Assign one theme per round, up to `--rounds N` (default 5).

If fewer themes exist than rounds requested, reduce the round count to match the number of themes. Do not pad with empty rounds.

**Special case — all dimensions at 9.0+:** If every dimension scores 9.0 or above, output:

```
No themes identified -- all dimensions at 9.0+.
Baseline composite: <X.X>
Recommendation: target is at excellent baseline. No rounds scheduled.
```

Report this to Jimmy. Execution ends here (skip to Phase 4 for history recording with status `No-Change`).

### Phase 2 Output

```
Theme Schedule
--------------
- T1: <theme> (score: X.X, gap: Y.Y)
- T2: <theme> (score: X.X, gap: Y.Y)
- ...
- Baseline composite: X.X
- Rounds planned: N
```

**After output:** Unload `theme-discovery.md`. Keep `scoring-model.md` loaded for Phase 3.

---

## Phase 3 — Improvement Rounds

**Goal:** Execute N improvement rounds, each targeting one theme. Every round follows the 6-step protocol with two-layer testing.

### Pre-Phase 3 Check

Confirm the following before starting the first round:
- Worktree is active and verified.
- Baseline scores are captured.
- Theme schedule is finalized.
- Safety gates are loaded and active.

If any condition is unmet, STOP. Do not start rounds without complete setup.

### Round Execution (Repeat for Each Round 1..N)

For each round, load `references/round-protocol.md` and execute its 6-step flow. The round protocol is the authoritative source for round execution. What follows is the orchestrator's dispatch sequence.

---

#### Step 3.R.1 — SNAPSHOT

Record the current composite score as `score_before` for this round.

- Round 1: use the baseline composite from Phase 2.
- Round 2+: use the composite from the last completed round's LOG entry.

Do not proceed without a numeric `score_before`.

---

#### Step 3.R.2 — APPLY Improvement Package

1. **Re-read ALL target files from disk** inside the worktree. Do NOT use cached content from previous rounds. This is mandatory between every round.
2. Identify all improvements aligned to this round's theme.
3. Apply the complete set of changes as a coherent, atomic package.
4. Commit using the convention:

```
improvement(<target-slug>): <theme> - round N
```

Example: `improvement(agent-orchestration-protocol): clarity - round 3`

Do not apply partial packages. The commit must represent a complete, coherent unit.

---

#### Step 3.R.3 — AUDIT GATE (Layer 1)

**Dispatch a sub-agent** with the following inputs ONLY:

| Input | Source |
|-------|--------|
| Modified files | All files changed in the worktree (post-commit from Step 3.R.2) |
| Audit checklist | The content of `references/audit-layer.md` — the checklist matching the target type |

**What the sub-agent must NOT receive:**
- The improvement rationale or reasoning
- The orchestrator's analysis
- Prior round context
- Original (pre-improvement) files
- Scoring data

**Sub-agent model:** Opus 4.6 (1M context). No exceptions.

**Sub-agent task:** Execute the audit checklist. Return a structured PASS or FAIL result.

| Audit Result | Action |
|--------------|--------|
| **PASS** | Proceed to Step 3.R.4 (Simulation). |
| **FAIL** | Trigger Atomic Decomposition (see below). Simulation is BLOCKED. |

---

#### Step 3.R.4 — SIMULATION (Layer 2)

**Pre-condition:** Audit gate (Step 3.R.3) returned PASS. If audit returned FAIL, do NOT run simulation.

**Dispatch a sub-agent** with the following inputs ONLY:

| Input | Source |
|-------|--------|
| Target files | The complete set of modified files as they currently exist in the worktree |
| Scoring dimensions and weights | The full dimension table for the target type from `references/scoring-model.md` |
| Baseline scores | The per-dimension scores from the Phase 2 baseline snapshot |

**What the sub-agent must NOT receive:**
- What was changed in this round
- Why the change was made
- The orchestrator's improvement rationale
- Notes, summaries, or context from previous phases
- The round number or execution history

**Sub-agent model:** Opus 4.6 (1M context). No exceptions.

**Sub-agent task:** Execute the simulation procedure from `references/simulation-layer.md`:
1. Read target as if for the first time.
2. Score each dimension.
3. Run scenario tests for the target type.
4. Calculate composite score and delta.
5. Return structured PASS/FAIL result with full score breakdown.

| Simulation Result | Action |
|-------------------|--------|
| **PASS** (score >= baseline) | Proceed to Step 3.R.5 (Decide). |
| **FAIL** (score < baseline) | Trigger Atomic Decomposition (see below). |

---

#### Step 3.R.5 — DECIDE

Compare the new composite score from simulation against `score_before`.

| Outcome | Condition | Action |
|---------|-----------|--------|
| **KEEP** | Score improved (`new > score_before`) | Commit remains. Proceed to Step 3.R.6. |
| **KEEP (lateral)** | Score equal (`new == score_before`) | Commit remains. Flag as `lateral: true` in log. Proceed to Step 3.R.6. |
| **DISCARD** | Score worsened (`new < score_before`) | Revert: `git reset --hard HEAD~1` on the isolated branch. Proceed to Step 3.R.6. |

**Note on lateral rounds:** A change that improves clarity or structure without moving the composite score is still valuable. Lateral rounds are kept, not discarded. However, if two or more consecutive rounds are lateral, flag diminishing returns in the log.

---

#### Step 3.R.6 — LOG

Record this round in `rounds-log.md` (maintained in memory during execution, written to disk in Phase 4):

| Field | Value |
|-------|-------|
| Round | `<N>` |
| Theme | `<theme name>` |
| Score before | `<score_before>` |
| Score after | `<new composite score>` |
| Delta | `<percentage change>` |
| Decision | `KEEP` / `KEEP(lateral)` / `DISCARD` |
| Reason | One sentence explaining the decision |

---

### Atomic Decomposition Protocol

**Triggered when:** A thematic package FAILS the audit gate (Step 3.R.3) or the simulation gate (Step 3.R.4).

**Procedure:**

1. Revert the package commit:
   ```bash
   git reset --hard HEAD~1
   ```

2. Decompose the package into individual, isolated changes.

3. For each decomposed change (sub-round N.M):
   a. Apply the single change and commit:
      ```
      improvement(<target-slug>): <theme> - round N.M
      ```
   b. Run audit gate (Step 3.R.3) on this single change.
   c. If audit PASS, run simulation (Step 3.R.4).
   d. If simulation PASS, KEEP the sub-round commit.
   e. If audit FAIL or simulation FAIL, revert: `git reset --hard HEAD~1`.

4. Maximum attempts: **2 decomposition attempts per package.** After the second attempt, if any change still cannot pass, stop retrying.

5. Escalation: If the package and its decomposed changes still fail after 2 attempts, register the failure as a finding (FND-XXXX) using the findings integration protocol. Move to the next theme. Do not stall.

---

### Between Rounds

Before starting the next round:

1. **Re-read ALL target files from disk.** Do not use cached content. Accumulated changes from previous rounds must be reflected.
2. Retrieve the updated composite score from the most recent round log entry.
3. This becomes `score_before` for the next round (Step 3.R.1).

**Why:** Each round builds on the previous. Stale content causes re-applied changes, conflicts, and false deltas.

---

### After All Rounds Complete

1. Calculate the final composite score from the last round's simulation output (or baseline if all rounds were discarded).
2. Calculate total delta: `((final_score - baseline_score) / baseline_score) * 100`.
3. Count: rounds kept, rounds discarded, lateral rounds.

### Phase 3 Output

| Artifact | Value |
|----------|-------|
| Rounds executed | `<N total>` |
| Rounds kept | `<count>` |
| Rounds discarded | `<count>` |
| Lateral rounds | `<count>` |
| Final composite score | `<X.X>` |
| Total delta | `<+X.X%>` |
| Round details | `<round-by-round log>` |

---

## Phase 4 — Report and History

**Goal:** Record execution history, generate detailed report, register out-of-scope findings.

### Step 4.1 — Record Execution History

Read `references/history-protocol.md` and execute its 7-step procedure:

1. Read templates from the reference.
2. Resolve paths: `HISTORY_ROOT` = `C:\ai\_skills\self-improvement\history\`.
3. Create directories if needed (`<target-slug>/` and `<YYYY-MM-DD>/`).
4. Write execution files: `report.md`, `scores.md`, `rounds-log.md` inside the date directory.
5. Update `changelog.md` (append one row).
6. Update `index.md` (update or add target row).
7. Verify all 5 files exist.

**Important:** History files are written to `_skills/self-improvement/history/` — NOT inside the worktree. This is the sole permitted write outside the worktree per Gate 2.

**After completion:** Unload `history-protocol.md`.

### Step 4.2 — Generate Detailed Report

Read `references/report-template.md` and generate the complete execution report.

The report has 7 sections:
1. **Executive Summary** — compact overview with recommendation logic
2. **Baseline Snapshot** — immutable Phase 2 scores
3. **Round Details** — one sub-section per round (kept, discarded, and lateral)
4. **Final Scores** — per-dimension comparison (baseline vs. final)
5. **Findings (Out of Scope)** — issues outside target scope
6. **Files Modified** — complete list from git log of kept commits
7. **Approval Gate** — decision prompt for Jimmy

Fill every placeholder. A report with unfilled `<placeholder>` markers is incomplete and must not be presented.

Save to: `_skills/self-improvement/history/<target-slug>/<YYYY-MM-DD>/report.md`

**After completion:** Unload `report-template.md`.

### Step 4.3 — Register Out-of-Scope Findings

Read `references/findings-integration.md`.

For each issue discovered during execution that falls outside the target scope (Gate 6 boundary):

1. Read the current counter from `obsidian/CIH/projects/_findings/findings-master-index.md`.
2. Generate the FND-XXXX ID and hash.
3. Create the detail file at `obsidian/CIH/projects/_findings/FND-XXXX.md`.
4. Update both the YAML frontmatter counters AND the registry table in `findings-master-index.md` (atomic update — both in the same operation).
5. Reference the finding in the execution report's Section 5.

**Important:** Findings persist regardless of execution outcome. Even if Jimmy rejects the merge, findings remain in the master index. They are independent of approval.

**If no out-of-scope findings were identified:** Skip this step. Report Section 5 uses the "no findings" note.

**After completion:** Unload `findings-integration.md`.

### Phase 4 Output

| Artifact | Value |
|----------|-------|
| Report path | `_skills/self-improvement/history/<target-slug>/<YYYY-MM-DD>/report.md` |
| History files updated | `changelog.md`, `index.md`, `scores.md`, `rounds-log.md` |
| Findings registered | `<count>` FND-XXXX tickets (or 0) |

---

## Phase 5 — Presentation and Approval

**Goal:** Present results to Jimmy and await explicit approval decision.

### Step 5.1 — Present Executive Summary

Display the following summary in chat:

```
<target> refined: <baseline_score> -> <final_score> (<delta>%) in <N> rounds.
Branch: self-improvement/<slug>-<YYYY-MM-DD>
<N> findings registered (out of scope).
Full report at: _skills/self-improvement/history/<target-slug>/<YYYY-MM-DD>/report.md
Recommendation: <from report Section 1 recommendation logic>

Do you want to approve the merge?
```

### Step 5.2 — Wait for Explicit Response

STOP. Take no further action until Jimmy responds. Do not suggest, prompt, or nudge. The framework is complete. The decision is Jimmy's.

**Acceptable responses and actions:**

| Response | Action |
|----------|--------|
| "approve" / "merge" / "apply" / "yes" | Execute Step 5.3 (Merge). |
| "reject" / "no" / "discard" | Execute Step 5.4 (Reject). |
| "partial" / "let me review" | List individual round commits for selective review. Wait for final decision. |

### Step 5.3 — Merge (On Approval)

1. Merge the improvement branch into main:
   ```bash
   git checkout main
   git merge self-improvement/<slug>-<YYYY-MM-DD> --no-ff -m "self-improvement(<target-slug>): merge approved -- <baseline> -> <final> (<delta>%)"
   ```

2. Update the report's `status` field from `pending-approval` to `approved`.

3. Update `changelog.md` status to `Approved`.

4. Cleanup the worktree:
   ```bash
   git worktree remove "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>"
   ```

5. The branch is retained after merge (it is part of main's history).

6. Report: `"Merge complete. Changes are now on main."`

### Step 5.4 — Reject (On Rejection)

1. Update the report's `status` field from `pending-approval` to `discarded`.

2. Update `changelog.md` status to `Rejected`.

3. Cleanup the worktree:
   ```bash
   git worktree remove "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>"
   ```

4. The branch is NOT deleted. It remains available for future reference at `self-improvement/<slug>-<YYYY-MM-DD>`.

5. Report: `"Execution logged as rejected. Branch retained for reference. No changes on main."`

### Step 5.5 — Zero-Delta Handling

If the total delta is exactly 0% (all rounds lateral or all discarded):

```
No improvement identified. Target is at <score> (<label>).
Recommendation: do not run again for 30 days.
Branch auto-discarded.
```

1. Update `changelog.md` status to `No-Change`.
2. Cleanup worktree.
3. Delete the branch (no value in retaining a zero-delta branch):
   ```bash
   git worktree remove "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>"
   git branch -D "self-improvement/<slug>-<YYYY-MM-DD>"
   ```

---

## Error Handling

Three failure modes and their required responses:

### Crash (Unrecoverable Agent Error)

1. Revert to the last good commit on the isolated branch:
   ```bash
   git -C "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>" reset --hard HEAD~1
   ```
2. Force-remove the worktree:
   ```bash
   git worktree remove --force "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>"
   git branch -D "self-improvement/<slug>-<YYYY-MM-DD>"
   ```
3. Write a partial execution entry to `_skills/self-improvement/history/<target-slug>/changelog.md` with status `Crashed`.
4. Report the crash to Jimmy with: phase reached, last successful step, error description.

### Timeout

Same procedure as Crash. Timeout is treated as an unrecoverable failure.

### Git Failure

If any git operation fails (merge conflict, corrupt index, disk error):

1. **STOP immediately.** Do not attempt alternatives on main.
2. Report the exact git error to Jimmy.
3. Do NOT attempt recovery operations beyond the isolated branch.
4. Provide cleanup instructions:
   ```
   To clean up manually:
   git worktree remove --force "_worktrees/self-improvement-<slug>-<YYYY-MM-DD>"
   git branch -D "self-improvement/<slug>-<YYYY-MM-DD>"
   ```

---

## Building Blocks (Existing Infrastructure)

This framework leverages established components from the workspace. Do not reinvent these systems.

| Component | Location | Role in Framework |
|-----------|----------|-------------------|
| **X-MEM** | `_skills/x-mem/` | Failure/success learning. Agents read past failures before starting a new execution to avoid repeating mistakes. |
| **Repo-Auditor** | `claude-intelligence-hub/repo-auditor/` | Audit layer patterns. The phase-based gate structure and fingerprinting approach are derived from repo-auditor's deterministic protocol. |
| **Findings System** | `obsidian/CIH/projects/_findings/` | Feedback registry. Out-of-scope issues are registered as FND-XXXX tickets in the global findings master index. |
| **Git Worktrees** | `_worktrees/` | Experimentation sandbox. Worktrees provide complete filesystem isolation without affecting main. |
| **Brainstorming + Sequential Thinking** | MCP tools | Analysis patterns. Used during theme discovery and improvement planning for structured evaluation. |

---

## Cross-Agent Compatibility

This framework works with ANY agent that can:

1. **Read markdown files** — the framework is entirely markdown-driven.
2. **Execute git commands** — worktree creation, commits, reverts, merges.
3. **Dispatch sub-agents** (or equivalent) — separate context windows for audit and simulation.
4. **Follow structured instructions** — sequential steps with conditional branching.

### Tested Providers

| Provider | Agent | Status |
|----------|-------|--------|
| Claude Code | Opus 4.6 (1M context) | Primary. Fully tested. |
| Codex | GPT 5.4 | Compatible. Sub-agent dispatch via `codex exec`. |
| Gemini | Gemini 2.5 Pro | Compatible in principle. Not yet field-tested. |

### Platform-Specific Notes

**Claude Code:** Use `claude -p` for sub-agent dispatch. Model flag: `--model claude-opus-4-6`.

**Codex:** Use `codex exec` for sub-agent dispatch. Ensure sandbox allows git operations.

**Gemini:** If using Gemini as orchestrator, sub-agents must still be Opus 4.6 per the Model Requirement. Gemini orchestrating with Claude sub-agents is valid.

---

## Quick Reference — Full Execution Flow

```
Phase 1: SETUP
  1.1  Load safety-gates.md (PERMANENT)
  1.2  Validate target path
  1.3  Detect target type -> unload target-detection.md
  1.4  Create worktree -> unload worktree-setup.md
  1.5  Check X-MEM for prior failures
  1.6  Check execution history

Phase 2: DISCOVERY
  2.1  Load theme-discovery.md + scoring-model.md
  2.2  Read all target files (from worktree)
  2.3  Calculate baseline score
  2.4  Identify themes by gap
  2.5  Map themes to rounds -> unload theme-discovery.md

Phase 3: ROUNDS (repeat for each round 1..N)
  3.R.1  SNAPSHOT current score
  3.R.2  APPLY thematic improvement + commit
  3.R.3  AUDIT GATE: dispatch sub-agent [audit-layer.md]
  3.R.4  SIMULATION: dispatch sub-agent [simulation-layer.md]
  3.R.5  DECIDE: keep / keep(lateral) / discard
  3.R.6  LOG round result
  [Between rounds: re-read all files from disk]

Phase 4: REPORT
  4.1  Record history -> unload history-protocol.md
  4.2  Generate report -> unload report-template.md
  4.3  Register findings -> unload findings-integration.md

Phase 5: PRESENTATION
  5.1  Present executive summary
  5.2  Wait for approval
  5.3  Merge (on approval)
  5.4  Reject (on rejection)
  5.5  Zero-delta auto-discard
```

---

## Safety Gates Summary

These gates are defined in full in `references/safety-gates.md`. This summary exists for quick reference only — the reference file is authoritative.

| Gate | Rule | Violation = |
|------|------|-------------|
| **Gate 1** — Total Isolation | All work in worktree on branch `self-improvement/<target>-<date>` | Immediate halt |
| **Gate 2** — Original Untouchable | No file outside worktree is modified (except `history/`) | Immediate halt |
| **Gate 3** — Merge Only With Authorization | Report first, then wait for explicit approval | Never auto-merge |
| **Gate 4** — Guaranteed Rollback | Every change is reversible via git | Branch discard restores pre-execution state |
| **Gate 5** — Total Transparency | Every action is traceable; nothing is silent | Incomplete report = report the gap |
| **Gate 6** — Scope Limited to Target | Only target directory files are modified | Out-of-scope = register as FND-XXXX |

**Additional rules:** Concurrent Execution Guard (one execution per target per day), Rejected Execution Handling (rejected merges are logged, branch retained, findings persist).

---

## Commit Convention Reference

| Type | Format | Example |
|------|--------|---------|
| Improvement package | `improvement(<slug>): <theme> - round N` | `improvement(aop): clarity - round 2` |
| Sub-round (decomposition) | `improvement(<slug>): <theme> - round N.M` | `improvement(aop): clarity - round 2.1` |
| Merge | `self-improvement(<slug>): merge approved -- <before> -> <after> (<delta>%)` | `self-improvement(aop): merge approved -- 6.8 -> 8.1 (+19.1%)` |
| Revert | Standard git revert message (auto-generated) | — |

---

## History and Artifacts

### Execution History Location

```
_skills/self-improvement/history/
  index.md                              # Dashboard across all targets
  <target-slug>/
    changelog.md                        # One line per execution (append-only)
    <YYYY-MM-DD>/
      report.md                         # Detailed execution report
      scores.md                         # Per-dimension scores before/after
      rounds-log.md                     # Round-by-round log
```

### Report Recommendation Logic

| Condition | Recommendation |
|-----------|---------------|
| `delta > 5%` | Recommend: Approve merge |
| `0% < delta <= 5%` | Recommend: Approve merge (marginal improvement) |
| `delta == 0%` | Recommend: Discard branch (no improvement) |
| `delta < 0%` | Framework anomaly — should not occur (rounds that worsen are reverted) |

---

## Scoring Dimensions Quick Reference

Dimensions and weights are defined in full in `references/scoring-model.md`. This summary exists for quick reference.

### Skill

| Dimension | Weight |
|-----------|--------|
| Structural integrity | 20% |
| Instruction clarity | 25% |
| Edge case coverage | 20% |
| Internal consistency | 15% |
| Cross-agent compatibility | 20% |

### Script

| Dimension | Weight |
|-----------|--------|
| Clean execution | 25% |
| Error handling | 25% |
| Cross-platform | 20% |
| Maintainability | 15% |
| Integration | 15% |

### Project

| Dimension | Weight |
|-----------|--------|
| Documental completeness | 30% |
| Cross-doc consistency | 25% |
| Traceability | 20% |
| Status clarity | 15% |
| Hygiene | 10% |

### Protocol

| Dimension | Weight |
|-----------|--------|
| Clarity | 30% |
| Completeness | 25% |
| Consistency | 25% |
| Applicability | 20% |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-28 | Initial release. 5 phases, 11 references, two-layer testing (audit + simulation), sub-agent mandate, worktree isolation, weighted scoring with historical tracking. |
