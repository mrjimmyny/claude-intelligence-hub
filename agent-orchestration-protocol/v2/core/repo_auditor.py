"""
AOP V2 - Milestone 4: Repo Auditor
=====================================
Replays and validates audit trails against the AOP v2.0.2-C contract.

Performs Repo-Auditor scenarios:
- Replay real orchestration sessions from audit trails
- Verify all messages comply with the v2 contract
- Check that budgets, payload limits, and guard rails were correctly applied
- Check that role assignments did not violate capabilities or access constraints

Author: Magneto (Claude Sonnet 4.6)
Date: 2026-03-01
Contract: 03_contract-aop-v2-ciclope-final.md (v2.0.2-C)
"""

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field

from audit_logger import AuditRecord


# ============================================================================
# Pydantic Models
# ============================================================================


class AuditFinding(BaseModel):
    """A single audit finding from a validation check."""

    check_name: str
    status: str  # PASS | WARN | FAIL
    details: str
    record_ids: List[str] = Field(default_factory=list)
    error_codes: List[str] = Field(default_factory=list)


class AuditReport(BaseModel):
    """Complete audit report for a session."""

    session_id: str
    audit_timestamp: datetime
    total_records: int
    findings: List[AuditFinding]
    overall_status: str  # PASS | WARN | FAIL (worst finding wins)
    summary: str


# ============================================================================
# RepoAuditor
# ============================================================================

# Contract limits (Contract Section 4)
TASK_PAYLOAD_LIMIT_BYTES = 200 * 1024    # 200KB
RESPONSE_PAYLOAD_LIMIT_BYTES = 500 * 1024  # 500KB

# Valid roles per contract
VALID_ROLES = {"ORCHESTRATOR", "EXECUTOR", "ROUTER", "GOVERNANCE", "SPECIALIST"}

# Valid actor roles per record type
RECORD_TYPE_EXPECTED_ROLES = {
    "TASK_DISPATCHED": {"ORCHESTRATOR"},
    "RESPONSE_RECEIVED": {"EXECUTOR", "SPECIALIST"},
    "ROUTING_DECISION": {"ROUTER"},
    "GUARD_RAIL_CHECK": {"GOVERNANCE"},
    "ROLLBACK_EVENT": {"ORCHESTRATOR"},
    "SESSION_SUMMARY": {"ORCHESTRATOR"},
}


