"""AOP v2 Version Router.

Handles version detection, routing, and fallback between AOP v2 and v1 protocols.
Implements the version detection pipeline from the contract:

1. Try JSON parse
2. If parsed and aop_version starts with "2." → validate as v2
3. If parsed and aop_version missing → attempt v1 markdown detection
4. If neither → classify as UNSTRUCTURED

On schema failure, emit VERSION_FALLBACK event and transform to v1 prompt.
"""

from __future__ import annotations

import json
import logging
from enum import Enum
from typing import Any, Optional, Union

from pydantic import ValidationError

from exceptions import AOPParseFailureError, AOPSchemaValidationError
from models import ExecutorResponse, OrchestrationEnvelope

logger = logging.getLogger(__name__)


class ProtocolVersion(str, Enum):
    """Detected protocol versions."""

    V2 = "v2"
    V1 = "v1"
    UNSTRUCTURED = "unstructured"


class VersionDetectionResult:
    """Result of version detection.

    Attributes:
        version: Detected protocol version.
        parsed_data: Parsed data if successful (v2 model or v1 dict).
        raw_input: Original raw input string.
        error: Parse/validation error if any.
        fallback_triggered: Whether v1 fallback was triggered.
    """

    def __init__(
        self,
        version: ProtocolVersion,
        raw_input: str,
        parsed_data: Optional[Union[OrchestrationEnvelope, dict[str, Any]]] = None,
        error: Optional[Exception] = None,
        fallback_triggered: bool = False,
    ) -> None:
        """Initialize version detection result.

        Args:
            version: Detected protocol version.
            raw_input: Original raw input string.
            parsed_data: Parsed data if successful.
            error: Parse/validation error if any.
            fallback_triggered: Whether v1 fallback was triggered.
        """
        self.version = version
        self.raw_input = raw_input
        self.parsed_data = parsed_data
        self.error = error
        self.fallback_triggered = fallback_triggered


