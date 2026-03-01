"""AOP v2 Guard Rail Engine.

Implements enforcement of guard rails, payload limits, access controls, and
policy precedence rules from the AOP v2.0.2-C contract.

Key responsibilities:
- Enforce timeout policies with precedence rules
- Validate payload size limits (soft and hard)
- Compute effective access rules (filesystem, network)
- Enforce cost budgets
- Validate response requirements (minimal report, final signal)
"""

from __future__ import annotations

import json
import logging
from dataclasses import dataclass
from typing import Any, Optional

from exceptions import (
    AOPContextOverflowError,
    AOPCostLimitExceededError,
    AOPPayloadSizeWarning,
    AOPPermissionDeniedError,
)
from models import ExecutorResponse, GuardRails, NetworkAccess, OrchestrationEnvelope

logger = logging.getLogger(__name__)


# === Payload Limits (from Contract) ===

PAYLOAD_LIMITS = {
    "task_objective_soft": 40_000,  # chars, warning at 40k
    "task_objective_hard": 50_000,  # chars, hard limit
    "task_inputs_hard": 100,  # files
    "task_expected_outputs_hard": 50,  # artifacts
    "phases_soft": 10,  # phases
    "checkpoints_per_phase_soft": 20,  # checkpoints
    "execution_actions_soft": 200,  # actions
    "task_envelope_hard": 200_000,  # bytes (200KB)
    "response_envelope_hard": 500_000,  # bytes (500KB)
}


@dataclass
class GuardRailViolation:
    """Guard rail violation details.

    Attributes:
        rule: Violated rule name.
        severity: Violation severity (WARNING, ERROR).
        message: Human-readable message.
        details: Additional violation details.
    """

    rule: str
    severity: str  # WARNING, ERROR
    message: str
    details: dict[str, Any]


@dataclass
class GuardRailResult:
    """Guard rail enforcement result.

    Attributes:
        allowed: Whether the operation is allowed.
        violations: List of violations found.
        warnings: List of warnings.
        effective_config: Effective configuration after applying precedence.
    """

    allowed: bool
    violations: list[GuardRailViolation]
    warnings: list[GuardRailViolation]
    effective_config: dict[str, Any]


