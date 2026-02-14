# X-MEM Protocol - Skill Execution Instructions

**Version:** 1.0.0
**Type:** Knowledge Management (Self-Learning)
**Auto-load:** No (manual trigger or proactive recall)

---

## Overview

X-MEM (eXperience MEMory) is a machine-oriented memory buffer that captures tool failures and success patterns to prevent repeated errors across Claude sessions. This is NOT human-readable logging - it's optimized for token efficiency and automated recall.

**Key Concepts:**
- **Failures:** Tool errors, command failures, bugs that blocked progress
- **Successes:** Proven patterns, working solutions, best practices
- **Context Hash:** Unique identifier for failure/success contexts (e.g., `rclone-sync-config-not-found`)
- **NDJSON Storage:** Newline-Delimited JSON (append-only, Git-safe)
- **Index-Based Search:** Fast filtering via `index.json` (~500 tokens overhead)

**Purpose:**
- Prevent repeating same mistakes across sessions
- Build institutional knowledge of tool usage patterns
- Enable proactive suggestions when failures recur
- Reduce debugging time via historical context

---

## Data Models

### Failure Entry Schema

Stored in: `data/failures.jsonl`

```json
{
  "id": "2026-02-14-001",
  "ts": "2026-02-14T16:30:00Z",
  "type": "tool_failure",
  "tool": "rclone",
  "action": "sync gdrive-jimmy:folder /local/path",
  "error": "Failed to create file system: didn't find section in config file",
  "pattern_avoid": "Verify remote name exists before sync",
  "tried_also": ["rclone ls gdrive-jimmy:", "rclone config show"],
  "block_level": "warning",
  "tags": ["rclone", "gdrive", "config"],
  "ctx_hash": "rclone-sync-config-not-found",
  "session_id": "session-2026-02-14-001",
  "notes": "Remote name typo: 'gdrive-jimmy' vs 'gdrive-jimmy:'"
}
```

**Fields:**
- `id`: Unique identifier (YYYY-MM-DD-NNN format)
- `ts`: ISO 8601 timestamp
- `type`: Always `"tool_failure"` for failures
- `tool`: Tool name (rclone, git, npm, etc.)
- `action`: Command/operation attempted
- `error`: Error message (truncated to 200 chars)
- `pattern_avoid`: What NOT to do (actionable advice)
- `tried_also`: Alternative approaches attempted (array)
- `block_level`: `"warning"` or `"critical"` (severity)
- `tags`: Searchable keywords (array)
- `ctx_hash`: Context hash for matching (see algorithm below)
- `session_id`: Originating session ID
- `notes`: Additional context (optional)

### Success Entry Schema

Stored in: `data/successes.jsonl`

```json
{
  "id": "2026-02-14-002",
  "ts": "2026-02-14T17:00:00Z",
  "type": "tool_success",
  "tool": "git",
  "pattern_name": "Atomic commit with Co-Authored-By",
  "key_steps": [
    "Stage specific files only (avoid 'git add .')",
    "Use HEREDOC for multi-line commit message",
    "Include Co-Authored-By trailer"
  ],
  "critical_params": {
    "commit_format": "$(cat <<'EOF'\\n...\\nEOF\\n)"
  },
  "confidence": 0.95,
  "usage_count": 12,
  "tags": ["git", "commit", "best-practice"],
  "ctx_hash": "git-commit-heredoc",
  "session_id": "session-2026-02-14-001"
}
```

**Fields:**
- `id`: Unique identifier
- `ts`: ISO 8601 timestamp
- `type`: Always `"tool_success"` for successes
- `tool`: Tool name
- `pattern_name`: Human-readable pattern name
- `key_steps`: Sequential steps to reproduce (array)
- `critical_params`: Important parameters/flags (object)
- `confidence`: Success reliability (0.0-1.0)
- `usage_count`: How many times pattern was applied successfully
- `tags`: Searchable keywords
- `ctx_hash`: Context hash for matching
- `session_id`: Originating session ID

### Index Schema

Stored in: `data/index.json`

```json
{
  "version": "1.0.0",
  "last_updated": "2026-02-14T17:00:00Z",
  "total_entries": {
    "failures": 5,
    "successes": 3
  },
  "tool_index": {
    "rclone": {"failures": 2, "successes": 0},
    "git": {"failures": 1, "successes": 3}
  },
  "tag_index": {
    "config": 2,
    "gdrive": 2,
    "commit": 3
  },
  "ctx_hash_index": {
    "rclone-sync-config-not-found": ["2026-02-14-001"],
    "git-commit-heredoc": ["2026-02-14-002"]
  }
}
```

