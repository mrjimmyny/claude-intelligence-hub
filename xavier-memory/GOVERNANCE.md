# Xavier Memory Governance

**Version**: 1.0.0
**Created**: 2026-02-15
**Type**: Infrastructure Governance

---

## 🎯 Purpose

This document defines the governance rules for Xavier's Global Memory System (MEMORY.md), including when to update, how to backup, and cross-project sync protocols.

---

## 📋 Memory Update Protocol (X-MEM)

### When to ADD New Learnings

**✅ APPROVED Triggers:**
1. **Explicit user request**: User says "add to X-MEM" or "update memory"
2. **Repeated errors**: Same error occurs 2+ times in a session
3. **Critical failures**: System-breaking issues that must be prevented

**❌ BLOCKED Triggers:**
1. One-off issues (not reproducible)
2. Successful operations (memory is for failures only)
3. User-specific preferences (those go in jimmy-core-preferences)
4. Temporary workarounds

### Memory Entry Format

Each entry MUST follow this structure:
```markdown
### Erro comum #N: [Brief Title]
- **Sintoma**: [What the user/system sees]
- **Causa**: [Root cause explanation]
- **Erro típico**: [Common error message]
- **Fix**: [Step-by-step solution]

\`\`\`
❌ MAU exemplo:
[Show broken code/command]
→ [Failure description]

✅ BOM exemplo:
[Show correct code/command]
→ [Success description]
\`\`\`
```

### Entry Requirements

**MUST include:**
- ✅ Atomic (testable independently)
- ✅ Reproducible (works every time)
- ✅ Clear before/after examples
- ✅ Platform-specific notes (Windows/Linux)

**MUST NOT include:**
- ❌ Vague descriptions
- ❌ User-specific paths
- ❌ Temporary solutions
- ❌ Opinion-based preferences

---

## 🔄 Sync Protocol

### Automatic Sync (via Hard Links)
- **Trigger**: Every edit to master MEMORY.md
- **Mechanism**: Hard links (PowerShell New-Item) ensure instant sync
- **Verification**: Check file sizes and timestamps match exactly
- **Target**: All ~/.claude/projects/*/memory/ folders
- **Platform**: Windows - uses NTFS hard links (same inode)
- **Setup**: Run `setup_memory_junctions.bat` to create hard links

### Manual Sync (Google Drive)
- **Trigger**: User command "Xavier, sync memory" or "Xavier, backup memory"
- **Frequency**: After significant updates or before important ops
- **Pre-sync checks**:
  1. Verify no uncommitted Git changes
  2. If uncommitted → prompt for commit message → commit → push to GitHub
  3. Create timestamped local backup
  4. Sync to Google Drive via rclone
- **Backup**: Creates timestamped local copy before sync
- **Retention**: Keep last 10 local backups

### Emergency Restore
- **Trigger**: User command "Xavier, restore memory"
- **Sources**: Local backups or Google Drive
- **Safety**: ALWAYS backup current state before restore
- **Verification**: Compare checksums after restore

---

## 🔐 Backup Strategy

### 3-Layer Protection

#### Layer 1: Git Version Control
- **Location**: `claude-intelligence-hub` repo
- **Frequency**: Every commit with memory changes
- **Retention**: Unlimited (Git history)
- **Recovery**: `git log`, `git checkout`

#### Layer 2: Hard Links (Real-time Sync)
- **Location**: All project memory folders
- **Frequency**: Instant (same inode - changes propagate immediately)
- **Retention**: While projects exist
- **Recovery**: Re-run setup_memory_junctions.bat
- **Implementation**: PowerShell `New-Item -ItemType HardLink` (reliable)
- **Verification**: `fsutil hardlink list MEMORY.md` shows multiple paths

#### Layer 3: Google Drive Backup
- **Location**: `_critical_bkp_xavier_local_persistent_memory`
- **Frequency**: Manual (via "sync memory" command)
- **Retention**: 10 local + unlimited cloud
- **Recovery**: `rclone copy` from Google Drive

---

## 🚨 Critical Rules

### NEVER:
1. ❌ Delete master MEMORY.md without backup
2. ❌ Edit project copies directly (edit master only)
3. ❌ Skip backup before major changes
4. ❌ Push to git without testing locally first
5. ❌ Sync to Google Drive without verification

### ALWAYS:
1. ✅ Edit master: `claude-intelligence-hub/xavier-memory/MEMORY.md`
2. ✅ Backup before restore operations
3. ✅ Verify hard links after setup
4. ✅ Test memory loads in new project
5. ✅ Commit to git with descriptive message

---

## 🔍 Verification Checklist

### After Adding New Learning:
- [ ] Entry follows format requirements
- [ ] Before/after examples included
- [ ] Platform-specific notes added
- [ ] Error message quoted exactly
- [ ] Fix tested and works

### After Sync Operation:
- [ ] Master MEMORY.md exists and readable
- [ ] All project hard links verified (same inode)
- [ ] Google Drive backup confirmed
- [ ] Local backup created with timestamp
- [ ] No errors in sync log

### After Restore Operation:
- [ ] Old state backed up before restore
- [ ] Restored file matches source checksum
- [ ] Hard links still functional
- [ ] Memory loads correctly in Claude
- [ ] Git status clean (or committed)

---

## 📊 Monitoring

### Health Checks

**Daily** (automatic):
- Hard link integrity (inode verification)
- Master file existence and readability

**On-demand** (user trigger):
- Google Drive connectivity
- Backup count and ages
- Git sync status

### Alert Conditions

**🔴 CRITICAL**:
- Master MEMORY.md missing
- All hard links broken
- Google Drive unreachable for 7+ days

**🟡 WARNING**:
- One or more hard links broken
- Last backup >24 hours old
- Uncommitted changes in git

**🟢 HEALTHY**:
- All hard links verified
- Recent backup exists
- Git up to date

---

## 🛠️ Maintenance

### Weekly:
- Verify all hard links
- Check Google Drive sync status
- Review local backup count

### Monthly:
- Audit memory entries for obsolescence
- Clean up resolved patterns
- Update governance rules if needed

### Quarterly:
- Full backup to external drive
- Test restore procedure
- Review and optimize memory size

---

## 📈 Growth Management

### Memory Size Limits

**Target**: <200 lines per section
**Maximum**: 500 lines total before archiving
**Action**: When approaching limit, move old patterns to archive

### Archiving Strategy

**When**:
- Pattern no longer occurs
- Platform deprecated
- Better solution found

**How**:
1. Move to `xavier-memory/archive/MEMORY_archive_YYYY-MM.md`
2. Note reason for archival
3. Keep cross-reference in active MEMORY.md

---

## 🔗 Related Documentation

- [MEMORY.md](MEMORY.md) - The actual memory file
- [README.md](README.md) - System overview
- [SKILL.md](../xavier-memory-sync/SKILL.md) - Sync skill documentation
- [MODULE_3_GOVERNANCE_XAVIER.md](../docs/MODULE_3_GOVERNANCE_XAVIER.md) - Original X-MEM protocol

---

## 📝 Change Log

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-15 | 1.0.0 | Initial governance document | Xavier |
| 2026-02-16 | 1.1.0 | Fixed hard link implementation (PowerShell), added Git pre-sync checks | Xavier |

---

**Maintained By**: Xavier (Claude Code)
**Review Frequency**: Quarterly
**Last Updated**: 2026-02-15
