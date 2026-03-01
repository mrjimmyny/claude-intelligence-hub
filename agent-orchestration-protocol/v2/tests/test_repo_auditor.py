"""
AOP V2 - Milestone 4: Test Suite for RepoAuditor
==================================================
Tests for repo_auditor.py - RepoAuditor, AuditFinding, AuditReport.

Target: >=20 tests, >=85% coverage on repo_auditor.py.

Author: Magneto (Claude Sonnet 4.6)
Date: 2026-03-01
"""

import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4

import pytest

# Add v2/core/ to path
sys.path.insert(0, str(Path(__file__).parent.parent / "core"))

from audit_logger import (
    AuditActor,
    AuditContext,
    AuditGovernance,
    AuditLogger,
    AuditRecord,
    BudgetStatus,
)
from repo_auditor import AuditFinding, AuditReport, RepoAuditor


# ============================================================================
# Helpers
# ============================================================================


def make_record(
    session_id: str = "TEST-SESSION-001",
    task_id: str = "TASK-001",
    record_type: str = "TASK_DISPATCHED",
    actor_role: str = "ORCHESTRATOR",
    actor_name: str = "Orchestrator",
    payload: dict = None,
    access_decision: str = "ALLOWED",
    reason_code: str = None,
    budget_status: BudgetStatus = None,
    guard_rails_applied: list = None,
    timestamp: datetime = None,
) -> AuditRecord:
    """Factory for AuditRecord in tests."""
    if payload is None:
        payload = {}
    return AuditRecord(
        audit_record_id=str(uuid4()),
        audit_version="1.0.0",
        timestamp=timestamp or datetime.now(timezone.utc),
        session_id=session_id,
        task_id=task_id,
        record_type=record_type,
        actor=AuditActor(name=actor_name, role=actor_role),
        payload=payload,
        context=AuditContext(
            parent_task_id=None,
            attempt=1,
            correlation_id=session_id,
        ),
        governance=AuditGovernance(
            guard_rails_applied=guard_rails_applied or [],
            budget_status=budget_status,
            access_decision=access_decision,
            reason_code=reason_code,
        ),
    )


def make_task_dispatched_payload(task_id: str = "TASK-001") -> dict:
    return {
        "message_type": "TASK",
        "session": {"session_id": "S-001", "created_at": "2026-03-01T12:00:00Z", "orchestrator": "X", "origin": "CLI"},
        "target": {"agent_name": "Agent", "role": "EXECUTOR", "provider": "CLAUDE", "model": "m"},
        "task": {"task_id": task_id, "objective": "test", "category": "ANALYSIS", "complexity": "LOW", "environment": {"workspace_root": "/"}},
    }


def make_response_received_payload(final_signal: str = "SUCCESS") -> dict:
    return {
        "message_type": "RESPONSE",
        "session_id": "S-001",
        "task_id": "TASK-001",
        "agent": {"name": "Magneto", "provider": "CLAUDE", "model": "claude-sonnet-4-6"},
        "task_status": {"state": "COMPLETED", "final_signal": final_signal, "message": "Done"},
        "execution_summary": {"summary": "Completed", "actions": ["done"]},
        "timing": {"started_at": "2026-03-01T12:00:00Z", "completed_at": "2026-03-01T12:05:00Z", "duration_seconds": 300},
    }


def persist_records(records: list, storage_path: Path):
    """Persist a list of AuditRecord objects to disk."""
    import os
    import tempfile
    storage_path.mkdir(parents=True, exist_ok=True)
    for record in records:
        ts_compact = record.timestamp.strftime("%Y%m%dT%H%M%SZ")
        filename = f"{record.session_id}_{record.task_id}_{record.record_type}_{ts_compact}_{record.audit_record_id[:8]}.json"
        file_path = storage_path / filename
        data = record.model_dump(mode="json")
        content = json.dumps(data, indent=2)
        tmp_fd, tmp_path = tempfile.mkstemp(dir=str(storage_path), prefix=".tmp_", suffix=".json")
        with os.fdopen(tmp_fd, "w", encoding="utf-8") as f:
            f.write(content)
        os.replace(tmp_path, str(file_path))


