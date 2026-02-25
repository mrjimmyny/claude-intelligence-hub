# 🛠️ Scripts - Claude Intelligence Hub

## Sync Skills to Global Directory

### Purpose
Automatically synchronize all skills from `claude-intelligence-hub` to the global Claude Code skills directory (`~/.claude/skills/`), making them available as slash commands in ALL sessions.

### Usage

**Windows (PowerShell):**
```powershell
cd C:\ai\claude-intelligence-hub\scripts
.\sync-skills-global.ps1
```

**Bash/WSL/Git Bash:**
```bash
cd /c/ai/claude-intelligence-hub/scripts
./sync-skills-global.sh
```

---

## Validation and Governance (Windows PowerShell)

Use these wrappers if you are on Windows without bash/WSL.

**Integrity Check (Hub Consistency):**
```powershell
cd C:\ai\claude-intelligence-hub\scripts
.\integrity-check.ps1
```

**Version Sync (Single Skill):**
```powershell
cd C:\ai\claude-intelligence-hub\scripts
.\sync-versions.ps1 agent-orchestration-protocol
```

Notes:
- These scripts mirror the behavior of `integrity-check.sh` and `sync-versions.sh`.
- `sync-versions.ps1` preserves the original file encoding to avoid unintended changes.

### When to Use

Run this script when:
1. **Creating a new skill** - After adding a new skill directory with SKILL.md
2. **Skill not appearing** - If `/skills` command doesn't show your new skill
3. **Fresh setup** - Initial setup on a new machine
4. **Broken symlinks** - If skills directory was corrupted or deleted

### What It Does

1. Scans `claude-intelligence-hub` for all `SKILL.md` files
2. Creates symlinks/junctions in `~/.claude/skills/` pointing to each skill
3. Handles existing symlinks intelligently:
   - ✓ Skips if already correctly linked
   - ↻ Updates if pointing to wrong location
   - ⚠ Warns if path exists but is not a symlink
4. Reports summary:
   - New skills added
   - Existing skills (unchanged)
   - Updated links

### Output Example

```
🔄 Syncing skills to global directory...

✓ agent-orchestration-protocol (already linked)
✓ claude-session-registry (new)
↻ repo-auditor (updated link)
⚠  context-guardian (exists but not a symlink - skipping)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Sync complete!
   New skills:      1
   Existing skills: 14
   Updated links:   1
   Total skills:    16
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Note: Restart Claude Code to load new skills
```

### After Running

1. **Restart Claude Code** - Close and reopen to load new skills
2. **Verify with `/skills`** - Check that your new skill appears
3. **Test with `/skill-name`** - Try running the skill directly

---

## 📋 Complete Workflow: Adding a New Skill

### Step 1: Create Skill Structure

```bash
cd /c/ai/claude-intelligence-hub
mkdir my-new-skill
cd my-new-skill

# Create required files
touch SKILL.md
touch README.md
touch .metadata
```

### Step 2: Define SKILL.md with Command

**CRITICAL:** Always include `command:` in frontmatter!

```yaml
---
name: my-new-skill
description: Brief description of what this skill does
command: /my-skill
aliases: [/myskill, /ms]
---

# My New Skill

## Objective
...
```

### Step 3: Create .metadata

```json
{
  "name": "my-new-skill",
  "version": "1.0.0",
  "status": "active",
  "description": "Brief description",
  "category": "category-name",
  "dependencies": [],
  "tags": ["tag1", "tag2"]
}
```

### Step 4: Run Sync Script

```powershell
cd C:\ai\claude-intelligence-hub\scripts
.\sync-skills-global.ps1
```

### Step 5: Restart Claude Code

Close and reopen Claude Code.

### Step 6: Validate with Repo Auditor

```bash
/repo-auditor --mode AUDIT_AND_FIX
```

The repo-auditor will:
- ✅ Verify `command:` is defined (CRITICAL)
- ✅ Validate command is documented in HUB_MAP, README, COMMANDS
- ✅ Check for command duplicates
- ✅ Auto-fix documentation if needed
- ✅ Ensure skill is in EXECUTIVE_SUMMARY Component Versions

### Step 7: Test Your Skill

```bash
/my-skill
```

---

## 🔍 Validation Rules (Enforced by Repo Auditor)

The repo-auditor enforces these rules automatically:

### 1. Command Definition (CRITICAL ERROR if missing)
- Every skill MUST have `command:` in SKILL.md frontmatter
- Missing command blocks the audit

### 2. Command Documentation Sync (CRITICAL ERROR if out of sync)
- Commands must appear in:
  - `HUB_MAP.md`
  - `README.md` Quick Commands section
  - `COMMANDS.md`
- Counts must match

### 3. Command Uniqueness (CRITICAL ERROR if duplicates)
- No two skills can have the same command
- Command collision blocks the audit

### 4. Component Versions Completeness (CRITICAL ERROR if missing)
- All skills must be listed in `EXECUTIVE_SUMMARY.md` Component Versions
- Missing skills block the audit

---

## 🚨 Common Issues

### Issue: "Unknown skill: my-skill"
**Solution:** Run sync script and restart Claude Code

### Issue: "skill_dir/SKILL.md lacks 'command:' in frontmatter"
**Solution:** Add `command: /skill-name` to SKILL.md frontmatter

### Issue: "Command documentation out of sync"
**Solution:** Run `/repo-auditor --mode AUDIT_AND_FIX` to auto-fix

### Issue: "Duplicate command definitions"
**Solution:** Choose unique command names, update SKILL.md, re-sync

---

## 📖 References

- **Skills Reference:** `~/.claude/SKILLS_REFERENCE.md`
- **Repo Auditor Protocol:** `~/claude-intelligence-hub/repo-auditor/SKILL.md`
- **Memory:** `~/.claude/projects/C--ai/memory/skills-configuration.md`

---

**Last Updated:** 2026-02-25
**Maintained by:** Magneto
