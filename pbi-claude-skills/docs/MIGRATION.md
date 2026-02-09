# Migration Guide - Existing Projects to Skills Hub

Guide for migrating existing Power BI projects to use the centralized skills hub.

## 🎯 Overview

**When to use this guide:**
- You have an existing Power BI PBIP project
- You want to adopt the skills hub for better management
- You already have local skills that need updating

**Migration time:** ~10 minutes per project

---

## 📋 Pre-Migration Checklist

- [ ] Backup project (commit to Git or copy directory)
- [ ] Verify project is Power BI PBIP format (.pbip)
- [ ] Git installed and configured
- [ ] Claude Code installed

---

## 🚀 Migration Steps

### Step 1: Backup Current Skills (if any)

```powershell
$project = "C:\path\to\your\project"
cd $project

# If you have existing .claude/skills, backup
if (Test-Path ".claude\skills") {
    Copy-Item ".claude\skills" ".claude\skills.backup" -Recurse
}
```

### Step 2: Run Setup Script

```powershell
# Clone hub (if not already cloned)
git clone https://github.com/mrjimmyny/claude-intelligence-hub.git C:\temp\claude-intelligence-hub

# Run setup
cd C:\temp\claude-intelligence-hub\pbi-claude-skills\scripts
.\setup_new_project.ps1 -ProjectPath $project
```

### Step 3: Review pbi_config.json

```powershell
code "$project\pbi_config.json"
```

**Verify:**
- `semantic_model.name` matches your `.SemanticModel` folder
- `semantic_model.path` points to correct definition directory
- `tables.main_dax` matches your DAX table name

### Step 4: Regenerate Index

```powershell
cd $project
claude

# In Claude:
/pbi-index-update
```

### Step 5: Test Skills

```powershell
# In Claude:
/pbi-query-structure tabelas
/pbi-add-measure test_migration "1+1" "#,0"
```

### Step 6: Cleanup (Optional)

```powershell
# If everything works, remove backup
Remove-Item "$project\.claude\skills.backup" -Recurse
```

---

## 📊 Migration for Multiple Projects

**Scenario:** You have 9+ projects to migrate

```powershell
# List your projects
$projectsRoot = "C:\Users\$env:USERNAME\Downloads\_pbi_projs"
$projects = Get-ChildItem $projectsRoot -Filter "_project_pbip_*"

# Migrate each
foreach ($proj in $projects) {
    Write-Host "Migrating: $($proj.Name)"
    .\setup_new_project.ps1 -ProjectPath $proj.FullName
}
```

---

## 🔄 Migrating Custom Skills

**If you have custom skills not in the hub:**

### Option 1: Keep Both (Recommended)

```powershell
# Hub skills in .claude/skills/
# Custom skills in .claude/custom_skills/

mkdir .claude\custom_skills
Move-Item .claude\skills.backup\my-custom-skill.md .claude\custom_skills\
```

Update `.claude/settings.local.json`:
```json
{
  "skills_directories": [
    ".claude/skills",
    ".claude/custom_skills"
  ]
}
```

### Option 2: Contribute to Hub

```powershell
# Fork hub repository
# Add your skill to fork
# Submit Pull Request

# Example:
cp .claude\skills.backup\my-custom-skill.md C:\temp\claude-intelligence-hub\pbi-claude-skills\skills\
cd C:\temp\claude-intelligence-hub
git checkout -b feature/add-my-custom-skill
git add pbi-claude-skills\skills\my-custom-skill.md
git commit -m "Add: my-custom-skill for X"
git push origin feature/add-my-custom-skill
# Open PR on GitHub
```

---

## ⚙️ Configuration Migration

### Existing .claudecode.json

**If you have custom deny_read rules:**

```powershell
# Compare your .claudecode.json with template
$yours = Get-Content .claudecode.json | ConvertFrom-Json
$template = Get-Content .claude\_hub\pbi-claude-skills\templates\.claudecode.template.json | ConvertFrom-Json

# Merge manually (keep your custom rules)
```

**Recommended:** Keep hub template + add your custom rules

---

## 🧪 Validation After Migration

### Run Validation Script

```powershell
cd .claude\_hub\pbi-claude-skills\scripts
.\validate_skills.ps1
```

**Expected:** 0 errors, 0-2 warnings

### Manual Tests

```powershell
# In Claude Code:

# 1. Discovery
/pbi-discover

# 2. Query structure
/pbi-query-structure medidas revenue

# 3. Add measure
/pbi-add-measure test_post_migration "2+2" "#,0"

# 4. Context check
/pbi-context-check
```

---

## 🚨 Rollback Procedure

**If migration fails:**

```powershell
# Restore backup
Remove-Item .claude\skills -Recurse -Force
Rename-Item .claude\skills.backup .claude\skills

# Restore original config
git restore .claudecode.json pbi_config.json

# Remove hub clone
Remove-Item .claude\_hub -Recurse -Force
```

---

## 📈 Post-Migration Benefits

**Before Migration:**
- ❌ Manual updates to skills (5+ min per project)
- ❌ No version control on skills
- ❌ Hard-coded paths (project-specific)

**After Migration:**
- ✅ `git pull` updates all skills (5 seconds)
- ✅ Full Git history of skills
- ✅ Portable configuration (pbi_config.json)
- ✅ Automated setup for new projects

---

## 💡 Best Practices Post-Migration

### 1. Regular Updates

```powershell
# Weekly (or after hub announcements)
cd your-project\.claude\_hub
git pull
Copy-Item pbi-claude-skills\skills\* ..\skills\ -Recurse -Force
```

### 2. Version Pinning (Optional)

```powershell
# Pin to specific hub version
cd .claude\_hub
git checkout v1.0.0  # Replace with desired version
```

### 3. Team Communication

**Notify team members:**
```markdown
## Project Updated to Skills Hub

Skills are now managed via: https://github.com/mrjimmyny/claude-intelligence-hub

**Setup on your machine:**
```powershell
git pull
cd .
.\path\to\setup_new_project.ps1 -ProjectPath .
```

**Benefits:**
- Faster skill updates
- Standardized workflows
- Better documentation
```

---

**Need help?** https://github.com/mrjimmyny/claude-intelligence-hub/issues
