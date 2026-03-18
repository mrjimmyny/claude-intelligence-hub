# Test Input: create-session — NEGATIVE (missing universal inputs)

## Purpose
Trigger SC-02 (MISSING_UNIVERSAL_INPUT). The agent_name and machine_id fields are absent.
These are universal inputs (I-02 and I-04) required for ALL operations.

## Expected behavior
- Agent fires SC-02 BEFORE any other processing
- Error message includes "SC-02" explicitly
- Error message names the specific missing fields (agent_name, machine_id)
- No files created or modified

operation: create-session
# agent_name: INTENTIONALLY OMITTED — triggers SC-02
agent_slug: testagent
# machine_id: INTENTIONALLY OMITTED — triggers SC-02
timestamp_local: 2026-03-17 14:30
timezone: America/Sao_Paulo
session_id: c3d4e5f6-a7b8-9012-cdef-123456789012
session_id_short: c3d4e5f6
project: test-project
context_type: Project
session_name: Test Session - SC-02 trigger
output_path: {BASE}/obsidian/CIH/projects/skills/test-project/ai-sessions/2026-03/session-c3d4e5f6-2026-03-17-testagent.md

## Universal inputs (I-01 to I-06) for reference
- I-01: operation (present)
- I-02: agent_name (MISSING)
- I-03: agent_slug (present)
- I-04: machine_id (MISSING)
- I-05: timestamp_local (present)
- I-06: timezone (present)

## Verification
After invoking this fixture, verify:
- [ ] Response contains "SC-02"
- [ ] Response contains "MISSING_UNIVERSAL_INPUT" or equivalent
- [ ] Response names "agent_name" as missing
- [ ] Response names "machine_id" as missing
- [ ] No files created
