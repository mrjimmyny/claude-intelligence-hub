# Troubleshooting Guide

Common issues and solutions when using Power BI Skills Hub.

## 🔧 Installation Issues

### Git Command Not Found

**Symptoms:**
```
'git' is not recognized as an internal or external command
```

**Solutions:**
```powershell
# Option 1: Install via winget
winget install Git.Git

# Option 2: Download installer
# https://git-scm.com/download/win

# Verify
git --version
```

---

### PowerShell Execution Policy

**Symptoms:**
```
cannot be loaded because running scripts is disabled
```

**Solutions:**
```powershell
# Option 1: Change policy for current user
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Option 2: Bypass for single execution
powershell -ExecutionPolicy Bypass -File .\setup_new_project.ps1 -ProjectPath "..."

# Verify
Get-ExecutionPolicy -List
```

---

### Semantic Model Not Detected

**Symptoms:**
```
⚠️  Múltiplos ou nenhum semantic model encontrado
```

**Diagnosis:**
```powershell
# List .SemanticModel directories
Get-ChildItem -Directory -Filter "*.SemanticModel"
```

**Solutions:**

**If multiple found:**
```powershell
# Edit pbi_config.json manually
code pbi_config.json

# Set correct model:
{
  "project": {
    "semantic_model": {
      "name": "CorrectModel.SemanticModel",
      "path": "CorrectModel.SemanticModel/definition"
    }
  }
}
```

**If none found:**
- Verify you're in correct directory
- Check project is PBIP format (not .pbix)
- Convert .pbix to PBIP in Power BI Desktop

---

## 🎯 Skill Execution Issues

### Skill Not Recognized

**Symptoms:**
```
Unknown command: /pbi-add-measure
```

**Diagnosis:**
```powershell
# Check skills directory exists
Test-Path .claude\skills

# List skills
Get-ChildItem .claude\skills -Filter "*.md"
```

**Solutions:**

**If directory missing:**
```powershell
# Re-run setup
.\path\to\setup_new_project.ps1 -ProjectPath .
```

**If skills missing:**
```powershell
# Re-copy from hub
cd .claude
Copy-Item "_hub\pbi-claude-skills\skills\*" .\skills\ -Recurse -Force
```

---

### pbi_config.json Not Found

**Symptoms:**
```
Error: pbi_config.json not found in project root
```

**Diagnosis:**
```powershell
# Check if exists
Test-Path pbi_config.json
```

**Solution:**
```powershell
# Copy template
Copy-Item .claude\_hub\pbi-claude-skills\templates\pbi_config.template.json .\pbi_config.json

# Edit with your project info
code pbi_config.json
```

---

### Invalid JSON in pbi_config.json

**Symptoms:**
```
Error parsing JSON: ...
```

**Diagnosis:**
```powershell
# Test JSON parsing
try {
    Get-Content pbi_config.json | ConvertFrom-Json
    Write-Host "JSON is valid"
} catch {
    Write-Host "JSON Error: $($_.Exception.Message)"
}
```

**Common Issues:**
- Trailing comma: `"field": "value",` after last item
- Missing quotes: `{name: "value"}` should be `{"name": "value"}`
- Wrong path separator: Use `/` or `\\`, not `\`

**Solution:**
```powershell
# Use JSON validator
code pbi_config.json  # VSCode shows JSON errors

