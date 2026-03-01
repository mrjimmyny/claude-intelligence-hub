"""
AOP V2 - Milestone 4: E2E Integration Tests
=============================================
End-to-end tests for audit trail generation and RepoAuditor validation.

Author: Magneto (Claude Sonnet 4.6)
Date: 2026-03-01
"""

import sys
from pathlib import Path

import pytest

# Add v2/core/ to path
sys.path.insert(0, str(Path(__file__).parent.parent / "core"))

from audit_logger import AuditLogger
from repo_auditor import RepoAuditor


# ============================================================================
# Fixtures
# ============================================================================


@pytest.fixture
def schemas_path():
    return str(Path(__file__).parent.parent / "schemas")


@pytest.fixture
def minimal_envelope():
    return {
        "aop_version": "2.0.2-C",
        "schema_version": "2.0.2",
        "protocol_family": "AOP",
        "message_type": "TASK",
        "session": {
            "session_id": "E2E-SESSION-001",
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
            "task_id": "E2E-TASK-001",
            "objective": "E2E test task",
            "category": "TESTING",
            "complexity": "LOW",
            "environment": {"workspace_root": "/workspace"},
            "budgets": {"max_cost_usd": 5.0},
        },
    }


@pytest.fixture
def success_response():
    return {
        "aop_version": "2.0.2-C",
        "schema_version": "2.0.2",
        "protocol_family": "AOP",
        "message_type": "RESPONSE",
        "session_id": "E2E-SESSION-001",
        "task_id": "E2E-TASK-001",
        "agent": {
            "name": "Magneto",
            "provider": "CLAUDE",
            "model": "claude-sonnet-4-6",
        },
        "task_status": {
            "state": "COMPLETED",
            "final_signal": "SUCCESS",
            "message": "E2E task completed",
        },
        "execution_summary": {
            "summary": "E2E test passed",
            "actions": ["Executed E2E flow", "Validated results"],
        },
        "timing": {
            "started_at": "2026-03-01T12:00:00Z",
            "completed_at": "2026-03-01T12:30:00Z",
            "duration_seconds": 1800,
        },
        "cost_tracking": {
            "actual_cost_usd": 0.25,
        },
    }


# ============================================================================
# TestM4Integration
# ============================================================================


