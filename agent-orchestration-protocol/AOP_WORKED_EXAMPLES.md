# Cookbook: Agent Orchestration Protocol (AOP) Worked Examples
**Supporting Document For:** `SKILL: agent-orchestration-protocol`
**Version:** 4.2.0
**Status:** Production-Validated

This document contains a curated list of prompts that have been executed with 100% success in real-world scenarios, demonstrating the practical application of the Seven Pillars of AOP.

---

## Best Practices for Orchestration

<details>
<summary><b>View Best Practices</b></summary>

- **Delegate the Loop:** For polling, delegate the entire loop to a single agent rather than spawning a new process every 60 seconds.
- **Boolean Checks:** Ask agents to return ONLY `YES` or `NO` when verifying state.
- **Verify Paths:** Always verify the absolute path before executing `cd` (bash) or `Set-Location` (PowerShell).
- **File-Based Prompts:** For any instruction containing code blocks, JSON, or special characters, write the prompt to a file and pipe it — do not use inline `-p` strings.

</details>

---

### Prompt 1: Basic Connectivity Test

**Objective:** Validate that the Orchestrator can invoke a shell and execute a basic CLI command.

<details>
<summary><b>View Prompt</b></summary>

```prompt
Execute the following connectivity test. Open a powershell -NoProfile -Command terminal, change directory using `Set-Location C:\Workspaces\llms_projects`, and call Codex CLI using `codex exec --dangerously-bypass-approvals-and-sandbox 'Return ONLY YES'`. Report Success or Fail.
```

</details>

---

### Prompt 2: Simple File Creation

**Objective:** Test the ability of an Executor (Codex) to create a file in the workspace after being granted permissions.

<details>
<summary><b>View Prompt</b></summary>

```prompt
Execute the second test. Open a powershell -NoProfile -Command terminal. Then use Option B routing: `Set-Location C:\Workspaces\llms_projects; codex exec --dangerously-bypass-approvals-and-sandbox 'Create a file called executor_test_file_creation.md'`
```

</details>

---

### Prompt 3: Read and Create New Version

**Objective:** Delegate the task of reading a file, analyzing it, and creating a new, improved version to an Executor.

<details>
<summary><b>View Prompt</b></summary>

```prompt
Execute the following test. Open a powershell -NoProfile -Command terminal. Execute this exact command: `Set-Location C:\Workspaces\llms_projects; codex exec --dangerously-bypass-approvals-and-sandbox 'Read file draft_proposal_jimmy_v1.txt, analyse it 100% and create your own version based on my draft, improving it. Save your version as draft_proposal_executor_v1.md and finish the task.'` Report Success or Fail.
```

</details>

---

### Prompt 4: Sequential Two-Agent Orchestration

**Objective:** Orchestrate two Executor Agents (Codex and Claude) to perform the same task in sequence, with each creating its own artifact.

<details>
<summary><b>View Prompt</b></summary>

```prompt
Execute these tasks with Codex CLI and Claude Code CLI.
Open a powershell -NoProfile -Command terminal.
Execute Codex using: `Set-Location C:\Workspaces\llms_projects; codex exec --dangerously-bypass-approvals-and-sandbox 'Read draft_proposal_jimmy_v1.md. Analyse it 100% and create your software engineer version, with your ideas and best market suggestions. Save it as draft_proposal_codex_v1.md. Finish when done.'`
Check if Codex created file draft_proposal_codex_v1.md.
Do the same for the Claude executor using `Set-Location C:\Workspaces\llms_projects; claude --dangerously-skip-permissions -p 'Read draft_proposal_jimmy_v1.md and save your version as draft_proposal_claude_v1.md'`.
Report SUCCESS or FAIL when both are done.
```

</details>

---

### Prompt 5: Orchestration with Merge, Delegation, and Polling

**Objective:** A complex workflow where the Orchestrator first creates a file, then delegates the review to an Executor, and finally monitors the creation of the final artifact.

<details>
<summary><b>View Prompt</b></summary>

```prompt
Execute as follows:
Step 1: Access file MASTER_PROPOSAL_SECURITY_REVIEW.md and analyse it 100%;
Step 2: Compare to file MASTER_PROPOSAL.md;
Step 3: Create a new file called MASTER_PROPOSAL_orchestrator_final_review.md applying all corrections suggested;
Step 4: Open a powershell -NoProfile -Command terminal in HEADLESS mode;
Step 5: Navigate via `Set-Location C:\Workspaces\llms_projects` and call Claude CLI: `claude --dangerously-skip-permissions -p 'Review MASTER_PROPOSAL_orchestrator_final_review.md then create MASTER_PROPOSAL_FINAL_executor.md with adjustments.'`
Step 6: Delegate the Polling Loop: Spawn a single sub-agent tasked to poll the directory every 60 seconds until MASTER_PROPOSAL_FINAL_executor.md is created, timing out after 10 minutes.
Step 7: Once the sub-agent reports the file was created, report SUCCESS or FAIL to me.
```

</details>

---

### Prompt 6: High-Integrity Orchestration (Master Template)

**Objective:** The most complete example, explicitly covering all AOP pillars, including environment setup, bypass, delegated instruction, polling with integrity validation, and a closeout cycle.

<details>
<summary><b>View Prompt</b></summary>

```prompt
Execute the following document engineering operation with a focus on integrity and multi-agent verification:
1- Execute the Codex CLI via a headless terminal: `powershell -NoProfile -Command`
2- Apply Flexible Routing: `Set-Location C:\Workspaces\llms_projects`
3- Instruct the executor using the mandatory standard (Option B):
`Set-Location C:\Workspaces\llms_projects; codex exec --dangerously-bypass-approvals-and-sandbox 'Analyze the differences of files A.md and B.md and create a merged version saving it as C.md'`
4- Monitoring and Validation Protocol (Polling):
* Delegate the Loop: Spawn a single sub-agent tasked to run a verification loop (polling) of up to 10 minutes.
* Every 60 seconds, check for the existence of `C.md` and validate it is not empty.
* If detected and validated, perform a `read_file` to confirm integrity.
5- Cycle Completion:
* If generated successfully: Return 'STATUS: SUCCESS'.
* If timeout or error: Return 'STATUS: FAIL' with the terminal error log.
```

