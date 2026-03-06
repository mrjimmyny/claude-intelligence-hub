---
name: xavier-memory
version: 1.1.0
description: Global memory infrastructure - Cross-project persistent memory
command: /xavier-memory
aliases: [/xmemory]
---

# Xavier Memory Management - Skill Workflows

**Version:** 1.1.0
**Type:** Memory Sync & Backup
**Language:** pt-BR (Brazilian Portuguese)
**Platform:** Windows (NTFS hard links)

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Backup Workflow](#backup-workflow)
3. [Sync Workflow](#sync-workflow)
4. [Restore Workflow](#restore-workflow)
5. [Status Check Workflow](#status-check-workflow)
6. [Validation Rules](#validation-rules)
7. [Best Practices](#best-practices)

---

## 🎯 OVERVIEW

This skill enables Xavier to manage global memory (MEMORY.md) across all Claude projects with automatic backup to Git and Google Drive.

### Features
- **Hard Link Sync** - Real-time sync across all projects (same inode)
- **Git Version Control** - Automatic commit/push before backup
- **Google Drive Backup** - Offsite backup with local snapshots
- **Status Monitoring** - Verify hard link integrity and sync status
- **Emergency Restore** - Rollback from Git or Google Drive

### Architecture
```
Master: claude-intelligence-hub/xavier-memory/MEMORY.md
   ↓ (Hard Links - instant sync)
Projects: ~/.claude/projects/*/memory/MEMORY.md
   ↓ (Git commit + push)
GitHub: mrjimmyny/claude-intelligence-hub
   ↓ (rclone sync)
Google Drive: _critical_bkp_xavier_local_persistent_memory/
```

---

## 🔄 BACKUP WORKFLOW

**Triggers:**
- `"Xavier, backup memory"`
- `"X, faz backup da memória"`
- `"sincroniza memória global"`

### 7-Step Process

#### Step 1: Pre-flight Checks
```bash
# Verify master exists
[[ -f /c/ai/claude-intelligence-hub/xavier-memory/MEMORY.md ]] || exit 1

# Verify rclone configured
rclone listremotes | grep -q "^gdrive-jimmy:$" || exit 1
```

#### Step 2: Check Git Status
Navigate to claude-intelligence-hub and check for uncommitted changes:
```bash
cd /c/ai/claude-intelligence-hub
git status --porcelain xavier-memory/MEMORY.md
```

#### Step 3: Git Commit (if needed)
If uncommitted changes detected:
```bash
# Prompt user for commit message
echo "⚠️  Uncommitted changes detected"
read -p "Commit message: " COMMIT_MSG

# Commit and push
git add xavier-memory/MEMORY.md
git commit -m "feat(xavier-memory): $COMMIT_MSG"
git push origin main
```

#### Step 4: Create Local Backup
```bash
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR=/c/ai/claude-intelligence-hub/xavier-memory/backups
mkdir -p "$BACKUP_DIR"
cp xavier-memory/MEMORY.md "$BACKUP_DIR/MEMORY_${TIMESTAMP}.md"
```

#### Step 5: Sync to Google Drive
```bash
rclone copy \
    /c/ai/claude-intelligence-hub/xavier-memory/MEMORY.md \
    gdrive-jimmy:Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/ \
    --verbose --stats-one-line
```

#### Step 6: Verify Sync Success
```bash
# Check Google Drive file info
rclone lsl gdrive-jimmy:Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/MEMORY.md

# Verify sizes match
LOCAL_SIZE=$(stat -f%z xavier-memory/MEMORY.md)
REMOTE_SIZE=$(rclone lsl gdrive-jimmy:... | awk '{print $1}')
[[ $LOCAL_SIZE -eq $REMOTE_SIZE ]] || echo "⚠️ Size mismatch!"
```

#### Step 7: Cleanup Old Backups
Keep only last 10 local backups:
```bash
cd /c/ai/claude-intelligence-hub/xavier-memory/backups
ls -1t MEMORY_*.md | tail -n +11 | xargs -r rm
```

#### Step 8: Success Confirmation
Display summary:
```
✅ Backup completo!

📊 Resumo:
   Git: commit + push ✓
   Local backup: MEMORY_2026-02-16_01-30-00.md
   Google Drive: synced (7744 bytes)
   Status: SUCCESS
```

---

## 🔗 SYNC WORKFLOW

**Triggers:**
- `"Xavier, sync memory"`
- After editing master MEMORY.md manually

### Process

**Automatic Sync (Hard Links):**
- Hard links ensure instant sync - NO action needed
- Edit master → All projects update immediately

**Manual Verification:**
```bash
# Check hard link integrity
fsutil hardlink list C:\Users\...\xavier-memory\MEMORY.md

# Should show multiple paths (master + all projects)
```

---

## 🔙 RESTORE WORKFLOW

**Triggers:**
- `"Xavier, restore memory"`
- `"X, recupera backup da memória"`

### 6-Step Process

#### Step 1: Confirm Restore Operation
```
⚠️  RESTORE OPERATION REQUESTED

This will OVERWRITE current MEMORY.md with a backup.

Available sources:
  1. Local backups (last 10)
  2. Google Drive (latest)
  3. Git history (any commit)

Choose source:
```

#### Step 2: Backup Current State
```bash
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
cp xavier-memory/MEMORY.md xavier-memory/backups/MEMORY_pre-restore_${TIMESTAMP}.md
```

#### Step 3: Restore from Source

**From Local Backup:**
```bash
ls -1t backups/MEMORY_*.md | head -5  # Show recent backups
cp backups/MEMORY_2026-02-15_20-57-01.md xavier-memory/MEMORY.md
```

**From Google Drive:**
```bash
rclone copy \
    gdrive-jimmy:Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/MEMORY.md \
    /c/ai/claude-intelligence-hub/xavier-memory/
```

**From Git:**
```bash
git checkout <commit-hash> -- xavier-memory/MEMORY.md
```

#### Step 4: Verify Hard Links Still Work
```bash
# Hard links should propagate restore automatically
# Verify by checking project file updated
diff xavier-memory/MEMORY.md ~/.claude/projects/*/memory/MEMORY.md
```

#### Step 5: Git Commit Restored State
```bash
git add xavier-memory/MEMORY.md
git commit -m "restore: revert MEMORY.md from backup"
git push origin main
```

#### Step 6: Confirm Success
```
✅ Restore completo!

📊 Resumo:
   Source: [local backup | Google Drive | Git]
   Restored to: xavier-memory/MEMORY.md
   Hard links: propagated ✓
   Git: committed ✓
```

---

## 📊 STATUS CHECK WORKFLOW

**Triggers:**
- `"Xavier, memory status"`
- `"X, verifica status da memória"`

### Checks to Perform

#### Check 1: Master File Exists
```bash
[[ -f /c/ai/claude-intelligence-hub/xavier-memory/MEMORY.md ]] && echo "✓ Master found"
```

#### Check 2: Hard Link Integrity
```bash
# Count hard links
LINK_COUNT=$(fsutil hardlink list ... | wc -l)
echo "Hard links: $LINK_COUNT (expected: N projects + 1 master)"
```

#### Check 3: Git Status
```bash
cd /c/ai/claude-intelligence-hub
if [[ -n $(git status --porcelain xavier-memory/MEMORY.md) ]]; then
    echo "⚠️  Uncommitted changes"
else
    echo "✓ Git clean"
fi
```

#### Check 4: Last Backup Age
```bash
LAST_BACKUP=$(ls -1t backups/MEMORY_*.md | head -1)
BACKUP_AGE=$(( ($(date +%s) - $(stat -c%Y "$LAST_BACKUP")) / 3600 ))
echo "Last backup: ${BACKUP_AGE}h ago"

if [[ $BACKUP_AGE -gt 24 ]]; then
    echo "⚠️  Backup older than 24h - consider backing up"
fi
```

#### Check 5: Google Drive Connectivity
```bash
if rclone lsd gdrive-jimmy: &>/dev/null; then
    echo "✓ Google Drive reachable"
else
    echo "⚠️  Google Drive unreachable"
fi
```

#### Step 6: Display Status Summary
```
📊 Xavier Memory Status

Master File: ✓ Found (7744 bytes)
Hard Links: ✓ 3 active (master + 2 projects)
Git Status: ✓ Clean
Last Backup: 2h ago
Google Drive: ✓ Reachable
Overall: 🟢 HEALTHY
```

---

## ✅ VALIDATION RULES

### Pre-Backup Validations
- Master MEMORY.md exists and readable
- rclone remote `gdrive-jimmy` configured
- Git repository status clean OR user provides commit message
- Network connectivity for Google Drive

### Post-Backup Validations
- Local backup created with timestamp
- Google Drive file size matches local file
- Git commit created (if there were changes)
- Old backups cleaned (keep last 10)

### Hard Link Validations
- `fsutil hardlink list` shows N+1 paths (N projects + master)
- File sizes match exactly across all hard links
- Timestamps match exactly (same inode)

---

## 💡 BEST PRACTICES

### For Xavier (Claude)
1. **Always use sync-to-gdrive.sh** - Don't reinvent the backup workflow
2. **Verify before restore** - Backup current state first
3. **Check hard links** - Verify integrity before claiming sync works
4. **Git commit messages** - Use descriptive messages (e.g., "add Error #7: XYZ pattern")
5. **Monitor backup age** - Warn if last backup >24h old

### For Jimmy (User)
1. **Edit master only** - `claude-intelligence-hub/xavier-memory/MEMORY.md`
2. **Backup after major edits** - Run "Xavier, backup memory"
3. **Verify hard links** - Run setup_memory_junctions.bat if projects out of sync
4. **Keep backups current** - Backup at least once per day
5. **Test restore** - Verify restore procedure works quarterly

---

## 🔧 TROUBLESHOOTING

### Hard Links Not Working
```bash
# Re-run setup script
cd /c/ai/claude-intelligence-hub/xavier-memory
./setup_memory_junctions.bat

# Verify
fsutil hardlink list MEMORY.md
```

### Git Sync Fails
```bash
# Check network
git fetch origin main

# Check branch
git branch --show-current  # Should be "main"

# Check uncommitted changes
git status xavier-memory/MEMORY.md
```

### Google Drive Unreachable
```bash
# Test connectivity
rclone lsd gdrive-jimmy:

# Re-authenticate if needed
rclone config reconnect gdrive-jimmy:
```

---

## 🎯 SKILL METADATA

**Name:** xavier-memory
**Version:** 1.1.0
**Author:** Xavier (Claude)
**Created:** 2026-02-16
**Type:** Memory Management
**Language:** pt-BR (Brazilian Portuguese)
**Platform:** Windows (NTFS)

**Dependencies:**
- Git (version control)
- rclone (Google Drive sync)
- PowerShell (hard link creation)
- Bash (script execution)

**Triggers:**
- Backup: `"xavier, backup memory"`, `"x, faz backup da memória"`
- Sync: `"xavier, sync memory"` (hard links = automatic)
- Restore: `"xavier, restore memory"`, `"x, recupera backup"`
- Status: `"xavier, memory status"`, `"x, verifica memória"`

---

**END OF SKILL.md**
