# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
