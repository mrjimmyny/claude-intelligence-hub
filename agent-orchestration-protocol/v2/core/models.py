"""AOP v2 Pydantic Models.

Complete Pydantic v2 models for Agent Orchestration Protocol v2.0.2-C.
These models enforce the contract schema and can export to JSON Schema.

All models follow the contract strictly with no new required fields.
"""

from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Any, Literal, Optional

from pydantic import BaseModel, Field, field_validator, model_validator


# === Enums ===


class MessageType(str, Enum):
    """AOP message types."""

    TASK = "TASK"
    RESPONSE = "RESPONSE"
    EVENT = "EVENT"


class AgentRole(str, Enum):
    """Agent roles in AOP."""

    ORCHESTRATOR = "ORCHESTRATOR"
    EXECUTOR = "EXECUTOR"
    SPECIALIST = "SPECIALIST"


class AgentProvider(str, Enum):
    """LLM providers."""

    CLAUDE = "CLAUDE"
    CODEX = "CODEX"
    GEMINI = "GEMINI"
    LOCAL = "LOCAL"
    OTHER = "OTHER"


class TaskCategory(str, Enum):
    """Task categories."""

    ANALYSIS = "ANALYSIS"
    CODE_GENERATION = "CODE_GENERATION"
    CODE_REFACTORING = "CODE_REFACTORING"
    TESTING = "TESTING"
    DEBUGGING = "DEBUGGING"
    DOCUMENTATION = "DOCUMENTATION"
    PLANNING = "PLANNING"
    REVIEW = "REVIEW"
    OTHER = "OTHER"


class TaskComplexity(str, Enum):
    """Task complexity levels."""

    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class TaskPriority(str, Enum):
    """Task priority levels."""

    LOW = "LOW"
    NORMAL = "NORMAL"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class WorkflowPattern(str, Enum):
    """Workflow orchestration patterns."""

    SINGLE = "SINGLE"
    CHAIN = "CHAIN"
    PARALLEL = "PARALLEL"
    MAP_REDUCE = "MAP_REDUCE"
    HIERARCHICAL = "HIERARCHICAL"


class NetworkAccess(str, Enum):
    """Network access levels."""

    NONE = "NONE"
    RESTRICTED = "RESTRICTED"
    FULL = "FULL"


class ExecutionProfile(str, Enum):
    """Execution profiles for agents."""

    fast = "fast"
    balanced = "balanced"
    thorough = "thorough"


class TaskState(str, Enum):
    """Task execution states."""

    PENDING = "PENDING"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    ABORTED = "ABORTED"
    SKIPPED = "SKIPPED"


class FinalSignal(str, Enum):
    """Final task outcome signals."""

    SUCCESS = "SUCCESS"
    PARTIAL_SUCCESS = "PARTIAL_SUCCESS"
    FAILURE = "FAILURE"
    ABORTED = "ABORTED"


class CheckpointStatus(str, Enum):
    """Checkpoint validation status."""

    PENDING = "PENDING"
    PASS = "PASS"
    FAIL = "FAIL"
    SKIP = "SKIP"


class RecoveryStrategy(str, Enum):
    """Recovery strategies for checkpoint failures."""

    RETRY = "RETRY"
    ABORT = "ABORT"
    CONTINUE = "CONTINUE"


class ValidationExpectation(str, Enum):
    """Validation command expectations."""

    EXIT_CODE_0 = "EXIT_CODE_0"
    MATCH_FOUND = "MATCH_FOUND"
    NO_MATCH = "NO_MATCH"
    FILE_EXISTS = "FILE_EXISTS"


class SnapshotStrategy(str, Enum):
    """Rollback snapshot strategies."""

    COPY = "COPY"
    GIT_STASH = "GIT_STASH"
    DIFF = "DIFF"


class FallbackTrigger(str, Enum):
    """Model fallback triggers."""

    TIMEOUT = "TIMEOUT"
    FIRST_ERROR = "FIRST_ERROR"
    CRITICAL_ERROR = "CRITICAL_ERROR"
    ALL_ERRORS = "ALL_ERRORS"
    COST_LIMIT_EXCEEDED = "COST_LIMIT_EXCEEDED"


class HeartbeatAction(str, Enum):
    """Actions on heartbeat failure."""

    ABORT = "ABORT"
    WARN = "WARN"
    CONTINUE = "CONTINUE"


