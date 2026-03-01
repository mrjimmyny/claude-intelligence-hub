"""Test Suite for AOP v2 Schema Validation (Milestone 2 - Task 1).

Tests JSON Schema validation and Pydantic model validation for TASK and RESPONSE
messages using canonical examples from the contract.

Test Coverage:
- Happy Path: Valid TASK and RESPONSE messages
- Sad Path: Missing required fields, invalid enums, extra fields, oversized payloads
"""

import json
import sys
import os
from datetime import datetime

import jsonschema
import pytest
from pydantic import ValidationError

# Add v2/core to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'core'))

from models import (
    ExecutorResponse,
    OrchestrationEnvelope,
    Session,
    Target,
    Task,
    TaskEnvironment,
    Agent,
    TaskStatus,
    ExecutionSummary,
    Timing,
)


class TestTaskSchemaValidation:
    """Test TASK message schema validation (JSON Schema + Pydantic)."""

    def setup_method(self):
        """Load JSON schemas before each test."""
        from pathlib import Path
        schemas_path = Path(__file__).parent.parent / "schemas"
        schema_path = schemas_path / "orchestration_envelope.schema.json"
        with open(schema_path) as f:
            self.task_schema = json.load(f)

    def test_minimal_task_happy_path(self):
        """Test minimal valid TASK message (Contract Section 2.1)."""
        # Canonical minimal example from contract
        task_payload = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "TASK",
            "session": {
                "session_id": "AOP-SESSION-2026-02-26-001",
                "created_at": "2026-02-26T14:00:00Z",
                "orchestrator": "Cyclops",
                "origin": "CLI",
            },
            "target": {
                "agent_name": "Emma",
                "role": "EXECUTOR",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
            },
            "task": {
                "task_id": "TASK-001",
                "objective": "Read and summarize the README.md file.",
                "category": "ANALYSIS",
                "complexity": "LOW",
                "environment": {"workspace_root": "C:/ai/my-project"},
            },
        }

        # Validate against JSON Schema
        jsonschema.validate(instance=task_payload, schema=self.task_schema)

        # Validate against Pydantic model
        envelope = OrchestrationEnvelope.model_validate(task_payload)

        # Assertions
        assert envelope.aop_version == "2.0.2-C"
        assert envelope.message_type == "TASK"
        assert envelope.task.task_id == "TASK-001"
        assert envelope.task.category == "ANALYSIS"

    def test_full_task_happy_path(self):
        """Test full TASK message with all optional fields (Contract Section 2.2)."""
        task_payload = {
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
            },
            "target": {
                "agent_name": "Emma",
                "role": "EXECUTOR",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
                "execution_profile": "balanced",
                "capabilities": {
                    "aop_versions_supported": ["2.0.2-C", "2.0.0", "1.x"],
                    "file_system_access": True,
                    "network_access": "RESTRICTED",
                    "headless_mode": True,
                },
            },
            "task": {
                "task_id": "TASK-001",
                "parent_task_id": None,
                "attempt": 1,
                "objective": "Refactor module X to use dependency injection.",
                "category": "CODE_REFACTORING",
                "complexity": "MEDIUM",
                "priority": "NORMAL",
                "environment": {
                    "workspace_root": "C:/workspace/project-x",
                    "os": "win32",
                    "shell": "powershell",
                    "git_branch": "feature/new-refactor",
                },
                "budgets": {"max_cost_usd": 0.50, "max_tokens": 15000},
            },
            "execution_policy": {
                "timeout_seconds": 1800,
                "max_retries": 1,
                "retry_backoff_seconds": [30, 120, 300],
                "abort_on_first_critical_error": False,
                "auto_terminate_on_timeout": True,
                "on_failure": "REPORT_AND_CONTINUE",
            },
            "guard_rails": {
                "require_minimal_report": True,
                "require_final_signal": True,
                "auto_terminate_on_timeout": True,
                "abort_on_first_critical_error": False,
            },
        }

        # Validate against JSON Schema
        jsonschema.validate(instance=task_payload, schema=self.task_schema)

        # Validate against Pydantic model
        envelope = OrchestrationEnvelope.model_validate(task_payload)

        # Assertions
        assert envelope.task.budgets.max_cost_usd == 0.50
        assert envelope.execution_policy.timeout_seconds == 1800
        assert envelope.guard_rails.require_final_signal is True

    def test_missing_aop_version_sad_path(self):
        """Test TASK message missing required aop_version field."""
        task_payload = {
            # Missing "aop_version"
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "TASK",
            "session": {
                "session_id": "AOP-SESSION-2026-02-26-001",
                "created_at": "2026-02-26T14:00:00Z",
                "orchestrator": "Cyclops",
                "origin": "CLI",
            },
            "target": {
                "agent_name": "Emma",
                "role": "EXECUTOR",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
            },
            "task": {
                "task_id": "TASK-001",
                "objective": "Test objective",
                "category": "ANALYSIS",
                "complexity": "LOW",
                "environment": {"workspace_root": "C:/ai/test"},
            },
        }

        # JSON Schema should fail (aop_version is required)
        with pytest.raises(jsonschema.ValidationError) as exc_info:
            jsonschema.validate(instance=task_payload, schema=self.task_schema)

        assert "'aop_version' is a required property" in str(exc_info.value)

    def test_invalid_message_type_sad_path(self):
        """Test TASK message with invalid message_type value."""
        task_payload = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "INVALID_TYPE",  # Should be "TASK"
            "session": {
                "session_id": "AOP-SESSION-2026-02-26-001",
                "created_at": "2026-02-26T14:00:00Z",
                "orchestrator": "Cyclops",
                "origin": "CLI",
            },
            "target": {
                "agent_name": "Emma",
                "role": "EXECUTOR",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
            },
            "task": {
                "task_id": "TASK-001",
                "objective": "Test objective",
                "category": "ANALYSIS",
                "complexity": "LOW",
                "environment": {"workspace_root": "C:/ai/test"},
            },
        }

        # Pydantic should fail (message_type must be "TASK" literal)
        with pytest.raises(ValidationError) as exc_info:
            OrchestrationEnvelope.model_validate(task_payload)

        errors = exc_info.value.errors()
        assert any("message_type" in str(e) for e in errors)

    def test_extra_fields_sad_path(self):
        """Test TASK message with extra fields (additionalProperties: false)."""
        task_payload = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "TASK",
            "extra_forbidden_field": "should_fail",  # Extra field
            "session": {
                "session_id": "AOP-SESSION-2026-02-26-001",
                "created_at": "2026-02-26T14:00:00Z",
                "orchestrator": "Cyclops",
                "origin": "CLI",
            },
            "target": {
                "agent_name": "Emma",
                "role": "EXECUTOR",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
            },
            "task": {
                "task_id": "TASK-001",
                "objective": "Test objective",
                "category": "ANALYSIS",
                "complexity": "LOW",
                "environment": {"workspace_root": "C:/ai/test"},
            },
        }

        # Pydantic should fail (extra='forbid')
        with pytest.raises(ValidationError) as exc_info:
            OrchestrationEnvelope.model_validate(task_payload)

        errors = exc_info.value.errors()
        assert any("extra_forbidden_field" in str(e) for e in errors)

    def test_objective_exceeds_hard_limit_sad_path(self):
        """Test TASK message with objective exceeding 50,000 char hard limit."""
        task_payload = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "TASK",
            "session": {
                "session_id": "AOP-SESSION-2026-02-26-001",
                "created_at": "2026-02-26T14:00:00Z",
                "orchestrator": "Cyclops",
                "origin": "CLI",
            },
            "target": {
                "agent_name": "Emma",
                "role": "EXECUTOR",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
            },
            "task": {
                "task_id": "TASK-001",
                "objective": "A" * 50001,  # Exceeds 50,000 char limit
                "category": "ANALYSIS",
                "complexity": "LOW",
                "environment": {"workspace_root": "C:/ai/test"},
            },
        }

        # Pydantic should fail (max_length=50000)
        with pytest.raises(ValidationError) as exc_info:
            OrchestrationEnvelope.model_validate(task_payload)

        errors = exc_info.value.errors()
        assert any("objective" in str(e) and "max_length" in str(e) for e in errors)

    def test_inputs_exceed_hard_limit_sad_path(self):
        """Test TASK message with more than 100 input files."""
        task_payload = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "TASK",
            "session": {
                "session_id": "AOP-SESSION-2026-02-26-001",
                "created_at": "2026-02-26T14:00:00Z",
                "orchestrator": "Cyclops",
                "origin": "CLI",
            },
            "target": {
                "agent_name": "Emma",
                "role": "EXECUTOR",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
            },
            "task": {
                "task_id": "TASK-001",
                "objective": "Test objective",
                "category": "ANALYSIS",
                "complexity": "LOW",
                "environment": {"workspace_root": "C:/ai/test"},
                "inputs": [
                    {"type": "FILE", "path": f"/path/file{i}.txt"}
                    for i in range(101)  # 101 files > 100 limit
                ],
            },
        }

        # Pydantic should fail (hard limit: 100)
        with pytest.raises(ValidationError) as exc_info:
            OrchestrationEnvelope.model_validate(task_payload)

        errors = exc_info.value.errors()
        assert any("inputs" in str(e) for e in errors)


