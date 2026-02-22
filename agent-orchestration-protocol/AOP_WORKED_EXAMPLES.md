# Cookbook: Agent Orchestration Protocol (AOP) Worked Examples
**Supporting Document For:** `SKILL: agent-orchestration-protocol`
**Status:** Production-Validated

This document contains a curated list of prompts that have been executed with 100% success in real-world scenarios, demonstrating the practical application of the AOP. They serve as a cookbook for Orchestrator Agents.

---

### Prompt 1: Basic Connectivity Test

**Objective:** Validate that the Orchestrator Agent can invoke a shell and execute a basic CLI command.

```prompt
Forge, lets perform a test. Can you open a powershell -NoProfile -Command terminal, call codex CLI into start folder C:\Workspaces\llms_projects? Please just test this and tell me Success or Fail.
```
**Analysis:** Covers **Pillar 1 (Environment Isolation)** in a simple way.

---

### Prompt 2: Simple File Creation

**Objective:** Test the ability of an Executor Agent (Codex/Emma) to create a file in the workspace after being granted permissions.

```prompt
Forge, lets perform the second test. open a powershell -NoProfile -Command terminal, call codex CLI into start folder C:\Workspaces\llms_projects. Then you have to put codex in full mode approval using /permissions and then choose 3. Then ask codex to create a file called emma_test_file_creation.md
```
**Analysis:** Adds **Pillar 3 (Permission Bypass)** through a simulated interactive command (`/permissions` + `3`).

---

### Prompt 3: Read and Create New Version

**Objective:** Delegate the task of reading a file, analyzing it, and creating a new, improved version to an Executor Agent.

```prompt
Ok, once we have all test passed 100%, let's try a new test, now with both CLIs, but one first, then another. Test: open a powershell -NoProfile -Command terminal, call codex CLI into start folder C:\Workspaces\llms_projects. Then you have to put codex CLI in full mode approval using /permissions and choose option 3 (full). Then you ask codex to read file draft_proposal_jimmy_v1.txt, analyse it 100% and codex have to create it's own version based on my draft, improving it. Codex must save its version as draft_proposal_emma_v1 and then finish the task. Report to me if Success or fail.
```
**Analysis:** Demonstrates a "read and create" workflow and the use of **Pillar 2 (Absolute Referencing)**, implied by the file name.

---

### Prompt 4: Sequential Two-Agent Orchestration

**Objective:** Orchestrate two Executor Agents (Codex and Claude) to perform the same task in sequence, with each creating its own artifact.

```prompt
Forge, please execute these tasks with codex CLI and claude code CLI.
open a powershell -NoProfile -Command terminal;
call codex CLI into start folder C:\Workspaces\llms_projects;
put codex CLI in full mode approval using /permissions and choose option 3 (full);
ask codex this way:'Read draft_proposal_jimmy_v1.md. Analyse it 100% and create your software engineer version, with your ideas and best market suggestions. Save it as draft_proposal_emma_v1.md C:\Workspaces\llms_projects. Finish with codex;
Check if codex created file draft_proposal_emma_v1.md;
Do the same, but now with claude code CLI. Claude Code saved file must be draft_proposal_magneto_v1.md;
job done for all. Report to me SUCESS or FAIL.
```
**Analysis:** A clear example of a sequential, multi-agent workflow.

---

### Prompt 5: Orchestration with Merge, Delegation, and Polling

**Objective:** A complex workflow where the Orchestrator first creates a file, then delegates the review to an Executor, and finally monitors the creation of the final artifact.

```prompt
Forge, execute as follows:
Step 1: Access file MASTER_PROPOSAL_SECURITY_REVIEW.md and analyse it 100%;
Step 2: Compare to file MASTER_PROPOSAL.md;
Step 3: Create a new file called MASTER_PROPOSAL_Forge_final_review.md applying all corrections suggested as MASTER_PROPOSAL_SECURITY_REVIEW.md merging the files into your final version;
Step 4: Open a powershell -NoProfile -Command terminal in HEADLESS mode;
Step 5: Call claude CLI using the command: claude --dangerously-skip-permissions -p and ask this way: 'Magneto, review file MASTER_PROPOSAL_Forge_final_review.md at C:\Workspaces\llms_projects then create a final proposal version called MASTER_PROPOSAL_FINAL_Magneto.md with all adjustments. Save it back at C:\Workspaces\llms_projects.';
Step 6: You Forge checks every minute if file was created by claude code;
Step 7: Once you see file was created, back to me and SUCCESS or FAIL. Job Done!
```
**Analysis:** Explicitly implements **Pillar 4 (Active Vigilance/Polling)** and a direct bypass flag (`--dangerously-skip-permissions`).

---

### Prompt 6: High-Integrity Orchestration (Master Template)

**Objective:** The most complete example, explicitly covering all AOP pillars, including environment setup, bypass, delegated instruction, polling with integrity validation, and a closeout cycle with a detailed status.

