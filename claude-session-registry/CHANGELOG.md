# Changelog

All notable changes to the claude-session-registry skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
