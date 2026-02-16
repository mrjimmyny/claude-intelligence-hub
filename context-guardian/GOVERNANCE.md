# Context Guardian - Governance

> Backup policies, triggers, safety rules, and retention policies

**Version:** 1.0.0
**Last Updated:** 2026-02-16

---

## Backup Policies

### Global Config Backup

**What is backed up:**
- `~/.claude/settings.json`
- `~/.claude/plugins/config.json`
- `~/.claude/plugins/installed_plugins.json`
- `~/.claude/plugins/known_marketplaces.json`
- `~/.claude/plugins/cache/` (if <50 MB)
- `~/.claude/skills/user/*` (with symlink metadata)

**When to backup:**
- Manual trigger: `"backup global config"`
- Before major system changes (OS upgrade, account migration)
- After installing new skills or plugins
- Weekly recommended for active development

**Retention:**
- **Local:** Keep last 10 timestamped backups
- **Google Drive:** Keep all backups (manual cleanup)
- **Recommended:** Monthly archive cleanup (keep 1 per month for >3 months old)

### Project Context Backup

**What is backed up:**
- `CLAUDE.md` (if exists)
- `MEMORY.md` (if exists and not a hard link to xavier-memory master)
- `.claude/skills/` (project-local skills)
- `.claude/commands/` (custom commands)
- **Excluded by default:** node_modules/, .git/, __pycache__/, dist/, build/

**When to backup:**
- Manual trigger: `"backup this project"`
- Before switching to another account
- After major project changes (architecture refactor, new features)
- Before destructive operations (branch deletion, force push)

**Retention:**
- **Local:** Keep last 5 backups per project
- **Google Drive:** Keep all backups
- **Recommended:** Archive old projects (move to `archived_projects/`)

---

## Automatic Triggers

### Natural Language Triggers

Context Guardian responds to these phrases (no exact match required):

**Global Config:**
- "backup global config"
- "backup claude settings"
- "backup my configuration"
- "save my claude setup"

**Project Context:**
- "backup this project"
- "backup current project"
- "save project context"

**Restore:**
- "restore global config"
- "restore claude settings"
- "restore project [name]"

**Status Check:**
- "verify context backup"
- "check backup health"
- "context backup status"

### Pre-flight Checks (Always Run)

Before ANY backup operation:
1. Check rclone connectivity
2. Verify Google Drive remote configured
3. Check disk space (warn if <1 GB free)
4. Verify Git status (if repo, offer to commit first)

---

## Safety Rules

### 🔴 NEVER Backup (Hardcoded Exclusions)

- Secrets and credentials (.env, credentials.json, *.key, *.pem)
- Large media files (>100 MB per file)
- System files (pagefile.sys, hiberfil.sys)
- Windows reserved names (CON, PRN, AUX, NUL, COM*, LPT*)

### ⚠️ Warn Before Backup

- Projects >500 MB (suggest .contextignore additions)
- Global config >100 MB (investigate large files)
- Hard links to master files (warn about breaking links)

### ✅ Auto-Rollback Triggers

Restore will automatically rollback if:
1. Checksum verification fails
2. JSON validation fails (invalid settings.json)
3. Symlink creation fails (all 3 strategies exhausted)
4. Critical files missing after restore
5. Post-restore validation fails (5+ checks)

---

## Symlink Handling Policy

### Backup Phase

**Detection:**
- Check if skill is a symlink using `readlink -f`
- Determine link type: hub_skill, external, or directory

**Metadata Storage:**
```json
{
  "skill_name": "session-memoria",
  "is_symlink": true,
  "link_type": "hub_skill",
  "hub_path": "session-memoria",
  "absolute_target": "/c/Users/jaderson.almeida/Downloads/claude-intelligence-hub/session-memoria"
}
```

**Backup Method:**
- **Hub skills:** Store metadata only (no file copy)
- **External symlinks:** Store metadata + warn user
- **Directories:** Full file backup

### Restore Phase

**3-Strategy Recreation:**

1. **Strategy 1: Developer Mode**
   - Try creating symlink with `New-Item -ItemType SymbolicLink`
   - No admin required
   - Recommended approach

2. **Strategy 2: Administrator**
   - Same command, but with elevated privileges
   - Use if Developer Mode disabled

3. **Strategy 3: Copy Fallback**
   - If both fail, copy directory instead
   - Warn user: "Skill was copied, not symlinked - updates won't sync"
   - Offer `--fix-symlinks` command later

**Post-Restore Fix:**
```powershell
.\bootstrap-magneto.ps1 --fix-symlinks
```
- Removes copied directories
- Recreates as symlinks (requires Developer Mode or Admin)

---

