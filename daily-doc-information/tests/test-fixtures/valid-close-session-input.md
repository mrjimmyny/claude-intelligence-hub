# Test Input: close-session (happy path)

operation: close-session
agent_name: TestAgent
agent_slug: testagent
machine_id: TEST-MACHINE-001
timestamp_local: 2026-03-17 16:00
timezone: America/Sao_Paulo
target_path: {BASE}/obsidian/CIH/projects/skills/test-project/ai-sessions/2026-03/session-a1b2c3d4-2026-03-17-testagent.md
clean_state_evidence:
  CS-01: "next_action is 'Run PT-R4 integration tests' — single and explicit"
  CS-02: "blockers: none"
  CS-03: "Decision D1 recorded: 'Test suite created'"
  CS-04: "Validation V1 recorded: 'All tests passed'"
  CS-05: "No temporary artifacts created"
  CS-06: "No commits made during this session"
