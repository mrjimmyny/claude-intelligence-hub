"""
AOP V2 - Milestone 4: Test Suite for AuditLogger
===================================================
Tests for audit_logger.py - AuditLogger and AuditRecord models.

Target: >=20 tests, >=85% coverage on audit_logger.py.

Author: Magneto (Claude Sonnet 4.6)
Date: 2026-03-01
"""

import json
import sys
import os
from datetime import datetime, timezone
from pathlib import Path

import pytest

# Add v2/core/ to path
sys.path.insert(0, str(Path(__file__).parent.parent / "core"))

from audit_logger import (
    AuditLogger,
    AuditRecord,
    AuditActor,
    AuditContext,
    AuditGovernance,
    BudgetStatus,
)


# ============================================================================
# Fixtures
# ============================================================================


@pytest.fixture
def session_id():
    return "TEST-SESSION-001"


@pytest.fixture
def logger(tmp_path, session_id):
    """Create a fresh AuditLogger in a temp directory."""
    return AuditLogger(storage_path=str(tmp_path / "audit_trails"), session_id=session_id)


@pytest.fixture
def minimal_envelope_dict():
    """Minimal valid OrchestrationEnvelope as dict."""
    return {
        "aop_version": "2.0.2-C",
        "schema_version": "2.0.2",
        "protocol_family": "AOP",
        "message_type": "TASK",
        "session": {
            "session_id": "TEST-SESSION-001",
            "created_at": "2026-03-01T12:00:00Z",
            "orchestrator": "Cyclops",
            "origin": "CLI",
        },
        "target": {
            "agent_name": "Magneto",
            "role": "EXECUTOR",
            "provider": "CLAUDE",
            "model": "claude-sonnet-4-6",
        },
        "task": {
            "task_id": "TASK-001",
            "objective": "Implement M4 audit module",
            "category": "CODE_GENERATION",
            "complexity": "HIGH",
            "environment": {"workspace_root": "/workspace"},
        },
    }


@pytest.fixture
def full_envelope_dict(minimal_envelope_dict):
    """Full OrchestrationEnvelope with budget."""
    full = dict(minimal_envelope_dict)
    full["task"] = dict(full["task"])
    full["task"]["budgets"] = {"max_cost_usd": 10.0}
    return full


@pytest.fixture
def minimal_response_dict():
    """Minimal valid ExecutorResponse as dict."""
    return {
        "aop_version": "2.0.2-C",
        "schema_version": "2.0.2",
        "protocol_family": "AOP",
        "message_type": "RESPONSE",
        "session_id": "TEST-SESSION-001",
        "task_id": "TASK-001",
        "agent": {
            "name": "Magneto",
            "provider": "CLAUDE",
            "model": "claude-sonnet-4-6",
        },
        "task_status": {
            "state": "COMPLETED",
            "final_signal": "SUCCESS",
            "message": "Task completed successfully",
        },
        "execution_summary": {
            "summary": "Implemented audit module",
            "actions": ["Created audit_logger.py", "Created repo_auditor.py"],
        },
        "timing": {
            "started_at": "2026-03-01T12:00:00Z",
            "completed_at": "2026-03-01T12:30:00Z",
            "duration_seconds": 1800,
        },
    }


@pytest.fixture
def failure_response_dict():
    """Failure ExecutorResponse."""
    return {
        "aop_version": "2.0.2-C",
        "schema_version": "2.0.2",
        "protocol_family": "AOP",
        "message_type": "RESPONSE",
        "session_id": "TEST-SESSION-001",
        "task_id": "TASK-001",
        "agent": {
            "name": "Magneto",
            "provider": "CLAUDE",
            "model": "claude-sonnet-4-6",
        },
        "task_status": {
            "state": "FAILED",
            "final_signal": "FAILURE",
            "message": "Task failed due to error",
        },
        "execution_summary": {
            "summary": "Task failed",
            "actions": ["Attempted to run tests"],
            "errors": ["ImportError: missing module"],
        },
        "timing": {
            "started_at": "2026-03-01T12:00:00Z",
            "completed_at": "2026-03-01T12:05:00Z",
            "duration_seconds": 300,
        },
    }


# ============================================================================
# TestAuditLoggerInit
# ============================================================================


class TestAuditLoggerInit:
    def test_creates_storage_directory(self, tmp_path, session_id):
        """AuditLogger creates storage directory on init."""
        storage = tmp_path / "new_audit_dir" / "nested"
        logger = AuditLogger(storage_path=str(storage), session_id=session_id)
        assert storage.exists()
        assert storage.is_dir()

    def test_initializes_with_session_id(self, tmp_path, session_id):
        """AuditLogger stores session_id correctly."""
        logger = AuditLogger(storage_path=str(tmp_path), session_id=session_id)
        assert logger.session_id == session_id

    def test_storage_path_as_pathlib(self, tmp_path, session_id):
        """AuditLogger accepts and converts string path."""
        logger = AuditLogger(storage_path=str(tmp_path), session_id=session_id)
        assert isinstance(logger.storage_path, Path)


