# Agent Orchestration Protocol (AOP)

**Skill ID:** `agent-orchestration-protocol`
**Version:** 1.2
**Status:** Production-Ready
**Category:** Multi-Agent Coordination
**Author:** Forge (Senior Software Engineer & Context Specialist)

---

## Overview

The **Agent Orchestration Protocol (AOP)** is a framework that enables Claude-based agents to orchestrate complex tasks across multiple autonomous agents through CLI interfaces. This skill transforms any agent into an **Orchestrator Agent** capable of delegating, monitoring, and validating work performed by **Executor Agents** (such as Codex, Emma, Magneto, or any Claude CLI instance).

AOP represents a paradigm shift from single-agent workflows to a distributed, high-performance multi-agent architecture that mirrors real-world software engineering team dynamics.

---

## Core Capabilities

- **Multi-Agent Task Delegation:** Orchestrate work across multiple AI agents simultaneously or sequentially
- **Environment Isolation:** Launch agents in isolated shell environments with absolute path referencing
- **Permission Management:** Automate permission bypass for trusted workspaces
- **Active Monitoring:** Implement polling loops to track task completion and artifact generation
- **Integrity Validation:** Verify created artifacts through content validation and checksums
- **Fallback & Recovery:** Handle timeouts and failures gracefully with defined recovery protocols

---

## The Seven Pillars of AOP

### Pillar 1: Environment Isolation
Launch Executor Agents in isolated, headless terminal sessions with explicit working directories.

```powershell
powershell -NoProfile -Command "claude --start-directory C:\absolute\path\to\workspace"
```

### Pillar 2: Absolute Referencing
Always use absolute paths for file operations to eliminate ambiguity across agent contexts.

```
C:\Workspaces\llms_projects\document.md
```

### Pillar 3: Permission Bypass (Trusted Workspaces Only)
Automate permission approval for pre-authorized, trusted workspace directories.

```bash
claude --dangerously-skip-permissions -p
```

### Pillar 4: Active Vigilance (Polling)
Implement verification loops to monitor task completion and artifact creation.

```python
# Pseudo-code
for i in range(10):  # 10 minute timeout
    if file_exists(target_artifact):
        validate_integrity()
        break
    sleep(60)
```

### Pillar 5: Integrity Verification
Validate generated artifacts through content checks, size validation, and optional checksums.

### Pillar 6: Closeout Protocol
Always return explicit status reports: `SUCCESS` with summary or `FAIL` with error logs.

### Pillar 7: Constraint Adaptation
If an Orchestrator's own environmental constraints prevent it from directly monitoring a resource (e.g., due to sandbox limitations), it must attempt to fulfill the monitoring requirement by delegating the verification task to a new, properly-scoped agent.

---

## State Handover Best Practices
For complex instructions, prefer file-based handover to ensure clarity and avoid overly long CLI commands that are prone to character escaping errors. The Orchestrator agent is responsible for the creation and subsequent cleanup of these temporary instruction files.

---

## Security Boundaries

### Mandatory Security Rules

1. **Trusted Workspace Restriction:**
   - The `--dangerously-skip-permissions` flag MAY ONLY be used in explicitly trusted workspace directories
   - Trusted workspaces must be defined and documented in the agent's context file
   - Default trusted workspaces:
     - `C:\Workspaces\llms_projects\`
     - `C:\ai\claude-intelligence-hub\`
   - Any other directory REQUIRES explicit user approval before using bypass flags

2. **Permission Escalation Protocol:**
   - Never use permission bypass flags on system directories (`C:\Windows\`, `C:\Program Files\`, etc.)
   - Never use bypass flags on user home directories unless explicitly whitelisted
   - Always validate the target directory is within the trusted workspace boundary before proceeding

3. **User Notification:**
   - When using `--dangerously-skip-permissions`, the Orchestrator Agent must log this action clearly
   - If a task requires operating outside trusted workspaces, STOP and request explicit user approval

4. **Fail-Safe Defaults:**
   - If workspace trust status is ambiguous, default to interactive permission mode (`-p` without bypass)
   - Never guess or assume a directory is safe

### Example Security Decision Tree

```
Is target directory in trusted workspace list?
├─ YES → Proceed with --dangerously-skip-permissions
└─ NO
   ├─ Is this a user home or system directory?
   │  └─ YES → ABORT, request user approval
   └─ NO → Use interactive mode (-p) or request user approval
```


---

## When to Use This Skill

- Orchestrating multiple agents to work on different parts of a complex project
- Delegating specialized tasks to agents optimized for specific roles (e.g., Emma for creative work, Magneto for system tasks)
- Implementing review/validation workflows where one agent creates and another reviews
- Running parallel workstreams that need coordination
- Automating multi-step engineering pipelines with agent handoffs

---

## Example Usage

### Basic Single-Agent Delegation

```prompt
Forge, execute the following task using Codex CLI:
1. Launch Codex in headless mode: powershell -NoProfile -Command
2. Set working directory: C:\Workspaces\llms_projects
3. Enable full permissions: /permissions -> option 3
4. Task: "Read draft_proposal.md, analyze it, and create an improved version as draft_proposal_v2.md"
5. Verify the file was created
6. Report: SUCCESS or FAIL
```

### Multi-Agent Sequential Workflow

```prompt
Forge, orchestrate this two-agent workflow:
Step 1: Launch Emma (Codex CLI) at C:\Workspaces\llms_projects
Step 2: Emma creates initial_design.md based on requirements.txt
Step 3: Launch Magneto (Claude Code CLI) at same directory
Step 4: Magneto reviews initial_design.md and creates final_design.md
Step 5: Validate both artifacts exist and are non-empty
Step 6: Report consolidated status
```

---

## Fallback & Recovery

See the [README.md](./README.md#fallback--recovery) for detailed recovery protocols.

### Standardized Error Reporting
To make the "Fallback & Recovery" more robust, AOP defines a standardized JSON format for error reporting. Executor Agents should output an `error.json` file in the root of their workspace upon failure.

**`error.json` format:**
```json
{
  "failed_step": "Step 3: Writing to file '...'",
  "reason": "Permission denied",
  "details": "The agent did not have write access to the specified directory.",
  "executor_agent_id": "Forge B" 
}
```

---

## Related Documentation

- [README.md](./README.md) - Complete onboarding guide and best practices
- [ROADMAP.md](./ROADMAP.md) - Visual overview and future direction
- [AOP_WORKED_EXAMPLES.md](./AOP_WORKED_EXAMPLES.md) - Production-validated prompt cookbook

---

## Changelog

- **v1.3 (In Progress)** - Enhanced protocol with Constraint Adaptation, State Handover Best Practices, and Standardized Error Reporting.
- **v1.2** - Added Security Boundaries section, clarified trusted workspace rules
- **v1.1** - Initial production release with all six pillars documented
- **v1.0** - Beta release for internal testing
