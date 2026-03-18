# Test Input: NEGATIVE — invalid operation value

## Purpose
Trigger SC-01 (INVALID_OPERATION). The operation field is set to "delete-session",
which is not one of the 8 valid operations. The check fires before any other processing.

## Expected behavior
- Agent fires SC-01 immediately (before checking any other inputs)
- Error message includes "SC-01" explicitly
- Error message states the received value ("delete-session")
- Error message lists the 8 valid operation values
- No files created or modified

operation: delete-session
agent_name: TestAgent
agent_slug: testagent
machine_id: TEST-MACHINE-001
timestamp_local: 2026-03-17 14:30
timezone: America/Sao_Paulo

## Notes
SC-01 applies to ALL operations. Other inputs are present and valid to ensure
SC-01 fires before SC-02 (the test isolates the invalid operation trigger).

## Valid operations (for reference)
The 8 valid values are:
1. create-session
2. update-session
3. close-session
4. create-daily-report
5. create-project
6. update-project-status
7. register-decision
8. update-next-step

## Verification
After invoking this fixture, verify:
- [ ] Response contains "SC-01"
- [ ] Response contains "INVALID_OPERATION" or equivalent
- [ ] Response includes the invalid value received ("delete-session")
- [ ] Response lists valid operation options (per PB-06 — no silent abort)
- [ ] No files created or modified