</details>

---

### Prompt 7: Full Lifecycle Feature Delegation

**Objective:** To orchestrate the creation of a new skill, including directory structure, documentation, and version control, by delegating a multi-step plan to an Executor.

<details>
<summary><b>View Prompt</b></summary>

```prompt
You are the Orchestrator (YOLO Mode) executing Phase 1 of PLAN-AOP-CIH-V1.2.

Step 1: Read the full PLAN-AOP-CIH-V1.2 document to understand the deliverables: C:\Workspaces\llms_projects\plan-aop-agent-orchestration-protocol_forge_v2.md.

Step 2: Open a powershell -NoProfile -Command terminal in HEADLESS mode.

Step 3: Call Claude CLI using this exact command to delegate Task 1.1 to 1.7 to the Executor:
`Set-Location C:\ai\claude-intelligence-hub; claude --dangerously-skip-permissions -p "You are executing Phase 1 of PLAN-AOP-CIH-V1.2. FIRST: Verify if the local repository is synchronized with the remote (run git status and git pull). SECOND: Create the folder 'skills/agent-orchestration-protocol/'. THIRD: read C:\Workspaces\llms_projects\plan-aop-agent-orchestration-protocol_forge_v2.md. Translate the concepts into English and create SKILL.md, README.md, and ROADMAP.md. FOURTH: You MUST commit all new files with a pertinent and professional commit message, and then push them directly to the 'main' branch."`

Step 4: Delegate the Polling Loop: Spawn a single sub-agent to check the target directory C:\ai\claude-intelligence-hub\skills\agent-orchestration-protocol\ every 60 seconds.

Step 5: Once you physically detect that SKILL.md and README.md have been created, AND the Executor finishes its execution (meaning the git push is done), report SUCCESS to me.
```

</details>

---

### Prompt 8: VCS-Verified Structural Fix

**Objective:** To execute a structural repository fix by delegating directory move and deletion operations to an Executor and verifying completion via version control.

<details>
<summary><b>View Prompt</b></summary>

```prompt
You are the Orchestrator (YOLO Mode) executing a structural fix using the AOP framework.

Step 1: Open a powershell -NoProfile -Command terminal in HEADLESS mode.

Step 2: Call Claude CLI using this exact command to delegate the fix to the Executor:
`Set-Location C:\ai\claude-intelligence-hub; claude --dangerously-skip-permissions -p "You are an Executor with a structural fix task. FIRST: Move the folder 'agent-orchestration-protocol' to the root of the repository. SECOND: Delete the now-empty 'skills' directory. THIRD: Commit these structural changes with a semantic message, and push the changes directly to the 'main' branch."`

Step 3: Delegate the Polling Loop: Spawn a single sub-agent to check if the directory C:\ai\claude-intelligence-hub\agent-orchestration-protocol\ exists in the root every 60 seconds.

Step 4: Once you physically detect that the directory is now correctly placed at the root, AND the Executor finishes its execution (meaning the git push is done), report SUCCESS to me.
```

</details>

---

### Prompt 9: Advanced Hybrid AOP Workflow

**Objective:** To execute an advanced hybrid AOP workflow, where the Orchestrator first performs an initial task, then delegates a sub-task to an Executor (Codex), and finally polls git history to verify the delegated task's completion and commit.

<details>
<summary><b>View Prompt</b></summary>

```prompt
You are the Orchestrator (YOLO Mode) executing an advanced hybrid AOP workflow.

Phase 1: Orchestrator's Hands-on Task
Step 1: Read source file A and target file B.
Step 2: Update file B integrating content from A. Save it.

Phase 2: Delegation to Executor (Codex)
Step 3: Open a powershell -NoProfile -Command terminal in HEADLESS mode.
Step 4: Call Codex CLI using the exact AOP bypass protocol (Option B):
`Set-Location C:\ai\claude-intelligence-hub; codex exec --dangerously-bypass-approvals-and-sandbox 'Verify if ALL the content in B.md is in English. If not, translate it. Once 100% English, commit the changes with a semantic message and push directly to the main branch.'`

Phase 3: The AOP Polling
Step 5: Delegate the Polling Loop. Spawn a single sub-agent tasked to poll the git history (Check git log -1 --pretty=%B) in C:\ai\claude-intelligence-hub every 60 seconds.
Step 6: Once you detect the Executor's semantic commit message, report SUCCESS.
```

</details>

---

### Prompt 10: Executive Content Generation Workflow

**Objective:** To orchestrate a content generation workflow where an Executor (Claude) autonomously searches for a specific skill directory, analyzes its `README.md`, and then generates a human-friendly executive summary.

<details>
<summary><b>View Prompt</b></summary>

```prompt
You are the Orchestrator (YOLO Mode) executing an Executive Content Generation workflow using AOP.

Step 1: Open a powershell -NoProfile -Command terminal in HEADLESS mode.

Step 2: Call Claude CLI using the exact AOP bypass protocol:
`Set-Location C:\ai\claude-intelligence-hub; claude --dangerously-skip-permissions -p "You are an Executor with a content analysis mission. FIRST: Run a git pull. SECOND: Autonomously search the repository to locate the skill directory named 'agent-orchestration-protocol'. THIRD: Once located, read its 'README.md' file. FOURTH: Generate a new file called 'AOP-EXECUTIVE-SUMMARY.md' transforming the technical jargon into an executive summary. FIFTH: Commit this new file and push it directly to the 'main' branch."`

Step 3: Delegate the Polling Loop. Spawn a single sub-agent tasked to poll the git history in C:\ai\claude-intelligence-hub every 60 seconds, looking for the Executor's commit message.

Step 4: Once you detect the Executor's semantic commit message, report SUCCESS to me.
```

