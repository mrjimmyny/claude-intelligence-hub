# Test Input: create-project — NEGATIVE (project already exists)

## Purpose
Trigger SC-11 (PROJECT_ALREADY_EXISTS). The target project folder already exists on disk.
The operation must abort instead of creating duplicate structure — PB-14 (NO_PROJECT_OVERWRITE) applies.

## Expected behavior
- Agent verifies target folder existence BEFORE creating anything
- Agent fires SC-11 immediately upon finding folder exists
- Error message includes "SC-11" explicitly
- Error message includes the existing folder path
- No files created or overwritten

operation: create-project
agent_name: TestAgent
agent_slug: testagent
machine_id: TEST-MACHINE-001
timestamp_local: 2026-03-17 18:00
timezone: America/Sao_Paulo
project_name: test-new-project
project_type: skill
objective: This create-project should fail because the project already exists
initial_phase: Phase 1 - Setup

## Setup requirement
Before running this test, the folder at
{BASE}/obsidian/CIH/projects/skills/test-new-project/
must already exist.

The project created in T-CP-01 (happy path) serves this purpose.
Run T-CP-01 first, then attempt this fixture.

## Target folder (derived from inputs)
For skill projects: {BASE}/obsidian/CIH/projects/skills/test-new-project/

## Verification
After invoking this fixture, verify:
- [ ] Response contains "SC-11"
- [ ] Response contains "PROJECT_ALREADY_EXISTS" or equivalent
- [ ] Response includes the target folder path
- [ ] No existing files overwritten in test-new-project/
- [ ] No new files created inside test-new-project/
