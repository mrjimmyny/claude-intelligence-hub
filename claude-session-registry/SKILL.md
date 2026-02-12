# Claude Session Registry - Skill Workflows

**Version:** 1.0.0
**Type:** Session Tracking with Git Context
**Language:** pt-BR (Brazilian Portuguese)
**Timezone:** America/Sao_Paulo

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Golden Close Protocol](#golden-close-protocol)
3. [Register Workflow](#register-workflow)
4. [Search Workflow](#search-workflow)
5. [Stats Workflow](#stats-workflow)
6. [Validation Rules](#validation-rules)
7. [Git Integration](#git-integration)
8. [Best Practices](#best-practices)

---

## 🎯 OVERVIEW

This skill enables Claude (Xavier) to track session metadata with automatic Git context capture.

### Features
- **Session Resume ID** tracking (for `claude --resume`)
- **Auto-capture Git context** (branch + commit hash)
- **Multi-machine tracking** (Machine ID)
- **Project path** recording
- **Tags & Summary** (achievements/conquistas)
- **Golden Close Protocol** (mandatory reminder when tasks complete)
- **Hierarchical storage** (registry/YYYY/MM/SESSIONS.md)
- **Brazilian timezone** support (America/Sao_Paulo)

### Data Schema

| Column | Source | Example |
|--------|--------|---------|
| Session ID | User provides | `claude-20260212-1430-a4f9` |
| Date | Auto-capture | `2026-02-12` |
| Time | Auto-capture | `14:30` |
| Machine | Auto-capture | `DESKTOP-ABC` |
| Branch | Auto-capture | `main` |
| Commit | Auto-capture | `abc1234` |
| Project | Auto-capture | `/c/Users/jimmy/project` |
| Tags | User provides | `#BI #MCP` |
| Summary | User provides | `- Item 1<br>- Item 2<br>- Item 3` |

---

## 🚨 GOLDEN CLOSE PROTOCOL

**Trigger:** Whenever Xavier (Claude) completes ANY task or plan for Jimmy.

### Protocol Flow

#### Step 1: Completion Check
When a task/plan is completed, Xavier ALWAYS asks:

```
🎯 Os tópicos desta sessão foram finalizados?
```

#### Step 2: Session Analysis (If YES)
If Jimmy confirms completion, Xavier **IMMEDIATELY ANALYZES** the current session and generates:

1. **Suggested Tags** (3-4 tags based on work done)
   - Examples: `#BI`, `#MCP`, `#Refactor`, `#Bug`, `#Feature`, `#Docs`
   - Based on: files modified, technologies used, type of work

2. **Suggested Summary** (3-5 bullet points)
   - Key achievements/conquistas
   - Major changes/modifications
   - Important decisions/decisions
   - Format: `- Action + context`

#### Step 3: Emphatic Alert (MANDATORY)
Xavier displays this alert with **PRE-GENERATED DATA**:

```
🚨🚨🚨 IMPORTANTE 🚨🚨🚨

COPIE O SESSION ID APÓS USAR `exit`!

📋 Dados da sessão capturados (guarde isso):

🏷️ Tags sugeridas: [GENERATED_TAGS]

📝 Summary sugerido:
[GENERATED_BULLETS]

⚠️ Após sair, execute:
    exit → [COPIE O SESSION ID]
    claude
    Xavier, registra sessão [SESSION_ID_COPIADO]

🔄 E cole esses dados quando eu pedir tags/summary!
```

### Why Generate Now?

- ✅ **Fresh context** - Session still open, work fresh in memory
- ✅ **Zero friction** - Jimmy only needs to copy Session ID after exit
- ✅ **Data ready** - No need to recall work later
- ✅ **Never forget** - Emphatic reminder prevents lost sessions

### Implementation Notes

- This protocol runs **automatically** after ANY completed task
- Xavier generates tags/summary from current conversation context
- Data is displayed for Jimmy to copy/save
- Jimmy can edit the suggestions when actually registering

---

## 📝 REGISTER WORKFLOW

**Trigger:** `"Xavier, registra sessão [SESSION_ID]"`

### 10-Step Process

#### Step 1: Capture Session ID
Extract from user input:
- Format: `claude-YYYYMMDD-HHMM-xxxx`
- Validate format (see [Validation Rules](#validation-rules))

#### Step 2: Auto-Capture Git Context
Run commands (handle errors gracefully):

```bash
BRANCH=$(git branch --show-current 2>/dev/null || echo "no-git")
COMMIT=$(git log -1 --format=%h 2>/dev/null || echo "no-git")
PROJECT=$(pwd)
```

#### Step 3: Auto-Capture Timestamp
Brazilian timezone (America/Sao_Paulo):

```bash
export TZ='America/Sao_Paulo'
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
YEAR=$(date '+%Y')
MONTH=$(date '+%m')
```

#### Step 4: Auto-Capture Machine ID
Windows:
```bash
MACHINE=$COMPUTERNAME
```

Linux/Mac:
```bash
MACHINE=$(hostname)
```

Or read from `.metadata` settings.

#### Step 5: Request User Data Confirmation
Display captured context:

```
📋 Contexto capturado:

🕐 Data/Hora: [DATE] [TIME]
💻 Máquina: [MACHINE]
🌿 Branch: [BRANCH]
📍 Commit: [COMMIT]
📂 Projeto: [PROJECT]

🏷️  Tags: (cole as que gerei no Golden Close ou edite)
📝 Summary: (cole os bullets que gerei ou edite)
```

**Note:** If Jimmy doesn't have Golden Close data, Xavier generates new suggestions based on current context.

#### Step 6: User Provides Tags & Summary
Jimmy inputs:
- **Tags:** Space-separated, must start with `#`
  - Example: `#BI #MCP #Feature`
- **Summary:** 3-5 bullet points with `<br>` separator
  - Example: `- Implementou X<br>- Corrigiu Y<br>- Documentou Z`

#### Step 7: Final Confirmation
Display complete row for review:

```
📋 Confirme os dados:

| Session ID | Date | Time | Machine | Branch | Commit | Project | Tags | Summary |
|------------|------|------|---------|--------|--------|---------|------|---------|
| [ID] | [DATE] | [TIME] | [MACHINE] | [BRANCH] | [COMMIT] | [PROJECT] | [TAGS] | [SUMMARY] |

✅ Salvar? (confirme para continuar)
```

#### Step 8: Create/Update Monthly File
Path: `registry/YYYY/MM/SESSIONS.md`

**If file doesn't exist:**
1. Create directories: `mkdir -p registry/YYYY/MM`
2. Copy template: `templates/monthly-registry.template.md`
3. Replace placeholders:
   - `{{YEAR}}` → current year
   - `{{MONTH}}` → current month (zero-padded)
   - `{{MONTH_NAME}}` → month name (Janeiro, Fevereiro, etc.)
   - `{{TIMESTAMP}}` → current timestamp

**If file exists:**
1. Read current content
2. Parse header (get current Total Sessions count)
3. Append new row at **END** of table
4. Update header:
   - Increment `Total Sessions`
   - Update `Last Updated` timestamp

**Table Append Format:**
```markdown
| claude-20260212-1430-a4f9 | 2026-02-12 | 14:30 | DESKTOP-ABC | main | abc1234 | /c/Users/jimmy/project | #BI #MCP | - Implementou X<br>- Corrigiu Y<br>- Documentou Z |
```

#### Step 9: Git Commit & Push
If `auto_push: true` in `.metadata` settings:

```bash
git add claude-session-registry/registry/YYYY/MM/SESSIONS.md
git commit -m "feat(session-registry): add session [ID] - [TAGS]

Machine: [MACHINE]
Project: [PROJECT]
Branch: [BRANCH]
Commit: [COMMIT]

Summary:
- Bullet 1
- Bullet 2
- Bullet 3"

git push origin main
```

#### Step 10: Success Confirmation
Display summary:

```
✅ Sessão registrada com sucesso!

📋 Session ID: [ID]
📂 Arquivo: registry/YYYY/MM/SESSIONS.md
📊 Total neste mês: N
🔄 Git: commit + push concluídos
```

---

## 🔍 SEARCH WORKFLOW

**Triggers:**
- `"Xavier, busca sessões com tag #BI"`
- `"procura sessões em 2026-02"`
- `"quais sessões do projeto claude-intelligence-hub"`

### 4-Step Process

#### Step 1: Parse Query
Extract filters from natural language:

**Date filters:**
- `--month YYYY-MM` or `"em 2026-02"` → month filter
- `--date YYYY-MM-DD` or `"dia 2026-02-12"` → exact date
- `"janeiro"`, `"fevereiro"` → month name (Portuguese)

**Tag filters:**
- `#tagname` anywhere in query → tag filter
- Multiple tags: `#BI #MCP` → AND logic

**Project filters:**
- `--project /path` or `"projeto X"` → project keyword
- `"claude-intelligence-hub"` → project name match

**Machine filters:**
- `--machine ID` or `"máquina DESKTOP-ABC"` → machine filter

#### Step 2: Execute Grep
Search in registry files:

```bash
grep -ri "pattern" claude-session-registry/registry/**/*.md
```

**Multi-filter logic:**
- Start with broadest filter (date/month)
- Apply narrower filters (tag, project, machine)
- Use pipe chain: `grep filter1 | grep filter2 | grep filter3`

#### Step 3: Rank Results
- **Sort by date:** Newest first (reverse chronological)
- **Limit:** Top 10 results (configurable)
- **Parse table rows** to extract structured data

#### Step 4: Display Results
Format output:

```
🔍 Encontrei N sessões:

1. [SESSION_ID] | [DATE] [TIME]
   💻 [MACHINE] | 🌿 [BRANCH] | 📂 [PROJECT]
   🏷️  [TAGS]
   📝 [SUMMARY_LINE_1]
      [SUMMARY_LINE_2]
      [SUMMARY_LINE_3]

2. [SESSION_ID] | [DATE] [TIME]
   ...

📄 Arquivo: registry/YYYY/MM/SESSIONS.md (linha XX)
```

**If no results:**
```
❌ Nenhuma sessão encontrada com os filtros:
   - [FILTER_1]
   - [FILTER_2]

💡 Tente buscar com critérios mais amplos.
```

---

## 📊 STATS WORKFLOW

**Trigger:** `/session-registry stats [OPTIONS]`

**Options:**
- (default) → stats for current month
- `--month YYYY-MM` → specific month
- `--all` → all-time stats

### 3-Step Process

#### Step 1: Parse Request
Determine scope:
- Default: current month (`date '+%Y-%m'`)
- `--month YYYY-MM`: specific month
- `--all`: scan all `registry/**/*.md` files

#### Step 2: Aggregate Data
Scan target files and count:

**General metrics:**
- Total sessions

**Per-Machine breakdown:**
- Count sessions by Machine ID
- Calculate percentages

**Per-Project breakdown (Top 5):**
- Count sessions by Project path
- Extract project name from path
- Rank by frequency

**Per-Tag breakdown (Top 10):**
- Extract all tags from Summary column
- Count tag frequency
- Rank by usage

**Per-Branch breakdown:**
- Count sessions by Branch
- Calculate percentages
- Highlight main/master vs feature branches

#### Step 3: Display Stats
Format output:

```
📊 Session Registry Stats - [SCOPE]

Geral:
- Total de Sessões: N

Por Máquina:
- DESKTOP-ABC: N sessões (XX%)
- LAPTOP-XYZ: N sessões (XX%)

Por Projeto (Top 5):
- /c/Users/jimmy/claude-intelligence-hub: N
- /c/Users/jimmy/project-x: N
- /c/Users/jimmy/project-y: N

Por Tag (Top 10):
- #BI: N
- #MCP: N
- #Feature: N
- #Refactor: N
- #Bug: N

Por Branch:
- main: N (XX%)
- feature/xyz: N (XX%)
- bugfix/abc: N (XX%)
```

---

## ✅ VALIDATION RULES

### Pre-Save Validations

**Session ID format:**
- Regex: `^claude-\d{8}-\d{4}-[a-z0-9]{4}$`
- Example: `claude-20260212-1430-a4f9`
- Components:
  - `claude-` prefix
  - `YYYYMMDD` date (8 digits)
  - `-HHMM-` time separator (4 digits)
  - `xxxx` random suffix (4 alphanumeric lowercase)

**Date validation:**
- Format: `YYYY-MM-DD`
- Valid date range: 2024-01-01 to 2099-12-31
- Month: 01-12
- Day: 01-31 (month-appropriate)

**Time validation:**
- Format: `HH:MM`
- Hours: 00-23
- Minutes: 00-59

**Tags validation:**
- Each tag must start with `#`
- No spaces in tag names
- Format: `#TagName` (CamelCase or lowercase)
- Multiple tags: space-separated

**Summary validation:**
- Minimum: 3 bullet points
- Maximum: 5 bullet points
- Each bullet: starts with `- `
- Separator: `<br>` between bullets
- No empty bullets

**Branch validation:**
- No spaces allowed
- Valid characters: `a-zA-Z0-9_/-`
- Special value: `"no-git"` (if not in Git repo)

**Commit hash validation:**
- Exactly 7 hexadecimal characters
- Format: `[a-f0-9]{7}`
- Special value: `"no-git"` (if not in Git repo)

### Pre-Append Validations

**Monthly file:**
- Path exists: `registry/YYYY/MM/`
- File exists or create from template
- Table header intact (9 columns)
- Header separator row intact

**Table integrity:**
- All rows have 9 columns (pipe-separated)
- No malformed rows
- Always append at **END** of table (after last row, before EOF)

### Post-Save Validations

**Git operations:**
- Commit created successfully
- No merge conflicts
- Push completed (if `auto_push: true`)

**File verification:**
- File exists at correct path: `registry/YYYY/MM/SESSIONS.md`
- File size increased (new row added)
- Table row count increased by 1

---

## 🔄 GIT INTEGRATION

### Auto-Capture Commands

**Branch detection:**
```bash
git branch --show-current 2>/dev/null || echo "no-git"
```

**Commit hash:**
```bash
git log -1 --format=%h 2>/dev/null || echo "no-git"
```

**Project path:**
```bash
pwd
# Or basename $(pwd) for project name only
```

### Git Commit Message Format

```
feat(session-registry): add session [SESSION_ID] - [TAGS]

Machine: [MACHINE]
Project: [PROJECT]
Branch: [BRANCH]
Commit: [COMMIT]

Summary:
- [BULLET_1]
- [BULLET_2]
- [BULLET_3]
```

**Example:**
```
feat(session-registry): add session claude-20260212-1430-a4f9 - #BI #MCP

Machine: DESKTOP-ABC
Project: /c/Users/jimmy/claude-intelligence-hub
Branch: main
Commit: abc1234

Summary:
- Implementou dashboard BI com MCP integration
- Corrigiu bug de timeout em queries longas
- Documentou workflow de session registry
```

### Multi-Machine Sync

**Setup:**
1. Junction points on each machine (see `SETUP_GUIDE.md`)
2. Git auto-push enabled (`auto_push: true`)
3. Same repo cloned on all machines

**Workflow:**
1. Machine A: register session → auto-commit → auto-push
2. Machine B: `git pull` → session appears in registry
3. Search/stats work across all machines

---

## 💡 BEST PRACTICES

### For Xavier (Claude)

1. **Always trigger Golden Close Protocol** when tasks complete
2. **Generate high-quality tags** from conversation context
3. **Write clear, concise summaries** (3-5 bullets, action-oriented)
4. **Validate all data** before saving
5. **Handle Git errors gracefully** (not all projects are Git repos)
6. **Preserve table formatting** (consistent column widths)
7. **Brazilian timezone always** (America/Sao_Paulo)

### For Jimmy (User)

1. **Copy Session ID immediately** after `exit`
2. **Register sessions promptly** (while memory is fresh)
3. **Use consistent tag naming** (see common tags below)
4. **Write action-oriented summaries** (start with verbs)
5. **Review data before final confirmation**
6. **Keep junction points active** for multi-machine sync

### Common Tags Reference

**By Technology:**
- `#BI` - Business Intelligence
- `#MCP` - Model Context Protocol
- `#Git` - Git operations
- `#Python` - Python development
- `#Bash` - Shell scripting

**By Type:**
- `#Feature` - New functionality
- `#Bug` - Bug fixes
- `#Refactor` - Code refactoring
- `#Docs` - Documentation
- `#Test` - Testing
- `#Config` - Configuration

**By Domain:**
- `#Memory` - Memory/persistence systems
- `#Session` - Session management
- `#Skill` - Skill development
- `#Workflow` - Workflow automation

---

## 🎯 SKILL METADATA

**Name:** claude-session-registry
**Version:** 1.0.0
**Author:** Xavier (Claude)
**Created:** 2026-02-12
**Type:** Session Tracking
**Language:** pt-BR (Brazilian Portuguese)
**Timezone:** America/Sao_Paulo

**Dependencies:**
- Git (optional, graceful fallback)
- Bash/Shell environment
- Junction points (for multi-machine sync)

**Triggers:**
- Register: `"xavier, registra sessão"`, `"x, registra a sessão"`, `"salvar sessão"`
- Search: `"xavier, busca sessões"`, `"procura sessões"`
- Stats: `/session-registry stats`

---

**END OF SKILL.md**
