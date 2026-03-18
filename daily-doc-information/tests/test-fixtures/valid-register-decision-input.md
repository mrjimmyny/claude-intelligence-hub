# Test Input: register-decision (happy path)

operation: register-decision
agent_name: TestAgent
agent_slug: testagent
machine_id: TEST-MACHINE-001
timestamp_local: 2026-03-17 15:30
timezone: America/Sao_Paulo
project_path: {BASE}/obsidian/CIH/projects/skills/test-new-project
decision: "Test suite will use specification-based testing, not runtime execution"
reason: "The skill is instruction-based (markdown), not code — runtime tests are not applicable"
impact: "All test cases verify contract completeness and correctness, not execution"
decision_date: 2026-03-17
