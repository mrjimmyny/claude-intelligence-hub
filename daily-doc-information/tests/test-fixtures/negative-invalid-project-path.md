# Test Input: update-project-status — NEGATIVE (project_path missing PROJECT_CONTEXT.md)

## Purpose
Trigger SC-10 (PROJECT_PATH_INVALID). The project_path points to a folder that exists
but does not contain PROJECT_CONTEXT.md. The presence of PROJECT_CONTEXT.md is the
validation check for a valid project root.

## Expected behavior
- Agent checks for PROJECT_CONTEXT.md at {project_path}/PROJECT_CONTEXT.md
- Agent fires SC-10 upon finding it absent
- Error message includes "SC-10" explicitly
- Error message includes the project_path that was checked
- No modification made to any file

operation: update-project-status
agent_name: TestAgent
agent_slug: testagent
machine_id: TEST-MACHINE-001
timestamp_local: 2026-03-17 15:00
timezone: America/Sao_Paulo
project_path: {BASE}/obsidian/CIH/projects/skills/non-existent-project
section: completed
content: "This update should never happen — project_path is invalid"
overall_progress: "0%"

## Why this triggers SC-10
- The folder non-existent-project/ does not exist, therefore PROJECT_CONTEXT.md cannot exist
- Even if the folder existed but lacked PROJECT_CONTEXT.md, SC-10 would fire
- The check is specifically: does PROJECT_CONTEXT.md exist at {project_path}/PROJECT_CONTEXT.md

## Alternative scenario for SC-10
SC-10 also fires if the folder exists but PROJECT_CONTEXT.md is missing:
- Create folder {BASE}/obsidian/CIH/projects/skills/partial-project/ (no docs inside)
- Attempt update-project-status with project_path pointing to it
- SC-10 fires because PROJECT_CONTEXT.md is absent

## Verification
After invoking this fixture, verify:
- [ ] Response contains "SC-10"
- [ ] Response contains "PROJECT_PATH_INVALID" or equivalent
- [ ] Response includes the project_path that was checked
- [ ] Response specifies that PROJECT_CONTEXT.md was not found
- [ ] No files created or modified