# ============================================================================
# Fixtures
# ============================================================================


@pytest.fixture
def session_id():
    return "TEST-SESSION-001"


@pytest.fixture
def auditor(tmp_path):
    schemas_path = Path(__file__).parent.parent.parent / "schemas"
    return RepoAuditor(
        audit_trails_path=str(tmp_path / "audit_trails"),
        schemas_path=str(schemas_path),
    )


@pytest.fixture
def auditor_with_records(tmp_path, session_id):
    """Auditor with a full simulated session."""
    schemas_path = Path(__file__).parent.parent.parent / "schemas"
    storage = tmp_path / "audit_trails"

    records = [
        make_record(
            session_id=session_id,
            task_id="TASK-001",
            record_type="TASK_DISPATCHED",
            actor_role="ORCHESTRATOR",
            payload=make_task_dispatched_payload("TASK-001"),
            guard_rails_applied=["PAYLOAD_LIMIT"],
        ),
        make_record(
            session_id=session_id,
            task_id="TASK-001",
            record_type="ROUTING_DECISION",
            actor_role="ROUTER",
            actor_name="VersionRouter",
            payload={"input_version": "V2", "routed_to": "Magneto", "model_selected": "claude-sonnet-4-6", "fallback_triggered": False, "fallback_reason": None, "alternatives_tried": []},
        ),
        make_record(
            session_id=session_id,
            task_id="TASK-001",
            record_type="GUARD_RAIL_CHECK",
            actor_role="GOVERNANCE",
            actor_name="GuardRailEngine",
            payload={"check_type": "PAYLOAD_LIMIT", "result": "PASS", "details": "OK", "error_code": None},
            guard_rails_applied=["PAYLOAD_LIMIT"],
        ),
        make_record(
            session_id=session_id,
            task_id="TASK-001",
            record_type="GUARD_RAIL_CHECK",
            actor_role="GOVERNANCE",
            actor_name="GuardRailEngine",
            payload={"check_type": "BUDGET", "result": "PASS", "details": "Within budget", "error_code": None},
            guard_rails_applied=["BUDGET"],
        ),
        make_record(
            session_id=session_id,
            task_id="TASK-001",
            record_type="RESPONSE_RECEIVED",
            actor_role="EXECUTOR",
            actor_name="Magneto",
            payload=make_response_received_payload("SUCCESS"),
            guard_rails_applied=["FINAL_SIGNAL", "MINIMAL_REPORT"],
        ),
    ]

    persist_records(records, storage)
    return RepoAuditor(audit_trails_path=str(storage), schemas_path=str(schemas_path))


# ============================================================================
# TestRepoAuditorInit
# ============================================================================


class TestRepoAuditorInit:
    def test_initializes_with_paths(self, tmp_path):
        """RepoAuditor initializes with audit_trails and schemas paths."""
        auditor = RepoAuditor(
            audit_trails_path=str(tmp_path / "trails"),
            schemas_path=str(tmp_path / "schemas"),
        )
        assert auditor.audit_trails_path == tmp_path / "trails"
        assert auditor.schemas_path == tmp_path / "schemas"


# ============================================================================
# TestLoadSession
# ============================================================================


class TestLoadSession:
    def test_loads_all_records_for_session(self, auditor_with_records, session_id):
        """load_session returns all records for the session."""
        records = auditor_with_records.load_session(session_id)
        assert len(records) == 5

    def test_returns_empty_for_unknown_session(self, auditor):
        """load_session returns empty list for unknown session."""
        records = auditor.load_session("NONEXISTENT-SESSION")
        assert records == []

    def test_records_sorted_by_timestamp(self, auditor_with_records, session_id):
        """load_session returns records sorted by timestamp."""
        records = auditor_with_records.load_session(session_id)
        for i in range(len(records) - 1):
            assert records[i].timestamp <= records[i + 1].timestamp


# ============================================================================
# TestValidateMessageCompliance
# ============================================================================