class OnFailureAction(str, Enum):
    """Actions on task failure."""

    REPORT_AND_CONTINUE = "REPORT_AND_CONTINUE"
    ABORT_SESSION = "ABORT_SESSION"
    RETRY = "RETRY"


class EventType(str, Enum):
    """AOP event types."""

    HEARTBEAT = "HEARTBEAT"
    PROGRESS_UPDATE = "PROGRESS_UPDATE"
    PRIORITY_ESCALATION = "PRIORITY_ESCALATION"
    ROLLBACK_INITIATED = "ROLLBACK_INITIATED"
    VERSION_FALLBACK = "VERSION_FALLBACK"
    SESSION_FINAL_REPORT = "SESSION_FINAL_REPORT"


class ArtifactStatus(str, Enum):
    """Output artifact status."""

    CREATED = "CREATED"
    UPDATED = "UPDATED"
    DELETED = "DELETED"
    UNCHANGED = "UNCHANGED"


# === Base Models ===


class AOPBaseModel(BaseModel):
    """Base model for all AOP objects with common config."""

    model_config = {
        "extra": "forbid",  # No additional properties
        "use_enum_values": True,
        "validate_assignment": True,
    }


class Extensions(AOPBaseModel):
    """Extensions object for vendor-specific data.

    All keys must start with 'x_' prefix.
    """

    model_config = {
        "extra": "allow",  # Allow x_* keys
    }

    @model_validator(mode="before")
    @classmethod
    def validate_extension_keys(cls, data: Any) -> Any:
        """Ensure all extension keys start with 'x_'."""
        if isinstance(data, dict):
            for key in data.keys():
                if not key.startswith("x_"):
                    raise ValueError(f"Extension key must start with 'x_': {key}")
        return data


# === Version Header ===


class VersionHeader(AOPBaseModel):
    """AOP version header (required in all messages)."""

    aop_version: str = Field(
        default="2.0.2-C",
        description="Protocol revision identifier",
    )
    schema_version: str = Field(
        default="2.0.2",
        description="Schema revision identifier",
    )
    protocol_family: Literal["AOP"] = Field(
        default="AOP",
        description="Protocol family identifier",
    )


# === Session Models ===


class Session(AOPBaseModel):
    """Session metadata."""

    session_id: str = Field(description="Unique session identifier")
    created_at: datetime = Field(description="Session creation timestamp")
    orchestrator: str = Field(description="Orchestrator agent name")
    origin: str = Field(description="Origin of the session (e.g., CLI, API)")
    workflow_pattern: Optional[WorkflowPattern] = Field(
        default=None,
        description="Workflow orchestration pattern",
    )
    extensions: Optional[Extensions] = None


# === Target Agent Models ===


class AgentCapabilities(AOPBaseModel):
    """Agent capabilities declaration."""

    aop_versions_supported: list[str] = Field(
        default_factory=lambda: ["2.0.2-C"],
        description="Supported AOP versions",
    )
    file_system_access: bool = Field(
        default=True,
        description="File system access capability",
    )
    network_access: NetworkAccess = Field(
        default=NetworkAccess.RESTRICTED,
        description="Network access level",
    )
    headless_mode: bool = Field(
        default=True,
        description="Can run without user interaction",
    )


class Target(AOPBaseModel):
    """Target agent specification."""

    agent_name: str = Field(description="Target agent name")
    role: AgentRole = Field(description="Agent role")
    provider: AgentProvider = Field(description="LLM provider")
    model: str = Field(description="Model identifier")
    execution_profile: Optional[ExecutionProfile] = Field(
        default=None,
        description="Execution profile preference",
    )
    capabilities: Optional[AgentCapabilities] = None
    extensions: Optional[Extensions] = None


# === Task Input/Output Models ===


class TaskInput(AOPBaseModel):
    """Task input specification."""

    type: str = Field(description="Input type (e.g., FILE, TEXT)")
    path: Optional[str] = Field(default=None, description="File path if type=FILE")
    content: Optional[str] = Field(default=None, description="Inline content")
    read_only: bool = Field(default=True, description="Read-only flag")


class Validation(AOPBaseModel):
    """Validation command specification."""

    command: str = Field(description="Validation command to execute")
    expects: ValidationExpectation = Field(description="Expected outcome")


