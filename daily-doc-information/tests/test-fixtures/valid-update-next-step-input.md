# Test Input: update-next-step (happy path)

operation: update-next-step
agent_name: TestAgent
agent_slug: testagent
machine_id: TEST-MACHINE-001
timestamp_local: 2026-03-17 16:00
timezone: America/Sao_Paulo
project_path: {BASE}/obsidian/CIH/projects/skills/test-new-project
immediate_action: "Execute integration tests with real session docs"
required_reading:
  - PROJECT_CONTEXT.md
  - status-atual.md
  - SKILL.md
completion_criteria:
  - "All 8 operations tested with valid inputs"
  - "All critical skip conditions verified"
  - "All critical failure modes verified"
