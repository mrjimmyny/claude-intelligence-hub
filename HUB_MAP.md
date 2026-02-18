# 🗺️ Claude Intelligence Hub - Skill Router Map

**Version:** 2.5.0
**Last Updated:** 2026-02-18
**Purpose:** Central routing dictionary for all skills, triggers, and workflows
**Routing Status:** 🟢 Active (Module 4 Complete - Deployment & CI/CD)

---

## 📊 Quick Stats

| Metric | Count | Status |
|--------|-------|--------|
| **Production Skills** | 10 | ✅ Active |
| **Planned Skills** | 2 | 📋 Roadmap |
| **Documented Triggers** | 20+ | ✅ Complete |
| **Skill Tiers** | 3 | ✅ Defined |
| **Dependencies** | Mapped | ✅ Complete |

---

## 🎯 Active Skills (Production)

### 1. jimmy-core-preferences
**Type:** Master/Universal
**Location:** `~/.claude/skills/user/jimmy-core-preferences/`
**Auto-load:** ✅ Always (Priority: Highest)

#### Purpose
Defines universal AI behavior, communication style, and working principles for Claude across ALL sessions and projects.

#### Key Features
- Core Principles (Radical Honesty, Proactivity, Context Awareness)
- Workflow Patterns (5 comprehensive)
- Identity Management (Xavier + Jimmy)
- Self-Learning System
- Session Memoria Integration

#### Triggers
**NO manual triggers** - Auto-loads at EVERY session start

#### Dependencies
- None (highest priority, loads first)
- Other skills reference this for behavior rules

#### Loading Tier
**Tier 1: Always-Load**

---

### 2. session-memoria
**Type:** Knowledge Management
**Location:** `~/.claude/skills/user/session-memoria/`
**Auto-load:** ❌ Explicit invocation

#### Purpose
Permanent knowledge management system - transforms conversations into searchable, permanent entries with full lifecycle tracking.

#### Key Features
- Triple-index system (by-date, by-category, by-tag)
- Entry lifecycle (aberto → em_discussao → resolvido → arquivado)
- Git-native (auto-commit + auto-push)
- Cross-device sync (mobile ↔ desktop)
- Status tracking (priority, resolution, last_discussed)

#### Triggers (Portuguese)
**Save:**
- "Xavier, registre isso"
- "X, salve essa conversa"
- "registra isso na session-memoria"

**Search:**
- "busca na session-memoria: [keyword]"
- "procura por [topic]"

**Recap:**
- "resume os últimos registros"
- "quais assuntos registramos?"

**Update:**
- "marca [entry-id] como resolvido"
- "fecha o tema [entry-id]"
- "atualiza status de [entry-id]"

**Stats:**
- "/memoria stats"
- "estatísticas da session-memoria"

#### Dependencies
- Requires `claude-intelligence-hub` repository
- Integrates with jimmy-core-preferences Pattern 5
- Works with gdrive-sync-memoria (optional)

#### Loading Tier
**Tier 2: Context-Aware** - Loads when triggers detected or when referenced

---

### 3. gdrive-sync-memoria
**Type:** Integration/Automation
**Location:** `~/.claude/skills/user/gdrive-sync-memoria/`
**Auto-load:** ❌ Explicit invocation

#### Purpose
Automates import of summaries from ChatLLM Teams (via Google Drive) into session-memoria permanent knowledge base.

#### Key Features
- rclone-based Google Drive integration
- 8-step automated workflow
- Auto-categorization and tagging
- Language preservation (no translation)
- Error handling with retry logic
- Proactive sync reminders (> 3 days)

#### Triggers (Portuguese)
**Manual:**
- "Xavier, sincroniza o Google Drive"
- "X, processa arquivos do ChatLLM"
- "importa os resumos do Google Drive"
- "/gdrive-sync"

**Proactive:**
- Automatic reminder if > 3 days since last sync (once per session)

