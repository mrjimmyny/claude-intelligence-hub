# Agent Orchestration Protocol (AOP) – JSON v2 Contract (Cyclops v2.0.2-C)

> Base Drafts: Cyclops v2.0.0, Magneto v2.0.1-M, Emma v2.0.1-E  
> This Contract: Cyclops (merged, canonical, compatibility-first)  
> Status: CONTRACT v2.0.2-C – Ready for Implementation

---

## 0. Merge Summary (Cyclops)

This contract merges Magneto’s **resilience & observability** focus and Emma’s **executor ergonomics & compatibility** focus into a single, conservative, backward-compatible spec.

Design stance:
- **No new REQUIRED fields** versus v2.0.0.
- All additions are OPTIONAL and live under clearly-scoped fields.
- Any message valid in v2.0.0 **remains valid** in v2.0.2-C.
- Implementations MAY progressively adopt v2.0.1-M/E features without breaking older agents.

Key merged features:
1. **Heartbeat & progress events** (Magneto) – optional, for early failure detection and UX.
2. **Practical payload limits** (both) – soft & hard, with explicit error codes.
3. **Cost tracking & budgets** (both) – optional task budgets + response/session cost tracking.
4. **Checkpoint recovery semantics** (both) – `recovery_strategy` on checkpoints.
5. **Rollback protocol** (both) – orchestrator-owned snapshots & rollback events.
6. **Explicit fallback triggers** for alternative models (Magneto).
7. **Dynamic priority escalation events** (Magneto).
8. **Effective access rules & precedence** for timeouts & policies (Emma).
9. **Extensions mechanism** (Emma) – `extensions` objects with `x_`-prefixed keys.

All of this rides on the **stable core** from v2.0.0.

---

## 1. Versioning & Compatibility

### 1.1 Canonical Version Header (REQUIRED)

```json
{
  "aop_version": "2.0.2-C",
  "schema_version": "2.0.2",
  "protocol_family": "AOP"
}
```

Rules:
- `aop_version` – protocol revision; `2.0.2-C` = Cyclops merged contract.
- `schema_version` – schema revision; increases only when JSON schema changes.
- `protocol_family` – MUST be `"AOP"`.

Compatibility:
- Any **valid v2.0.0** message is valid under v2.0.2-C.
- Orchestrators MUST accept any `aop_version` that starts with `"2."` and validate
  against the latest known schema, falling back conservatively if unknown fields appear.

### 1.2 Message Types

```json
"message_type": "TASK" | "RESPONSE" | "EVENT"
```

Cross-field rules:
- `TASK` – MUST contain `session`, `target`, `task`. MUST NOT contain `task_status`.
- `RESPONSE` – MUST contain `task_status`, `agent`, `session_id`, `task_id`.
- `EVENT` – used for **version**, **heartbeat**, **progress**, **priority**, **rollback**, **final report**, etc.

### 1.3 V2 Detection & V1 Fallback

Same pipeline as Cyclops v2.0.0, with Emma’s clarification:

1. Try JSON parse.
2. If parsed and `aop_version` starts with `"2."` → validate as v2.
3. If parsed and `aop_version` missing → attempt v1 markdown detection.
4. If neither → classify as `UNSTRUCTURED`.

On schema failure, emit `VERSION_FALLBACK` event and transform to v1 prompt.

---

## 2. Core TASK Envelope

### 2.1 Minimal Envelope (Baseline)

```json
{
  "aop_version": "2.0.2-C",
  "schema_version": "2.0.2",
  "protocol_family": "AOP",
  "message_type": "TASK",
  "session": {
    "session_id": "AOP-SESSION-2026-02-26-001",
    "created_at": "2026-02-26T14:00:00Z",
    "orchestrator": "Cyclops",
    "origin": "CLI"
  },
  "target": {
    "agent_name": "Emma",
    "role": "EXECUTOR",
    "provider": "CODEX",
    "model": "gpt-5.3-codex"
  },
  "task": {
    "task_id": "TASK-001",
    "objective": "Read and summarize the README.md file.",
    "category": "ANALYSIS",
    "complexity": "LOW",
    "environment": {
      "workspace_root": "C:/ai/my-project"
    }
  }
}
```

Enums and defaults remain as in v2.0.0 (no change).