class TestValidateMessageCompliance:
    def test_valid_task_envelope_passes(self, auditor):
        """validate_message_compliance PASS for valid TASK_DISPATCHED."""
        record = make_record(
            record_type="TASK_DISPATCHED",
            actor_role="ORCHESTRATOR",
            payload=make_task_dispatched_payload(),
        )
        finding = auditor.validate_message_compliance(record)
        assert finding.status == "PASS"

    def test_invalid_task_envelope_fails(self, auditor):
        """validate_message_compliance FAIL for wrong message_type."""
        record = make_record(
            record_type="TASK_DISPATCHED",
            actor_role="ORCHESTRATOR",
            payload={"message_type": "RESPONSE"},  # Wrong type
        )
        finding = auditor.validate_message_compliance(record)
        assert finding.status == "FAIL"
        assert "E_SCHEMA_VALIDATION" in finding.error_codes

    def test_valid_response_passes(self, auditor):
        """validate_message_compliance PASS for valid RESPONSE_RECEIVED."""
        record = make_record(
            record_type="RESPONSE_RECEIVED",
            actor_role="EXECUTOR",
            payload=make_response_received_payload(),
        )
        finding = auditor.validate_message_compliance(record)
        assert finding.status == "PASS"

    def test_invalid_response_fails(self, auditor):
        """validate_message_compliance FAIL when required fields missing."""
        record = make_record(
            record_type="RESPONSE_RECEIVED",
            actor_role="EXECUTOR",
            payload={"message_type": "RESPONSE"},  # Missing session_id, task_id, etc.
        )
        finding = auditor.validate_message_compliance(record)
        assert finding.status == "FAIL"

    def test_non_message_record_passes_trivially(self, auditor):
        """Non-message records (ROUTING_DECISION etc.) pass compliance trivially."""
        record = make_record(record_type="ROUTING_DECISION", actor_role="ROUTER", payload={})
        finding = auditor.validate_message_compliance(record)
        assert finding.status == "PASS"


# ============================================================================
# TestValidateBudgetCompliance
# ============================================================================


class TestValidateBudgetCompliance:
    def test_within_budget_passes(self, auditor):
        """validate_budget_compliance PASS when all budget checks pass."""
        records = [
            make_record(
                record_type="GUARD_RAIL_CHECK",
                actor_role="GOVERNANCE",
                payload={"check_type": "BUDGET", "result": "PASS", "details": "OK", "error_code": None},
                budget_status=BudgetStatus(max_cost_usd=10.0, current_cost_usd=1.0, within_budget=True),
            )
        ]
        finding = auditor.validate_budget_compliance(records)
        assert finding.status == "PASS"

    def test_over_budget_fails(self, auditor):
        """validate_budget_compliance FAIL when budget check fails."""
        records = [
            make_record(
                record_type="GUARD_RAIL_CHECK",
                actor_role="GOVERNANCE",
                payload={"check_type": "BUDGET", "result": "FAIL", "details": "Over budget", "error_code": "E_COST_LIMIT_EXCEEDED"},
            )
        ]
        finding = auditor.validate_budget_compliance(records)
        assert finding.status == "FAIL"
        assert "E_COST_LIMIT_EXCEEDED" in finding.error_codes

    def test_no_budget_set_passes(self, auditor):
        """validate_budget_compliance PASS when no budget checks exist."""
        records = [
            make_record(record_type="TASK_DISPATCHED", actor_role="ORCHESTRATOR", payload=make_task_dispatched_payload()),
        ]
        finding = auditor.validate_budget_compliance(records)
        assert finding.status == "PASS"

    def test_exceeded_budget_status_fails(self, auditor):
        """validate_budget_compliance FAIL when governance.budget_status.within_budget=False."""
        records = [
            make_record(
                record_type="RESPONSE_RECEIVED",
                actor_role="EXECUTOR",
                payload=make_response_received_payload(),
                budget_status=BudgetStatus(max_cost_usd=1.0, current_cost_usd=5.0, within_budget=False),
            )
        ]
        finding = auditor.validate_budget_compliance(records)
        assert finding.status == "FAIL"


# ============================================================================
# TestValidateGuardRailCompliance
# ============================================================================


