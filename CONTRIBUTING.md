# 🤝 Contributing to Claude Intelligence Hub

Thank you for your interest in contributing! This guide will help you add new skills, fix issues, and improve the hub.

---

## 💡 The Golden Rule: Command-First Development

**Every skill MUST have a slash command defined in SKILL.md frontmatter.**

This is automatically validated by the repo-auditor. Missing commands will block the build.

---

## ⚡ Quick Start: Adding a New Skill

### The 4-Step "Colinha" (Cheat Sheet)

```bash
# 1️⃣ Create skill with command: in SKILL.md frontmatter
cd /c/ai/claude-intelligence-hub
mkdir my-new-skill && cd my-new-skill

# Create required files (see template below)

# 2️⃣ Sync to global skills directory
cd ../scripts
./sync-skills-global.ps1  # Windows PowerShell
# OR
./sync-skills-global.sh   # Bash/WSL/Git Bash

# 3️⃣ Restart Claude Code
# Close and reopen Claude Code

# 4️⃣ Validate with repo-auditor
/repo-auditor --mode AUDIT_AND_FIX
```

**Done!** Your skill is now available globally as `/my-skill` ✅

---

## 📋 Skill Template

### Minimum Required Files

Every skill needs these 3 files:

```
my-new-skill/
├── SKILL.md        # Skill definition with frontmatter
├── README.md       # User-facing documentation
└── .metadata       # Skill metadata (JSON)
```

### 1. SKILL.md Template

```markdown
---
name: my-new-skill
description: Brief description of what this skill does
command: /my-skill
aliases: [/myskill, /ms]
---

# My New Skill

## Objective
Clear statement of what this skill accomplishes.

## Usage
\```bash
/my-skill [OPTIONS]
\```

## Parameters
- `--option`: Description of option

## Examples
\```bash
# Example 1
/my-skill --option value

# Example 2
/my-skill
\```

## Implementation
Step-by-step protocol for executing this skill.

## Validation
How to verify the skill worked correctly.
```

### 2. README.md Template

```markdown
# My New Skill

## Overview
User-friendly description of the skill.

## Quick Start
\```bash
/my-skill
\```

## Features
- Feature 1
- Feature 2

## Configuration
Any required setup or configuration.

## Examples
Detailed usage examples.

## Troubleshooting
Common issues and solutions.
```

### 3. .metadata Template

```json
{
  "name": "my-new-skill",
  "version": "1.0.0",
  "status": "active",
  "description": "Brief description",
  "category": "productivity",
  "dependencies": [],
  "tags": ["tag1", "tag2"]
}
```

**Categories:**
- `productivity` - Workflow enhancement
- `memory` - Memory/storage systems
- `governance` - Policy/standards enforcement
- `integration` - External service integration
- `automation` - Task automation
- `documentation` - Documentation tools

---

## 🔍 Validation Rules (Auto-Enforced)

The repo-auditor automatically validates:

### ✅ CRITICAL (Build Blockers)

1. **Command Definition**
   - Every skill MUST have `command:` in SKILL.md frontmatter
   - Missing → `CRITICAL ERROR` → Build fails

2. **Command Documentation Sync**
   - Commands must appear in HUB_MAP.md, README.md, COMMANDS.md
   - Out of sync → Auto-fixed by repo-auditor

3. **Command Uniqueness**
   - No duplicate commands allowed
   - Collision → `CRITICAL ERROR` → Build fails

4. **Component Version Tracking**
   - All skills must be in EXECUTIVE_SUMMARY.md Component Versions
   - Missing → Auto-fixed by repo-auditor

5. **Metadata Completeness**
   - All required .metadata fields must be present
   - Missing → `CRITICAL ERROR` → Build fails

6. **File Structure**
   - SKILL.md, README.md, .metadata all required
   - Missing → `CRITICAL ERROR` → Build fails

### ⚠️ WARNINGS (Non-Blocking)

- Encoding issues (non-UTF-8)
- Missing optional files (LICENSE in skill dir)
- Broken links to non-critical files
- Formatting inconsistencies