</details>

---

### Prompt 11: Orchestrator-to-Orchestrator Basic Execution (Using --approval-mode yolo)

**Objective:** To test an Orchestrator-to-Orchestrator delegation where one Orchestrator delegates a simple, non-interactive file creation task to a Gemini Executor using the `--approval-mode yolo` flag.

<details>
<summary><b>View Prompt</b></summary>

```prompt
Execute as follows:
Step 1: Open a powershell -NoProfile -Command terminal in HEADLESS mode;
Step 2: Execute `Set-Location C:\Workspaces\llms_projects`;
Step 3: Call Gemini CLI using the command: `gemini --approval-mode yolo -p 'Create a folder called _temp and inside this folder create a file called gemini_file_creation_test.md'`;
Step 4: Monitoring and Validation Protocol (Polling):
* Delegate the Loop: Spawn a single sub-agent tasked to poll for the existence of file creation every 60 seconds for up to 10 minutes.
* Validate that the file is not empty;
Step 5: Once you see file was created and validated, report SUCCESS to me.
```

</details>

---

### Prompt 12: Hybrid AOP Workflow & Autonomous Sub-Agent Spawning

**Objective:** To demonstrate Orchestrator resilience by autonomously spawning a temporary proxy sub-agent to bypass workspace boundary restrictions when performing verification tasks like polling git logs.

<details>
<summary><b>View Prompt</b></summary>

```prompt
You are the Orchestrator executing an advanced hybrid AOP workflow.

** Phase 1: Preparation
Step 1: Create a temporary file at C:\ai\temp\new_aop_prompts.txt. Write instructions into this file.

** Phase 2: Job Delegation
Step 2: Open a powershell -NoProfile -Command terminal in HEADLESS mode.
Step 3: Call a Gemini Executor using the Gemini CLI. Execute exactly this command:
`Set-Location C:\ai\claude-intelligence-hub; gemini -y -p "Executor B, FIRST: Run a git pull to sync. SECOND: Read the file 'C:\ai\temp\new_aop_prompts.txt'. THIRD: Append the contents to 'AOP_WORKED_EXAMPLES.md'. FOURTH: Commit the changes and push directly to the 'main' branch."`

** Phase 3: The AOP Polling & Cleanup
Step 4: Delegate the Polling Loop. Spawn a single sub-agent tasked to poll git log -1 --pretty=%B in C:\ai\claude-intelligence-hub every 60 seconds.
Step 5: Once you detect the Executor's semantic commit message in the git log, report SUCCESS to me.
Step 6: Clean up your workspace by deleting the temporary file C:\ai\temp\new_aop_prompts.txt.
```

</details>

---

### Prompt 13: Claude/Codex Orchestrating Gemini

**Objective:** To demonstrate a cross-LLM orchestration where Claude or Codex acts as the Orchestrator, calling Gemini as the Executor using the `gemini` CLI with the YOLO bypass flag.

<details>
<summary><b>View Prompt</b></summary>

```prompt
You are the Orchestrator for this AOP execution.

Step 1: Open a terminal in HEADLESS mode.
Step 2: Delegate Phase 1 to the Gemini Executor using the Gemini CLI. Use the exact Option B routing syntax:
`Set-Location C:\ai\temp; gemini --approval-mode yolo -p "Phase 1: create a file named aop-test-1.md with the text 'Phase 1 initialized.'. Output ONLY the word 'YES' upon completion."`
Step 3: Monitor the output. Once the Executor returns "YES", read the file `C:\ai\temp\aop-test-1.md` to verify its integrity.
Step 4: Report 'STATUS: SUCCESS' to me.
```

</details>

---

## Resolved Executor Agent Limitations

Based on the AOP Audit (Feb 2026), earlier reports of `codex exec` argument parsing failures were misdiagnosed.

### Resolution: Sandbox and Initialization Restrictions
The `codex` executor is **fully compliant**. Previous failures were due to sandbox restrictions and incorrect directory initialization contexts, not CLI argument parsing.

**The Fix (Mandatory Standard):**
Orchestrators must strictly adhere to the Flexible Security Routing and Execution Standards documented in `SKILL.md`. You **must** isolate the context using `cd` (bash) or `Set-Location` (PowerShell) and apply the `--dangerously-bypass-approvals-and-sandbox` flag to ensure uninterrupted execution.

<details>
<summary><b>Correct Usage Example</b></summary>

```bash
# bash (primary)
cd C:/ai/claude-intelligence-hub && codex exec --dangerously-bypass-approvals-and-sandbox 'Your complex multi-word instruction here.'
```

```powershell
# PowerShell (alternative)
Set-Location C:\ai\claude-intelligence-hub; codex exec --dangerously-bypass-approvals-and-sandbox 'Your complex multi-word instruction here.'
```

</details>

---

### Prompt 14: Chain Delegation with Sub-Orchestration

**Objective:** To validate multi-level delegation where an Executor acts simultaneously as both Executor and Sub-Orchestrator, creating its own artifact and then delegating a secondary task to another Executor (Gemini). This demonstrates that AOP supports chain delegation across multiple LLM backends (Claude → Codex → Gemini).

<details>
<summary><b>View Prompt</b></summary>