class TestValidateGuardRailCompliance:
    def test_all_checks_pass(self, auditor):
        """validate_guard_rail_compliance PASS when all checks are present and pass."""
        records = [
            make_record(record_type="TASK_DISPATCHED", actor_role="ORCHESTRATOR", task_id="T-1", payload=make_task_dispatched_payload("T-1")),
            make_record(record_type="GUARD_RAIL_CHECK", actor_role="GOVERNANCE", task_id="T-1", payload={"check_type": "PAYLOAD_LIMIT", "result": "PASS", "details": "OK", "error_code": None}),
        ]
        finding = auditor.validate_guard_rail_compliance(records)
        assert finding.status == "PASS"

    def test_missing_guard_rail_check_warns(self, auditor):
        """validate_guard_rail_compliance WARN when task has no guard rail checks."""
        records = [
            make_record(record_type="TASK_DISPATCHED", actor_role="ORCHESTRATOR", task_id="T-1", payload=make_task_dispatched_payload("T-1")),
            # No GUARD_RAIL_CHECK for T-1
        ]
        finding = auditor.validate_guard_rail_compliance(records)
        assert finding.status == "WARN"

    def test_ignored_fail_detected(self, auditor):
        """validate_guard_rail_compliance FAIL when task continues after FAIL check."""
        records = [
            make_record(record_type="TASK_DISPATCHED", actor_role="ORCHESTRATOR", task_id="T-1", payload=make_task_dispatched_payload("T-1")),
            make_record(record_type="GUARD_RAIL_CHECK", actor_role="GOVERNANCE", task_id="T-1", payload={"check_type": "BUDGET", "result": "FAIL", "details": "Over budget", "error_code": "E_COST_LIMIT_EXCEEDED"}),
            make_record(record_type="RESPONSE_RECEIVED", actor_role="EXECUTOR", task_id="T-1", payload=make_response_received_payload()),  # Continued despite FAIL!
        ]
        finding = auditor.validate_guard_rail_compliance(records)
        assert finding.status == "FAIL"


# ============================================================================
# TestValidateRoleAssignments
# ============================================================================


class TestValidateRoleAssignments:
    def test_valid_assignments_pass(self, auditor):
        """validate_role_assignments PASS for all standard role assignments."""
        records = [
            make_record(record_type="TASK_DISPATCHED", actor_role="ORCHESTRATOR"),
            make_record(record_type="ROUTING_DECISION", actor_role="ROUTER"),
            make_record(record_type="GUARD_RAIL_CHECK", actor_role="GOVERNANCE"),
            make_record(record_type="RESPONSE_RECEIVED", actor_role="EXECUTOR"),
            make_record(record_type="SESSION_SUMMARY", actor_role="ORCHESTRATOR"),
        ]
        finding = auditor.validate_role_assignments(records)
        assert finding.status == "PASS"

    def test_invalid_role_detected(self, auditor):
        """validate_role_assignments FAIL for completely invalid role string."""
        records = [
            make_record(record_type="TASK_DISPATCHED", actor_role="UNKNOWN_INVALID_ROLE_XYZ"),
        ]
        finding = auditor.validate_role_assignments(records)
        assert finding.status == "FAIL"


# ============================================================================
# TestValidatePayloadLimits
# ============================================================================


class TestValidatePayloadLimits:
    def test_within_limits_passes(self, auditor):
        """validate_payload_limits PASS for small payloads."""
        record = make_record(
            record_type="TASK_DISPATCHED",
            actor_role="ORCHESTRATOR",
            payload=make_task_dispatched_payload(),
        )
        finding = auditor.validate_payload_limits(record)
        assert finding.status == "PASS"

    def test_exceeds_hard_limit_fails(self, auditor):
        """validate_payload_limits FAIL for payload exceeding 200KB."""
        # Create a payload that exceeds 200KB
        large_payload = make_task_dispatched_payload()
        large_payload["_large_data"] = "X" * (210 * 1024)

        record = make_record(
            record_type="TASK_DISPATCHED",
            actor_role="ORCHESTRATOR",
            payload=large_payload,
        )
        finding = auditor.validate_payload_limits(record)
        assert finding.status == "FAIL"
        assert "E_CONTEXT_OVERFLOW" in finding.error_codes

    def test_non_message_record_passes_trivially(self, auditor):
        """validate_payload_limits PASS for non-message records."""
        record = make_record(record_type="ROUTING_DECISION", actor_role="ROUTER", payload={})
        finding = auditor.validate_payload_limits(record)
        assert finding.status == "PASS"

    def test_response_within_500kb_passes(self, auditor):
        """validate_payload_limits PASS for response within 500KB."""
        record = make_record(
            record_type="RESPONSE_RECEIVED",
            actor_role="EXECUTOR",
            payload=make_response_received_payload(),
        )
        finding = auditor.validate_payload_limits(record)
        assert finding.status == "PASS"


