---
name: xavier-memory-sync
version: 1.0.0
description: Memory sync automation - Google Drive integration
command: /xavier-sync
aliases: [/sync-memory]
---

# Xavier Memory Sync Skill

**Version:** 1.0.0

**Trigger Phrases**:
- "Xavier, sync memory"
- "Xavier, backup memory"
- "Xavier, restore memory"
- "Xavier, memory status"
- "X, sync mem"

---

## When to Use This Skill

Use this skill when:
- User explicitly asks to sync/backup Xavier's memory
- After making significant updates to MEMORY.md
- Before important operations (as a safety net)
- When setting up new machines or projects

---

## What This Skill Does

### Trigger: "sync memory"
1. Runs hard link verification across all projects
2. Syncs MEMORY.md to Google Drive
3. Creates local backup snapshot
4. Reports sync status

### Trigger: "backup memory"
1. Creates local backup with timestamp
2. Syncs to Google Drive
3. Confirms backup location

### Trigger: "restore memory"
1. Lists available backups (local + Google Drive)
2. Prompts user to select which backup to restore
3. Restores selected backup to master MEMORY.md
4. Re-syncs to all projects

### Trigger: "memory status"
1. Shows master MEMORY.md location and size
2. Lists all project hard links (with verification)
3. Shows last Google Drive sync time
4. Reports local backup count

---

## Implementation Steps

### STEP 1: Detect Trigger
When user message contains any trigger phrase, activate this skill.

### STEP 2: Determine Action
Parse which specific action requested:
- "sync" → Full sync (all projects + Google Drive)
- "backup" → Google Drive backup only
- "restore" → Interactive restore from backups
- "status" → Report current state

### STEP 3: Execute Action

#### Action: SYNC MEMORY
```bash
# 1. Verify master exists
MASTER="/c/ai/claude-intelligence-hub/xavier-memory/MEMORY.md"
if [[ ! -f "$MASTER" ]]; then
    echo "ERROR: Master MEMORY.md not found"
    exit 1
fi

# 2. Verify hard links in all projects
echo "Verifying hard links..."
for project in ~/.claude/projects/*/memory; do
    if [[ -f "$project/MEMORY.md" ]]; then
        # Check if same inode (hard link)
        master_inode=$(stat -c %i "$MASTER")
        project_inode=$(stat -c %i "$project/MEMORY.md")
        if [[ "$master_inode" == "$project_inode" ]]; then
            echo "  ✓ $(basename $(dirname $project)): Hard linked"
        else
            echo "  ✗ $(basename $(dirname $project)): NOT linked (manual fix needed)"
        fi
    fi
done

# 3. Sync to Google Drive
echo ""
echo "Syncing to Google Drive..."
cd /c/ai/claude-intelligence-hub/xavier-memory
./sync-to-gdrive.sh

echo ""
echo "✅ Memory sync complete!"
```

#### Action: BACKUP MEMORY
```bash
cd /c/ai/claude-intelligence-hub/xavier-memory
./sync-to-gdrive.sh
```

#### Action: RESTORE MEMORY
```bash
echo "Available backups:"
echo ""
echo "LOCAL:"
ls -1t /c/ai/claude-intelligence-hub/xavier-memory/backups/MEMORY_*.md | head -5

echo ""
echo "GOOGLE DRIVE:"
rclone ls gdrive-jimmy:_critical_bkp_xavier_local_persistent_memory/ | grep MEMORY

echo ""
read -p "Enter backup filename to restore (or 'cancel'): " backup_file

if [[ "$backup_file" != "cancel" ]]; then
    # Restore logic here
    echo "Restoring from $backup_file..."
    # Implementation needed
fi
```