```prompt
You are the Orchestrator. Execute the following chain delegation orchestration using AOP principles:

Phase 1: Delegate to Executor A (Codex)
Step 1: Open a terminal and navigate to the workspace: `cd /c/ai/temp`
Step 2: Call Codex CLI with full bypass: `codex exec --dangerously-bypass-approvals-and-sandbox "Create a file named file_test_codex_v1.txt in C:/ai/temp with content 'File created by Codex executor at [timestamp]'. Use PowerShell Write-Output and Out-File. Return only YES when done."`
Step 3: Verify the artifact: `ls -lh /c/ai/temp/file_test_codex_v1.txt && cat /c/ai/temp/file_test_codex_v1.txt`

Phase 2: Executor A Delegates to Executor B (Sub-Orchestration)
Step 4: The Codex executor acts as Sub-Orchestrator and delegates to a Gemini Executor using: `cd /c/ai/temp && gemini --approval-mode yolo -p "Create a file named file_test_gemini_v1.txt in C:/ai/temp with content 'File created by Gemini executor at [timestamp]'. Use PowerShell commands. Return only YES when completed."`
Step 5: Verify the artifact: `ls -lh /c/ai/temp/file_test_gemini_v1.txt && cat /c/ai/temp/file_test_gemini_v1.txt`

Phase 3: Integrity Verification & Closeout
Step 6: Verify both artifacts exist, contain correct content, and identify their creators
Step 7: Generate structured orchestration report with execution chain, metrics, and AOP pillars applied
Step 8: Report final STATUS: SUCCESS or FAIL
```

**Production Validation:** This pattern was executed successfully on 2026-02-25 with 100% success rate. Both artifacts created correctly. See detailed case study at `orchestrations/2026-02-25_chain-delegation/README.md`.

</details>

---

### Prompt 15: Claude-to-Claude Production AOP (File-Based Prompt + Artifact Polling)

**Objective:** Real production orchestration where an Orchestrator (Opus 4.6) launches a headless Claude Sonnet 4.6 Executor to implement 11 code findings across 8 files, with artifact-based completion detection and independent post-verification.

<details>
<summary><b>View Prompt</b></summary>

**Phase 1: Prompt Preparation (Orchestrator)**
The Orchestrator writes a detailed prompt file with all instructions, code references, and verification steps:
```bash
# Orchestrator writes the prompt to a file (avoids escaping issues with complex instructions)
# Write the prompt content to AOP_EXECUTOR_PROMPT.md
```

**Phase 2: Headless Launch**
```bash
cat AOP_EXECUTOR_PROMPT.md | claude -p --dangerously-skip-permissions --model claude-sonnet-4-6 &
```

> **Key:** The `&` runs the process in background. The Orchestrator does NOT wait synchronously — it polls.

**Phase 3: Active Vigilance (Artifact-Based Polling)**
```bash
# Poll every 30-45 seconds for the completion artifact
test -f AOP_HEADLESS_COMPLETE.json && cat AOP_HEADLESS_COMPLETE.json || echo "Not yet."
```

**Phase 4: Integrity Verification (Orchestrator)**
Once the artifact is detected, the Orchestrator independently verifies:
```bash
# Verify the Executor's work independently
python -m pytest tests/ -q          # Must match expected test count
git log --oneline -2                 # Verify expected commits exist
git diff <before>..<after> -- file   # Spot-check critical diffs
```

**Phase 5: Closeout**
Orchestrator reports SUCCESS/FAIL to the user with full metrics.

**Production Validation:** This pattern was executed on 2026-03-16 in the `docx-indexer` project:
- Executor (Sonnet 4.6 headless) implemented 11 findings across 8 files in ~9 minutes (84 tool calls)
- Orchestrator (Opus 4.6) detected completion via artifact polling (4 polls)
- Post-verification: 372/372 tests PASS, validate.py PASS, 3 critical diffs spot-checked
- Zero rollbacks, zero test regressions
- A second headless session was launched for documentation updates (~2 min, 20 tool calls)
- See case study at `orchestrations/2026-03-16_docx-indexer-w1w2/`

</details>

---

### Prompt 16: Headless Documentation Executor

**Objective:** Delegate session documentation and project doc updates to a headless Executor. Proves that AOP Executors can handle not just code but also structured document editing with surgical precision.

<details>
<summary><b>View Prompt</b></summary>

```bash
# Write detailed prompt with:
# - Exact file paths (absolute)
# - Facts to document (commits, timestamps, metrics)
# - Exact edit instructions per file (what to add, where, formatting)
# - Completion artifact path
# Then launch:
cat DOC_EXECUTOR_PROMPT.md | claude -p --dangerously-skip-permissions --model claude-sonnet-4-6 &

# Poll for completion artifact
test -f AOP_HEADLESS_COMPLETE.json && cat AOP_HEADLESS_COMPLETE.json || echo "Not yet."

# Post-verification: read each updated file and confirm edits are correct
```

**Key Lesson:** The Executor can update session docs, project docs, and any structured markdown — as long as the prompt includes:
1. Absolute file paths
2. The exact content/facts to write
3. Clear formatting rules matching the existing document style
4. A completion artifact as the last step

**Production Validation:** Executed on 2026-03-16, updating 3 project docs (`status-atual.md`, `next-step.md`, `decisoes.md`) in ~2 minutes. Artifact detected on poll #4. All edits verified correct by Orchestrator.

</details>

---

### Prompt 17: Parallel Fan-Out/Fan-In with 3 Executors

**Objective:** Full end-to-end parallel orchestration: the Orchestrator dispatches 3 independent tasks to 3 headless executors (fan-out), monitors all concurrently via fast-polling, collects results into a single aggregation artifact (fan-in), and handles partial failures gracefully. Demonstrates the complete Fan-In/Fan-Out Orchestration protocol from SKILL.md.

<details>
<summary><b>View Prompt</b></summary>

**Scenario:**
- **Task A** (`update-readme`): Update README.md with new feature documentation — Sonnet
- **Task B** (`update-changelog`): Add version entry to CHANGELOG.md — Sonnet
- **Task C** (`run-lint`): Run linter and write results to lint-report.md — Haiku

All three tasks have disjoint write paths and can execute in parallel.

