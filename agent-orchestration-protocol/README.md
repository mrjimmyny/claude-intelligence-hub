# 🚀 Agent Orchestration Protocol (AOP) - Complete Guide

Welcome to the **Agent Orchestration Protocol (AOP)**, a revolutionary framework for multi-agent coordination in the Claude ecosystem. This guide will take you from zero to orchestration mastery.

---

## 🆕 AOP V2 — Now Available

**Version 2.0.0** is live! The new JSON-native protocol adds:
- Role-based, model-agnostic architecture
- Structured JSON envelopes with schema validation
- Guard rail enforcement (budgets, timeouts, payload limits)
- Full audit trail system with Repo-Auditor
- Backward compatibility with V1

👉 See [`v2/`](./v2/) for the complete implementation.
👉 See [`CHANGELOG.md`](./CHANGELOG.md) for version history.

---

## 📑 Table of Contents

1. [What is AOP?](#what-is-aop)
2. [Quick Start](#quick-start)
3. [The Seven Pillars Explained](#the-seven-pillars-explained)
4. [Step-by-Step Tutorial](#step-by-step-tutorial)
5. [Fallback & Recovery](#fallback--recovery)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Patterns](#advanced-patterns)

---

## 🧠 What is AOP?

The **Agent Orchestration Protocol** is a methodology and set of practices that enables a **single Orchestrator Agent** to coordinate **multiple Executor Agents** working on complex, multi-step tasks.

<details>
<summary><b>📊 Click to view the AOP Flow Architecture</b></summary>

```mermaid
graph TD
    A[User Prompt] --> B(Orchestrator Agent - Forge)
    B -->|Delegate Task 1| C{Executor Agent - Emma}
    B -->|Delegate Task 2| D{Executor Agent - Magneto}
    C -->|Output| E[Artifact 1]
    D -->|Output| F[Artifact 2]
    B -->|Active Vigilance / Polling| E
    B -->|Active Vigilance / Polling| F
    E --> G[Final Validation & Merge]
    F --> G
    G -->|Status Report| A
```

</details>

### Key Concepts

- 🎩 **Orchestrator Agent:** The "conductor" - typically Forge - who delegates and monitors tasks.
- 🛠️ **Executor Agent:** The "specialist" - Codex (Emma), Claude Code (Magneto), or any CLI-invocable agent.
- 🤖 **Headless Mode:** Running agents in non-interactive terminal sessions for automation.
- 🛡️ **Trusted Workspace:** Pre-approved directories where permission bypass is allowed.

---

## ⚡ Quick Start

### Your First Orchestration (5 Minutes)

**Objective:** Have Forge orchestrate Emma (Codex) to create a test file.

<details>
<summary><b>💻 View Prompt Example</b></summary>

```prompt
Forge, execute this basic test:
1. Open a PowerShell terminal: powershell -NoProfile -Command
2. Change directory: Set-Location C:\Workspaces\llms_projects
3. Launch Codex CLI using the bypass flag: codex exec --dangerously-bypass-approvals-and-sandbox
4. Ask Codex to create a file named hello_aop.md with content "AOP Test Successful"
5. Verify the file exists
6. Report: SUCCESS or FAIL
```

</details>

---

## 🏛️ The Seven Pillars Explained

### 1️⃣ Pillar 1: Environment Isolation
Ensure Executor Agents operate in clean, predictable environments.
*Implementation:* Spawning agents in dedicated terminal processes.

### 2️⃣ Pillar 2: Absolute Referencing
Eliminate path ambiguity.
*Implementation:* Always use full absolute paths (`C:\Workspaces\llms_projects\document.md`).

### 3️⃣ Pillar 3: Permission Bypass (Trusted Workspaces Only)
Enable fully automated workflows in pre-approved safe directories.
⚠️ **CRITICAL SECURITY NOTE:** Only use in explicitly trusted workspaces.

### 4️⃣ Pillar 4: Active Vigilance (Polling)
Monitor progress and detect task completion.
*Implementation:* Orchestrator polls the file system or git history.

### 5️⃣ Pillar 5: Integrity Verification
Ensure generated artifacts meet quality standards (Existence, Non-Empty, Content).

### 6️⃣ Pillar 6: Closeout Protocol
Provide clear, actionable status reports (`SUCCESS` or `FAIL`).

### 7️⃣ Pillar 7: Constraint Adaptation
Overcome sandbox or environment limitations.
*Implementation:* If an Orchestrator cannot access a resource directly, it MUST delegate the verification task to a new, properly-scoped agent.

---

## 🔒 Execution & Routing Standard (MANDATORY)

To ensure reliable execution, orchestrators must adhere to the **Flexible Security Routing** standard. 

**Rule:** Orchestrators can route executors to ANY trusted, pre-configured project directory (e.g., `C:\ai`, `C:\Workspaces`) using the `Set-Location` syntax, **provided the path is explicitly verified before handover.**

<details>
<summary><b>🛠️ View Execution Options for Codex & Gemini</b></summary>

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

### Standardized `error.json` Reporting
When an Executor Agent fails, it should generate an `error.json` file in its workspace for the Orchestrator to parse.

<details>
<summary><b>📄 View error.json schema</b></summary>

```json
{
  "failed_step": "Step 3: Writing to file '...'",
  "reason": "Permission denied",
  "details": "The agent did not have write access to the specified directory.",
  "executor_agent_id": "Forge B" 
}
```

</details>

### Polling Best Practices
💡 **Boolean Polling Strategy:** When polling a sub-agent, use boolean prompts like `"Return ONLY 'YES' or 'NO'"` to avoid conversational drift. 

💡 **Delegate the Loop:** Do not spawn a new agent for every check; delegate the entire polling loop to a single, long-lived sub-agent.

---

## 📚 Production Case Studies

Real-world orchestration executions are documented in the `orchestrations/` directory. Each case study includes:
- Complete execution report (JSON)
- Detailed documentation (README)
- Metrics and lessons learned
- Application of all Seven Pillars

**Featured Case Studies:**
- **[Chain Delegation with Sub-Orchestration](./orchestrations/2026-02-25_chain-delegation/)** - Validates multi-level delegation where Emma (Codex) acts as both Executor and Sub-Orchestrator, delegating to Forge (Gemini). Demonstrates cross-LLM orchestration (Claude → OpenAI → Google) with 100% success rate.
- **[docx-indexer W1+W2 Production Execution](./orchestrations/2026-03-16_docx-indexer-w1w2/)** - First real production AOP: Magneto (Opus 4.6) orchestrates Sonnet 4.6 headless to implement 11 code findings across 8 files. Validates file-based prompt pattern, artifact-based polling, and documentation delegation. 372/372 tests maintained.

For additional worked examples and prompt templates, see [AOP_WORKED_EXAMPLES.md](./AOP_WORKED_EXAMPLES.md).

---

## 🤝 Support and Contribution

For issues, questions, or contributions to the AOP framework:
- Review the [Security Boundaries](./SKILL.md#security-boundaries) before implementation.
- Check existing worked examples before creating new patterns.

---

## Lessons from Production (2026-03-16)

Key learnings from the first real production AOP execution:

1. **Sub-agents are NOT AOP.** Internal sub-agent tools (Claude Code's Agent tool, etc.) run inside the parent session. True AOP requires `claude -p` / `codex exec` / `gemini -p` launching an independent OS process.
2. **File-based prompts for complex instructions.** Write the Executor prompt to a `.md` file and pipe via `cat file | claude -p`. Avoids all escaping issues with code snippets, tables, and special characters.
3. **Artifact-based completion detection.** Have the Executor create a JSON file as its last step. The Orchestrator polls for this file. Simpler and more reliable than parsing stdout.
4. **Executors can handle documentation.** With the right instructions (absolute paths, exact content, formatting rules), Executors update structured documents as reliably as code.
5. **Prompt quality determines success.** The more precise the prompt (exact line numbers, before/after code, verification steps), the fewer iterations needed.

**Version:** 2.1.0
**Last Updated:** 2026-03-16
**Maintained by:** Claude Intelligence Hub Team