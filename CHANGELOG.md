# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.8.0] - 2026-02-14

### 🎯 Module 3: Advanced Technical Governance

**Focus:** Self-learning, token economy, incremental indexing

### Added

#### Phase 1: X-MEM Protocol (Self-Learning)
- **x-mem/** - New skill for capturing failures/successes
  - SKILL.md - Execution instructions (~300 lines)
  - README.md - User documentation (~200 lines)
  - .metadata - Skill configuration (v1.0.0)
  - CHANGELOG.md - Version history
  - data/index.json - Fast search index (~500 tokens)
  - data/failures.jsonl - NDJSON failure records (append-only)
  - data/successes.jsonl - NDJSON success patterns (append-only)
  - scripts/xmem-search.sh - Search utility
  - scripts/xmem-compact.sh - Compaction utility
  - scripts/xmem-stats.sh - Statistics generator
- **jimmy-core-preferences:** Pattern 6A - X-MEM Proactive Recall
  - Automatic failure detection
  - Proactive suggestion when errors recur
  - Token budget enforcement (15K hard limit per query)
- **HUB_MAP.md:** Added x-mem section (skill #6)
  - Updated to v1.8.0
  - 6 production skills (was 5)
  - 20+ documented triggers (was 15+)

#### Phase 2: Token Economy Enforcement
- **token-economy/** - New governance layer
  - README.md - Overview and best practices (~350 lines)
  - budget-rules.md - Detailed token rules (~450 lines)
- **jimmy-core-preferences:** Section 7 - Token Economy Enforcement
  - Pre-flight token checks before skill loads
  - File loading discipline (index-only HUB_MAP loads)
  - Response size targets (<1.5K standard, <3K complex)
  - Automatic warnings (50%, 75%, 90% thresholds)
- **MEMORY.md:** Token budget patterns
  - DO/DON'T patterns
  - Partial file read examples
  - Context budget warnings

#### Phase 3: Incremental Indexing Automation
- **scripts/sync-versions.sh** - Version synchronization utility (~100 lines)
  - Syncs .metadata, SKILL.md, HUB_MAP.md
  - Updates last_updated date automatically
  - Color-coded output
- **scripts/update-skill.sh** - Incremental update procedure (~150 lines)
  - Semver increment (patch/minor/major)
  - CHANGELOG.md auto-update
  - Git commit suggestions
- **scripts/integrity-check.sh:** CHECK 6 - Version Synchronization
  - Detects version drift across files
  - Reports mismatches (.metadata vs SKILL.md vs HUB_MAP)
  - Suggests fix command

### Changed
- **HUB_MAP.md:**
  - Version: 1.7.0 → 1.8.0
  - Production skills: 5 → 6 (added x-mem)
  - Routing status: Module 2 → Module 3 Complete
- **claude-session-registry/SKILL.md:**
  - Version header synced: 1.0.0 → 1.1.0
- **session-memoria/SKILL.md:**
  - Version header synced: 1.1.0 → 1.2.0

### Features
- **X-MEM Protocol:**
  - Prevents repeated errors across sessions
  - NDJSON storage (Git-safe, append-only)
  - Index-based search (~500 token overhead)
  - 5 trigger commands: load, record, search, stats, compact
  - Proactive recall on tool failures
- **Token Economy:**
  - 30-50% token reduction target
  - <3K tokens per skill load (vs ~6K baseline)
  - <1.5K tokens per response (vs ~3K baseline)
  - Automatic budget warnings
- **Incremental Indexing:**
  - Zero version drift enforcement
  - <1KB commits per update
  - Automated last_updated tracking

### Technical
- **Token Budget Enforcement:**
  - Hard limits: 3K response, 15K X-MEM query
  - File loading discipline (offset/limit)
  - Pre-flight checks before skill loads
- **Version Synchronization:**
  - .metadata as source of truth
  - Automated sync scripts
  - Drift detection in CHECK 6
- **NDJSON Protocol:**
  - Append-only (no file rewrites)
  - Git-friendly (no merge conflicts)
  - Atomic index updates

### Validation
- ✅ CHECK 6: All versions synchronized
- ✅ X-MEM Protocol tested (failure capture, proactive recall)
- ✅ Token economy enforced (budget warnings, file discipline)
- ✅ Incremental indexing automated (sync-versions, update-skill)

### Migration Notes
- No breaking changes - fully backward compatible
- X-MEM auto-load disabled (manual trigger or proactive recall)
- Token economy enforced via Section 7 (jimmy-core-preferences)
- Version synchronization automatic (via scripts)

---

## [1.7.1] - 2026-02-14

### Changed - Module 2 Governance Complete
- **jimmy-core-preferences:** Version synchronized to v1.5.0 across all files
  - SKILL.md header updated (v1.4.0 → v1.5.0)
  - Last updated date: 2026-02-14
  - CHANGELOG.md footer synchronized
- **HUB_MAP.md:** Updated to reflect v1.5.0 production status
  - jimmy-core-preferences version reference corrected (line 357)
  - Added Routing Status: 🟢 Active (Module 2 Complete)
  - Last updated: 2026-02-14
  - Footer version: 1.7.1

### Added
- **Routing validation test:** scripts/validate_routing.md
  - 4 test scenarios covering all Ciclope Rules (#1-5)
  - Read-only verification commands
  - Regression prevention checklist
  - Comprehensive troubleshooting guide

### Fixed
- Version inconsistency between .metadata (v1.5.0) and SKILL.md (v1.4.0)
- HUB_MAP.md outdated version reference

### Notes
- All Module 2 deliverables complete
- Zero breaking changes - fully backward compatible
- Routing infrastructure production-ready

---

## [1.7.0] - 2026-02-13

### 🎯 Major Architectural Upgrade

**Focus:** Hub cleanup, skill routing foundation, scalability preparation

### Added
- **HUB_MAP.md** - Centralized skill routing dictionary (~30KB)
  - All triggers documented (15+)
  - Skill dependencies declared
  - Tier-based loading strategy (Always/Context-Aware/Explicit)
  - Lifecycle states defined (Production/Roadmap/Deprecated)
  - Skill Routing Logic (4 patterns: Trigger-Based, Context-Based, Always-Load, Proactive)
  - Complete troubleshooting guide
  - Adding New Skills Protocol
- Hierarchy notes in skill-level EXECUTIVE_SUMMARY.md files
  - jimmy-core-preferences/EXECUTIVE_SUMMARY.md
  - session-memoria/EXECUTIVE_SUMMARY.md
  - gdrive-sync-memoria/EXECUTIVE_SUMMARY.md
  - pbi-claude-skills/EXECUTIVE_SUMMARY_PBI_SKILLS.md

### Changed
- **EXECUTIVE_SUMMARY.md** (root) - Renamed from HUB_EXECUTIVE_SUMMARY.md
  - Single canonical summary for entire hub
  - Clear hierarchy (hub-level vs. skill-level docs)
- **README.md** - Fixed skill count and added HUB_MAP integration
  - Skill count: 7 collections → 5 production collections
  - Session-memoria entry count: 8 → 11 entries
  - Added "🗺️ Skill Routing Guide" section with HUB_MAP links
  - Added HUB_MAP.md references to skill table
  - Updated stats section (production vs. planned skills)
- **MODULE 2 COMPLETED:** jimmy-core-preferences v1.5.0
  - Pattern 6: HUB_MAP Integration & Skill Router implemented
  - Xavier now proactively routes to skills based on HUB_MAP
  - Tier-based loading prevents token explosion (8K vs 250K+ at 100 skills)
  - Zero Tolerance enforcement blocks orphaned skills (Ciclope Rule #5)
  - Veto Rule prevents reinventing the wheel (Ciclope Rule #3)
  - Proactive Transparency notifies skill activation (Ciclope Rule #2)
  - Post-Task Hygiene auto-suggests cleanup (Ciclope Rule #4)
  - Active Routing Mandate checks HUB_MAP first (Ciclope Rule #1)
- **MODULE 3 COMPLETED:** session-memoria v1.2.0
  - 3-Tier Archiving System (HOT/WARM/COLD) with aggressive tiering (<30d/30-90d/>90d)
  - Incremental indexing (O(1) constant time vs O(n) rebuild)
  - Token budget management (INFO/WARN/CONFIRM alerts)
  - Deep search protocol (--deep and --full flags)
  - Performance: 200x faster indexing at 500 entries, 91% token savings
  - Scalability: Supports 1000+ entries without degradation
- **MODULE 4 COMPLETED:** Documentation Consistency & Golden Close Protocol
  - Pattern 7: Golden Close Protocol (7-step mandatory checklist)
  - Integrity check tool (scripts/integrity-check.sh) - 5 automated validations
  - EXECUTIVE_SUMMARY.md updated to v1.7.0 (all versions current)
  - Hub 100% Zero Tolerance compliant (no loose files)
  - NotebookLM-optimized documentation structure
- **Skills by Status**
  - Production: 5 skills (jimmy-core-preferences, session-memoria, gdrive-sync-memoria, claude-session-registry, pbi-claude-skills)
  - Planned: 0 (python/git moved to roadmap v1.8.0)

### Removed
- **EXECUTIVE_SUMMARY.md** (obsolete Feb 8 version) - Removed duplicate
- **python-claude-skills/** - Placeholder removed (moved to roadmap v1.8.0)
- **git-claude-skills/** - Placeholder removed (moved to roadmap v1.8.0)

### Migration Notes
- No breaking changes (all production skills unchanged)
- HUB_MAP.md is new documentation (no code changes)
- Placeholder skills can be recreated when ready for development

### Validation
- Run: `ls -la | grep claude-skills` → Should show ONLY pbi-claude-skills
- Run: `cat HUB_MAP.md | grep "Production Skills"` → Should list 5 skills
- Check: README.md links to HUB_MAP work correctly
- Verify: All skill EXECUTIVE_SUMMARY.md files have hierarchy notes

---

## [1.6.0] - 2026-02-12

### Added
- **claude-session-registry** - New skill v1.0.0 for session tracking
  - Resume ID tracking with Git context (branch + commit hash)
  - Golden Close protocol (reminds to capture session before exit)
  - Session search and statistics
  - Timezone-aware timestamps (America/Sao_Paulo)
  - Auto-push to GitHub after registry updates
  - Template-based entry creation
  - Integration with session-memoria for cross-referencing
- **gdrive-sync-memoria automation improvements**
  - sync-gdrive.sh wrapper script for direct execution
  - QUICK_REFERENCE.md for troubleshooting and quick access
  - Zero-friction defense implementation (3-layer protection)
  - MEMORY.md enhanced with triggers and anti-patterns
  - Automated trigger recognition ("sincroniza Google Drive")
- **session-memoria** v1.2
  - 2 new entries synced from Google Drive
  - Entry: 2026-02-12-001 (Claude Code Session Resume IDs)
  - Total entries: 6 → 8
  - Total size: 18.2 KB → 20.7 KB
  - Enhanced Google Drive metadata tracking

### Changed
- **README.md**
  - Added claude-session-registry to skills table
  - Updated Hub Architecture with claude-session-registry structure
  - Updated gdrive-sync-memoria architecture (new files)
  - Updated statistics: 8 entries, 4 skills, 21KB knowledge base
  - Updated version history: v1.4.0 → v1.6.0
  - Last updated: 2026-02-11 → 2026-02-12
- **MEMORY.md** (auto memory)
  - Section: "Google Drive Sync - PADRÃO AUTOMÁTICO"
  - Triggers documented for immediate recognition
  - Anti-pattern documented: "Instalação desnecessária"
  - Workflow padrão: Check docs FIRST, then execute
  - Claude Intelligence Hub structure reference

### Fixed
- **Zero-friction sync trigger** - Eliminated setup questions when requesting Google Drive sync
  - 3-layer defense: MEMORY.md + script wrapper + skill registration
  - Xavier now recognizes sync requests immediately without asking about installations
  - Anti-pattern catalogued to prevent regression

### Documentation
- Created: claude-session-registry/SKILL.md (15KB)
- Created: claude-session-registry/README.md (4KB)
- Created: claude-session-registry/SETUP_GUIDE.md (10KB)
- Created: gdrive-sync-memoria/sync-gdrive.sh (executable script)
- Created: gdrive-sync-memoria/QUICK_REFERENCE.md (3KB)
- Updated: MEMORY.md (auto memory with patterns)
- Updated: README.md (skills table, architecture, stats)
- Updated: CHANGELOG.md (this file)

### Validation
- ✅ Google Drive sync executed successfully (1 file)
- ✅ Entry 2026-02-12-001 created and indexed
- ✅ Git commit + push successful (af98566)
- ✅ claude-session-registry skill symlinked
- ✅ MEMORY.md triggers tested
- ✅ Zero-friction workflow validated
- ✅ All documentation updated

---

## [1.5.0] - 2026-02-11

### Added
- **gdrive-sync-memoria** - New skill v1.0.0 for Google Drive integration
  - Automated import from ChatLLM Teams (ABACUS.AI) → session-memoria
  - 8-step workflow: list → download → parse → create → index → commit → rename → move
  - Auto-categorization and auto-tagging (up to 5 tags)
  - Language preservation (NO translation)
  - Error handling with retry logic and comprehensive logging
  - Proactive sync reminders (>3 days)
  - rclone integration with OAuth Google Drive access
  - Server-side operations (fast rename/move)
- **Token Monitoring Protocol** - jimmy-core-preferences v1.5.0
  - Real token parsing from system reminders
  - Proactive alerts at 70%, 85%, 95% (fixed from 2%)
  - Improved fallback heuristic (chars / 3.8)
  - Visual indicators (🟠 🔶 🔴)
  - Automatic snapshot creation before /compact

### Changed
- **session-memoria** v1.1 → v1.2
  - Added Google Drive integration metadata tracking
  - Total entries: 6 → 7 (first sync: github_security_summary.md)
  - Total size: 16.8 KB → 18.2 KB
  - New frontmatter fields: source, original_filename, language, sync_date
- **jimmy-core-preferences** v1.4 → v1.5
  - Context Management section completely rewritten
  - Alert thresholds now functional
- **README.md** - Added gdrive-sync-memoria to skills table

### Fixed
- **Context overflow prevention** - Alerts now trigger at correct thresholds (70/85/95%)
- **Token estimation** - More accurate when system reminders unavailable

### Documentation
- Created: gdrive-sync-memoria/SKILL.md (10KB)
- Created: gdrive-sync-memoria/README.md (5KB)
- Created: gdrive-sync-memoria/EXECUTIVE_SUMMARY.md (22KB)
- Created: gdrive-sync-memoria/SETUP_INSTRUCTIONS.md
- Created: gdrive-sync-memoria/CHANGELOG.md
- Updated: session-memoria/EXECUTIVE_SUMMARY.md (v1.2)
- Updated: session-memoria/CHANGELOG.md (v1.2)
- Updated: jimmy-core-preferences/CHANGELOG.md (v1.5)
- Updated: .gitignore (gdrive-sync-memoria/logs/, temp/)

### Validation
- ✅ rclone installed and configured (v1.73.0)
- ✅ Google Drive remote authenticated (gdrive-jimmy)
- ✅ First production sync successful (1 file processed)
- ✅ Entry created: 2026-02-11-002
- ✅ Indexes updated (by-date, by-category, by-tag)
- ✅ Git commit + push successful
- ✅ File renamed and moved to processed folder
- ✅ Hybrid workflow operational (ChatLLM → Google Drive → session-memoria)

---

## [1.4.0] - 2026-02-11

### Added
- **Windows Junction Setup** - Complete guide for auto-sync skills on Windows (WINDOWS_JUNCTION_SETUP.md)
- **Mobile Session Support** - MOBILE_SESSION_STARTER.md for session-memoria on mobile devices
- **Hub Executive Summary** - Comprehensive HUB_EXECUTIVE_SUMMARY.md covering all components
- **Cross-device sync** - Validated mobile → desktop → mobile workflow

### Changed
- **session-memoria** v1.0 → v1.1
  - Added entry status tracking (aberto, em_discussao, resolvido, arquivado)
  - Added priority levels (alta, media, baixa)
  - Added update/recap triggers
  - Mobile usage section in README.md
  - Updated EXECUTIVE_SUMMARY.md with mobile strategy
- **jimmy-core-preferences** v1.0 → v1.4 (via junction fix)
- **README.md** - Added Windows junction warning

### Fixed
- **Critical:** Skills loading outdated versions (3+ versions behind)
  - Implemented Windows junction points (no admin needed)
  - Auto-sync via git pull, true file linking (same inode)
- **Git sync protocol** - Reinforced mandatory pull at session start

### Documentation
- Created: WINDOWS_JUNCTION_SETUP.md (6KB)
- Created: HUB_EXECUTIVE_SUMMARY.md (30KB+)
- Created: session-memoria/MOBILE_SESSION_STARTER.md (12KB)
- Updated: session-memoria/README.md, EXECUTIVE_SUMMARY.md
- Updated: README.md

### Validation
- ✅ Junction points working (verified)
- ✅ Mobile starter file tested
- ✅ Cross-device sync validated
- ✅ 6 session-memoria entries

## [1.0.0] - 2026-02-08

### Added
- Repository structure with hierarchical organization
- pbi-claude-skills/ directory for Power BI specific skills
- Placeholders for future skill categories (Python, Git)
- MIT License
- Initial .gitignore (Python template)