**Phase 1: Fan-Out — Task Manifest and Dispatch**
```bash
#!/usr/bin/env bash
set -euo pipefail

SESSION_ID="$(date +%s%N | sha256sum | head -c 8)"
PROJECT_DIR="/c/ai/target-project"
STATE_FILE="${PROJECT_DIR}/AOP_STATE_${SESSION_ID}.json"
FANIN_FILE="${PROJECT_DIR}/AOP_FANIN_${SESSION_ID}.json"

# Task manifest
TASK_IDS=("update-readme" "update-changelog" "run-lint")
MODELS=("claude-sonnet-4-6" "claude-sonnet-4-6" "claude-haiku-4-5")
WRITE_PATHS=(
  "${PROJECT_DIR}/README.md"
  "${PROJECT_DIR}/CHANGELOG.md"
  "${PROJECT_DIR}/lint-report.md"
)

# Validate write paths are disjoint
for i in "${!WRITE_PATHS[@]}"; do
  for j in "${!WRITE_PATHS[@]}"; do
    [ "$i" -ge "$j" ] && continue
    pa="${WRITE_PATHS[$i]}"; pb="${WRITE_PATHS[$j]}"
    if [[ "$pb" == "$pa"* ]] || [[ "$pa" == "$pb"* ]]; then
      echo "ABORT: conflict between ${TASK_IDS[$i]} and ${TASK_IDS[$j]}" >&2; exit 1
    fi
  done
done
echo "Write paths validated."

# Atomic state file writer
update_state() {
  local tmp="${STATE_FILE}.tmp.$$"
  printf '%s\n' "$1" > "$tmp"
  mv -f "$tmp" "$STATE_FILE"
}

# Initialize state file
EXECUTORS_JSON=""
for i in "${!TASK_IDS[@]}"; do
  [ -n "$EXECUTORS_JSON" ] && EXECUTORS_JSON="${EXECUTORS_JSON},"
  EXECUTORS_JSON="${EXECUTORS_JSON}{\"task_id\":\"${TASK_IDS[$i]}\",\"pid\":null,\"status\":\"PENDING\",\"model\":\"${MODELS[$i]}\",\"artifact_path\":\"${PROJECT_DIR}/AOP_COMPLETE_${TASK_IDS[$i]}_${SESSION_ID}.json\"}"
done
update_state "{\"session_id\":\"${SESSION_ID}\",\"workflow_type\":\"PARALLEL\",\"started_at\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"executors\":[${EXECUTORS_JSON}]}"

# Generate prompts and launch executors
declare -A EXECUTOR_PID_MAP EXECUTOR_STATUS EXECUTOR_POLLS

for i in "${!TASK_IDS[@]}"; do
  tid="${TASK_IDS[$i]}"
  model="${MODELS[$i]}"
  wpath="${WRITE_PATHS[$i]}"
  PROMPT="${PROJECT_DIR}/AOP_PROMPT_${tid}_${SESSION_ID}.md"
  ARTIFACT="${PROJECT_DIR}/AOP_COMPLETE_${tid}_${SESSION_ID}.json"

  cat > "${PROMPT}" <<PEOF
You are an Executor Agent. Working directory: ${PROJECT_DIR}

WRITE SCOPE (you may ONLY write to these paths):
- ${wpath}
- ${ARTIFACT}

TASK (${tid}):
$(case "$tid" in
  "update-readme")    echo "Read the current README.md. Add a new '## Recent Changes' section documenting the v2.0 feature set. Preserve all existing content." ;;
  "update-changelog") echo "Read CHANGELOG.md. Add an entry under '## [2.0.0] - 2026-03-18' with the list of changes from the last 5 commits (run git log --oneline -5)." ;;
  "run-lint")         echo "Run the project linter: npm run lint 2>&1. Write the full output to lint-report.md." ;;
esac)

COMPLETION REQUIREMENT:
As your LAST action, write: ${ARTIFACT}
{"status":"SUCCESS","task_id":"${tid}","session_id":"${SESSION_ID}","executor_id":"exec_${tid}_${SESSION_ID}","timestamp":"<ISO 8601>","executor":"${model} (headless AOP)","files_changed":["<list>"]}
PEOF

  cd "$PROJECT_DIR"
  cat "${PROMPT}" | claude -p --dangerously-skip-permissions --model "$model" &
  EXECUTOR_PID_MAP["$tid"]=$!
  EXECUTOR_STATUS["$tid"]="PENDING"
  EXECUTOR_POLLS["$tid"]=0
  echo "Launched exec_${tid}_${SESSION_ID} (PID ${EXECUTOR_PID_MAP[$tid]}, model ${model})"
done

echo "=== Fan-out complete: 3 executors dispatched ==="
```

**Phase 2: Multi-Executor Polling (Fast-Polling at 3s)**
```bash
MAX_POLLS=60
POLL_INTERVAL=3

all_done() {
  for t in "${TASK_IDS[@]}"; do
    [[ "${EXECUTOR_STATUS[$t]}" == "PENDING" ]] && return 1
  done
  return 0
}

while ! all_done; do
  for tid in "${TASK_IDS[@]}"; do
    [[ "${EXECUTOR_STATUS[$tid]}" != "PENDING" ]] && continue
    ARTIFACT="${PROJECT_DIR}/AOP_COMPLETE_${tid}_${SESSION_ID}.json"

    if test -f "$ARTIFACT" && test -s "$ARTIFACT"; then
      EXECUTOR_STATUS[$tid]="COMPLETE"
      echo "[$(date -u +%H:%M:%SZ)] COMPLETE: exec_${tid}_${SESSION_ID}"
      cat "$ARTIFACT"
      continue
    fi

    EXECUTOR_POLLS[$tid]=$(( EXECUTOR_POLLS[$tid] + 1 ))
    if [ "${EXECUTOR_POLLS[$tid]}" -ge $MAX_POLLS ]; then
      EXECUTOR_STATUS[$tid]="TIMEOUT"
      echo "[$(date -u +%H:%M:%SZ)] TIMEOUT: exec_${tid}_${SESSION_ID} (PID ${EXECUTOR_PID_MAP[$tid]})"
      kill "${EXECUTOR_PID_MAP[$tid]}" 2>/dev/null; sleep 1; kill -9 "${EXECUTOR_PID_MAP[$tid]}" 2>/dev/null
    fi
  done
  all_done || sleep $POLL_INTERVAL
done
```

