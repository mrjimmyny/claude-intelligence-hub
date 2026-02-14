# Changelog

All notable changes to X-MEM Protocol will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-02-14

### Added
- Initial X-MEM protocol implementation
- NDJSON storage format (failures.jsonl, successes.jsonl)
- Index-based search (index.json)
- 5 trigger commands: load, record, search, stats, compact
- Integration with jimmy-core-preferences Pattern 6 (Proactive Recall)
- Context hash algorithm for failure/success matching
- Token budget enforcement (15K hard limit per query)
- Git auto-push on record operations
- SKILL.md execution instructions (~300 lines)
- README.md user documentation (~200 lines)
- .metadata skill configuration

### Features
- Automatic failure detection via Pattern 6
- Proactive recall suggestions when errors recur
- Tag-based search and filtering
- Tool-specific statistics
- Compaction utility for pruning stale entries
- Backup creation before compaction

### Technical
- NDJSON append protocol (Git-safe, no merge conflicts)
- Atomic index updates
- Token-efficient entry loading
- Fast index scanning (~500 token overhead)

---

## Unreleased

### Planned for 1.1.0
- `/xmem:export` command (JSON/CSV export)
- `/xmem:import` command (bulk import from logs)
- Web UI for browsing entries
- Success pattern promotion to jimmy-core-preferences
- Advanced analytics (failure trends, tool reliability scores)

### Planned for 1.2.0
- Cloud sync via gdrive-sync-memoria
- Multi-user X-MEM (shared team knowledge)
- AI-powered pattern extraction from logs
- Automatic confidence scoring based on usage

---

**Legend:**
- **Added:** New features
- **Changed:** Changes to existing functionality
- **Deprecated:** Soon-to-be removed features
- **Removed:** Removed features
- **Fixed:** Bug fixes
- **Security:** Vulnerability fixes
