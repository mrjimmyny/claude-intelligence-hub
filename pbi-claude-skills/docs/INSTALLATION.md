# Installation Guide - Power BI Claude Skills

Complete guide to installing and configuring the Power BI Skills Hub in your projects.

## 📋 Prerequisites

### Required
- ✅ **Git** installed (v2.30+)
  ```powershell
  git --version
  # If not installed: winget install Git.Git
  ```

- ✅ **PowerShell** 5.1 or higher
  ```powershell
  $PSVersionTable.PSVersion
  ```

- ✅ **Claude Code CLI** installed
  ```powershell
  claude --version
  ```

- ✅ **Power BI Desktop** (for PBIP projects)
- ✅ **GitHub account** (for cloning the hub)

### Recommended
- Visual Studio Code (for editing configurations)
- GitHub CLI (`gh`) for PR workflows

---

## 🚀 Installation Methods

### Method 1: Automated Setup (Recommended)

**Best for:** New projects or first-time setup

```powershell
# 1. Clone the hub
git clone https://github.com/mrjimmyny/claude-intelligence-hub.git
cd claude-intelligence-hub/pbi-claude-skills/scripts

# 2. Run automated setup
.\setup_new_project.ps1 -ProjectPath "C:\path\to\your\pbi\project"

# 3. Verify installation
cd "C:\path\to\your\pbi\project"
dir .claude\skills
```

**What it does:**
1. Creates `.claude/` structure
2. Clones hub to `.claude/_hub`
3. **Copies skills** to `.claude/skills` (no symlinks)
4. Copies templates (.claudecode.json, settings.local.json, pbi_config.json)
5. Auto-detects semantic model name
6. Creates POWER_BI_INDEX.md (empty)

**Expected output:**
```
🚀 Configurando novo projeto Power BI...
📂 Projeto: C:\path\to\your\pbi\project

📁 Criando estrutura .claude/...
📥 Clonando skills do GitHub...
📋 Copiando skills para o projeto...
📄 Copiando templates...
🔍 Detectando semantic model...
  ✅ Semantic model detectado: YourProject.SemanticModel

✅ Projeto configurado com sucesso!

📋 Próximos passos:
  1. Editar pbi_config.json com informações do projeto
     Path: C:\path\to\your\pbi\project\pbi_config.json

  2. Executar /pbi-index-update para gerar índice completo
     (Abra Claude Code no projeto e execute o comando)

  3. Testar com /pbi-query-structure tabelas
```

---

### Method 2: Manual Setup

**Best for:** Custom configurations or understanding the process

#### Step 1: Clone the Hub

```powershell
cd C:\temp
git clone https://github.com/mrjimmyny/claude-intelligence-hub.git
```

#### Step 2: Create Project Structure

```powershell
cd "C:\path\to\your\pbi\project"
mkdir .claude\skills
```

#### Step 3: Copy Hub

```powershell
cd .claude
git clone https://github.com/mrjimmyny/claude-intelligence-hub.git _hub
```

#### Step 4: Copy Skills

```powershell
# Copy skills (direct copy - not symlink)
$hubSkills = ".\_hub\pbi-claude-skills\skills"
Copy-Item "$hubSkills\*" .\skills\ -Recurse -Force
```

#### Step 5: Copy Templates

```powershell
# .claudecode.json (root of project)
Copy-Item ".\_hub\pbi-claude-skills\templates\.claudecode.template.json" "..\claudecode.json"

# settings.local.json (.claude directory)
Copy-Item ".\_hub\pbi-claude-skills\templates\settings.local.template.json" ".\settings.local.json"

# pbi_config.json (root of project)
Copy-Item ".\_hub\pbi-claude-skills\templates\pbi_config.template.json" "..\pbi_config.json"
```

#### Step 6: Configure pbi_config.json

```powershell
code ..\pbi_config.json
```

Edit the following fields:
```json
{
  "project": {
    "name": "your_project_name",
    "semantic_model": {
      "name": "YourProject.SemanticModel",
      "path": "YourProject.SemanticModel/definition"
    }
  },
  "tables": {
    "main_dax": "DAX"
  }
}
```

#### Step 7: Create Initial Index

```powershell
New-Item POWER_BI_INDEX.md -ItemType File
```

---

## 🔧 Post-Installation

### 1. Generate Project Index

```powershell
# Open Claude Code in project root
cd "C:\path\to\your\pbi\project"
claude

# In Claude Code, run:
/pbi-index-update
```

**Expected:** POWER_BI_INDEX.md populated with tables, relationships, measures

### 2. Verify Skills

```powershell
# In Claude Code:
/pbi-query-structure tabelas
```

**Expected:** List of all tables organized by type (dimension, fact, DAX, etc.)

### 3. Test Measure Addition

```powershell
# In Claude Code:
/pbi-add-measure test_skill "1+1" "#,0"
```

**Expected:** Measure added to `definition/tables/DAX.tmdl`

---

## 📁 Project Structure After Installation