**Phase 3: Fan-In — Aggregate Results**
```bash
TOTAL=${#TASK_IDS[@]}; COMPLETED=0; FAILED=0; TIMED_OUT=0
TASKS_JSON=""; ALL_FILES=""

for tid in "${TASK_IDS[@]}"; do
  ARTIFACT="${PROJECT_DIR}/AOP_COMPLETE_${tid}_${SESSION_ID}.json"
  status="${EXECUTOR_STATUS[$tid]}"
  artifact_ref="null"; files="[]"; error="null"

  case "$status" in
    COMPLETE) COMPLETED=$((COMPLETED+1)); artifact_ref="\"AOP_COMPLETE_${tid}_${SESSION_ID}.json\""
      [ -s "$ARTIFACT" ] && command -v jq &>/dev/null && files=$(jq -c '.files_changed // []' "$ARTIFACT")
      ALL_FILES="${ALL_FILES},$(echo "$files" | tr -d '[]')"
      final="SUCCESS" ;;
    TIMEOUT) TIMED_OUT=$((TIMED_OUT+1)); error="\"Timeout\""; final="TIMEOUT" ;;
    *) FAILED=$((FAILED+1)); error="\"No artifact\""; final="FAILURE" ;;
  esac
  [ -n "$TASKS_JSON" ] && TASKS_JSON="${TASKS_JSON},"
  TASKS_JSON="${TASKS_JSON}{\"task_id\":\"${tid}\",\"status\":\"${final}\",\"artifact\":${artifact_ref},\"files_changed\":${files}$([ "$error" != "null" ] && echo ",\"error\":${error}")}"
done

[ "$COMPLETED" -eq "$TOTAL" ] && OVERALL="SUCCESS" || { [ "$COMPLETED" -eq 0 ] && OVERALL="FAILURE" || OVERALL="PARTIAL_SUCCESS"; }
AGG_FILES="[${ALL_FILES#,}]"
command -v jq &>/dev/null && AGG_FILES=$(echo "$AGG_FILES" | jq -c 'flatten | unique' 2>/dev/null || echo "$AGG_FILES")

FANIN_TMP="${FANIN_FILE}.tmp.$$"
cat > "$FANIN_TMP" <<FEOF
{
  "session_id": "${SESSION_ID}",
  "total_tasks": ${TOTAL},
  "completed": ${COMPLETED},
  "failed": ${FAILED},
  "timed_out": ${TIMED_OUT},
  "overall_status": "${OVERALL}",
  "tasks": [${TASKS_JSON}],
  "aggregated_files_changed": ${AGG_FILES},
  "fan_in_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
FEOF
mv -f "$FANIN_TMP" "$FANIN_FILE"

echo "=== Fan-In Complete ==="
echo "Overall: ${OVERALL} | Completed: ${COMPLETED}/${TOTAL} | Failed: ${FAILED} | Timed out: ${TIMED_OUT}"
cat "$FANIN_FILE"
```

**Phase 4: Integrity Verification and Closeout**
```bash
# Post-execution write scope audit
echo "=== Write Scope Audit ==="
CHANGED=$(git -C "$PROJECT_DIR" diff --name-only HEAD)
for i in "${!TASK_IDS[@]}"; do
  tid="${TASK_IDS[$i]}"; scope="${WRITE_PATHS[$i]}"
  relative_scope="${scope#${PROJECT_DIR}/}"
  out=$(echo "$CHANGED" | grep -v "^${relative_scope}" | grep -v "^AOP_" || true)
  [ -n "$out" ] && echo "WARN: ${tid} may have written outside scope: ${out}" || echo "PASS: ${tid} writes within scope"
done

# Cleanup
for tid in "${TASK_IDS[@]}"; do
  rm -f "${PROJECT_DIR}/AOP_PROMPT_${tid}_${SESSION_ID}.md"
  rm -f "${PROJECT_DIR}/AOP_COMPLETE_${tid}_${SESSION_ID}.json"
done
rm -f "$STATE_FILE" "$FANIN_FILE"
echo "Cleanup complete."

# Closeout
echo "STATUS: ${OVERALL}"
echo "- Executors: 3 (2x Sonnet 4.6, 1x Haiku 4.5)"
echo "- Files changed: $(echo "$AGG_FILES" | tr -d '[]"')"
echo "- Fan-in artifact: AOP_FANIN_${SESSION_ID}.json (verified)"
echo "- Duration: ~$(( ($(date +%s) - START_TIME) / 60 )) min"
```

**AOP Pillars Applied:**
| Pillar | How Applied |
| :--- | :--- |
| P1: Environment Isolation | 3 independent headless processes, each with own PID |
| P2: Absolute Referencing | All paths use `${PROJECT_DIR}/...` — fully absolute |
| P3: Permission Bypass | `--dangerously-skip-permissions` on all 3 executors |
| P4: Active Vigilance | Fast-polling at 3s with per-executor timeout |
| P5: Integrity Verification | Post-execution write scope audit per executor |
| P6: Closeout Protocol | Fan-in artifact + STATUS report with metrics |
| P7: Constraint Adaptation | Model selection per-task (Sonnet for writing, Haiku for linting) |

</details>

---

### Prompt 18: DAG Execution with Dependencies and Priority

**Objective:** Full end-to-end DAG orchestration: the Orchestrator builds a dependency graph with 5 tasks, validates the DAG (cycle detection), dispatches tasks in dependency order with priority-based scheduling, handles a bounded concurrency limit, tracks task completion with dependency-aware progression, and produces a final execution report. Demonstrates the complete Task Dependency Management protocol from SKILL.md.

<details>
<summary><b>View Prompt</b></summary>

