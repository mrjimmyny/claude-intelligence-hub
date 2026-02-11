# Windows Junction Point Setup for Skills Auto-Loading

## 🎯 Problem Solved
**Issue**: Skills were copied instead of linked, causing version drift
- jimmy-core-preferences was stuck at v1.0.0 (should be v1.3.0)
- session-memoria was stuck at v1.0.0 (should be v1.1.0)
- Updates to Git repo didn't reflect in Claude sessions

**Solution**: Windows Junction Points (directory symlinks that don't require admin privileges)

---

## ✅ Current Setup (Feb 11, 2026)

Both skills are now using **junction points** that auto-sync:

```
C:\Users\<username>\.claude\skills\user\
├── jimmy-core-preferences  → C:\Users\<username>\Downloads\claude-intelligence-hub\jimmy-core-preferences
└── session-memoria         → C:\Users\<username>\Downloads\claude-intelligence-hub\session-memoria
```

**Benefits:**
- ✅ Git pull = instant skill updates
- ✅ No admin privileges needed
- ✅ Same inode = true file linking
- ✅ Works across Git operations
- ✅ Mobile/desktop sync via Git

---

## 🔧 Setup Instructions (Windows)

### Quick Setup (Batch Script Method)

1. **Create setup script:**

```batch
@echo off
REM Save this as setup_junctions.bat in your Downloads folder

set SKILLS_DIR=%USERPROFILE%\.claude\skills\user
set REPO_DIR=%USERPROFILE%\Downloads\claude-intelligence-hub

REM Remove old copies if they exist (save any local changes first!)
if exist "%SKILLS_DIR%\jimmy-core-preferences" rmdir "%SKILLS_DIR%\jimmy-core-preferences" /s /q
if exist "%SKILLS_DIR%\session-memoria" rmdir "%SKILLS_DIR%\session-memoria" /s /q

REM Create junction points
mklink /J "%SKILLS_DIR%\jimmy-core-preferences" "%REPO_DIR%\jimmy-core-preferences"
mklink /J "%SKILLS_DIR%\session-memoria" "%REPO_DIR%\session-memoria"

echo.
echo ✅ Junction points created successfully!
echo.
pause
```

2. **Run the script:**
```bash
cd ~/Downloads
./setup_junctions.bat
```

3. **Verify:**
```bash
ls -la ~/.claude/skills/user/
# Should show: lrwxrwxrwx ... jimmy-core-preferences -> ...
```

---

## 🔍 Verification Commands

### Check if junctions are active:
```bash
# Git Bash
ls -la ~/.claude/skills/user/
# Look for 'lrwxrwxrwx' and '->' symbols

# Windows CMD
dir "%USERPROFILE%\.claude\skills\user"
# Look for '<JUNCTION>' tag
```

### Verify same file (not copy):
```bash
# Should show SAME inode number for both paths
stat ~/Downloads/claude-intelligence-hub/jimmy-core-preferences/.metadata | grep Inode
stat ~/.claude/skills/user/jimmy-core-preferences/.metadata | grep Inode
```

### Check loaded versions:
```bash
cat ~/.claude/skills/user/jimmy-core-preferences/.metadata | grep version
cat ~/.claude/skills/user/session-memoria/.metadata | grep version
```

**Expected output (as of Feb 11, 2026):**
- jimmy-core-preferences: v1.3.0
- session-memoria: v1.1.0

---

## 🔄 Update Workflow

### Receiving Updates:
```bash
cd ~/Downloads/claude-intelligence-hub
git pull
# Skills are INSTANTLY updated (no copy needed!)
```

### Making Updates:
```bash
# Claude updates SKILL.md directly in Git repo
cd ~/Downloads/claude-intelligence-hub
git add .
git commit -m "Updated: jimmy-core-preferences"
git push
# Available immediately on other machines after git pull
```

---

## 🐛 Troubleshooting

### Junction Not Working
```bash
# Check if it's a real junction or a copy
ls -la ~/.claude/skills/user/jimmy-core-preferences

# If it shows 'drwxr-xr-x' (directory) instead of 'lrwxrwxrwx' (link):
# - Delete it: rm -rf ~/.claude/skills/user/jimmy-core-preferences
# - Re-run setup_junctions.bat
```

### Old Version Still Loading
```bash
# 1. Verify junction is active
ls -la ~/.claude/skills/user/

# 2. Check Git repo is up to date
cd ~/Downloads/claude-intelligence-hub
git pull

# 3. Verify inode numbers match (same file)
stat ~/Downloads/claude-intelligence-hub/jimmy-core-preferences/.metadata | grep Inode
stat ~/.claude/skills/user/jimmy-core-preferences/.metadata | grep Inode

# 4. Restart Claude Code
# Exit and restart claude
```

### "Access Denied" Error
**Junction points don't need admin!** If you get this:
- Make sure you're using `/J` flag (junction), not `/D` (symlink)
- Check that both paths exist
- Verify you have write access to `.claude\skills\user\` directory

---

## 📱 Mobile Setup

On mobile (Android/iOS with Termux/iSH):

```bash
# Mobile uses standard symlinks (no admin needed on Linux)
cd ~/.claude/skills/user
ln -s ~/path/to/claude-intelligence-hub/jimmy-core-preferences .
ln -s ~/path/to/claude-intelligence-hub/session-memoria .
```

**Sync workflow:**
1. Desktop: Make changes, commit, push
2. Mobile: Git pull → instant update
3. Mobile: Make changes, commit, push
4. Desktop: Git pull → instant update

---

## 🎯 Why Junction Points Over Copies?

| Method | Git Sync | Admin Required | Cross-Platform |
|--------|----------|----------------|----------------|
| **Copy** | ❌ Manual | No | Yes |
| **Symlink (/D)** | ✅ Auto | ⚠️ Yes (Windows) | Yes |
| **Junction (/J)** | ✅ Auto | ✅ No | Windows only |
| **Hard Link** | ✅ Auto | No | Files only (not dirs) |

**Winner**: Junction points = auto-sync + no admin privileges

---

## 📊 Version History

| Date | jimmy-core-preferences | session-memoria | Notes |
|------|----------------------|-----------------|-------|
| Feb 9, 2025 | v1.0.0 | - | Initial release |
| Feb 10, 2026 | v1.3.0 | v1.0.0 | session-memoria created |
| Feb 11, 2026 | v1.3.0 | v1.1.0 | Junction fix applied |

---

## 🔗 Related Documentation

- [jimmy-core-preferences/SETUP_GUIDE.md](jimmy-core-preferences/SETUP_GUIDE.md) - Original setup instructions
- [session-memoria/README.md](session-memoria/README.md) - Session memoria documentation
- [.claude/project-instructions.md](.claude/project-instructions.md) - Git sync mandatory protocol

---

**Last Updated**: 2026-02-11
**Fixed By**: Xavier (Claude)
**Tested On**: Windows 10/11, Git Bash

