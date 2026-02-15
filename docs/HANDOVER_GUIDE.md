# Claude Intelligence Hub - Handover Guide

**Version:** 1.9.0
**Last Updated:** 2026-02-15
**Target Audience:** New developers, system administrators
**Time to Complete:** ~15 minutes

---

## 🎯 Purpose

This guide enables **zero-to-production deployment** of the Claude Intelligence Hub on a fresh machine in under 15 minutes. Follow these step-by-step instructions to set up the complete skill ecosystem.

---

## 📋 Prerequisites

### Required Software

- **Git** (2.30+)
  - Windows: [Git for Windows](https://git-scm.com/download/win)
  - macOS: `brew install git` or Xcode Command Line Tools
  - Linux: `sudo apt install git` (Debian/Ubuntu) or `sudo yum install git` (RHEL/CentOS)

- **Claude Code CLI**
  - Installation: Follow [Claude Code setup guide](https://docs.anthropic.com/claude/claude-code)
  - Verify: `claude --version`

### Platform-Specific Requirements

**Windows:**
- PowerShell 5.1+ (pre-installed on Windows 10/11)
- Git Bash (included with Git for Windows)

**macOS/Linux:**
- Bash 4.0+
- Standard Unix utilities (ln, grep, sed)

### Access Requirements

- GitHub account with access to `claude-intelligence-hub` repository
- Active Claude API key (for Claude Code)

---

## 🚀 Quick Start (15-Minute Setup)

### Step 1: Clone the Repository (2 minutes)

```bash
# Navigate to your preferred location (adjust path as needed)
cd ~/Downloads

# Clone the hub repository
git clone https://github.com/mrjimmyny/claude-intelligence-hub.git

# Verify clone success
cd claude-intelligence-hub
ls -la  # Should show HUB_MAP.md, README.md, skills/, etc.
```

**Expected output:**
```
HUB_MAP.md
README.md
jimmy-core-preferences/
session-memoria/
x-mem/
gdrive-sync-memoria/
claude-session-registry/
pbi-claude-skills/
scripts/
docs/
```

---

### Step 2: Run Setup Script (10 minutes)

#### Windows (PowerShell)

```powershell
# Open PowerShell (no admin required!)
cd ~/Downloads/claude-intelligence-hub

# Run setup script
.\scripts\setup_local_env.ps1

# Optional: Force recreate existing junctions
.\scripts\setup_local_env.ps1 -Force

# Optional: Skip optional skills prompt
.\scripts\setup_local_env.ps1 -SkipOptional
```

#### macOS/Linux (Bash)

```bash
# Open Terminal
cd ~/Downloads/claude-intelligence-hub

# Make script executable (if not already)
chmod +x scripts/setup_local_env.sh

# Run setup script
bash scripts/setup_local_env.sh

# Optional: Force recreate existing symlinks
bash scripts/setup_local_env.sh --force

# Optional: Skip optional skills prompt
bash scripts/setup_local_env.sh --skip-optional
```

**What the script does:**

1. ✅ Validates hub directory structure
2. ✅ Creates `~/.claude/skills/user/` directory if missing
3. ✅ Auto-installs 5 mandatory core skills:
   - `jimmy-core-preferences` (Master Framework)
   - `session-memoria` (Knowledge Management)
   - `x-mem` (Self-Learning)
   - `gdrive-sync-memoria` (GDrive Integration)
   - `claude-session-registry` (Session Tracking)
4. ⚠️ Prompts for optional skills:
   - `pbi-claude-skills` (Power BI optimization)
5. ✅ Runs integrity validation
6. ✅ Displays success summary

**Expected final output:**
```
═══════════════════════════════════════════════════════════════
  ✅ SETUP COMPLETE!
═══════════════════════════════════════════════════════════════

📍 Installed Skills:
  ✓ jimmy-core-preferences (1.5.0)
  ✓ session-memoria (1.2.0)
  ✓ x-mem (1.0.0)
  ✓ gdrive-sync-memoria (1.0.0)
  ✓ claude-session-registry (1.1.0)

📊 Summary:
  • Total skills installed: 5
  • Mandatory core skills: 5
```

---

### Step 3: Verify Installation (3 minutes)

```bash
# Check junction points / symlinks
ls -la ~/.claude/skills/user/

# Expected output (Windows - Git Bash):
# lrwxrwxrwx ... jimmy-core-preferences -> .../claude-intelligence-hub/jimmy-core-preferences
# lrwxrwxrwx ... session-memoria -> .../claude-intelligence-hub/session-memoria
# ...

# Expected output (Windows - CMD):
# <JUNCTION> jimmy-core-preferences [...\claude-intelligence-hub\jimmy-core-preferences]
# <JUNCTION> session-memoria [...\claude-intelligence-hub\session-memoria]
```

**Verify versions:**

```bash
cat ~/.claude/skills/user/jimmy-core-preferences/.metadata | grep version
cat ~/.claude/skills/user/session-memoria/.metadata | grep version
```

**Expected versions (as of v1.9.0):**
- jimmy-core-preferences: v1.5.0
- session-memoria: v1.2.0
- x-mem: v1.0.0
- gdrive-sync-memoria: v1.0.0
- claude-session-registry: v1.1.0

---

### Step 4: Test Claude Code Integration (2 minutes)

```bash
# Navigate to any project directory
cd ~/your-project

# Start Claude Code
claude

# In Claude session, verify skills loaded
# Type: "List loaded skills"
# Expected: Should show all 5 mandatory skills auto-loaded
```

**Verification command:**
```
You: List all loaded skills with versions
Claude: [Should show jimmy-core-preferences v1.5.0, session-memoria v1.2.0, etc.]
```

---

## 🔧 Advanced Configuration

### Custom Installation Paths

**Windows (PowerShell):**
```powershell
.\scripts\setup_local_env.ps1 `
  -HubPath "C:\Custom\Path\claude-intelligence-hub" `
  -SkillsPath "C:\Custom\Path\.claude\skills\user"
```

**macOS/Linux (Bash):**
```bash
bash scripts/setup_local_env.sh \
  --hub-path ~/custom/path/claude-intelligence-hub \
  --skills-path ~/custom/path/.claude/skills/user
```

### Skip Validation (Not Recommended)

```bash
# Windows
.\scripts\setup_local_env.ps1 -SkipValidation

# macOS/Linux
bash scripts/setup_local_env.sh --skip-validation
```

### Force Recreate Existing Junctions/Symlinks

Use this if you have old copies instead of junctions/symlinks:

```bash
# Windows
.\scripts\setup_local_env.ps1 -Force

# macOS/Linux
bash scripts/setup_local_env.sh --force
```

---

## 🐛 Troubleshooting

### Issue 1: "Hub directory not found"

**Symptom:**
```
ERROR: Hub directory not found: ~/Downloads/claude-intelligence-hub
```

**Fix:**
```bash
# Verify Git clone completed
cd ~/Downloads
ls -la | grep claude-intelligence-hub

# If missing, re-clone
git clone https://github.com/mrjimmyny/claude-intelligence-hub.git
```

---

### Issue 2: "Access Denied" on Windows

**Symptom:**
```
ERROR: Failed to create junction for jimmy-core-preferences
```

**Fix:**
1. **Do NOT run PowerShell as Administrator** (junctions don't need admin!)
2. Verify paths exist:
   ```powershell
   Test-Path "$env:USERPROFILE\Downloads\claude-intelligence-hub"
   Test-Path "$env:USERPROFILE\.claude\skills\user"
   ```
3. If `.claude\skills\user` doesn't exist, script will create it automatically

---

### Issue 3: Skills Not Auto-Loading in Claude

**Symptom:**
Claude Code starts but skills aren't loaded.

**Fix:**

1. **Verify junctions/symlinks:**
   ```bash
   ls -la ~/.claude/skills/user/
   # Should show 'lrwxrwxrwx' (symlinks) or '<JUNCTION>' (Windows)
   ```

2. **Check if they're copies instead:**
   ```bash
   # Windows (Git Bash)
   stat ~/.claude/skills/user/jimmy-core-preferences/.metadata | grep Inode

   stat ~/Downloads/claude-intelligence-hub/jimmy-core-preferences/.metadata | grep Inode

   # If inode numbers are DIFFERENT, it's a copy (bad!)
   # If SAME, it's a proper junction/symlink (good!)
   ```

3. **Fix: Delete copies and re-run setup with --force:**
   ```bash
   # Windows
   rm -rf ~/.claude/skills/user/jimmy-core-preferences
   .\scripts\setup_local_env.ps1 -Force

   # macOS/Linux
   rm -rf ~/.claude/skills/user/jimmy-core-preferences
   bash scripts/setup_local_env.sh --force
   ```

---

### Issue 4: "Integrity check failed"

**Symptom:**
```
⚠️ Hub integrity check reported issues
```

**Fix:**

1. **Run integrity check manually:**
   ```bash
   cd ~/Downloads/claude-intelligence-hub
   bash scripts/integrity-check.sh
   ```

2. **Common issues:**
   - **Orphaned directories:** Directory exists but not in `HUB_MAP.md`
     - Fix: Add to HUB_MAP or delete directory
   - **Ghost skills:** Listed in `HUB_MAP.md` but directory missing
     - Fix: Create directory or remove from HUB_MAP
   - **Missing .metadata:** Skill directory missing `.metadata` file
     - Fix: Create `.metadata` file or delete skill

3. **Review logs:**
   ```bash
   cat scripts/setup_local_env.log
   ```

---

### Issue 5: Old Versions Loading

**Symptom:**
Claude shows `jimmy-core-preferences v1.0.0` but hub has `v1.5.0`.

**Fix:**

1. **Verify junction/symlink is active:**
   ```bash
   ls -la ~/.claude/skills/user/jimmy-core-preferences
   # Should show '->' symbol (symlink)
   ```

2. **Check if it's a copy:**
   ```bash
   # If it shows 'drwxr-xr-x' (directory) instead of 'lrwxrwxrwx' (symlink):
   rm -rf ~/.claude/skills/user/jimmy-core-preferences

   # Re-run setup
   bash scripts/setup_local_env.sh --force
   ```

3. **Update hub repository:**
   ```bash
   cd ~/Downloads/claude-intelligence-hub
   git pull origin main
   ```

4. **Restart Claude Code**

---

## 🔄 Updating Skills

### Automatic Updates (Recommended)

```bash
# Pull latest hub changes
cd ~/Downloads/claude-intelligence-hub
git pull origin main

# Skills are INSTANTLY updated (no copy needed!)
# Restart Claude Code to reload
```

### Manual Version Sync

If you make local changes to skills:

```bash
# Sync version across .metadata, SKILL.md, HUB_MAP.md
cd ~/Downloads/claude-intelligence-hub
bash scripts/sync-versions.sh jimmy-core-preferences

# Commit and push
git add .
git commit -m "Updated: jimmy-core-preferences"
git push origin main
```

---

## 📊 Verification Checklist

Use this checklist to verify successful installation:

- [ ] Hub repository cloned to `~/Downloads/claude-intelligence-hub`
- [ ] `HUB_MAP.md` exists in hub root
- [ ] Setup script ran without errors
- [ ] 5 mandatory skills installed (verified via `ls -la ~/.claude/skills/user/`)
- [ ] Junctions/symlinks are active (not copies)
- [ ] `integrity-check.sh` passes
- [ ] Claude Code starts and shows loaded skills
- [ ] Skill versions match hub versions (e.g., jimmy-core-preferences v1.5.0)

---

## 🚀 Next Steps After Setup

### 1. Configure GDrive Sync (Optional)

If you use Google Drive for session memories:

```bash
# Follow setup guide
cat ~/Downloads/claude-intelligence-hub/gdrive-sync-memoria/SETUP_GUIDE.md

# Configure rclone remote
rclone config
```

### 2. Test Session Memoria

```bash
# In Claude session
You: "/session-memoria save-note Test note for handover"
Claude: [Saves to session-memoria/memories/]

# Verify
ls ~/Downloads/claude-intelligence-hub/session-memoria/memories/
```

### 3. Review Core Preferences

```bash
# Read master framework
cat ~/Downloads/claude-intelligence-hub/jimmy-core-preferences/SKILL.md
```

### 4. Explore Optional Skills

If you skipped optional skills during setup, you can add them later:

```bash
# Example: Add pbi-claude-skills
cd ~/.claude/skills/user

# Windows
cmd /c mklink /J "pbi-claude-skills" "$env:USERPROFILE\Downloads\claude-intelligence-hub\pbi-claude-skills"

# macOS/Linux
ln -s ~/Downloads/claude-intelligence-hub/pbi-claude-skills pbi-claude-skills
```

---

## 📚 Additional Resources

- **Hub Map:** `~/Downloads/claude-intelligence-hub/HUB_MAP.md`
  Complete skill inventory and version history

- **Executive Summary:** `~/Downloads/claude-intelligence-hub/EXECUTIVE_SUMMARY.md`
  High-level architecture and ROI metrics

- **Integrity Check:** `~/Downloads/claude-intelligence-hub/scripts/integrity-check.sh`
  Run anytime to validate hub consistency

- **Project Final Report:** `~/Downloads/claude-intelligence-hub/docs/PROJECT_FINAL_REPORT.md`
  Comprehensive project documentation (Module 1-4)

- **Per-Skill Setup Guides:**
  - `jimmy-core-preferences/SETUP_GUIDE.md`
  - `session-memoria/SETUP_GUIDE.md`
  - `gdrive-sync-memoria/SETUP_GUIDE.md`

---

## 🆘 Support & Contact

**Issues:**
Open an issue on GitHub: `https://github.com/mrjimmyny/claude-intelligence-hub/issues`

**Questions:**
- Review `HUB_MAP.md` first
- Check skill-specific `SKILL.md` files
- Run `integrity-check.sh` for validation errors

**Contributing:**
See `CONTRIBUTING.md` for development guidelines.

---

## ✅ Handover Complete!

You should now have a fully functional Claude Intelligence Hub with:

- ✅ 5 mandatory core skills auto-loaded
- ✅ Optional skills (if selected)
- ✅ Junctions/symlinks for auto-sync
- ✅ Integrity validation passing
- ✅ Claude Code integration working

**Total setup time:** ~15 minutes
**Next:** Start using Claude Code with the full skill ecosystem!

---

**Document Version:** 1.0.0
**Created:** 2026-02-15
**Part of:** Module 4 - Deployment & CI/CD