#### Dependencies
- **Required:** rclone installed and configured (remote: `gdrive-jimmy:`)
- **Required:** Google Drive folders (`_tobe_registered/`, `_registered_claude_session_memoria/`)
- **Integration:** session-memoria (creates entries)
- **Integration:** Git (auto-commit + auto-push)

#### Loading Tier
**Tier 3: Explicit** - Only loads when manually invoked

---

### 4. claude-session-registry
**Type:** Session Tracking
**Location:** `~/.claude/skills/user/claude-session-registry/`
**Auto-load:** ❌ Explicit invocation

#### Purpose
Tracks and documents Claude Code sessions with metadata, summaries, and outcomes.

#### Key Features
- Session metadata tracking
- Summary generation
- Outcome documentation
- Git integration

#### Triggers
- "registra sessão"
- "documenta essa sessão"
- "/session-registry"

#### Dependencies
- Git repository for storage
- Optional integration with session-memoria

#### Loading Tier
**Tier 2: Context-Aware** - Loads when session documentation requested

---

### 5. pbi-claude-skills
**Type:** Domain-Specific (Power BI)
**Location:** Project-specific `.claude/skills/`
**Auto-load:** ❌ Context-aware suggestion

#### Purpose
Complete skill system for Power BI PBIP projects - optimizes DAX work, structure queries, and model management.

#### Key Features
- 5 specialized skills (query, discover, add-measure, index-update, context-check)
- Token economy (50-97% savings)
- Context management with snapshots
- Parametrized (works on any Power BI project)
- GitHub Hub integration

#### Triggers
**Context-based:** Claude suggests when working in `.pbip` projects

**Manual:**
- "/pbi-query" - Query structure
- "/pbi-discover" - Discover files
- "/pbi-add-measure" - Add DAX measure
- "/pbi-index-update" - Regenerate index
- "/pbi-context-check" - Check context usage

#### Dependencies
- Power BI project in PBIP format
- POWER_BI_INDEX.md in project root
- pbi_config.json (auto-created if absent)

#### Loading Tier
**Tier 2: Context-Aware** - Suggests when `.pbip` project detected

---

### 6. x-mem
**Type:** Knowledge Management (Self-Learning Protocol)
**Location:** `~/.claude/skills/user/x-mem/`
**Auto-load:** ❌ No (manual trigger or proactive recall)

#### Purpose
Machine-oriented memory buffer that captures tool failures and success patterns to prevent repeated errors across sessions. NOT human-readable logs - optimized for token efficiency.

#### Key Features
- NDJSON storage (failures.jsonl, successes.jsonl)
- Fast index-based search (~500 token overhead)
- Automatic failure detection via jimmy-core-preferences Pattern 6A
- Token budget enforcement (15K hard limit per query)
- Git-versioned (auto-push enabled)

#### Triggers (Commands)
- `/xmem:load` - Load X-MEM context
- `/xmem:record` - Record failure/success
- `/xmem:search <query>` - Search by tool/tag
- `/xmem:stats` - Usage statistics
- `/xmem:compact` - Prune stale entries

#### Dependencies
- **Required:** jimmy-core-preferences (Pattern 6A integration)
- **Optional:** session-memoria (cross-reference entries)

#### Loading Tier
**Tier 2: Context-Aware (Proactive)**
- Auto-suggests on tool failures
- Explicit load via `/xmem:*` commands
- Index always loaded for Pattern 6A (<500 tokens)

#### Related Files
- `x-mem/SKILL.md` (execution instructions, ~300 lines)
- `x-mem/data/index.json` (fast search index, ~500 tokens)
- `x-mem/data/failures.jsonl` (append-only NDJSON)
- `x-mem/data/successes.jsonl` (append-only NDJSON)

---

### 7. xavier-memory
**Type:** Infrastructure (Global Memory System)
**Location:** `claude-intelligence-hub/xavier-memory/`
**Auto-load:** ✅ Always (via hard links to all projects)

#### Purpose
Master memory repository that provides cross-project persistent memory with disaster recovery capability. Foundation for X-MEM protocol and all learned patterns.

