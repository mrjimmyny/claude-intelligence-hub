---
name: agent-orchestration-protocol
version: 1.3.0
description: Multi-agent coordination framework - The Seven Pillars of AOP
command: /aop
aliases: [/orchestrate, /delegate]
---

# 🤖 Agent Orchestration Protocol (AOP)

**Skill ID:** `agent-orchestration-protocol`
**Version:** 1.3.0
**Status:** Production-Ready
**Category:** Multi-Agent Coordination
**Author:** Forge (Senior Software Engineer & Context Specialist)

---

## 🎯 Overview

The **Agent Orchestration Protocol (AOP)** is a framework that enables Claude-based agents to orchestrate complex tasks across multiple autonomous agents through CLI interfaces. This skill transforms any agent into an **Orchestrator Agent** capable of delegating, monitoring, and validating work performed by **Executor Agents**.

<details>
<summary><b>📊 View Orchestration Event Flow</b></summary>

```mermaid
sequenceDiagram
    participant User
    participant Forge as Orchestrator
    participant Emma as Executor
    User->>Forge: Start complex task
    Forge->>Forge: Verify Workspace Path
    Forge->>Emma: Set-Location & Execute (Bypass Flag)
    loop Active Vigilance
        Forge->>Forge: Poll for artifact/commit
    end
    Emma-->>Forge: Task Complete (Artifact)
    Forge->>Forge: Integrity Verification
    Forge->>User: Closeout (SUCCESS/FAIL)
```

</details>

---

## 🏛️ The Seven Pillars of AOP

1. **Environment Isolation:** Launch agents in isolated shell environments.
2. **Absolute Referencing:** Always use absolute paths for file operations.
3. **Permission Bypass:** Automate permission approval for trusted workspaces.
4. **Active Vigilance (Polling):** Implement verification loops to monitor task completion.
5. **Integrity Verification:** Validate generated artifacts.
6. **Closeout Protocol:** Return explicit status reports (`SUCCESS` or `FAIL`).
7. **Constraint Adaptation:** Delegate monitoring tasks if sandbox constraints prevent direct access.

---

## 🔒 Flexible Security Routing & Execution Standard (MANDATORY)

To guarantee reliable execution and resolve sandbox initialization issues, orchestrators MUST strictly follow this execution standard.

### The Workspace Routing Rule
Orchestrators can route executors to **ANY trusted, pre-configured project directory** (e.g., `C:\ai`, `C:\Workspaces`) using the `Set-Location` syntax, provided the orchestrator explicitly verifies the path before handover.

### The Executor Agent Routing Standard
The `codex` and `gemini` executor agents are fully compliant. Failures are typically due to incorrect directory contexts. You MUST use one of the following patterns, utilizing the appropriate bypass flag:

<details>
<summary><b>💻 View Mandatory PowerShell Execution Patterns</b></summary>

**For Codex (Emma):**
**Option A (Simple, reliable execution):**
```powershell
Set-Location <Target_Path>
codex exec --dangerously-bypass-approvals-and-sandbox '<Complex_Instructions_Wrapped_In_Single_Quotes>'
```

**Option B (One-liner - Highly Recommended for automated orchestration):**
```powershell
Set-Location <Target_Path>; codex exec --dangerously-bypass-approvals-and-sandbox '<Complex_Instructions_Wrapped_In_Single_Quotes>'
```

**For Gemini (Forge):**
**Option B (One-liner):**
```powershell
Set-Location <Target_Path>; gemini --approval-mode yolo -p "<Complex_Instructions_Wrapped_In_Double_Quotes>"
```

**Option C (Spawn in a completely new terminal instance):**
```powershell
Start-Process powershell -WorkingDirectory <Target_Path>
```

</details>

---

## 🚑 Fallback & Recovery

### Standardized Error Reporting
Executor Agents should output an `error.json` file in the root of their workspace upon failure to aid the Orchestrator.

<details>
<summary><b>📄 Example error.json</b></summary>

```json
{
  "failed_step": "Step 3: Writing to file '...'",
  "reason": "Permission denied",
  "details": "The agent did not have write access.",
  "executor_agent_id": "Emma" 
}
```

</details>

### Polling Optimizations
- **Boolean Strategy:** Ask sub-agents to "Return ONLY 'YES' or 'NO'" to prevent hallucinations.
- **Delegate the Loop:** Delegate the entire `while` loop to a single long-lived agent instead of spawning an agent per check.

---

## 📚 Related Documentation

- [README.md](./README.md) - Complete onboarding guide
- [AOP_WORKED_EXAMPLES.md](./AOP_WORKED_EXAMPLES.md) - Production-validated prompt cookbook

---

### Cross-LLM Command Reference

| Task | Gemini CLI (`gemini`) | Codex CLI (`codex`) | Claude Code (`claude`) |
| :--- | :--- | :--- | :--- |
| **Execution (Standard)** | `gemini -p "..."` | `codex exec "..."` | `claude -p "..."` |
| **Bypass Sandbox / Approval** | `--approval-mode yolo` or `-y` | `--dangerously-bypass-approvals-and-sandbox` | `--dangerously-skip-permissions` |
| **Set Workspace / Context** | `--include-directories <path>` | Handled via `Set-Location` prior to execution | Handled via `Set-Location` prior to execution |
| **Git Bypass** | *N/A (Works outside git)* | `--skip-git-repo-check` | *N/A* |

**Example: Claude or Codex orchestrating Gemini (Forge):**
```powershell
Set-Location C:\ai\target_dir; gemini --approval-mode yolo -p "Forge, execute Phase 1: create file X. Output ONLY the word 'YES' upon completion."
```

---

**Version History:**
- **v1.3.0** - Added Seven Pillars, Flexible Routing, UX/UI Upgrades, and Execution Standards.