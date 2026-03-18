# Test Input: update-session — NEGATIVE (target already closed)

## Purpose
Trigger SC-05 (TARGET_ALREADY_CLOSED). The target session doc has status: complete
in its frontmatter. Updating a closed session is prohibited.

## Expected behavior
- Agent reads target document and checks status
- Agent fires SC-05 upon finding status=complete
- Error message includes "SC-05" explicitly
- Error message states the document is complete and cannot be updated
- No modification made to the target file

operation: update-session
agent_name: TestAgent
agent_slug: testagent
machine_id: TEST-MACHINE-001
timestamp_local: 2026-03-17 17:00
timezone: America/Sao_Paulo
target_path: {BASE}/obsidian/CIH/projects/skills/test-project/ai-sessions/2026-03/session-a1b2c3d4-2026-03-17-testagent.md
update_type: history
update_content: "This update should never happen — target is already closed"

## Setup requirement
The target file must have status: complete in its frontmatter.
After running T-CL-01 (close-session happy path), the session doc will be in this state.
Run T-CL-01 first, then attempt this fixture on the same target_path.

## Verification
After invoking this fixture, verify:
- [ ] Response contains "SC-05"
- [ ] Response contains "TARGET_ALREADY_CLOSED" or equivalent
- [ ] Response confirms the document status is "complete"
- [ ] Target file frontmatter status is still "complete" (unchanged)
- [ ] No new history rows added to the document
