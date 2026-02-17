# Context Guardian - Skill Documentation

> Complete context preservation system for Xavier ↔ Magneto account switching

**Version:** 1.0.0
**Type:** System Skill (Auto-invoked)
**Owner:** Jimmy (xavier)

---

## Natural Language Triggers

Context Guardian activates on these phrases (flexible matching):

### Backup Triggers
- "backup global config" / "backup claude settings"
- "backup this project" / "backup current project"

### Restore Triggers
- "restore global config" / "restore claude settings"
- "restore project [name]"

### Status Check Triggers
- "verify context backup" / "check backup health"

---

## Workflow 1: Backup Global Config

**Trigger:** "backup global config"

**What gets backed up:**
- `~/.claude/settings.json`
- `~/.claude/plugins/` (all config files + cache if <50 MB)
- `~/.claude/skills/user/*` (metadata for symlinks, full copy for directories)

**Steps:**

1. **Pre-flight Checks**
   - Verify rclone installed and remote configured
   - Check disk space (warn if <1 GB)
   - Calculate backup size (warn if >100 MB)

2. **Collect Files**
   - Copy settings.json
   - Copy plugins config files
   - Detect symlinks (3 types: hub, external, directory)

3. **Generate Metadata**
   - Calculate SHA256 checksums
   - Store symlink types and targets
   - Create `LATEST_GLOBAL.json`

4. **Local Backup**
   - Create timestamped archive: `backups/global_YYYYMMDD_HHMMSS.tar.gz`

5. **Sync to Google Drive**
   - Upload to `global/` folder
   - Verify checksums match

6. **Cleanup**
   - Keep last 10 local backups
   - Delete older backups

**Output:**
```
✅ Global config backed up successfully
   Files: 4 config files, 4 skills (symlinks)
   Size: 68M
   Location: Google Drive/Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/global/
   Duration: 12.3s
```

**Dry-Run:**
```bash
bash scripts/backup-global.sh --dry-run
```

---

## Workflow 2: Backup Project Context

**Trigger:** "backup this project"

**What gets backed up:**
- `CLAUDE.md` (if exists)
- `MEMORY.md` (if exists and NOT hard-linked to xavier-memory)
- `AUDIT_TRAIL.md` (if exists — critical file from repo-auditor skill)
- `.claude/skills/` (project-local skills)
- `.claude/commands/` (custom commands)

**Excluded (via `.contextignore`):**
- node_modules/, .git/, __pycache__/, dist/, build/
- Large binaries, media files, logs

**Steps:**

1. **Pre-flight Checks**
   - Auto-detect current project (use `pwd`)
   - Check for `.contextignore` (use template if missing)
   - Calculate size BEFORE backup (exclude ignored files)
   - Warn if >500 MB

2. **MEMORY.md Hard Link Detection**
   - Use `fsutil hardlink list` (Windows) or `stat` (Linux)
   - Check if linked to xavier-memory master
   - Store hard link metadata (do NOT backup file content if linked)

3. **Collect Files**
   - Copy CLAUDE.md
   - Copy MEMORY.md (if NOT hard link)
   - Copy local skills

4. **Generate Metadata**
   - Calculate checksums
   - Store hard link flag and target
   - Create `project-metadata.json`

5. **Update PROJECTS_INDEX.json**
   - Add or update project entry
   - Store path, size, last backup timestamp

6. **Sync to Google Drive**
   - Upload to `projects/{project-name}/`

**Output:**
```
✅ Project "my-app" backed up successfully
   Files: CLAUDE.md, MEMORY.md (hard link - skipped), 2 local skills
   Size: 1.2M (excluded 48M from node_modules)
   Location: Google Drive/.../projects/my-app/
```

---

## Workflow 3: Restore Global Config

**Trigger:** "restore global config"

**What gets restored:**
- All files from `global/` folder in Google Drive
- Symlinks recreated using 3-strategy approach

**Steps:**

1. **Pre-flight Checks**
   - Fetch `LATEST_GLOBAL.json` from Google Drive
   - Display last backup info (who, when, what)
   - Ask for confirmation (unless `--yes` flag)

2. **Create Rollback Point**
   - Backup current `~/.claude/` to `~/.claude_rollback_TIMESTAMP/`
   - Set error trap to auto-rollback on failure

3. **Download Files**
   - Fetch all files from `global/`
   - Verify checksums against metadata

4. **Restore Files**
   - Copy settings.json
   - Copy plugins config files
   - Restore skills (recreate symlinks)

5. **Recreate Symlinks (3 Strategies)**

   **Strategy 1: Developer Mode (Recommended)**
   - Try `New-Item -ItemType SymbolicLink`
   - No admin required
   - Works if Developer Mode enabled

   **Strategy 2: Administrator**
   - Same command, elevated privileges
   - Works if running as Admin

   **Strategy 3: Copy Fallback**
   - Copy directory instead of symlink
   - Warn user: "Skill was copied, not symlinked"
   - Offer `--fix-symlinks` later

