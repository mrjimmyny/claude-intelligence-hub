# Changelog

All notable changes to the **jimmy-core-preferences** skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.4.0] - 2026-02-10

### Added
- **🚨 CRITICAL: Session Memoria Git Strategy** section
  - Mandatory git workflow rules for session-memoria operations
  - ALWAYS work on branch `main` (never create feature branches)
  - ALWAYS commit and push immediately after operations
  - Detailed implementation checklist with bash commands
  - Error handling procedures for git conflicts and failures
  - Clear explanation of why these rules prevent sync issues between Mobile and Desktop sessions

### Changed
- Updated version from 1.3.0 to 1.4.0
- Enhanced Pattern 1 (Starting a New Session) with mandatory git sync requirement

### Fixed
- **CRITICAL FIX:** Prevents session-memoria entries from being created in feature branches
- Eliminates sync issues that cause lost entries between Mobile and Desktop sessions
- Ensures git is always the single source of truth for knowledge entries

### Security
- Prevents data loss from unmerged branches
- Ensures consistency across all Claude instances (Mobile and Desktop)

---

## [1.3.0] - 2026-02-10

### Added
- **Recap triggers** in Pattern 5: "resume os últimos registros", "quais assuntos registramos", "o que temos em aberto", etc.
- **Update triggers** in Pattern 5: "marca como resolvido", "fecha o tema", "atualiza o status de", etc.
- **Git Sync requirement** documented as mandatory Step 0 before any session-memoria read operation
- **Status-aware proactive recall**: Xavier now mentions entry status when referencing past topics

### Changed
- Pattern 5 expanded from save/recall only to save/recap/update/recall
- Pattern 5 now documents full workflows for all 4 operations
- Updated version from 1.2.0 to 1.3.0

---

## [1.2.0] - 2026-02-10

### Added
- Pattern 5: Knowledge Capture (Session Memoria Integration)
- Proactive knowledge capture workflow
- Two-tier memory system documentation (MEMORY.md + Session Memoria)
- Trigger detection for save and recall operations
- Proactive recall integration

### Changed
- Updated version from 1.1.0 to 1.2.0

---

## [1.1.0] - 2026-02-10

### Added
- **Identity & Relationship** section
  - Established names: Xavier (Claude) and Jimmy (user)
  - Defined relationship as professional partners, collaborators, and friends
  - Set clear addressing conventions (always use names, not generic terms)
  - Inspiration reference: Professor Xavier from X-Men

### Changed
- Updated version from 1.0.0 to 1.1.0
- Updated last modified date to 2026-02-10

### Technical
- Implemented auto-sync workflow (Option 3)
  - Updates made to `~/.claude/skills/user/jimmy-core-preferences/`
  - Automatically copied to `~/claude-intelligence-hub/jimmy-core-preferences/`
  - Changes committed and pushed to GitHub automatically

---

## [1.0.0] - 2025-02-09

### 🎉 Initial Release

First version of the Jimmy Core Preferences master skill.

### Added
- **Core Principles** section
  - Radical Honesty & Professional Objectivity
  - Proactive Intelligence
  - Context Awareness & Self-Management

- **Do's Section** - What Claude should do
  - Communication style guidelines
  - Work approach standards
  - Autonomy & auto-update rules

- **Don'ts Section** - What Claude should avoid
  - Communication anti-patterns
  - Work anti-patterns
  - Dangerous patterns to avoid

- **Workflow Patterns**
  - Pattern 1: Starting a new session
  - Pattern 2: Receiving a request
  - Pattern 3: Context management
  - Pattern 4: Learning & updating

- **Context Management Rules**
  - Proactive alerts at different context levels (50%, 70%, 85%, 95%)
  - Compact strategy with structured summaries
  - Auto-snapshot creation

- **Tool & Technology Preferences**
  - Git & GitHub conventions
  - Code quality standards
  - Documentation requirements

- **Progress Tracking** guidelines
  - How to show progress during long operations
  - How to handle being stuck

- **Learning & Adaptation** system
  - Rules for evolving this skill
  - Version history tracking
  - Emergency override mechanism

### Configuration
- Auto-load enabled with highest priority
- Metadata file created with version tracking
- GitHub sync configured

### Documentation
- Comprehensive README.md for human readers
- Detailed SKILL.md for Claude to parse
- This CHANGELOG.md for tracking changes

---

## [Unreleased]

### Planned for Future Versions

#### v1.1.0 (Future)
- [ ] Add project-specific override mechanisms
- [ ] Include examples of actual conversations
- [ ] Create quick reference card
- [ ] Add troubleshooting section

#### v1.2.0 (Future)
- [ ] Integration with other domain skills
- [ ] Telemetry for tracking skill effectiveness
- [ ] A/B testing different approaches
- [ ] Automated skill optimization

---

## Version Guidelines

### Major Version (x.0.0)
- Breaking changes to core principles
- Fundamental restructuring
- Complete rewrites

### Minor Version (1.x.0)
- New sections added
- New workflow patterns
- Significant preference additions
- Non-breaking enhancements

### Patch Version (1.0.x)
- Typo fixes
- Clarifications
- Small rule adjustments
- Documentation updates

---

## Update Template

When adding a new entry, use this format:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature or section

### Changed
- Modified existing behavior

### Deprecated
- Features marked for removal

### Removed
- Features that were removed

### Fixed
- Bug fixes or corrections

### Security
- Security-related changes
```

---

## Notes

- All updates to this skill should include a CHANGELOG entry
- Each entry should explain WHAT changed and WHY
- Keep entries concise but informative
- Link to relevant issues or discussions when applicable

---

**Last Updated:** 2026-02-10
**Current Version:** 1.4.0
**Status:** ✅ Active Maintenance
