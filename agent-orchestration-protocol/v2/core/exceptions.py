"""AOP v2 Exception Hierarchy.

This module defines the complete error taxonomy for the Agent Orchestration Protocol
v2.0.2-C as specified in the contract. Each exception maps to a canonical E_* error code.

All exceptions inherit from AOPError base class and include structured error details
for observability and debugging.
"""

from __future__ import annotations

from typing import Any, Optional


class AOPError(Exception):
    """Base exception for all AOP v2 errors.

    All AOP exceptions include:
    - error_code: Canonical E_* code from the contract
    - message: Human-readable description
    - details: Optional structured details for debugging
    """

    def __init__(
        self,
        error_code: str,
        message: str,
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        """Initialize AOP error.

        Args:
            error_code: Canonical E_* error code from contract.
            message: Human-readable error description.
            details: Optional structured details for debugging/observability.
        """
        super().__init__(message)
        self.error_code = error_code
        self.message = message
        self.details = details or {}

    def to_dict(self) -> dict[str, Any]:
        """Convert exception to structured dictionary.

        Returns:
            Dictionary with error_code, message, and details.
        """
        return {
            "error_code": self.error_code,
            "message": self.message,
            "details": self.details,
        }


# === Timeout & Heartbeat Errors ===


class AOPTimeoutError(AOPError):
    """Task exceeded configured timeout.

    Error Code: E_TIMEOUT
    """

    def __init__(
        self,
        message: str = "Task exceeded timeout",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_TIMEOUT", message, details)


class AOPHeartbeatFailureError(AOPError):
    """Executor missed maximum allowed heartbeat signals.

    Error Code: E_HEARTBEAT_FAILURE
    """

    def __init__(
        self,
        message: str = "Heartbeat failure detected",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_HEARTBEAT_FAILURE", message, details)


# === Parsing & Schema Errors ===


class AOPParseFailureError(AOPError):
    """Could not parse JSON or v1 markdown.

    Error Code: E_PARSE_FAILURE
    """

    def __init__(
        self,
        message: str = "Failed to parse input",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_PARSE_FAILURE", message, details)


class AOPSchemaValidationError(AOPError):
    """JSON parsed but failed v2 schema validation.

    Error Code: E_SCHEMA_VALIDATION
    """

    def __init__(
        self,
        message: str = "Schema validation failed",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_SCHEMA_VALIDATION", message, details)


# === Agent & Model Errors ===


class AOPAgentNotFoundError(AOPError):
    """Target agent is missing or unreachable.

    Error Code: E_AGENT_NOT_FOUND
    """

    def __init__(
        self,
        message: str = "Agent not found",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_AGENT_NOT_FOUND", message, details)


class AOPModelUnavailableError(AOPError):
    """Requested model is unavailable.

    Error Code: E_MODEL_UNAVAILABLE
    """

    def __init__(
        self,
        message: str = "Model unavailable",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_MODEL_UNAVAILABLE", message, details)


class AOPAllModelsExhaustedError(AOPError):
    """All alternative models failed.

    Error Code: E_ALL_MODELS_EXHAUSTED
    """

    def __init__(
        self,
        message: str = "All models exhausted",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_ALL_MODELS_EXHAUSTED", message, details)


# === File & Permission Errors ===


class AOPFileNotFoundError(AOPError):
    """Required input file is missing.

    Error Code: E_FILE_NOT_FOUND
    """

    def __init__(
        self,
        message: str = "File not found",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_FILE_NOT_FOUND", message, details)


class AOPPermissionDeniedError(AOPError):
    """Filesystem or network access not permitted.

    Error Code: E_PERMISSION_DENIED
    """

    def __init__(
        self,
        message: str = "Permission denied",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_PERMISSION_DENIED", message, details)


# === Payload & Context Errors ===


class AOPContextOverflowError(AOPError):
    """Exceeded hard payload size or context limits.

    Error Code: E_CONTEXT_OVERFLOW
    """

    def __init__(
        self,
        message: str = "Context overflow",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_CONTEXT_OVERFLOW", message, details)


class AOPPayloadSizeWarning(AOPError):
    """Exceeded soft payload size limit (warning only).

    Error Code: E_PAYLOAD_SIZE_WARNING
    """

    def __init__(
        self,
        message: str = "Payload size warning",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_PAYLOAD_SIZE_WARNING", message, details)


class AOPMalformedResponseError(AOPError):
    """Executor response failed schema validation.

    Error Code: E_MALFORMED_RESPONSE
    """

    def __init__(
        self,
        message: str = "Malformed response",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_MALFORMED_RESPONSE", message, details)


# === Dependency & Delegation Errors ===


class AOPDependencyFailedError(AOPError):
    """Dependency task/node aborted or failed.

    Error Code: E_DEPENDENCY_FAILED
    """

    def __init__(
        self,
        message: str = "Dependency failed",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_DEPENDENCY_FAILED", message, details)


class AOPMaxDepthExceededError(AOPError):
    """Delegation depth exceeded maximum (> 3).

    Error Code: E_MAX_DEPTH_EXCEEDED
    """

    def __init__(
        self,
        message: str = "Max delegation depth exceeded",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_MAX_DEPTH_EXCEEDED", message, details)


# === Process & Cost Errors ===


class AOPProcessCrashError(AOPError):
    """CLI process crashed or exited with non-zero code.

    Error Code: E_PROCESS_CRASH
    """

    def __init__(
        self,
        message: str = "Process crash",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_PROCESS_CRASH", message, details)


class AOPCostLimitExceededError(AOPError):
    """Task exceeded budget or max_cost_usd constraint.

    Error Code: E_COST_LIMIT_EXCEEDED
    """

    def __init__(
        self,
        message: str = "Cost limit exceeded",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_COST_LIMIT_EXCEEDED", message, details)


# === Rollback Errors ===


class AOPRollbackFailedError(AOPError):
    """Rollback operation failed.

    Error Code: E_ROLLBACK_FAILED
    """

    def __init__(
        self,
        message: str = "Rollback failed",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_ROLLBACK_FAILED", message, details)


# === Unknown Errors ===


class AOPUnknownError(AOPError):
    """Unknown or unclassified error.

    Error Code: E_UNKNOWN
    """

    def __init__(
        self,
        message: str = "Unknown error",
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__("E_UNKNOWN", message, details)


# === Error Code Registry ===

ERROR_CODE_MAP: dict[str, type[AOPError]] = {
    "E_TIMEOUT": AOPTimeoutError,
    "E_HEARTBEAT_FAILURE": AOPHeartbeatFailureError,
    "E_PARSE_FAILURE": AOPParseFailureError,
    "E_SCHEMA_VALIDATION": AOPSchemaValidationError,
    "E_AGENT_NOT_FOUND": AOPAgentNotFoundError,
    "E_MODEL_UNAVAILABLE": AOPModelUnavailableError,
    "E_ALL_MODELS_EXHAUSTED": AOPAllModelsExhaustedError,
    "E_FILE_NOT_FOUND": AOPFileNotFoundError,
    "E_PERMISSION_DENIED": AOPPermissionDeniedError,
    "E_CONTEXT_OVERFLOW": AOPContextOverflowError,
    "E_PAYLOAD_SIZE_WARNING": AOPPayloadSizeWarning,
    "E_MALFORMED_RESPONSE": AOPMalformedResponseError,
    "E_DEPENDENCY_FAILED": AOPDependencyFailedError,
    "E_MAX_DEPTH_EXCEEDED": AOPMaxDepthExceededError,
    "E_PROCESS_CRASH": AOPProcessCrashError,
    "E_COST_LIMIT_EXCEEDED": AOPCostLimitExceededError,
    "E_ROLLBACK_FAILED": AOPRollbackFailedError,
    "E_UNKNOWN": AOPUnknownError,
}


def get_exception_for_code(error_code: str) -> type[AOPError]:
    """Get exception class for given error code.

    Args:
        error_code: Canonical E_* error code.

    Returns:
        Exception class for the code, or AOPUnknownError if not found.
    """
    return ERROR_CODE_MAP.get(error_code, AOPUnknownError)
