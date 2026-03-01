"""
AOP V2 Orchestrator - Milestone 3
Production-ready integration module for AOP v2.0.2-C

This module provides the main AOPOrchestrator class that integrates:
- Task envelope construction (Contract Section 2)
- Version routing (Contract Section 1.3)
- Guard rail enforcement (Contract Sections 4, 11)
- Response validation (Contract Section 5)

Author: Magneto
Date: 2026-02-28
Contract: 03_contract-aop-v2-ciclope-final.md (v2.0.2-C)
"""

import json
from typing import Dict, Any, Optional, List, Union
from datetime import datetime, timezone

# Import from same directory (v2/core/)
from models import (
    VersionHeader,
    Session,
    Target,
    Task,
    OrchestrationEnvelope,
    ExecutionPolicy,
    GuardRails,
    ExecutorResponse,
    TaskStatus,
    ExecutionSummary,
    Agent
)
from version_router import VersionRouter
from guard_rail_engine import GuardRailEngine
from exceptions import (
    AOPError,
    AOPSchemaValidationError,
    AOPContextOverflowError,
    AOPCostLimitExceededError,
    AOPPermissionDeniedError,
    AOPTimeoutError
)


class AOPOrchestrator:
    """
    Production orchestrator for AOP v2.0.2-C tasks.

    Integrates version routing, guard rail enforcement, and response validation
    into a single cohesive workflow.
    """

    def __init__(self):
        """Initialize orchestrator with router and guard rail engine."""
        from pathlib import Path
        self.router = VersionRouter()
        self.guard_engine = GuardRailEngine()
        # Schema files are in v2/schemas/ (sibling directory to v2/core/)
        schemas_path = Path(__file__).parent.parent / "schemas"
        self.schema_path = schemas_path / "orchestration_envelope.schema.json"
        self.response_schema_path = schemas_path / "executor_response.schema.json"

    def build_task_envelope(
        self,
        session_id: str,
        orchestrator_name: str,
        origin: str,
        target_agent_name: str,
        target_role: str,
        target_provider: str,
        target_model: str,
        task_id: str,
        objective: str,
        category: str,
        complexity: str,
        workspace_root: str,
        # Optional parameters for full envelope
        workflow_pattern: Optional[str] = None,
        parent_task_id: Optional[str] = None,
        attempt: int = 1,
        priority: str = "NORMAL",
        inputs: Optional[List[Dict[str, Any]]] = None,
        expected_outputs: Optional[List[Dict[str, Any]]] = None,
        constraints: Optional[Dict[str, Any]] = None,
        budgets: Optional[Dict[str, Any]] = None,
        access: Optional[Dict[str, Any]] = None,
        execution_policy: Optional[Dict[str, Any]] = None,
        guard_rails: Optional[Dict[str, Any]] = None,
        phases: Optional[List[Dict[str, Any]]] = None,
        orchestration_metadata: Optional[Dict[str, Any]] = None,
        **kwargs
    ) -> OrchestrationEnvelope:
        """
        Build a validated TASK envelope from Python parameters.

        Supports both minimal (Contract 2.1) and full (Contract 2.2) envelopes.

        Args:
            session_id: Unique session identifier
            orchestrator_name: Name of orchestrating agent
            origin: Origin of request (CLI, API, etc.)
            target_agent_name: Executor agent name
            target_role: Agent role (EXECUTOR, AUDITOR, etc.)
            target_provider: Provider (CLAUDE, CODEX, GEMINI)
            target_model: Model identifier
            task_id: Unique task identifier
            objective: Task objective/description
            category: Task category (ANALYSIS, CODE_GENERATION, etc.)
            complexity: Complexity level (LOW, MEDIUM, HIGH, CRITICAL)
            workspace_root: Workspace root path
            **kwargs: Additional optional fields

        Returns:
            Validated OrchestrationEnvelope object

        Raises:
            AOPSchemaValidationError: If envelope fails validation
        """
        # Build session info (Contract Section 2.1)
        session_data = {
            "session_id": session_id,
            "created_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
            "orchestrator": orchestrator_name,
            "origin": origin
        }
        if workflow_pattern:
            session_data["workflow_pattern"] = workflow_pattern

        session = Session(**session_data)

        # Build target agent (Contract Section 2.1)
        target = Target(
            agent_name=target_agent_name,
            role=target_role,
            provider=target_provider,
            model=target_model
        )

        # Build task definition (Contract Section 2.1/2.2)
        task_data = {
            "task_id": task_id,
            "objective": objective,
            "category": category,
            "complexity": complexity,
            "environment": {"workspace_root": workspace_root},
            "attempt": attempt,
            "priority": priority
        }

        # Add optional fields if provided
        if parent_task_id:
            task_data["parent_task_id"] = parent_task_id
        if inputs:
            task_data["inputs"] = inputs
        if expected_outputs:
            task_data["expected_outputs"] = expected_outputs
        if constraints:
            task_data["constraints"] = constraints
        if budgets:
            task_data["budgets"] = budgets
        if access:
            task_data["access"] = access

        task = Task(**task_data)

        # Build envelope (OrchestrationEnvelope inherits from VersionHeader)
        envelope_data = {
            "aop_version": "2.0.2-C",
            "schema_version": "2.0.2",
            "protocol_family": "AOP",
            "message_type": "TASK",
            "session": session.model_dump(exclude_none=True),
            "target": target.model_dump(exclude_none=True),
            "task": task.model_dump(exclude_none=True)
        }

        # Add optional top-level fields
        if execution_policy:
            envelope_data["execution_policy"] = execution_policy
        if guard_rails:
            envelope_data["guard_rails"] = guard_rails
        if phases:
            envelope_data["phases"] = phases
        if orchestration_metadata:
            envelope_data["orchestration_metadata"] = orchestration_metadata

        # Validate and return
        try:
            envelope = OrchestrationEnvelope(**envelope_data)
            return envelope
        except Exception as e:
            raise AOPSchemaValidationError(f"Task envelope validation failed: {e}")

    def route_task(self, envelope: Union[OrchestrationEnvelope, Dict[str, Any], str]) -> Dict[str, Any]:
        """
        Route task using version detection logic.

        Uses VersionRouter from M1 to detect V2, V1_FALLBACK, or UNSTRUCTURED.

        Args:
            envelope: OrchestrationEnvelope object, dict, or JSON string

        Returns:
            Dict with:
                - mode: "V2" | "V1_FALLBACK" | "UNSTRUCTURED"
                - error_code: Optional error code (E_PARSE_FAILURE, E_SCHEMA_VALIDATION)
                - envelope: Parsed envelope (if successful)
                - fallback_metadata: VERSION_FALLBACK event (if applicable)
        """
        # Convert to dict if OrchestrationEnvelope
        if isinstance(envelope, OrchestrationEnvelope):
            envelope_dict = json.loads(envelope.model_dump_json())
        elif isinstance(envelope, str):
            try:
                envelope_dict = json.loads(envelope)
            except json.JSONDecodeError:
                return {
                    "mode": "UNSTRUCTURED",
                    "error_code": "E_PARSE_FAILURE",
                    "error_message": "Failed to parse JSON"
                }
        else:
            envelope_dict = envelope

        # Use VersionRouter to detect and route
        try:
            # Step 1: Detect version
            detection_result = self.router.detect_version(json.dumps(envelope_dict))

            # Step 2: Route based on detection
            routing_metadata = self.router.route_task(detection_result)

            # Step 3: Transform to expected format
            if routing_metadata["version"] == "v2":
                return {
                    "mode": "V2",
                    "parsed_envelope": routing_metadata.get("parsed_envelope"),
                    "error_code": None
                }
            elif routing_metadata["version"] == "v1":
                return {
                    "mode": "V1_FALLBACK",
                    "error_code": "E_SCHEMA_VALIDATION" if routing_metadata.get("fallback_triggered") else None,
                    "fallback_metadata": routing_metadata
                }
            else:  # unstructured
                return {
                    "mode": "UNSTRUCTURED",
                    "error_code": "E_PARSE_FAILURE",
                    "error_message": routing_metadata.get("warning")
                }
        except Exception as e:
            return {
                "mode": "V1_FALLBACK",
                "error_code": "E_SCHEMA_VALIDATION",
                "error_message": str(e)
            }

    def apply_guard_rails(
        self,
        envelope: Union[OrchestrationEnvelope, Dict[str, Any]],
        guard_rails_config: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Apply guard rail enforcement to task envelope.

        Enforces (Contract Section 11):
        - Payload size limits (200KB TASK hard limit, Contract Section 4)
        - Cost budgets (max_cost_usd)
        - Timeout limits (with policy precedence)
        - Access rules (filesystem + network)

        Args:
            envelope: Task envelope to validate
            guard_rails_config: Optional guard rails config (uses envelope's if not provided)

        Returns:
            Dict with:
                - valid: True if passed all guard rails
                - violations: List of violations (if any)
                - error_code: Error code if hard limit violated
                - warnings: List of warnings for soft limits
        """
        # Convert to dict if OrchestrationEnvelope
        if isinstance(envelope, OrchestrationEnvelope):
            envelope_dict = json.loads(envelope.model_dump_json())
        else:
            envelope_dict = envelope

        # Extract guard rails config
        if guard_rails_config is None:
            guard_rails_config = envelope_dict.get("guard_rails", {})
        if guard_rails_config is None:
            guard_rails_config = {}

        violations = []
        warnings = []

        # 1. Check payload size (Contract Section 4 - HARD limit 200KB)
        envelope_json = json.dumps(envelope_dict)
        payload_size_bytes = len(envelope_json.encode('utf-8'))
        payload_size_kb = payload_size_bytes / 1024

        if payload_size_kb > 200:
            return {
                "valid": False,
                "violations": ["Payload exceeds 200KB hard limit"],
                "error_code": "E_CONTEXT_OVERFLOW",
                "error_message": f"TASK envelope size {payload_size_kb:.2f}KB exceeds 200KB limit",
                "payload_size_kb": payload_size_kb
            }

        # 2. Check cost budget (Contract Section 2.2)
        task = envelope_dict.get("task", {})
        budgets = task.get("budgets") or {}
        constraints = task.get("constraints") or {}

        max_cost = budgets.get("max_cost_usd") or constraints.get("max_cost_usd")
        if max_cost is not None and max_cost < 0:
            violations.append("Negative cost budget not allowed")

        # 3. Check timeout (Contract Section 11 - policy precedence)
        # guard_rails.timeout_seconds overrides execution_policy.timeout_seconds
        guard_timeout = guard_rails_config.get("timeout_seconds")
        exec_policy = envelope_dict.get("execution_policy") or {}
        exec_timeout = exec_policy.get("timeout_seconds") if isinstance(exec_policy, dict) else None

        effective_timeout = guard_timeout if guard_timeout is not None else exec_timeout

        if effective_timeout is not None and effective_timeout <= 0:
            violations.append("Invalid timeout value (must be > 0)")

        # 4. Check access rules (Contract Section 11)
        task_access = task.get("access") or {}
        target = envelope_dict.get("target") or {}
        target_caps = target.get("capabilities") or {}

        # Network access - most restrictive wins
        task_network = task_access.get("network") if isinstance(task_access, dict) else None
        caps_network = target_caps.get("network_access") if isinstance(target_caps, dict) else None

        if task_network == "NONE" and caps_network not in ["NONE", None]:
            # Task restricts network but capabilities allow it - OK (task is more restrictive)
            pass
        elif task_network in ["FULL", "RESTRICTED"] and caps_network == "NONE":
            violations.append(f"Task requires network={task_network} but target capabilities deny network access")

        # Filesystem access - intersection of allowed paths
        # (simplified check - production would validate path overlaps)
        fs_access = task_access.get("filesystem", {})
        write_paths = fs_access.get("write_paths", [])

        if target_caps.get("file_system_access") is False and len(write_paths) > 0:
            violations.append("Task requires file system write access but target capabilities deny it")

        # Return results
        if violations:
            return {
                "valid": False,
                "violations": violations,
                "error_code": "E_PERMISSION_DENIED" if "access" in str(violations) else "E_SCHEMA_VALIDATION",
                "warnings": warnings
            }

        return {
            "valid": True,
            "violations": [],
            "warnings": warnings,
            "effective_timeout": effective_timeout,
            "payload_size_kb": payload_size_kb
        }

    def process_executor_response(self, raw_json: str) -> Dict[str, Any]:
        """
        Parse and validate executor RESPONSE.

        Enforces (Contract Section 5):
        - require_final_signal: Must have task_status.state + task_status.final_signal
        - require_minimal_report: Must have non-empty summary + actions

        Args:
            raw_json: Raw JSON response from executor

        Returns:
            Dict with:
                - valid: True if response is valid
                - response: Parsed and validated ExecutorResponse object
                - violations: List of violations (if any)
                - error_code: Error code if validation failed
        """
        # Parse JSON
        try:
            response_dict = json.loads(raw_json)
        except json.JSONDecodeError as e:
            return {
                "valid": False,
                "error_code": "E_PARSE_FAILURE",
                "error_message": f"Failed to parse response JSON: {e}",
                "violations": ["Invalid JSON"]
            }

        # Validate message type
        if response_dict.get("message_type") != "RESPONSE":
            return {
                "valid": False,
                "error_code": "E_MALFORMED_RESPONSE",
                "error_message": "Expected message_type=RESPONSE",
                "violations": ["Invalid message_type"]
            }

        violations = []

        # Enforce require_final_signal (Contract Section 5)
        task_status = response_dict.get("task_status", {})
        if not task_status.get("state"):
            violations.append("Missing required field: task_status.state")
        if not task_status.get("final_signal"):
            violations.append("Missing required field: task_status.final_signal")

        # Enforce require_minimal_report (Contract Section 5)
        exec_summary = response_dict.get("execution_summary", {})
        summary = exec_summary.get("summary", "")
        actions = exec_summary.get("actions", [])

        if not summary or len(summary.strip()) == 0:
            violations.append("Missing or empty execution_summary.summary")
        if not actions or len(actions) == 0:
            violations.append("Missing or empty execution_summary.actions")

        # Validate Pydantic models
        try:
            # Validate task_status
            task_status_obj = TaskStatus(**task_status)

            # Validate execution_summary
            exec_summary_obj = ExecutionSummary(**exec_summary)

            # Validate agent info
            agent_dict = response_dict.get("agent", {})
            agent_obj = Agent(**agent_dict)

            # Build full response object
            response_obj = ExecutorResponse(**response_dict)

        except Exception as e:
            violations.append(f"Pydantic validation failed: {e}")

        # Return results
        if violations:
            return {
                "valid": False,
                "violations": violations,
                "error_code": "E_MALFORMED_RESPONSE",
                "error_message": "; ".join(violations)
            }

        return {
            "valid": True,
            "response": response_obj,
            "violations": [],
            "parsed_data": {
                "session_id": response_dict.get("session_id"),
                "task_id": response_dict.get("task_id"),
                "state": task_status.get("state"),
                "final_signal": task_status.get("final_signal"),
                "summary": summary,
                "actions_count": len(actions)
            }
        }