class VersionRouter:
    """AOP version detection and routing engine.

    Implements the contract-specified detection pipeline and provides
    routing decisions for multi-version orchestration.
    """

    def __init__(self) -> None:
        """Initialize version router."""
        logger.info("Initializing VersionRouter")

    def detect_version(self, raw_input: str) -> VersionDetectionResult:
        """Detect AOP protocol version from raw input.

        Implements the contract pipeline:
        1. Try JSON parse
        2. Check aop_version field
        3. Fallback to v1 detection
        4. Classify as unstructured

        Args:
            raw_input: Raw input string (JSON or text).

        Returns:
            VersionDetectionResult with detection details.
        """
        logger.debug(f"Detecting version for input ({len(raw_input)} chars)")

        # Step 1: Try JSON parse
        try:
            parsed_json = json.loads(raw_input)
            logger.debug("Successfully parsed JSON")
        except json.JSONDecodeError as e:
            logger.info(f"JSON parse failed: {e}")
            # Not JSON → attempt v1 markdown detection
            return self._detect_v1_or_unstructured(raw_input)

        # Step 2: Check aop_version field
        aop_version = parsed_json.get("aop_version")

        if aop_version and isinstance(aop_version, str):
            if aop_version.startswith("2."):
                logger.info(f"Detected AOP v2: {aop_version}")
                return self._validate_v2(parsed_json, raw_input)
            else:
                logger.warning(f"Unknown aop_version: {aop_version}")
                # Unknown version → attempt v1 fallback
                return self._detect_v1_or_unstructured(raw_input)

        # Step 3: Missing aop_version → attempt v1 markdown detection
        logger.info("Missing aop_version field, attempting v1 detection")
        return self._detect_v1_or_unstructured(raw_input)

    def _validate_v2(
        self, parsed_json: dict[str, Any], raw_input: str
    ) -> VersionDetectionResult:
        """Validate v2 JSON against Pydantic schema.

        Args:
            parsed_json: Parsed JSON dictionary.
            raw_input: Original raw input.

        Returns:
            VersionDetectionResult with v2 envelope or fallback.
        """
        try:
            envelope = OrchestrationEnvelope.model_validate(parsed_json)
            logger.info("Successfully validated v2 envelope")
            return VersionDetectionResult(
                version=ProtocolVersion.V2,
                raw_input=raw_input,
                parsed_data=envelope,
            )
        except ValidationError as e:
            logger.error(f"V2 schema validation failed: {e}")
            # Schema failure → emit VERSION_FALLBACK event and transform to v1
            self._emit_version_fallback_event(raw_input, str(e))

            return VersionDetectionResult(
                version=ProtocolVersion.V1,
                raw_input=raw_input,
                parsed_data=None,
                error=AOPSchemaValidationError(
                    message="V2 schema validation failed",
                    details={"validation_error": str(e)},
                ),
                fallback_triggered=True,
            )

    def _detect_v1_or_unstructured(self, raw_input: str) -> VersionDetectionResult:
        """Detect v1 markdown or classify as unstructured.

        V1 detection heuristics:
        - Contains markdown-like patterns
        - Has "task:", "objective:", or similar v1 keywords
        - Plain text without clear structure → v1 prompt-based

        Args:
            raw_input: Raw input string.

        Returns:
            VersionDetectionResult with v1 or unstructured classification.
        """
        # V1 heuristics
        v1_keywords = [
            "task:",
            "objective:",
            "agent:",
            "executor:",
            "context:",
            "requirements:",
        ]

        lowercased = raw_input.lower()
        if any(keyword in lowercased for keyword in v1_keywords):
            logger.info("Detected v1 prompt-based format")
            return VersionDetectionResult(
                version=ProtocolVersion.V1,
                raw_input=raw_input,
                parsed_data={"type": "v1_prompt", "content": raw_input},
            )

        # Fallback: treat as unstructured
        logger.info("Classified as unstructured input")
        return VersionDetectionResult(
            version=ProtocolVersion.UNSTRUCTURED,
            raw_input=raw_input,
        )

    def _emit_version_fallback_event(
        self, raw_input: str, validation_error: str
    ) -> None:
        """Emit VERSION_FALLBACK event for observability.

        Args:
            raw_input: Original input that failed validation.
            validation_error: Validation error message.
        """
        logger.warning(
            f"Emitting VERSION_FALLBACK event due to schema failure: {validation_error[:100]}"
        )
        # In production, this would emit an event to the event bus
        # For now, just log it
        event = {
            "event": "VERSION_FALLBACK",
            "reason": "V2_SCHEMA_VALIDATION_FAILED",
            "validation_error": validation_error,
            "input_preview": raw_input[:200],
        }
        logger.info(f"VERSION_FALLBACK event: {json.dumps(event, indent=2)}")

    def route_task(
        self, detection_result: VersionDetectionResult
    ) -> dict[str, Any]:
        """Route task based on detected version.

        Provides routing metadata for orchestration decisions:
        - Which executor to use
        - Whether transformation is needed
        - Fallback recommendations

        Args:
            detection_result: Version detection result.

        Returns:
            Routing metadata dictionary.
        """
        logger.debug(f"Routing task for version: {detection_result.version}")

        if detection_result.version == ProtocolVersion.V2:
            return {
                "version": "v2",
                "use_v2_executor": True,
                "transformation_needed": False,
                "fallback_available": True,
                "parsed_envelope": detection_result.parsed_data,
            }

        elif detection_result.version == ProtocolVersion.V1:
            return {
                "version": "v1",
                "use_v2_executor": False,
                "transformation_needed": True,
                "fallback_available": False,
                "raw_prompt": detection_result.raw_input,
                "fallback_triggered": detection_result.fallback_triggered,
            }

        else:  # UNSTRUCTURED
            return {
                "version": "unstructured",
                "use_v2_executor": False,
                "transformation_needed": True,
                "fallback_available": False,
                "raw_input": detection_result.raw_input,
                "warning": "Unstructured input may require manual interpretation",
            }

    def validate_response(
        self, raw_response: str, expected_version: ProtocolVersion
    ) -> Union[ExecutorResponse, dict[str, Any]]:
        """Validate executor response against expected version.

        Args:
            raw_response: Raw response string from executor.
            expected_version: Expected protocol version.

        Returns:
            Validated ExecutorResponse (v2) or dict (v1).

        Raises:
            AOPSchemaValidationError: If validation fails.
        """
        logger.debug(
            f"Validating response for version: {expected_version} ({len(raw_response)} chars)"
        )

        if expected_version == ProtocolVersion.V2:
            try:
                parsed_json = json.loads(raw_response)
                response = ExecutorResponse.model_validate(parsed_json)
                logger.info("Successfully validated v2 response")
                return response
            except json.JSONDecodeError as e:
                logger.error(f"Response JSON parse failed: {e}")
                raise AOPParseFailureError(
                    message="Failed to parse response JSON",
                    details={"error": str(e)},
                )
            except ValidationError as e:
                logger.error(f"Response v2 schema validation failed: {e}")
                raise AOPSchemaValidationError(
                    message="Response schema validation failed",
                    details={"validation_error": str(e)},
                )

        else:  # V1 or UNSTRUCTURED
            # V1 responses are free-form text
            logger.info("Treating response as v1 free-form text")
            return {
                "type": "v1_response",
                "content": raw_response,
            }

    def supports_v2(self, agent_capabilities: dict[str, Any]) -> bool:
        """Check if agent supports AOP v2.

        Args:
            agent_capabilities: Agent capabilities dictionary.

        Returns:
            True if agent supports v2, False otherwise.
        """
        supported_versions = agent_capabilities.get("aop_versions_supported", [])
        return any(v.startswith("2.") for v in supported_versions)

    def get_effective_timeout(
        self, guard_rails: Optional[dict[str, Any]], execution_policy: Optional[dict[str, Any]]
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

        if guard_rails and guard_rails.get("timeout_seconds") is not None:
            timeout = guard_rails["timeout_seconds"]
            logger.debug(f"Using guard_rails timeout: {timeout}s")
            return timeout

        if execution_policy and execution_policy.get("timeout_seconds") is not None:
            timeout = execution_policy["timeout_seconds"]
            logger.debug(f"Using execution_policy timeout: {timeout}s")
            return timeout

        logger.debug(f"Using default timeout: {default_timeout}s")
        return default_timeout


# === Public API ===


def detect_protocol_version(raw_input: str) -> VersionDetectionResult:
    """Detect AOP protocol version from raw input.

    Convenience function for one-shot detection.

    Args:
        raw_input: Raw input string.

    Returns:
        VersionDetectionResult with detection details.
    """
    router = VersionRouter()
    return router.detect_version(raw_input)


def route_to_executor(raw_input: str) -> dict[str, Any]:
    """Detect version and route to appropriate executor.

    Convenience function combining detection and routing.

    Args:
        raw_input: Raw input string.

    Returns:
        Routing metadata dictionary.
    """
    router = VersionRouter()
    detection = router.detect_version(raw_input)
    return router.route_task(detection)