```prompt
Forge, execute the following document engineering operation with a focus on integrity and multi-agent verification:
1- Execute the Codex CLI via a headless terminal: `powershell -NoProfile -Command` directly in the directory: `C:\Workspaces\llms_projects`;
2- Put codex in full mode approval using the slash command `/permissions` and choose option `3`, full;
3- Instruct codex exactly as follows: 'Emma, analyze the Differences (Diff & Merge) of the files proposal-aop-agent-orchestration-protocol_forge_v1.md and proposal-aop-agent-orchestration-protocol_gmn-web_v1.md and create another version performing a technical merge, with your improvements and suggestions, saving it in C:\Workspaces\llms_projects. File name: proposal-aop-agent-orchestration-protocol_emma_review_v1.md';
4- Monitoring and Validation Protocol (Polling):
* Implement a verification loop (polling) of up to 10 minutes.
* Every 60 seconds, check for the existence of `proposal-aop-agent-orchestration-protocol_emma_review_v1.md` and validate that the file is not empty.
* If the file is detected and validated, perform a quick `read_file` to confirm content integrity.
5- Cycle Completion:
* If the file is generated successfully: Return 'STATUS: SUCCESS' and a brief summary of the critical sections added.
* If the timeout is reached or a CLI error occurs: Return 'STATUS: FAIL' with the terminal error log.
```
**Analysis:** Considered the "gold standard" for AOP delegation. It explicitly and robustly covers **Pillars 1, 2, 3, 4, 5, and 6**.

---

### Prompt 7: Full Lifecycle Feature Delegation

**Objective:** To orchestrate the creation of a new skill, including directory structure, documentation, and version control, by delegating a multi-step plan to another agent.

```prompt
Forge, we are executing Phase 1 of PLAN-AOP-CIH-V1.2. You are the Orchestrator (YOLO Mode).

Step 1: Read the full PLAN-AOP-CIH-V1.2 document to understand the deliverables: C:\Workspaces\llms_projects\plan-aop-agent-orchestration-protocol_forge_v2.md.

Step 2: Open a powershell -NoProfile -Command terminal in HEADLESS mode.

Step 3: Call Claude CLI using this exact command to delegate Task 1.1 to 1.7 to Magneto:
claude --dangerously-skip-permissions -p "Magneto, you are executing Phase 1 of PLAN-AOP-CIH-V1.2 in C:\ai\claude-intelligence-hub. FIRST: Verify if the local repository is synchronized with the remote (run git status and git pull). SECOND: Create the folder 'skills/agent-orchestration-protocol/'. THIRD: read C:\Workspaces\llms_projects\plan-aop-agent-orchestration-protocol_forge_v2.md and C:\Workspaces\llms_projects\AOP_WORKED_EXAMPLES.md. Translate the concepts into English and create the following files inside that folder: SKILL.md (with Security Boundaries), README.md (with Fallback & Recovery), and ROADMAP.md. Also, translate and save AOP_WORKED_EXAMPLES.md inside this new folder. FOURTH: You MUST commit all new files with a pertinent and professional commit message, and then push them directly to the 'main' branch. Do not wait for human confirmation. Report back when the push is successful."

Step 4: Start the AOP Polling protocol. Check the target directory C:\ai\claude-intelligence-hub\skills\agent-orchestration-protocol\ every 60 seconds.

Step 5: Once you physically detect that SKILL.md and README.md have been created, AND Magneto finishes its execution (meaning the git push is done), report SUCCESS to me. Provide a brief summary of the commit if possible.
```
**Analysis:** This prompt demonstrates a full lifecycle delegation for a feature. It combines **Pillar 2 (Absolute Referencing)** for source documents, **Pillar 4 (Active Vigilance/Polling)** to check for artifacts, and **Pillar 6 (Reliable Closeout)** by verifying the final git push. It's a complex, real-world project execution command.

---

### Prompt 8: VCS-Verified Structural Fix

**Objective:** To execute a structural repository fix by delegating directory move and deletion operations to an executor agent and verifying completion via version control.

```prompt
Forge, we are executing a structural fix using the AOP framework. You are the Orchestrator (YOLO Mode).

Step 1: Open a powershell -NoProfile -Command terminal in HEADLESS mode.

Step 2: Call Claude CLI using this exact command to delegate the fix to Magneto:
claude --dangerously-skip-permissions -p "Magneto, we have a structural issue in the repository at C:\ai\claude-intelligence-hub. You previously created a nested folder 'skills/agent-orchestration-protocol/', but our standard is to place skills directly in the root directory. FIRST: Move the folder 'agent-orchestration-protocol' to the root of the repository. SECOND: Delete the now-empty 'skills' directory. THIRD: Commit these structural changes with a semantic message like 'fix(skills): move agent-orchestration-protocol to repo root to match architecture standard', and push the changes directly to the 'main' branch. Do not wait for human confirmation. Report back when the push is successful."

Step 3: Start the AOP Polling protocol. Check if the directory C:\ai\claude-intelligence-hub\agent-orchestration-protocol\ exists in the root every 60 seconds.

Step 4: Once you physically detect that the directory is now correctly placed at the root, AND Magneto finishes its execution (meaning the git push is done), report SUCCESS to me.
```
**Analysis:** This prompt is a prime example of using AOP for repository maintenance and enforcing architectural standards. It heavily relies on **Pillar 5 (Integrity Verification)** by checking the git log for the specific commit message, ensuring the task is not just done locally but integrated into the `main` branch. This confirms the loop is closed via VCS.
