# AOP JSON v2 – Final Implementation Plan (Cyclops)

This document defines the final, consolidated implementation plan for the AOP JSON v2 contract (file: `03_contract-aop-v2-ciclope-final.md`).

It assumes a **role-based** architecture:
- One **Orchestrator** role (which may be fulfilled by any model/agent).
- One or more **Executor** roles (which may be fulfilled by any model/agent).
- Optional specialized responsibilities for **Routing** and **Governance/Guard Rails**, which can be attached to either the Orchestrator, to a dedicated service, or shared across Executors.

**Important:** roles are **not statically bound** to specific models. Claude, Gemini, or any other model can act as Orchestrator and/or Executor, as long as they respect the AOP JSON v2 contract.

The plan is structured in four stages:
1. BUILD – what to implement
2. TEST – how to test each piece
3. VALIDATE – schema/contract validation steps
4. AUDIT – how to verify behavior using Repo-Auditor

Each stage is further split into activities per **role**, not per model:
- Orchestrator role
- Executor role(s)
- Routing responsibility
- Governance & Guard Rails responsibility

## 1. BUILD – Implementation Tasks

### 1.1 Orchestrator Role
- Implement version detection and routing for `aop_json_v2` with fallback to v1.
- Implement canonical orchestration envelope creation based on `03_contract-aop-v2-ciclope-final.md`.
- Implement multi-agent delegation graph handling (parent/child tasks, lineage, correlation IDs).
- Implement checkpointing hooks and rollback protocol integration.
- Implement cost budget propagation to all Executors and aggregation of actual costs per task/session.
- Implement hooks to call routing and governance components (which may be internal or external services).

### 1.2 Executor Role(s)
- Implement parsing and execution of the v2 executor payload.
- Implement guard-rail-aware execution (timeouts, forbidden actions, safety constraints) as provided by the Orchestrator/Governance component.
- Implement structured result object generation, including partial results and tool/action traces.
- Implement error taxonomy mapping to `E_*` codes defined in the contract.
- Support concurrent execution when the Orchestrator delegates to multiple Executors in parallel.

### 1.3 Routing Responsibility
- Implement model and agent routing logic based on task metadata, cost/latency preferences, and guard rails.
- Implement fallback routing triggers (e.g., on `TIMEOUT`, `E_MODEL_CAPABILITY_MISMATCH`).
- Implement payload size checks and potential request shrinking (summarization, truncation) when near limits.
- Expose a clear interface so that any Orchestrator implementation can call this routing layer consistently, regardless of which model is currently acting as Orchestrator.

### 1.4 Governance & Guard Rails Responsibility
- Implement enforcement of global and per-task guard rails (timeouts, budgets, safety policies).
- Implement effective access rules computation (intersection of capabilities and constraints for each Executor).
- Implement payload limit enforcement (soft and hard limits) with appropriate warnings and errors.
- Implement logging and observability hooks for all governance decisions.
- Expose governance checks via a stable interface that can be called by any Orchestrator and/or Executor implementation.

## 2. TEST – Unit and Integration Testing

### 2.1 Unit Tests
- For each role/responsibility (Orchestrator, Executor, Routing, Governance), add unit tests that cover:
  - Happy-path flows for v2 messages.
  - Fallback to v1 behavior when v2 is not available.
  - Edge cases for timeouts, payload limits, and budget overruns.

### 2.2 Integration Tests
- Define end-to-end scenarios that:
  - Orchestrate multi-step, multi-agent workflows using v2, with different models filling Orchestrator and Executor roles.
  - Exercise model routing and fallback paths when different models are selected.
  - Exercise checkpoint and rollback behavior on failure.
  - Exercise parallel delegation to multiple Executors and aggregation of results.

### 2.3 Regression Tests
- Ensure that existing v1 tests continue to pass unchanged.
- Add regression tests specifically to confirm backward compatibility of v2 with v1 contracts.
- Add scenarios where an Orchestrator using v2 interacts with Executors that only support v1 via the defined fallback rules.

## 3. VALIDATE – Contract and Schema Validation

### 3.1 JSON Schema Validation
- Define and maintain JSON Schema(s) for the v2 orchestration envelope and executor response.
- Add schema validation in CI for:
  - All test payloads.
  - Generated examples from documentation.

### 3.2 Static and Runtime Validation
- Implement static validation of configuration (guard rails, routing rules, budgets) at startup.
- Implement runtime validation hooks that reject malformed or out-of-contract messages early, before they reach models.

### 3.3 Compatibility Validation
- Validate that any message that is valid v2 can be transformed into a valid v1-compatible message when needed.
- Validate that v1-only agents can interoperate via the defined fallback rules.
- Validate that swapping which model acts as Orchestrator or Executor does **not** break the contract, as long as the role implementation is respected.

## 4. AUDIT – Observability and Repo-Auditor Integration

### 4.1 Audit Trail Structure
- Implement structured audit trail records for:
  - Orchestration envelope per task.
  - Executor requests and responses (per Executor instance).
  - Routing and fallback decisions (which model took which role, and why).
  - Guard rail decisions (allow/deny, reason codes) per request.
- Store audit files under: `_skills/agent-orchestration-protocol_d/v2/audit_trails/` inside the workspace root.

### 4.2 Repo-Auditor Scenarios
- Define Repo-Auditor scenarios that:
  - Replay real orchestration sessions from audit trails.
  - Verify that all messages comply with the v2 contract.
  - Check that budgets, payload limits, and guard rails were correctly applied.
  - Check that role assignments (which model acted as Orchestrator/Executor) did not violate capabilities or access constraints.

### 4.3 Operational Dashboards (Optional)
- (Optional) Define dashboards or reports that aggregate audit trail information:
  - Cost per session / per agent.
  - Frequency and causes of fallbacks.
  - Frequency and types of guard rail violations.
  - Distribution of which models most often act as Orchestrator vs Executor, and associated performance/cost.

## 5. Milestones and Acceptance Criteria

- **Milestone 1 – Core BUILD completed**
  - All BUILD tasks for Orchestrator role, Executor role(s), Routing, and Governance are implemented behind feature flags.
  - Any model can be configured to assume Orchestrator or Executor roles without changing the contract.
- **Milestone 2 – TEST green**
  - Unit, integration, and regression tests for v2/v1 are passing in CI.
  - Tests include scenarios with different models taking the Orchestrator/Executor roles.
- **Milestone 3 – VALIDATE enforced**
  - JSON Schema validation is active and blocks out-of-contract messages.
  - Compatibility tests for v2↔v1 and role-swapping are green.
- **Milestone 4 – AUDIT operational**
  - Audit trail generation is enabled and Repo-Auditor scenarios pass.
  - Role assignments and governance decisions are transparently observable in the audit trails.

This plan supersedes the individual plans previously produced and is the single source of truth for implementing AOP JSON v2 in a **role-based, model-agnostic** way.
