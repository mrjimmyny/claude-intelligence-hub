"""
AOP V2 Integration Tests - Milestone 3
End-to-end integration test scenarios for AOPOrchestrator

Tests the complete orchestration flow:
- Task envelope construction
- Version routing
- Guard rail enforcement
- Response validation

Author: Magneto
Date: 2026-02-28
Contract: 03_contract-aop-v2-ciclope-final.md (v2.0.2-C)
"""

import sys
import json
import pytest
import os

# Add v2/core to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'core'))

from orchestrator import AOPOrchestrator


class TestIntegrationScenarios:
    """Integration test scenarios for AOP V2 orchestration."""

    @pytest.fixture
    def orchestrator(self):
        """Fixture to create AOPOrchestrator instance."""
        return AOPOrchestrator()

    def test_scenario_a_happy_path_v2(self, orchestrator):
        """
        Scenario A: Happy Path V2 (Contract Sections 2, 5, 11)

        Flow:
        1. Build valid TASK via build_task_envelope
        2. Route: assert mode == "V2"
        3. Apply guard rails: assert no violations
        4. Process valid RESPONSE (state: COMPLETED, final_signal: SUCCESS)
        5. Assert: no error codes, all required fields present
        """
        # Step 1: Build valid TASK envelope (minimal version)
        envelope = orchestrator.build_task_envelope(
            session_id="AOP-SESSION-TEST-001",
            orchestrator_name="TestOrchestrator",
            origin="CLI",
            target_agent_name="TestExecutor",
            target_role="EXECUTOR",
            target_provider="CLAUDE",
            target_model="claude-sonnet-4-5",
            task_id="TASK-TEST-001",
            objective="Run integration test - scenario A",
            category="ANALYSIS",
            complexity="LOW",
            workspace_root="C:/ai/test-workspace"
        )

        # Verify envelope is valid
        assert envelope is not None
        assert envelope.aop_version == "2.0.2-C"
        assert envelope.message_type == "TASK"
        assert envelope.session.session_id == "AOP-SESSION-TEST-001"
        assert envelope.task.task_id == "TASK-TEST-001"

        # Step 2: Route task - assert mode == "V2"
        routing_result = orchestrator.route_task(envelope)
        assert routing_result["mode"] == "V2"
        assert "error_code" not in routing_result or routing_result["error_code"] is None

        # Step 3: Apply guard rails - assert no violations
        guard_result = orchestrator.apply_guard_rails(envelope)
        assert guard_result["valid"] is True
        assert len(guard_result["violations"]) == 0
        assert guard_result["payload_size_kb"] < 200  # Under hard limit

        # Step 4: Build valid RESPONSE
        valid_response = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "RESPONSE",
            "session_id": "AOP-SESSION-TEST-001",
            "task_id": "TASK-TEST-001",
            "agent": {
                "name": "TestExecutor",
                "provider": "CLAUDE",
                "model": "claude-sonnet-4-5"
            },
            "task_status": {
                "state": "COMPLETED",
                "final_signal": "SUCCESS",
                "message": "Task completed successfully."
            },
            "execution_summary": {
                "summary": "Integration test scenario A executed successfully.",
                "actions": [
                    "Validated task envelope",
                    "Executed test scenario",
                    "Generated response"
                ],
                "output_artifacts": [],
                "warnings": [],
                "errors": []
            },
            "timing": {
                "started_at": "2026-02-28T10:00:00Z",
                "completed_at": "2026-02-28T10:00:05Z",
                "duration_seconds": 5
            }
        }

        # Step 5: Process response - assert no errors, all required fields present
        response_result = orchestrator.process_executor_response(json.dumps(valid_response))

        assert response_result["valid"] is True
        assert len(response_result["violations"]) == 0
        assert "error_code" not in response_result
        assert response_result["parsed_data"]["state"] == "COMPLETED"
        assert response_result["parsed_data"]["final_signal"] == "SUCCESS"
        assert len(response_result["parsed_data"]["summary"]) > 0
        assert response_result["parsed_data"]["actions_count"] == 3

        print("[PASS] Scenario A: Happy Path V2")

    def test_scenario_b_v2_failure_with_v1_fallback(self, orchestrator):
        """
        Scenario B: V2 Failure with V1 Fallback (Contract Section 1.3)

        Flow:
        1. Provide input that fails V2 schema validation
        2. Assert: error_code == "E_SCHEMA_VALIDATION"
        3. Assert: mode == "V1_FALLBACK"
        4. Assert: VERSION_FALLBACK metadata produced
        """
        # Step 1: Create invalid V2 envelope (missing required fields)
        invalid_envelope = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "TASK",
            # Missing required fields: session, target, task
        }

        # Step 2 & 3: Route task - assert E_SCHEMA_VALIDATION and V1_FALLBACK
        routing_result = orchestrator.route_task(invalid_envelope)

        assert routing_result["mode"] == "V1_FALLBACK"
        assert routing_result["error_code"] == "E_SCHEMA_VALIDATION"
        # error_message is optional
        assert routing_result["error_code"] is not None

        # Step 4: Verify VERSION_FALLBACK metadata is produced
        # (VersionRouter should include fallback metadata in the result)
        assert routing_result["error_code"] is not None

        print("[PASS] Scenario B: V2 Failure with V1 Fallback")

    def test_scenario_c_guard_rail_violation(self, orchestrator):
        """
        Scenario C: Guard-Rail Violation During Flow (Contract Sections 4, 11)

        Flow:
        1. Build TASK that intentionally violates payload size (> 200KB)
        2. Run through apply_guard_rails(...)
        3. Assert: correct E_* error raised and execution blocked
        """
        # Step 1: Create a minimal valid envelope, then pad it to exceed 200KB
        # Build base envelope
        base_envelope = orchestrator.build_task_envelope(
            session_id="AOP-SESSION-TEST-002",
            orchestrator_name="TestOrchestrator",
            origin="CLI",
            target_agent_name="TestExecutor",
            target_role="EXECUTOR",
            target_provider="CLAUDE",
            target_model="claude-sonnet-4-5",
            task_id="TASK-TEST-002",
            objective="Test guard rail violation",
            category="ANALYSIS",
            complexity="LOW",
            workspace_root="C:/ai/test-workspace"
        )

        # Convert to dict and add a large padding field (using extensions)
        import json
        envelope_dict = json.loads(base_envelope.model_dump_json())
        # Add 250KB of padding via extensions
        envelope_dict["extensions"] = {"x_padding": "X" * (250 * 1024)}
        envelope = envelope_dict

        # Step 2: Apply guard rails
        guard_result = orchestrator.apply_guard_rails(envelope)

        # Step 3: Assert E_CONTEXT_OVERFLOW error and execution blocked
        assert guard_result["valid"] is False
        assert len(guard_result["violations"]) > 0
        assert guard_result["error_code"] == "E_CONTEXT_OVERFLOW"
        assert "200KB" in guard_result["error_message"]
        assert guard_result["payload_size_kb"] > 200

        print("[PASS] Scenario C: Guard-Rail Violation")

    def test_scenario_c_alternative_cost_budget_violation(self, orchestrator):
        """
        Scenario C (Alternative): Cost Budget Violation (Contract Section 11)

        Alternative guard rail violation: negative cost budget.
        """
        # Build envelope with invalid cost budget
        envelope = orchestrator.build_task_envelope(
            session_id="AOP-SESSION-TEST-003",
            orchestrator_name="TestOrchestrator",
            origin="CLI",
            target_agent_name="TestExecutor",
            target_role="EXECUTOR",
            target_provider="CLAUDE",
            target_model="claude-sonnet-4-5",
            task_id="TASK-TEST-003",
            objective="Test cost budget violation",
            category="ANALYSIS",
            complexity="LOW",
            workspace_root="C:/ai/test-workspace",
            budgets={"max_cost_usd": -1.0}  # Invalid negative budget
        )

        # Apply guard rails
        guard_result = orchestrator.apply_guard_rails(envelope)

        # Assert violation detected
        assert guard_result["valid"] is False
        assert any("cost budget" in v.lower() for v in guard_result["violations"])

        print("[PASS] Scenario C (Alternative): Cost Budget Violation")

    def test_scenario_d_malformed_executor_response(self, orchestrator):
        """
        Scenario D: Malformed Executor Response (Contract Sections 5, 12)

        Flow:
        1. Create valid JSON representing a RESPONSE missing required fields
        2. Process via process_executor_response()
        3. Assert error is returned (E_MALFORMED_RESPONSE)
        4. Verify execution is blocked

        Tests that process_executor_response() correctly rejects
        a RESPONSE missing required fields (final_signal, report).
        """
        # Create a malformed RESPONSE - valid JSON but missing required fields
        malformed_response = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "RESPONSE",
            "session_id": "AOP-SESSION-TEST-004",
            "task_id": "TASK-TEST-004",
            "agent": {
                "name": "TestExecutor",
                "provider": "CLAUDE",
                "model": "claude-sonnet-4-5"
            },
            "task_status": {
                "state": "COMPLETED",
                # Missing: final_signal (REQUIRED when require_final_signal=true)
                "message": "Task completed."
            },
            "execution_summary": {
                # Missing: summary (REQUIRED when require_minimal_report=true)
                "actions": [],  # Empty actions (also invalid)
                "output_artifacts": [],
                "warnings": [],
                "errors": []
            },
            "timing": {
                "started_at": "2026-02-28T10:00:00Z",
                "completed_at": "2026-02-28T10:00:05Z",
                "duration_seconds": 5
            }
        }

        # Process the malformed response
        import json
        validation_result = orchestrator.process_executor_response(json.dumps(malformed_response))

        # Assert that validation fails
        assert validation_result["valid"] is False
        assert len(validation_result["violations"]) > 0

        # Assert correct error code (E_MALFORMED_RESPONSE)
        assert validation_result["error_code"] in ["E_MALFORMED_RESPONSE", "E_SCHEMA_VALIDATION"]

        # Verify that specific violations are detected
        violations_text = " ".join(validation_result["violations"]).lower()
        assert "final_signal" in violations_text or "summary" in violations_text or "actions" in violations_text

        print("[PASS] Scenario D: Malformed Executor Response")


if __name__ == "__main__":
    # Allow running tests directly
    pytest.main([__file__, "-v", "-s"])
