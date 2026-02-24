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

### Prompt 1: Basic Connectivity Test

**Objective:** Validate that the Orchestrator Agent can invoke a shell and execute a basic CLI command.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, lets perform a test. Open a powershell -NoProfile -Command terminal, change directory using `Set-Location C:\Workspaces\llms_projects`, and call Codex CLI using `codex exec --dangerously-bypass-approvals-and-sandbox 'Return ONLY YES'`. Please just test this and tell me Success or Fail.
```

</details>

---

### Prompt 2: Simple File Creation

**Objective:** Test the ability of an Executor Agent (Codex/Emma) to create a file in the workspace after being granted permissions.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, lets perform the second test. Open a powershell -NoProfile -Command terminal. Then use Option B routing: `Set-Location C:\Workspaces\llms_projects; codex exec --dangerously-bypass-approvals-and-sandbox 'Create a file called emma_test_file_creation.md'`
```

</details>

---

### Prompt 3: Read and Create New Version

**Objective:** Delegate the task of reading a file, analyzing it, and creating a new, improved version to an Executor Agent.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Ok, let's try a new test. Open a powershell -NoProfile -Command terminal. Execute this exact command: `Set-Location C:\Workspaces\llms_projects; codex exec --dangerously-bypass-approvals-and-sandbox 'Read file draft_proposal_jimmy_v1.txt, analyse it 100% and create your own version based on my draft, improving it. Save your version as draft_proposal_emma_v1.md and finish the task.'` Report to me if Success or fail.
```

</details>

---

### Prompt 4: Sequential Two-Agent Orchestration

**Objective:** Orchestrate two Executor Agents (Codex and Claude) to perform the same task in sequence, with each creating its own artifact.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, please execute these tasks with codex CLI and claude code CLI.
Open a powershell -NoProfile -Command terminal.
Execute Codex using: `Set-Location C:\Workspaces\llms_projects; codex exec --dangerously-bypass-approvals-and-sandbox 'Read draft_proposal_jimmy_v1.md. Analyse it 100% and create your software engineer version, with your ideas and best market suggestions. Save it as draft_proposal_emma_v1.md. Finish with codex'`
Check if codex created file draft_proposal_emma_v1.md.
Do the same for Magneto using `Set-Location C:\Workspaces\llms_projects; claude --dangerously-skip-permissions -p 'Read draft_proposal_jimmy_v1.md and save your version as draft_proposal_magneto_v1.md'`.
Job done for all. Report to me SUCCESS or FAIL.
```

</details>

---

### Prompt 5: Orchestration with Merge, Delegation, and Polling

**Objective:** A complex workflow where the Orchestrator first creates a file, then delegates the review to an Executor, and finally monitors the creation of the final artifact.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, execute as follows:
Step 1: Access file MASTER_PROPOSAL_SECURITY_REVIEW.md and analyse it 100%;
Step 2: Compare to file MASTER_PROPOSAL.md;
Step 3: Create a new file called MASTER_PROPOSAL_Forge_final_review.md applying all corrections suggested;
Step 4: Open a powershell -NoProfile -Command terminal in HEADLESS mode;
Step 5: Navigate via `Set-Location C:\Workspaces\llms_projects` and call claude CLI: `claude --dangerously-skip-permissions -p 'Magneto, review MASTER_PROPOSAL_Forge_final_review.md then create MASTER_PROPOSAL_FINAL_Magneto.md with adjustments.'`
Step 6: Delegate the Polling Loop: Spawn a single sub-agent tasked to poll the directory every 60 seconds until MASTER_PROPOSAL_FINAL_Magneto.md is created, timing out after 10 minutes.
Step 7: Once the sub-agent reports the file was created, report SUCCESS or FAIL to me.
```

</details>

---

### Prompt 6: High-Integrity Orchestration (Master Template)

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

**Objective:** To orchestrate the creation of a new skill, including directory structure, documentation, and version control, by delegating a multi-step plan to another agent.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, we are executing Phase 1 of PLAN-AOP-CIH-V1.2. You are the Orchestrator (YOLO Mode).

Step 1: Read the full PLAN-AOP-CIH-V1.2 document to understand the deliverables: C:\Workspaces\llms_projects\plan-aop-agent-orchestration-protocol_forge_v2.md.

Step 2: Open a powershell -NoProfile -Command terminal in HEADLESS mode.

Step 3: Call Claude CLI using this exact command to delegate Task 1.1 to 1.7 to Magneto:
`Set-Location C:\ai\claude-intelligence-hub; claude --dangerously-skip-permissions -p "Magneto, you are executing Phase 1 of PLAN-AOP-CIH-V1.2. FIRST: Verify if the local repository is synchronized with the remote (run git status and git pull). SECOND: Create the folder 'skills/agent-orchestration-protocol/'. THIRD: read C:\Workspaces\llms_projects\plan-aop-agent-orchestration-protocol_forge_v2.md. Translate the concepts into English and create SKILL.md, README.md, and ROADMAP.md. FOURTH: You MUST commit all new files with a pertinent and professional commit message, and then push them directly to the 'main' branch."`

Step 4: Delegate the Polling Loop: Spawn a single sub-agent to check the target directory C:\ai\claude-intelligence-hub\skills\agent-orchestration-protocol\ every 60 seconds.

Step 5: Once you physically detect that SKILL.md and README.md have been created, AND Magneto finishes its execution (meaning the git push is done), report SUCCESS to me.
```