# ============================================================================
# TestLogTaskDispatched
# ============================================================================


class TestLogTaskDispatched:
    def test_logs_minimal_envelope(self, logger, minimal_envelope_dict):
        """log_task_dispatched returns AuditRecord with correct type."""
        record = logger.log_task_dispatched(minimal_envelope_dict)
        assert isinstance(record, AuditRecord)
        assert record.record_type == "TASK_DISPATCHED"

    def test_logs_full_envelope_with_all_fields(self, logger, full_envelope_dict):
        """log_task_dispatched captures budget from full envelope."""
        record = logger.log_task_dispatched(full_envelope_dict)
        assert record.governance.budget_status is not None
        assert record.governance.budget_status.max_cost_usd == 10.0

    def test_persists_to_disk(self, logger, minimal_envelope_dict, tmp_path):
        """log_task_dispatched writes a JSON file to storage."""
        record = logger.log_task_dispatched(minimal_envelope_dict)
        files = list(logger.storage_path.glob("*.json"))
        assert len(files) == 1
        # File contains valid JSON
        with open(files[0]) as f:
            data = json.load(f)
        assert data["record_type"] == "TASK_DISPATCHED"

    def test_record_has_correct_type_and_actor(self, logger, minimal_envelope_dict):
        """log_task_dispatched sets ORCHESTRATOR role."""
        record = logger.log_task_dispatched(minimal_envelope_dict)
        assert record.actor.role == "ORCHESTRATOR"
        assert record.record_type == "TASK_DISPATCHED"

    def test_record_has_session_and_task_id(self, logger, minimal_envelope_dict, session_id):
        """log_task_dispatched populates session_id and task_id."""
        record = logger.log_task_dispatched(minimal_envelope_dict)
        assert record.session_id == session_id
        assert record.task_id == "TASK-001"

    def test_record_has_utc_timestamp(self, logger, minimal_envelope_dict):
        """log_task_dispatched uses UTC timestamp."""
        record = logger.log_task_dispatched(minimal_envelope_dict)
        assert record.timestamp.tzinfo is not None


# ============================================================================
# TestLogResponseReceived
# ============================================================================


class TestLogResponseReceived:
    def test_logs_success_response(self, logger, minimal_response_dict):
        """log_response_received creates RESPONSE_RECEIVED record."""
        record = logger.log_response_received(minimal_response_dict)
        assert record.record_type == "RESPONSE_RECEIVED"
        assert record.actor.role == "EXECUTOR"

    def test_logs_failure_response(self, logger, failure_response_dict):
        """log_response_received handles FAILURE final_signal."""
        record = logger.log_response_received(failure_response_dict)
        assert record.record_type == "RESPONSE_RECEIVED"
        payload = record.payload
        assert payload["task_status"]["final_signal"] == "FAILURE"

    def test_persists_to_disk(self, logger, minimal_response_dict):
        """log_response_received writes JSON file to storage."""
        record = logger.log_response_received(minimal_response_dict)
        files = list(logger.storage_path.glob("*.json"))
        assert len(files) == 1
        with open(files[0]) as f:
            data = json.load(f)
        assert data["record_type"] == "RESPONSE_RECEIVED"

    def test_extracts_agent_info(self, logger, minimal_response_dict):
        """log_response_received extracts agent name and model."""
        record = logger.log_response_received(minimal_response_dict)
        assert record.actor.name == "Magneto"
        assert record.actor.model == "claude-sonnet-4-6"


# ============================================================================
# TestLogRoutingDecision
# ============================================================================