### 2.2 Full Envelope (with Optional Enhancements)

The full envelope remains v2.0.0-compatible, with **optional** new fields from Magneto and Emma:

```json
{
  "aop_version": "2.0.2-C",
  "schema_version": "2.0.2",
  "protocol_family": "AOP",
  "message_type": "TASK",
  "session": {
    "session_id": "AOP-SESSION-2026-02-26-001",
    "created_at": "2026-02-26T12:34:56Z",
    "orchestrator": "Cyclops",
    "origin": "CLI",
    "workflow_pattern": "CHAIN",
    "extensions": {
      "x_org_policy": "strict"
    }
  },
  "target": {
    "agent_name": "Emma",
    "role": "EXECUTOR",
    "provider": "CODEX",
    "model": "gpt-5.3-codex",
    "execution_profile": "balanced",
    "capabilities": {
      "aop_versions_supported": ["2.0.2-C", "2.0.1-M", "2.0.1-E", "2.0.0", "1.x"],
      "file_system_access": true,
      "network_access": "RESTRICTED",
      "headless_mode": true
    },
    "extensions": {
      "x_vendor_feature": { "enabled": true }
    }
  },
  "task": {
    "task_id": "TASK-001",
    "parent_task_id": null,
    "attempt": 1,
    "objective": "Refactor module X to use dependency injection.",
    "category": "CODE_REFACTORING",
    "complexity": "MEDIUM",
    "priority": "NORMAL",
    "environment": {
      "workspace_root": "C:/workspace/project-x",
      "os": "win32",
      "shell": "powershell",
      "git_branch": "feature/new-refactor"
    },
    "inputs": [
      {
        "type": "FILE",
        "path": "C:/workspace/project-x/src/module_x.py",
        "read_only": true
      }
    ],
    "expected_outputs": [
      {
        "type": "FILE",
        "path": "C:/workspace/project-x/src/module_x.py",
        "description": "Refactored file with DI pattern.",
        "validation": {
          "command": "python -m py_compile src/module_x.py",
          "expects": "EXIT_CODE_0"
        },
        "rollback_snapshot": {
          "enabled": true,
          "snapshot_path": "C:/workspace/project-x/.aop_snapshots/module_x.py.before",
          "snapshot_strategy": "COPY"
        }
      },
      {
        "type": "FILE",
        "path": "C:/workspace/project-x/tests/test_module_x.py",
        "description": "New unit tests for module X.",
        "validation": {
          "command": "pytest tests/test_module_x.py",
          "expects": "EXIT_CODE_0"
        }
      }
    ],
    "constraints": {
      "max_tokens": 15000,
      "max_cost_usd": 0.50,
      "read_only_mode": false,
      "delegation_allowed": false,
      "network_access": "RESTRICTED"
    },
    "budgets": {
      "max_cost_usd": 0.50,
      "max_tokens": 15000
    },
    "access": {
      "filesystem": {
        "read_paths": ["C:/workspace/project-x"],
        "write_paths": ["C:/workspace/project-x/src", "C:/workspace/project-x/tests"]
      },
      "network": "RESTRICTED"
    },
    "extensions": {
      "x_tool_preference": "shell_command"
    }
  },
  "execution_policy": {
    "timeout_seconds": 1800,
    "max_retries": 1,
    "retry_backoff_seconds": [30, 120, 300],
    "abort_on_first_critical_error": false,
    "auto_terminate_on_timeout": true,
    "on_failure": "REPORT_AND_CONTINUE",
    "alternative_models": [
      {
        "provider": "GEMINI",
        "model": "gemini-2.5-pro",
        "fallback_trigger": "TIMEOUT"
      },
      {
        "provider": "CLAUDE",
        "model": "claude-opus-4-6",
        "fallback_trigger": "ALL_ERRORS"
      }
    ],
    "heartbeat": {
      "enabled": true,
      "interval_seconds": 120,
      "max_missed_beats": 3,
      "on_heartbeat_failure": "ABORT"
    },
    "extensions": {
      "x_routing_hint": "prefer_low_latency"
    }
  },
  "guard_rails": {
    "require_minimal_report": true,
    "require_final_signal": true,
    "auto_terminate_on_timeout": true,
    "timeout_seconds": 1800,
    "abort_on_first_critical_error": false,
    "extensions": {
      "x_human_review_required": false
    }
  },
  "phases": [
    {
      "phase_id": "PHASE-ANALYSIS",
      "phase_order": 1,
      "label": "Analysis",
      "objective": "Analyze existing code and identify global state usage.",
      "checkpoints": [
        {
          "checkpoint_id": "CP-ANA-001",
          "description": "Identify global config access in module_x.py.",
          "expected_artifacts": [
            { "type": "FILE", "path": "C:/workspace/project-x/src/module_x.py" }
          ],
          "validation": {
            "command": "grep -n 'config.get' src/module_x.py",
            "expects": "MATCH_FOUND"
          },
          "status": "PENDING",
          "recovery_strategy": "RETRY"
        }
      ]
    },
    {
      "phase_id": "PHASE-IMPLEMENTATION",
      "phase_order": 2,
      "label": "Implementation",
      "objective": "Apply refactoring and create unit tests.",
      "checkpoints": [
        {
          "checkpoint_id": "CP-IMPL-001",
          "description": "module_x.py refactored and compiles.",
          "expected_artifacts": [
            { "type": "FILE", "path": "C:/workspace/project-x/src/module_x.py" }
          ],
          "validation": {
            "command": "python -m py_compile src/module_x.py",
            "expects": "EXIT_CODE_0"
          },
          "status": "PENDING",
          "recovery_strategy": "ABORT"
        }
      ]
    }
  ],
  "orchestration_metadata": {
    "initiator": "user@domain.com",
    "spec_author": "Cyclops",
    "tags": ["AOP_V2", "REFACTORING", "CONTRACT"],
    "notes": "Merged Magneto + Emma revisions into Cyclops contract v2.0.2-C.",
    "extensions": {
      "x_internal_ticket": "AOP-2026-001"
    }
  },
  "extensions": {
    "x_experimental": false
  }
}
```

