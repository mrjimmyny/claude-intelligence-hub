# ORCHESTRATION_TASK

**TO:** Emma (Codex)
**FROM:** Forge (Gemini)
**PROTOCOL:** AOP v1

## 1. ENVIRONMENT
- **Workspace:** `C:\ai`
- **Source Document:** `_skills/agent-orchestration-protocol_d/v2/00_contract/01_draft-aop-v2.md` (Cyclops's Draft)
- **Output File:** `_skills/agent-orchestration-protocol_d/v2/00_contract/01_draft-aop-v2-emma.md`

## 2. TOOLING
- You have access to the file system to read the source document and write your output file.

## 3. CONTEXT
- We are evolving the Agent Orchestration Protocol from v1 (markdown-based) to v2 (JSON-based).
- The initial draft has been prepared by Cyclops.
- Your task is to review Cyclops's draft and produce your own version from your perspective as the team's primary Architect and specialist in type-safe interfaces and validation.

## 4. INSTRUCTIONS
1.  Read the content of the source document: `C:\ai\_skills\agent-orchestration-protocol_d\v2\00_contract\01_draft-aop-v2.md`.
2.  Produce your own version of the **Agent Orchestration Protocol (AOP) – JSON v2 Draft Specification**.
3.  **Your Perspective:** As an architect (Emma/Codex), focus on schema integrity, type safety, and the concrete implementation of validators and CLI wrappers.
4.  **Refine and/or adjust the JSON structures**, especially:
    - The v2 envelope (session, routing, task, guard_rails, phases).
    - The executor response object (status, minimal_report, checkpoints).
    - The delegation graph for multi-agent chains.
5.  **Tighten the schema** where you feel it's important for determinism, future auto-documentation, and the creation of type-safe interfaces (e.g., Pydantic, TypeScript).
6.  **Clarify the relationship with AOP v1**, including how v2 should gracefully fall back to v1.
7.  Add **implementation notes** for the other agents on how to build validators, CLI wrappers, and code-level patterns for orchestration modules.
8.  Save your completed specification to the output file path: `C:\ai\_skills\agent-orchestration-protocol_d\v2\00_contract\01_draft-aop-v2-emma.md`.

## 5. VERIFICATION
- The file `01_draft-aop-v2-emma.md` must exist and contain your detailed specification.

## 6. DELEGATION
- This is a direct task. No further delegation is authorized.

## 7. CLOSURE
- Upon successful creation of the file, your task is complete. No formal report back is needed for this AOPv1 task.
