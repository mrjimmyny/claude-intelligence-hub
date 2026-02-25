# 🎮 Slash Commands Reference

**Quick access to all Claude Intelligence Hub skills via slash commands**

---

## 📋 Table of Contents

- [Command Syntax](#command-syntax)
- [All Commands (Alphabetical)](#all-commands-alphabetical)
- [Commands by Category](#commands-by-category)
- [Commands by Tier](#commands-by-tier)
- [Usage Examples](#usage-examples)

---

## Command Syntax

**Basic format:**
```
/command [arguments]
```

**With aliases:**
```
/primary-command [args]    # Primary command
/alias1 [args]            # Alternative command (same behavior)
/alias2 [args]            # Another alternative
```

**Examples:**
```bash
/repo-auditor --mode AUDIT_AND_FIX
/audit --mode AUDIT_AND_FIX              # Same as above (alias)
/memoria search "project X"
/memory search "project X"               # Same as above (alias)
```

---

## All Commands (Alphabetical)

| Command | Aliases | Skill | Description |
|---|---|---|---|
| `/aop` | `/orchestrate`, `/delegate` | agent-orchestration-protocol | Multi-agent coordination framework |
| `/catalog` | `/core` | core_catalog | System configurations & bootstrap data |
| `/context-guardian` | `/guardian`, `/switch` | context-guardian | Account switching (Xavier ↔ Magneto) |
| `/conversation` | `/conv`, `/history` | conversation-memoria | Save/Load session history |
| `/gdrive-sync` | `/gdrive` | gdrive-sync-memoria | Sync ChatLLM Teams content to session-memoria |
| `/governance` | `/codex` | codex-governance-framework | Institutional governance framework |
| `/memoria` | `/memory`, `/save` | session-memoria | Permanent conversation storage |
| `/pbi` | `/powerbi` | pbi-claude-skills | Power BI PBIP optimization |
| `/preferences` | `/prefs`, `/jimmy` | jimmy-core-preferences | Master AI behavior framework |
| `/registry` | `/register-session` | claude-session-registry | Session tracking & backup |
| `/repo-auditor` | `/audit`, `/validate` | repo-auditor | Repository integrity audit |
| `/token-economy` | `/tokens`, `/budget` | token-economy | Budget enforcement & token reduction |
| `/xavier-memory` | `/xmemory` | xavier-memory | Cross-project persistent memory |
| `/xavier-sync` | `/sync-memory` | xavier-memory-sync | Memory sync to Google Drive |
| `/xmem` | `/learn`, `/recall` | x-mem | Self-learning from failures/successes |

---

## Commands by Category

### 🧠 Memory & Knowledge Management
| Command | Description |
|---|---|
| `/memoria` | Capture, search, and recall conversations |
| `/xavier-memory` | Cross-project global memory |
| `/xavier-sync` | Backup memory to Google Drive |
| `/conversation` | Save/load full conversation histories |
| `/xmem` | Learn from failures and successes |
| `/gdrive-sync` | Import from ChatLLM Teams |

### ⚙️ System & Governance
| Command | Description |
|---|---|
| `/preferences` | Master AI behavior settings |
| `/token-economy` | Enforce token budgets |
| `/repo-auditor` | Deep repository audit |
| `/governance` | Codex governance framework |
| `/catalog` | System configuration data |

### 🔄 Workflow & Coordination
| Command | Description |
|---|---|
| `/aop` | Orchestrate multi-agent tasks |
| `/registry` | Track Claude sessions |
| `/context-guardian` | Switch between accounts |

### 📊 Power BI Optimization
| Command | Description |
|---|---|
| `/pbi` | Power BI PBIP project tools |

---

## Commands by Tier

### 🔵 Tier 1: Always-Load (Mandatory)
These skills auto-load at every session start:

| Command | Description |
|---|---|
| `/preferences` | Master AI behavior framework |
| `/token-economy` | Budget enforcement |

### 🟢 Tier 2: Context-Aware (Suggested)
These skills load based on triggers or project detection:

| Command | Description | Auto-Load Trigger |
|---|---|---|
| `/memoria` | Permanent memory | "registre isso", "busca na memoria" |
| `/registry` | Session tracking | "registra sessão", Golden Close |
| `/pbi` | Power BI tools | `.pbip` project detected |
| `/xavier-memory` | Global memory | Cross-project sync |
| `/aop` | Multi-agent | "orchestrate", "delegate" |

### 🟡 Tier 3: Explicit (On-Demand)
These skills only load when manually invoked:

| Command | Description |
|---|---|
| `/gdrive-sync` | ChatLLM sync |
| `/xmem` | Failure learning |
| `/xavier-sync` | Memory backup |
| `/context-guardian` | Account switching |
| `/repo-auditor` | Repo audit |
| `/conversation` | Session history |
| `/catalog` | System config |
| `/governance` | Governance docs |

---

## Usage Examples

### Repository Audit
```bash
# Run full audit with auto-fix
/repo-auditor --mode AUDIT_AND_FIX

# Audit only (no fixes)
/audit --mode AUDIT_ONLY

# Dry run (simulate)
/validate --mode DRY_RUN
```

### Memory Management
```bash
# Save conversation to memoria
/memoria save "Important decision about project X architecture"

# Search memoria
/memory search "project X"

# Backup to Google Drive
/xavier-sync backup

# Import from ChatLLM Teams
/gdrive sync
```

### Power BI Optimization
```bash
# Read semantic model
/pbi read-model

# List all objects
/powerbi list-objects

# Search DAX code
/pbi search-code "Sales"
```

### Multi-Agent Coordination
```bash
# Orchestrate complex task
/aop delegate "Build dashboard with tests"

# Alternative
/orchestrate "Analyze codebase and generate report"
```

### Session Management
```bash
# Register current session
/registry save

# Load conversation history
/conversation load 2026-02-25

# Switch accounts
/guardian switch magneto
```

### Token Management
```bash
# Check token budget
/token-economy status

# Show token reduction tips
/budget optimize
```

---

## 💡 Tips

1. **Use Tab Completion:** Most CLI tools support tab completion after typing `/`
2. **Aliases are shortcuts:** Use shorter aliases for frequently used commands
3. **Chain commands:** Some skills support piping results to other skills
4. **Check help:** Most commands support `--help` flag for detailed options

---

## 👨‍💻 Creating Your Own Slash Commands

Want to add a new skill with its own slash command? Here's the quick process:

### The 4-Step "Colinha" (Cheat Sheet)

```bash
# 1️⃣ Create skill with command: in SKILL.md frontmatter
cd /c/ai/claude-intelligence-hub
mkdir my-new-skill && cd my-new-skill
# Add SKILL.md (with command: field), .metadata, README.md

# 2️⃣ Sync to global skills directory
cd ../scripts
./sync-skills-global.ps1  # Windows
# OR
./sync-skills-global.sh   # Bash/WSL

# 3️⃣ Restart Claude Code
# Close and reopen Claude Code

# 4️⃣ Validate with repo-auditor
/repo-auditor --mode AUDIT_AND_FIX
```

**Done!** Your new command `/my-skill` is now available globally! ✅

### Required SKILL.md Frontmatter

```yaml
---
name: my-new-skill
description: What this skill does
command: /my-skill        # ← MANDATORY!
aliases: [/alias1, /alias2]
---
```

### Auto-Validation

The repo-auditor automatically validates:
- ✅ All skills have `command:` defined
- ✅ Commands are documented in HUB_MAP, README, COMMANDS (auto-synced)
- ✅ No duplicate commands
- ✅ Skills appear in EXECUTIVE_SUMMARY

**Full guide:** [CONTRIBUTING.md](CONTRIBUTING.md) | [QUICKSTART_NEW_SKILL.md](QUICKSTART_NEW_SKILL.md)

---

## 📚 Further Reading

- **[HUB_MAP.md](HUB_MAP.md)** - Visual skill router with detailed routing
- **[README.md](README.md)** - Main hub documentation
- **[EXECUTIVE_SUMMARY.md](EXECUTIVE_SUMMARY.md)** - Complete system overview

---

**Last Updated:** 2026-02-25
**Version:** 2.6.0