---

## 3. Extensions Mechanism

To keep `additionalProperties: false` while allowing vendor-specific data:

- Any core object MAY have an `extensions` object.
- Keys inside `extensions` MUST start with `"x_"`.
- Orchestrators MUST ignore unknown `extensions` keys.

This is Emma’s mechanism, adopted as canonical.

---

## 4. Practical Payload Limits

Merged table from Magneto and Emma (values identical):

| Field | Max Size | Enforcement |
|------|----------|------------|
| `task.objective` | 50,000 chars | SOFT (warn at 40k) |
| `task.inputs[]` total | 100 files | HARD |
| `task.expected_outputs[]` total | 50 artifacts | HARD |
| `phases[]` total | 10 | SOFT |
| `checkpoints[]` per phase | 20 | SOFT |
| `execution_summary.actions[]` | 200 items | SOFT |
| Total TASK envelope | 200KB JSON | HARD |
| Total RESPONSE envelope | 500KB JSON | HARD |

Overflow behavior:
- SOFT → emit `E_PAYLOAD_SIZE_WARNING` (Magneto & Emma).
- HARD → reject with `E_CONTEXT_OVERFLOW`.

---

## 5. Executor Response (RESPONSE)

Same core as v2.0.0, with optional additions:

```json
{
  "aop_version": "2.0.2-C",
  "schema_version": "2.0.2",
  "protocol_family": "AOP",
  "message_type": "RESPONSE",
  "session_id": "AOP-SESSION-2026-02-26-001",
  "task_id": "TASK-001",
  "agent": {
    "name": "Emma",
    "provider": "CODEX",
    "model": "gpt-5.3-codex"
  },
  "task_status": {
    "state": "COMPLETED",
    "final_signal": "SUCCESS",
    "message": "Task completed successfully."
  },
  "execution_summary": {
    "summary": "Refactored module_x.py to use dependency injection and added scaffolding tests.",
    "actions": [
      "Read src/module_x.py (312 lines).",
      "Identified 4 uses of global configuration.",
      "Introduced ConfigProvider interface.",
      "Updated module_x.py to accept ConfigProvider.",
      "Created tests/test_module_x.py with initial test cases."
    ],
    "output_artifacts": [
      {
        "type": "FILE",
        "path": "C:/workspace/project-x/src/module_x.py",
        "hash": "sha256:abc123def456...",
        "status": "UPDATED",
        "size_bytes": 8432
      },
      {
        "type": "FILE",
        "path": "C:/workspace/project-x/tests/test_module_x.py",
        "hash": "sha256:789ghi012jkl...",
        "status": "CREATED",
        "size_bytes": 3210
      }
    ],
    "warnings": [],
    "errors": [],
    "extensions": {
      "x_log_ref": "logs/session-001/task-001.log"
    }
  },
  "checkpoint_results": [
    {
      "checkpoint_id": "CP-IMPL-001",
      "status": "PASS",
      "validation_output": "Compilation successful. Exit code 0.",
      "evidence": [
        "python -m py_compile src/module_x.py → exit 0",
        "File size: 8432 bytes (> 0)"
      ],
      "notes": "File present, compiles cleanly, non-empty."
    }
  ],
  "error_details": null,
  "timing": {
    "started_at": "2026-02-26T12:35:01Z",
    "completed_at": "2026-02-26T12:40:32Z",
    "duration_seconds": 331,
    "retries_attempted": 0
  },
  "cost_tracking": {
    "estimated_cost_usd": 0.15,
    "actual_cost_usd": 0.18,
    "tokens_input": 12500,
    "tokens_output": 3200,
    "model_pricing_tier": "standard"
  },
  "progress_log": {
    "last_progress_event_at": "2026-02-26T12:38:30Z",
    "progress_percentage": 60
  },
  "extensions": {
    "x_debug_id": "resp-uuid-1234"
  }
}
```

