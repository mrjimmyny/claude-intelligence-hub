---
title: "Project Planning Methodology Guide"
date: 2026-03-18
author: Magneto (Claude Code - Opus 4.6)
cat_doc: Operationalization Guide
version: 1.0.0
tags:
  - project-planning
  - methodology
  - cross-agent
  - guide
  - prd
  - spec
  - tdd
aliases:
  - project-planning-guide
  - planning-methodology-guide
---

# Project Planning Methodology Guide

> **Purpose:** The definitive reference for any agent selecting the right planning methodology when starting, evolving, or maintaining a project. Covers PRD, SPEC, Spec-Driven, TDD, Requirements, Plan, and Manifesto/Contract. Any agent initiating a project **MUST** consult this guide before choosing an approach.

> **v1.0 — Initial Edition.** Approved by Jimmy on 2026-03-18. Covers all major planning document types with decision matrices, project type mapping, and concrete selection criteria.

---

## 1. Purpose and Scope

This guide exists to solve a single problem: **agents waste effort, create misaligned deliverables, and slow down projects when they pick the wrong planning methodology.**

The three failure modes are:
1. **Over-planning** — Using PRD + SPEC + TDD for a simple bug fix (building a cathedral for a shed)
2. **Under-planning** — Using a quick plan for a complex multi-agent skill (building a shed when you need a cathedral)
3. **Wrong-type planning** — Using TDD for documentation work, or PRD for internal tooling (using the right tool for the wrong job)

This guide provides:
- **Methodology profiles** with definitions, strengths, and limitations
- **A decision matrix** mapping project types to recommended methodologies
- **Selection criteria** for quick decision-making
- **Combination patterns** for projects that need multiple approaches
- **Anti-patterns** to avoid

**Who should use this guide:**
- Any agent (Claude, Codex, Gemini, or other) starting a new project
- Any agent evolving an existing project to a new phase
- Jimmy (Owner) when deciding project approach
- Any orchestrator dispatching project-level tasks

---

## 2. Methodology Profiles

### 2.1 PRD (Product Requirements Document)

| Field | Value |
|---|---|
| **What it is** | Document defining WHAT to build, for WHOM, and WHY. Does not define HOW. |
| **Scope** | Product-level. Focused on user needs, business goals, and success metrics. |
| **Strengths** | Aligns stakeholders, defines success criteria, prevents scope creep at the product level. |
| **Limitations** | Too high-level for technical implementation. Requires a SPEC or Plan to become actionable. |
| **Typical size** | 3-10 pages. |
| **When created** | Before any implementation. Usually the first document in a product lifecycle. |

### 2.2 SPEC (Specification)