#### Key Features
- Single source of truth (MEMORY.md master file)
- Hard link sync to all project memory folders (instant, zero-latency)
- 3-layer protection: Git + Hard Links + Google Drive
- No duplicates (always ONE latest file per location)
- Survives machine crashes and formats

#### Triggers
**NO manual triggers** - Memory auto-loads in ALL projects via hard links

#### Dependencies
- None (infrastructure layer)
- Used by: jimmy-core-preferences, x-mem protocol

#### Loading Tier
**Tier 1: Always-Load** (via hard link mechanism)

#### Related Files
- `xavier-memory/MEMORY.md` (master memory file, ~200 lines)
- `xavier-memory/README.md` (system documentation)
- `xavier-memory/GOVERNANCE.md` (X-MEM protocol rules)
- `xavier-memory/setup_memory_junctions.bat` (hard link setup)
- `xavier-memory/sync-to-gdrive.sh` (Google Drive backup)

---

### 8. xavier-memory-sync
**Type:** Automation (Memory Sync Skill)
**Location:** `claude-intelligence-hub/xavier-memory-sync/`
**Auto-load:** ❌ Explicit invocation

#### Purpose
Automation skill for managing Xavier Global Memory System - handles backup, restore, status checks, and sync operations.

#### Key Features
- One-command backup to Google Drive
- Hard link verification across all projects
- Restore from backups (local or cloud)
- System health monitoring
- Zero-duplicate guarantee (always overwrites, never creates duplicates)

#### Triggers (Commands)
- `"Xavier, sync memory"` - Full sync (all projects + Google Drive)
- `"Xavier, backup memory"` - Google Drive backup only
- `"Xavier, restore memory"` - Restore from backups (interactive)
- `"Xavier, memory status"` - System health report
- `"X, sync mem"` - Short alias for sync

#### Dependencies
- **Required:** xavier-memory (master infrastructure)
- **Required:** rclone (Google Drive sync)
- **Required:** gdrive-jimmy remote (configured)

#### Loading Tier
**Tier 2: On-Demand** (explicit trigger phrases)

#### Related Files
- `xavier-memory-sync/SKILL.md` (execution instructions, ~300 lines)
- `xavier-memory/backups/` (local backup snapshots)
- Google Drive: `Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/`

---

### 9. context-guardian
**Type:** Infrastructure (Context Preservation System)
**Location:** `claude-intelligence-hub/context-guardian/`
**Auto-load:** ❌ Explicit invocation

#### Purpose
Complete context preservation system enabling seamless Xavier ↔ Magneto account switching by backing up and restoring global config, project contexts, and symlink relationships.

#### Key Features
- **3-Layer Backup**: Global config + Project contexts + Metadata
- **3-Strategy Symlinks**: Developer Mode / Administrator / Copy fallback
- **Rollback Protection**: Auto-rollback on restore failure
- **Post-Restore Validation**: 5 comprehensive checks
- **`.contextignore` Support**: Exclude node_modules, .git, etc.
- **Dry-Run Mode**: Preview changes without modifying files
- **Structured Logging**: All operations logged to `~/.claude/context-guardian/logs/`

#### What Gets Backed Up
**Global Config:**
- `~/.claude/settings.json`
- `~/.claude/plugins/` (all config files + cache if <50 MB)
- `~/.claude/skills/user/*` (metadata for symlinks, full copy for directories)

**Project Context:**
- `CLAUDE.md` (if exists)
- `MEMORY.md` (if exists and NOT hard-linked to xavier-memory)
- `.claude/skills/` (project-local skills)
- `.claude/commands/` (custom commands)

#### Triggers (Commands)
**Backup:**
- `"backup global config"` / `"backup claude settings"`
- `"backup this project"` / `"backup current project"`

**Restore:**
- `"restore global config"` / `"restore claude settings"`
- `"restore project [name]"`

**Status:**
- `"verify context backup"` / `"check backup health"`

#### Dependencies
- **Required:** rclone (with `gdrive-jimmy:` remote configured)
- **Required:** Windows 10/11 + PowerShell 5.1+
- **Recommended:** Developer Mode enabled (for symlinks)
- **Optional:** Git (for automatic commits)

