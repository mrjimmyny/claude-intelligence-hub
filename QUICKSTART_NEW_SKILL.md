# ⚡ Quick Start: Adding a New Skill

**TL;DR:** Create skill → Add command → Sync → Restart → Validate

---

## 🎯 5-Step Process

### 1️⃣ Create Skill Files

```bash
cd /c/ai/claude-intelligence-hub
mkdir my-new-skill && cd my-new-skill

# Create required files
cat > SKILL.md << 'EOF'
---
name: my-new-skill
description: Brief description
command: /my-skill
aliases: [/myskill]
---

# My New Skill

## Objective
What this skill does...
EOF

cat > .metadata << 'EOF'
{
  "name": "my-new-skill",
  "version": "1.0.0",
  "status": "active",
  "description": "Brief description",
  "category": "productivity",
  "dependencies": [],
  "tags": ["utility"]
}
EOF

cat > README.md << 'EOF'
# My New Skill

## Overview
...
EOF
```

### 2️⃣ Sync to Global

**PowerShell:**
```powershell
C:\ai\claude-intelligence-hub\scripts\sync-skills-global.ps1
```

**Bash:**
```bash
/c/ai/claude-intelligence-hub/scripts/sync-skills-global.sh
```

### 3️⃣ Restart Claude Code

Close and reopen Claude Code.

### 4️⃣ Validate

```bash
/repo-auditor --mode AUDIT_AND_FIX
```

### 5️⃣ Test

```bash
/my-skill
```

---

## ✅ Validation Checklist

Before running repo-auditor, verify:

- [ ] `command:` is defined in SKILL.md frontmatter
- [ ] `.metadata` file exists with all required fields
- [ ] `README.md` exists
- [ ] Skill directory name matches metadata name
- [ ] Command is unique (no collisions)

---

## 🚨 Critical Rules (Auto-Enforced)

The repo-auditor will **BLOCK** if:

1. ❌ **Missing `command:` in SKILL.md** → `CRITICAL ERROR`
2. ❌ **Command not in HUB_MAP/README/COMMANDS** → `CRITICAL ERROR` (auto-fixed)
3. ❌ **Duplicate command** → `CRITICAL ERROR`
4. ❌ **Skill not in EXECUTIVE_SUMMARY** → `CRITICAL ERROR` (auto-fixed)

---

## 📝 Example: Complete Skill

```yaml
---
name: quick-backup
description: Fast incremental backup with gdrive sync
command: /backup
aliases: [/bkp, /save]
---

# Quick Backup

## Objective
Perform fast incremental backups with optional Google Drive sync.

## Usage
```bash
/backup [--target PATH] [--sync]
```

## Parameters
- `--target PATH`: Target directory (default: current)
- `--sync`: Upload to Google Drive after backup

## Examples
```bash
# Backup current directory
/backup

# Backup specific path
/backup --target /c/ai/projects

# Backup and sync to Drive
/backup --sync
```
```

---

## 🔄 Maintenance

After creating the skill:

1. **Document the command** - Repo auditor will sync to HUB_MAP, README, COMMANDS
2. **Update version** - Increment version in `.metadata` when updating
3. **Re-run sync** - Only needed if skill is moved/renamed
4. **Run auditor** - Ensures everything stays consistent

---

## ⚠️ Common Pitfalls

### Adding Files to Repository Root

**Problem:** CI/CD fails with "CLUTTER: YOUR_FILE.md (unauthorized root file)"

**Cause:** Hub has Zero Tolerance policy for unauthorized root files

**Solution:**
```bash
# 1. Edit scripts/integrity-check.sh
# Add your file to approved_files array:

approved_files=(
    "CHANGELOG.md"
    "YOUR_FILE.md"    # ← Add here
    ...
)

# 2. Test locally
bash scripts/integrity-check.sh

# 3. Commit both files together
git add YOUR_FILE.md scripts/integrity-check.sh
git commit -m "docs: add YOUR_FILE.md with integrity approval"
```

**Why?** Keeps repository root clean and organized. Every root file must be explicitly approved.

---

**For detailed documentation, see:** `scripts/README.md`