#### Action: MEMORY STATUS
```bash
MASTER="/c/ai/claude-intelligence-hub/xavier-memory/MEMORY.md"

echo "================================================================"
echo "Xavier Memory Status"
echo "================================================================"
echo ""

# Master info
echo "Master MEMORY.md:"
echo "  Location: $MASTER"
echo "  Size: $(stat -c %s "$MASTER" 2>/dev/null || echo "unknown") bytes"
echo "  Last modified: $(stat -c %y "$MASTER" 2>/dev/null | cut -d. -f1)"
echo ""

# Project links
echo "Project Hard Links:"
for project in ~/.claude/projects/*/memory; do
    if [[ -f "$project/MEMORY.md" ]]; then
        project_name=$(basename $(dirname $project))
        master_inode=$(stat -c %i "$MASTER" 2>/dev/null)
        project_inode=$(stat -c %i "$project/MEMORY.md" 2>/dev/null)
        if [[ "$master_inode" == "$project_inode" ]]; then
            echo "  ✓ $project_name"
        else
            echo "  ✗ $project_name (NOT linked!)"
        fi
    fi
done
echo ""

# Google Drive status
echo "Google Drive Backup:"
gdrive_info=$(rclone lsl gdrive-jimmy:_critical_bkp_xavier_local_persistent_memory/MEMORY.md 2>/dev/null)
if [[ -n "$gdrive_info" ]]; then
    echo "  ✓ Synced"
    echo "  $gdrive_info"
else
    echo "  ✗ Not found or not synced"
fi
echo ""

# Local backups
backup_count=$(ls -1 /c/ai/claude-intelligence-hub/xavier-memory/backups/MEMORY_*.md 2>/dev/null | wc -l)
echo "Local Backups: $backup_count"
if [[ $backup_count -gt 0 ]]; then
    echo "  Latest: $(ls -1t /c/ai/claude-intelligence-hub/xavier-memory/backups/MEMORY_*.md | head -1)"
fi
echo ""
echo "================================================================"
```

---

## Safety Rules

1. **NEVER delete master MEMORY.md** without explicit user confirmation
2. **ALWAYS create backup** before any restore operation
3. **VERIFY hard links** before reporting success
4. **PRESERVE local backups** (keep last 10)
5. **CHECK Google Drive connectivity** before sync

---

## Error Handling

### Error: Master MEMORY.md not found
```
→ Check if /c/ai/claude-intelligence-hub/xavier-memory/MEMORY.md exists
→ If missing, restore from Google Drive backup
→ Report to user immediately
```

### Error: Hard link broken
```
→ Report which project has broken link
→ Suggest running: /c/ai/claude-intelligence-hub/xavier-memory/setup_memory_junctions.bat
→ Do NOT auto-fix (requires user approval)
```

### Error: Google Drive sync failed
```
→ Check rclone config: rclone listremotes
→ Test connectivity: rclone lsd gdrive-jimmy:
→ Report error details to user
→ Local operations should still succeed
```

---

## Success Criteria

- ✅ All project hard links verified
- ✅ Google Drive sync completed
- ✅ Local backup created with timestamp
- ✅ Status report generated
- ✅ No errors in sync log

---

## Example Usage

**User**: "Xavier, sync memory"

**Xavier Response**:
```
🧠 Syncing Xavier Memory...

Verifying hard links:
  ✓ C--Users-{USERNAME}-Downloads: Hard linked
  ✓ C--Users-{USERNAME}-Downloads--pbi-projs--project-pbip-hr-kpis-board-v2: Hard linked

Syncing to Google Drive:
  ✓ Local backup: backups/MEMORY_2026-02-15_19-45-32.md
  ✓ Google Drive: _critical_bkp_xavier_local_persistent_memory/MEMORY.md
  ✓ Sync completed (6.2 KB transferred)

✅ Memory sync complete! All systems in sync.
```

---

## Related Files

- Master: `/c/ai/claude-intelligence-hub/xavier-memory/MEMORY.md`
- Sync script: `/c/ai/claude-intelligence-hub/xavier-memory/sync-to-gdrive.sh`
- Junction setup: `/c/ai/claude-intelligence-hub/xavier-memory/setup_memory_junctions.bat`
- Backups: `/c/ai/claude-intelligence-hub/xavier-memory/backups/`

---

**Version**: 1.0.0
**Created**: 2026-02-15
**Type**: Infrastructure Skill
**Auto-invocable**: Yes (on trigger phrases)