#### Loading Tier
**Tier 3: Explicit** - Only loads when manual triggers detected

#### Related Files
- `context-guardian/SKILL.md` (workflows and troubleshooting, ~600 lines)
- `context-guardian/README.md` (architecture overview)
- `context-guardian/GOVERNANCE.md` (backup policies and safety rules)
- `context-guardian/scripts/backup-global.sh` (global config backup)
- `context-guardian/scripts/backup-project.sh` (project context backup)
- `context-guardian/scripts/restore-global.sh` (global config restore)
- `context-guardian/scripts/restore-project.sh` (project context restore)
- `context-guardian/scripts/bootstrap-magneto.ps1` (Magneto self-contained restore)
- `context-guardian/scripts/verify-backup.sh` (health checks)
- Google Drive: `Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/global/`
- Google Drive: `Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory/projects/`

---

### 10. repo-auditor
**Type:** Quality/Governance
**Location:** `claude-intelligence-hub/repo-auditor/`
**Auto-load:** ❌ Explicit invocation

#### Purpose
End-to-end repository audit skill with mandatory proof-of-read fingerprinting per file. Ensures all documentation, skills, and metadata are up-to-date — no claims without evidence.

#### Key Features
- **Mandatory fingerprinting**: total_lines + first_line + last_line per file audited
- **Accumulative AUDIT_TRAIL.md**: never overwritten, grows append-only
- **Adversarial spot-checks**: per phase and global (minimum 5 total)
- **Anti-bluffing protocol**: fingerprints are machine-verifiable at any time
- **validate-trail.sh**: scope vs. trail comparison, CI-ready (exit 0/1)
- **Context-guardian integration**: AUDIT_TRAIL.md included in critical backups

#### Triggers
- `"audit"` / `"repo audit"` / `"run audit"`
- `"repo-auditor"` / `@repo-auditor`
- Any mention of "documentação desatualizada" or "release pendente"

#### Dependencies
- **Optional:** context-guardian (for backup integration)
- **Optional:** Git (for delta detection since last audit)

#### Loading Tier
**Tier 3: Explicit** - Only loads when audit triggers detected

#### Related Files
- `repo-auditor/SKILL.md` (full protocol, ~260 lines)
- `repo-auditor/AUDIT_TRAIL.md` (accumulative audit history)
- `repo-auditor/scripts/validate-trail.sh` (CI validation script)

---

## 📋 Planned Skills (Roadmap)

### python-claude-skills (v1.8.0)
**Status:** Placeholder created
**Purpose:** Python development workflow optimization
**Location:** `python-claude-skills/` (future)
**Planned Features:**
- Virtual environment management
- Dependency tracking
- Testing integration
- Code quality checks

### git-claude-skills (v1.8.0)
**Status:** Placeholder created
**Purpose:** Git workflow optimization
**Location:** `git-claude-skills/` (future)
**Planned Features:**
- Commit message generation
- Branch management
- PR automation
- Git history analysis

---

## 🧭 Skill Routing Logic

### Pattern 1: Trigger-Based Routing
**How it works:** User says specific phrase → Skill loads → Executes workflow

**Examples:**
- "Xavier, registre isso" → **session-memoria** (save workflow)
- "sincroniza Google Drive" → **gdrive-sync-memoria** (sync workflow)
- "registra sessão" → **claude-session-registry** (session tracking)

**Priority:** Highest (explicit user intent)

---

### Pattern 2: Context-Based Routing
**How it works:** Claude detects project/file type → Suggests relevant skill

**Examples:**
- Working in `.pbip` project → Suggests **pbi-claude-skills**
- Working in Python project → Will suggest **python-claude-skills** (v1.8)
- Frequent git operations → Will suggest **git-claude-skills** (v1.8)

**Priority:** Medium (helpful suggestion, not forced)

---

### Pattern 3: Always-Load Routing
**How it works:** Skill loads automatically at EVERY session start