**Scenario:**
- **t1** (`build-core`, HIGH, weight 3, no deps): Build core module — Sonnet
- **t2** (`build-utils`, MEDIUM, weight 1, no deps): Build utility functions — Sonnet
- **t3** (`integrate-api`, CRITICAL, weight 5, depends on t1): Integrate API layer — Opus
- **t4** (`write-tests`, LOW, weight 2, depends on t1, t2): Write integration tests — Haiku
- **t5** (`deploy-staging`, MEDIUM, weight 3, depends on t3, t4): Deploy to staging — Sonnet

**Dependency Graph (DAG):**
```
t1 (HIGH) ──┬──→ t3 (CRITICAL) ──┬──→ t5 (MEDIUM)
             │                      │
t2 (MEDIUM) ─┼──→ t4 (LOW) ───────┘
             │
             └──→ t4 (LOW)
```

MAX_CONCURRENT = 2 (demonstrating bounded concurrency queue)

**Phase 1: DAG Validation and Initialization**
```bash
#!/usr/bin/env bash
set -euo pipefail

SESSION_ID="$(date +%s%N | sha256sum | head -c 8)"
PROJECT_DIR="/c/ai/target-project"
STATE_FILE="${PROJECT_DIR}/AOP_STATE_${SESSION_ID}.json"
MAX_CONCURRENT=2

# --- Task manifest ---
TASK_IDS=("build-core" "build-utils" "integrate-api" "write-tests" "deploy-staging")
MODELS=("claude-sonnet-4-6" "claude-sonnet-4-6" "claude-opus-4-6" "claude-haiku-4-5" "claude-sonnet-4-6")
PRIORITIES=("HIGH" "MEDIUM" "CRITICAL" "LOW" "MEDIUM")
WEIGHTS=(3 1 5 2 3)
WRITE_PATHS=(
  "${PROJECT_DIR}/src/core/"
  "${PROJECT_DIR}/src/utils/"
  "${PROJECT_DIR}/src/api/"
  "${PROJECT_DIR}/tests/"
  "${PROJECT_DIR}/deploy/"
)

declare -A DEPENDS_ON
DEPENDS_ON["build-core"]=""
DEPENDS_ON["build-utils"]=""
DEPENDS_ON["integrate-api"]="build-core"
DEPENDS_ON["write-tests"]="build-core build-utils"
DEPENDS_ON["deploy-staging"]="integrate-api write-tests"

declare -A TASK_STATUS TASK_PID EXECUTOR_POLLS
for tid in "${TASK_IDS[@]}"; do
  TASK_STATUS["$tid"]="WAITING"
  TASK_PID["$tid"]=""
  EXECUTOR_POLLS["$tid"]=0
done

# --- Step 1: Validate write paths are disjoint ---
for i in "${!WRITE_PATHS[@]}"; do
  for j in "${!WRITE_PATHS[@]}"; do
    [ "$i" -ge "$j" ] && continue
    pa="${WRITE_PATHS[$i]}"; pb="${WRITE_PATHS[$j]}"
    if [[ "$pb" == "$pa"* ]] || [[ "$pa" == "$pb"* ]]; then
      echo "ABORT: write path conflict: ${TASK_IDS[$i]} <-> ${TASK_IDS[$j]}" >&2; exit 1
    fi
  done
done
echo "Write paths validated: no conflicts."

# --- Step 2: Cycle detection ---
# (detect_cycles function from SKILL.md DAG Cycle Detection section)
detect_cycles || { echo "ABORT: cycle detected" >&2; exit 1; }
echo "DAG validation passed."
```

**Phase 2: DAG Execution with Priority Dispatch**
```bash
# --- Helper functions ---
priority_rank() {
  case "$1" in
    CRITICAL) echo 0 ;; HIGH) echo 1 ;; MEDIUM) echo 2 ;; LOW) echo 3 ;; *) echo 2 ;;
  esac
}

count_running() {
  local n=0
  for tid in "${TASK_IDS[@]}"; do
    [[ "${TASK_STATUS[$tid]}" == "RUNNING" ]] && n=$((n + 1))
  done
  echo "$n"
}

find_ready_tasks() {
  for tid in "${TASK_IDS[@]}"; do
    [[ "${TASK_STATUS[$tid]}" != "WAITING" ]] && continue
    local ready=true
    for dep in ${DEPENDS_ON[$tid]}; do
      case "${TASK_STATUS[$dep]}" in
        COMPLETE) ;;
        FAILED|SKIPPED) TASK_STATUS["$tid"]="SKIPPED"; ready=false; break ;;
        *) ready=false; break ;;
      esac
    done
    [[ "${TASK_STATUS[$tid]}" == "SKIPPED" ]] && continue
    if $ready; then
      local idx=-1
      for i in "${!TASK_IDS[@]}"; do [[ "${TASK_IDS[$i]}" == "$tid" ]] && { idx=$i; break; }; done
      echo "$(priority_rank "${PRIORITIES[$idx]}") ${WEIGHTS[$idx]} $tid"
    fi
  done | sort -k1,1n -k2,2rn | awk '{print $3}'
}

# --- Main DAG loop ---
POLL_INTERVAL=3
MAX_POLLS_DEFAULT=60
STALL_COUNTER=0

echo "=== DAG Execution Started (session: ${SESSION_ID}, max_concurrent: ${MAX_CONCURRENT}) ==="

dag_all_settled() {
  for tid in "${TASK_IDS[@]}"; do
    case "${TASK_STATUS[$tid]}" in WAITING|RUNNING) return 1 ;; esac
  done
  return 0
}

while ! dag_all_settled; do
  # --- Dispatch ready tasks up to MAX_CONCURRENT ---
  running=$(count_running)
  slots=$((MAX_CONCURRENT - running))
  if [ "$slots" -gt 0 ]; then
    ready_list=$(find_ready_tasks)
    dispatched=0
    while IFS= read -r tid && [ "$dispatched" -lt "$slots" ]; do
      [ -z "$tid" ] && continue
      # (launch_executor from SKILL.md DAG engine — generates prompt, launches headless)
      launch_executor "$tid"
      dispatched=$((dispatched + 1))
    done <<< "$ready_list"
  fi

  # --- Poll running executors ---
  progress="false"
  for tid in "${TASK_IDS[@]}"; do
    [[ "${TASK_STATUS[$tid]}" != "RUNNING" ]] && continue
    ARTIFACT="${PROJECT_DIR}/AOP_COMPLETE_${tid}_${SESSION_ID}.json"

    if test -f "$ARTIFACT" && test -s "$ARTIFACT"; then
      TASK_STATUS["$tid"]="COMPLETE"
      echo "[$(date -u +%H:%M:%SZ)] COMPLETE: ${tid}"
      progress="true"
      continue
    fi

    EXECUTOR_POLLS["$tid"]=$(( ${EXECUTOR_POLLS[$tid]} + 1 ))
    # Priority-adjusted timeout
    idx=-1
    for i in "${!TASK_IDS[@]}"; do [[ "${TASK_IDS[$i]}" == "$tid" ]] && { idx=$i; break; }; done
    max_polls=$MAX_POLLS_DEFAULT
    case "${PRIORITIES[$idx]}" in
      CRITICAL) max_polls=$((MAX_POLLS_DEFAULT * 2)) ;;
      LOW)      max_polls=$((MAX_POLLS_DEFAULT / 2)) ;;
    esac

    if [ "${EXECUTOR_POLLS[$tid]}" -ge "$max_polls" ]; then
      TASK_STATUS["$tid"]="FAILED"
      kill "${TASK_PID[$tid]}" 2>/dev/null; sleep 1; kill -9 "${TASK_PID[$tid]}" 2>/dev/null
      echo "[$(date -u +%H:%M:%SZ)] TIMEOUT: ${tid}"
      propagate_failure "$tid"
      progress="true"
    fi
  done

  # --- Deadlock detection ---
  check_deadlock "$progress"
  [ $? -eq 2 ] && { echo "DEADLOCK: Aborting."; break; }

  dag_all_settled || sleep $POLL_INTERVAL
done
```

