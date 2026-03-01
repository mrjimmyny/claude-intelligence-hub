# Context Guardian

> Complete context preservation system for seamless Xavier ↔ Magneto account switching

**Version:** 1.0.1
**Status:** ✅ Production
**Owner:** Jimmy (xavier account)

---

## What is Context Guardian?

Context Guardian is a comprehensive backup and restore system that enables seamless switching between Claude Code accounts (Xavier and Magneto) by preserving:

1. **Global Configuration** - `~/.claude/` directory including settings, plugins, and skills
2. **Project Contexts** - Project-specific CLAUDE.md, MEMORY.md, and local skills
3. **Symlink Relationships** - Hub skills and hard links (with intelligent recreation)

Unlike `xavier-memory` (which only backs up MEMORY.md), Context Guardian backs up **everything** needed to switch accounts without losing context.

---

## Architecture

### 3-Layer Backup Structure

```
Google Drive: Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/
├─ MEMORY.md                    (xavier-memory, unchanged)
├─ backups/                     (xavier-memory, unchanged)
│
├─ bootstrap-magneto.ps1        (NEW: Self-contained restore script)
├─ LATEST_GLOBAL.json           (NEW: Global config metadata)
├─ PROJECTS_INDEX.json          (NEW: Project inventory)
│
├─ global/                      (NEW: Global config layer)
│  ├─ settings.json
│  ├─ plugins/
│  │  ├─ config.json
│  │  ├─ installed_plugins.json
│  │  ├─ known_marketplaces.json
│  │  └─ cache/ (optional)
│  └─ skills/
│     ├─ session-memoria/
│     ├─ gdrive-sync-memoria/
│     ├─ claude-session-registry/
│     └─ jimmy-core-preferences/
│
└─ projects/                    (NEW: Per-project backups)
   └─ {project-name}/
      ├─ CLAUDE.md
      ├─ MEMORY.md (if not hard link)
      ├─ metadata.json
      └─ local-skills/
```

### Key Features

- **3-Strategy Symlink Handling** - Developer Mode / Administrator / Copy fallback
- **Rollback Protection** - Auto-rollback on restore failure
- **Post-Restore Validation** - 5+ comprehensive checks
- **`.contextignore` Support** - Exclude node_modules, .git, etc.
- **Dry-Run Mode** - Preview changes without modifying files
- **Structured Logging** - All operations logged to `~/.claude/context-guardian/logs/`
- **Health Check Reports** - Reports saved to `~/.claude/context-guardian/reports/` and synced to Google Drive

---

## Quick Start

### For Xavier (Backup)

```bash
# Backup global config
"backup global config"

# Backup current project
"backup this project"

# Check backup health
"verify context backup"
```

### For Magneto (Restore)

```powershell
# Download bootstrap script from Google Drive
# Then run:
.\bootstrap-magneto.ps1

# Follow interactive menus to restore global config and/or projects
```

---

## Documentation

- **[SKILL.md](./SKILL.md)** - Workflows and usage guide
- **[GOVERNANCE.md](./GOVERNANCE.md)** - Backup policies and safety rules
- **[PHASE0_DISCOVERY_REPORT.md](./docs/PHASE0_DISCOVERY_REPORT.md)** - Environment baseline

---

## Implementation Status

### Phase 0: Discovery ✅ COMPLETE
- [x] Environment check (Windows 11, PowerShell 5.1, rclone 1.73.0)
- [x] Developer Mode detection
- [x] Skills inventory (4 hub symlinks)
- [x] Backup size estimates (68M total)
- [x] `.contextignore` template

### Phase 1: Foundation ✅ COMPLETE
- [x] Folder structure
- [x] JSON templates
- [x] Logging infrastructure
- [x] Documentation skeletons

### Phase 2-7: Implementation ✅ COMPLETE
- [x] Global config backup/restore (backup-global.sh, restore-global.sh)
- [x] Project context backup/restore (backup-project.sh, restore-project.sh)
- [x] Bootstrap script (bootstrap-magneto.ps1 - self-contained PowerShell)
- [x] Health checks (verify-backup.sh - 6 comprehensive checks + report output)
- [x] Integration & documentation (SKILL.md ~600 lines, GOVERNANCE.md)
- [x] End-to-end testing (14 bootstrap validation tests, Xavier → Magneto → Xavier flow)

---

## Requirements

- **Windows:** 10/11 (tested on Windows 11 Pro 10.0.26100)
- **PowerShell:** 5.1+ (tested on 5.1.26100.7705)
- **rclone:** 1.73.0+ with configured remote `gdrive-jimmy:`
- **Git:** For automatic commits (optional)
- **Developer Mode:** Recommended for symlink support (or run as Admin)

---

## Safety Features

- ✅ **No changes to existing systems** - xavier-memory unchanged
- ✅ **Rollback on failure** - Auto-restore previous state
- ✅ **Validation checks** - Verify integrity before marking success
- ✅ **Dry-run mode** - Preview without modifying files
- ✅ **Comprehensive logging** - Full audit trail

---

## Support

For issues or questions, contact Jimmy or check:
- [claude-intelligence-hub Issues](https://github.com/jadersonaires/claude-intelligence-hub/issues)
