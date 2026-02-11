# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