---

## 🚀 Pull Request Process

### 1. Fork & Branch

```bash
# Fork the repo on GitHub
git clone https://github.com/YOUR_USERNAME/claude-intelligence-hub.git
cd claude-intelligence-hub

# Create feature branch
git checkout -b feature/my-new-skill
```

### 2. Develop Your Skill

Follow the 4-step process above.

### 3. Test Locally

```bash
# Sync skills
cd scripts
./sync-skills-global.ps1

# Restart Claude Code

# Test your skill
/my-skill

# Validate with repo-auditor
/repo-auditor --mode AUDIT_AND_FIX
```

### 4. Update Documentation

The repo-auditor will auto-update:
- HUB_MAP.md
- README.md Quick Commands
- COMMANDS.md
- EXECUTIVE_SUMMARY.md

But you should manually update:
- CHANGELOG.md (add entry for your version)
- Your skill's README.md (comprehensive docs)

### 5. Commit & Push

```bash
git add .
git commit -m "feat: add my-new-skill for X functionality"
git push origin feature/my-new-skill
```

### 6. Open Pull Request

- Go to GitHub
- Open PR from your branch to `main`
- Fill out PR template
- Wait for CI/CD validation (automatic)
- Address any review comments

---

## 📝 Commit Message Convention

We use **semantic commit messages**:

```
<type>: <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New skill or feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements

**Examples:**
```
feat: add quick-backup skill for automated backups

fix: repo-auditor not detecting missing commands

docs: improve CONTRIBUTING.md with templates

refactor: simplify sync-skills-global script
```

---

## 🧪 Testing Checklist

Before submitting your PR, verify:

- [ ] Skill has `command:` in SKILL.md frontmatter
- [ ] All 3 required files exist (SKILL.md, README.md, .metadata)
- [ ] Skill syncs to global directory successfully
- [ ] Slash command works: `/my-skill`
- [ ] Repo auditor passes: `/repo-auditor --mode AUDIT_AND_FIX`
- [ ] No duplicate commands
- [ ] CHANGELOG.md updated
- [ ] Documentation is clear and comprehensive
- [ ] Examples are tested and working

---

## 🏗️ Advanced: Multi-File Skills

Some skills may need additional files:

```
my-complex-skill/
├── SKILL.md
├── README.md
├── .metadata
├── lib/                 # Optional: helper scripts
│   └── helper.sh
├── templates/           # Optional: file templates
│   └── template.yaml
├── tests/               # Optional: validation tests
│   └── test.sh
└── docs/                # Optional: extended docs
    └── advanced.md