**Examples:**
- **jimmy-core-preferences** → Loads first, defines all behavior

**Priority:** Mandatory (cannot be disabled)

---

### Pattern 4: Proactive Routing
**How it works:** Skill monitors conditions → Reminds user when applicable

**Examples:**
- **gdrive-sync-memoria** → Reminds if > 3 days since last sync
- **pbi-context-check** → Alerts when context usage high
- **session-memoria** → Claude suggests saving important moments

**Priority:** Low (gentle reminder, user can dismiss)

---

## 📊 Skill Loading Tiers

### Tier 1: Always-Load (Mandatory)
**Characteristics:**
- Loads at every session start
- Highest priority
- Defines universal behavior
- Cannot be disabled

**Skills:**
- jimmy-core-preferences ✅

**Use Case:** Universal rules that apply everywhere

---

### Tier 2: Context-Aware (Suggested)
**Characteristics:**
- Loads when context suggests relevance
- Claude suggests to user
- User can accept or decline
- Adapts to project type

**Skills:**
- session-memoria (when knowledge work detected)
- claude-session-registry (when session documentation needed)
- pbi-claude-skills (when `.pbip` project detected)

**Use Case:** Domain-specific skills for particular work types

---

### Tier 3: Explicit (On-Demand)
**Characteristics:**
- Only loads when explicitly invoked
- User must trigger manually
- No automatic loading
- Specialized workflows

**Skills:**
- gdrive-sync-memoria (manual sync only)

**Use Case:** Infrequent operations, external integrations

---

## 🔗 Skill Dependencies

### Dependency Graph
```
jimmy-core-preferences (no dependencies)
    ↓
    ├→ session-memoria (references Pattern 5)
    ├→ claude-session-registry (follows core principles)
    └→ pbi-claude-skills (follows core principles)

session-memoria
    ↓
    └→ gdrive-sync-memoria (creates entries in session-memoria)

Git Repository
    ↓
    ├→ session-memoria (Git storage)
    ├→ gdrive-sync-memoria (Git commit/push)
    └→ claude-session-registry (Git storage)
```

### Critical Dependencies
1. **Git:** Required for session-memoria, gdrive-sync-memoria, claude-session-registry
2. **rclone:** Required only for gdrive-sync-memoria
3. **Google Drive:** Required only for gdrive-sync-memoria
4. **PBIP project:** Required only for pbi-claude-skills

---

## 🔄 Skill Lifecycle States

### Production (5 skills)
**Definition:** Fully tested, documented, ready for use
**Characteristics:**
- Complete documentation (README, SKILL.md, EXECUTIVE_SUMMARY)
- Tested in real-world usage
- Git-versioned
- Active maintenance

**List:**
1. jimmy-core-preferences (v1.5.0)
2. session-memoria (v1.2.0)
3. gdrive-sync-memoria (v1.0.0)
4. claude-session-registry (v1.1.0)
5. pbi-claude-skills (v1.3.0)

---

### Roadmap (2 skills)
**Definition:** Planned for future development
**Characteristics:**
- Placeholder directory created
- README stub exists
- No implementation yet
- Target version: v1.8.0

**List:**
1. python-claude-skills
2. git-claude-skills

---

### Deprecated (0 skills)
**Definition:** No longer maintained, removed from hub

**List:** None currently

---

## ➕ Adding New Skills Protocol

### Step 1: Plan
- Define skill purpose and scope
- Identify triggers and workflows
- Map dependencies
- Choose loading tier (1, 2, or 3)

### Step 2: Create Structure
```bash
mkdir [skill-name]
cd [skill-name]

# Required files:
touch SKILL.md                 # Claude instructions
touch README.md                # User guide
touch .metadata                # Skill configuration
touch CHANGELOG.md             # Version history
```

### Step 3: Document
- Write SKILL.md (Claude-readable instructions)
- Write README.md (User-readable guide)
- Create EXECUTIVE_SUMMARY.md (if complex)
- Add hierarchy note (link to /EXECUTIVE_SUMMARY.md)