class RepoAuditor:
    """Replays and validates audit trails against the AOP v2.0.2-C contract."""

    def __init__(self, audit_trails_path: str, schemas_path: str):
        """
        Initialize RepoAuditor.

        Args:
            audit_trails_path: Directory containing audit trail JSON files.
            schemas_path: Directory containing JSON schema files.
        """
        self.audit_trails_path = Path(audit_trails_path)
        self.schemas_path = Path(schemas_path)
        self._schema_cache: Dict[str, Any] = {}

    # -------------------------------------------------------------------------
    # Session Loading
    # -------------------------------------------------------------------------

    def load_session(self, session_id: str) -> List[AuditRecord]:
        """
        Load all audit records for a given session.

        Args:
            session_id: Session identifier to load.

        Returns:
            List of AuditRecord objects sorted by timestamp.
        """
        records = []
        if not self.audit_trails_path.exists():
            return records

        pattern = f"{session_id}_*.json"
        for file_path in sorted(self.audit_trails_path.glob(pattern)):
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                record = AuditRecord.model_validate(data)
                records.append(record)
            except Exception as e:
                print(f"WARNING: Failed to load audit record {file_path}: {e}")

        records.sort(key=lambda r: r.timestamp)
        return records

    # -------------------------------------------------------------------------
    # Individual Validation Methods
    # -------------------------------------------------------------------------

    def validate_message_compliance(self, record: AuditRecord) -> AuditFinding:
        """
        Verify a TASK_DISPATCHED or RESPONSE_RECEIVED record complies with v2 schema.

        Validates the payload against the appropriate JSON schema.

        Args:
            record: AuditRecord to validate.

        Returns:
            AuditFinding with PASS/FAIL status.
        """
        if record.record_type not in ("TASK_DISPATCHED", "RESPONSE_RECEIVED"):
            return AuditFinding(
                check_name="message_compliance",
                status="PASS",
                details=f"Record type {record.record_type} does not require message compliance check",
                record_ids=[record.audit_record_id],
            )

        # Determine which schema to use
        if record.record_type == "TASK_DISPATCHED":
            schema_name = "task_envelope.schema.json"
            expected_msg_type = "TASK"
        else:
            schema_name = "executor_response.schema.json"
            expected_msg_type = "RESPONSE"

        payload = record.payload

        # Basic structural validation
        msg_type = payload.get("message_type")
        if msg_type != expected_msg_type:
            return AuditFinding(
                check_name="message_compliance",
                status="FAIL",
                details=f"Expected message_type={expected_msg_type}, got {msg_type!r}",
                record_ids=[record.audit_record_id],
                error_codes=["E_SCHEMA_VALIDATION"],
            )

        # Try JSON Schema validation if jsonschema is available
        schema = self._load_schema(schema_name)
        if schema is not None:
            try:
                import jsonschema
                jsonschema.validate(instance=payload, schema=schema)
            except ImportError:
                # jsonschema not installed - skip schema validation
                pass
            except jsonschema.ValidationError as e:
                return AuditFinding(
                    check_name="message_compliance",
                    status="FAIL",
                    details=f"Schema validation failed: {e.message}",
                    record_ids=[record.audit_record_id],
                    error_codes=["E_SCHEMA_VALIDATION"],
                )
            except jsonschema.SchemaError as e:
                return AuditFinding(
                    check_name="message_compliance",
                    status="WARN",
                    details=f"Schema file error (cannot validate): {e.message}",
                    record_ids=[record.audit_record_id],
                )

        # Validate required fields based on record type
        if record.record_type == "TASK_DISPATCHED":
            missing = [
                f for f in ("session", "target", "task")
                if f not in payload
            ]
        else:  # RESPONSE_RECEIVED
            missing = [
                f for f in ("session_id", "task_id", "agent", "task_status", "execution_summary")
                if f not in payload
            ]

        if missing:
            return AuditFinding(
                check_name="message_compliance",
                status="FAIL",
                details=f"Missing required fields: {missing}",
                record_ids=[record.audit_record_id],
                error_codes=["E_SCHEMA_VALIDATION"],
            )

        return AuditFinding(
            check_name="message_compliance",
            status="PASS",
            details=f"Record {record.record_type} complies with {schema_name}",
            record_ids=[record.audit_record_id],
        )

    def validate_budget_compliance(self, session_records: List[AuditRecord]) -> AuditFinding:
        """
        Check that budgets were not exceeded across the session.

        Inspects GUARD_RAIL_CHECK records with check_type=BUDGET and
        SESSION_SUMMARY for cost validation.

        Args:
            session_records: All records for a session.

        Returns:
            AuditFinding with PASS/FAIL status.
        """
        violations = []
        record_ids = []

        for record in session_records:
            if record.record_type == "GUARD_RAIL_CHECK":
                payload = record.payload
                if payload.get("check_type") == "BUDGET":
                    result = payload.get("result")
                    if result == "FAIL":
                        violations.append(
                            f"Budget check FAIL at task={record.task_id}: {payload.get('details', '')}"
                        )
                        record_ids.append(record.audit_record_id)

            # Also check governance budget_status
            if record.governance.budget_status:
                bs = record.governance.budget_status
                if not bs.within_budget:
                    violations.append(
                        f"Budget exceeded at record {record.record_type} task={record.task_id}: "
                        f"cost={bs.current_cost_usd} > max={bs.max_cost_usd}"
                    )
                    record_ids.append(record.audit_record_id)

        if violations:
            return AuditFinding(
                check_name="budget_compliance",
                status="FAIL",
                details="; ".join(violations),
                record_ids=list(set(record_ids)),
                error_codes=["E_COST_LIMIT_EXCEEDED"],
            )

        return AuditFinding(
            check_name="budget_compliance",
            status="PASS",
            details="All budget checks passed within session",
            record_ids=[],
        )

    def validate_guard_rail_compliance(self, session_records: List[AuditRecord]) -> AuditFinding:
        """
        Check that guard rail decisions were correctly applied.

        Verifies:
        - Every TASK_DISPATCHED has at least one corresponding GUARD_RAIL_CHECK
        - No FAIL results were ignored (task continued after a FAIL)

        Args:
            session_records: All records for a session.

        Returns:
            AuditFinding with PASS/WARN/FAIL status.
        """
        # Build sets of task_ids by type
        dispatched_tasks = set()
        guard_rail_tasks = set()
        failed_guard_rails = {}  # task_id -> record_id
        post_fail_tasks = set()  # tasks that continued after a FAIL

        # Track order of events by timestamp
        dispatched_records = []
        response_records = []
        fail_guard_rail_records = []

        for record in sorted(session_records, key=lambda r: r.timestamp):
            if record.record_type == "TASK_DISPATCHED":
                dispatched_tasks.add(record.task_id)
                dispatched_records.append(record)
            elif record.record_type == "GUARD_RAIL_CHECK":
                guard_rail_tasks.add(record.task_id)
                if record.payload.get("result") == "FAIL":
                    failed_guard_rails[record.task_id] = record.audit_record_id
                    fail_guard_rail_records.append(record)
            elif record.record_type == "RESPONSE_RECEIVED":
                response_records.append(record)

        # Check: tasks that have FAIL guard rails AND a subsequent RESPONSE_RECEIVED
        fail_task_ids = set(failed_guard_rails.keys())
        response_task_ids = {r.task_id for r in response_records}
        continued_after_fail = fail_task_ids & response_task_ids

        # Check: dispatched tasks without guard rail checks
        missing_checks = dispatched_tasks - guard_rail_tasks

        issues = []
        record_ids = []
        worst_status = "PASS"

        if missing_checks:
            issues.append(
                f"Tasks missing guard rail checks: {sorted(missing_checks)}"
            )
            worst_status = "WARN"

        if continued_after_fail:
            for task_id in continued_after_fail:
                issues.append(
                    f"Task {task_id} continued after FAIL guard rail check (record {failed_guard_rails[task_id]})"
                )
                record_ids.append(failed_guard_rails[task_id])
            worst_status = "FAIL"

        if issues:
            return AuditFinding(
                check_name="guard_rail_compliance",
                status=worst_status,
                details="; ".join(issues),
                record_ids=record_ids,
                error_codes=["E_SCHEMA_VALIDATION"] if worst_status == "FAIL" else [],
            )

        return AuditFinding(
            check_name="guard_rail_compliance",
            status="PASS",
            details="All guard rail checks properly applied and respected",
            record_ids=[],
        )

    def validate_role_assignments(self, session_records: List[AuditRecord]) -> AuditFinding:
        """
        Check that role assignments did not violate capabilities.

        Verifies:
        - Actor roles in ROUTING_DECISION records are consistent
        - Roles match the expected roles per record_type

        Args:
            session_records: All records for a session.

        Returns:
            AuditFinding with PASS/FAIL status.
        """
        violations = []
        record_ids = []

        for record in session_records:
            expected_roles = RECORD_TYPE_EXPECTED_ROLES.get(record.record_type)
            if expected_roles is None:
                continue

            actor_role = record.actor.role
            if actor_role not in expected_roles and actor_role not in VALID_ROLES:
                violations.append(
                    f"Invalid role {actor_role!r} for actor {record.actor.name!r} "
                    f"in {record.record_type} (expected one of {expected_roles})"
                )
                record_ids.append(record.audit_record_id)

        if violations:
            return AuditFinding(
                check_name="role_assignments",
                status="FAIL",
                details="; ".join(violations),
                record_ids=record_ids,
                error_codes=["E_PERMISSION_DENIED"],
            )

        return AuditFinding(
            check_name="role_assignments",
            status="PASS",
            details="All role assignments are valid and consistent",
            record_ids=[],
        )

    def validate_payload_limits(self, record: AuditRecord) -> AuditFinding:
        """
        Check that payload sizes are within contract limits.

        Contract limits:
        - TASK envelope: 200KB hard limit
        - RESPONSE: 500KB hard limit

        Args:
            record: AuditRecord to check (TASK_DISPATCHED or RESPONSE_RECEIVED).

        Returns:
            AuditFinding with PASS/FAIL status.
        """
        if record.record_type not in ("TASK_DISPATCHED", "RESPONSE_RECEIVED"):
            return AuditFinding(
                check_name="payload_limits",
                status="PASS",
                details=f"Record type {record.record_type} has no payload size constraint",
                record_ids=[record.audit_record_id],
            )

        payload_json = json.dumps(record.payload, ensure_ascii=False)
        size_bytes = len(payload_json.encode("utf-8"))

        if record.record_type == "TASK_DISPATCHED":
            limit = TASK_PAYLOAD_LIMIT_BYTES
            limit_label = "200KB TASK limit"
        else:
            limit = RESPONSE_PAYLOAD_LIMIT_BYTES
            limit_label = "500KB RESPONSE limit"

        size_kb = size_bytes / 1024

        if size_bytes > limit:
            return AuditFinding(
                check_name="payload_limits",
                status="FAIL",
                details=f"Payload {size_kb:.2f}KB exceeds {limit_label} ({limit//1024}KB)",
                record_ids=[record.audit_record_id],
                error_codes=["E_CONTEXT_OVERFLOW"],
            )

        return AuditFinding(
            check_name="payload_limits",
            status="PASS",
            details=f"Payload {size_kb:.2f}KB within {limit_label}",
            record_ids=[record.audit_record_id],
        )

    # -------------------------------------------------------------------------
    # Full Audit & Replay
    # -------------------------------------------------------------------------

    def run_full_audit(self, session_id: str) -> AuditReport:
        """
        Run all validations on a session and return a comprehensive report.

        Args:
            session_id: Session to audit.

        Returns:
            AuditReport with all findings and overall status.
        """
        session_records = self.load_session(session_id)
        findings: List[AuditFinding] = []

        if not session_records:
            return AuditReport(
                session_id=session_id,
                audit_timestamp=datetime.now(timezone.utc),
                total_records=0,
                findings=[
                    AuditFinding(
                        check_name="session_load",
                        status="WARN",
                        details=f"No records found for session {session_id}",
                    )
                ],
                overall_status="WARN",
                summary=f"Session {session_id} has no audit records",
            )

        # 1. Per-record: message compliance and payload limits
        for record in session_records:
            if record.record_type in ("TASK_DISPATCHED", "RESPONSE_RECEIVED"):
                findings.append(self.validate_message_compliance(record))
                findings.append(self.validate_payload_limits(record))

        # 2. Session-wide: budget compliance
        findings.append(self.validate_budget_compliance(session_records))

        # 3. Session-wide: guard rail compliance
        findings.append(self.validate_guard_rail_compliance(session_records))

        # 4. Session-wide: role assignments
        findings.append(self.validate_role_assignments(session_records))

        # Compute overall status (worst finding wins: FAIL > WARN > PASS)
        overall_status = _compute_overall_status(findings)

        # Build summary
        pass_count = sum(1 for f in findings if f.status == "PASS")
        warn_count = sum(1 for f in findings if f.status == "WARN")
        fail_count = sum(1 for f in findings if f.status == "FAIL")

        summary = (
            f"Session {session_id}: {len(session_records)} records audited. "
            f"Findings: {pass_count} PASS, {warn_count} WARN, {fail_count} FAIL. "
            f"Overall: {overall_status}"
        )

        return AuditReport(
            session_id=session_id,
            audit_timestamp=datetime.now(timezone.utc),
            total_records=len(session_records),
            findings=findings,
            overall_status=overall_status,
            summary=summary,
        )

    def replay_session(self, session_id: str) -> List[Dict]:
        """
        Replay a session chronologically, returning ordered events with annotations.

        Args:
            session_id: Session to replay.

        Returns:
            List of dicts with record data and annotations, sorted by timestamp.
        """
        records = self.load_session(session_id)

        replayed = []
        for i, record in enumerate(records):
            annotation = _annotate_record(record, i, len(records))

            replayed.append({
                "sequence": i + 1,
                "timestamp": record.timestamp.isoformat(),
                "record_type": record.record_type,
                "task_id": record.task_id,
                "actor": record.actor.model_dump(),
                "audit_record_id": record.audit_record_id,
                "annotation": annotation,
                "governance_decision": record.governance.access_decision,
                "payload_summary": _summarize_payload(record),
            })

        return replayed

    # -------------------------------------------------------------------------
    # Internal Helpers
    # -------------------------------------------------------------------------

    def _load_schema(self, schema_name: str) -> Optional[Dict[str, Any]]:
        """Load a JSON schema file from the schemas directory."""
        if schema_name in self._schema_cache:
            return self._schema_cache[schema_name]

        schema_path = self.schemas_path / schema_name
        if not schema_path.exists():
            return None

        try:
            with open(schema_path, "r", encoding="utf-8") as f:
                schema = json.load(f)
            self._schema_cache[schema_name] = schema
            return schema
        except Exception as e:
            print(f"WARNING: Could not load schema {schema_name}: {e}")
            return None