class TestM4Integration:
    def test_e2e_audit_trail_generation(self, tmp_path, schemas_path, minimal_envelope, success_response):
        """
        E2E test: complete orchestration flow generates clean audit trail
        that RepoAuditor validates as PASS.

        Flow:
        1. Create AuditLogger
        2. log_task_dispatched
        3. log_routing_decision (direct, no fallback)
        4. log_guard_rail_check (PAYLOAD_LIMIT -> PASS)
        5. log_guard_rail_check (BUDGET -> PASS)
        6. log_response_received (SUCCESS)
        7. generate_session_summary
        8. Create RepoAuditor
        9. run_full_audit
        10. Assert overall_status == PASS
        11. Assert all findings are PASS
        """
        session_id = "E2E-SESSION-001"
        audit_path = str(tmp_path / "audit_trails")

        # Step 1: Create AuditLogger
        logger = AuditLogger(storage_path=audit_path, session_id=session_id)

        # Step 2: Log task dispatched
        r1 = logger.log_task_dispatched(minimal_envelope)
        assert r1.record_type == "TASK_DISPATCHED"

        # Step 3: Log routing decision (direct, no fallback)
        r2 = logger.log_routing_decision(
            task_id="E2E-TASK-001",
            input_version="V2",
            routed_to="Magneto",
            model_selected="claude-sonnet-4-6",
            fallback_triggered=False,
        )
        assert r2.record_type == "ROUTING_DECISION"

        # Step 4: Guard rail check - PAYLOAD_LIMIT PASS
        r3 = logger.log_guard_rail_check(
            task_id="E2E-TASK-001",
            check_type="PAYLOAD_LIMIT",
            result="PASS",
            details="Payload 1.2KB within 200KB limit",
        )
        assert r3.payload["result"] == "PASS"

        # Step 5: Guard rail check - BUDGET PASS
        r4 = logger.log_guard_rail_check(
            task_id="E2E-TASK-001",
            check_type="BUDGET",
            result="PASS",
            details="Cost $0.25 within $5.00 budget",
        )
        assert r4.payload["result"] == "PASS"

        # Step 6: Log response received (SUCCESS)
        r5 = logger.log_response_received(success_response)
        assert r5.record_type == "RESPONSE_RECEIVED"

        # Step 7: Generate session summary
        summary = logger.generate_session_summary()
        assert summary.record_type == "SESSION_SUMMARY"
        assert summary.payload["total_tasks"] == 1

        # Verify all files are on disk
        import os
        audit_files = list(Path(audit_path).glob("E2E-SESSION-001_*.json"))
        assert len(audit_files) == 6  # 5 records + 1 summary

        # Step 8: Create RepoAuditor
        auditor = RepoAuditor(audit_trails_path=audit_path, schemas_path=schemas_path)

        # Step 9: Run full audit
        report = auditor.run_full_audit(session_id)

        # Step 10: Assert overall_status == PASS
        assert report.overall_status == "PASS", (
            f"Expected PASS but got {report.overall_status}. "
            f"Findings: {[(f.check_name, f.status, f.details) for f in report.findings if f.status != 'PASS']}"
        )
        assert report.total_records == 6

        # Step 11: Assert all findings are PASS
        failed_findings = [f for f in report.findings if f.status != "PASS"]
        assert len(failed_findings) == 0, (
            f"Non-PASS findings: {[(f.check_name, f.status, f.details) for f in failed_findings]}"
        )

    def test_e2e_audit_detects_violation(self, tmp_path, schemas_path, minimal_envelope):
        """
        E2E test: budget violation is detected by RepoAuditor.

        Flow:
        1. Simulate flow with budget violation FAIL check
        2. Assert RepoAuditor detects it
        3. Assert overall_status == FAIL
        """
        session_id = "VIOLATION-SESSION-001"
        audit_path = str(tmp_path / "audit_trails_violation")

        # Step 1: Create AuditLogger
        envelope = dict(minimal_envelope)
        envelope["session"] = dict(envelope["session"])
        envelope["session"]["session_id"] = session_id
        task = dict(envelope["task"])
        task["task_id"] = "VIOLATION-TASK-001"
        envelope["task"] = task

        logger = AuditLogger(storage_path=audit_path, session_id=session_id)

        # Log task dispatched
        logger.log_task_dispatched(envelope)

        # Guard rail FAIL (budget violation)
        logger.log_guard_rail_check(
            task_id="VIOLATION-TASK-001",
            check_type="BUDGET",
            result="FAIL",
            details="Cost $6.50 exceeds $5.00 budget",
            error_code="E_COST_LIMIT_EXCEEDED",
        )

        # Task continued despite FAIL (violation!)
        violation_response = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "RESPONSE",
            "session_id": session_id,
            "task_id": "VIOLATION-TASK-001",
            "agent": {"name": "Magneto", "provider": "CLAUDE", "model": "claude-sonnet-4-6"},
            "task_status": {"state": "COMPLETED", "final_signal": "SUCCESS", "message": "Completed"},
            "execution_summary": {"summary": "Done", "actions": ["action"]},
            "timing": {
                "started_at": "2026-03-01T12:00:00Z",
                "completed_at": "2026-03-01T12:05:00Z",
                "duration_seconds": 300,
            },
        }
        logger.log_response_received(violation_response)

        # Step 2: Create RepoAuditor
        auditor = RepoAuditor(audit_trails_path=audit_path, schemas_path=schemas_path)

        # Step 3: Run full audit
        report = auditor.run_full_audit(session_id)

        # Assert RepoAuditor detects violation
        assert report.overall_status == "FAIL", (
            f"Expected FAIL but got {report.overall_status}"
        )

        # Find the failing findings
        fail_findings = [f for f in report.findings if f.status == "FAIL"]
        assert len(fail_findings) >= 1

        # Budget compliance should be FAIL
        budget_finding = next(
            (f for f in report.findings if f.check_name == "budget_compliance"),
            None
        )
        assert budget_finding is not None
        assert budget_finding.status == "FAIL"

    def test_e2e_replay_session_order(self, tmp_path, schemas_path, minimal_envelope, success_response):
        """
        E2E test: replay_session returns events in correct chronological order
        with proper annotations.
        """
        session_id = "REPLAY-SESSION-001"
        audit_path = str(tmp_path / "audit_trails_replay")

        envelope = dict(minimal_envelope)
        envelope["session"] = dict(envelope["session"])
        envelope["session"]["session_id"] = session_id
        task = dict(envelope["task"])
        task["task_id"] = "REPLAY-TASK-001"
        envelope["task"] = task

        response = dict(success_response)
        response["session_id"] = session_id
        response["task_id"] = "REPLAY-TASK-001"

        logger = AuditLogger(storage_path=audit_path, session_id=session_id)
        logger.log_task_dispatched(envelope)
        logger.log_guard_rail_check("REPLAY-TASK-001", "PAYLOAD_LIMIT", "PASS", "OK")
        logger.log_response_received(response)
        logger.generate_session_summary()

        auditor = RepoAuditor(audit_trails_path=audit_path, schemas_path=schemas_path)
        replayed = auditor.replay_session(session_id)

        assert len(replayed) == 4
        # Check sequence
        assert replayed[0]["sequence"] == 1
        assert replayed[3]["sequence"] == 4

        # Verify types in order
        record_types = [e["record_type"] for e in replayed]
        assert "TASK_DISPATCHED" in record_types
        assert "GUARD_RAIL_CHECK" in record_types
        assert "RESPONSE_RECEIVED" in record_types
        assert "SESSION_SUMMARY" in record_types

        # Check annotations are present
        for event in replayed:
            assert event["annotation"]
            assert event["payload_summary"]