```

**Guidelines:**
- Keep skill directory organized
- Document additional files in README.md
- Use relative paths for imports
- Include setup instructions if needed

---

## 🔄 Updating Existing Skills

### Version Bump

Update both files:
1. `.metadata` → `"version": "1.1.0"`
2. `CHANGELOG.md` → Add entry for new version

### Breaking Changes

If your update changes the skill's interface:
1. Bump major version: `1.0.0` → `2.0.0`
2. Document migration path in CHANGELOG
3. Update all examples in documentation

### Run Repo Auditor

Always validate after updates:
```bash
/repo-auditor --mode AUDIT_AND_FIX
```

---

## 📖 Documentation Standards

### SKILL.md

- **Frontmatter:** Always include name, description, command, aliases
- **Objective:** Clear, one-sentence goal
- **Usage:** Command syntax with placeholders
- **Examples:** Real, tested examples
- **Implementation:** Step-by-step protocol

### README.md

- **Overview:** User-friendly introduction
- **Quick Start:** Simplest usage example
- **Features:** Bulleted list of capabilities
- **Examples:** Comprehensive, copy-pasteable examples
- **Troubleshooting:** Common issues with solutions

### Code Comments

- Explain WHY, not WHAT (code shows what)
- Document assumptions and edge cases
- Include examples for complex logic

---

## 🆘 Getting Help

### Questions?

- 📖 Read [CIH-ROADMAP.md](CIH-ROADMAP.md) for navigation
- 📚 Check [QUICKSTART_NEW_SKILL.md](QUICKSTART_NEW_SKILL.md) for quick guide
- 🔧 See [scripts/README.md](scripts/README.md) for sync script details
- 💬 Open a GitHub Discussion for questions
- 🐛 Open an Issue for bugs

### Common Issues

**"Unknown skill: my-skill"**
→ Run sync script and restart Claude Code

**"SKILL.md lacks 'command:' in frontmatter"**
→ Add `command: /skill-name` to SKILL.md frontmatter

**"Command documentation out of sync"**
→ Run `/repo-auditor --mode AUDIT_AND_FIX`

**"Duplicate command definitions"**
→ Choose unique command, update SKILL.md, re-sync

---

## 🎯 Quick Reference Card

### I want to...

**Add a new skill:**
1. Create skill files (SKILL.md, README.md, .metadata)
2. Run `scripts/sync-skills-global.ps1`
3. Restart Claude Code
4. Run `/repo-auditor --mode AUDIT_AND_FIX`

**Update existing skill:**
1. Make changes
2. Bump version in `.metadata`
3. Update `CHANGELOG.md`
4. Run `/repo-auditor --mode AUDIT_AND_FIX`

**Test my skill:**
1. `/my-skill` (try the command)
2. `/repo-auditor --mode AUDIT_AND_FIX` (validate)

**Submit contribution:**
1. Fork repo
2. Create feature branch
3. Add skill following 4-step process
4. Push and open PR

---

## 📊 Contribution Statistics

Want to see your impact? After your PR is merged:
- Your skill appears in HUB_MAP.md skill count
- EXECUTIVE_SUMMARY.md lists your skill version
- CHANGELOG.md documents your contribution
- README.md Quick Commands table includes your skill

---

## ⚠️ Adding Files to Repository Root

**CRITICAL:** The hub has a **Zero Tolerance policy** for unauthorized root files to maintain organization.

### The Rule

Only files explicitly listed in `scripts/integrity-check.sh` are allowed in the repository root.

### If You Need to Add a Root File

**Example:** Adding `NEW_GUIDE.md` to the root

1. **Add to approved list:**
   ```bash
   # Edit scripts/integrity-check.sh
   # Find the approved_files array and add your file:

   approved_files=(
       "CHANGELOG.md"
       "COMMANDS.md"
       "CONTRIBUTING.md"
       "NEW_GUIDE.md"        # ← Add here (alphabetically)
       ...
   )
   ```

2. **Test locally:**
   ```bash
   bash scripts/integrity-check.sh
   ```

3. **Verify all checks pass:**
   ```
   ✅ Passed: 6
   ❌ Failed: 0
   ```

4. **Commit both files together:**
   ```bash
   git add NEW_GUIDE.md scripts/integrity-check.sh
   git commit -m "docs: add NEW_GUIDE.md with integrity approval"
   git push
   ```

### Why This Matters

- **Prevents clutter:** Keeps root directory clean
- **Enforces organization:** Documents every root file explicitly
- **Fails CI/CD:** Unauthorized files block merges
- **Zero surprises:** Everyone knows what's allowed

### Common Mistake

❌ **Wrong:** Add file to root → Commit → Push → CI/CD fails

✅ **Right:** Add file to root → Update approved_files → Test → Commit → Push → CI/CD passes

### When CI/CD Fails with "CLUTTER"

```
🗑️ CLUTTER: YOUR_FILE.md (unauthorized root file)
Fix: Move to skill directory or delete
```

**Solution:** Add to `scripts/integrity-check.sh` approved_files array

---

## 🙏 Thank You!

Every contribution makes Claude Code more powerful for the entire community. Whether you're adding a skill, fixing a bug, or improving docs — thank you for making this hub better! 🚀

---

**Need the quick cheat sheet?** → See top of this file (4-Step "Colinha")

**Ready to contribute?** → Follow the Pull Request Process section

**Questions?** → Open a GitHub Discussion

**Let's build something amazing together!** ✨
