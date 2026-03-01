"""Test Suite for AOP v2 Version Router (Milestone 2 - Task 2).

Tests version detection, V1 fallback, and error handling in the VersionRouter.

Test Coverage:
- V2 detection with valid aop_version
- V1 fallback when aop_version is missing
- E_PARSE_FAILURE trigger (malformed JSON)
- E_SCHEMA_VALIDATION trigger (invalid schema)
"""

import json
import sys
import os

import pytest

# Add v2/core to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'core'))

from exceptions import AOPParseFailureError, AOPSchemaValidationError
from version_router import (
    ProtocolVersion,
    VersionDetectionResult,
    VersionRouter,
    detect_protocol_version,
    route_to_executor,
)


class TestVersionDetection:
    """Test version detection logic."""

    def setup_method(self):
        """Initialize router before each test."""
        self.router = VersionRouter()

    def test_detect_v2_with_valid_json(self):
        """Test V2 detection with valid aop_version starting with '2.'"""
        valid_v2_json = json.dumps({
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
            },
        })

        result = self.router.detect_version(valid_v2_json)

        # Assertions
        assert result.version == ProtocolVersion.V2
        assert result.parsed_data is not None
        assert result.parsed_data.aop_version == "2.0.2-C"
        assert result.error is None
        assert result.fallback_triggered is False

    def test_detect_v2_with_different_version_number(self):
        """Test V2 detection with aop_version='2.1.0' (still starts with '2.')"""
        v2_json_different_version = json.dumps({
            "aop_version": "2.1.0",
            "schema_version": "2.1.0",
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
        })

        result = self.router.detect_version(v2_json_different_version)

        # Should still detect as V2 (starts with "2.")
        assert result.version == ProtocolVersion.V2

    def test_fallback_to_v1_missing_aop_version(self):
        """Test fallback when aop_version field is missing (may be V1 or unstructured)."""
        json_without_aop_version = json.dumps({
            # Missing "aop_version"
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "TASK",
            "session": {
                "session_id": "AOP-SESSION-2026-02-26-001",
            },
        })

        result = self.router.detect_version(json_without_aop_version)

        # Should not be V2 (missing aop_version field means no V2 detection)
        assert result.version != ProtocolVersion.V2
        # Could be V1 or UNSTRUCTURED depending on content (no v1 keywords here)
        assert result.version in [ProtocolVersion.V1, ProtocolVersion.UNSTRUCTURED]

    def test_fallback_to_v1_with_v1_keywords(self):
        """Test V1 detection with v1-style markdown keywords."""
        v1_prompt = """
        Task: Refactor the authentication module
        Objective: Replace hardcoded credentials with environment variables
        Agent: Emma
        Context: Production security audit
        """

        result = self.router.detect_version(v1_prompt)

        # Should detect as V1 (has v1 keywords)
        assert result.version == ProtocolVersion.V1
        assert result.parsed_data is not None
        assert result.parsed_data["type"] == "v1_prompt"
        assert "Refactor the authentication module" in result.parsed_data["content"]

    def test_classify_as_unstructured(self):
        """Test unstructured classification for plain text without v1 keywords."""
        plain_text = "This is just plain text with no structure or keywords."

        result = self.router.detect_version(plain_text)

        # Should classify as unstructured
        assert result.version == ProtocolVersion.UNSTRUCTURED
        assert result.parsed_data is None

    def test_e_parse_failure_malformed_json(self):
        """Test E_PARSE_FAILURE with malformed JSON."""
        malformed_json = '{"aop_version": "2.0.2-C", "invalid": }'  # Syntax error

        result = self.router.detect_version(malformed_json)

        # Should fallback to V1 or unstructured (parse failure)
        assert result.version in [ProtocolVersion.V1, ProtocolVersion.UNSTRUCTURED]

    def test_e_schema_validation_invalid_schema(self):
        """Test E_SCHEMA_VALIDATION with valid JSON but invalid schema."""
        # Valid JSON but missing required fields for v2 schema
        invalid_schema_json = json.dumps({
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "TASK",
            # Missing required "session", "target", "task" fields
        })

        result = self.router.detect_version(invalid_schema_json)

        # Should trigger V1 fallback due to schema validation failure
        assert result.version == ProtocolVersion.V1
        assert result.fallback_triggered is True  # Schema failure triggered fallback
        assert isinstance(result.error, AOPSchemaValidationError)
        assert result.error.error_code == "E_SCHEMA_VALIDATION"


class TestVersionRouting:
    """Test routing logic based on detected version."""

    def setup_method(self):
        """Initialize router before each test."""
        self.router = VersionRouter()

    def test_route_v2_task(self):
        """Test routing metadata for V2 task."""
        valid_v2_json = json.dumps({
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
            },
        })

        detection = self.router.detect_version(valid_v2_json)
        routing = self.router.route_task(detection)

        # Assertions
        assert routing["version"] == "v2"
        assert routing["use_v2_executor"] is True
        assert routing["transformation_needed"] is False
        assert routing["fallback_available"] is True
        assert routing["parsed_envelope"] is not None

    def test_route_v1_task(self):
        """Test routing metadata for V1 task."""
        v1_prompt = "Task: Test V1 routing\nObjective: Verify routing logic"

        detection = self.router.detect_version(v1_prompt)
        routing = self.router.route_task(detection)

        # Assertions
        assert routing["version"] == "v1"
        assert routing["use_v2_executor"] is False
        assert routing["transformation_needed"] is True
        assert routing["fallback_available"] is False
        assert routing["raw_prompt"] == v1_prompt

    def test_route_unstructured_input(self):
        """Test routing metadata for unstructured input."""
        unstructured_text = "Random unstructured text"

        detection = self.router.detect_version(unstructured_text)
        routing = self.router.route_task(detection)

        # Assertions
        assert routing["version"] == "unstructured"
        assert routing["use_v2_executor"] is False
        assert routing["transformation_needed"] is True
        assert "warning" in routing