class RollbackSnapshot(AOPBaseModel):
    """Rollback snapshot configuration."""

    enabled: bool = Field(default=False, description="Enable snapshot")
    snapshot_path: Optional[str] = Field(default=None, description="Snapshot file path")
    snapshot_strategy: Optional[SnapshotStrategy] = Field(
        default=None,
        description="Snapshot strategy",
    )


class ExpectedOutput(AOPBaseModel):
    """Expected output artifact specification."""

    type: str = Field(description="Output type (e.g., FILE, TEXT)")
    path: Optional[str] = Field(default=None, description="File path if type=FILE")
    description: str = Field(description="Output description")
    validation: Optional[Validation] = None
    rollback_snapshot: Optional[RollbackSnapshot] = None


# === Constraint & Access Models ===


class TaskConstraints(AOPBaseModel):
    """Task execution constraints (DEPRECATED - use budgets/access instead)."""

    max_tokens: Optional[int] = Field(default=None, description="Max token limit")
    max_cost_usd: Optional[float] = Field(default=None, description="Max cost in USD")
    read_only_mode: bool = Field(default=False, description="Read-only execution")
    delegation_allowed: bool = Field(
        default=False,
        description="Allow task delegation",
    )
    network_access: Optional[NetworkAccess] = Field(
        default=None,
        description="Network access level",
    )


class TaskBudgets(AOPBaseModel):
    """Task budget constraints."""

    max_cost_usd: Optional[float] = Field(default=None, description="Max cost in USD")
    max_tokens: Optional[int] = Field(default=None, description="Max token limit")


class FilesystemAccess(AOPBaseModel):
    """Filesystem access configuration."""

    read_paths: list[str] = Field(
        default_factory=list,
        description="Allowed read paths",
    )
    write_paths: list[str] = Field(
        default_factory=list,
        description="Allowed write paths",
    )


class TaskAccess(AOPBaseModel):
    """Task access configuration."""

    filesystem: Optional[FilesystemAccess] = None
    network: Optional[NetworkAccess] = Field(
        default=None,
        description="Network access level",
    )


# === Environment ===


class TaskEnvironment(AOPBaseModel):
    """Task execution environment."""

    workspace_root: str = Field(description="Workspace root directory")
    os: Optional[str] = Field(default=None, description="Operating system")
    shell: Optional[str] = Field(default=None, description="Shell type")
    git_branch: Optional[str] = Field(default=None, description="Git branch")


# === Checkpoint & Phase Models ===


class Checkpoint(AOPBaseModel):
    """Checkpoint specification."""

    checkpoint_id: str = Field(description="Unique checkpoint identifier")
    description: str = Field(description="Checkpoint description")
    expected_artifacts: list[ExpectedOutput] = Field(
        default_factory=list,
        description="Expected artifacts",
    )
    validation: Optional[Validation] = None
    status: CheckpointStatus = Field(
        default=CheckpointStatus.PENDING,
        description="Checkpoint status",
    )
    recovery_strategy: Optional[RecoveryStrategy] = Field(
        default=None,
        description="Recovery strategy on failure",
    )


class Phase(AOPBaseModel):
    """Task phase specification."""

    phase_id: str = Field(description="Unique phase identifier")
    phase_order: int = Field(description="Phase execution order")
    label: str = Field(description="Human-readable phase label")
    objective: str = Field(description="Phase objective")
    checkpoints: list[Checkpoint] = Field(
        default_factory=list,
        description="Phase checkpoints",
    )


# === Execution Policy ===


class AlternativeModel(AOPBaseModel):
    """Alternative model configuration for fallback."""

    provider: AgentProvider = Field(description="Provider name")
    model: str = Field(description="Model identifier")
    fallback_trigger: FallbackTrigger = Field(description="Fallback trigger condition")


class HeartbeatConfig(AOPBaseModel):
    """Heartbeat configuration."""

    enabled: bool = Field(default=False, description="Enable heartbeat")
    interval_seconds: int = Field(default=120, description="Heartbeat interval")
    max_missed_beats: int = Field(default=3, description="Max missed heartbeats")
    on_heartbeat_failure: HeartbeatAction = Field(
        default=HeartbeatAction.ABORT,
        description="Action on heartbeat failure",
    )


