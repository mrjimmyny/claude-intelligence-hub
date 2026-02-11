# Changelog - Session Memoria

All notable changes to this skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.2.0] - 2026-02-11

### Added
- **Google Drive Integration:** New companion skill `gdrive-sync-memoria` v1.0.0
- **ChatLLM Teams Workflow:** Automated import of summaries from ABACUS.AI via Google Drive
- **Auto-Categorization:** Keyword-based category inference for imported files
- **Auto-Tagging:** Extract up to 5 relevant tags from imported content
- **Language Preservation:** Preserves original language (NO translation) for all imported content
- **Source Tracking:** New frontmatter fields `source`, `original_filename`, `language`, `sync_date`
- **gdrive_sync Metadata:** Tracking in metadata.json (last_sync, total_synced, last_count, last_error)

### Changed
- **metadata.json:** Added `gdrive_sync` section with sync tracking
- **Total Entries:** 6 → 7 (first Google Drive sync: github_security_summary.md)
- **Total Size:** 16.8 KB → 18.2 KB
- **Supported Sources:** Local manual + Google Drive automated

### Fixed
- None

---

## [1.1.0] - 2026-02-10

### Added
- **Entry tracking fields:** `status`, `priority`, `last_discussed`, `resolution` in YAML frontmatter
- **Update Workflow:** 7-step process to change status, resolution, and priority of existing entries
- **Recap Workflow:** 6-step process to summarize recent entries with status overview and visual indicators
- **Git Sync (Step 0):** Mandatory git fetch + pull before any read operation (search, recap, update, stats)
- **Update triggers (Portuguese):** "marca como resolvido", "fecha o tema", "atualiza o status de", etc.
- **Recap triggers (Portuguese):** "resume os últimos registros", "quais assuntos registramos", "o que temos em aberto", etc.
- **Status values:** `aberto`, `em_discussao`, `resolvido`, `arquivado`
- **Priority values:** `alta`, `media`, `baixa`
- **Status visual indicators:** in indices and recap display
- **Data validation:** for new status and priority fields
- **Resolution section:** optional markdown section added to entries when resolved

### Changed
- Entry template updated with 4 new frontmatter fields
- Index format now includes status badge (`Status: \`aberto\``)
- Index template updated to reflect new format
- Existing entry (2026-02-10-001) updated with new fields
- `.metadata` updated with update/recap triggers and valid status/priority settings
- Future enhancements renumbered to v1.2.0+ (entry editing/updating now implemented)

---

## [1.0.0] - 2026-02-10

### Added
- Initial release of session-memoria skill
- Save workflow with Portuguese trigger detection
- Entry creation with YAML frontmatter and markdown content
- Unique entry ID generation (YYYY-MM-DD-NNN format)
- Triple index system:
  - by-date.md (chronological index)
  - by-category.md (domain-based index)
  - by-tag.md (cross-cutting themes index)
- Search workflow with multi-index parallel search
- Search modifiers: --category, --tag, --date, --recent
- Growth monitoring with alert thresholds:
  - Warning at 500 entries
  - Critical at 1000 entries
- Statistics command (/session-memoria stats)
- Automatic Git integration:
  - Auto-commit on every save
  - Auto-push (configurable)
  - Structured commit messages
- Metadata tracking (metadata.json):
  - Total entries and size
  - Counters (daily, by category, by tag, by month)
  - Alert history
- Entry templates (entry.template.md)
- Index templates (index.template.md)
- Year/Month directory structure for scalability
- Portuguese language support:
  - PT-BR triggers
  - Brazilian date format (DD/MM/YYYY)
  - PT-BR content support
- Predefined categories:
  - Power BI
  - Python
  - Gestão (Management)
  - Pessoal (Personal)
  - Git
  - Other
- Tag system (max 5 tags, kebab-case)
- Entry validation (category, tags, summary length)
- Proactive offering integration with jimmy-core-preferences
- Proactive recall integration
- Two-tier memory system (MEMORY.md + session-memoria)

### Documentation
- SKILL.md: Comprehensive instructions for Claude
- README.md: User documentation in Portuguese
- CHANGELOG.md: Version history
- SETUP_GUIDE.md: Installation guide
- templates/entry.template.md: Entry structure template
- templates/index.template.md: Index structure template

### Technical
- File structure optimized for 1000+ entries
- Parallel search across indices
- Metadata-driven counters (no file counting)
- Error handling for common scenarios
- Data validation before and after save

---

## [Unreleased]

### Planned for v1.2.0
- Archive entries older than 6 months
- Entry merging (consolidate related entries)
- Tag consolidation and cleanup tools
- Entry summarization for large corpus
- Export functionality (PDF, JSON, etc.)
- Advanced search features:
  - Boolean operators (AND, OR, NOT)
  - Date range queries
  - Full-text search within entries
- Related entries suggestion (based on tags and content)
- Batch import from existing notes
- Entry deletion with confirmation

### Planned for v1.3.0
- Web interface for browsing entries
- Visual analytics (graphs, charts)
- Entry linking and backlinks
- Automatic tag suggestions (ML-based)
- Natural language date queries ("last month", "this year")
- Entry versions and history
- Collaborative features (comments, sharing)

---

## Version History

| Version | Date | Status | Notes |
|---------|------|--------|-------|
| 1.1.0 | 2026-02-10 | Released | Entry tracking, update/recap workflows, git sync |
| 1.0.0 | 2026-02-10 | Released | Initial release with core features |

---

**Maintained by Xavier**
**Repository:** https://github.com/mrjimmyny/claude-intelligence-hub
