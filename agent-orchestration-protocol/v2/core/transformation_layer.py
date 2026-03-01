"""AOP v2 Transformation Layer.

Handles bidirectional transformation between AOP v2 and v1 protocols.

V1 → V2: Lifts v1 prompt-based tasks into v2 structured envelopes.
V2 → V1: Extracts task objective from v2 envelope for v1-only executors.
"""

import logging
from datetime import datetime, timezone
from typing import Any, Dict, Optional

from models import (
    Agent,
    AgentProvider,
    ExecutionSummary,
    ExecutorResponse,
    FinalSignal,
    OrchestrationEnvelope,
    Session,
    Target,
    Task,
    TaskCategory,
    TaskComplexity,
    TaskEnvironment,
    TaskPriority,
    TaskState,
    TaskStatus,
    Timing,
)

logger = logging.getLogger(__name__)


class TransformationLayer:
    """Bidirectional transformation between AOP v1 and v2.

    Provides lossless v2→v1 transformation for compatibility with v1-only
    executors, and best-effort v1→v2 lifting for structured orchestration.
    """

    def __init__(self) -> None:
        """Initialize transformation layer."""
        logger.info("Initializing TransformationLayer")

    # === V2 → V1 Transformation ===

    def v2_to_v1_prompt(self, envelope: OrchestrationEnvelope) -> str:
        """Transform v2 orchestration envelope to v1 prompt string.

        Extracts the task objective and converts structured fields into
        a human-readable prompt suitable for v1-only executors.

        Args:
            envelope: v2 OrchestrationEnvelope.

        Returns:
            v1-compatible prompt string.
        """
        logger.debug(f"Transforming v2 envelope to v1 prompt: {envelope.task.task_id}")

        prompt_parts = []

        # Header
        prompt_parts.append("=== TASK (AOP v1 Compatibility Mode) ===\n")

        # Task ID and metadata
        prompt_parts.append(f"Task ID: {envelope.task.task_id}")
        prompt_parts.append(f"Category: {envelope.task.category}")
        prompt_parts.append(f"Complexity: {envelope.task.complexity}")
        prompt_parts.append(f"Priority: {envelope.task.priority}\n")

        # Objective
        prompt_parts.append("## Objective")
        prompt_parts.append(envelope.task.objective + "\n")

        # Environment
        if envelope.task.environment:
            prompt_parts.append("## Environment")
            prompt_parts.append(
                f"Workspace: {envelope.task.environment.workspace_root}"
            )
            if envelope.task.environment.os:
                prompt_parts.append(f"OS: {envelope.task.environment.os}")
            if envelope.task.environment.shell:
                prompt_parts.append(f"Shell: {envelope.task.environment.shell}")
            if envelope.task.environment.git_branch:
                prompt_parts.append(f"Git Branch: {envelope.task.environment.git_branch}")
            prompt_parts.append("")

        # Inputs
        if envelope.task.inputs:
            prompt_parts.append("## Inputs")
            for idx, inp in enumerate(envelope.task.inputs, 1):
                if inp.path:
                    readonly_flag = " (read-only)" if inp.read_only else ""
                    prompt_parts.append(f"{idx}. {inp.type}: {inp.path}{readonly_flag}")
                elif inp.content:
                    prompt_parts.append(f"{idx}. {inp.type}: [inline content]")
            prompt_parts.append("")

        # Expected Outputs
        if envelope.task.expected_outputs:
            prompt_parts.append("## Expected Outputs")
            for idx, out in enumerate(envelope.task.expected_outputs, 1):
                prompt_parts.append(f"{idx}. {out.type}: {out.path or '[unspecified]'}")
                prompt_parts.append(f"   {out.description}")
            prompt_parts.append("")

        # Phases & Checkpoints
        if envelope.phases:
            prompt_parts.append("## Phases")
            for phase in envelope.phases:
                prompt_parts.append(f"\n### Phase {phase.phase_order}: {phase.label}")
                prompt_parts.append(f"Objective: {phase.objective}")
                if phase.checkpoints:
                    prompt_parts.append("Checkpoints:")
                    for cp in phase.checkpoints:
                        prompt_parts.append(f"  - {cp.checkpoint_id}: {cp.description}")
            prompt_parts.append("")

        # Constraints
        if envelope.task.budgets:
            prompt_parts.append("## Budgets")
            if envelope.task.budgets.max_cost_usd:
                prompt_parts.append(f"Max Cost: ${envelope.task.budgets.max_cost_usd}")
            if envelope.task.budgets.max_tokens:
                prompt_parts.append(f"Max Tokens: {envelope.task.budgets.max_tokens}")
            prompt_parts.append("")

        # Execution Policy
        if envelope.execution_policy:
            prompt_parts.append("## Execution Policy")
            prompt_parts.append(
                f"Timeout: {envelope.execution_policy.timeout_seconds}s"
            )
            prompt_parts.append(
                f"Max Retries: {envelope.execution_policy.max_retries}"
            )
            prompt_parts.append("")

        # Footer
        prompt_parts.append(
            "---\nNote: This task was transformed from AOP v2 for v1 compatibility."
        )

        prompt = "\n".join(prompt_parts)
        logger.info(f"Generated v1 prompt ({len(prompt)} chars)")
        return prompt

    def v2_envelope_to_v1_dict(
        self, envelope: OrchestrationEnvelope
    ) -> Dict[str, Any]:
        """Convert v2 envelope to v1-compatible dictionary.

        Useful for internal processing where structured access is needed
        but full v2 features are not supported.

        Args:
            envelope: v2 OrchestrationEnvelope.

        Returns:
            v1-compatible dictionary.
        """
        logger.debug(f"Converting v2 envelope to v1 dict: {envelope.task.task_id}")

        return {
            "type": "v1_task",
            "task_id": envelope.task.task_id,
            "objective": envelope.task.objective,
            "category": envelope.task.category,
            "complexity": envelope.task.complexity,
            "priority": envelope.task.priority,
            "workspace_root": envelope.task.environment.workspace_root,
            "inputs": [
                {"type": inp.type, "path": inp.path, "content": inp.content}
                for inp in envelope.task.inputs
            ],
            "expected_outputs": [
                {"type": out.type, "path": out.path, "description": out.description}
                for out in envelope.task.expected_outputs
            ],
            "timeout_seconds": (
                envelope.execution_policy.timeout_seconds
                if envelope.execution_policy
                else 1800
            ),
            "prompt": self.v2_to_v1_prompt(envelope),
        }

    # === V1 → V2 Transformation ===

    def v1_prompt_to_v2_envelope(
        self,
        v1_prompt: str,
        session_id: Optional[str] = None,
        orchestrator: str = "UnknownOrchestrator",
        target_agent: str = "UnknownExecutor",
        workspace_root: str = ".",
    ) -> OrchestrationEnvelope:
        """Lift v1 prompt into v2 orchestration envelope.

        This is a best-effort transformation. V1 prompts are unstructured,
        so we make reasonable assumptions about missing fields.

        Args:
            v1_prompt: v1 prompt string.
            session_id: Session ID (generated if not provided).
            orchestrator: Orchestrator name.
            target_agent: Target executor name.
            workspace_root: Workspace root directory.

        Returns:
            v2 OrchestrationEnvelope.
        """
        logger.debug(f"Lifting v1 prompt to v2 envelope ({len(v1_prompt)} chars)")

        # Generate IDs if needed
        if not session_id:
            session_id = f"AOP-SESSION-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}"

        task_id = f"TASK-V1-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}"

        # Create minimal v2 envelope
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id=session_id,
                created_at=datetime.now(timezone.utc),
                orchestrator=orchestrator,
                origin="V1_COMPAT",
            ),
            target=Target(
                agent_name=target_agent,
                role="EXECUTOR",
                provider=AgentProvider.OTHER,
                model="unknown",
            ),
            task=Task(
                task_id=task_id,
                objective=v1_prompt,
                category=TaskCategory.OTHER,
                complexity=TaskComplexity.MEDIUM,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root=workspace_root),
            ),
        )

        logger.info(f"Lifted v1 prompt to v2 envelope: {task_id}")
        return envelope

    def v1_response_to_v2(
        self,
        v1_response: str,
        task_id: str,
        session_id: str,
        agent_name: str,
        started_at: datetime,
        completed_at: datetime,
    ) -> ExecutorResponse:
        """Lift v1 response into v2 ExecutorResponse.

        V1 responses are free-form text. We package them into a minimal
        v2 response structure.

        Args:
            v1_response: v1 response string.
            task_id: Task ID.
            session_id: Session ID.
            agent_name: Executor agent name.
            started_at: Task start time.
            completed_at: Task completion time.

        Returns:
            v2 ExecutorResponse.
        """
        logger.debug(f"Lifting v1 response to v2 ({len(v1_response)} chars)")

        duration_seconds = int((completed_at - started_at).total_seconds())

        response = ExecutorResponse(
            session_id=session_id,
            task_id=task_id,
            agent=Agent(
                name=agent_name,
                provider=AgentProvider.OTHER,
                model="v1-compat",
            ),
            task_status=TaskStatus(
                state=TaskState.COMPLETED,
                final_signal=FinalSignal.SUCCESS,
                message="V1 task completed (lifted to v2)",
            ),
            execution_summary=ExecutionSummary(
                summary=v1_response[:500] + "..." if len(v1_response) > 500 else v1_response,
                actions=["Executed v1 task", "Generated free-form response"],
                output_artifacts=[],
            ),
            timing=Timing(
                started_at=started_at,
                completed_at=completed_at,
                duration_seconds=duration_seconds,
            ),
        )

        logger.info(f"Lifted v1 response to v2 for task {task_id}")
        return response

    # === Validation Helpers ===

    def is_v2_compatible(self, envelope: OrchestrationEnvelope) -> bool:
        """Check if v2 envelope is fully compatible (no degradation in v1).

        Some v2 features cannot be represented in v1:
        - Structured phases/checkpoints (approximated in text)
        - Extensions (lost in transformation)
        - Guard rails (lost in transformation)
        - Cost tracking (lost in transformation)

        Args:
            envelope: v2 OrchestrationEnvelope.

        Returns:
            True if envelope uses only v1-compatible features, False otherwise.
        """
        # Check for v2-only features
        has_guard_rails = envelope.guard_rails is not None
        has_extensions = envelope.extensions is not None
        has_phases = len(envelope.phases) > 0
        has_budgets = envelope.task.budgets is not None

        if has_guard_rails or has_extensions or has_phases or has_budgets:
            logger.warning(
                "V2 envelope contains features that will be lost in v1 transformation"
            )
            return False

        return True

    def estimate_transformation_loss(
        self, envelope: OrchestrationEnvelope
    ) -> Dict[str, Any]:
        """Estimate information loss in v2→v1 transformation.

        Args:
            envelope: v2 OrchestrationEnvelope.

        Returns:
            Dictionary describing lost features.
        """
        loss_report = {
            "guard_rails_lost": envelope.guard_rails is not None,
            "extensions_lost": envelope.extensions is not None,
            "phases_lost": len(envelope.phases) > 0,
            "budgets_lost": envelope.task.budgets is not None,
            "checkpoints_lost": sum(
                len(phase.checkpoints) for phase in envelope.phases
            ),
            "structured_access_lost": envelope.task.access is not None,
            "heartbeat_config_lost": (
                envelope.execution_policy.heartbeat is not None
                if envelope.execution_policy
                else False
            ),
        }

        total_loss = sum(1 for v in loss_report.values() if v is True or v > 0)
        loss_report["total_features_lost"] = total_loss

        logger.debug(f"Transformation loss report: {total_loss} features lost")
        return loss_report


# === Public API ===


def transform_v2_to_v1_prompt(envelope: OrchestrationEnvelope) -> str:
    """Transform v2 envelope to v1 prompt string.

    Convenience function for one-shot transformation.

    Args:
        envelope: v2 OrchestrationEnvelope.

    Returns:
        v1-compatible prompt string.
    """
    layer = TransformationLayer()
    return layer.v2_to_v1_prompt(envelope)


def transform_v1_to_v2_envelope(
    v1_prompt: str,
    session_id: Optional[str] = None,
    orchestrator: str = "UnknownOrchestrator",
    target_agent: str = "UnknownExecutor",
    workspace_root: str = ".",
) -> OrchestrationEnvelope:
    """Lift v1 prompt to v2 envelope.

    Convenience function for one-shot transformation.

    Args:
        v1_prompt: v1 prompt string.
        session_id: Session ID.
        orchestrator: Orchestrator name.
        target_agent: Target executor name.
        workspace_root: Workspace root directory.

    Returns:
        v2 OrchestrationEnvelope.
    """
    layer = TransformationLayer()
    return layer.v1_prompt_to_v2_envelope(
        v1_prompt, session_id, orchestrator, target_agent, workspace_root
    )