class ExecutionPolicy(AOPBaseModel):
    """Task execution policy."""

    timeout_seconds: int = Field(default=1800, description="Task timeout")
    max_retries: int = Field(default=0, description="Max retry attempts")
    retry_backoff_seconds: list[int] = Field(
        default_factory=lambda: [30, 120, 300],
        description="Retry backoff intervals",
    )
    abort_on_first_critical_error: bool = Field(
        default=False,
        description="Abort on first critical error",
    )
    auto_terminate_on_timeout: bool = Field(
        default=True,
        description="Auto-terminate on timeout",
    )
    on_failure: OnFailureAction = Field(
        default=OnFailureAction.REPORT_AND_CONTINUE,
        description="Action on task failure",
    )
    alternative_models: list[AlternativeModel] = Field(
        default_factory=list,
        description="Alternative models for fallback",
    )
    heartbeat: Optional[HeartbeatConfig] = None
    extensions: Optional[Extensions] = None


# === Guard Rails ===


class GuardRails(AOPBaseModel):
    """Guard rail configuration."""

    require_minimal_report: bool = Field(
        default=True,
        description="Require minimal execution report",
    )
    require_final_signal: bool = Field(
        default=True,
        description="Require final task signal",
    )
    auto_terminate_on_timeout: bool = Field(
        default=True,
        description="Auto-terminate on timeout",
    )
    timeout_seconds: Optional[int] = Field(
        default=None,
        description="Override timeout (takes precedence)",
    )
    abort_on_first_critical_error: bool = Field(
        default=False,
        description="Abort on first critical error",
    )
    extensions: Optional[Extensions] = None


# === Task Model ===


class Task(AOPBaseModel):
    """Core task specification."""

    task_id: str = Field(description="Unique task identifier")
    parent_task_id: Optional[str] = Field(
        default=None,
        description="Parent task ID for delegation",
    )
    attempt: int = Field(default=1, description="Attempt number")
    objective: str = Field(description="Task objective", max_length=50000)
    category: TaskCategory = Field(description="Task category")
    complexity: TaskComplexity = Field(description="Task complexity")
    priority: TaskPriority = Field(default=TaskPriority.NORMAL, description="Priority")
    environment: TaskEnvironment = Field(description="Execution environment")
    inputs: list[TaskInput] = Field(default_factory=list, description="Task inputs")
    expected_outputs: list[ExpectedOutput] = Field(
        default_factory=list,
        description="Expected outputs",
        max_length=50,
    )
    constraints: Optional[TaskConstraints] = Field(
        default=None,
        description="DEPRECATED - use budgets/access",
    )
    budgets: Optional[TaskBudgets] = None
    access: Optional[TaskAccess] = None
    extensions: Optional[Extensions] = None

    @field_validator("inputs")
    @classmethod
    def validate_inputs_limit(cls, v: list[TaskInput]) -> list[TaskInput]:
        """Enforce hard limit of 100 input files."""
        if len(v) > 100:
            raise ValueError("Task inputs cannot exceed 100 files")
        return v


# === Orchestration Metadata ===


class OrchestrationMetadata(AOPBaseModel):
    """Orchestration metadata."""

    initiator: Optional[str] = Field(default=None, description="Session initiator")
    spec_author: Optional[str] = Field(default=None, description="Spec author")
    tags: list[str] = Field(default_factory=list, description="Session tags")
    notes: Optional[str] = Field(default=None, description="Session notes")
    extensions: Optional[Extensions] = None


# === Orchestration Envelope (TASK Message) ===


class OrchestrationEnvelope(VersionHeader):
    """Complete AOP v2 orchestration envelope (TASK message).

    This is the primary message type sent from Orchestrator to Executor.
    """

    message_type: Literal[MessageType.TASK] = Field(
        default=MessageType.TASK,
        description="Message type",
    )
    session: Session = Field(description="Session metadata")
    target: Target = Field(description="Target agent specification")
    task: Task = Field(description="Task specification")
    execution_policy: Optional[ExecutionPolicy] = None
    guard_rails: Optional[GuardRails] = None
    phases: list[Phase] = Field(
        default_factory=list,
        description="Task phases",
        max_length=10,
    )
    orchestration_metadata: Optional[OrchestrationMetadata] = None
    extensions: Optional[Extensions] = None

    @model_validator(mode="after")
    def validate_envelope_size(self) -> "OrchestrationEnvelope":
        """Validate total envelope size (hard limit: 200KB)."""
        import json

        envelope_json = json.dumps(self.model_dump(mode="json"))
        size_bytes = len(envelope_json.encode("utf-8"))

        if size_bytes > 200_000:
            raise ValueError(
                f"TASK envelope exceeds 200KB limit: {size_bytes} bytes"
            )

        return self