# ============================================================================
# TestRunFullAudit
# ============================================================================


class TestRunFullAudit:
    def test_full_audit_all_pass(self, auditor_with_records, session_id):
        """run_full_audit returns PASS overall when session is clean."""
        report = auditor_with_records.run_full_audit(session_id)
        assert isinstance(report, AuditReport)
        assert report.overall_status == "PASS"
        assert report.total_records == 5

    def test_full_audit_with_failures(self, tmp_path):
        """run_full_audit detects FAIL when budget is violated."""
        schemas_path = Path(__file__).parent.parent.parent / "schemas"
        storage = tmp_path / "audit_trails_fail"

        session_id = "FAIL-SESSION"
        records = [
            make_record(
                session_id=session_id,
                task_id="TASK-001",
                record_type="TASK_DISPATCHED",
                actor_role="ORCHESTRATOR",
                payload=make_task_dispatched_payload("TASK-001"),
            ),
            make_record(
                session_id=session_id,
                task_id="TASK-001",
                record_type="GUARD_RAIL_CHECK",
                actor_role="GOVERNANCE",
                payload={"check_type": "BUDGET", "result": "FAIL", "details": "Over limit", "error_code": "E_COST_LIMIT_EXCEEDED"},
            ),
            make_record(
                session_id=session_id,
                task_id="TASK-001",
                record_type="RESPONSE_RECEIVED",
                actor_role="EXECUTOR",
                payload=make_response_received_payload("SUCCESS"),
            ),
        ]
        persist_records(records, storage)

        auditor = RepoAuditor(audit_trails_path=str(storage), schemas_path=str(schemas_path))
        report = auditor.run_full_audit(session_id)
        assert report.overall_status == "FAIL"

    def test_overall_status_worst_finding_wins(self, auditor):
        """run_full_audit: FAIL > WARN > PASS in overall_status."""
        # Inject records directly that will produce warnings
        from repo_auditor import _compute_overall_status

        findings = [
            AuditFinding(check_name="a", status="PASS", details="ok"),
            AuditFinding(check_name="b", status="WARN", details="warning"),
            AuditFinding(check_name="c", status="PASS", details="ok"),
        ]
        assert _compute_overall_status(findings) == "WARN"

        findings_with_fail = findings + [
            AuditFinding(check_name="d", status="FAIL", details="fail")
        ]
        assert _compute_overall_status(findings_with_fail) == "FAIL"

    def test_full_audit_empty_session_warns(self, auditor):
        """run_full_audit WARN for session with no records."""
        report = auditor.run_full_audit("EMPTY-SESSION")
        assert report.overall_status == "WARN"
        assert report.total_records == 0


# ============================================================================
# TestReplaySession
# ============================================================================


class TestReplaySession:
    def test_replays_in_chronological_order(self, auditor_with_records, session_id):
        """replay_session returns events in chronological order."""
        replayed = auditor_with_records.replay_session(session_id)
        assert len(replayed) == 5
        # Check sequence numbers are increasing
        sequences = [e["sequence"] for e in replayed]
        assert sequences == list(range(1, 6))

    def test_annotates_events(self, auditor_with_records, session_id):
        """replay_session provides non-empty annotations for each event."""
        replayed = auditor_with_records.replay_session(session_id)
        for event in replayed:
            assert "annotation" in event
            assert len(event["annotation"]) > 0
            assert "record_type" in event
            assert "task_id" in event

    def test_replay_empty_session(self, auditor):
        """replay_session returns empty list for unknown session."""
        replayed = auditor.replay_session("NONEXISTENT")
        assert replayed == []
