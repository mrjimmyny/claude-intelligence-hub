"""Test Suite for AOP v2 Transformation Layer (Milestone 3 - Refinement Sprint).

Tests bidirectional transformation between V2 and V1 protocols.

Test Coverage:
- V2 → V1 prompt transformation (happy path, edge cases)
- V2 → V1 dict transformation
- V1 → V2 envelope lifting
- V1 → V2 response lifting
- Compatibility checks (is_v2_compatible)
- Transformation loss estimation
- Convenience API functions

Author: Magneto
Date: 2026-02-28
Contract: 03_contract-aop-v2-ciclope-final.md (v2.0.2-C)
"""

import sys
import os
from datetime import datetime, timezone

import pytest

# Add v2/core to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'core'))

from transformation_layer import (
    TransformationLayer,
    transform_v2_to_v1_prompt,
    transform_v1_to_v2_envelope,
)
from models import (
    OrchestrationEnvelope,
    Session,
    Target,
    Task,
    TaskEnvironment,
    TaskInput,
    ExpectedOutput,
    TaskBudgets,
    ExecutionPolicy,
    GuardRails,
    Phase,
    Checkpoint,
    AgentProvider,
    TaskCategory,
    TaskComplexity,
    TaskPriority,
    Agent,
    FinalSignal,
)


class TestV2ToV1Transformation:
    """Test V2 → V1 transformation logic."""

    def setup_method(self):
        """Initialize transformation layer before each test."""
        self.layer = TransformationLayer()

    def test_v2_to_v1_prompt_minimal_envelope(self):
        """Test V2 → V1 prompt with minimal envelope."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-001",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-001",
                objective="Test minimal transformation",
                category=TaskCategory.ANALYSIS,
                complexity=TaskComplexity.LOW,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
            ),
        )

        prompt = self.layer.v2_to_v1_prompt(envelope)

        # Assertions
        assert "TASK (AOP v1 Compatibility Mode)" in prompt
        assert "TASK-001" in prompt
        assert "Test minimal transformation" in prompt
        assert "Category: ANALYSIS" in prompt
        assert "Complexity: LOW" in prompt
        assert "C:/ai/test" in prompt

    def test_v2_to_v1_prompt_with_inputs_outputs(self):
        """Test V2 → V1 prompt with inputs and expected outputs."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-002",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-002",
                objective="Test with inputs and outputs",
                category=TaskCategory.CODE_GENERATION,
                complexity=TaskComplexity.MEDIUM,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(
                    workspace_root="C:/ai/test",
                    os="Windows",
                    shell="PowerShell",
                    git_branch="main",
                ),
                inputs=[
                    TaskInput(
                        type="FILE",
                        path="input.txt",
                        read_only=True,
                    ),
                    TaskInput(
                        type="FILE",
                        path="config.yaml",
                        read_only=False,
                    ),
                ],
                expected_outputs=[
                    ExpectedOutput(
                        type="FILE",
                        path="output.json",
                        description="Generated output file",
                    ),
                ],
            ),
        )

        prompt = self.layer.v2_to_v1_prompt(envelope)

        # Assertions
        assert "## Inputs" in prompt
        assert "input.txt" in prompt
        assert "(read-only)" in prompt
        assert "config.yaml" in prompt
        assert "## Expected Outputs" in prompt
        assert "output.json" in prompt
        assert "Generated output file" in prompt
        assert "OS: Windows" in prompt
        assert "Shell: PowerShell" in prompt
        assert "Git Branch: main" in prompt

    def test_v2_to_v1_prompt_with_budgets_and_policy(self):
        """Test V2 → V1 prompt with budgets and execution policy."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-003",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-003",
                objective="Test with budgets and policy",
                category=TaskCategory.ANALYSIS,
                complexity=TaskComplexity.LOW,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
                budgets=TaskBudgets(
                    max_cost_usd=5.0,
                    max_tokens=100000,
                ),
            ),
            execution_policy=ExecutionPolicy(
                timeout_seconds=600,
                max_retries=3,
            ),
        )

        prompt = self.layer.v2_to_v1_prompt(envelope)

        # Assertions
        assert "## Budgets" in prompt
        assert "$5.0" in prompt
        assert "100000" in prompt
        assert "## Execution Policy" in prompt
        assert "600s" in prompt
        assert "Max Retries: 3" in prompt

    def test_v2_to_v1_prompt_with_phases(self):
        """Test V2 → V1 prompt with phases and checkpoints."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-004",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-004",
                objective="Test with phases",
                category=TaskCategory.CODE_GENERATION,
                complexity=TaskComplexity.HIGH,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
            ),
            phases=[
                Phase(
                    phase_id="PHASE-001",
                    phase_order=1,
                    label="Analysis",
                    objective="Analyze requirements",
                    checkpoints=[
                        Checkpoint(
                            checkpoint_id="CP-001",
                            description="Requirements analyzed",
                        ),
                    ],
                ),
                Phase(
                    phase_id="PHASE-002",
                    phase_order=2,
                    label="Implementation",
                    objective="Implement solution",
                    checkpoints=[
                        Checkpoint(
                            checkpoint_id="CP-002",
                            description="Code written",
                        ),
                        Checkpoint(
                            checkpoint_id="CP-003",
                            description="Tests passing",
                        ),
                    ],
                ),
            ],
        )

        prompt = self.layer.v2_to_v1_prompt(envelope)

        # Assertions
        assert "## Phases" in prompt
        assert "Phase 1: Analysis" in prompt
        assert "Analyze requirements" in prompt
        assert "CP-001" in prompt
        assert "Requirements analyzed" in prompt
        assert "Phase 2: Implementation" in prompt
        assert "Implement solution" in prompt
        assert "CP-002" in prompt
        assert "CP-003" in prompt


