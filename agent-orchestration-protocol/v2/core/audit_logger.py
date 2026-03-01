"""
AOP V2 - Milestone 4: Audit Logger
====================================
Generates and persists structured audit trail records per AOP v2.0.2-C.

Author: Magneto (Claude Sonnet 4.6)
Date: 2026-03-01
Contract: 03_contract-aop-v2-ciclope-final.md (v2.0.2-C)
"""

import json
import os
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional
from uuid import uuid4

from pydantic import BaseModel, Field


# ============================================================================
# Pydantic Models
# ============================================================================


class AuditActor(BaseModel):
    """Actor that performed the audited action."""

    name: str
    role: str  # ORCHESTRATOR | EXECUTOR | ROUTER | GOVERNANCE
    provider: Optional[str] = None
    model: Optional[str] = None


class BudgetStatus(BaseModel):
    """Budget tracking at time of audit record."""

    max_cost_usd: Optional[float] = None
    current_cost_usd: float = 0.0
    within_budget: bool = True


class AuditGovernance(BaseModel):
    """Governance metadata for an audit record."""

    guard_rails_applied: List[str] = Field(default_factory=list)
    budget_status: Optional[BudgetStatus] = None
    access_decision: str = "N/A"  # ALLOWED | DENIED | N/A
    reason_code: Optional[str] = None


class AuditContext(BaseModel):
    """Execution context for an audit record."""

    parent_task_id: Optional[str] = None
    attempt: int = 1
    correlation_id: str


class AuditRecord(BaseModel):
    """Complete structured audit trail record."""

    audit_record_id: str  # UUID
    audit_version: str = "1.0.0"
    timestamp: datetime
    session_id: str
    task_id: str
    record_type: str  # TASK_DISPATCHED | RESPONSE_RECEIVED | ROUTING_DECISION | GUARD_RAIL_CHECK | ROLLBACK_EVENT | SESSION_SUMMARY
    actor: AuditActor
    payload: Dict[str, Any]
    context: AuditContext
    governance: AuditGovernance


# ============================================================================
# AuditLogger
# ============================================================================


