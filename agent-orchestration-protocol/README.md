# Agent Orchestration Protocol (AOP) - Complete Guide

Welcome to the **Agent Orchestration Protocol (AOP)**, a revolutionary framework for multi-agent coordination in the Claude ecosystem. This guide will take you from zero to orchestration mastery.

---

## Table of Contents

1. [What is AOP?](#what-is-aop)
2. [Quick Start](#quick-start)
3. [The Six Pillars Explained](#the-six-pillars-explained)
4. [Step-by-Step Tutorial](#step-by-step-tutorial)
5. [Fallback & Recovery](#fallback--recovery)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Patterns](#advanced-patterns)

---

## What is AOP?

The **Agent Orchestration Protocol** is a methodology and set of practices that enables a **single Orchestrator Agent** to coordinate **multiple Executor Agents** working on complex, multi-step tasks.

### Key Concepts

- **Orchestrator Agent:** The "conductor" - typically Forge - who delegates and monitors tasks
- **Executor Agent:** The "specialist" - Codex (Emma), Claude Code (Magneto), or any CLI-invocable agent
- **Headless Mode:** Running agents in non-interactive terminal sessions for automation
- **Trusted Workspace:** Pre-approved directories where permission bypass is allowed

### Why AOP?

Traditional single-agent workflows hit limits when facing:
- Tasks requiring multiple specialized skill sets
- Parallel workstreams that need coordination
- Review/validation loops (creator → reviewer → finalizer)
- Long-running operations requiring monitoring

AOP solves these by enabling **true multi-agent collaboration**.

---

## Quick Start

### Prerequisites

- Claude CLI (Code, Codex, or other variants) installed and accessible
- PowerShell or Bash terminal
- A trusted workspace directory (e.g., `C:\Workspaces\llms_projects`)

### Your First Orchestration (5 Minutes)

**Objective:** Have Forge orchestrate Emma (Codex) to create a test file.

```prompt
Forge, execute this basic test:
1. Open a PowerShell terminal: powershell -NoProfile -Command
2. Launch Codex CLI with start directory: C:\Workspaces\llms_projects
3. Set Codex to full permission mode: /permissions → option 3
4. Ask Codex to create a file named hello_aop.md with content "AOP Test Successful"
5. Verify the file exists
6. Report: SUCCESS or FAIL
```

**Expected Outcome:** Forge reports `SUCCESS` and the file exists at the specified location.

---

## The Six Pillars Explained

### Pillar 1: Environment Isolation

**Purpose:** Ensure Executor Agents operate in clean, predictable environments.

**Implementation:**
```powershell
# PowerShell
powershell -NoProfile -Command "claude --start-directory C:\absolute\path"

# Bash
bash -c "claude --start-directory /absolute/path"
```

**Why it matters:** Prevents context pollution between agents and ensures reproducibility.

---

### Pillar 2: Absolute Referencing

**Purpose:** Eliminate path ambiguity across different agent execution contexts.

**Good:**
```
C:\Workspaces\llms_projects\document.md
/home/user/projects/document.md
```

**Bad:**
```
./document.md
../projects/document.md
```

**Why it matters:** Relative paths can resolve differently depending on the agent's current working directory.

---

### Pillar 3: Permission Bypass (Trusted Workspaces Only)

**Purpose:** Enable fully automated workflows in pre-approved safe directories.

**Implementation:**
```bash
claude --dangerously-skip-permissions -p
```

**CRITICAL SECURITY NOTE:**
- Only use in explicitly trusted workspaces
- See [SKILL.md Security Boundaries](./SKILL.md#security-boundaries)
- Default trusted workspaces:
  - `C:\Workspaces\llms_projects\`
  - `C:\ai\claude-intelligence-hub\`

**Why it matters:** Eliminates interactive permission prompts for automation.

---

### Pillar 4: Active Vigilance (Polling)

**Purpose:** Monitor Executor Agent progress and detect task completion.

**Implementation Pattern:**
```python
# Pseudo-code for Orchestrator Agent logic
timeout_minutes = 10
check_interval_seconds = 60

for attempt in range(timeout_minutes):
    if file_exists(target_artifact):
        if validate_file_not_empty(target_artifact):
            return SUCCESS
    sleep(check_interval_seconds)

return TIMEOUT_FAILURE
```

**Why it matters:** Headless agents don't send completion signals; polling provides feedback.

---

### Pillar 5: Integrity Verification

**Purpose:** Ensure generated artifacts meet quality standards.

**Validation Checks:**
1. **Existence:** Does the file exist at the expected path?
2. **Non-Empty:** Is the file size > 0 bytes?
3. **Content Validation:** Does the file contain expected markers/sections?
4. **Checksum (Optional):** For critical files, verify hash matches expected value

**Example Validation Prompt:**
```prompt
Forge, after Emma creates the file:
1. Verify file exists at C:\Workspaces\llms_projects\output.md
2. Confirm file size > 1KB
3. Read first 100 characters to validate it's not corrupted
4. Report validation results
```

---

### Pillar 6: Closeout Protocol

**Purpose:** Provide clear, actionable status reports for all orchestrated tasks.

**Required Status Format:**

**On Success:**
```
STATUS: SUCCESS
Agent: Emma (Codex CLI)
Artifact: C:\Workspaces\llms_projects\final_report.md
Size: 15.3 KB
Key Sections: Executive Summary, Technical Analysis, Recommendations
Completion Time: 3m 42s
```

**On Failure:**
```
STATUS: FAIL
Agent: Magneto (Claude Code CLI)
Error: Timeout - File not created after 10 minutes
Expected Artifact: C:\Workspaces\llms_projects\review.md
Terminal Output: [Last 20 lines of error log]
Suggested Action: Retry with extended timeout or manual execution
```

**Why it matters:** Enables debugging and automated workflow decisions.

---

## Step-by-Step Tutorial

### Tutorial 1: Single-Agent File Creation

**Goal:** Learn basic orchestration with one Executor Agent.

**Step 1:** Craft the orchestration prompt
```prompt
Forge, execute this task:
1. Launch Emma (Codex CLI) in headless mode
2. Working directory: C:\Workspaces\llms_projects
3. Full permissions mode
4. Task: Create tutorial_1_result.md with a summary of AI trends in 2026
5. Validate file creation
6. Report status
```

**Step 2:** Forge executes the task

**Step 3:** Verify results
- Check for `tutorial_1_result.md` in the workspace
- Review Forge's status report

---

### Tutorial 2: Two-Agent Sequential Workflow

**Goal:** Orchestrate a creator → reviewer workflow.

```prompt
Forge, execute this two-phase task:

Phase 1 - Content Creation:
1. Launch Emma at C:\Workspaces\llms_projects
2. Emma creates initial_draft.md about quantum computing basics
3. Validate Emma's output

Phase 2 - Expert Review:
4. Launch Magneto at same directory
5. Magneto reviews initial_draft.md and creates reviewed_draft.md with corrections
6. Validate Magneto's output

Final Report:
7. Provide consolidated status for both phases
8. Include word counts for both files
```

---

### Tutorial 3: Polling and Integrity Validation

**Goal:** Implement robust monitoring for long-running tasks.

```prompt
Forge, execute with active monitoring:
1. Launch Emma for a complex analysis task (estimated 5-8 minutes)
2. Implement polling:
   - Check every 60 seconds for output file
   - Timeout after 15 minutes
   - Validate file integrity on detection
3. Provide real-time status updates every 2 minutes
4. Final report with validation results
```

---

## Fallback & Recovery

### Common Failure Scenarios

#### Scenario 1: Timeout (File Not Created)

**Symptoms:**
- Polling loop completes without detecting the target artifact
- STATUS: FAIL with timeout message

**Recovery Protocol:**
1. **Verify the command syntax** - Check for typos in file paths or agent invocations
2. **Check terminal logs** - Look for error messages from the Executor Agent
3. **Extend timeout** - Some tasks legitimately require more time; retry with 20+ minutes
4. **Manual fallback** - If automation fails twice, escalate to manual execution
5. **Report to user** - Provide detailed failure analysis for human intervention

**Example Recovery Prompt:**
```prompt
Forge, the previous task timed out. Please:
1. Check the terminal log for any error messages from Emma
2. Verify Emma CLI is functional with a simple "create test.txt" command
3. If Emma works, retry the original task with 20-minute timeout
4. If Emma fails basic test, report the error for troubleshooting
```

---

#### Scenario 2: Corrupted or Empty Artifact

**Symptoms:**
- File exists but size is 0 bytes
- File contains error messages instead of expected content

**Recovery Protocol:**
1. **Read the file** - Inspect contents to determine failure mode
2. **Check disk space** - Ensure the workspace has available storage
3. **Retry with explicit instructions** - Add more detail to the task specification
4. **Alternative agent** - Try a different Executor Agent if one consistently fails

---

#### Scenario 3: Permission Denied

**Symptoms:**
- Agent reports access denied or insufficient permissions
- File creation fails with permission errors

**Recovery Protocol:**
1. **Verify workspace is trusted** - Check against the trusted workspace list
2. **Validate directory permissions** - Ensure the directory is writable
3. **Fallback to interactive mode** - Remove `--dangerously-skip-permissions` and use `-p` only
4. **User intervention** - Request explicit permission for the operation

---

### Timeout Configuration Guidelines

| Task Type | Recommended Timeout |
|-----------|---------------------|
| Simple file creation | 2-5 minutes |
| Document analysis/summary | 5-10 minutes |
| Complex multi-file operations | 10-15 minutes |
| Research and synthesis tasks | 15-30 minutes |

---

## Best Practices

### 1. Clear Task Decomposition
Break complex tasks into discrete, verifiable steps that can be delegated to specific agents.

### 2. Explicit Success Criteria
Define exactly what "done" looks like before starting orchestration.

### 3. Agent Specialization
- **Emma (Codex):** Creative writing, content generation, brainstorming
- **Magneto (Claude Code):** Code review, technical documentation, system tasks
- **Forge (Gemini):** Orchestration, planning, multi-agent coordination

### 4. Logging and Audit Trails
Always capture terminal output and agent responses for debugging.

### 5. Incremental Validation
Validate intermediate artifacts, not just final outputs.

---

## Troubleshooting

### Problem: "Command not found: claude"

**Solution:** Ensure Claude CLI is installed and in system PATH.

```bash
# Verify installation
claude --version

# If not found, reinstall or add to PATH
```

---

### Problem: Agent doesn't respond to /permissions command

**Solution:** The `/permissions` command is interactive. Use flag-based approach instead:

```bash
# Instead of interactive /permissions
claude --dangerously-skip-permissions -p
```

---

### Problem: File created in wrong directory

**Root Cause:** Relative paths or incorrect working directory.

**Solution:** Always use absolute paths (Pillar 2) and verify start directory.

---

## Advanced Patterns

### Pattern 1: Parallel Agent Execution

Launch multiple agents simultaneously for independent tasks, then consolidate results.

```prompt
Forge, execute in parallel:
Thread 1: Emma analyzes dataset_A.csv → summary_A.md
Thread 2: Magneto analyzes dataset_B.csv → summary_B.md
After both complete: Create consolidated_analysis.md merging both summaries
```

---

### Pattern 2: Agent Specialization Pipeline

Route tasks through a sequence of specialized agents.

```
Ideation (Emma) → Technical Validation (Magneto) → Executive Summary (Forge)
```

---

### Pattern 3: Recursive Orchestration

An Orchestrator Agent can delegate to another Orchestrator for hierarchical task management.

```
Forge (Master Orchestrator)
  ├─ Sub-Orchestrator 1 (Manages Emma + Codex)
  └─ Sub-Orchestrator 2 (Manages Magneto + Claude)
```

---

## Next Steps

1. **Review Worked Examples:** See [AOP_WORKED_EXAMPLES.md](./AOP_WORKED_EXAMPLES.md) for production-validated prompts
2. **Explore the Roadmap:** Check [ROADMAP.md](./ROADMAP.md) for future capabilities
3. **Run Test Suite:** Execute `Test-AopSkill.ps1` to validate your environment
4. **Start Experimenting:** Begin with simple tasks and progressively increase complexity

---

## Support and Contribution

For issues, questions, or contributions to the AOP framework:
- Review the [Security Boundaries](./SKILL.md#security-boundaries) before implementation
- Check existing worked examples before creating new patterns
- Document successful orchestrations for future reference

---

**Version:** 1.2
**Last Updated:** 2026-02-22
**Maintained by:** Claude Intelligence Hub Team