class TestV2ToV1DictConversion:
    """Test V2 → V1 dict conversion."""

    def setup_method(self):
        """Initialize transformation layer before each test."""
        self.layer = TransformationLayer()

    def test_v2_envelope_to_v1_dict(self):
        """Test V2 envelope to V1 dict conversion."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-005",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-005",
                objective="Test dict conversion",
                category=TaskCategory.ANALYSIS,
                complexity=TaskComplexity.LOW,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
                inputs=[
                    TaskInput(type="FILE", path="input.txt", read_only=True),
                ],
                expected_outputs=[
                    ExpectedOutput(
                        type="FILE",
                        path="output.txt",
                        description="Output file",
                    ),
                ],
            ),
            execution_policy=ExecutionPolicy(timeout_seconds=1200),
        )

        v1_dict = self.layer.v2_envelope_to_v1_dict(envelope)

        # Assertions
        assert v1_dict["type"] == "v1_task"
        assert v1_dict["task_id"] == "TASK-005"
        assert v1_dict["objective"] == "Test dict conversion"
        assert v1_dict["category"] == "ANALYSIS"
        assert v1_dict["complexity"] == "LOW"
        assert v1_dict["priority"] == "NORMAL"
        assert v1_dict["workspace_root"] == "C:/ai/test"
        assert len(v1_dict["inputs"]) == 1
        assert v1_dict["inputs"][0]["path"] == "input.txt"
        assert len(v1_dict["expected_outputs"]) == 1
        assert v1_dict["expected_outputs"][0]["path"] == "output.txt"
        assert v1_dict["timeout_seconds"] == 1200
        assert "prompt" in v1_dict  # Should contain generated prompt

    def test_v2_envelope_to_v1_dict_default_timeout(self):
        """Test V2 envelope to V1 dict with default timeout."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-006",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-006",
                objective="Test default timeout",
                category=TaskCategory.ANALYSIS,
                complexity=TaskComplexity.LOW,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
            ),
            # No execution_policy specified
        )

        v1_dict = self.layer.v2_envelope_to_v1_dict(envelope)

        # Should use default timeout of 1800 seconds (30 minutes)
        assert v1_dict["timeout_seconds"] == 1800