class GuardRailEngine:
    """AOP v2 guard rail enforcement engine.

    Implements all guard rail checks from the contract:
    - Payload size limits (soft and hard)
    - Timeout policy precedence
    - Effective access rules computation
    - Cost budget enforcement
    - Response validation requirements
    """

    def __init__(self) -> None:
        """Initialize guard rail engine."""
        logger.info("Initializing GuardRailEngine")

    # === Envelope Validation ===

    def validate_task_envelope(
        self, envelope: OrchestrationEnvelope
    ) -> GuardRailResult:
        """Validate task envelope against all guard rails.

        Checks:
        - Payload size limits
        - Input/output artifact limits
        - Phase/checkpoint limits
        - Objective length limits

        Args:
            envelope: OrchestrationEnvelope to validate.

        Returns:
            GuardRailResult with validation outcome.
        """
        logger.debug(f"Validating task envelope: {envelope.task.task_id}")

        violations = []
        warnings = []

        # Check total envelope size (hard limit: 200KB)
        envelope_json = json.dumps(envelope.model_dump(mode="json"))
        envelope_size = len(envelope_json.encode("utf-8"))

        if envelope_size > PAYLOAD_LIMITS["task_envelope_hard"]:
            violations.append(
                GuardRailViolation(
                    rule="TASK_ENVELOPE_SIZE",
                    severity="ERROR",
                    message=f"Task envelope exceeds 200KB hard limit: {envelope_size} bytes",
                    details={
                        "envelope_size_bytes": envelope_size,
                        "limit_bytes": PAYLOAD_LIMITS["task_envelope_hard"],
                    },
                )
            )
            logger.error(f"Task envelope size violation: {envelope_size} bytes")

        # Check objective length
        objective_len = len(envelope.task.objective)

        if objective_len > PAYLOAD_LIMITS["task_objective_hard"]:
            violations.append(
                GuardRailViolation(
                    rule="TASK_OBJECTIVE_LENGTH",
                    severity="ERROR",
                    message=f"Objective exceeds 50,000 char hard limit: {objective_len} chars",
                    details={
                        "objective_length": objective_len,
                        "limit": PAYLOAD_LIMITS["task_objective_hard"],
                    },
                )
            )
        elif objective_len > PAYLOAD_LIMITS["task_objective_soft"]:
            warnings.append(
                GuardRailViolation(
                    rule="TASK_OBJECTIVE_LENGTH",
                    severity="WARNING",
                    message=f"Objective exceeds 40,000 char soft limit: {objective_len} chars",
                    details={
                        "objective_length": objective_len,
                        "soft_limit": PAYLOAD_LIMITS["task_objective_soft"],
                    },
                )
            )

        # Check input artifacts limit (hard: 100)
        num_inputs = len(envelope.task.inputs)
        if num_inputs > PAYLOAD_LIMITS["task_inputs_hard"]:
            violations.append(
                GuardRailViolation(
                    rule="TASK_INPUTS_LIMIT",
                    severity="ERROR",
                    message=f"Task inputs exceed 100 file limit: {num_inputs} files",
                    details={
                        "num_inputs": num_inputs,
                        "limit": PAYLOAD_LIMITS["task_inputs_hard"],
                    },
                )
            )

        # Check output artifacts limit (hard: 50)
        num_outputs = len(envelope.task.expected_outputs)
        if num_outputs > PAYLOAD_LIMITS["task_expected_outputs_hard"]:
            violations.append(
                GuardRailViolation(
                    rule="TASK_OUTPUTS_LIMIT",
                    severity="ERROR",
                    message=f"Expected outputs exceed 50 artifact limit: {num_outputs} artifacts",
                    details={
                        "num_outputs": num_outputs,
                        "limit": PAYLOAD_LIMITS["task_expected_outputs_hard"],
                    },
                )
            )

        # Check phases limit (soft: 10)
        num_phases = len(envelope.phases)
        if num_phases > PAYLOAD_LIMITS["phases_soft"]:
            warnings.append(
                GuardRailViolation(
                    rule="PHASES_LIMIT",
                    severity="WARNING",
                    message=f"Phases exceed 10 soft limit: {num_phases} phases",
                    details={
                        "num_phases": num_phases,
                        "soft_limit": PAYLOAD_LIMITS["phases_soft"],
                    },
                )
            )

        # Check checkpoints per phase (soft: 20)
        for phase in envelope.phases:
            num_checkpoints = len(phase.checkpoints)
            if num_checkpoints > PAYLOAD_LIMITS["checkpoints_per_phase_soft"]:
                warnings.append(
                    GuardRailViolation(
                        rule="CHECKPOINTS_PER_PHASE_LIMIT",
                        severity="WARNING",
                        message=f"Phase {phase.phase_id} exceeds 20 checkpoint soft limit: {num_checkpoints}",
                        details={
                            "phase_id": phase.phase_id,
                            "num_checkpoints": num_checkpoints,
                            "soft_limit": PAYLOAD_LIMITS["checkpoints_per_phase_soft"],
                        },
                    )
                )

        allowed = len(violations) == 0
        return GuardRailResult(
            allowed=allowed,
            violations=violations,
            warnings=warnings,
            effective_config={
                "envelope_size_bytes": envelope_size,
                "objective_length": objective_len,
                "num_inputs": num_inputs,
                "num_outputs": num_outputs,
                "num_phases": num_phases,
            },
        )

    def validate_response_envelope(
        self, response: ExecutorResponse, guard_rails: Optional[GuardRails]
    ) -> GuardRailResult:
        """Validate executor response against guard rails.

        Checks:
        - Response envelope size (hard: 500KB)
        - require_final_signal enforcement
        - require_minimal_report enforcement
        - Action count limit (soft: 200)

        Args:
            response: ExecutorResponse to validate.
            guard_rails: Guard rails configuration from task.

        Returns:
            GuardRailResult with validation outcome.
        """
        logger.debug(f"Validating response envelope: {response.task_id}")

        violations = []
        warnings = []

        # Check total response size (hard limit: 500KB)
        response_json = json.dumps(response.model_dump(mode="json"))
        response_size = len(response_json.encode("utf-8"))

        if response_size > PAYLOAD_LIMITS["response_envelope_hard"]:
            violations.append(
                GuardRailViolation(
                    rule="RESPONSE_ENVELOPE_SIZE",
                    severity="ERROR",
                    message=f"Response exceeds 500KB hard limit: {response_size} bytes",
                    details={
                        "response_size_bytes": response_size,
                        "limit_bytes": PAYLOAD_LIMITS["response_envelope_hard"],
                    },
                )
            )

        # Check guard rail requirements
        if guard_rails:
            # require_final_signal
            if guard_rails.require_final_signal:
                if not response.task_status or not response.task_status.final_signal:
                    violations.append(
                        GuardRailViolation(
                            rule="REQUIRE_FINAL_SIGNAL",
                            severity="ERROR",
                            message="Guard rail requires final_signal but it is missing",
                            details={"require_final_signal": True},
                        )
                    )

            # require_minimal_report
            if guard_rails.require_minimal_report:
                if not response.execution_summary.summary:
                    violations.append(
                        GuardRailViolation(
                            rule="REQUIRE_MINIMAL_REPORT",
                            severity="ERROR",
                            message="Guard rail requires summary but it is missing",
                            details={"require_minimal_report": True},
                        )
                    )
                if not response.execution_summary.actions:
                    violations.append(
                        GuardRailViolation(
                            rule="REQUIRE_MINIMAL_REPORT",
                            severity="ERROR",
                            message="Guard rail requires actions but it is missing",
                            details={"require_minimal_report": True},
                        )
                    )

        # Check actions limit (soft: 200)
        num_actions = len(response.execution_summary.actions)
        if num_actions > PAYLOAD_LIMITS["execution_actions_soft"]:
            warnings.append(
                GuardRailViolation(
                    rule="EXECUTION_ACTIONS_LIMIT",
                    severity="WARNING",
                    message=f"Actions exceed 200 soft limit: {num_actions} actions",
                    details={
                        "num_actions": num_actions,
                        "soft_limit": PAYLOAD_LIMITS["execution_actions_soft"],
                    },
                )
            )

        allowed = len(violations) == 0
        return GuardRailResult(
            allowed=allowed,
            violations=violations,
            warnings=warnings,
            effective_config={
                "response_size_bytes": response_size,
                "num_actions": num_actions,
            },
        )

    # === Policy Precedence ===

    def get_effective_timeout(
        self,
        guard_rails: Optional[GuardRails],
        execution_policy: Optional[dict[str, Any]],
    ) -> int:
        """Calculate effective timeout per contract precedence rules.

        Contract: If guard_rails.timeout_seconds is set, it overrides
        execution_policy.timeout_seconds. Otherwise use execution_policy.
        If neither set, return default.

        Args:
            guard_rails: Guard rails configuration.
            execution_policy: Execution policy configuration.

        Returns:
            Effective timeout in seconds.
        """
        default_timeout = 1800  # 30 minutes

        if guard_rails and guard_rails.timeout_seconds is not None:
            timeout = guard_rails.timeout_seconds
            logger.debug(f"Using guard_rails timeout: {timeout}s (precedence)")
            return timeout

        if execution_policy and execution_policy.get("timeout_seconds") is not None:
            timeout = execution_policy["timeout_seconds"]
            logger.debug(f"Using execution_policy timeout: {timeout}s")
            return timeout

        logger.debug(f"Using default timeout: {default_timeout}s")
        return default_timeout

    # === Access Control ===

    def compute_effective_access(
        self,
        target_capabilities: Optional[dict[str, Any]],
        task_access: Optional[dict[str, Any]],
    ) -> dict[str, Any]:
        """Compute effective access rules per contract precedence.

        Contract rules:
        - Filesystem: intersection of capabilities + task access
        - Network: most restrictive of capabilities and task access

        Args:
            target_capabilities: Target agent capabilities.
            task_access: Task access configuration.

        Returns:
            Effective access configuration.
        """
        logger.debug("Computing effective access rules")

        effective_access = {
            "filesystem": {"read_paths": [], "write_paths": []},
            "network": NetworkAccess.NONE,
        }

        # Filesystem access: intersection
        if target_capabilities and task_access:
            # If both specify filesystem, take intersection
            cap_fs = target_capabilities.get("filesystem", {})
            task_fs = task_access.get("filesystem", {})

            if cap_fs and task_fs:
                # Intersection of read paths
                cap_read = set(cap_fs.get("read_paths", []))
                task_read = set(task_fs.get("read_paths", []))
                effective_access["filesystem"]["read_paths"] = list(
                    cap_read & task_read
                )

                # Intersection of write paths
                cap_write = set(cap_fs.get("write_paths", []))
                task_write = set(task_fs.get("write_paths", []))
                effective_access["filesystem"]["write_paths"] = list(
                    cap_write & task_write
                )
            elif task_fs:
                # Only task specified
                effective_access["filesystem"] = task_fs
            elif cap_fs:
                # Only capabilities specified
                effective_access["filesystem"] = cap_fs

        # Network access: most restrictive
        cap_network = (
            target_capabilities.get("network_access", NetworkAccess.NONE)
            if target_capabilities
            else NetworkAccess.NONE
        )
        task_network = (
            task_access.get("network", NetworkAccess.NONE)
            if task_access
            else NetworkAccess.NONE
        )

        # Network access hierarchy: NONE < RESTRICTED < FULL
        network_levels = {
            NetworkAccess.NONE: 0,
            NetworkAccess.RESTRICTED: 1,
            NetworkAccess.FULL: 2,
        }

        cap_level = network_levels.get(cap_network, 0)
        task_level = network_levels.get(task_network, 0)

        effective_level = min(cap_level, task_level)
        effective_access["network"] = list(network_levels.keys())[effective_level]

        logger.debug(f"Effective access: {effective_access}")
        return effective_access

    def check_filesystem_access(
        self,
        requested_path: str,
        access_type: str,  # "read" or "write"
        effective_access: dict[str, Any],
    ) -> bool:
        """Check if filesystem access is allowed.

        Args:
            requested_path: Requested file path.
            access_type: Access type ("read" or "write").
            effective_access: Effective access configuration.

        Returns:
            True if access is allowed, False otherwise.

        Raises:
            AOPPermissionDeniedError: If access is denied.
        """
        logger.debug(f"Checking {access_type} access to: {requested_path}")

        allowed_paths = effective_access["filesystem"].get(f"{access_type}_paths", [])

        # Check if requested path starts with any allowed path
        for allowed_path in allowed_paths:
            if requested_path.startswith(allowed_path):
                logger.debug(f"Access allowed: {requested_path} matches {allowed_path}")
                return True

        logger.warning(f"Access denied: {requested_path} not in allowed paths")
        raise AOPPermissionDeniedError(
            message=f"Filesystem {access_type} access denied",
            details={
                "requested_path": requested_path,
                "access_type": access_type,
                "allowed_paths": allowed_paths,
            },
        )

    # === Cost Budget Enforcement ===

    def check_cost_budget(
        self,
        actual_cost_usd: float,
        max_cost_usd: Optional[float],
    ) -> None:
        """Check if actual cost exceeds budget.

        Args:
            actual_cost_usd: Actual cost incurred.
            max_cost_usd: Maximum allowed cost.

        Raises:
            AOPCostLimitExceededError: If cost exceeds budget.
        """
        if max_cost_usd is None:
            logger.debug("No cost budget specified, skipping check")
            return

        logger.debug(f"Checking cost: ${actual_cost_usd} vs budget ${max_cost_usd}")

        if actual_cost_usd > max_cost_usd:
            logger.error(f"Cost limit exceeded: ${actual_cost_usd} > ${max_cost_usd}")
            raise AOPCostLimitExceededError(
                message=f"Task cost ${actual_cost_usd} exceeds budget ${max_cost_usd}",
                details={
                    "actual_cost_usd": actual_cost_usd,
                    "max_cost_usd": max_cost_usd,
                },
            )

        logger.info(f"Cost within budget: ${actual_cost_usd} <= ${max_cost_usd}")

    # === Payload Size Checks ===

    def check_payload_size(
        self, payload_json: str, limit_bytes: int, payload_type: str
    ) -> None:
        """Check payload size against limit.

        Args:
            payload_json: JSON payload string.
            limit_bytes: Hard limit in bytes.
            payload_type: Payload type for error messages.

        Raises:
            AOPContextOverflowError: If payload exceeds hard limit.
        """
        size_bytes = len(payload_json.encode("utf-8"))
        logger.debug(f"Checking {payload_type} size: {size_bytes} bytes vs {limit_bytes}")

        if size_bytes > limit_bytes:
            logger.error(f"{payload_type} exceeds hard limit: {size_bytes} bytes")
            raise AOPContextOverflowError(
                message=f"{payload_type} exceeds {limit_bytes} byte limit",
                details={
                    "size_bytes": size_bytes,
                    "limit_bytes": limit_bytes,
                    "payload_type": payload_type,
                },
            )

    def emit_payload_size_warning(
        self, payload_json: str, soft_limit_bytes: int, payload_type: str
    ) -> None:
        """Emit warning for payload size approaching soft limit.

        Args:
            payload_json: JSON payload string.
            soft_limit_bytes: Soft limit in bytes.
            payload_type: Payload type for warning messages.
        """
        size_bytes = len(payload_json.encode("utf-8"))

        if size_bytes > soft_limit_bytes:
            logger.warning(
                f"{payload_type} exceeds soft limit: {size_bytes} bytes (soft: {soft_limit_bytes})"
            )
            # In production, this would emit a warning event
            # For now, just log it


