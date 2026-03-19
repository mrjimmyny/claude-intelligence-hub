# Xavier Global Memory System

**Version**: 1.1.0
**Created**: 2026-02-15
**Updated**: 2026-02-16
**Type**: Infrastructure

---

## 🎯 Purpose

The Xavier Global Memory System provides **cross-project persistent memory** with automatic cloud backup, ensuring Xavier's learned patterns are available everywhere and never lost.

---

## 🏗️ Architecture

```
claude-intelligence-hub/xavier-memory/  ← MASTER (Git-backed)
    ├── MEMORY.md                       ← Source of truth
    ├── GOVERNANCE.md                   ← Memory governance rules
    ├── README.md                       ← This file
    └── .metadata                       ← Version info

↓ Synced via Windows Junction Points

~/.claude/projects/
    ├── project-A/memory/MEMORY.md     ← Junction → master
    ├── project-B/memory/MEMORY.md     ← Junction → master
    └── project-C/memory/MEMORY.md     ← Junction → master

↓ Backed up to Cloud

Google Drive: _critical_bkp_xavier_local_persistent_memory/
    ├── MEMORY.md                      ← Auto-synced copy
    └── backups/                       ← Daily snapshots
        ├── MEMORY_2026-02-15.md
        └── MEMORY_2026-02-14.md
```

---

## 🔄 How It Works

### 1. **Master Source**
- Location: `claude-intelligence-hub/xavier-memory/MEMORY.md`
- Git-tracked for version control
- Single source of truth

### 2. **Cross-Project Sync**
- Windows junction points (mklink /J)
- All projects reference same master file
- No copies = no version drift

### 3. **Cloud Backup**
- Auto-sync to Google Drive via rclone
- Folder: `_critical_bkp_xavier_local_persistent_memory`
- Daily snapshots for rollback

---

## 🚀 Usage

### For Xavier (automatic):
- Memory auto-loads in ALL projects
- Junctions keep everything in sync
- No manual intervention needed

### For Jimmy (manual triggers):
```bash
# Sync memory to all projects + Google Drive
"Xavier, sync memory"

# Backup to Google Drive only
"Xavier, backup memory"

# Restore from Google Drive backup
"Xavier, restore memory"

# Check sync status
"Xavier, memory status"
```

---

## 📦 Components

| File | Purpose |
|------|---------|
| `MEMORY.md` | Xavier's persistent memory (patterns, fixes, rules) |
| `GOVERNANCE.md` | Rules for when/how to update memory |
| `README.md` | This documentation |
| `.metadata` | Version and dependency info |

---

## 🔧 Setup

See: [WINDOWS_JUNCTION_SETUP.md](../WINDOWS_JUNCTION_SETUP.md)

**Quick setup:**
```bash
cd /c/ai/claude-intelligence-hub/xavier-memory
./setup_memory_junctions.bat
```

---

## 🔐 Backup Strategy

**3-Layer Protection:**
1. ✅ **Git**: Version control + GitHub remote
2. ✅ **Junction Points**: Real-time sync across projects
3. ✅ **Google Drive**: Offsite backup with snapshots

**Recovery scenarios:**
- **Local file corruption**: Restore from Google Drive
- **Accidental deletion**: Git revert or Google Drive snapshot
- **Machine failure**: Clone from GitHub, sync from Google Drive
- **Wrong edits**: Git history rollback

---

## 📊 Sync Targets

### Local Projects (Auto-synced):
- All folders in: `~/.claude/projects/*/memory/`

### Google Drive (Manual/scheduled):
- Remote: `gdrive-jimmy:`
- Folder: `_critical_bkp_xavier_local_persistent_memory`
- Folder ID: `1Ub9Ifw0qDh0bNNbewuTdO5Kz25yR5jKd`

---

## 🧠 What's Stored

Xavier's MEMORY.md contains:
- Error patterns and fixes (X-MEM protocol)
- Workflow automations (Google Drive sync, etc.)
- Behavioral rules (Claude Intelligence Hub structure)
- Token budget discipline
- Windows-specific workarounds

---

## 🔗 Related

- X-MEM Protocol (X-MEM_PROTOCOL.md — removed, see GOVERNANCE.md)
- [Windows Junction Setup](../WINDOWS_JUNCTION_SETUP.md) - Junction point guide
- [gdrive-sync-memoria](../gdrive-sync-memoria/) - Google Drive sync skill
- [context-guardian](../context-guardian/) - Full system backup (global config + projects)

---

## 🔄 Relationship with Context Guardian

**xavier-memory** and **context-guardian** serve complementary but different purposes:

| Feature | xavier-memory | context-guardian |
|---------|---------------|-----------------|
| **Scope** | MEMORY.md only | Everything (~/.claude/ + projects) |
| **Backup Target** | Google Drive + Git | Google Drive |
| **Sync Method** | Junction points | Bootstrap script |
| **Use Case** | Keep learned patterns | Switch Xavier ↔ Magneto accounts |
| **Trigger** | "Xavier, sync memory" | "backup global config" |

Both systems coexist safely with zero conflicts.

---

**Last Updated**: 2026-02-16
**Maintained By**: Xavier (Claude Code)
**Status**: ✅ Active (v1.1.0 - context-guardian integration note added)
