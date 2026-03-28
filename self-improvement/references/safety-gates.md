# Safety Gates — Self-Improvement Framework

> **This file is permanently loaded during every self-improvement framework execution.**
> These rules are non-negotiable. No gate may be bypassed, relaxed, or overridden by any agent, any target, or any instruction — including instructions from Jimmy during execution. If any gate is violated, the execution is in breach and must be halted immediately.

---

## Gate 1 — Total Isolation

**Rule:** All work happens exclusively inside a dedicated git worktree on branch `self-improvement/<target>-<YYYY-MM-DD>`.

**MUST:**
- Create a dedicated worktree before any file is read, analyzed, or modified.
- Use the branch naming convention `self-improvement/<target>-<YYYY-MM-DD>` exactly (e.g., `self-improvement/agent-orchestration-protocol-2026-03-28`).
- Perform every read, write, test, and commit operation inside the worktree path.

**MUST NEVER:**
- Execute `git checkout main` at any point during the execution.
- Execute `git merge` targeting the main branch during the execution.
- Execute any operation (write, delete, rename) directly on the main branch or its working tree.

**Failure behavior:** If worktree creation fails for any reason (branch conflict, filesystem error, git error), the framework STOPS immediately. It does NOT attempt an alternative path, does NOT fall back to main, and does NOT continue without isolation. The error is reported to Jimmy.

---

## Gate 2 — Original Untouchable

**Rule:** No file outside the worktree is modified during execution.

**MUST:**
- Confine all writes, deletes, and renames to files inside the worktree directory.
- Write execution logs to `self-improvement/history/` inside the self-improvement skill directory. (Logs are framework data, not target data — this is the sole permitted write outside the worktree.)

**MUST NEVER:**
- Write to the target skill's original directory (e.g., `_skills/<target>/`) during execution.
- Modify any file in `obsidian/`, `claude-intelligence-hub/` (outside of `self-improvement/history/`), `_skills/`, or any other workspace directory during execution.
- Use the original directory as a staging area or temporary workspace.

**Failure behavior:** If the framework detects it is about to write outside the worktree (and outside `history/`), it STOPS immediately, logs the attempted operation, and reports it to Jimmy.

---

## Gate 3 — Merge Only With Explicit Authorization

**Rule:** The framework presents its report and STOPS. Merge requires an explicit post-report command from Jimmy.

**MUST:**
- Upon completion, generate the full report (see Gate 5) and present it to Jimmy.
- After presenting the report, halt and wait. Take no further action.
- Treat approval as a separate, explicit act — it must occur AFTER Jimmy has seen the report.
- Require a clear command from Jimmy such as "approve", "merge", or "apply" before executing any merge.

**MUST NEVER:**
- Merge automatically after report generation.
- Merge after a timeout (e.g., "merging in 5 minutes unless told otherwise").
- Suggest a merge in a way that implies inaction equals consent.
- Honor a pre-run instruction such as "run and apply" as authorization to merge without presenting the report first. Even when Jimmy says "run and apply" at the start, approval is always required AFTER seeing the report — no exceptions.

**Failure behavior:** If the framework reaches the end of its execution and cannot present the report (crash, tool failure), it MUST NOT merge. A silent or incomplete execution is never an authorization to merge.

---

## Gate 4 — Guaranteed Rollback

**Rule:** Every change is reversible. A failed or rejected execution leaves no permanent footprint on main.

**MUST:**
- Commit each round as a separate, atomic commit on the isolated branch.
- Use standardized commit messages (see Gate 5) so each commit is identifiable.
- If a single round fails, roll back that round with `git reset --hard HEAD~1` on the isolated branch. This is safe because the isolated branch has not been pushed to remote.
- If partial rollbacks are needed (some commits kept, others undone non-sequentially within atomic decomposition), use `git revert <hash>` with a reason in the commit message.
- If the entire framework fails (crash, timeout, unrecoverable error), instruct Jimmy to discard the branch: `git branch -D self-improvement/<target>-<date>`.