class TestResponseSchemaValidation:
    """Test RESPONSE message schema validation (JSON Schema + Pydantic)."""

    def setup_method(self):
        """Load JSON schemas before each test."""
        from pathlib import Path
        schemas_path = Path(__file__).parent.parent / "schemas"
        schema_path = schemas_path / "executor_response.schema.json"
        with open(schema_path) as f:
            self.response_schema = json.load(f)

    def test_response_happy_path(self):
        """Test valid RESPONSE message (Contract Section 5)."""
        response_payload = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "RESPONSE",
            "session_id": "AOP-SESSION-2026-02-26-001",
            "task_id": "TASK-001",
            "agent": {
                "name": "Emma",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
            },
            "task_status": {
                "state": "COMPLETED",
                "final_signal": "SUCCESS",
                "message": "Task completed successfully.",
            },
            "execution_summary": {
                "summary": "Refactored module_x.py to use dependency injection.",
                "actions": [
                    "Read src/module_x.py (312 lines).",
                    "Identified 4 uses of global configuration.",
                    "Introduced ConfigProvider interface.",
                ],
                "output_artifacts": [],
                "warnings": [],
                "errors": [],
            },
            "timing": {
                "started_at": "2026-02-26T12:35:01Z",
                "completed_at": "2026-02-26T12:40:32Z",
                "duration_seconds": 331,
                "retries_attempted": 0,
            },
        }

        # Validate against JSON Schema
        jsonschema.validate(instance=response_payload, schema=self.response_schema)

        # Validate against Pydantic model
        response = ExecutorResponse.model_validate(response_payload)

        # Assertions
        assert response.task_status.state == "COMPLETED"
        assert response.task_status.final_signal == "SUCCESS"
        assert response.timing.duration_seconds == 331

    def test_response_missing_final_signal_sad_path(self):
        """Test RESPONSE missing final_signal (guard rail violation)."""
        response_payload = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "RESPONSE",
            "session_id": "AOP-SESSION-2026-02-26-001",
            "task_id": "TASK-001",
            "agent": {
                "name": "Emma",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
            },
            "task_status": {
                "state": "COMPLETED",
                # Missing "final_signal" - required by guard rails
                "message": "Task completed.",
            },
            "execution_summary": {
                "summary": "Test summary.",
                "actions": ["Action 1"],
                "output_artifacts": [],
                "warnings": [],
                "errors": [],
            },
            "timing": {
                "started_at": "2026-02-26T12:35:01Z",
                "completed_at": "2026-02-26T12:40:32Z",
                "duration_seconds": 331,
                "retries_attempted": 0,
            },
        }

        # Pydantic should fail (final_signal is required in TaskStatus)
        with pytest.raises(ValidationError) as exc_info:
            ExecutorResponse.model_validate(response_payload)

        errors = exc_info.value.errors()
        assert any("final_signal" in str(e) for e in errors)

    def test_response_empty_summary_sad_path(self):
        """Test RESPONSE with empty summary (guard rail violation)."""
        response_payload = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "RESPONSE",
            "session_id": "AOP-SESSION-2026-02-26-001",
            "task_id": "TASK-001",
            "agent": {
                "name": "Emma",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
            },
            "task_status": {
                "state": "COMPLETED",
                "final_signal": "SUCCESS",
                "message": "Task completed.",
            },
            "execution_summary": {
                "summary": "",  # Empty summary - guard rail violation
                "actions": [],  # Empty actions - guard rail violation
                "output_artifacts": [],
                "warnings": [],
                "errors": [],
            },
            "timing": {
                "started_at": "2026-02-26T12:35:01Z",
                "completed_at": "2026-02-26T12:40:32Z",
                "duration_seconds": 331,
                "retries_attempted": 0,
            },
        }

        # Pydantic model_validator should fail (require_minimal_report)
        with pytest.raises(ValidationError) as exc_info:
            ExecutorResponse.model_validate(response_payload)

        errors = exc_info.value.errors()
        # Check for guard rail validation error
        assert any("require_minimal_report" in str(e) for e in errors)

    def test_response_exceeds_size_limit_sad_path(self):
        """Test RESPONSE exceeding 500KB hard limit."""
        # Create a large response by adding many long actions (but under 200 count limit)
        large_actions = [f"Action {i}: " + "x" * 3000 for i in range(180)]

        response_payload = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "RESPONSE",
            "session_id": "AOP-SESSION-2026-02-26-001",
            "task_id": "TASK-001",
            "agent": {
                "name": "Emma",
                "provider": "CODEX",
                "model": "gpt-5.3-codex",
            },
            "task_status": {
                "state": "COMPLETED",
                "final_signal": "SUCCESS",
                "message": "Task completed.",
            },
            "execution_summary": {
                "summary": "Large response test.",
                "actions": large_actions,  # Will exceed 500KB
                "output_artifacts": [],
                "warnings": [],
                "errors": [],
            },
            "timing": {
                "started_at": "2026-02-26T12:35:01Z",
                "completed_at": "2026-02-26T12:40:32Z",
                "duration_seconds": 331,
                "retries_attempted": 0,
            },
        }

        # Pydantic model_validator should fail (exceeds 500KB)
        with pytest.raises(ValidationError) as exc_info:
            ExecutorResponse.model_validate(response_payload)

        # Check that envelope size validation failed
        errors = exc_info.value.errors()
        assert any("500" in str(e) or "envelope" in str(e).lower() for e in errors)


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
