# Claude Session Registry

**Version:** 1.1.0
**Author:** Xavier (Claude)
**Language:** pt-BR (Brazilian Portuguese)
**Timezone:** America/Sao_Paulo

Track Claude Code sessions with automatic Git context capture, multi-machine sync, intelligent session memory, and **automatic backup to private GitHub repository**.

---

## ✨ Features

- 🆔 **Session Resume ID** tracking (for `claude --resume`)
- 🌿 **Auto-capture Git context** (branch + commit hash)
- 💻 **Multi-machine tracking** (Machine ID support)
- 📂 **Project path** recording
- 🏷️ **Tags & Summary** (achievements/conquistas)
- 🚨 **Golden Close Protocol** (never forget to register sessions)
- 📊 **Hierarchical storage** (registry/YYYY/MM/SESSIONS.md)
- 🇧🇷 **Brazilian timezone** built-in (America/Sao_Paulo)
- 🔍 **Smart search** (by tag, project, date, machine)
- 📈 **Statistics** (monthly or all-time analytics)
- 💾 **Automatic Backup** (NEW v1.1.0) - Zero-cost session backup to private GitHub
  - Markdown transcripts for all sessions (human-readable)
  - Raw .jsonl backups for critical sessions (full restore)
  - Auto-indexed by date, tag, and machine

---

## 🚀 Quick Start

### Installation

1. Clone the repository:
   ```bash
   cd ~/Downloads
   git clone <repo-url> claude-intelligence-hub
   ```

2. Setup junction points (Windows):
   ```bash
   cd ~/Downloads
   ./setup_junctions.bat
   ```

3. Verify installation:
   ```bash
   ls -la ~/.claude/skills/user/claude-session-registry
   ```

### First Session Registration

1. **Complete your work** in a Claude session

2. **Golden Close Protocol** triggers:
   ```
   🚨🚨🚨 IMPORTANTE 🚨🚨🚨
   COPIE O SESSION ID APÓS USAR `exit`!

   📋 Dados capturados: [tags & summary pre-generated]
   ```

3. **Exit and copy Session ID:**
   ```bash
   exit
   # Copy the Session ID shown
   ```

4. **Register the session:**
   ```bash
   claude
   ```
   ```
   Xavier, registra sessão claude-20260212-1430-a4f9
   ```

5. **Paste the generated data** when prompted

---

## 📖 Usage Examples

### Register Session
```
Xavier, registra sessão claude-20260212-1430-a4f9
```

### Search Sessions
```
Xavier, busca sessões com tag #BI

procura sessões em 2026-02

quais sessões do projeto claude-intelligence-hub
```

### View Statistics
```
/session-registry stats

/session-registry stats --month 2026-02

/session-registry stats --all
```

---

## 🗂️ File Structure

```
claude-session-registry/
├── .metadata                          # Config JSON
├── SKILL.md                           # Workflows (~350 lines)
├── README.md                          # This file
├── CHANGELOG.md                       # Version history
├── SETUP_GUIDE.md                     # Installation guide
├── templates/
│   └── monthly-registry.template.md   # Monthly table template
└── registry/
    └── YYYY/MM/
        └── SESSIONS.md                # Monthly session tables
```

---

## 📊 Data Schema

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

## 🔄 Multi-Machine Sync

The skill uses **Git + Junction Points** for seamless multi-machine sync:

1. **Machine A:** Register session → auto-commit → auto-push
2. **Machine B:** `git pull` → session appears instantly
3. **Search/Stats:** Work across all machines

See `SETUP_GUIDE.md` for junction point configuration.

---

## 🏷️ Common Tags

**By Technology:**
- `#BI` `#MCP` `#Git` `#Python` `#Bash`

**By Type:**
- `#Feature` `#Bug` `#Refactor` `#Docs` `#Test` `#Config`

**By Domain:**
- `#Memory` `#Session` `#Skill` `#Workflow`

---

## 💾 Session Backup System (NEW v1.1.0)

**Zero-cost automatic backup** of sessions to private GitHub repository.

### Features
- ✅ **Markdown transcripts** for all registered sessions (human-readable)
- ✅ **Raw .jsonl backups** for sessions tagged `#critical` (full restore capability)
- ✅ **Auto-indexed** by date, tag, and machine
- ✅ **Git-based** with full version history
- ✅ **Free** - Uses GitHub private repo (500MB storage)

### Backup Repository
🔗 **[claude-session-backups](https://github.com/mrjimmyny/claude-session-backups)** (private)

### Quick Stats
<!-- AUTO-UPDATED BY BACKUP SCRIPT -->
- **Total Backups:** 0
- **Critical Backups:** 0
- **Last Backup:** -

### Usage

**Mark session as critical** (triggers .jsonl backup):
```
Tags: #critical #project #gdrive-sync
```

**View backups:**
```bash
# Read markdown transcript
cat ~/claude-session-backups/transcripts/2026/02/[session-id].md

# List critical backups
ls ~/claude-session-backups/critical/2026/02/

# View indexes
cat ~/claude-session-backups/indexes/by-date/2026-02.md
cat ~/claude-session-backups/indexes/by-tag/critical.md
```

**Restore critical session:**
```bash
# Copy .jsonl to project directory
cp critical/2026/02/[id].jsonl ~/.claude/projects/[project-slug]/[id].jsonl

# Resume session
cd /path/to/original/project
claude --resume [session-id]
```

### Documentation
- **[docs/BACKUP_SYSTEM.md](docs/BACKUP_SYSTEM.md)** - Complete backup system documentation
- `~/claude-session-backups/docs/RESTORE_GUIDE.md` - How to restore sessions

---

## 📚 Documentation

- **SKILL.md** - Complete workflow documentation
- **SETUP_GUIDE.md** - Installation & troubleshooting
- **CHANGELOG.md** - Version history
- **docs/BACKUP_SYSTEM.md** - Backup system documentation (NEW)

---

## 🤝 Contributing

This skill is part of the `claude-intelligence-hub` ecosystem. For issues or suggestions, contact the repository maintainer.

---

## 📄 License

Created by Xavier (Claude) for Jimmy's Claude Code environment.

---

**Happy Session Tracking! 🎯**