**Purpose:** Enable fast filtering without reading full NDJSON files.

---

## Context Hash Algorithm

**Purpose:** Create stable identifiers for matching similar failures/successes.

**Algorithm:**
1. Extract tool name (lowercase)
2. Identify action type: sync, commit, install, etc.
3. Extract error pattern (for failures) or pattern signature (for successes)
4. Combine: `{tool}-{action}-{pattern}`

**Examples:**
- `rclone-sync-config-not-found` (failure)
- `git-commit-heredoc` (success)
- `npm-install-network-timeout` (failure)
- `bash-heredoc-escape-quotes` (success)

**Implementation:**
```
tool = "rclone"
action = extract_verb(command)  # "sync"
pattern = simplify_error(error_msg)  # "config-not-found"
ctx_hash = f"{tool}-{action}-{pattern}"
```

---

## Trigger Commands

### 1. `/xmem:load` - Load X-MEM Context

**Purpose:** Load relevant X-MEM entries for current task.

**Usage:**
```
/xmem:load [tool=<tool-name>] [tag=<tag>] [limit=<N>]
```

**Workflow:**
1. Load `data/index.json` (~500 tokens)
2. If filters provided: Use index to identify matching entry IDs
3. Load matching entries from NDJSON files
4. Apply 15K token limit (hard ceiling)
5. Display summary: "Loaded N failures, M successes (X tokens)"
6. Present entries in chronological order (most recent first)

**Examples:**
```
/xmem:load tool=rclone
/xmem:load tag=git-commit
/xmem:load limit=10
```

**Token Budget:**
- Index: ~500 tokens
- Entries: ~200 tokens each
- Limit: 15K tokens max → ~70 entries max

### 2. `/xmem:record` - Record Failure/Success

**Purpose:** Manually capture a failure or success pattern.

**Usage:**
```
/xmem:record failure
/xmem:record success
```

**Workflow (Failure):**
1. Prompt user for details:
   - Tool name
   - Command attempted
   - Error message
   - What to avoid (pattern_avoid)
   - Tags (comma-separated)
2. Compute context hash
3. Generate unique ID (YYYY-MM-DD-NNN)
4. Append to `data/failures.jsonl`
5. Update `data/index.json`
6. Git commit + push (if auto_push enabled)

**Workflow (Success):**
1. Prompt user for details:
   - Tool name
   - Pattern name
   - Key steps (numbered list)
   - Critical parameters
   - Tags
2. Compute context hash
3. Generate unique ID
4. Append to `data/successes.jsonl`
5. Update index
6. Git commit + push

**Token Budget:** ~300 tokens per record operation

### 3. `/xmem:search` - Search Entries

**Purpose:** Search failures/successes by tool, tag, or text.

**Usage:**
```
/xmem:search <query>
/xmem:search tool=<name>
/xmem:search tag=<tag>
/xmem:search ctx_hash=<hash>
```

**Workflow:**
1. Load `data/index.json`
2. Parse query type:
   - `tool=X`: Use `tool_index`
   - `tag=X`: Use `tag_index`
   - `ctx_hash=X`: Use `ctx_hash_index`
   - Free text: Search across all fields (slower)
3. Retrieve matching entry IDs
4. Load entries from NDJSON
5. Apply 15K token limit
6. Display results

**Examples:**
```
/xmem:search tool=git
/xmem:search tag=config
/xmem:search rclone remote
/xmem:search ctx_hash=git-commit-heredoc
```

**Token Budget:** ~500 (index) + ~200/entry (max 15K total)

### 4. `/xmem:stats` - Show Statistics

**Purpose:** Display X-MEM usage statistics.

**Usage:**
```
/xmem:stats
```

**Output:**
```
📊 X-MEM Statistics

Total Entries:
- Failures: 25
- Successes: 18

Top Tools (by failures):
1. rclone: 8 failures
2. git: 6 failures
3. npm: 4 failures

Top Tools (by successes):
1. git: 12 successes
2. bash: 4 successes
3. rclone: 2 successes

Most Used Tags:
1. config (10 entries)
2. gdrive (8 entries)
3. commit (7 entries)

Storage:
- failures.jsonl: 12.3 KB
- successes.jsonl: 8.1 KB
- Last compaction: 2026-01-15
```