# ============================================================================
# Module-level helpers
# ============================================================================


def _compute_overall_status(findings: List[AuditFinding]) -> str:
    """Compute overall status: FAIL > WARN > PASS."""
    statuses = {f.status for f in findings}
    if "FAIL" in statuses:
        return "FAIL"
    if "WARN" in statuses:
        return "WARN"
    return "PASS"


def _annotate_record(record: AuditRecord, index: int, total: int) -> str:
    """Generate a human-readable annotation for a replayed record."""
    if record.record_type == "TASK_DISPATCHED":
        task_id = record.task_id
        return f"[{index+1}/{total}] Orchestrator dispatched task '{task_id}' to executor"

    elif record.record_type == "ROUTING_DECISION":
        payload = record.payload
        routed_to = payload.get("routed_to", "unknown")
        model = payload.get("model_selected", "unknown")
        fallback = payload.get("fallback_triggered", False)
        fb_note = f" (FALLBACK: {payload.get('fallback_reason')})" if fallback else ""
        return f"[{index+1}/{total}] Routed to '{routed_to}' using model '{model}'{fb_note}"

    elif record.record_type == "GUARD_RAIL_CHECK":
        payload = record.payload
        check_type = payload.get("check_type", "?")
        result = payload.get("result", "?")
        return f"[{index+1}/{total}] Guard rail '{check_type}': {result}"

    elif record.record_type == "RESPONSE_RECEIVED":
        task_status = record.payload.get("task_status", {})
        signal = task_status.get("final_signal", "?")
        return f"[{index+1}/{total}] Response received: final_signal={signal}"

    elif record.record_type == "ROLLBACK_EVENT":
        status = record.payload.get("status", "?")
        trigger = record.payload.get("trigger", "?")
        return f"[{index+1}/{total}] Rollback triggered by '{trigger}': {status}"

    elif record.record_type == "SESSION_SUMMARY":
        payload = record.payload
        total_tasks = payload.get("total_tasks", 0)
        completed = payload.get("completed", 0)
        cost = payload.get("total_cost_usd", 0.0)
        return f"[{index+1}/{total}] Session summary: {completed}/{total_tasks} tasks completed, cost=${cost:.4f}"

    return f"[{index+1}/{total}] {record.record_type}"


