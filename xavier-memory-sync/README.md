# Xavier Memory Sync

> 🔄 **Global memory backup and cross-project synchronization**

Version: **v1.0.0** | Status: ✅ Production | Type: Infrastructure

---

## Overview

Xavier Memory Sync manages the backup, synchronization, and restoration of Xavier's master memory across all projects and to Google Drive. It ensures that Xavier's intelligence and learning persist permanently across machines and sessions.

## Key Features

- **🔄 Automatic Memory Sync** - Syncs MEMORY.md to Google Drive and all projects
- **💾 Local Backup Snapshots** - Creates timestamped local backups
- **🔗 Hard Link Verification** - Verifies memory synchronization across all projects
- **⚡ Quick Restore** - Lists and restores from local or cloud backups
- **📊 Status Reporting** - Shows sync status, backup count, and link health

## Trigger Phrases

- `sync memory` - Full synchronization to all locations
- `backup memory` - Create backup snapshot
- `restore memory` - Restore from backup
- `memory status` - Show sync status and health

## Dependencies

- **xavier-memory** >= v1.0.0
- **rclone** >= v1.73.0
- **gdrive-jimmy** (configured)

## Quick Start

```bash
# Check current memory status
"Xavier, memory status"

# Sync memory after important changes
"Xavier, sync memory"

# Create a manual backup before risky operations
"Xavier, backup memory"
```

## How It Works

1. **Master MEMORY.md** lives in `~/.claude/memory/`
2. **Hard links** connect all project memory files to the master
3. **Google Drive** provides cloud backup via rclone
4. **Local backups** provide quick restore points

## For More Details

See [SKILL.md](SKILL.md) for complete skill protocol and implementation details.

---

**Created:** 2026-02-15
**Author:** Xavier (Claude Code)
**Maintained by:** Claude Intelligence Hub