## Hard Link Handling Policy

### MEMORY.md Hard Links

**Detection:**
- Use `fsutil hardlink list` (Windows) or `stat -c %i` (Linux)
- Check if MEMORY.md is hard-linked to xavier-memory master

**Backup:**
- Store hard link metadata in project metadata.json
- **Do NOT backup file content** (already in xavier-memory)

**Restore:**
- **If master exists:** Skip restore, warn user not to overwrite
- **If master missing:** Restore as regular file, warn that hard link is broken
- **Fix:** Run `xavier-memory/setup_memory_junctions.bat` to recreate hard links

---

## Retention and Cleanup

### Local Backups

**Location:** `~/.claude/context-guardian/backups/`

**Automatic Cleanup:**
- Global config: Keep last 10 backups
- Projects: Keep last 5 backups per project
- Cleanup runs at end of each backup operation

**Manual Cleanup:**
```bash
# View backup sizes
du -sh ~/.claude/context-guardian/backups/*

# Delete old backups
rm -rf ~/.claude/context-guardian/backups/global_20260101_*
```

### Google Drive Backups

**Location:** `My Drive/Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/`

**Manual Cleanup (Recommended):**
- Monthly: Review and delete backups >3 months old
- Keep 1 backup per month for historical reference
- Archive old projects to `archived_projects/`

**Commands:**
```bash
# List remote backups
rclone ls gdrive-jimmy:Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/global/

# Delete old backup
rclone delete gdrive-jimmy:Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/global/settings_20260101.json
```

---

## Validation and Health Checks

### Backup Validation

After each backup:
1. Calculate SHA256 checksums for all files
2. Verify rclone sync completed successfully
3. Compare local vs remote file sizes
4. Store metadata (timestamp, owner, checksums)

### Restore Validation (5 Checks)

After each restore:
1. **settings.json exists and valid JSON**
2. **Skills directory exists** (with expected count)
3. **Symlinks valid** (no broken links)
4. **Plugins config exists** (warn if missing)
5. **Checksums match metadata**

### Health Check Schedule

**Manual:** `"verify context backup"`

**Checks:**
1. Google Drive connectivity
2. Metadata integrity (JSON parsing)
3. Backup age (warn if >7 days)
4. Checksum verification
5. Size check (warn if >100 MB global, >500 MB project)
6. Broken symlinks (detect and report)

---

## Dry-Run Mode

All scripts support `--dry-run` flag:

```bash
# Preview global backup
bash scripts/backup-global.sh --dry-run

# Preview project restore
bash scripts/restore-project.sh --dry-run --project-name my-project
```

**Behavior:**
- Show what WOULD be backed up/restored
- NO files modified
- NO rclone operations
- Still creates logs (marked as DRY-RUN)

---

## Logging Policy

### Log Location
`~/.claude/context-guardian/logs/`

### Log Retention
- Keep last 30 days of logs
- Auto-cleanup on 1st of each month
- Critical errors logged to separate `errors.log`

### Log Format
```
[2026-02-16 10:30:45] [INFO] Starting global config backup
[2026-02-16 10:30:46] [SUCCESS] Backup completed: 68M in 12.3s
[2026-02-16 10:30:46] [SUMMARY] success: Global config backed up successfully
```

---

## Emergency Procedures

### Restore Failed - Manual Rollback

If restore fails and auto-rollback doesn't work:

```bash
# Find rollback directory
ls -la ~/.claude_rollback_*

# Manually restore
rm -rf ~/.claude
mv ~/.claude_rollback_20260216_103000 ~/.claude
```

### Broken Symlinks After Restore

```powershell
# Check for broken symlinks
Get-ChildItem -Path "$env:USERPROFILE\.claude\skills\user" | Where-Object {$_.LinkType -eq "SymbolicLink" -and -not (Test-Path $_.Target)}

# Fix with bootstrap
.\bootstrap-magneto.ps1 --fix-symlinks
```

### Lost Google Drive Access

If Google Drive is unavailable:

1. Use local backups: `~/.claude/context-guardian/backups/`
2. Verify backup integrity: `bash scripts/verify-backup.sh --local-only`
3. Restore from local: `bash scripts/restore-global.sh --source local`

---

## Approval and Changes

### Governance Changes

Changes to this document require:
- Review by Jimmy (xavier)
- Testing on non-production account
- Documentation update in CHANGELOG.md
- Git commit with message: "governance: [change description]"

### Policy Exceptions

Temporary exceptions (e.g., backup large project >500 MB):
- Must be logged in project metadata
- Document reason in backup commit message
- Review after 30 days

---

**Last Reviewed:** 2026-02-16
**Next Review:** 2026-03-16
