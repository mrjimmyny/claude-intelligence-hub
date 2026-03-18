# Test Input: create-session — NEGATIVE (output already exists)

## Purpose
Trigger SC-07 (OUTPUT_ALREADY_EXISTS). The output_path points to a file that already exists.
The operation must abort instead of overwriting — PB-09 (NO_OVERWRITE) applies.

## Expected behavior
- Agent checks output_path existence BEFORE writing (create-session step 6)
- Agent fires SC-07 immediately upon finding the file exists
- Error message includes "SC-07" explicitly
- Error message includes the path that already exists
- Existing file is NOT overwritten

operation: create-session
agent_name: TestAgent
agent_slug: testagent
machine_id: TEST-MACHINE-001
timestamp_local: 2026-03-17 14:30
timezone: America/Sao_Paulo
session_id: b2c3d4e5-f6a7-8901-bcde-f12345678901
session_id_short: b2c3d4e5
project: test-project
context_type: Project
session_name: Test Session - SC-07 trigger
output_path: {BASE}/obsidian/CIH/projects/skills/test-project/ai-sessions/2026-03/session-a1b2c3d4-2026-03-17-testagent.md

## Setup requirement
Before running this test, the file at output_path must already exist.
The file from T-CS-01 (happy path) serves this purpose — run T-CS-01 first.

## Verification
After invoking this fixture, verify:
- [ ] Response contains "SC-07"
- [ ] Response contains "OUTPUT_ALREADY_EXISTS" or equivalent
- [ ] Response includes the output_path that was found to exist
- [ ] Existing file content is NOT changed