6. **Post-Restore Validation (5 Checks)**
   - settings.json exists and valid JSON
   - Skills directory exists
   - Symlinks valid (no broken links)
   - Plugins config exists
   - Checksums match

7. **Cleanup or Rollback**
   - If validation passes: Delete rollback point
   - If validation fails: Trigger auto-rollback

**Output:**
```
✅ Global config restored successfully
   Restored by: xavier
   Backup date: 2026-02-16 10:30:00
   Files: 4 config files, 4 skills
   Symlinks: 4 created via Developer Mode
   Validation: PASSED (5/5 checks)
```

**Fix Symlinks Later:**
```powershell
.\bootstrap-magneto.ps1 --fix-symlinks
```

---

## Workflow 4: Restore Project Context

**Trigger:** "restore project [name]"

**Steps:**

1. **Pre-flight Checks**
   - Fetch `PROJECTS_INDEX.json` from Google Drive
   - If no project name specified: Show interactive menu

2. **Interactive Project Selection**
   ```
   Available projects:
   [1] my-app (Last backup: 2026-02-16 by xavier, Size: 1.2M)
   [2] other-project (Last backup: 2026-02-15 by xavier, Size: 500K)

   Select project [1-2]:
   ```

3. **Create Rollback Point**
   - Backup current project context to `.context-guardian-rollback_TIMESTAMP/`

4. **Download Files**
   - Fetch from `projects/{project-name}/`
   - Verify checksums

5. **Handle MEMORY.md Hard Links**
   - Check metadata for `is_hard_link` flag
   - If master exists: SKIP restore (warn user)
   - If master missing: Restore as regular file, warn about broken link

6. **Restore Files**
   - Copy CLAUDE.md
   - Copy MEMORY.md (if not hard link)
   - Copy local skills

7. **Post-Restore Validation**
   - CLAUDE.md exists (if expected)
   - MEMORY.md exists (if expected and not skipped)
   - Local skills directory exists
   - Checksums match

8. **Cleanup or Rollback**
   - Delete rollback on success
   - Auto-rollback on failure

**Output:**
```
✅ Project "my-app" restored successfully
   Files: CLAUDE.md, MEMORY.md (skipped - hard link exists), 2 local skills
   Validation: PASSED (4/4 checks)

   ⚠️  MEMORY.md was skipped because it's a hard link to xavier-memory master.
       If you need to restore it, manually copy from backup.
```

---

## Workflow 5: Bootstrap for Magneto (PowerShell)

**Trigger:** Manual execution on Magneto account

**Usage:**
```powershell
.\bootstrap-magneto.ps1
```

**Steps:**

1. **Dependency Check**
   - Verify rclone installed
   - Verify remote `gdrive-jimmy:` configured
   - Guide user to install/configure if missing

2. **Permission Check**
   - Check Developer Mode status
   - Check if running as Administrator
   - Offer options if neither:
     - [D] Enable Developer Mode (opens Settings)
     - [A] Restart as Administrator
     - [C] Continue with copy fallback
     - [Q] Quit

3. **Fetch Metadata**
   - Download `LATEST_GLOBAL.json` from Google Drive
   - Download `PROJECTS_INDEX.json`
   - Display last backup info

4. **Interactive Menu**
   ```
   What would you like to restore?
   [1] Global config only
   [2] Global config + select projects
   [3] Specific project only
   [4] Exit
   ```

5. **Restore Based on Selection**
   - Follow Workflow 3 (global) or Workflow 4 (project)
   - Use 3-strategy symlink recreation
   - Validate after restore

6. **Display Symlink Warnings**
   - If any skills were copied (fallback mode):
     ```
     ⚠️  SYMLINK WARNINGS:
     - session-memoria was copied instead of symlinked
     - gdrive-sync-memoria was copied instead of symlinked

     To convert to symlinks later:
     1. Enable Developer Mode (Settings > For Developers)
     2. Run: .\bootstrap-magneto.ps1 --fix-symlinks
     ```

**Fix Symlinks Command:**
```powershell
.\bootstrap-magneto.ps1 --fix-symlinks
```

- Reads `LATEST_GLOBAL.json` for symlink metadata
- Deletes copied directories
- Recreates as symlinks (requires Developer Mode or Admin)

---

## Workflow 6: Status Check / Verify Backup

**Trigger:** "verify context backup"

**Checks:**

1. **Google Drive Connectivity**
   - Test connection to `gdrive-jimmy:`
   - Result: ✅ CONNECTED or ❌ FAILED

2. **Metadata Integrity**
   - Parse `LATEST_GLOBAL.json` and `PROJECTS_INDEX.json`
   - Result: ✅ VALID JSON or ❌ CORRUPTED

3. **Backup Age**
   - Check last backup timestamp
   - Result: ✅ FRESH (<7 days) or ⚠️ STALE (>7 days)

4. **Checksum Verification**
   - Compare local files vs metadata checksums
   - Result: ✅ MATCH or ❌ MISMATCH

5. **Size Check**
   - Check global config size (<100 MB)
   - Check project sizes (<500 MB)
   - Result: ✅ REASONABLE or ⚠️ LARGE