Guard rails:
- `require_final_signal = true` → must have `task_status.state` + `task_status.final_signal`.
- `require_minimal_report = true` → must have non-empty `summary` + `actions`.

---

## 6. Heartbeat & Progress Events

### 6.1 Heartbeat (Optional)

Config (in `execution_policy.heartbeat`):

```json
"heartbeat": {
  "enabled": true,
  "interval_seconds": 120,
  "max_missed_beats": 3,
  "on_heartbeat_failure": "ABORT"
}
```

Event:

```json
{
  "aop_version": "2.0.2-C",
  "message_type": "EVENT",
  "event": "HEARTBEAT",
  "session_id": "AOP-SESSION-2026-02-26-001",
  "task_id": "TASK-001",
  "timestamp": "2026-02-26T12:37:01Z",
  "agent": "Emma",
  "progress_percentage": 45,
  "current_phase": "PHASE-IMPLEMENTATION",
  "current_checkpoint": "CP-IMPL-001"
}
```

### 6.2 Progress Updates (Optional)

Event:

```json
{
  "aop_version": "2.0.2-C",
  "message_type": "EVENT",
  "event": "PROGRESS_UPDATE",
  "session_id": "AOP-SESSION-2026-02-26-001",
  "task_id": "TASK-001",
  "timestamp": "2026-02-26T12:38:30Z",
  "agent": "Emma",
  "progress": {
    "percentage": 60,
    "current_phase": "PHASE-IMPLEMENTATION",
    "current_checkpoint": "CP-IMPL-001",
    "message": "Refactoring 3 of 5 functions",
    "estimated_time_remaining_seconds": 420
  }
}
```

Frequency: not more than once every 30 seconds.

---

## 7. Rollback Protocol (Orchestrator-Owned)

Snapshot configuration in `expected_outputs`:

```json
"rollback_snapshot": {
  "enabled": true,
  "snapshot_path": "C:/workspace/project-x/.aop_snapshots/module_x.py.before",
  "snapshot_strategy": "COPY"
}
```

Rollback event:

```json
{
  "aop_version": "2.0.2-C",
  "message_type": "EVENT",
  "event": "ROLLBACK_INITIATED",
  "session_id": "AOP-SESSION-2026-02-26-001",
  "task_id": "TASK-001",
  "timestamp": "2026-02-26T12:45:00Z",
  "trigger": "TASK_ABORTED",
  "artifacts_rolled_back": [
    {
      "path": "C:/workspace/project-x/src/module_x.py",
      "restored_from": "C:/workspace/project-x/.aop_snapshots/module_x.py.before",
      "status": "SUCCESS"
    }
  ]
}
```

Executors are **not required** to perform rollback; this is orchestrator tooling.

