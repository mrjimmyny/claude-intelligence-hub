# 🚀 Developer Cheat Sheet

**Quick reference for common tasks in Claude Intelligence Hub**

---

## 💡 Adding a New Skill (The "Colinha")

### The 4-Step Process

```bash
# 1️⃣ Create skill structure
cd /c/ai/claude-intelligence-hub
mkdir my-new-skill && cd my-new-skill

# Create SKILL.md with frontmatter (MANDATORY: include command:)
cat > SKILL.md << 'EOF'
---
name: my-new-skill
description: Brief description
command: /my-skill
aliases: [/alias1]
---

# My New Skill
...
EOF

# Create .metadata
cat > .metadata << 'EOF'
{
  "name": "my-new-skill",
  "version": "1.0.0",
  "status": "active",
  "description": "Brief description",
  "category": "productivity",
  "dependencies": [],
  "tags": []
}
EOF

# Create README.md
cat > README.md << 'EOF'
# My New Skill
Overview...
EOF

# 2️⃣ Sync to global directory
cd ../scripts
./sync-skills-global.ps1  # Windows
# OR
./sync-skills-global.sh   # Bash/WSL

# 3️⃣ Restart Claude Code
# Close and reopen

# 4️⃣ Validate
/repo-auditor --mode AUDIT_AND_FIX
```

**Done!** Your `/my-skill` command is live! ✅

---

## 🔧 Common Commands

### Sync Skills Globally
```powershell
# PowerShell
C:\ai\claude-intelligence-hub\scripts\sync-skills-global.ps1

# Bash/WSL
/c/ai/claude-intelligence-hub/scripts/sync-skills-global.sh
```

### Validate Repository
```bash
/repo-auditor --mode AUDIT_AND_FIX    # Auto-fix issues
/repo-auditor --mode AUDIT_ONLY       # Report only
/repo-auditor --mode DRY_RUN          # Simulate
```

### Test Your Skill
```bash
# List all skills
/skills

# Run your skill
/my-skill

# Check if command exists
/my-skill --help
```

---

## 📋 Required Skill Structure

```
my-new-skill/
├── SKILL.md        # WITH command: in frontmatter!
├── README.md       # User documentation
└── .metadata       # JSON metadata
```

### SKILL.md Frontmatter (Mandatory)
```yaml
---
name: my-new-skill
description: Brief description
command: /my-skill        # ← CRITICAL: Don't forget!
aliases: [/alias1, /ms]
---
```

### .metadata Fields (All Required)
```json
{
  "name": "my-new-skill",
  "version": "1.0.0",
  "status": "active",
  "description": "Brief description",
  "category": "productivity",
  "dependencies": [],
  "tags": []
}
```

**Categories:**
- `productivity`, `memory`, `governance`, `integration`, `automation`, `documentation`

---

## ✅ Pre-Submit Checklist

Before pushing your changes:

- [ ] `command:` defined in SKILL.md frontmatter
- [ ] All 3 required files exist (SKILL.md, README.md, .metadata)
- [ ] Skill synced: `scripts/sync-skills-global.ps1`
- [ ] Claude Code restarted
- [ ] Slash command works: `/my-skill`
- [ ] Repo auditor passes: `/repo-auditor --mode AUDIT_AND_FIX`
- [ ] CHANGELOG.md updated with new version
- [ ] Documentation is comprehensive

---

## 🚨 Common Issues & Fixes

### "Unknown skill: my-skill"
```bash
# Fix: Sync and restart
cd /c/ai/claude-intelligence-hub/scripts
./sync-skills-global.ps1
# Restart Claude Code
```

### "SKILL.md lacks 'command:' in frontmatter"
```yaml
# Fix: Add to SKILL.md frontmatter
---
name: my-skill
command: /my-skill  # ← Add this line!
---
```

### "Command documentation out of sync"
```bash
# Fix: Run repo-auditor (auto-fixes)
/repo-auditor --mode AUDIT_AND_FIX
```

### "Duplicate command definitions"
```bash
# Fix: Choose unique command name
# Edit SKILL.md → change command: /my-unique-skill
# Re-sync and validate
```

---

## 📊 Validation Rules

The repo-auditor enforces:

| Rule | Severity | Auto-Fix |
|------|----------|----------|
| Missing `command:` in SKILL.md | CRITICAL ERROR ❌ | No |
| Command not in docs (HUB_MAP, README, COMMANDS) | CRITICAL ERROR ❌ | Yes |
| Duplicate commands | CRITICAL ERROR ❌ | No |
| Missing skill in EXECUTIVE_SUMMARY | CRITICAL ERROR ❌ | Yes |
| Missing .metadata fields | CRITICAL ERROR ❌ | No |
| Broken links (critical files) | CRITICAL ERROR ❌ | No |
| Non-UTF-8 encoding | WARNING ⚠️ | No |
| Broken links (non-critical) | WARNING ⚠️ | No |

---

## 🔄 Update Existing Skill

```bash
# 1. Make changes to skill files

# 2. Bump version in .metadata
# "version": "1.0.0" → "1.1.0"

# 3. Update CHANGELOG.md
echo "## [1.1.0] - $(date +%Y-%m-%d)" >> CHANGELOG.md
echo "- Added: new feature" >> CHANGELOG.md

# 4. Validate
/repo-auditor --mode AUDIT_AND_FIX
```

---

## 📖 Full Documentation

| Document | Purpose |
|----------|---------|
| [CONTRIBUTING.md](CONTRIBUTING.md) | Complete contribution guide |
| [QUICKSTART_NEW_SKILL.md](QUICKSTART_NEW_SKILL.md) | 5-minute quick start |
| [scripts/README.md](scripts/README.md) | Sync script documentation |
| [README.md](README.md) | Main hub overview |
| [CIH-ROADMAP.md](CIH-ROADMAP.md) | Navigation guide |

---

## 🎯 Quick Links

| Action | Command/Link |
|--------|--------------|
| Add new skill | See "The 4-Step Process" above ⬆️ |
| Sync skills | `scripts/sync-skills-global.ps1` |
| Validate repo | `/repo-auditor --mode AUDIT_AND_FIX` |
| List skills | `/skills` |
| Full guide | [CONTRIBUTING.md](CONTRIBUTING.md) |

---

**Keep this file bookmarked for quick reference!** 📌

**Last Updated:** 2026-02-25