class TestV1ToV2Transformation:
    """Test V1 → V2 transformation logic."""

    def setup_method(self):
        """Initialize transformation layer before each test."""
        self.layer = TransformationLayer()

    def test_v1_prompt_to_v2_envelope_basic(self):
        """Test V1 prompt to V2 envelope lifting (basic)."""
        v1_prompt = "Please analyze the codebase and generate a report."

        envelope = self.layer.v1_prompt_to_v2_envelope(v1_prompt)

        # Assertions
        assert envelope.aop_version == "2.0.2-C"
        assert envelope.schema_version == "2.0.2"
        assert envelope.message_type == "TASK"
        assert envelope.session.origin == "V1_COMPAT"
        assert envelope.target.role == "EXECUTOR"
        assert envelope.target.provider == AgentProvider.OTHER
        assert envelope.task.objective == v1_prompt
        assert envelope.task.category == TaskCategory.OTHER
        assert envelope.task.complexity == TaskComplexity.MEDIUM
        assert envelope.task.priority == TaskPriority.NORMAL
        assert "TASK-V1-" in envelope.task.task_id
        assert "AOP-SESSION-" in envelope.session.session_id

    def test_v1_prompt_to_v2_envelope_with_params(self):
        """Test V1 prompt to V2 envelope with custom parameters."""
        v1_prompt = "Run tests and generate coverage report."

        envelope = self.layer.v1_prompt_to_v2_envelope(
            v1_prompt=v1_prompt,
            session_id="CUSTOM-SESSION-001",
            orchestrator="CustomOrchestrator",
            target_agent="CustomExecutor",
            workspace_root="C:/ai/custom",
        )

        # Assertions
        assert envelope.session.session_id == "CUSTOM-SESSION-001"
        assert envelope.session.orchestrator == "CustomOrchestrator"
        assert envelope.target.agent_name == "CustomExecutor"
        assert envelope.task.environment.workspace_root == "C:/ai/custom"
        assert envelope.task.objective == v1_prompt

    def test_v1_response_to_v2(self):
        """Test V1 response to V2 ExecutorResponse lifting."""
        v1_response = "Task completed successfully. All tests passed. Coverage: 85%."
        task_id = "TASK-V1-001"
        session_id = "SESSION-V1-001"
        agent_name = "V1Executor"
        started_at = datetime.now(timezone.utc)
        completed_at = datetime.now(timezone.utc)

        response = self.layer.v1_response_to_v2(
            v1_response=v1_response,
            task_id=task_id,
            session_id=session_id,
            agent_name=agent_name,
            started_at=started_at,
            completed_at=completed_at,
        )

        # Assertions
        assert response.aop_version == "2.0.2-C"
        assert response.message_type == "RESPONSE"
        assert response.session_id == session_id
        assert response.task_id == task_id
        assert response.agent.name == agent_name
        assert response.agent.provider == AgentProvider.OTHER
        assert response.task_status.state == "COMPLETED"
        assert response.task_status.final_signal == FinalSignal.SUCCESS
        assert "V1 task completed" in response.task_status.message
        assert len(response.execution_summary.summary) > 0
        assert "Executed v1 task" in response.execution_summary.actions
        assert response.timing.duration_seconds >= 0

    def test_v1_response_to_v2_long_text_truncation(self):
        """Test V1 response truncation for very long responses."""
        # Create a response longer than 500 characters
        v1_response = "X" * 600
        task_id = "TASK-V1-002"
        session_id = "SESSION-V1-002"
        agent_name = "V1Executor"
        started_at = datetime.now(timezone.utc)
        completed_at = datetime.now(timezone.utc)

        response = self.layer.v1_response_to_v2(
            v1_response=v1_response,
            task_id=task_id,
            session_id=session_id,
            agent_name=agent_name,
            started_at=started_at,
            completed_at=completed_at,
        )

        # Summary should be truncated to 500 chars + "..."
        assert len(response.execution_summary.summary) == 503  # 500 + "..."
        assert response.execution_summary.summary.endswith("...")