```
your_pbi_project/
├── .claudecode.json               # Claude Code config (deny_read rules)
├── pbi_config.json                # Project-specific settings
├── POWER_BI_INDEX.md              # Generated index
├── YourProject.pbip               # Power BI project file
├── YourProject.SemanticModel/     # Semantic model
│   └── definition/
│       ├── model.tmdl
│       ├── relationships.tmdl
│       └── tables/
│           ├── DAX.tmdl
│           ├── employee.tmdl
│           └── ...
└── .claude/
    ├── _hub/                       # Cloned hub repository
    │   └── pbi-claude-skills/
    │       ├── skills/
    │       ├── templates/
    │       └── scripts/
    ├── skills/                     # Copied skills (working directory)
    │   ├── pbi-add-measure.md
    │   ├── pbi-query-structure.md
    │   ├── pbi-discover.md
    │   ├── pbi-index-update.md
    │   ├── pbi-context-check.md
    │   ├── README.md
    │   └── TESTING.md
    └── settings.local.json         # Local Claude settings
```

---

## 🔄 Updating Skills

### Single Project Update

```powershell
cd your_project\.claude\_hub
git pull origin main

# Re-copy skills after update
cd ..
Copy-Item "_hub\pbi-claude-skills\skills\*" .\skills\ -Recurse -Force
```

### Update All Projects (Automated)

```powershell
cd claude-intelligence-hub\pbi-claude-skills\scripts
.\update_all_projects.ps1
```

**Default search location:** `C:\Users\[user]\Downloads\_pbi_projs`

**Custom location:**
```powershell
.\update_all_projects.ps1 -ProjectsRoot "D:\my_pbi_projects"
```

---

## 🚨 Troubleshooting

### Problem: "Git command not found"

**Solution:**
```powershell
# Install Git
winget install Git.Git

# Or download from: https://git-scm.com/download/win

# Verify installation
git --version
```

---

### Problem: "Execution Policy restricts scripts"

**Symptoms:**
```
.\setup_new_project.ps1: The term '...' is not recognized...
```

**Solution:**
```powershell
# Option 1: Change execution policy (CurrentUser scope)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Option 2: Bypass for single execution
powershell -ExecutionPolicy Bypass -File .\setup_new_project.ps1 -ProjectPath "..."
```

---

### Problem: "Semantic model not detected"

**Symptoms:**
```
⚠️  Múltiplos ou nenhum semantic model encontrado
   Edite manualmente: pbi_config.json
```

**Solution:**
```powershell
# List .SemanticModel directories
Get-ChildItem -Directory -Filter "*.SemanticModel"

# If multiple found, choose the correct one and edit pbi_config.json
code pbi_config.json

# Set manually:
{
  "project": {
    "semantic_model": {
      "name": "CorrectModel.SemanticModel",
      "path": "CorrectModel.SemanticModel/definition"
    }
  }
}
```

---

### Problem: "Skills not working in Claude Code"

**Check:**
```powershell
# 1. Verify skills directory exists
Test-Path .claude\skills

# 2. List skills
Get-ChildItem .claude\skills -Filter "*.md"

# 3. Verify pbi_config.json exists
Test-Path pbi_config.json

# 4. Validate JSON
Get-Content pbi_config.json | ConvertFrom-Json
```

**If invalid JSON:**
```powershell
# Re-copy template
Copy-Item .claude\_hub\pbi-claude-skills\templates\pbi_config.template.json pbi_config.json -Force
```

---

### Problem: "Index not updating"

**Solution:**
```powershell
# Delete and regenerate
Remove-Item POWER_BI_INDEX.md

# In Claude Code:
/pbi-index-update
```

---

## 💡 Best Practices

### 1. Version Control

**Do:**
- ✅ Commit `.claudecode.json` (project-specific rules)
- ✅ Commit `pbi_config.json` (project configuration)
- ✅ Commit `POWER_BI_INDEX.md` (useful for team)

**Don't:**
- ❌ Commit `.claude/_hub/` (local clone of hub)
- ❌ Commit `.claude/skills/` (copied files)
- ❌ Commit `.pbi/cache.abf` (binary cache)

**Recommended .gitignore:**
```gitignore
# Claude hub (local clone)
.claude/_hub/
.claude/skills/

# Power BI cache
.pbi/cache.abf
.pbi/localSettings.json

# Temp files
*.tmp
*.bak
```

---

### 2. Multi-Machine Setup

**Scenario:** Work on same project on different machines

**Setup:**
1. Install hub on both machines (Method 1)
2. Commit `pbi_config.json` and `.claudecode.json` to Git
3. On second machine:
   ```powershell
   git clone your-project-repo
   cd your-project
   .\path\to\setup_new_project.ps1 -ProjectPath .
   ```

**Result:** Skills synchronized automatically via hub

---

### 3. Team Collaboration

**Share with team:**
1. Commit `pbi_config.json` to shared repo
2. Document in project README:
   ```markdown
   ## Claude Code Skills

   This project uses skills from:
   https://github.com/mrjimmyny/claude-intelligence-hub

   Setup:
   ```powershell
   git clone https://github.com/mrjimmyny/claude-intelligence-hub.git
   cd claude-intelligence-hub/pbi-claude-skills/scripts
   .\setup_new_project.ps1 -ProjectPath "path\to\project"
   ```
   ```

---

## 📚 Next Steps

After successful installation:

1. **Read skill documentation:** `.claude/skills/README.md`
2. **Explore workflows:** [CONFIGURATION.md](CONFIGURATION.md)
3. **Learn troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
4. **Migrate existing project:** [MIGRATION.md](MIGRATION.md)

---

**Questions or issues?** https://github.com/mrjimmyny/claude-intelligence-hub/issues