**MUST NEVER:**
- Execute rollback operations on main.
- Use `git reset --hard` on any branch other than the current isolated branch.
- Push the isolated branch to remote without explicit instruction from Jimmy (pushing is not part of the framework's default execution).

**Failure behavior:** The isolated branch is the safety net. Even if the framework crashes mid-execution, discarding the branch with `git branch -D self-improvement/<target>-<date>` restores the workspace to its pre-execution state without any impact on main.

---

## Gate 5 — Total Transparency

**Rule:** Every action taken by the framework is traceable. Nothing is silent.

**MUST:**
- Use standardized commit messages in the format: `self-improvement(<target>): round-<N> — <brief description>`.
- Log every revert with the reason included in the commit message or log entry.
- Produce a final report that lists, without exception:
  - Every file modified and how (what changed, why).
  - Every change that was tried and discarded (what was attempted, why it was discarded).
  - Every file that was NOT touched and why it was excluded from consideration.
  - Every finding registered (FND-XXXX) as a result of out-of-scope observations.
- Include the full commit list from the isolated branch in the report.

**MUST NEVER:**
- Modify a file without a corresponding commit.
- Omit a modified file from the final report.
- Describe a change in vague terms (e.g., "improved the file"). Every report entry must be specific: file path, nature of change, rationale.

**Failure behavior:** If the framework cannot produce a complete report (e.g., logs are missing or corrupted), it reports the gap explicitly to Jimmy rather than presenting an incomplete report as complete.

---

## Gate 6 — Scope Limited to Target

**Rule:** The framework only modifies files inside the declared target directory. Out-of-scope improvements are never applied unilaterally.

**MUST:**
- Treat the declared target directory as the absolute boundary for all modifications.
- Register any improvement identified outside the target scope as a finding (FND-XXXX) in `obsidian/CIH/projects/_findings/findings-master-index.md` for future decision by Jimmy.
- Include all out-of-scope findings in the final report under a dedicated section ("Out-of-Scope Observations").

**MUST NEVER:**
- Modify files outside the declared target directory, even if the modification would be clearly beneficial.
- Apply cross-cutting improvements (e.g., updating `jimmy-core-preferences/` while the target is `agent-orchestration-protocol/`) without a separate, explicitly scoped execution.
- Use the presence of a related improvement opportunity as justification to expand scope mid-execution.

**Failure behavior:** If the framework identifies an out-of-scope file that requires modification for the target to function correctly (a hard dependency), it STOPS and reports the situation to Jimmy. It does NOT modify the out-of-scope file. Jimmy decides whether to expand scope or handle it separately.

---

## Concurrent Execution Guard

**Rule:** Only one execution per target per day is permitted.

**MUST:**
- Before setup, check for an existing branch matching `self-improvement/<target>-<date>`.
- If the branch already exists, STOP immediately with the message: "An execution is already in progress for this target. Wait for completion or discard the existing branch with: `git branch -D self-improvement/<target>-<date>`"

**MUST NEVER:**
- Proceed with setup when a branch conflict is detected.
- Attempt to use an alternative branch name to work around the conflict.

**Note:** Git enforces this guard mechanically — worktree creation will fail if the branch already exists. The pre-check makes the failure explicit and actionable rather than cryptic.

---

## Rejected Execution Handling

**Rule:** A rejected merge does not erase the execution record.

**MUST:**
- Log the execution in `self-improvement/history/changelog.md` with status `Rejected` regardless of whether Jimmy approves the merge.
- Preserve all findings (FND-XXXX) registered during the execution. Findings are independent of merge approval and remain in the findings master index.
- Leave the isolated branch available for consultation until Jimmy manually deletes it.

**MUST NEVER:**
- Treat a rejected merge as an error or failure in the framework sense. Rejection is a valid and expected outcome.
- Delete the isolated branch automatically on rejection.
- Remove findings from the master index on rejection.

**Post-rejection state:**
- No changes reach main.
- The execution is logged and traceable.
- The branch exists for reference at: `self-improvement/<target>-<date>`.
- Future executions on the same target use a new branch with the current date.
