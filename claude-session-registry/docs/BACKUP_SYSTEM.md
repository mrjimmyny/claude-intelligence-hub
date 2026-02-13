# Session Backup System

Complete documentation for the claude-session-registry automatic backup system.

## 📚 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Backup Types](#backup-types)
- [How It Works](#how-it-works)
- [Configuration](#configuration)
- [Manual Backup](#manual-backup)
- [Restore Procedures](#restore-procedures)
- [Troubleshooting](#troubleshooting)
- [Technical Details](#technical-details)

---

## Overview

The session backup system provides **zero-cost, automated backup** of Claude session transcripts and critical session files to a private GitHub repository.

**Key Features:**
- ✅ Automatic backup after session registration
- ✅ Two-tier strategy: markdown transcripts (all) + .jsonl backups (critical)
- ✅ Zero cost (GitHub free tier: unlimited private repos, 500MB storage)
- ✅ Auto-indexed by date, tag, and machine
- ✅ Git-based with full version history
- ✅ Retry logic for network failures
- ✅ Non-blocking (backup failure doesn't prevent registration)

**Integration:** Seamlessly integrated with `claude-session-registry` Step 9 workflow

---

## Architecture

```
User registers session
        ↓
claude-session-registry (Step 1-8)
        ↓
Git commit + push registry
        ↓
AUTO-TRIGGER backup-session.sh
        ↓
┌─────────────────────────────────────┐
│ 1. Find .jsonl in ~/.claude/        │
│ 2. Parse → markdown transcript      │
│ 3. Copy .jsonl if #critical         │
│ 4. Update indexes (date/tag/machine)│
│ 5. Update metadata.json             │
│ 6. Git commit                       │
│ 7. Git push (retry 3x)              │
└─────────────────────────────────────┘
        ↓
claude-session-backups (GitHub private repo)
        ├── transcripts/YYYY/MM/[id].md
        ├── critical/YYYY/MM/[id].jsonl
        └── indexes/ (by-date, by-tag, by-machine)
```

---

## Backup Types

### 1. Markdown Transcripts (All Sessions)

**Created for:** Every registered session

**Location:** `~/claude-session-backups/transcripts/YYYY/MM/[session-id].md`

**Content:**
- Session metadata (date, time, tags, project, machine, git context)
- Full conversation transcript (user messages, assistant responses)
- Thinking blocks (extended thinking)
- Tool calls (Read, Write, Edit, Bash, etc.)
- Session statistics (message counts, tool usage)

**Use Cases:**
- Review conversation history
- Search for specific discussions
- Extract code snippets or decisions
- Audit tool usage
- Reference thinking process

**Limitations:**
- Read-only (cannot resume session)
- No interactive continuation
- Tool results abbreviated for readability

**Example:**
```markdown
---
session_id: 338633b3-36fb-43c9-8bdd-701f93fba9f2
date: 2026-02-12
tags: #critical #gdrive-sync
---

# Session: 338633b3-36fb-43c9-8bdd-701f93fba9f2

**Summary:** Implemented Google Drive sync automation

## 💬 Conversation Transcript

### 👤 User [2026-02-12 14:30:15]
Xavier, sincroniza o Google Drive

### 🤖 Assistant [2026-02-12 14:30:20]
**💭 Thinking:**
User triggered gdrive-sync. Check MEMORY.md for standard workflow...

**🔧 Tool Calls:** (3)
- 📖 **Read** → `claude-intelligence-hub/gdrive-sync-memoria/SKILL.md`
- 💻 **Bash** → `rclone sync gdrive-jimmy:...`
- 💻 **Bash** → `git add . && git commit...`
```

### 2. Raw .jsonl Backups (Critical Sessions Only)

**Created for:** Sessions tagged with `#critical`

**Location:** `~/claude-session-backups/critical/YYYY/MM/[session-id].jsonl`

**Content:**
- Complete session file (binary copy)
- All messages (user, assistant, system)
- Full tool calls with complete inputs/outputs
- File history snapshots
- All metadata

**Use Cases:**
- Full session restore with `claude --resume`
- Debug session issues
- Preserve high-value sessions
- Compliance/audit requirements

**Limitations:**
- Larger file size (~100KB - 5MB per session)
- Only for critical sessions (tag required)
- Must manually restore to `~/.claude/projects/` to use

**Restore Example:**
```bash
# Copy .jsonl to project directory
cp critical/2026/02/[session-id].jsonl \
   ~/.claude/projects/C--Users-jaderson-almeida-Downloads/[session-id].jsonl

# Resume session
cd /c/Users/jaderson.almeida/Downloads
claude --resume [session-id]
```

---

## How It Works

### Automatic Trigger (Step 9 Integration)

After successful session registration and git push to `claude-session-registry`:

1. **Check Configuration**
   - Read `.metadata` → `settings.auto_backup`
   - If `false`, skip backup
   - If `true`, proceed

2. **Prepare Metadata**
   - Extract session ID, date, time, tags, summary
   - Extract project path, machine, git branch/commit
   - Format as JSON string

3. **Call Backup Script**
   ```bash
   bash claude-intelligence-hub/claude-session-registry/scripts/backup-session.sh \
       "$SESSION_ID" \
       "$SESSION_METADATA"
   ```

4. **Handle Result**
   - Success → Display confirmation + GitHub link
   - Failure → Log error, display retry command
   - **Important:** Backup failure does NOT block registration

### 10-Step Backup Process

**Script:** `claude-session-registry/scripts/backup-session.sh`

#### Step 1: Locate Session File
- Convert project path to slug (e.g., `/c/Users/...` → `C--Users-...`)
- Find `.jsonl` at `~/.claude/projects/[slug]/[session-id].jsonl`
- Error if not found (session may be deleted)

#### Step 2: Extract Date Components
- Parse `YYYY-MM` from session date
- Used for directory structure: `transcripts/2026/02/`

#### Step 3: Create Directory Structure
- `mkdir -p transcripts/$YEAR/$MONTH`
- If `#critical` tag: `mkdir -p critical/$YEAR/$MONTH`

#### Step 4: Generate Markdown Transcript
- Call `parse-jsonl-to-markdown.sh` (see Technical Details)
- Parse .jsonl line-by-line → markdown format
- Extract user/assistant messages, tool calls, thinking
- Generate statistics (message counts, tool usage)

#### Step 5: Copy Critical .jsonl
- If `#critical` tag present:
  - `cp [source].jsonl critical/$YEAR/$MONTH/[id].jsonl`
- Else: skip

#### Step 6: Update Indexes
- **by-date:** `indexes/by-date/2026-02.md`
  - Append session entry with date, ID, tags, summary
- **by-tag:** `indexes/by-tag/critical.md`, `indexes/by-tag/project.md`, etc.
  - One index per tag
  - Append session entry
- **by-machine:** `indexes/by-machine/BR-SPO-DCFC264.md`
  - Append session entry

#### Step 7: Update Metadata.json
- Increment `total_backups`
- Increment `total_critical` (if applicable)
- Update `last_backup_date`, `last_backup_session`

#### Step 8: Git Commit
```bash
git add transcripts/$YEAR/$MONTH/[id].md
git add indexes/
git add metadata.json
[ critical ] && git add critical/$YEAR/$MONTH/[id].jsonl

git commit -m "backup: add session [short-id] - [tags]

Date: [date] [time]
Machine: [machine]
Critical: [true/false]

Summary: [first line of summary]"
```

#### Step 9: Git Push (with Retry)
- Attempt 1: `git push origin main`
- If fail → wait 2s → Attempt 2
- If fail → wait 4s → Attempt 3
- If fail → error message with manual recovery steps

#### Step 10: Success Summary
```
✅ Backup complete!

📊 Summary:
   📄 Transcript: transcripts/2026/02/[id].md
   💾 Critical backup: critical/2026/02/[id].jsonl
   📑 Indexes updated: by-date, by-tag, by-machine
   📈 Total backups: 42
   🔗 View: https://github.com/mrjimmyny/claude-session-backups
```

---

## Configuration

### Enable/Disable Auto-Backup

**File:** `claude-intelligence-hub/claude-session-registry/.metadata`

```json
{
  "settings": {
    "auto_backup": true,    // ← Set to false to disable
    "backup_repo_path": "~/claude-session-backups"
  }
}
```

**To disable:**
1. Edit `.metadata`
2. Set `"auto_backup": false`
3. Commit change: `git add .metadata && git commit -m "disable auto-backup"`

### Backup Repository Path

Default: `~/claude-session-backups`

**To change:**
1. Clone backup repo to new location
2. Update `.metadata` → `settings.backup_repo_path`
3. Update script reference if needed

### Critical Tag Configuration

**Default tag:** `#critical`

To mark session as critical during registration:
- Include `#critical` in tags field
- Case-sensitive
- Can combine with other tags: `#critical #project #gdrive-sync`

**What triggers .jsonl backup:**
```bash
# In backup-session.sh:
if [[ "$SESSION_TAGS" == *"#critical"* ]]; then
    IS_CRITICAL=true
    # Copy .jsonl file
fi
```

---

## Manual Backup

### Backup Existing Session

```bash
cd claude-intelligence-hub/claude-session-registry/scripts

# Prepare metadata JSON
SESSION_ID="338633b3-36fb-43c9-8bdd-701f93fba9f2"
METADATA=$(cat <<EOF
{
  "session_id": "$SESSION_ID",
  "date": "2026-02-12",
  "time": "14:30",
  "machine": "BR-SPO-DCFC264",
  "branch": "main",
  "commit": "a6f2536",
  "project": "/c/Users/jaderson.almeida/Downloads",
  "tags": "#critical #gdrive-sync",
  "summary": "Implemented Google Drive sync automation"
}
EOF
)

# Run backup
bash backup-session.sh "$SESSION_ID" "$METADATA"
```

### Retry Failed Backup

```bash
# Check tracking file for failed backups
cat claude-session-registry/backup-tracking.json | jq '.stats'

# Retry specific session
bash scripts/backup-session.sh "[session-id]" "$METADATA"
```

### Batch Backup Multiple Sessions

```bash
# Read registry file
cat claude-session-registry/registry/2026/02/SESSIONS.md | grep "claude-" | while read -r line; do
    SESSION_ID=$(echo "$line" | cut -d'|' -f2 | tr -d ' ')
    # Extract other fields...
    # Prepare metadata JSON
    # Call backup-session.sh
done
```

---

## Restore Procedures

See **[RESTORE_GUIDE.md](~/claude-session-backups/docs/RESTORE_GUIDE.md)** for detailed instructions.

### Quick Restore (Critical Sessions)

```bash
# 1. Copy .jsonl to project directory
cp critical/2026/02/[session-id].jsonl \
   ~/.claude/projects/[project-slug]/[session-id].jsonl

# 2. Navigate to original project directory
cd /c/Users/jaderson.almeida/Downloads

# 3. Resume session
claude --resume [session-id]
```

### Read-Only Access (All Sessions)

```bash
# View transcript
cat transcripts/2026/02/[session-id].md

# Search content
grep -r "keyword" transcripts/

# Use indexes
cat indexes/by-date/2026-02.md
cat indexes/by-tag/critical.md
```

---

## Troubleshooting

### Backup Failed - Session File Not Found

**Error:**
```
❌ Error: Session file not found: ~/.claude/projects/[...]/[id].jsonl
```

**Causes:**
- Session was deleted manually
- Project directory was moved/renamed
- Project slug calculation mismatch

**Fix:**
- Verify session exists: `ls ~/.claude/projects/*/[session-id].jsonl`
- If found in different location: update PROJECT path in metadata
- If deleted: cannot backup (markdown-only via manual transcript)

### Backup Failed - Git Push Error

**Error:**
```
❌ Error: Git push failed after 3 attempts
```

**Causes:**
- Network connectivity issue
- SSH key not configured
- GitHub authentication expired
- Repository not accessible

**Fix:**
```bash
# Manual push
cd ~/claude-session-backups
git push origin main

# Check authentication
ssh -T git@github.com

# Check remote
git remote -v
```

### Markdown Transcript Incomplete

**Symptoms:**
- Transcript missing messages
- Tool calls not shown
- Statistics incorrect

**Causes:**
- Malformed .jsonl file
- Parser script error
- Large messages truncated

**Debug:**
```bash
# Validate .jsonl integrity
jq empty ~/.claude/projects/[...]/[session-id].jsonl

# Run parser manually with verbose output
bash -x scripts/parse-jsonl-to-markdown.sh [args...]

# Check for parsing errors
cat /tmp/[temp-conv-file]
```

### Auto-Backup Not Triggering

**Check:**
1. `.metadata` → `auto_backup: true`?
2. Session registration completed Step 9?
3. Git push to registry successful?
4. Script exists: `scripts/backup-session.sh`?

**Debug:**
```bash
# Test backup manually
bash scripts/backup-session.sh "[session-id]" "$METADATA"

# Check tracking file
cat backup-tracking.json | jq
```

---

## Technical Details

### Parser Script Architecture

**File:** `scripts/parse-jsonl-to-markdown.sh`

**Input:**
- Session ID (UUID)
- .jsonl file path
- Output markdown path
- Metadata JSON string

**Process:**
1. Validate inputs
2. Read metadata fields (date, tags, summary, etc.)
3. Initialize counters (messages, tool calls)
4. Parse .jsonl line-by-line:
   - `type="user"` → Format as "### 👤 User [timestamp]"
   - `type="assistant"` → Extract thinking, text, tool_use
   - `type="tool_result"` → Show errors only (success too verbose)
   - `type="file-history-snapshot"` → Skip (noise)
5. Generate markdown with:
   - Frontmatter (YAML metadata)
   - Summary section
   - Conversation transcript
   - Statistics section
   - Links to registry/restore guide

**Tool Call Formatting:**
```bash
case "$TOOL_NAME" in
    Read)   echo "- 📖 **Read** → \`$FILE_PATH\`" ;;
    Write)  echo "- ✍️ **Write** → \`$FILE_PATH\`" ;;
    Edit)   echo "- ✏️ **Edit** → \`$FILE_PATH\`" ;;
    Bash)   echo "- 💻 **Bash** → \`$COMMAND...\`" ;;
    Grep)   echo "- 🔍 **Grep** → \`$PATTERN\`" ;;
    Glob)   echo "- 📁 **Glob** → \`$PATTERN\`" ;;
    Task)   echo "- 🤖 **Task** ($SUBAGENT) → \`$PROMPT...\`" ;;
esac
```

### Retry Logic Pattern

```bash
PUSH_SUCCESS=false
for attempt in 1 2 3; do
    if git push origin main 2>&1; then
        PUSH_SUCCESS=true
        break
    else
        if [ $attempt -lt 3 ]; then
            SLEEP_TIME=$((2 ** attempt))  # 2s, 4s, 8s
            sleep $SLEEP_TIME
        fi
    fi
done
```

**Pattern source:** `gdrive-sync-memoria/sync-gdrive.sh`

### Project Path to Slug Conversion

```bash
# Example: /c/Users/jaderson.almeida/Downloads
# → C--Users-jaderson-almeida-Downloads

PROJECT_SLUG=$(echo "$SESSION_PROJECT" | sed 's|^/||; s|:|--|g; s|/|-|g')

# Breakdown:
# s|^/||      - Remove leading /
# s|:|--|g    - Replace : with -- (Windows drive letters)
# s|/|-|g     - Replace / with -
```

### Index Format

**by-date/2026-02.md:**
```markdown
# Sessions: 2026-02

Auto-generated index of all sessions backed up in 2026-02.

- [2026-02-12] [`338633b3`](../../transcripts/2026/02/338633b3-...-701f93fba9f2.md) #critical #gdrive-sync - Implemented Google Drive sync...
- [2026-02-13] [`abc12345`](../../transcripts/2026/02/abc12345-...-xyz98765.md) #project - Updated documentation...
```

**by-tag/critical.md:**
```markdown
# Sessions: #critical

Auto-generated index of all sessions tagged with `#critical`.

- [2026-02-12] [`338633b3`](../../transcripts/2026/02/338633b3-...-701f93fba9f2.md) - Implemented Google Drive sync...
```

---

## Cost Analysis

**GitHub Free Tier:**
- ✅ Unlimited private repositories
- ✅ 500MB storage per repository
- ✅ Unlimited commits/pushes
- ✅ No bandwidth charges

**Storage Estimates:**
- Markdown transcript: ~10-50KB per session
- Critical .jsonl: ~100KB - 5MB per session (depends on conversation length)
- 100 sessions (50% critical): ~25MB total
- 1,000 sessions (20% critical): ~150MB total
- **500MB limit supports ~2,000-3,000 sessions**

**Cost:** $0 (completely free)

---

## Version History

### v1.0.0 (2026-02-13)

**Initial Release:**
- Markdown transcript generation for all sessions
- Raw .jsonl backups for critical sessions
- Auto-indexing by date, tag, machine
- Integration with claude-session-registry Step 9
- Retry logic for git push
- Non-blocking error handling
- Documentation (BACKUP_SYSTEM.md, RESTORE_GUIDE.md)

---

## Related Documentation

- [RESTORE_GUIDE.md](~/claude-session-backups/docs/RESTORE_GUIDE.md) - How to restore critical sessions
- [claude-session-registry/SKILL.md](../SKILL.md) - Session registration workflow
- [claude-session-backups/README.md](~/claude-session-backups/README.md) - Backup repository overview

---

**Maintained by:** Xavier (Claude Sonnet 4.5)
**Last Updated:** 2026-02-13
**Version:** 1.0.0