# Or re-copy template
Copy-Item .claude\_hub\pbi-claude-skills\templates\pbi_config.template.json .\pbi_config.json -Force
```

---

## 📊 Index Issues

### POWER_BI_INDEX.md Empty or Outdated

**Symptoms:**
- `/pbi-query-structure` returns nothing
- Index shows old table count

**Solution:**
```powershell
# Regenerate index
# In Claude Code:
/pbi-index-update
```

**If still fails:**
```powershell
# Delete and recreate
Remove-Item POWER_BI_INDEX.md
# In Claude Code:
/pbi-index-update
```

---

### Index Generation Fails

**Symptoms:**
```
Error reading definition/tables/*.tmdl
```

**Diagnosis:**
```powershell
# Verify semantic model path
$config = Get-Content pbi_config.json | ConvertFrom-Json
$defPath = $config.project.semantic_model.path
Test-Path "$defPath\tables"
```

**Solution:**
```powershell
# Fix path in pbi_config.json
code pbi_config.json

# Correct format:
{
  "project": {
    "semantic_model": {
      "path": "YourProject.SemanticModel/definition"  // Not "definition" alone
    }
  }
}
```

---

## 🔄 Update Issues

### update_all_projects.ps1 Skips Projects

**Symptoms:**
```
⚠️  Hub não encontrado (não configurado)
```

**Diagnosis:**
```powershell
# Check if .claude\_hub exists
Test-Path your-project\.claude\_hub
```

**Solution:**
```powershell
# Run setup on skipped project
.\setup_new_project.ps1 -ProjectPath "path\to\skipped\project"
```

---

### Git Pull Fails in _hub

**Symptoms:**
```
error: Your local changes to the following files would be overwritten by merge
```

**Diagnosis:**
```powershell
cd .claude\_hub
git status
```

**Solution:**
```powershell
# If you made local changes to hub (not recommended):
git stash
git pull
git stash pop

# Better: Reset to hub version
git reset --hard origin/main
git pull
```

---

## 📝 Measure Addition Issues

### Measure Not Added to DAX.tmdl

**Symptoms:**
- `/pbi-add-measure` completes but measure not in file

**Diagnosis:**
```powershell
# Check if DAX table exists
$config = Get-Content pbi_config.json | ConvertFrom-Json
$daxTable = $config.tables.main_dax
$defPath = $config.project.semantic_model.path
Test-Path "$defPath\tables\$daxTable.tmdl"
```

**Solution:**
```powershell
# If table name wrong in config:
code pbi_config.json

# Set correct table name:
{
  "tables": {
    "main_dax": "ActualTableName"  // Not "DAX" if different
  }
}
```

---

### lineageTag UUID Collision

**Symptoms:**
```
Warning: Duplicate lineageTag detected
```

**Diagnosis:**
```powershell
# Rare - UUIDs should be unique
# Claude regenerates UUIDs automatically
```

**Solution:**
- Ignore warning (Claude will generate new UUID next time)
- Or manually edit `.tmdl` and change lineageTag

---

## 🧠 Context Management Issues

### Claude "Forgets" Configuration

**Symptoms:**
- Claude asks for project info repeatedly
- Skills fail after working before

**Diagnosis:**
- Context window filled
- Session too long

**Solution:**
```powershell
# In Claude Code, run:
/compact

# Or restart Claude session:
# Ctrl+C to exit, then `claude` again
```

**Prevention:**
- Use `/pbi-context-check` to monitor context
- Compact when warned (Yellow/Red alerts)

---

## 🚨 Performance Issues

### Skills Run Slowly

**Symptoms:**
- `/pbi-query-structure` takes >10 seconds
- `/pbi-index-update` takes >2 minutes

**Diagnosis:**
```powershell
# Check project size
$defPath = (Get-Content pbi_config.json | ConvertFrom-Json).project.semantic_model.path
$tableCount = (Get-ChildItem "$defPath\tables" -Filter "*.tmdl").Count
Write-Host "Tables: $tableCount"

# Check index size
(Get-Item POWER_BI_INDEX.md).Length / 1KB
```

**Solutions:**

**If 100+ tables:**
- Use `/pbi-query-structure medidas keyword` (filtered query)
- Avoid reading all `.tmdl` files at once

**If index > 500KB:**
- Normal for large projects
- Index still faster than reading raw files (92% token savings)

---

## 💡 Prevention Best Practices

### Regular Maintenance

```powershell
# Weekly routine:

# 1. Update hub
cd .claude\_hub
git pull

# 2. Re-copy skills
cd ..
Copy-Item "_hub\pbi-claude-skills\skills\*" .\skills\ -Recurse -Force

# 3. Regenerate index
# In Claude Code:
/pbi-index-update

# 4. Test
/pbi-query-structure tabelas
```

### Validation Before Commits

```powershell
# Before committing changes:
cd .claude\_hub\pbi-claude-skills\scripts
.\validate_skills.ps1

# Should return:
# SUCCESS: Validation passed - No errors found
```

---

## 📞 Getting Help

### Check Documentation First

1. [INSTALLATION.md](INSTALLATION.md) - Setup issues
2. [CONFIGURATION.md](CONFIGURATION.md) - Config issues
3. [MIGRATION.md](MIGRATION.md) - Migration issues
4. This file - Everything else

### Search Existing Issues

https://github.com/mrjimmyny/claude-intelligence-hub/issues

### Open New Issue

**Include:**
- OS version: `winver` output
- PowerShell version: `$PSVersionTable.PSVersion`
- Git version: `git --version`
- Claude Code version: `claude --version`
- Error message (full output)
- Steps to reproduce

**Example:**
```markdown
## Issue: setup_new_project.ps1 fails to detect semantic model

**Environment:**
- OS: Windows 11 23H2
- PowerShell: 7.4.0
- Git: 2.43.0
- Claude Code: 1.2.0

**Error:**
```
⚠️  Múltiplos ou nenhum semantic model encontrado
```

**Steps to reproduce:**
1. Clone hub
2. Run `.\setup_new_project.ps1 -ProjectPath "C:\projects\my_pbi"`
3. Error appears

**Project structure:**
```
my_pbi/
├── Model1.SemanticModel/
└── Model2.SemanticModel/  # <-- Multiple models
```

**Expected:** Script should prompt to choose model
**Actual:** Script exits with warning
```

---

**Still stuck?** https://github.com/mrjimmyny/claude-intelligence-hub/discussions
