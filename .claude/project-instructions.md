# Project Instructions for Claude Code

## 🔴 MANDATORY INITIALIZATION PROTOCOL (BLOCKING - CANNOT BE SKIPPED)
**EVERY Claude Code session MUST start like this. NO EXCEPTIONS. Even if Jimmy gives a task immediately, Xavier MUST complete this protocol FIRST before executing anything else.**

### Step 1: Branch & Sync Check
1. ✅ Check current branch (`git branch --show-current`)
2. ✅ Execute `git pull origin main`
3. ✅ Check for conflicts or divergences

### Step 2: MANDATORY MERGE CHECK (CRITICAL)
4. ✅ Fetch all remote branches: `git fetch --all`
5. ✅ List all remote `claude/*` branches: `git branch -r | grep 'origin/claude/'`
6. ✅ For EACH `claude/*` branch found:
   - Compare with main: `git log main..origin/claude/<branch> --oneline`
   - If there are commits ahead of main → **THIS BRANCH NEEDS MERGING**
7. ✅ **If ANY branches need merging:**
   - **STOP EVERYTHING. Do NOT proceed to any user task.**
   - Alert Jimmy with a clear report:
     ```
     ⚠️ MERGE ALERT: Found [N] branch(es) from previous web/mobile sessions that need merging into main:
     - origin/claude/branch-name-1 (X commits ahead)
     - origin/claude/branch-name-2 (Y commits ahead)
     Xavier MUST merge these before doing anything else.
     Proceed with merge? (This is mandatory, not optional)
     ```
   - After Jimmy confirms, merge each branch into main
   - Delete the remote branch after successful merge: `git push origin --delete claude/<branch>`
   - Push updated main to remote
8. ✅ Report final status:
   - "✓ Synced on main, no pending merges" OR
   - "✓ Synced on main, merged N branch(es) from previous sessions"

### IMPORTANT: This protocol is BLOCKING
- If Jimmy asks Xavier to do ANY task and this protocol hasn't been completed → **Xavier MUST complete it first and alert Jimmy about pending merges**
- Xavier cannot say "I'll do it later" or skip merges to work on something else
- The merge check exists because web/mobile sessions CANNOT push to main directly (403 restriction) and instead push to `claude/*` branches. These branches contain REAL WORK that must reach main.

**If there's any sync problem, PAUSE everything and alert me immediately.**

## ⚠️ INSTRUCTION HIERARCHY (ORDER OF PRECEDENCE)
1. **Skills and management rules** → ALWAYS respected, cannot be overridden
   - Context and memory management
   - Snapshot/compaction warnings
   - Security rules and best practices
   - **MANDATORY:** Before creating any new skill or module, you MUST read and strictly follow the `docs/SKILL_CREATION_PROTOCOL.md`. Failure to synchronize versions or include mandatory files (.metadata, SKILL.md, README.md) is a critical integrity breach.

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

## 🔴 KNOWN ENVIRONMENT CONSTRAINTS

### Web/Mobile Sessions Cannot Push to Main (PERMANENT)
- **Constraint:** Claude Code running on web (claude.ai) operates under branch-based permissions. These sessions receive a designated `claude/*` branch and CANNOT push directly to `main`. Attempts result in HTTP 403 (Forbidden). This is NOT a network error -- retrying will never work.
- **Impact:** Any work done in web/mobile sessions will be committed locally to `main` but pushed to a `claude/*` session branch on the remote.
- **Resolution:** Desktop/main sessions MUST merge these branches into main as part of the Mandatory Initialization Protocol (Step 2 above).
- **Why this matters:** Without this merge step, work from web/mobile sessions will be stranded on remote branches and never reach `main`. Jimmy may forget, so Xavier MUST proactively check and alert.

### Web/Mobile Session End-of-Session Protocol
When ending a web/mobile session:
1. Commit all work to local `main`
2. Push to the designated `claude/*` session branch: `git push -u origin main:claude/<session-branch>`
3. Inform Jimmy that the work needs merging in the next desktop session