### Step 4: Configure
**`.metadata` format:**
```json
{
  "name": "skill-name",
  "version": "1.0.0",
  "auto_load": false,
  "priority": "medium",
  "description": "Brief description"
}
```

### Step 5: Integrate
- Update HUB_MAP.md (add skill to Active Skills section)
- Update README.md (add to skill count table)
- Update CHANGELOG.md (add version entry)
- Commit to Git

### Step 6: Test
- Test triggers work correctly
- Validate dependencies resolve
- Confirm documentation accuracy
- Real-world validation

---

## ⚠️ Critical Rules

### Rule 1: MEMORY.md First
**Always check MEMORY.md BEFORE inventing solutions**
- MEMORY.md contains hub-specific patterns
- Existing skills may already solve the problem
- Avoid duplicate implementations

### Rule 2: Skill Independence
**Skills should NOT hard-code paths or assumptions**
- Use configuration files (e.g., `pbi_config.json`)
- Auto-detect environment when possible
- Fail gracefully with clear error messages

### Rule 3: Git Sync Protocol
**All persistent data MUST use Git**
- Mandatory git pull before reads
- Automatic git commit after writes
- Always work on `main` branch (for session-memoria)
- Immediate push to remote

### Rule 4: Hierarchy Documentation
**All skill-level summaries MUST link to hub summary**
- Add hierarchy note at top of EXECUTIVE_SUMMARY.md
- Link to `/EXECUTIVE_SUMMARY.md` (root)
- Prevents confusion about documentation structure

### Rule 5: Portuguese First (for Jimmy)
**Jimmy's native language is Portuguese**
- Triggers should be Portuguese when possible
- Confirmations in Portuguese
- Error messages in Portuguese
- Documentation can be English (technical reference)

### Rule 6: Proactive > Reactive
**Claude should offer to help BEFORE being asked**
- jimmy-core-preferences defines proactive behavior
- session-memoria: "Quer que eu registre isso?"
- gdrive-sync: Reminds if > 3 days
- pbi-context-check: Alerts before context overflow

### Rule 7: Zero Breaking Changes Without Migration
**Updates must preserve backward compatibility**
- Provide migration guides if breaking
- Support old format temporarily
- Clear deprecation warnings
- Document upgrade path

---

## 🔧 Maintenance Protocol

### Weekly
- [ ] Check for failed Git syncs (session-memoria, gdrive-sync)
- [ ] Review proactive reminder effectiveness
- [ ] Monitor skill usage patterns

### Monthly
- [ ] Review MEMORY.md for outdated patterns
- [ ] Check HUB_MAP.md accuracy (skill count, triggers)
- [ ] Update session-memoria entry count in README.md
- [ ] Validate all triggers still work

### Quarterly
- [ ] Audit skill dependencies (still needed?)
- [ ] Review roadmap skills (still planned?)
- [ ] Clean up deprecated skills
- [ ] Update EXECUTIVE_SUMMARY.md with new learnings

### On New Skill Addition
- [ ] Update HUB_MAP.md (Active Skills section)
- [ ] Update README.md (skill count table)
- [ ] Update CHANGELOG.md (version entry)
- [ ] Update EXECUTIVE_SUMMARY.md (if major)
- [ ] Test all existing skills still work