| Field | Value |
|---|---|
| **What it is** | Technical specification defining HOW to build. Inputs, outputs, rules, contracts, behavior. |
| **Scope** | System/component-level. Focused on behavior, interfaces, and constraints. |
| **Strengths** | Precise, testable, unambiguous. The source of truth for implementation. |
| **Limitations** | Requires knowing WHAT you want first. Not suitable for exploration or discovery. |
| **Typical size** | 5-30 pages depending on complexity. |
| **When created** | After requirements are known (from PRD, discovery, or owner's direction). |

### 2.3 Spec-Driven Development

| Field | Value |
|---|---|
| **What it is** | Methodology: write the SPEC before the code/skill. The spec is the source of truth. Implementation must match the spec. |
| **Scope** | Full project lifecycle. Applies to any project where traceability and compliance matter. |
| **Strengths** | Full traceability (spec → implementation → tests → audit). Prevents drift. |
| **Limitations** | Slower initial velocity. Over-engineering risk for simple projects. |
| **Typical size** | Multiple rounds of spec (e.g., Round 01 scope, Round 02 I/O, Round 03 guardrails). |
| **When created** | At project kickoff, before implementation begins. |

### 2.4 TDD (Test-Driven Development)

| Field | Value |
|---|---|
| **What it is** | Methodology: write tests BEFORE code. Cycle: Red (failing test) → Green (make it pass) → Refactor. |
| **Scope** | Code-level. Focused on functions, classes, APIs, and logic. |
| **Strengths** | High code quality, regression safety, forces clear interface design. |
| **Limitations** | Not applicable to documentation, templates, or configuration. Overhead for trivial changes. |
| **Typical size** | Test files alongside implementation files. |
| **When created** | During implementation, before each piece of logic is written. |

### 2.5 Requirements Document

| Field | Value |
|---|---|
| **What it is** | Formal list of functional and non-functional requirements. More rigid than PRD, less technical than SPEC. |
| **Scope** | System-level. Focused on what the system MUST do and quality attributes. |
| **Strengths** | Clear acceptance criteria. Good for compliance, auditing, and formal approval. |
| **Limitations** | Can become a checklist without context. Needs narrative (PRD) or technical detail (SPEC) to be truly useful. |
| **Typical size** | 2-15 pages. |
| **When created** | Early in the project. Can be derived from PRD or created standalone. |

### 2.6 Plan / Simple Plan

| Field | Value |
|---|---|
| **What it is** | Lightweight document: "we will do X, Y, Z in this order." Steps, owners, and expected outcomes. |
| **Scope** | Task-level. Focused on execution sequence. |
| **Strengths** | Fast to create, easy to follow, minimal overhead. |
| **Limitations** | No traceability. No formal contracts. Easy to drift from without noticing. |
| **Typical size** | 0.5-2 pages. |
| **When created** | When the scope is clear and small enough to not need formal documentation. |

### 2.7 Manifesto / Contract

| Field | Value |
|---|---|
| **What it is** | Declaration of principles + binding commitments. Defines the "social contract" of the project: who does what, what's in/out of scope, operating rules. |
| **Scope** | Project governance. Focused on alignment between owner and agents. |
| **Strengths** | Prevents misalignment, defines boundaries, establishes authority and roles. |
| **Limitations** | Not a technical document. Needs a SPEC or Plan to become actionable. |
| **Typical size** | 1-5 pages. |
| **When created** | At project kickoff, before anything else. |

---

## 3. Decision Matrix

### 3.1 By Project Type

| Project Type | Recommended Methodology | Justification |
|---|---|---|
| New skill (cross-agent, formal) | Manifesto + Spec-Driven + Validation Matrix | Traceability, compliance, multi-agent coordination. Example: DDI skill. |
| New feature in existing skill | SPEC + Plan | Defined scope within existing architecture. No new manifesto needed. |
| Bug fix / point adjustment | Plan (or none) | Small scope, fast execution, clear problem. |
| Product with end users | PRD + SPEC + TDD | Multiple stakeholders, quality-critical, user-facing. |
| POC / Experimentation | Plan (or none) | Speed over formality. Throw-away output expected. |
| Infrastructure / tooling | Requirements + SPEC | Precise technical definitions, system constraints. |
| Documentation project | Manifesto + Plan | Alignment on scope + execution order. TDD not applicable. |
| Multi-agent orchestration | Manifesto + Spec-Driven | Roles, boundaries, and contracts must be explicit for agent coordination. |
| Refactoring / migration | Plan + Requirements | Clear before/after state, minimal ceremony. |
| Audit / compliance | Requirements + Validation Matrix | Formal criteria, evidence-based verification. |

### 3.2 Quick Decision Flowchart

```
START: New project or task
  |
  ├── Is it a bug fix or < 1 day of work?
  │     └── YES → Simple Plan (or just do it)
  │
  ├── Does it involve multiple agents or formal governance?
  │     └── YES → Manifesto/Contract first, then:
  │           ├── Complex technical behavior? → Spec-Driven
  │           └── Execution-focused? → Plan
  │
  ├── Does it have end users or external stakeholders?
  │     └── YES → PRD first, then SPEC, then TDD for code
  │
  ├── Is it primarily code with complex logic?
  │     └── YES → TDD (+ SPEC if interfaces are non-trivial)
  │
  ├── Is it primarily documentation or templates?
  │     └── YES → Plan (TDD does not apply)
  │
  └── Is it infrastructure or system-level?
        └── YES → Requirements + SPEC
```

### 3.3 By Complexity Level

| Complexity | Time Estimate | Methodology | Example |
|---|---|---|---|
| Trivial | < 2 hours | None or verbal agreement | Fix a typo, update a version number |
| Low | 2 hours - 1 day | Simple Plan | Add a new field to an existing template |
| Medium | 1-3 days | SPEC + Plan | New operation in an existing skill |
| High | 3-10 days | Manifesto + Spec-Driven | New skill from scratch (like DDI) |
| Very High | 10+ days | PRD + Manifesto + Spec-Driven + TDD | Multi-agent product with users |

---

## 4. Combination Patterns

Most real projects use a **combination** of methodologies, not a single one. Here are proven patterns:

### Pattern A: Formal Skill Development (used in DDI)
```
Manifesto/Contract → Spec Rounds (01-05) → Implementation → Validation Matrix → Audit Gate
```

### Pattern B: Product Development
```
PRD → Requirements → SPEC → TDD → Implementation → Integration Tests → Release
```

### Pattern C: Quick Enhancement
```
Plan → Implementation → Manual Verification → Done
```

### Pattern D: Exploratory/POC
```
(Nothing formal) → Prototype → Evaluate → Decide: formalize (go to A/B) or discard
```

---

## 5. Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| PRD for internal tools | Over-formalizes what doesn't need user research | Use Manifesto + SPEC instead |
| TDD for documentation | Tests can't verify prose quality | Use Validation Matrix or peer review |
| No plan for 3+ day work | Drift, rework, misalignment | At minimum: Simple Plan with milestones |
| SPEC without knowing WHAT | Specifying HOW before knowing WHAT leads to solving the wrong problem | PRD or discovery first |
| Manifesto without follow-up | A contract nobody references is just decoration | Link manifesto to SPEC/Plan that references it |
| Over-planning small tasks | 2 hours of planning for 1 hour of work | If it's under 2 hours, just do it |

---

## 6. Integration with Existing Skills

This guide is referenced by:
- **CLAUDE.md** (`C:\ai\CLAUDE.md`) — auto-loaded in every Claude Code session
- **AGENTS.md** (`C:\ai\AGENTS.md`) — auto-loaded in every Codex session
- **GEMINI.md** (`C:\ai\GEMINI.md`) — auto-loaded in every Gemini CLI session

When an agent encounters project-level work (creation, evolution, maintenance), the instruction files above direct the agent to consult this guide before selecting an approach.

This guide does NOT replace skill-specific documentation. It complements it by answering: "Which approach should I use?" Skills then answer: "How do I document and track the work?"

---

## 7. Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0.0 | 2026-03-18 | Magneto (Claude Code - Opus 4.6) | Initial publication. Approved by Jimmy. 7 methodology profiles, decision matrix, combination patterns, anti-patterns. |
