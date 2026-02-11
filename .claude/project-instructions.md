# Project Instructions for Claude Code

## 🔴 MANDATORY INITIALIZATION PROTOCOL
**EVERY Claude Code session MUST start like this (no exceptions):**

1. ✅ Check current branch (`git branch --show-current`)
2. ✅ Execute `git pull` automatically
3. ✅ Check for conflicts or divergences
4. ✅ Report status: "✓ Synced on main" or "⚠️ Problem detected: [detail]"

**Do this BEFORE any other action, even if I don't explicitly ask.**

If there's any sync problem, **PAUSE everything and alert me immediately**.

## ⚠️ INSTRUCTION HIERARCHY (ORDER OF PRECEDENCE)
1. **Skills and management rules** → ALWAYS respected, cannot be overridden
   - Context and memory management
   - Snapshot/compaction warnings
   - Security rules and best practices

2. **Project Instructions** (this file) → Operational autonomy
   - How to execute approved tasks
   - Permissions and workflow

3. **Specific prompts** → Current context and priority
   - Specific tasks and requests

## Autonomy and Permissions
- ✅ You have FULL autonomy to execute all necessary actions
- ✅ Execute edits, file creations, deletions without asking for confirmation
- ✅ Execute bash commands, dependency installations, builds without pauses
- ✅ Implement the ENTIRE approved plan at once, without interruptions
- ⚠️ Only consult me for: major architecture decisions, irreversible production changes, or technical blockers
- ⚠️ ALWAYS respect context warnings, snapshot suggestions, and Skills rules

## Workflow
1. Present the complete plan
2. After my approval, EXECUTE EVERYTHING without pauses
3. Notify me only upon completion or critical errors
4. **CRITICAL**: Before any commit/push, verify current branch and synchronization

## Preferences
- Be direct and efficient
- Avoid unnecessary questions during execution
- Prioritize action over confirmation when context has already been established
- Maintain clear communication about Git sync status

## 🔴 CRITICAL SYNCHRONIZATION RULES
- **Central repository**: `claude-intelligence-hub` (main branch)
- **ALWAYS** check branch before committing
- **NEVER** create branches without explicit authorization
- If divergences are detected between sessions/machines, **PAUSE and alert immediately**
- All Skills changes must be committed/pushed to main BEFORE ending session