class TestResponseValidation:
    """Test executor response validation."""

    def setup_method(self):
        """Initialize router before each test."""
        self.router = VersionRouter()

    def test_validate_v2_response_success(self):
        """Test validation of valid V2 response."""
        valid_response_json = json.dumps({
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
                "summary": "Test summary.",
                "actions": ["Action 1", "Action 2"],
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
        })

        response = self.router.validate_response(
            valid_response_json, ProtocolVersion.V2
        )

        # Assertions
        assert response.message_type == "RESPONSE"
        assert response.task_status.state == "COMPLETED"
        assert response.task_status.final_signal == "SUCCESS"

    def test_validate_v2_response_malformed_json(self):
        """Test validation failure with malformed JSON response."""
        malformed_response = '{"aop_version": "2.0.2-C", invalid: }'

        with pytest.raises(AOPParseFailureError) as exc_info:
            self.router.validate_response(malformed_response, ProtocolVersion.V2)

        assert exc_info.value.error_code == "E_PARSE_FAILURE"

    def test_validate_v2_response_schema_failure(self):
        """Test validation failure with invalid schema."""
        invalid_schema_response = json.dumps({
            "aop_version": "2.0.2-C",
            "message_type": "RESPONSE",
            # Missing required fields
        })

        with pytest.raises(AOPSchemaValidationError) as exc_info:
            self.router.validate_response(invalid_schema_response, ProtocolVersion.V2)

        assert exc_info.value.error_code == "E_SCHEMA_VALIDATION"

    def test_validate_v1_response_freeform(self):
        """Test V1 response validation (free-form text)."""
        v1_response = "Task completed. File refactored successfully."

        result = self.router.validate_response(v1_response, ProtocolVersion.V1)

        # V1 responses are free-form dictionaries
        assert result["type"] == "v1_response"
        assert result["content"] == v1_response


class TestPolicyPrecedence:
    """Test policy precedence rules."""

    def setup_method(self):
        """Initialize router before each test."""
        self.router = VersionRouter()

    def test_guard_rails_timeout_overrides_execution_policy(self):
        """Test that guard_rails.timeout_seconds overrides execution_policy.timeout_seconds."""
        guard_rails = {"timeout_seconds": 600}
        execution_policy = {"timeout_seconds": 1800}

        effective_timeout = self.router.get_effective_timeout(
            guard_rails, execution_policy
        )

        # Guard rails should take precedence
        assert effective_timeout == 600

    def test_execution_policy_timeout_when_guard_rails_not_set(self):
        """Test that execution_policy.timeout_seconds is used when guard_rails is not set."""
        guard_rails = {"timeout_seconds": None}
        execution_policy = {"timeout_seconds": 1200}

        effective_timeout = self.router.get_effective_timeout(
            guard_rails, execution_policy
        )

        # Execution policy should be used
        assert effective_timeout == 1200

    def test_default_timeout_when_neither_set(self):
        """Test default timeout when neither guard_rails nor execution_policy is set."""
        guard_rails = None
        execution_policy = None

        effective_timeout = self.router.get_effective_timeout(
            guard_rails, execution_policy
        )

        # Default timeout: 1800 seconds (30 minutes)
        assert effective_timeout == 1800


class TestAgentCapabilities:
    """Test agent capabilities checks."""

    def setup_method(self):
        """Initialize router before each test."""
        self.router = VersionRouter()

    def test_supports_v2_true(self):
        """Test agent supports V2 when aop_versions_supported includes '2.x'."""
        agent_capabilities = {
            "aop_versions_supported": ["2.0.2-C", "2.0.0", "1.x"]
        }

        supports_v2 = self.router.supports_v2(agent_capabilities)

        assert supports_v2 is True

    def test_supports_v2_false(self):
        """Test agent does NOT support V2 when only V1 is listed."""
        agent_capabilities = {"aop_versions_supported": ["1.x", "1.0"]}

        supports_v2 = self.router.supports_v2(agent_capabilities)

        assert supports_v2 is False

    def test_supports_v2_empty_list(self):
        """Test agent with empty aop_versions_supported list."""
        agent_capabilities = {"aop_versions_supported": []}

        supports_v2 = self.router.supports_v2(agent_capabilities)

        assert supports_v2 is False


class TestConvenienceFunctions:
    """Test public API convenience functions."""

    def test_detect_protocol_version_convenience(self):
        """Test detect_protocol_version convenience function."""
        valid_v2_json = json.dumps({
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
            },
        })

        result = detect_protocol_version(valid_v2_json)

        assert result.version == ProtocolVersion.V2

    def test_route_to_executor_convenience(self):
        """Test route_to_executor convenience function."""
        v1_prompt = "Task: Test routing\nObjective: Test convenience function"

        routing = route_to_executor(v1_prompt)

        assert routing["version"] == "v1"
        assert routing["use_v2_executor"] is False


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
