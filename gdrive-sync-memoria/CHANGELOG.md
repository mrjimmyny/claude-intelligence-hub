# Changelog

All notable changes to gdrive-sync-memoria will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-02-11

### Added

**Core Features:**
- Google Drive integration via rclone
- Automatic file sync from `_tobe_registered` to session-memoria
- Auto-categorization (Power BI, Python, Gestão, API Development, Database, Other)
- Auto-tagging (up to 5 tags per entry)
- Preserve original language (NO translation)
- Server-side file operations (fast rename/move)
- Batch git commits + push
- Comprehensive error handling and logging

**Workflow (8 Steps):**
1. List files in Google Drive input folder
2. Download files to temp/
3. Parse content and extract metadata
4. Create session-memoria entries
5. Rename files with `_pushed_session_memoria` suffix
6. Move to processed folder
7. Git commit + push
8. Cleanup and logging

**Error Handling:**
- Network failure retry (3 attempts, exponential backoff)
- Malformed file skip + log (continues processing)
- Git push retry (3 attempts)
- Comprehensive validation (pre-flight + per-file)

**Monitoring:**
- Sync history logging (`logs/sync_history.log`)
- Metadata tracking (last_sync, total_synced, last_count)
- Proactive reminders (>3 days since last sync)

**Configuration:**
- `config/drive_folders.json` (folder IDs, rclone remote)
- `.metadata` (skill configuration)
- Customizable settings (max_tags, summary_max_length)

**Documentation:**
- Comprehensive SKILL.md (10KB, Claude instructions)
- User-friendly README.md (setup guide, troubleshooting)
- This CHANGELOG.md

### Security
- OAuth-based Google Drive authentication
- No credentials stored in repo
- Git-ignored temp/ and logs/ directories
- Privacy warnings (no secrets in .md files)

### Performance
- Server-side operations (no download/upload for move)
- Batch git commits (one per sync, not per file)
- Typical sync: 1 file ~10s, 10 files ~60s

### Known Limitations
- No parallel file processing (sequential)
- No automatic duplicate detection (manual review)
- No translation (preserves original language only)
- No image/PDF support (markdown only)

---

## [Unreleased]

### Planned for v2.0
- [ ] Parallel file processing
- [ ] Conflict resolution (duplicate titles)
- [ ] Multi-language translation (preserve original + add PT/EN)
- [ ] Image embedding support
- [ ] PDF conversion support
- [ ] Automated categorization via Claude API
- [ ] Web UI for monitoring
- [ ] Auto-delete old processed files

---

## Version History Summary

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2026-02-11 | Initial release - Google Drive sync |

---

## Migration Guide

### From Manual Google Drive Workflow

**Before (Manual):**
1. Create summary in ChatLLM Teams
2. Download .md file
3. Manually create session-memoria entry
4. Manually format frontmatter
5. Manually update indexes
6. Git commit + push

**After (Automated):**
1. Create summary in ChatLLM Teams
2. Save .md to Google Drive `_tobe_registered`
3. Run `/gdrive-sync`
4. ✅ Done (all steps automated)

**Time saved:** ~5 minutes per file

---

## Breaking Changes

None (initial release)

---

## Contributors

- Jimmy (Product Owner, Requirements)
- Xavier (Implementation, Claude Sonnet 4.5)

---

## Support

**Issues:** Review logs at `gdrive-sync-memoria/logs/sync_history.log`
**Questions:** Ask Xavier for troubleshooting assistance