### On Skill Deprecation
- [ ] Move to archive/ directory (don't delete)
- [ ] Update HUB_MAP.md (move to Deprecated section)
- [ ] Update README.md (decrement skill count)
- [ ] Document deprecation reason in CHANGELOG.md
- [ ] Provide migration guide if replacement exists

---

## 📖 Skill Routing Quick Reference

| User Says | Skill Activated | Workflow |
|-----------|----------------|----------|
| "Xavier, registre isso" | session-memoria | Save conversation |
| "resume os últimos registros" | session-memoria | Recap entries |
| "marca [id] como resolvido" | session-memoria | Update status |
| "sincroniza Google Drive" | gdrive-sync-memoria | Import from GDrive |
| "registra sessão" | claude-session-registry | Document session |
| Working in `.pbip` | pbi-claude-skills | Suggests Power BI skills |
| "/pbi-add-measure" | pbi-claude-skills | Add DAX measure |
| (Session starts) | jimmy-core-preferences | Auto-loads (always) |
| (>3 days since sync) | gdrive-sync-memoria | Proactive reminder |
| "documenta essa conversa" | session-memoria | Save entry |
| "busca por [topic]" | session-memoria | Search entries |

---

## 🎓 Common Patterns

### Pattern: Knowledge Capture
**When:** Important conversation happens
**Trigger:** "Xavier, registre isso"
**Skill:** session-memoria
**Workflow:** Analyze → Confirm metadata → Create entry → Update indices → Git commit/push
**Result:** Permanent, searchable knowledge

---

### Pattern: Cross-Device Sync
**When:** Work on mobile, continue on desktop
**Trigger:** (Automatic via Git)
**Skill:** session-memoria + Git
**Workflow:** Mobile creates entry → Git push → Desktop git pull → Entry visible
**Result:** Seamless cross-device continuity

---

### Pattern: External Knowledge Import
**When:** ChatLLM Teams generates summary
**Trigger:** "sincroniza Google Drive"
**Skill:** gdrive-sync-memoria → session-memoria
**Workflow:** List files → Download → Parse → Create entry → Git push → Move to processed
**Result:** External knowledge integrated into hub

---

### Pattern: Session Documentation
**When:** End of productive session
**Trigger:** "registra sessão"
**Skill:** claude-session-registry
**Workflow:** Collect metadata → Summarize → Document → Git commit
**Result:** Session history tracked

---

### Pattern: Domain-Specific Work
**When:** Working in Power BI project
**Trigger:** (Context-based suggestion)
**Skill:** pbi-claude-skills
**Workflow:** Detect `.pbip` → Suggest skills → User accepts → Load skills
**Result:** Optimized Power BI workflow

---

## 🔍 Troubleshooting Skill Routing

### Problem: Trigger not working
**Diagnosis:**
1. Check HUB_MAP.md for correct trigger syntax
2. Verify skill is in Production (not Roadmap)
3. Check .metadata auto_load setting
4. Confirm dependencies installed (e.g., rclone for gdrive-sync)

**Solution:**
- Use exact trigger phrase (case-sensitive for some)
- Check MEMORY.md for trigger reminders
- Verify skill location (~/.claude/skills/user/)

---

### Problem: Skill not loading
**Diagnosis:**
1. Check Tier (Tier 3 requires explicit invocation)
2. Verify .metadata exists and valid JSON
3. Check file permissions
4. Confirm Claude Code can read directory

**Solution:**
- For Tier 3: Use explicit trigger
- Validate .metadata format
- Check ~/.claude/skills/user/ permissions

---

### Problem: Wrong skill loads
**Diagnosis:**
1. Check trigger overlap (multiple skills same trigger)
2. Verify loading priority in .metadata
3. Review HUB_MAP.md routing logic

**Solution:**
- Use more specific trigger phrase
- Check priority settings (higher loads first)
- Report conflict to update HUB_MAP.md

---

### Problem: Proactive reminder too frequent
**Diagnosis:**
1. Check reminder logic in skill
2. Verify "once per session" rule
3. Confirm last_reminder metadata

**Solution:**
- Disable reminders: "desabilita lembretes [skill-name]"
- Adjust threshold (e.g., gdrive-sync: 3 days → 7 days)

---

## 📚 Related Documentation

### Hub Documentation
- [/README.md](README.md) - Hub overview, getting started
- [/EXECUTIVE_SUMMARY.md](EXECUTIVE_SUMMARY.md) - Comprehensive hub summary
- [/CHANGELOG.md](CHANGELOG.md) - Version history
- [/DEVELOPMENT_IMPACT_ANALYSIS.md](DEVELOPMENT_IMPACT_ANALYSIS.md) - AI-assisted development ROI case study (17 days, 92–94% time savings, 95–98% cost savings)

### Skill Documentation
- [jimmy-core-preferences/](jimmy-core-preferences/) - Core principles and patterns
- [session-memoria/](session-memoria/) - Knowledge management system
- [gdrive-sync-memoria/](gdrive-sync-memoria/) - Google Drive integration
- [claude-session-registry/](claude-session-registry/) - Session tracking
- [pbi-claude-skills/](pbi-claude-skills/) - Power BI optimization

### Technical References
- Jimmy's MEMORY.md - Auto-loaded behavior rules (200-line limit)
- .metadata files - Skill configuration reference
- pbi_config.json - Power BI project configuration

---

## 🚀 Next Steps

### For New Users
1. Read [/README.md](README.md) - Understand hub structure
2. Review HUB_MAP.md (this file) - Learn skill routing
3. Try a trigger - "Xavier, registre isso" (session-memoria)
4. Check MEMORY.md - Review learned patterns
5. Explore skill docs - Deep dive into specific skills

### For Existing Users
1. Review "Active Skills" section - Discover new triggers
2. Check "Planned Skills" - See roadmap
3. Use "Skill Routing Quick Reference" - Bookmark for quick lookup
4. Explore "Common Patterns" - Optimize workflows
5. Report issues - Help improve routing logic

### For Contributors
1. Read "Adding New Skills Protocol"
2. Follow critical rules (Rule 1-7)
3. Update HUB_MAP.md when adding skills
4. Test routing logic thoroughly
5. Document new patterns

---

## 📜 Version History

### v1.9.0 (2026-02-15) - Module 4: Deployment & CI/CD
**Major Release - Enterprise Deployment System**

**New Features:**
- ✅ Idempotent setup scripts (Windows PowerShell + Unix Bash)
- ✅ 15-minute fresh machine deployment (down from 2-4 hours)
- ✅ Enhanced CI/CD pipeline (5-job workflow)
  - Version sync validation
  - Mandatory skills validation
  - Breaking change detection
- ✅ Comprehensive handover documentation (HANDOVER_GUIDE.md)
- ✅ Project final report (PROJECT_FINAL_REPORT.md)
- ✅ Golden close checklist (GOLDEN_CLOSE_CHECKLIST.md)

**Scripts Added:**
- `scripts/setup_local_env.ps1` - Windows automated setup
- `scripts/setup_local_env.sh` - macOS/Linux automated setup
- `.github/workflows/ci-integrity.yml` - Enhanced CI/CD (5 jobs)

**Documentation:**
- `docs/HANDOVER_GUIDE.md` - 15-minute deployment guide
- `docs/PROJECT_FINAL_REPORT.md` - Comprehensive project report
- `docs/GOLDEN_CLOSE_CHECKLIST.md` - Sign-off validation

### v1.8.0 (2026-02-14) - Module 3: Advanced Governance
**Major Release - Zero-Breach Policy Enforcement**

**New Features:**
- ✅ integrity-check.sh (6 governance rules)
- ✅ sync-versions.sh (3-source version synchronization)
- ✅ update-skill.sh (automated skill versioning)
- ✅ GitHub Actions CI/CD (integrity.yml)
- ✅ Token Economy Framework (30-50% savings)

### v1.7.0 (2025-12-01) - Module 2: Memory & Knowledge
**Major Release - Permanent Memory System**

**Skills Added:**
- session-memoria v1.2.0 (3-tier archiving)
- x-mem v1.0.0 (self-learning protocol)
- gdrive-sync-memoria v1.0.0 (ChatLLM integration)
- claude-session-registry v1.1.0 (session tracking)

### v1.0.0 (2025-02-09) - Module 1: Foundation
**Initial Release**

**Skills Added:**
- jimmy-core-preferences v1.0.0
- pbi-claude-skills v1.0.0

---

**Version:** 2.5.0
**Status:** ✅ Production - Enterprise-Ready
**Last Updated:** 2026-02-18
**Maintained by:** Xavier, Magneto & Jimmy

*This is the single source of truth for skill routing in the Claude Intelligence Hub*