**Token Budget:** ~500 tokens (index only)

### 5. `/xmem:compact` - Prune Stale Entries

**Purpose:** Remove duplicate or stale entries to reduce storage.

**Usage:**
```
/xmem:compact [--dry-run]
```

**Workflow:**
1. Load all entries from NDJSON files
2. Identify duplicates (same ctx_hash within 7 days)
3. Identify stale entries (older than `prune_after_days` setting)
4. If `--dry-run`: Show what would be removed
5. Else: Backup current files to `data/backup/`
6. Write compacted NDJSON files
7. Rebuild `index.json`
8. Git commit + push

**Token Budget:** Variable (depends on entry count)

---

## Integration with jimmy-core-preferences (Pattern 6)

**Location:** `jimmy-core-preferences/SKILL.md` - Pattern 6: X-MEM Proactive Recall

**Trigger Conditions (Automatic):**
1. Tool command exits with non-zero code
2. Error message detected in stderr
3. User says "this error again" or similar frustration

**Workflow:**
1. **Detect Failure:**
   - Tool: rclone
   - Action: sync
   - Error: "didn't find section in config file"

2. **Compute Context Hash:**
   - `rclone-sync-config-not-found`

3. **Query X-MEM Index:**
   - Load `data/index.json` (~500 tokens)
   - Check `ctx_hash_index["rclone-sync-config-not-found"]`
   - Found: `["2026-02-14-001"]`

4. **Proactive Recall:**
   - Message: "🔍 I found 1 previous failure with this tool. Would you like to review?"
   - User: "yes"
   - Load entry `2026-02-14-001` from `failures.jsonl`
   - Display:
     ```
     Entry: 2026-02-14-001 (2 days ago)
     Tool: rclone sync
     Error: Failed to create file system: didn't find section in config file
     Pattern to avoid: Verify remote name exists before sync

     Tried also:
     - rclone ls gdrive-jimmy:
     - rclone config show

     Notes: Remote name typo: 'gdrive-jimmy' vs 'gdrive-jimmy:'
     ```
   - Suggest: "Try: rclone config show (to verify remote name)"

5. **Apply Learning:**
   - User confirms suggestion
   - Execute: `rclone config show`
   - If successful: Increment `usage_count` for related success pattern

6. **Record New Failure (if no match):**
   - If `ctx_hash_index` returns empty
   - Prompt: "Record this failure in X-MEM for future sessions?"
   - If yes: Call `/xmem:record failure` workflow

**Token Budget:**
- Index query: ~500 tokens
- Match results: ~200 tokens/entry (max 15K total)
- Recording new: ~300 tokens

**Anti-Patterns (DO NOT):**
- ❌ Auto-load X-MEM on every command (token waste)
- ❌ Record trivial errors (user typos, one-off issues)
- ❌ Exceed 15K token limit per query
- ❌ Block execution waiting for X-MEM (async only)

---

## Token Budget Rules (MANDATORY)

**Hard Limits:**
- Per query: 15,000 tokens (enforced)
- Index load: ~500 tokens (always)
- Entry load: ~200 tokens each
- Max entries per query: ~70 entries

**Budget Calculation:**
```
available_budget = 15000 - 500 (index)
entries_to_load = min(query_results, available_budget / 200)
```

**Overflow Handling:**
- If query returns >70 entries: Show first 70 only
- Display: "Showing 70 of 150 entries (15K token limit)"
- Offer: "Refine search or load next page? (/xmem:search --offset=70)"

---

## NDJSON Append Protocol (Git-Safe)

