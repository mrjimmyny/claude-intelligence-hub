# Test Input: update-session — NEGATIVE (legacy target, dated 2026-03-10)

## Purpose
Trigger SC-06 (TARGET_IS_LEGACY). The target_path points to a document dated 2026-03-10,
which is before the 2026-03-13 active-range cutoff. Legacy docs are frozen and must never be modified.

## Expected behavior
- Agent fires SC-06 BEFORE attempting any modification
- Error message includes "SC-06" explicitly
- Error message includes the document date (2026-03-10)
- Error message states the document is frozen/legacy
- No modification made to the target file

operation: update-session
agent_name: TestAgent
agent_slug: testagent
machine_id: TEST-MACHINE-001
timestamp_local: 2026-03-17 15:00
timezone: America/Sao_Paulo
target_path: {BASE}/obsidian/CIH/projects/skills/test-project/ai-sessions/2026-03/session-deadbeef-2026-03-10-testagent.md
update_type: history
update_content: "This update should never happen — target is legacy"

## What makes this legacy
- Filename contains 2026-03-10
- 2026-03-10 is before the 2026-03-13 active range cutoff
- SC-06 applies to ALL operations (not just update-session)
- FM-06 would fire if SC-06 somehow failed to catch it at pre-flight

## Verification
After invoking this fixture, verify:
- [ ] Response contains "SC-06"
- [ ] Response contains "TARGET_IS_LEGACY" or equivalent
- [ ] Response includes the date 2026-03-10 or a reference to the legacy status
- [ ] Target file is NOT modified