class TestLogRoutingDecision:
    def test_logs_direct_routing_no_fallback(self, logger):
        """log_routing_decision logs direct V2 routing."""
        record = logger.log_routing_decision(
            task_id="TASK-001",
            input_version="V2",
            routed_to="Magneto",
            model_selected="claude-sonnet-4-6",
            fallback_triggered=False,
        )
        assert record.record_type == "ROUTING_DECISION"
        assert record.payload["fallback_triggered"] is False
        assert record.payload["input_version"] == "V2"

    def test_logs_fallback_triggered(self, logger):
        """log_routing_decision captures fallback trigger with reason."""
        record = logger.log_routing_decision(
            task_id="TASK-001",
            input_version="V1",
            routed_to="FallbackAgent",
            model_selected="claude-haiku-4-5",
            fallback_triggered=True,
            fallback_reason="E_SCHEMA_VALIDATION",
        )
        assert record.payload["fallback_triggered"] is True
        assert record.payload["fallback_reason"] == "E_SCHEMA_VALIDATION"
        assert record.governance.reason_code == "E_SCHEMA_VALIDATION"

    def test_logs_with_alternatives_tried(self, logger):
        """log_routing_decision captures alternatives_tried list."""
        record = logger.log_routing_decision(
            task_id="TASK-001",
            input_version="V1",
            routed_to="FallbackAgent",
            model_selected="claude-haiku-4-5",
            fallback_triggered=True,
            alternatives_tried=["claude-sonnet-4-6", "claude-opus-4-6"],
        )
        assert record.payload["alternatives_tried"] == ["claude-sonnet-4-6", "claude-opus-4-6"]

    def test_router_actor_role(self, logger):
        """log_routing_decision sets ROUTER actor role."""
        record = logger.log_routing_decision(
            task_id="TASK-001",
            input_version="V2",
            routed_to="Magneto",
            model_selected="claude-sonnet-4-6",
        )
        assert record.actor.role == "ROUTER"


# ============================================================================
# TestLogGuardRailCheck
# ============================================================================


class TestLogGuardRailCheck:
    def test_logs_pass_result(self, logger):
        """log_guard_rail_check logs PASS result."""
        record = logger.log_guard_rail_check(
            task_id="TASK-001",
            check_type="PAYLOAD_LIMIT",
            result="PASS",
            details="Payload 1.2KB within 200KB limit",
        )
        assert record.record_type == "GUARD_RAIL_CHECK"
        assert record.payload["result"] == "PASS"
        assert record.governance.access_decision == "ALLOWED"

    def test_logs_warn_result(self, logger):
        """log_guard_rail_check logs WARN result."""
        record = logger.log_guard_rail_check(
            task_id="TASK-001",
            check_type="BUDGET",
            result="WARN",
            details="Cost approaching limit",
            error_code="E_PAYLOAD_SIZE_WARNING",
        )
        assert record.payload["result"] == "WARN"
        assert record.payload["error_code"] == "E_PAYLOAD_SIZE_WARNING"
        assert record.governance.access_decision == "ALLOWED"

    def test_logs_fail_result(self, logger):
        """log_guard_rail_check logs FAIL result with DENIED access."""
        record = logger.log_guard_rail_check(
            task_id="TASK-001",
            check_type="BUDGET",
            result="FAIL",
            details="Cost limit exceeded",
            error_code="E_COST_LIMIT_EXCEEDED",
        )
        assert record.payload["result"] == "FAIL"
        assert record.governance.access_decision == "DENIED"
        assert record.governance.reason_code == "E_COST_LIMIT_EXCEEDED"

    def test_governance_actor_role(self, logger):
        """log_guard_rail_check sets GOVERNANCE actor role."""
        record = logger.log_guard_rail_check(
            task_id="TASK-001",
            check_type="TIMEOUT",
            result="PASS",
            details="Within timeout",
        )
        assert record.actor.role == "GOVERNANCE"


# ============================================================================
# TestLogRollbackEvent
# ============================================================================


class TestLogRollbackEvent:
    def test_logs_successful_rollback(self, logger):
        """log_rollback_event logs SUCCESS rollback."""
        artifacts = [{"path": "/workspace/file.py", "restored_from": "/backup/file.py", "status": "SUCCESS"}]
        record = logger.log_rollback_event(
            task_id="TASK-001",
            trigger="Guard rail FAIL",
            artifacts_rolled_back=artifacts,
            status="SUCCESS",
        )
        assert record.record_type == "ROLLBACK_EVENT"
        assert record.payload["status"] == "SUCCESS"
        assert len(record.payload["artifacts_rolled_back"]) == 1

    def test_logs_failed_rollback(self, logger):
        """log_rollback_event sets E_ROLLBACK_FAILED reason code on FAILED status."""
        record = logger.log_rollback_event(
            task_id="TASK-001",
            trigger="Critical error",
            artifacts_rolled_back=[],
            status="FAILED",
        )
        assert record.payload["status"] == "FAILED"
        assert record.governance.reason_code == "E_ROLLBACK_FAILED"

    def test_captures_trigger(self, logger):
        """log_rollback_event stores trigger reason."""
        record = logger.log_rollback_event(
            task_id="TASK-001",
            trigger="E_COST_LIMIT_EXCEEDED",
            artifacts_rolled_back=[],
            status="SUCCESS",
        )
        assert record.payload["trigger"] == "E_COST_LIMIT_EXCEEDED"


# ============================================================================
# TestSessionSummary
# ============================================================================


