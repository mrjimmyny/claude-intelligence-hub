# ORCHESTRATION_TASK

**TO:** Magneto (Claude)
**FROM:** Forge (Gemini)
**PROTOCOL:** AOP v1

## 1. ENVIRONMENT
- **Workspace:** `C:\ai`
- **Source Document:** `_skills/agent-orchestration-protocol_d/v2/00_contract/01_draft-aop-v2.md` (Cyclops's Draft)
- **Output File:** `_skills/agent-orchestration-protocol_d/v2/00_contract/01_draft-aop-v2-magneto.md`

## 2. TOOLING
- You have access to the file system to read the source document and write your output file.

## 3. CONTEXT
- We are evolving the Agent Orchestration Protocol from v1 (markdown-based) to v2 (JSON-based).
- The initial draft has been prepared by Cyclops.
- Your task is to review Cyclops's draft and produce your own version from your perspective as the team's primary implementer and specialist in routing and execution logic.

## 4. INSTRUCTIONS
1.  Read the content of the source document: `C:\ai\_skills\agent-orchestration-protocol_d\v2\00_contract\01_draft-aop-v2.md`.
2.  Produce your own version of the **Agent Orchestration Protocol (AOP) – JSON v2 Draft Specification**.
3.  **Your Perspective:** As an implementer (Magneto/Claude), focus on the practicalities of execution, routing, error handling, and backward compatibility.
4.  **Refine and/or adjust the JSON structures**, especially:
    - The v2 envelope (session, routing, task, guard_rails, phases).
    - The executor response object (status, minimal_report, checkpoints).
    - The delegation graph for multi-agent chains.
5.  **Tighten the schema** where you feel it's important for reliable execution flow and error recovery.
6.  **Clarify the relationship with AOP v1**, detailing the implementation plan for the v1 detection and fallback mechanism.
7.  Add detailed **implementation notes** for the team on:
    - Building the v1/v2 routing engine.
    - Handling timeouts, partial failures, and retries.
    - Wiring the protocol to the actual `claude` and `gemini` CLI tools.
8.  Save your completed specification to the output file path: `C:\ai\_skills\agent-orchestration-protocol_d\v2\00_contract\01_draft-aop-v2-magneto.md`.

## 5. VERIFICATION
- The file `01_draft-aop-v2-magneto.md` must exist and contain your detailed specification.

## 6. DELEGATION
- This is a direct task. No further delegation is authorized.

## 7. CLOSURE
- Upon successful creation of the file, your task is complete. No formal report back is needed for this AOPv1 task.
