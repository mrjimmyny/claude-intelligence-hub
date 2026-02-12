---
entry_id: 2026-02-12-003
date: 2026-02-12
time: "06:30"
category: Projects
tags: [claude-code, session-backup, data-persistence, disaster-recovery, session-management, critical-concern]
status: aberto
priority: alta
last_discussed: 2026-02-12
resolution: "Pending - Xavier to plan and implement session backup solution"
project: claude-intelligence-hub
conversation_id: web-session-0129cHfuYQwhJ2ihDuEqms6x
summary: "CRITICAL: CLI sessions stored locally only - machine format = total loss. Backup strategy approved for registered sessions."
---

# CRITICAL: CLI Session Data Persistence & Backup Strategy

## Context
During a web/mobile session reviewing branch rules and merge protocol, a critical concern was raised: Claude Code CLI sessions are stored ONLY in `~/.claude/` on the local machine. If the machine is formatted, the drive fails, or the OS is reinstalled, ALL session data (conversation history, resume IDs) is permanently lost with NO recovery option.

This is especially critical because:
- Session resume IDs (`claude --resume <id>`) are the ONLY way to restore exact conversation context
- The `claude-session-registry` already tracks important session IDs
- Losing these sessions means losing the ability to resume critical project contexts

## Key Facts Confirmed
1. **CLI sessions** → stored locally at `~/.claude/` → NO cloud sync → NO recovery if machine lost
2. **Web sessions** → stored on Anthropic's servers → accessible via browser URL → NOT compatible with CLI `--resume`
3. **Web ↔ CLI** → completely separate systems, no cross-resume capability
4. **Session registry** → already tracks which sessions are important (via `claude-session-registry`)

## Approved Strategy (Owner Decision)
The owner approved the following combined approach:

### Option 1 + Option 3: Git Export + GitHub Gists
- **Session-memoria** keeps the index (already implemented)
- **Git repo** stores summaries/key decisions of registered sessions
- **GitHub Gists** stores session transcripts (private, free, versioned, searchable)
- **ONLY** sessions already registered in session-memoria/session-registry get backed up (not all sessions)

### Implementation Requirements
- Xavier (desktop CLI) to plan and implement
- Must present at least 3 approaches with pros/cons before implementation
- User approval required before execution (GOEXEC protocol)
- Zero-cost or very low-cost solutions only
- Must integrate with existing session-memoria and session-registry workflows

## What NOT to Do
- Do NOT attempt to backup ALL sessions (too many, too large)
- Do NOT store raw `~/.claude/` binary data in git (bloat)
- Do NOT create paid service dependencies

## Next Steps
- [ ] Xavier: Receive power prompt with full context and requirements
- [ ] Xavier: Research `~/.claude/` session file structure and export capabilities
- [ ] Xavier: Present minimum 3 approaches with pros/cons
- [ ] Owner: Select approach
- [ ] Xavier: Create detailed Plan Mode implementation plan
- [ ] Owner: Approve with GOEXEC
- [ ] Xavier: Implement, test, and document

## Additional Session Notes
This web session also covered:
- Branch rules review and merge protocol discussion
- Confirmation that web sessions cannot push to `main` (only to feature branches)
- Merge-first protocol: desktop must always pull/merge feature branches before continuing
- Web ↔ CLI session ID incompatibility confirmed

## References
- Related entry: [[2026-02-12-001]] (Session Resume IDs & Registry)
- Session Registry: `claude-session-registry/registry/2026/02/SESSIONS.md`
- CLI session storage: `~/.claude/` directory

---
**Recorded by:** Claude (Web Session)
**Session type:** Web/Mobile (claude.ai)
**Session ID:** web-session-0129cHfuYQwhJ2ihDuEqms6x
**Entry size:** ~350 words