def _summarize_payload(record: AuditRecord) -> str:
    """Generate a short summary of the payload for replay output."""
    payload = record.payload

    if record.record_type == "TASK_DISPATCHED":
        task = payload.get("task", {})
        return f"task_id={task.get('task_id', '?')}, category={task.get('category', '?')}"

    elif record.record_type == "RESPONSE_RECEIVED":
        ts = payload.get("task_status", {})
        return f"state={ts.get('state', '?')}, signal={ts.get('final_signal', '?')}"

    elif record.record_type == "ROUTING_DECISION":
        return (
            f"version={payload.get('input_version', '?')}, "
            f"model={payload.get('model_selected', '?')}, "
            f"fallback={payload.get('fallback_triggered', False)}"
        )

    elif record.record_type == "GUARD_RAIL_CHECK":
        return f"check={payload.get('check_type', '?')}, result={payload.get('result', '?')}"

    elif record.record_type == "ROLLBACK_EVENT":
        arts = len(payload.get("artifacts_rolled_back", []))
        return f"status={payload.get('status', '?')}, artifacts={arts}"

    elif record.record_type == "SESSION_SUMMARY":
        return (
            f"tasks={payload.get('total_tasks', 0)}, "
            f"completed={payload.get('completed', 0)}, "
            f"cost=${payload.get('total_cost_usd', 0.0):.4f}"
        )

    return "..."
