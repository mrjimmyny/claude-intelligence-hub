# Setup Guide - Jimmy Core Preferences

**Version:** 2.0.0 | **Last Updated:** 2026-03-11

Quick reference for setting up this global skill in different environments.

---

## 🚀 Quick Start (5 minutes)

### Prerequisites
- Claude Code installed
- Git configured
- Access to `claude-intelligence-hub` repo

### Option 1: First Time Setup (New Machine)

```bash
# 1. Clone the intelligence hub
cd ~/projects  # or wherever you keep repos
git clone https://github.com/mrjimmyny/claude-intelligence-hub.git

# 2. Link to Claude Code skills directory
# macOS/Linux (symlink):
ln -s ~/projects/claude-intelligence-hub/jimmy-core-preferences \
      ~/.claude/skills/user/jimmy-core-preferences

# Windows — IMPORTANT: use Junction, NOT SymbolicLink
# Junction points are required; Claude Code uses dirent.isDirectory() which
# resolves Junctions correctly but not SymbolicLinks on Windows.
# Run in CMD (not PowerShell) as Admin:
cmd /c mklink /J "%USERPROFILE%\.claude\skills\user\jimmy-core-preferences" "C:\ai\claude-intelligence-hub\jimmy-core-preferences"

# 3. Verify
claude
# Then in Claude:
/skills list
# You should see "jimmy-core-preferences"
```

### Option 2: Already Have the Repo

```bash
# Navigate to your existing repo
cd ~/path/to/claude-intelligence-hub

# Pull latest changes
git pull

# Create symlink (if not already done)
# macOS/Linux:
ln -s $(pwd)/jimmy-core-preferences ~/.claude/skills/user/jimmy-core-preferences

# Windows (PowerShell as Admin):
$repoPath = Get-Location
New-Item -ItemType SymbolicLink `
  -Path "$env:USERPROFILE\.claude\skills\user\jimmy-core-preferences" `
  -Target "$repoPath\jimmy-core-preferences"
```

---

## 🔍 Verification

After setup, verify everything works:

```bash
# 1. Check files exist
ls ~/.claude/skills/user/jimmy-core-preferences
# Should show: README.md, SKILL.md, CHANGELOG.md, .metadata

# 2. Start Claude Code
claude

# 3. In Claude, check skills loaded
/skills list
# Should show jimmy-core-preferences with ✅

# 4. Test it's working
# Just start a conversation - Claude should follow the preferences automatically
```

---

## 🔄 Syncing Across Machines

### Machine 1 (Primary Development)
```bash
# Work with Claude, let it update preferences
# Claude will commit changes to the skill
cd ~/projects/claude-intelligence-hub
git push
```

### Machine 2 (Secondary)
```bash
# Pull latest preferences
cd ~/projects/claude-intelligence-hub
git pull

# If using symlink, changes are immediately available
# If using copy, re-copy:
cp -r jimmy-core-preferences ~/.claude/skills/user/
```

---

## 🛠️ Troubleshooting

### Skill Not Loading

**Problem:** Claude doesn't seem to follow preferences

**Solutions:**
```bash
# 1. Check skill exists in correct location
ls -la ~/.claude/skills/user/jimmy-core-preferences

# 2. Check .metadata is readable
cat ~/.claude/skills/user/jimmy-core-preferences/.metadata

# 3. Restart Claude Code
# Exit and restart claude

# 4. Manually trigger skill load (in Claude)
/skills reload
```

### Symlink Issues (Windows)

**Problem:** Symlink creation fails

**Solution:** Run PowerShell as Administrator
```powershell
# Right-click PowerShell → "Run as Administrator"
# Then create symlink
```

### Changes Not Syncing

**Problem:** Updates in GitHub not reflected locally

**Solutions:**
```bash
# 1. Check git status
cd ~/projects/claude-intelligence-hub
git status

# 2. Pull latest
git pull

# 3. If using symlink, changes should be immediate
# If using copy, recopy:
cp -r jimmy-core-preferences ~/.claude/skills/user/

# 4. Reload skills in Claude
/skills reload
```

### Merge Conflicts

**Problem:** Git merge conflicts in SKILL.md

**Solutions:**
```bash
# 1. View the conflict
cat jimmy-core-preferences/SKILL.md

# 2. Resolve manually or take remote version
git checkout --theirs jimmy-core-preferences/SKILL.md
git add jimmy-core-preferences/SKILL.md
git commit -m "Resolved: accepted remote changes to SKILL.md"

# 3. Or take local version
git checkout --ours jimmy-core-preferences/SKILL.md
git add jimmy-core-preferences/SKILL.md
git commit -m "Resolved: kept local changes to SKILL.md"
```

---

## 📋 Directory Structure Reference

```
~/.claude/skills/user/                     ← Claude Code skills directory
└── jimmy-core-preferences/                ← Symlinked or copied
    ├── README.md
    ├── SKILL.md
    ├── CHANGELOG.md
    └── .metadata

~/projects/claude-intelligence-hub/       ← Git repo (source of truth)
├── pbi-claude-skills/
├── python-claude-skills/
├── git-claude-skills/
└── jimmy-core-preferences/                ← Actual files
    ├── README.md
    ├── SKILL.md
    ├── CHANGELOG.md
    └── .metadata
```

---

## 🔐 Permissions (macOS/Linux)

If you encounter permission issues:

```bash
# Make sure you own the skills directory
sudo chown -R $(whoami) ~/.claude/skills/

# Ensure files are readable
chmod -R u+rw ~/.claude/skills/user/jimmy-core-preferences/
```

---

## 🌐 Team Setup (Optional)

If sharing with team members:

### Each Team Member:
1. Clone the shared repo
2. Create their own symlink
3. Pull updates regularly

### Customization:
- Fork the repo for personal modifications
- Use branches for experimental preferences
- Pull requests for team-wide changes

---

## 📦 Backup Strategy

### Automatic (Recommended)
Since this lives in GitHub:
- ✅ Every commit is a backup
- ✅ Full version history
- ✅ Can rollback anytime

### Manual Backup
```bash
# Create a dated backup
cd ~/projects/claude-intelligence-hub
tar -czf "../jimmy-core-preferences-backup-$(date +%Y%m%d).tar.gz" jimmy-core-preferences/
```

---

## 🔄 Update Workflow

### Automated (Claude Does It)
1. You mention a preference
2. Claude updates SKILL.md
3. Claude commits to GitHub
4. You pull on other machines

### Manual
```bash
# Edit the file directly
cd ~/projects/claude-intelligence-hub/jimmy-core-preferences
nano SKILL.md  # or your preferred editor

# Commit changes
git add .
git commit -m "Updated: [describe change]"
git push

# On other machines
git pull
```

---

## ✅ Checklist

After setup, confirm:

- [ ] Repo cloned to local machine
- [ ] Symlink created (or files copied)
- [ ] Files visible in `~/.claude/skills/user/jimmy-core-preferences/`
- [ ] Claude Code recognizes skill (`/skills list`)
- [ ] Test conversation shows Claude following preferences
- [ ] Can commit changes from Claude sessions
- [ ] Can pull updates on other machines

---

**Setup Issues?** Open an issue: https://github.com/mrjimmyny/claude-intelligence-hub/issues

**Last Updated:** 2025-02-09