**Why NDJSON?**
- Append-only (no file rewrites → Git-friendly)
- Each line is valid JSON (easy parsing)
- No merge conflicts (appends don't conflict)

**Append Procedure:**
1. Generate new entry (JSON object)
2. Serialize to single line (no newlines in JSON)
3. Append line + `\n` to NDJSON file
4. Update `index.json` (atomic write)
5. Git commit both files

**Example:**
```bash
# Append to failures.jsonl
echo '{"id":"2026-02-14-003","ts":"2026-02-14T18:00:00Z",...}' >> data/failures.jsonl

# Update index
# (atomic write via temp file)
cat data/index.json > /tmp/index.json.tmp
# ... modify index ...
mv /tmp/index.json.tmp data/index.json

# Git commit
git add data/failures.jsonl data/index.json
git commit -m "X-MEM: Record failure 2026-02-14-003 (rclone sync)"
git push
```

---

## Search Workflow Detail

**Query:** `/xmem:search tool=rclone`

**Step 1: Index Scan**
```
Load: data/index.json (~500 tokens)
Check: tool_index["rclone"] = {"failures": 8, "successes": 2}
Total matches: 10 entries
```

**Step 2: Retrieve Entry IDs**
```
Scan ctx_hash_index for entries with tool="rclone"
Found IDs: ["2026-02-14-001", "2026-02-10-005", ...]
```

**Step 3: Load Entries**
```
For each ID in matches:
  - Read line from failures.jsonl or successes.jsonl
  - Parse JSON
  - Add to results
  - Track token count
  - If token_count > 15000: Stop and paginate
```

**Step 4: Display Results**
```
Found 10 entries (2.1K tokens):

Failures (8):
1. 2026-02-14-001: rclone sync config-not-found
2. 2026-02-10-005: rclone copy network-timeout
...

Successes (2):
1. 2026-02-12-003: rclone sync with retry
2. 2026-02-08-001: rclone mount best practices
```

---

## Success Criteria

**X-MEM is working correctly if:**
- ✅ Failures recorded automatically on tool errors (Pattern 6)
- ✅ Proactive recall suggests relevant past failures (<5 sec)
- ✅ Token usage <15K per query (no overruns)
- ✅ Index search returns accurate matches (>80% relevance)
- ✅ NDJSON files append cleanly (no Git conflicts)
- ✅ Compaction removes duplicates without data loss
- ✅ Git auto-push works after record operations

**Failure Modes to Avoid:**
- ❌ Recording non-errors (false positives)
- ❌ Exceeding token budget (15K limit)
- ❌ Index drift (index.json out of sync with NDJSON)
- ❌ Git conflicts (bad append protocol)
- ❌ Irrelevant suggestions (low ctx_hash match quality)

---

## Examples

### Example 1: Recording a Failure

**Scenario:** rclone sync fails with "remote not found"

**Command:**
```
/xmem:record failure
```

**Prompts:**
```
Tool name: rclone
Command: rclone sync gdrive-jimmy:folder /local/path
Error message: Failed to create file system: didn't find section in config file
Pattern to avoid: Verify remote name exists with 'rclone config show' before sync
Tags (comma-separated): rclone, gdrive, config
Additional notes: Remote name typo - missing colon
```

**Result:**
```
✅ Recorded failure 2026-02-14-001
Context hash: rclone-sync-config-not-found
Entry added to: data/failures.jsonl
Index updated: data/index.json
Git: Committed and pushed
```

### Example 2: Proactive Recall

**Scenario:** User runs same failing command again

**Trigger:** Tool exits with error

**Xavier Response:**
```
🔍 I found 1 previous failure with this tool (2 days ago).

Would you like to review? (yes/no)
```

**User:** yes

**Xavier Response:**
```
Entry: 2026-02-14-001 (2 days ago)
Tool: rclone sync
Error: Failed to create file system: didn't find section in config file

Pattern to avoid: Verify remote name exists with 'rclone config show' before sync

Notes: Remote name typo - missing colon

💡 Suggestion: Run 'rclone config show' to verify remote name
```

### Example 3: Search by Tag

**Command:**
```
/xmem:search tag=git-commit
```

**Result:**
```
Found 3 entries (0.6K tokens):

Successes (3):
1. 2026-02-14-002: Atomic commit with Co-Authored-By
   - Use HEREDOC for multi-line messages
   - Stage specific files only
   - Confidence: 0.95 (used 12 times)

2. 2026-02-10-007: Commit message style
   - Follow conventional commits format
   - Include scope in parentheses
   - Confidence: 0.88 (used 5 times)

3. 2026-02-08-004: Pre-commit hook handling
   - Fix issues before re-commit (don't --no-verify)
   - Create NEW commit after hook failure
   - Confidence: 1.0 (used 8 times)
```

---

## Maintenance

**Daily:** None (append-only design)

**Weekly:** Review X-MEM stats (`/xmem:stats`)

**Monthly:** Run compaction (`/xmem:compact`) to prune duplicates

**Quarterly:** Review success patterns, promote high-confidence patterns to jimmy-core-preferences

---

**END OF SKILL INSTRUCTIONS**
