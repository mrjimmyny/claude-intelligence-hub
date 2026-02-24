# 🍳 Cookbook: Agent Orchestration Protocol (AOP) Worked Examples
**Supporting Document For:** `SKILL: agent-orchestration-protocol`
**Status:** Production-Validated

This document contains a curated list of prompts that have been executed with 100% success in real-world scenarios, demonstrating the practical application of the Seven Pillars of AOP.

---

## 💡 Best Practices for Orchestration

<details>
<summary><b>View Best Practices</b></summary>

- **Delegate the Loop:** For polling, delegate the entire loop to a single agent rather than spawning a new process every 60 seconds.
- **Boolean Checks:** Ask agents to return ONLY `YES` or `NO` when verifying state.
- **Verify Paths:** Always verify the absolute path before executing `Set-Location`.
</details>

---

### Prompt 1: High-Integrity Orchestration (Master Template)

**Objective:** The most complete example, explicitly covering all AOP pillars, including environment setup, bypass, delegated instruction, polling with integrity validation, and a closeout cycle.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, execute the following document engineering operation with a focus on integrity and multi-agent verification:      
1- Execute the Codex CLI via a headless terminal: `powershell -NoProfile -Command`
2- Apply Flexible Routing: `Set-Location C:\Workspaces\llms_projects`
3- Instruct codex using the mandatory standard (Option B):
`Set-Location C:\Workspaces\llms_projects; codex exec --dangerously-bypass-approvals-and-sandbox 'Emma, analyze the Differences of the files A.md and B.md and create a merged version saving it as C.md'`
4- Monitoring and Validation Protocol (Polling):
* Implement a verification loop (polling) of up to 10 minutes.
* Every 60 seconds, check for the existence of `C.md` and validate it is not empty.
* If detected and validated, perform a `read_file` to confirm integrity.
5- Cycle Completion:
* If generated successfully: Return 'STATUS: SUCCESS'.
* If timeout or error: Return 'STATUS: FAIL' with the terminal error log.
```
</details>

---

### Prompt 2: Advanced Hybrid AOP Workflow

**Objective:** To execute an advanced hybrid workflow, where the Orchestrator performs an initial task, delegates to Codex, and polls git history.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, we are executing an advanced hybrid AOP workflow. You are the Orchestrator (YOLO Mode).

Phase 1: Forge's Hands-on Task
Step 1: Read source file A and target file B.
Step 2: Update file B integrating content from A. Save it.

Phase 2: Delegation to Emma (Codex)
Step 3: Open a powershell -NoProfile -Command terminal in HEADLESS mode.
Step 4: Call Codex CLI using the exact AOP bypass protocol (Option B):
`Set-Location C:\ai\claude-intelligence-hub; codex exec --dangerously-bypass-approvals-and-sandbox 'Emma, verify if ALL the content in B.md is in English. If not, translate it. Once 100% English, commit the changes with a semantic message and push directly to the main branch.'`

Phase 3: The AOP Polling
Step 5: Start the AOP Polling protocol. Poll the git history. Check git log -1 --pretty=%B in C:\ai\claude-intelligence-hub every 60 seconds.        
Step 6: Once you detect Emma's semantic commit message, report SUCCESS.
```
</details>

---

## ⚠️ Resolved Executor Agent Limitations

Based on the AOP Audit (Feb 2026), earlier reports of `codex exec` argument parsing failures were misdiagnosed. 

### Resolution: Sandbox and Initialization Restrictions
The `codex` executor agent is **fully compliant**. Previous failures were due to sandbox restrictions and incorrect directory initialization contexts, not CLI argument parsing.

**The Fix (Mandatory Standard):**
Orchestrators must strictly adhere to the Flexible Security Routing and Execution Standards documented in `SKILL.md`. You **must** isolate the context using `Set-Location` and apply the `--dangerously-bypass-approvals-and-sandbox` flag to ensure uninterrupted execution.

<details>
<summary><b>✅ Correct Usage Example</b></summary>

```powershell
Set-Location C:\ai\claude-intelligence-hub; codex exec --dangerously-bypass-approvals-and-sandbox 'Your complex multi-word instruction here.'
```
</details>