class TestCompatibilityChecks:
    """Test compatibility and transformation loss detection."""

    def setup_method(self):
        """Initialize transformation layer before each test."""
        self.layer = TransformationLayer()

    def test_is_v2_compatible_true_minimal_envelope(self):
        """Test is_v2_compatible returns True for minimal envelope."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-007",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-007",
                objective="Test compatibility",
                category=TaskCategory.ANALYSIS,
                complexity=TaskComplexity.LOW,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
            ),
        )

        is_compatible = self.layer.is_v2_compatible(envelope)

        assert is_compatible is True

    def test_is_v2_compatible_false_with_guard_rails(self):
        """Test is_v2_compatible returns False when guard rails present."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-008",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-008",
                objective="Test incompatibility",
                category=TaskCategory.ANALYSIS,
                complexity=TaskComplexity.LOW,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
            ),
            guard_rails=GuardRails(
                timeout_seconds=600,
                require_final_signal=True,
            ),
        )

        is_compatible = self.layer.is_v2_compatible(envelope)

        assert is_compatible is False

    def test_is_v2_compatible_false_with_budgets(self):
        """Test is_v2_compatible returns False when budgets present."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-009",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-009",
                objective="Test incompatibility",
                category=TaskCategory.ANALYSIS,
                complexity=TaskComplexity.LOW,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
                budgets=TaskBudgets(max_cost_usd=10.0),
            ),
        )

        is_compatible = self.layer.is_v2_compatible(envelope)

        assert is_compatible is False

    def test_estimate_transformation_loss_no_loss(self):
        """Test estimate_transformation_loss with no features lost."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-010",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-010",
                objective="Test no loss",
                category=TaskCategory.ANALYSIS,
                complexity=TaskComplexity.LOW,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
            ),
        )

        loss_report = self.layer.estimate_transformation_loss(envelope)

        # Assertions
        assert loss_report["guard_rails_lost"] is False
        assert loss_report["extensions_lost"] is False
        assert loss_report["phases_lost"] is False
        assert loss_report["budgets_lost"] is False
        assert loss_report["checkpoints_lost"] == 0
        assert loss_report["structured_access_lost"] is False
        assert loss_report["heartbeat_config_lost"] is False
        assert loss_report["total_features_lost"] == 0

    def test_estimate_transformation_loss_with_losses(self):
        """Test estimate_transformation_loss with multiple features lost."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-011",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-011",
                objective="Test with losses",
                category=TaskCategory.ANALYSIS,
                complexity=TaskComplexity.LOW,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
                budgets=TaskBudgets(max_cost_usd=5.0),
            ),
            guard_rails=GuardRails(timeout_seconds=600),
            phases=[
                Phase(
                    phase_id="PHASE-TEST-001",
                    phase_order=1,
                    label="Test",
                    objective="Test phase",
                    checkpoints=[
                        Checkpoint(checkpoint_id="CP-001", description="Test checkpoint"),
                    ],
                ),
            ],
            extensions={"x_custom_field": "custom_value"},
        )

        loss_report = self.layer.estimate_transformation_loss(envelope)

        # Assertions
        assert loss_report["guard_rails_lost"] is True
        assert loss_report["extensions_lost"] is True
        assert loss_report["phases_lost"] is True
        assert loss_report["budgets_lost"] is True
        assert loss_report["checkpoints_lost"] == 1
        assert loss_report["total_features_lost"] >= 4  # At least 4 features lost


class TestConvenienceAPI:
    """Test convenience API functions."""

    def test_transform_v2_to_v1_prompt_convenience(self):
        """Test transform_v2_to_v1_prompt convenience function."""
        envelope = OrchestrationEnvelope(
            session=Session(
                session_id="TEST-SESSION-012",
                created_at=datetime.now(timezone.utc),
                orchestrator="TestOrchestrator",
                origin="CLI",
            ),
            target=Target(
                agent_name="TestExecutor",
                role="EXECUTOR",
                provider=AgentProvider.CLAUDE,
                model="claude-sonnet-4-5",
            ),
            task=Task(
                task_id="TASK-012",
                objective="Test convenience API",
                category=TaskCategory.ANALYSIS,
                complexity=TaskComplexity.LOW,
                priority=TaskPriority.NORMAL,
                environment=TaskEnvironment(workspace_root="C:/ai/test"),
            ),
        )

        prompt = transform_v2_to_v1_prompt(envelope)

        assert "TASK-012" in prompt
        assert "Test convenience API" in prompt

    def test_transform_v1_to_v2_envelope_convenience(self):
        """Test transform_v1_to_v2_envelope convenience function."""
        v1_prompt = "Run tests and report results."

        envelope = transform_v1_to_v2_envelope(v1_prompt)

        assert envelope.aop_version == "2.0.2-C"
        assert envelope.task.objective == v1_prompt
        assert envelope.session.origin == "V1_COMPAT"


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