6. **Broken Symlinks**
   - Detect broken symlinks in `~/.claude/skills/user/`
   - Result: ✅ ALL VALID or ❌ BROKEN (list them)

**Output:**
```
Context Backup Health Report
============================================================
✅ Google Drive: CONNECTED
✅ Metadata: VALID JSON
✅ Backup Age: FRESH (backed up 2 days ago)
✅ Checksums: MATCH (4/4 files)
✅ Size: REASONABLE (68M global, 1.2M projects)
✅ Symlinks: ALL VALID (4/4 skills)

Overall Status: ✅ HEALTHY
============================================================
```

---

## Troubleshooting

### Problem: Symlinks not created (Windows)

**Cause:** Developer Mode disabled, not running as Admin

**Fix:**
1. Enable Developer Mode: Settings > Privacy & Security > For Developers > Toggle ON
2. OR run scripts as Administrator
3. OR use copy fallback (run `--fix-symlinks` later)

### Problem: MEMORY.md not restored

**Cause:** Hard link detected, master file exists (skip to avoid breaking link)

**Fix:**
- This is intentional to protect xavier-memory master
- If you need to restore: Manually copy from backup
- To recreate hard link: Run `xavier-memory/setup_memory_junctions.bat`

### Problem: Backup too large (>500 MB)

**Cause:** Project includes node_modules, .git, dist, etc.

**Fix:**
1. Create `.contextignore` in project root
2. Copy from template: `context-guardian/templates/.contextignore.template`
3. Add patterns to exclude large files
4. Re-run backup

### Problem: Restore validation failed

**Cause:** Corrupted download, invalid JSON, missing files

**Fix:**
- Auto-rollback should trigger automatically
- If not, manually restore from `~/.claude_rollback_TIMESTAMP/`
- Check logs in `~/.claude/context-guardian/logs/`
- Re-download from Google Drive

### Problem: Google Drive sync failed

**Cause:** Network issue, rclone not authenticated

**Fix:**
1. Check internet connection
2. Test rclone: `rclone ls gdrive-jimmy:Claude/`
3. Re-authenticate: `rclone config reconnect gdrive-jimmy:`

---

## Advanced Usage

### Dry-Run Mode

Preview changes without modifying files:

```bash
# Backup dry-run
bash scripts/backup-global.sh --dry-run
bash scripts/backup-project.sh --dry-run

# Restore dry-run
bash scripts/restore-global.sh --dry-run
bash scripts/restore-project.sh --dry-run --project-name my-app
```

### Custom Exclusions (.contextignore)

Create `.contextignore` in project root:

```
# My custom exclusions
node_modules/
.git/
dist/
*.log
large-dataset/
```

### Manual Cleanup

```bash
# View local backups
ls -lh ~/.claude/context-guardian/backups/

# Delete old backup
rm -rf ~/.claude/context-guardian/backups/global_20260101_103000/

# View Google Drive backups
rclone ls gdrive-jimmy:Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/global/

# Delete old remote backup
rclone delete gdrive-jimmy:Claude/.../global/settings_20260101.json
```

### Logs

```bash
# View recent logs
ls -lt ~/.claude/context-guardian/logs/ | head -10

# Tail current operation log
tail -f ~/.claude/context-guardian/logs/backup-global_20260216_103000.log

# Search for errors
grep ERROR ~/.claude/context-guardian/logs/*.log
```

---

## Script Reference

### Backup Scripts

**`scripts/backup-global.sh`**
- Backs up global Claude config
- Flags: `--dry-run`
- Logs to: `logs/backup-global_TIMESTAMP.log`

**`scripts/backup-project.sh`**
- Backs up current project context
- Flags: `--dry-run`
- Logs to: `logs/backup-project_TIMESTAMP.log`

### Restore Scripts

**`scripts/restore-global.sh`**
- Restores global Claude config
- Flags: `--dry-run`, `--yes` (skip confirmation)
- Logs to: `logs/restore-global_TIMESTAMP.log`

**`scripts/restore-project.sh`**
- Restores project context
- Flags: `--dry-run`, `--project-name <name>`, `--yes`
- Logs to: `logs/restore-project_TIMESTAMP.log`

### Bootstrap Script

**`scripts/bootstrap-magneto.ps1`**
- Self-contained restore for Magneto
- Flags: `--fix-symlinks`
- Logs to: PowerShell transcript in `logs/`

### Health Check Script

**`scripts/verify-backup.sh`**
- Verifies backup health
- Flags: `--local-only` (skip Google Drive check)
- Logs to: `logs/verify-backup_TIMESTAMP.log`

---

## See Also

- [README.md](./README.md) - Architecture overview
- [GOVERNANCE.md](./GOVERNANCE.md) - Backup policies and safety rules
- [xavier-memory](../xavier-memory/) - MEMORY.md backup system (unchanged)

---

**Last Updated:** 2026-02-16
**Status:** ✅ Production (v1.0.0 - All phases complete)
