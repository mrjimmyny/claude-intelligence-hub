# Setup Guide - Claude Session Registry

**Version:** 1.0.0
**Platform:** Windows (Git Bash), Linux, macOS
**Prerequisites:** Git, Claude Code CLI

---

## 📋 TABLE OF CONTENTS

1. [Installation](#installation)
2. [Junction Point Setup (Windows)](#junction-point-setup-windows)
3. [Verification](#verification)
4. [Configuration](#configuration)
5. [Troubleshooting](#troubleshooting)

---

## 🚀 INSTALLATION

### Step 1: Clone Repository

```bash
cd ~/Downloads
git clone <repo-url> claude-intelligence-hub
```

### Step 2: Verify Structure

```bash
cd claude-intelligence-hub/claude-session-registry
ls -la
```

Expected output:
```
.metadata
SKILL.md
README.md
CHANGELOG.md
SETUP_GUIDE.md
templates/
registry/
```

---

## 🔗 JUNCTION POINT SETUP (Windows)

Junction points create a **live link** (not a copy) from Claude's skills directory to the Git repository. This enables:
- ✅ Real-time sync (changes in repo → visible in skills)
- ✅ Multi-machine sync via Git
- ✅ Single source of truth

### Automated Setup (Recommended)

#### Create/Update `setup_junctions.bat`

Create this file in `~/Downloads/` (or update existing):

```batch
@echo off
set SKILLS_DIR=%USERPROFILE%\.claude\skills\user
set REPO_DIR=%USERPROFILE%\Downloads\claude-intelligence-hub

echo Removing old junction points...

REM Remove old junctions/copies
if exist "%SKILLS_DIR%\jimmy-core-preferences" rmdir "%SKILLS_DIR%\jimmy-core-preferences" /s /q
if exist "%SKILLS_DIR%\session-memoria" rmdir "%SKILLS_DIR%\session-memoria" /s /q
if exist "%SKILLS_DIR%\gdrive-sync-memoria" rmdir "%SKILLS_DIR%\gdrive-sync-memoria" /s /q
if exist "%SKILLS_DIR%\claude-session-registry" rmdir "%SKILLS_DIR%\claude-session-registry" /s /q

echo Creating junction points...

REM Create junction points
mklink /J "%SKILLS_DIR%\jimmy-core-preferences" "%REPO_DIR%\jimmy-core-preferences"
mklink /J "%SKILLS_DIR%\session-memoria" "%REPO_DIR%\session-memoria"
mklink /J "%SKILLS_DIR%\gdrive-sync-memoria" "%REPO_DIR%\gdrive-sync-memoria"
mklink /J "%SKILLS_DIR%\claude-session-registry" "%REPO_DIR%\claude-session-registry"

echo.
echo ✅ Junction points created successfully!
echo.
echo Verify with:
echo   ls -la %SKILLS_DIR% | grep claude-session-registry
echo.
pause
```

#### Run Setup Script

```bash
cd ~/Downloads
./setup_junctions.bat
```

### Manual Setup (Alternative)

If batch script fails, create junction manually:

```bash
# Remove old copy (if exists)
rmdir "$USERPROFILE/.claude/skills/user/claude-session-registry" /s /q

# Create junction
mklink /J "$USERPROFILE/.claude/skills/user/claude-session-registry" "$USERPROFILE/Downloads/claude-intelligence-hub/claude-session-registry"
```

---

## ✅ VERIFICATION

### 1. Check Junction Point Exists

```bash
ls -la ~/.claude/skills/user/ | grep claude-session-registry
```

Expected output:
```
lrwxrwxrwx ... claude-session-registry -> /c/Users/jaderson.almeida/Downloads/claude-intelligence-hub/claude-session-registry
```

**Key indicators:**
- `lrwxrwxrwx` - Shows it's a link (not a directory)
- `->` - Shows the target path

### 2. Verify Same Inode (Not a Copy)

```bash
# Get inode of source
stat ~/Downloads/claude-intelligence-hub/claude-session-registry/.metadata | grep Inode

# Get inode of junction
stat ~/.claude/skills/user/claude-session-registry/.metadata | grep Inode
```

**They MUST be identical** - if different, it's a copy (not a junction).

### 3. Test Read Access

```bash
cat ~/.claude/skills/user/claude-session-registry/.metadata | jq .
```

Should display valid JSON without errors.

### 4. Test Write Access

Edit a file in the repo:

```bash
echo "# Test" >> ~/Downloads/claude-intelligence-hub/claude-session-registry/README.md
```

Verify visible via junction:

```bash
tail -1 ~/.claude/skills/user/claude-session-registry/README.md
```

Should show `# Test`.

**Clean up:**
```bash
cd ~/Downloads/claude-intelligence-hub
git checkout -- claude-session-registry/README.md
```

---

## ⚙️ CONFIGURATION

### Edit `.metadata` Settings

Open in editor:
```bash
cd ~/Downloads/claude-intelligence-hub/claude-session-registry
nano .metadata
```

### Key Settings

```json
{
  "settings": {
    "auto_push": true,              // Auto-push to Git after register
    "default_language": "pt-BR",     // Language (pt-BR or en-US)
    "timezone": "America/Sao_Paulo", // Timezone for timestamps
    "machine_id": "",                // Leave empty to auto-detect
    "golden_close_enabled": true,    // Enable Golden Close Protocol
    "min_summary_items": 3,          // Minimum summary bullets
    "max_summary_items": 5           // Maximum summary bullets
  }
}
```

### Machine ID (Optional)

By default, uses `$COMPUTERNAME` (Windows) or `$(hostname)` (Linux/Mac).

To set custom ID:
```json
"machine_id": "MY-CUSTOM-ID"
```

### Auto-Push Behavior

**Enabled (`true`):**
- Register workflow auto-commits AND pushes to remote
- Best for multi-machine sync

**Disabled (`false`):**
- Register workflow only commits locally
- Manual `git push` required
- Best for offline work or manual control

---

## 🔧 TROUBLESHOOTING

### Issue: Junction Not Created

**Symptoms:**
- `ls -la` shows directory (not link)
- Or: "symbolic link" not shown

**Solution:**
```bash
# Remove old copy
rm -rf ~/.claude/skills/user/claude-session-registry

# Re-run setup
cd ~/Downloads
./setup_junctions.bat
```

### Issue: "Permission Denied" on Windows

**Cause:** Administrator rights required for `mklink /J`

**Solution:**
1. Right-click Git Bash
2. Select "Run as Administrator"
3. Re-run setup script

### Issue: Junction Points to Wrong Path

**Symptoms:**
- Path in `ls -la` incorrect
- Files not found

**Solution:**
```bash
# Check REPO_DIR in setup script
echo $USERPROFILE/Downloads/claude-intelligence-hub

# Adjust path in setup_junctions.bat:
set REPO_DIR=%USERPROFILE%\Downloads\claude-intelligence-hub

# Re-run setup
./setup_junctions.bat
```

### Issue: Changes Not Syncing Between Machines

**Cause:** Junction exists but Git not pushing/pulling

**Solution:**
```bash
# Machine A (after registering session):
cd ~/Downloads/claude-intelligence-hub
git status
git push origin main

# Machine B:
cd ~/Downloads/claude-intelligence-hub
git pull
```

**Tip:** Enable `auto_push: true` in `.metadata` for automatic sync.

### Issue: "Not a Git Repository"

**Symptoms:**
- Register workflow shows `no-git` for Branch/Commit
- Or: error messages about Git

**Cause:** Command run outside Git repo

**Solution:**
This is **normal behavior** if working in non-Git projects:
- Branch/Commit will show `no-git`
- Session still registers successfully
- Other fields (Date, Machine, Project) still captured

**To fix for Git projects:**
```bash
cd ~/your/git/project
git init  # If new repo
git remote add origin <url>  # If connecting to remote
```

### Issue: Claude Doesn't Recognize Skill

**Symptoms:**
- Triggers don't work
- `/session-registry` not found

**Solution:**
1. Verify junction exists:
   ```bash
   ls -la ~/.claude/skills/user/claude-session-registry
   ```

2. Restart Claude:
   ```bash
   exit
   claude
   ```

3. Check `.metadata` is valid JSON:
   ```bash
   cat ~/.claude/skills/user/claude-session-registry/.metadata | jq .
   ```

### Issue: Table Format Broken

**Symptoms:**
- Columns misaligned in `SESSIONS.md`
- Extra/missing pipes `|`

**Cause:** Manual editing broke Markdown table

**Solution:**
```bash
cd ~/Downloads/claude-intelligence-hub/claude-session-registry/registry/YYYY/MM
nano SESSIONS.md

# Ensure each row has exactly 9 columns:
| col1 | col2 | col3 | col4 | col5 | col6 | col7 | col8 | col9 |
```

**Prevention:** Always use Register Workflow (don't manually edit tables).

---

## 🔄 MULTI-MACHINE SYNC WORKFLOW

### Initial Setup (Each Machine)

**Machine A:**
```bash
cd ~/Downloads
git clone <repo-url> claude-intelligence-hub
cd claude-intelligence-hub
./setup_junctions.bat
```

**Machine B:**
```bash
cd ~/Downloads
git clone <repo-url> claude-intelligence-hub
cd claude-intelligence-hub
./setup_junctions.bat
```

### Daily Workflow

**Machine A (morning):**
```bash
cd ~/Downloads/claude-intelligence-hub
git pull  # Fetch sessions from other machines
claude
# ... work ...
# Xavier: Golden Close Protocol triggers
exit
# Copy Session ID
claude
# "Xavier, registra sessão [ID]"
# Auto-commit + auto-push (if enabled)
```

**Machine B (afternoon):**
```bash
cd ~/Downloads/claude-intelligence-hub
git pull  # Fetch session from Machine A
cat claude-session-registry/registry/2026/02/SESSIONS.md  # See all sessions
claude
# ... work ...
```

---

## 📚 NEXT STEPS

After successful setup:

1. **Test Registration:**
   ```
   Xavier, registra sessão claude-20260212-1430-test
   ```

2. **Test Search:**
   ```
   Xavier, busca sessões com tag #Test
   ```

3. **Test Stats:**
   ```
   /session-registry stats
   ```

4. **Read Full Documentation:**
   - `SKILL.md` - Complete workflow details
   - `README.md` - Feature overview

---

## 🤝 SUPPORT

For issues or questions:
- Check this troubleshooting guide first
- Review `SKILL.md` for workflow details
- Contact repository maintainer

---

**Happy Session Tracking! 🎯**