# === Response Models ===


class Agent(AOPBaseModel):
    """Agent identification in response."""

    name: str = Field(description="Agent name")
    provider: AgentProvider = Field(description="Provider")
    model: str = Field(description="Model identifier")


class TaskStatus(AOPBaseModel):
    """Task status in response."""

    state: TaskState = Field(description="Task state")
    final_signal: FinalSignal = Field(description="Final outcome signal")
    message: str = Field(description="Status message")


class OutputArtifact(AOPBaseModel):
    """Output artifact metadata."""

    type: str = Field(description="Artifact type")
    path: str = Field(description="Artifact path")
    hash: Optional[str] = Field(default=None, description="Content hash (e.g., sha256)")
    status: ArtifactStatus = Field(description="Artifact status")
    size_bytes: Optional[int] = Field(default=None, description="File size in bytes")


class ExecutionSummary(AOPBaseModel):
    """Execution summary in response."""

    summary: str = Field(description="High-level summary")
    actions: list[str] = Field(
        description="List of actions taken",
        max_length=200,
    )
    output_artifacts: list[OutputArtifact] = Field(
        default_factory=list,
        description="Output artifacts produced",
    )
    warnings: list[str] = Field(default_factory=list, description="Warning messages")
    errors: list[str] = Field(default_factory=list, description="Error messages")
    extensions: Optional[Extensions] = None


class CheckpointResult(AOPBaseModel):
    """Checkpoint validation result."""

    checkpoint_id: str = Field(description="Checkpoint identifier")
    status: CheckpointStatus = Field(description="Validation status")
    validation_output: Optional[str] = Field(
        default=None,
        description="Validation command output",
    )
    evidence: list[str] = Field(
        default_factory=list,
        description="Evidence of validation",
    )
    notes: Optional[str] = Field(default=None, description="Additional notes")


class ErrorDetails(AOPBaseModel):
    """Structured error details."""

    error_code: str = Field(description="Error code (E_*)")
    message: str = Field(description="Error message")
    stack_trace: Optional[str] = Field(default=None, description="Stack trace")
    recovery_suggestions: list[str] = Field(
        default_factory=list,
        description="Recovery suggestions",
    )


class Timing(AOPBaseModel):
    """Task timing information."""

    started_at: datetime = Field(description="Task start timestamp")
    completed_at: datetime = Field(description="Task completion timestamp")
    duration_seconds: int = Field(description="Duration in seconds")
    retries_attempted: int = Field(default=0, description="Number of retries")


class CostTracking(AOPBaseModel):
    """Cost tracking information."""

    estimated_cost_usd: Optional[float] = Field(
        default=None,
        description="Estimated cost",
    )
    actual_cost_usd: Optional[float] = Field(default=None, description="Actual cost")
    tokens_input: Optional[int] = Field(default=None, description="Input tokens")
    tokens_output: Optional[int] = Field(default=None, description="Output tokens")
    model_pricing_tier: Optional[str] = Field(
        default=None,
        description="Pricing tier",
    )


class ProgressLog(AOPBaseModel):
    """Progress log summary."""

    last_progress_event_at: Optional[datetime] = Field(
        default=None,
        description="Last progress event timestamp",
    )
    progress_percentage: Optional[int] = Field(
        default=None,
        description="Progress percentage (0-100)",
        ge=0,
        le=100,
    )


# === Executor Response (RESPONSE Message) ===