class AuditLogger:
    """Generates and persists structured audit trail records per AOP v2.0.2-C."""

    def __init__(self, storage_path: str, session_id: str):
        """
        Initialize AuditLogger.

        Args:
            storage_path: Directory where audit trail JSON files will be stored.
            session_id: Session identifier that groups all records in this session.
        """
        self.storage_path = Path(storage_path)
        self.session_id = session_id
        self._records: List[AuditRecord] = []

        # Create storage directory if it doesn't exist
        self.storage_path.mkdir(parents=True, exist_ok=True)

    # -------------------------------------------------------------------------
    # Public Logging Methods
    # -------------------------------------------------------------------------

    def log_task_dispatched(self, envelope: Any) -> AuditRecord:
        """
        Log when a TASK envelope is dispatched to an executor.

        Args:
            envelope: OrchestrationEnvelope object or dict.

        Returns:
            Persisted AuditRecord.
        """
        # Serialize envelope to dict
        if hasattr(envelope, "model_dump"):
            payload = envelope.model_dump(mode="json")
        elif isinstance(envelope, dict):
            payload = envelope
        else:
            payload = json.loads(str(envelope))

        task_id = self._extract_task_id_from_envelope(payload)

        # Extract budget info from envelope
        task_data = payload.get("task", {})
        budgets = task_data.get("budgets") or task_data.get("constraints") or {}
        max_cost = budgets.get("max_cost_usd")

        budget_status = BudgetStatus(
            max_cost_usd=max_cost,
            current_cost_usd=0.0,
            within_budget=True,
        )

        actor = AuditActor(
            name=payload.get("session", {}).get("orchestrator", "Orchestrator"),
            role="ORCHESTRATOR",
        )

        governance = AuditGovernance(
            guard_rails_applied=[],
            budget_status=budget_status,
            access_decision="ALLOWED",
            reason_code=None,
        )

        record = self._build_record(
            record_type="TASK_DISPATCHED",
            task_id=task_id,
            actor=actor,
            payload=payload,
            governance=governance,
        )

        self._persist_record(record)
        self._records.append(record)
        return record

    def log_response_received(self, response: Any) -> AuditRecord:
        """
        Log when a RESPONSE is received from an executor.

        Args:
            response: ExecutorResponse object or dict.

        Returns:
            Persisted AuditRecord.
        """
        if hasattr(response, "model_dump"):
            payload = response.model_dump(mode="json")
        elif isinstance(response, dict):
            payload = response
        else:
            payload = json.loads(str(response))

        task_id = payload.get("task_id", "UNKNOWN")

        # Extract actual cost from cost_tracking if available
        cost_tracking = payload.get("cost_tracking") or {}
        actual_cost = cost_tracking.get("actual_cost_usd", 0.0) or 0.0

        budget_status = BudgetStatus(
            max_cost_usd=None,
            current_cost_usd=actual_cost,
            within_budget=True,
        )

        agent_info = payload.get("agent", {})
        actor = AuditActor(
            name=agent_info.get("name", "Executor"),
            role="EXECUTOR",
            provider=agent_info.get("provider"),
            model=agent_info.get("model"),
        )

        governance = AuditGovernance(
            guard_rails_applied=["FINAL_SIGNAL", "MINIMAL_REPORT"],
            budget_status=budget_status,
            access_decision="ALLOWED",
            reason_code=None,
        )

        record = self._build_record(
            record_type="RESPONSE_RECEIVED",
            task_id=task_id,
            actor=actor,
            payload=payload,
            governance=governance,
        )

        self._persist_record(record)
        self._records.append(record)
        return record

    def log_routing_decision(
        self,
        task_id: str,
        input_version: str,
        routed_to: str,
        model_selected: str,
        fallback_triggered: bool = False,
        fallback_reason: Optional[str] = None,
        alternatives_tried: Optional[List[str]] = None,
    ) -> AuditRecord:
        """
        Log a routing/fallback decision.

        Args:
            task_id: Task being routed.
            input_version: Detected input version (V2 | V1 | UNSTRUCTURED).
            routed_to: Agent name that received the task.
            model_selected: Model identifier selected.
            fallback_triggered: Whether fallback was triggered.
            fallback_reason: E_* code explaining why fallback triggered.
            alternatives_tried: List of alternative models/agents tried.

        Returns:
            Persisted AuditRecord.
        """
        payload = {
            "input_version": input_version,
            "routed_to": routed_to,
            "model_selected": model_selected,
            "fallback_triggered": fallback_triggered,
            "fallback_reason": fallback_reason,
            "alternatives_tried": alternatives_tried or [],
        }

        actor = AuditActor(name="VersionRouter", role="ROUTER")

        governance = AuditGovernance(
            guard_rails_applied=[],
            budget_status=None,
            access_decision="ALLOWED" if not fallback_triggered else "ALLOWED",
            reason_code=fallback_reason,
        )

        record = self._build_record(
            record_type="ROUTING_DECISION",
            task_id=task_id,
            actor=actor,
            payload=payload,
            governance=governance,
        )

        self._persist_record(record)
        self._records.append(record)
        return record

    def log_guard_rail_check(
        self,
        task_id: str,
        check_type: str,
        result: str,
        details: str,
        error_code: Optional[str] = None,
    ) -> AuditRecord:
        """
        Log a guard rail check result.

        Args:
            task_id: Task being checked.
            check_type: Type of guard rail (PAYLOAD_LIMIT | BUDGET | TIMEOUT | ACCESS | FINAL_SIGNAL | MINIMAL_REPORT).
            result: Check result (PASS | WARN | FAIL).
            details: Human-readable details of the check.
            error_code: E_* code if result is FAIL or WARN.

        Returns:
            Persisted AuditRecord.
        """
        payload = {
            "check_type": check_type,
            "result": result,
            "details": details,
            "error_code": error_code,
        }

        actor = AuditActor(name="GuardRailEngine", role="GOVERNANCE")

        access_decision = "ALLOWED" if result in ("PASS", "WARN") else "DENIED"

        governance = AuditGovernance(
            guard_rails_applied=[check_type],
            budget_status=None,
            access_decision=access_decision,
            reason_code=error_code,
        )

        record = self._build_record(
            record_type="GUARD_RAIL_CHECK",
            task_id=task_id,
            actor=actor,
            payload=payload,
            governance=governance,
        )

        self._persist_record(record)
        self._records.append(record)
        return record

    def log_rollback_event(
        self,
        task_id: str,
        trigger: str,
        artifacts_rolled_back: List[Dict],
        status: str,
    ) -> AuditRecord:
        """
        Log a rollback event.

        Args:
            task_id: Task that triggered the rollback.
            trigger: Human-readable reason for rollback.
            artifacts_rolled_back: List of artifact dicts with path/status info.
            status: Overall rollback status (SUCCESS | FAILED).

        Returns:
            Persisted AuditRecord.
        """
        payload = {
            "trigger": trigger,
            "artifacts_rolled_back": artifacts_rolled_back,
            "status": status,
        }

        actor = AuditActor(name="Orchestrator", role="ORCHESTRATOR")

        reason_code = "E_ROLLBACK_FAILED" if status == "FAILED" else None

        governance = AuditGovernance(
            guard_rails_applied=[],
            budget_status=None,
            access_decision="N/A",
            reason_code=reason_code,
        )

        record = self._build_record(
            record_type="ROLLBACK_EVENT",
            task_id=task_id,
            actor=actor,
            payload=payload,
            governance=governance,
        )

        self._persist_record(record)
        self._records.append(record)
        return record

    def generate_session_summary(self) -> AuditRecord:
        """
        Generate a SESSION_SUMMARY record aggregating all records in this session.

        Reads all persisted records and aggregates costs, task counts, and agent info.

        Returns:
            Persisted SESSION_SUMMARY AuditRecord.
        """
        # Load all records from disk to ensure completeness
        all_records = self.get_session_records()

        total_tasks = 0
        completed = 0
        failed = 0
        total_cost_usd = 0.0
        agents_used = set()
        role_assignments = []
        start_time = None
        end_time = None

        for record in all_records:
            ts = record.timestamp
            if start_time is None or ts < start_time:
                start_time = ts
            if end_time is None or ts > end_time:
                end_time = ts

            if record.record_type == "TASK_DISPATCHED":
                total_tasks += 1

            elif record.record_type == "RESPONSE_RECEIVED":
                task_status = record.payload.get("task_status", {})
                final_signal = task_status.get("final_signal", "")
                if final_signal in ("SUCCESS", "PARTIAL_SUCCESS"):
                    completed += 1
                elif final_signal in ("FAILURE", "ABORTED"):
                    failed += 1

                cost_tracking = record.payload.get("cost_tracking") or {}
                cost = cost_tracking.get("actual_cost_usd") or 0.0
                total_cost_usd += cost

                agent_info = record.payload.get("agent", {})
                agent_name = agent_info.get("name", "")
                agent_model = agent_info.get("model", "")
                if agent_name:
                    agents_used.add(agent_name)
                    role_assignments.append({
                        "agent": agent_name,
                        "role": record.actor.role,
                        "model": agent_model,
                    })

            elif record.record_type == "GUARD_RAIL_CHECK":
                # Accumulate budget costs from guard rail checks
                if record.governance.budget_status:
                    bs = record.governance.budget_status
                    if bs.current_cost_usd > total_cost_usd:
                        total_cost_usd = max(total_cost_usd, bs.current_cost_usd)

        # Calculate duration
        total_duration = 0.0
        if start_time and end_time:
            total_duration = (end_time - start_time).total_seconds()

        payload = {
            "total_tasks": total_tasks,
            "completed": completed,
            "failed": failed,
            "total_cost_usd": round(total_cost_usd, 6),
            "total_duration_seconds": total_duration,
            "agents_used": sorted(list(agents_used)),
            "role_assignments": role_assignments,
        }

        actor = AuditActor(name="Orchestrator", role="ORCHESTRATOR")

        governance = AuditGovernance(
            guard_rails_applied=[],
            budget_status=None,
            access_decision="N/A",
            reason_code=None,
        )

        record = self._build_record(
            record_type="SESSION_SUMMARY",
            task_id="SESSION",
            actor=actor,
            payload=payload,
            governance=governance,
        )

        self._persist_record(record)
        self._records.append(record)
        return record

    def get_session_records(self) -> List[AuditRecord]:
        """
        Return all audit records for the current session.

        Reads from disk to ensure we get all records including those from
        previous method calls or recovered sessions.

        Returns:
            List of AuditRecord objects sorted by timestamp.
        """
        records = []
        if not self.storage_path.exists():
            return records

        for file_path in sorted(self.storage_path.glob(f"{self.session_id}_*.json")):
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                record = AuditRecord.model_validate(data)
                records.append(record)
            except Exception as e:
                # Log but do not fail on corrupt records
                print(f"WARNING: Failed to load audit record {file_path}: {e}")

        # Sort by timestamp
        records.sort(key=lambda r: r.timestamp)
        return records

    # -------------------------------------------------------------------------
    # Internal Methods
    # -------------------------------------------------------------------------

    def _persist_record(self, record: AuditRecord) -> Path:
        """
        Write a single audit record to disk as JSON (atomic write).

        Args:
            record: AuditRecord to persist.

        Returns:
            Path to the written file.
        """
        # Build filename: {session_id}_{task_id}_{record_type}_{timestamp_compact}.json
        ts_compact = record.timestamp.strftime("%Y%m%dT%H%M%SZ")
        # Sanitize task_id for filesystem
        safe_task_id = record.task_id.replace("/", "_").replace("\\", "_").replace(" ", "_")
        filename = f"{record.session_id}_{safe_task_id}_{record.record_type}_{ts_compact}_{record.audit_record_id[:8]}.json"
        final_path = self.storage_path / filename

        # Serialize with Pydantic v2
        data = record.model_dump(mode="json")
        json_content = json.dumps(data, indent=2, ensure_ascii=False)

        # Atomic write: temp file -> rename
        tmp_fd, tmp_path = tempfile.mkstemp(
            dir=str(self.storage_path),
            prefix=".tmp_audit_",
            suffix=".json"
        )
        try:
            with os.fdopen(tmp_fd, "w", encoding="utf-8") as f:
                f.write(json_content)
            os.replace(tmp_path, str(final_path))
        except Exception:
            # Clean up temp file on failure
            try:
                os.unlink(tmp_path)
            except OSError:
                pass
            raise

        return final_path

    def _build_record(
        self,
        record_type: str,
        task_id: str,
        actor: AuditActor,
        payload: Dict[str, Any],
        governance: AuditGovernance,
        parent_task_id: Optional[str] = None,
        attempt: int = 1,
    ) -> AuditRecord:
        """
        Build an AuditRecord with common fields filled in.

        Args:
            record_type: Type of audit record.
            task_id: Associated task ID.
            actor: Actor that performed the action.
            payload: Event-specific payload.
            governance: Governance metadata.
            parent_task_id: Optional parent task ID.
            attempt: Attempt number (default 1).

        Returns:
            AuditRecord (not yet persisted).
        """
        return AuditRecord(
            audit_record_id=str(uuid4()),
            audit_version="1.0.0",
            timestamp=datetime.now(timezone.utc),
            session_id=self.session_id,
            task_id=task_id,
            record_type=record_type,
            actor=actor,
            payload=payload,
            context=AuditContext(
                parent_task_id=parent_task_id,
                attempt=attempt,
                correlation_id=self.session_id,
            ),
            governance=governance,
        )

    def _extract_task_id_from_envelope(self, envelope_dict: Dict[str, Any]) -> str:
        """Extract task_id from an envelope dict."""
        task = envelope_dict.get("task", {})
        return task.get("task_id", "UNKNOWN")