</details>

---

### Prompt 8: VCS-Verified Structural Fix

**Objective:** To execute a structural repository fix by delegating directory move and deletion operations to an executor agent and verifying completion via version control.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, we are executing a structural fix using the AOP framework. You are the Orchestrator (YOLO Mode).

Step 1: Open a powershell -NoProfile -Command terminal in HEADLESS mode.

Step 2: Call Claude CLI using this exact command to delegate the fix to Magneto:
`Set-Location C:\ai\claude-intelligence-hub; claude --dangerously-skip-permissions -p "Magneto, we have a structural issue. FIRST: Move the folder 'agent-orchestration-protocol' to the root of the repository. SECOND: Delete the now-empty 'skills' directory. THIRD: Commit these structural changes with a semantic message, and push the changes directly to the 'main' branch."`

Step 3: Delegate the Polling Loop: Spawn a single sub-agent to check if the directory C:\ai\claude-intelligence-hub\agent-orchestration-protocol\ exists in the root every 60 seconds. 

Step 4: Once you physically detect that the directory is now correctly placed at the root, AND Magneto finishes its execution (meaning the git push is done), report SUCCESS to me.
```

</details>

---

### Prompt 9: Advanced Hybrid AOP Workflow

**Objective:** To execute an advanced hybrid AOP workflow, where the Orchestrator first performs an initial task, then delegates a sub-task to another agent (Codex/Emma), and finally polls git history to verify the delegated task's completion and commit.

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
Step 5: Delegate the Polling Loop. Spawn a single sub-agent tasked to poll the git history (Check git log -1 --pretty=%B) in C:\ai\claude-intelligence-hub every 60 seconds.        
Step 6: Once you detect Emma's semantic commit message, report SUCCESS.
```

</details>

---

### Prompt 10: Executive Content Generation Workflow

**Objective:** To orchestrate a content generation workflow where an Executor Agent (Magneto) autonomously searches for a specific skill directory, analyzes its `README.md`, and then generates a human-friendly executive summary.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, we are executing an Executive Content Generation workflow using AOP. You are the Orchestrator (YOLO Mode).

Step 1: Open a powershell -NoProfile -Command terminal in HEADLESS mode.

Step 2: Call Claude CLI using the exact AOP bypass protocol:
`Set-Location C:\ai\claude-intelligence-hub; claude --dangerously-skip-permissions -p "Magneto, you have a content analysis mission. FIRST: Run a git pull. SECOND: Autonomously search the repository to locate the skill directory named 'agent-orchestration-protocol'. THIRD: Once located, read its 'README.md' file. FOURTH: Generate a new file called 'AOP-EXECUTIVE-SUMMARY.md' transforming the technical jargon into an executive summary. FIFTH: Commit this new file and push it directly to the 'main' branch."`

Step 3: Delegate the Polling Loop. Spawn a single sub-agent tasked to poll the git history in C:\ai\claude-intelligence-hub every 60 seconds, looking for Magneto's commit message.

Step 4: Once you detect Magneto's semantic commit message, report SUCCESS to me.
```

</details>

---

### Prompt 11: Forge-to-Forge Basic Execution (Using --approval-mode yolo)      

**Objective:** To test a Forge-to-Forge orchestration where one Forge agent (Orchestrator) delegates a simple, non-interactive file creation task to another Forge agent (Executor) using the Gemini CLI with a YOLO approval flag.

<details>
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, please execute as follows:
Step 1: Open a powershell -NoProfile -Command terminal in HEADLESS mode;
Step 2: Execute `Set-Location C:\Workspaces\llms_projects`;
Step 3: Call gemini CLI using the command: `gemini --approval-mode yolo -p 'Forge, create a folder called _temp and inside this folder create a file called forge_file_creation_test.md'`;
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
<summary><b>💻 View Prompt</b></summary>

```prompt
Forge, we are executing an advanced hybrid AOP workflow.

** Phase 1: Preparation
Step 1: Create a temporary file at C:\ai\temp\new_aop_prompts.txt. Write instructions into this file.

** Phase 2: Job Delegation
Step 2: Open a powershell -NoProfile -Command terminal in HEADLESS mode.
Step 3: Call another Agent, using the Gemini CLI. Execute exactly this command:
`Set-Location C:\ai\claude-intelligence-hub; gemini -y -p "Forge B, FIRST: Run a git pull to sync. SECOND: Read the file 'C:\ai\temp\new_aop_prompts.txt'. THIRD: Append the contents to 'AOP_WORKED_EXAMPLES.md'. FOURTH: Commit the changes and push directly to the 'main' branch."`

** Phase 3: The AOP Polling & Cleanup
Step 4: Delegate the Polling Loop. Spawn a single sub-agent tasked to poll git log -1 --pretty=%B in C:\ai\claude-intelligence-hub every 60 seconds.
Step 5: Once you detect Forge B's semantic commit message in the git log, report SUCCESS to me.
Step 6: Clean up your workspace by deleting the temporary file C:\ai\temp\new_aop_prompts.txt.
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