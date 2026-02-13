# Changelog

All notable changes to the claude-session-registry skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] - 2026-02-13

### Added
- **Session Backup System** - Automatic backup of registered sessions to private GitHub repo
  - Markdown transcripts for all registered sessions (human-readable, searchable)
  - Raw .jsonl backups for sessions tagged `#critical` (full restore capability)
  - Indexed by date, tag, and machine for easy discovery
  - Zero-cost solution using GitHub private repo (500MB free storage)
  - Integration with Step 9 of registration workflow (auto-trigger after git push)

- **New Scripts:**
  - `scripts/backup-session.sh` - Main backup orchestrator (10-step workflow)
  - `scripts/parse-jsonl-to-markdown.sh` - JSONL to markdown transcript converter

- **New Configuration Options:**
  - `settings.auto_backup` (default: true) - Enable/disable automatic backup
  - `settings.backup_repo_path` (default: ~/claude-session-backups) - Backup repository location

- **New Documentation:**
  - `docs/BACKUP_SYSTEM.md` - Complete backup system documentation
  - `~/claude-session-backups/docs/RESTORE_GUIDE.md` - Session restore instructions
  - `~/claude-session-backups/README.md` - Backup repository overview

- **Backup Tracking:**
  - `backup-tracking.json` - Local tracking file for backup statistics
  - `~/claude-session-backups/metadata.json` - Remote backup statistics

### Changed
- **Step 9 Enhanced** - Now includes automatic backup trigger after git push
  - Part A: Commit session registry (existing logic)
  - Part B: Trigger session backup (new)
  - Non-blocking: backup failure does not prevent registration

- **Version Bump:**
  - `.metadata` version: 1.0.0 → 1.1.0
  - Description updated to mention backup feature

### Technical Details
- **Backup Workflow:**
  1. Locate session .jsonl file in ~/.claude/projects/
  2. Extract date components (YYYY/MM) for directory structure
  3. Create directory structure in backup repo
  4. Generate markdown transcript via parser script
  5. Copy .jsonl if #critical tag present
  6. Update indexes (by-date, by-tag, by-machine)
  7. Update metadata.json with statistics
  8. Git commit with structured message
  9. Git push with retry logic (3 attempts, exponential backoff: 2s, 4s, 8s)
  10. Success summary with links

- **Parser Features:**
  - Parses .jsonl line-by-line
  - Extracts user/assistant messages with timestamps
  - Formats thinking blocks (extended thinking)
  - Summarizes tool calls (Read, Write, Edit, Bash, Grep, Glob, Task)
  - Generates session statistics (message counts, tool usage)
  - Creates markdown with YAML frontmatter

- **Error Handling:**
  - Missing .jsonl file: log error, skip backup
  - Git push failure: retry 3x with backoff, manual recovery steps
  - Parser failure: create minimal transcript with error notice
  - Disk space check: warn if < 100MB free

- **Retry Logic Pattern:** From `gdrive-sync-memoria/sync-gdrive.sh`
- **Structured Commit Messages:** From existing registry commit pattern

### Files Added/Modified

**New Files:**
- `scripts/backup-session.sh` (~300 lines)
- `scripts/parse-jsonl-to-markdown.sh` (~400 lines)
- `backup-tracking.json` (tracking file)
- `docs/BACKUP_SYSTEM.md` (comprehensive docs)
- `~/claude-session-backups/` (entire backup repository)
  - `README.md`
  - `.gitignore`
  - `metadata.json`
  - `docs/RESTORE_GUIDE.md`
  - `transcripts/` (directory structure)
  - `critical/` (directory structure)
  - `indexes/` (directory structure)

**Modified Files:**
- `SKILL.md` - Step 9 enhanced with backup trigger (~50 lines added)
- `.metadata` - Added auto_backup and backup_repo_path settings
- `README.md` - Added backup system section
- `CHANGELOG.md` - This entry

### Migration Notes

**For Existing Users:**
1. Pull latest changes: `git pull origin main`
2. Create backup repository on GitHub (private)
3. Clone backup repo: `git clone git@github.com:mrjimmyny/claude-session-backups.git ~/claude-session-backups`
4. Next session registration will automatically trigger backup
5. Optional: Retroactively backup existing sessions (see docs/BACKUP_SYSTEM.md)

**Configuration:**
- Auto-backup enabled by default (`auto_backup: true`)
- To disable: edit `.metadata` → `settings.auto_backup: false`

---

## [1.0.0] - 2026-02-12

### Added
- **Golden Close Protocol** - Automatic reminder system when tasks complete
  - Pre-generates tags and summary suggestions
  - Emphatic alert to prevent forgotten session registrations
  - Fresh context capture while session is still active

- **Register Workflow** - 10-step session registration process
  - Auto-capture Git context (branch + commit hash)
  - Auto-capture timestamp (Brazilian timezone)
  - Auto-capture machine ID
  - User-provided tags and summary
  - Git commit with structured message
  - Auto-push to remote (configurable)

- **Search Workflow** - Multi-filter session search
  - Search by tag (`#TagName`)
  - Search by date/month (`2026-02`, `2026-02-12`)
  - Search by project keyword
  - Search by machine ID
  - Ranked results (newest first, limit 10)

- **Stats Workflow** - Analytics and insights
  - Monthly stats (default)
  - All-time stats (`--all`)
  - Breakdowns by machine, project, tag, branch
  - Top 5 projects, Top 10 tags

- **Hierarchical Storage** - Organized file structure
  - Registry organized by `YYYY/MM/SESSIONS.md`
  - Monthly template system
  - Auto-create directories as needed

- **Multi-Machine Support**
  - Machine ID tracking
  - Junction point sync (Windows)
  - Git-based synchronization

- **Brazilian Timezone** - Built-in support
  - All timestamps in `America/Sao_Paulo`
  - Consistent across all machines

- **Data Validation** - Comprehensive validation rules
  - Session ID format validation
  - Date/time format validation
  - Tag format validation (must start with `#`)
  - Summary validation (3-5 bullet points)
  - Git context validation

### Technical Details
- **Storage Format:** Markdown tables (9 columns)
- **Auto-capture:** Git branch, commit, project path, timestamp, machine
- **User Input:** Session ID, tags, summary
- **Git Integration:** Auto-commit with structured messages, optional auto-push
- **Language:** pt-BR (Brazilian Portuguese)

### Files Included
- `.metadata` - Skill configuration (triggers, settings)
- `SKILL.md` - Complete workflow documentation (~350 lines)
- `README.md` - User-facing documentation
- `CHANGELOG.md` - This file
- `SETUP_GUIDE.md` - Installation and troubleshooting
- `templates/monthly-registry.template.md` - Monthly table template

---

## Future Roadmap

### Planned for v1.1.0
- Export to CSV/JSON
- Session resume integration (auto-load context from past sessions)
- Rich summary formatting (support for code snippets)
- Automatic tag suggestions based on file paths

### Planned for v1.2.0
- Web dashboard for session visualization
- Time tracking (session duration)
- Dependency tracking (related sessions)
- Cross-project insights

---

**For full documentation, see SKILL.md**