class ExecutorResponse(VersionHeader):
    """Complete AOP v2 executor response (RESPONSE message).

    This is the primary message type returned from Executor to Orchestrator.
    """

    message_type: Literal[MessageType.RESPONSE] = Field(
        default=MessageType.RESPONSE,
        description="Message type",
    )
    session_id: str = Field(description="Session identifier")
    task_id: str = Field(description="Task identifier")
    agent: Agent = Field(description="Executor agent identification")
    task_status: TaskStatus = Field(description="Task status")
    execution_summary: ExecutionSummary = Field(description="Execution summary")
    checkpoint_results: list[CheckpointResult] = Field(
        default_factory=list,
        description="Checkpoint results",
    )
    error_details: Optional[ErrorDetails] = None
    timing: Timing = Field(description="Timing information")
    cost_tracking: Optional[CostTracking] = None
    progress_log: Optional[ProgressLog] = None
    extensions: Optional[Extensions] = None

    @model_validator(mode="after")
    def validate_response_size(self) -> "ExecutorResponse":
        """Validate total response size (hard limit: 500KB)."""
        import json

        response_json = json.dumps(self.model_dump(mode="json"))
        size_bytes = len(response_json.encode("utf-8"))

        if size_bytes > 500_000:
            raise ValueError(
                f"RESPONSE envelope exceeds 500KB limit: {size_bytes} bytes"
            )

        return self

    @model_validator(mode="after")
    def validate_guard_rails(self) -> "ExecutorResponse":
        """Validate guard rail requirements if present.

        Note: Guard rails are passed in the TASK envelope, not the RESPONSE.
        This validation assumes they were enforced during execution.
        """
        # Validate require_final_signal
        if not self.task_status or not self.task_status.final_signal:
            raise ValueError("require_final_signal: final_signal is required")

        # Validate require_minimal_report
        if not self.execution_summary.summary or not self.execution_summary.actions:
            raise ValueError(
                "require_minimal_report: summary and actions are required"
            )

        return self


# === Event Models ===


class HeartbeatEvent(VersionHeader):
    """Heartbeat event."""

    message_type: Literal[MessageType.EVENT] = MessageType.EVENT
    event: Literal[EventType.HEARTBEAT] = EventType.HEARTBEAT
    session_id: str = Field(description="Session identifier")
    task_id: str = Field(description="Task identifier")
    timestamp: datetime = Field(description="Event timestamp")
    agent: str = Field(description="Agent name")
    progress_percentage: Optional[int] = Field(
        default=None,
        description="Progress percentage",
        ge=0,
        le=100,
    )
    current_phase: Optional[str] = Field(default=None, description="Current phase ID")
    current_checkpoint: Optional[str] = Field(
        default=None,
        description="Current checkpoint ID",
    )


class ProgressUpdate(AOPBaseModel):
    """Progress update details."""

    percentage: int = Field(description="Progress percentage", ge=0, le=100)
    current_phase: Optional[str] = Field(default=None, description="Current phase ID")
    current_checkpoint: Optional[str] = Field(
        default=None,
        description="Current checkpoint ID",
    )
    message: str = Field(description="Progress message")
    estimated_time_remaining_seconds: Optional[int] = Field(
        default=None,
        description="Estimated time remaining",
    )


class ProgressUpdateEvent(VersionHeader):
    """Progress update event."""

    message_type: Literal[MessageType.EVENT] = MessageType.EVENT
    event: Literal[EventType.PROGRESS_UPDATE] = EventType.PROGRESS_UPDATE
    session_id: str = Field(description="Session identifier")
    task_id: str = Field(description="Task identifier")
    timestamp: datetime = Field(description="Event timestamp")
    agent: str = Field(description="Agent name")
    progress: ProgressUpdate = Field(description="Progress details")


class PriorityEscalationEvent(VersionHeader):
    """Priority escalation event."""

    message_type: Literal[MessageType.EVENT] = MessageType.EVENT
    event: Literal[EventType.PRIORITY_ESCALATION] = EventType.PRIORITY_ESCALATION
    session_id: str = Field(description="Session identifier")
    task_id: str = Field(description="Task identifier")
    timestamp: datetime = Field(description="Event timestamp")
    old_priority: TaskPriority = Field(description="Previous priority")
    new_priority: TaskPriority = Field(description="New priority")
    reason: str = Field(description="Escalation reason")
    escalated_by: str = Field(description="Who escalated")


class RollbackArtifact(AOPBaseModel):
    """Rolled-back artifact details."""

    path: str = Field(description="Artifact path")
    restored_from: str = Field(description="Snapshot path")
    status: str = Field(description="Rollback status (SUCCESS/FAILED)")


class RollbackInitiatedEvent(VersionHeader):
    """Rollback initiated event."""

    message_type: Literal[MessageType.EVENT] = MessageType.EVENT
    event: Literal[EventType.ROLLBACK_INITIATED] = EventType.ROLLBACK_INITIATED
    session_id: str = Field(description="Session identifier")
    task_id: str = Field(description="Task identifier")
    timestamp: datetime = Field(description="Event timestamp")
    trigger: str = Field(description="Rollback trigger reason")
    artifacts_rolled_back: list[RollbackArtifact] = Field(
        description="Rolled-back artifacts"
    )