---

## 8. Priority Escalation (Optional)

Event:

```json
{
  "aop_version": "2.0.2-C",
  "message_type": "EVENT",
  "event": "PRIORITY_ESCALATION",
  "session_id": "AOP-SESSION-2026-02-26-001",
  "task_id": "TASK-001",
  "timestamp": "2026-02-26T12:40:00Z",
  "old_priority": "NORMAL",
  "new_priority": "CRITICAL",
  "reason": "User manually escalated via CLI",
  "escalated_by": "user@domain.com"
}
```

Effects are implementation-specific (e.g., model upgrade, resource preference).

---

## 9. Model & Agent Routing + Fallback Triggers

Same routing rules as previous v2 drafts, with Magneto’s explicit triggers:

```json
"alternative_models": [
  {
    "provider": "GEMINI",
    "model": "gemini-2.5-pro",
    "fallback_trigger": "TIMEOUT"
  },
  {
    "provider": "CLAUDE",
    "model": "claude-opus-4-6",
    "fallback_trigger": "ALL_ERRORS"
  }
]
```

Triggers: `TIMEOUT`, `FIRST_ERROR`, `CRITICAL_ERROR`, `ALL_ERRORS`, `COST_LIMIT_EXCEEDED`.

---

## 10. Delegation Graph & Session Final Report

Unchanged structurally from Cyclops v2.0.0, with cost summary and events from Magneto/Emma.

Final session report adds optional `cost_summary` and continues to use:
- `audit_trail.storage_path = "_skills/agent-orchestration-protocol_d/v2/audit_trails/"`

---

## 11. Policy Precedence & Effective Access

Adopting Emma’s precedence rules:

1. Timeout:
   - If `guard_rails.timeout_seconds` is set → it overrides `execution_policy.timeout_seconds`.
   - Else use `execution_policy.timeout_seconds`.
   - If neither set → executor defaults.

2. Access:
   - Effective filesystem access = intersection of `target.capabilities` + `task.access.filesystem`.
   - Effective network access = **most restrictive** of `target.capabilities.network_access` and `task.access.network`.

---

## 12. Error Taxonomy (Merged)

Combined list from Magneto + Emma:

- `E_TIMEOUT` – task exceeded timeout.
- `E_HEARTBEAT_FAILURE` – missed `max_missed_beats`.
- `E_PARSE_FAILURE` – could not parse JSON or v1 markdown.
- `E_SCHEMA_VALIDATION` – JSON parsed but failed v2 schema.
- `E_AGENT_NOT_FOUND` – agent missing/unreachable.
- `E_MODEL_UNAVAILABLE` – requested model unavailable.
- `E_ALL_MODELS_EXHAUSTED` – all alternatives failed.
- `E_FILE_NOT_FOUND` – required input missing.
- `E_PERMISSION_DENIED` – FS/network not permitted.
- `E_CONTEXT_OVERFLOW` – exceeded hard size/context limits.
- `E_PAYLOAD_SIZE_WARNING` – exceeded soft limit (warning).
- `E_MALFORMED_RESPONSE` – response schema invalid.
- `E_DEPENDENCY_FAILED` – dependency node aborted.
- `E_MAX_DEPTH_EXCEEDED` – delegation depth > 3.
- `E_PROCESS_CRASH` – CLI process crashed / non-zero.
- `E_COST_LIMIT_EXCEEDED` – budgets / max_cost_usd exceeded.
- `E_ROLLBACK_FAILED` – rollback attempt failed.
- `E_UNKNOWN` – everything else.

---

## 13. Status of this Document

This **Cyclops v2.0.2-C contract** is the canonical, merged AOP JSON v2 spec for your local multi-agent stack.

- Magneto’s v2.0.1-M and Emma’s v2.0.1-E are now **source drafts**; this file is the authoritative contract.
- Future proposals (v2.1+) MUST start from here and clearly label any new REQUIRED fields or breaking changes.

Implementation order recommendation:
1. Implement **core v2.0.0** (if not already).
2. Add **extensions + cost tracking + payload limits**.
3. Add **heartbeat + progress events**.
4. Add **rollback + priority escalation** where needed.

This staged adoption lets Xavier, Magneto, Forge, and Emma evolve without breaking each other.