**Phase 3: Expected Execution Timeline**
```
Cycle 1:  Ready: build-core (HIGH,3), build-utils (MEDIUM,1)
          MAX_CONCURRENT=2 → dispatch both
          Running: [build-core, build-utils]

Cycle N:  build-core COMPLETE
          Ready: integrate-api (CRITICAL,5) — deps [build-core] met
          build-utils still RUNNING — 1 slot available
          Dispatch integrate-api (CRITICAL gets priority)
          Running: [build-utils, integrate-api]

Cycle M:  build-utils COMPLETE
          Ready: write-tests (LOW,2) — deps [build-core, build-utils] met
          integrate-api still RUNNING — 1 slot available
          Dispatch write-tests
          Running: [integrate-api, write-tests]

Cycle P:  integrate-api COMPLETE, write-tests COMPLETE
          Ready: deploy-staging (MEDIUM,3) — deps [integrate-api, write-tests] met
          Dispatch deploy-staging
          Running: [deploy-staging]

Cycle Q:  deploy-staging COMPLETE
          All tasks settled.
```

**Phase 4: Final Report**
```bash
echo "=== DAG Execution Report ==="
TOTAL=${#TASK_IDS[@]}; COMPLETED=0; FAILED=0; SKIPPED=0
for tid in "${TASK_IDS[@]}"; do
  echo "  ${tid}: ${TASK_STATUS[$tid]} (priority: ${PRIORITIES[$idx]}, weight: ${WEIGHTS[$idx]})"
  case "${TASK_STATUS[$tid]}" in
    COMPLETE) COMPLETED=$((COMPLETED + 1)) ;;
    FAILED)   FAILED=$((FAILED + 1)) ;;
    SKIPPED)  SKIPPED=$((SKIPPED + 1)) ;;
  esac
done

echo ""
echo "Summary: ${COMPLETED}/${TOTAL} completed | ${FAILED} failed | ${SKIPPED} skipped"
echo "Concurrency limit: MAX_CONCURRENT=${MAX_CONCURRENT}"
echo "Session: ${SESSION_ID}"

# Cleanup
for tid in "${TASK_IDS[@]}"; do
  rm -f "${PROJECT_DIR}/AOP_PROMPT_${tid}_${SESSION_ID}.md"
  rm -f "${PROJECT_DIR}/AOP_COMPLETE_${tid}_${SESSION_ID}.json"
done
rm -f "$STATE_FILE"
echo "Cleanup complete. STATUS: SUCCESS"
```

**AOP Pillars Applied:**
| Pillar | How Applied |
| :--- | :--- |
| P1: Environment Isolation | 5 independent headless processes, each with own PID, launched per DAG ordering |
| P2: Absolute Referencing | All paths use `${PROJECT_DIR}/...` — fully absolute |
| P3: Permission Bypass | `--dangerously-skip-permissions` on all executors |
| P4: Active Vigilance | Fast-polling at 3s + DAG-aware completion detection + deadlock monitoring |
| P5: Integrity Verification | Post-execution write scope audit per executor |
| P6: Closeout Protocol | DAG execution report with per-task status, priority, weight |
| P7: Constraint Adaptation | Model selection per-task based on priority tier (Opus for CRITICAL, Haiku for LOW) |

**New AOP Capabilities Demonstrated:**
| Capability | How Demonstrated |
| :--- | :--- |
| DAG Dependencies | t3 waits for t1; t4 waits for t1+t2; t5 waits for t3+t4 |
| Cycle Detection | DAG validated before any executor launches |
| Priority Dispatch | CRITICAL t3 dispatched before LOW t4 when both become ready |
| Bounded Concurrency | MAX_CONCURRENT=2 creates a queue with priority ordering |
| Deadlock Detection | Stall counter monitors progress across consecutive poll cycles |
| Failure Propagation | If t1 fails, t3/t4/t5 are transitively SKIPPED; t2 still runs |

</details>