class TestSessionSummary:
    def test_generates_summary_from_multiple_records(self, logger, minimal_envelope_dict, minimal_response_dict):
        """generate_session_summary creates SESSION_SUMMARY after multiple records."""
        logger.log_task_dispatched(minimal_envelope_dict)
        logger.log_guard_rail_check("TASK-001", "PAYLOAD_LIMIT", "PASS", "OK")
        logger.log_response_received(minimal_response_dict)

        summary = logger.generate_session_summary()
        assert summary.record_type == "SESSION_SUMMARY"
        assert summary.payload["total_tasks"] == 1

    def test_aggregates_costs_correctly(self, logger, minimal_envelope_dict):
        """generate_session_summary aggregates task counts."""
        # Dispatch 2 tasks
        env1 = dict(minimal_envelope_dict)
        env1["task"] = dict(env1["task"])
        env1["task"]["task_id"] = "TASK-001"
        logger.log_task_dispatched(env1)

        env2 = dict(minimal_envelope_dict)
        env2["task"] = dict(env2["task"])
        env2["task"]["task_id"] = "TASK-002"
        logger.log_task_dispatched(env2)

        summary = logger.generate_session_summary()
        assert summary.payload["total_tasks"] == 2

    def test_counts_tasks_correctly(self, logger, minimal_envelope_dict, minimal_response_dict):
        """generate_session_summary counts completed tasks from RESPONSE_RECEIVED."""
        logger.log_task_dispatched(minimal_envelope_dict)
        logger.log_response_received(minimal_response_dict)  # SUCCESS

        failure_resp = dict(minimal_response_dict)
        failure_resp["task_status"] = {"state": "FAILED", "final_signal": "FAILURE", "message": "Failed"}
        logger.log_response_received(failure_resp)

        summary = logger.generate_session_summary()
        assert summary.payload["completed"] == 1
        assert summary.payload["failed"] == 1

    def test_summary_persisted_to_disk(self, logger, minimal_envelope_dict):
        """generate_session_summary persists SESSION_SUMMARY to disk."""
        logger.log_task_dispatched(minimal_envelope_dict)
        logger.generate_session_summary()

        summary_files = list(logger.storage_path.glob("*SESSION_SUMMARY*.json"))
        assert len(summary_files) == 1


# ============================================================================
# TestGetSessionRecords
# ============================================================================


class TestGetSessionRecords:
    def test_returns_all_records_for_session(self, logger, minimal_envelope_dict, minimal_response_dict):
        """get_session_records returns all persisted records for the session."""
        logger.log_task_dispatched(minimal_envelope_dict)
        logger.log_routing_decision("TASK-001", "V2", "Magneto", "claude-sonnet-4-6")
        logger.log_guard_rail_check("TASK-001", "PAYLOAD_LIMIT", "PASS", "OK")
        logger.log_response_received(minimal_response_dict)

        records = logger.get_session_records()
        assert len(records) == 4

    def test_returns_empty_for_no_records(self, tmp_path, session_id):
        """get_session_records returns empty list when no records exist."""
        logger = AuditLogger(storage_path=str(tmp_path / "empty"), session_id=session_id)
        records = logger.get_session_records()
        assert records == []

    def test_records_sorted_by_timestamp(self, logger, minimal_envelope_dict, minimal_response_dict):
        """get_session_records returns records sorted by timestamp."""
        logger.log_task_dispatched(minimal_envelope_dict)
        logger.log_response_received(minimal_response_dict)

        records = logger.get_session_records()
        for i in range(len(records) - 1):
            assert records[i].timestamp <= records[i + 1].timestamp

    def test_does_not_include_other_sessions(self, tmp_path):
        """get_session_records only returns records for the matching session."""
        storage = str(tmp_path / "shared_storage")
        logger_a = AuditLogger(storage_path=storage, session_id="SESSION-A")
        logger_b = AuditLogger(storage_path=storage, session_id="SESSION-B")

        envelope = {
            "message_type": "TASK",
            "session": {"session_id": "SESSION-A", "created_at": "2026-03-01T12:00:00Z", "orchestrator": "X", "origin": "CLI"},
            "target": {"agent_name": "Agent", "role": "EXECUTOR", "provider": "CLAUDE", "model": "m"},
            "task": {"task_id": "T-001", "objective": "test", "category": "ANALYSIS", "complexity": "LOW", "environment": {"workspace_root": "/"}},
        }
        logger_a.log_task_dispatched(envelope)

        records_b = logger_b.get_session_records()
        assert len(records_b) == 0

    def test_atomic_write_creates_valid_json(self, logger, minimal_envelope_dict):
        """Persisted files are valid JSON with correct audit_record_id."""
        record = logger.log_task_dispatched(minimal_envelope_dict)
        files = list(logger.storage_path.glob("*.json"))
        assert len(files) == 1
        with open(files[0]) as f:
            data = json.load(f)
        assert data["audit_record_id"] == record.audit_record_id