# === Public API ===


def validate_task_envelope(envelope: OrchestrationEnvelope) -> GuardRailResult:
    """Validate task envelope against guard rails.

    Convenience function for one-shot validation.

    Args:
        envelope: OrchestrationEnvelope to validate.

    Returns:
        GuardRailResult with validation outcome.
    """
    engine = GuardRailEngine()
    return engine.validate_task_envelope(envelope)


def validate_response_envelope(
    response: ExecutorResponse, guard_rails: Optional[GuardRails]
) -> GuardRailResult:
    """Validate response envelope against guard rails.

    Convenience function for one-shot validation.

    Args:
        response: ExecutorResponse to validate.
        guard_rails: Guard rails configuration.

    Returns:
        GuardRailResult with validation outcome.
    """
    engine = GuardRailEngine()
    return engine.validate_response_envelope(response, guard_rails)


def compute_effective_access(
    target_capabilities: Optional[dict[str, Any]],
    task_access: Optional[dict[str, Any]],
) -> dict[str, Any]:
    """Compute effective access rules.

    Convenience function for one-shot computation.

    Args:
        target_capabilities: Target agent capabilities.
        task_access: Task access configuration.

    Returns:
        Effective access configuration.
    """
    engine = GuardRailEngine()
    return engine.compute_effective_access(target_capabilities, task_access)
