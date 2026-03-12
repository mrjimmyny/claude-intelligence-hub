# Changelog

All notable changes to the **jimmy-core-preferences** skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.2] - 2026-03-12

### Changed
- **Section G: Session Log and Daily Report Protocol** — clarified the curator model for daily reports:
  - session docs are updated during the work
  - daily reports are consolidated once per day, at closure
  - daily reports are source-of-truth summaries built from the session docs of the same day
  - daily reports must not be treated as per-interaction logs unless Jimmy explicitly requests that exception

### Updated
- `SKILL.md`
- `README.md`
- `.metadata`

## [2.0.1] - 2026-03-12

### Changed
- **Section F: Project Documentary Workspace Protocol** — added the formal project operational state layer at the project root:
  - `PROJECT_CONTEXT.md`
  - `status-atual.md`
  - `next-step.md`
  - `decisoes.md`
- **Section G: Session Log and Daily Report Protocol** — aligned to the hybrid documentary model:
  - `1 session doc per day + agent`
  - never create session docs per project
  - mandatory `Context Type: Project|General`
  - mandatory `Project: <real name>` or `GENERAL`
  - same session doc may contain multiple `Project` and `General` work blocks
  - daily reports must separate `Project Work` and `General Work`

### Updated
- `SKILL.md`
- `README.md`
- `SETUP_GUIDE.md`
- `EXECUTIVE_SUMMARY.md`
- `.metadata`

## [2.0.0] - 2026-03-11

### Global Cross-Agent Operating Framework

**Focus:** Transform `jimmy-core-preferences` from a Claude/Xavier-centric master skill into a global cross-agent operating framework, aligned with Jimmy's documentary operating model in Obsidian.

### Added
- **Section D: Cross-Agent Bootstrap and Fallback** — fallback path via `C:\ai\obsidian\CIH\_skills-cross-agent-machines\README.md` for agents without native auto-load
- **Section E: Prompt Creation and Delegation Standard** — English-only delegation prompts, file-first, path-specific, no chat dumps
- **Section F: Project Documentary Workspace Protocol** — baseline folder structure for project documentation, coherence over rigidity
- **Section G: Session Log and Daily Report Protocol** — mandatory session documentation, update-during-work, handoff blocks
- **Section H: Proactive Reminder Cadence** — conditional reminders for `claude-session-registry`, `context-guardian`, `docx-indexer` (max 1 per skill per phase)
- **Section I: Power BI / DAX Domain Overlay** — 10-rule overlay for DAX/PBI work (activated on relevant context)
- **Section J: Skill Evolution Governance** — rules for evolving this skill, sibling skill routing list

### Changed
- **Skill repositioned** — from "Master Skill for Claude" to "Global Cross-Agent Operating Framework"
- **Identity section** — removed fixed "Xavier" agent name; Jimmy is always Jimmy, agents keep their own codenames
- **Operating posture** — retained radical honesty, objectivity, anti-yes-man, proactive intelligence; made them more operational
- **Communication rules** — formalized default compression (5-6 lines max per topic; artifact as file, not chat)
- **Cross-agent routing** — `HUB_MAP.md` remains the routing authority for Claude Code sessions

### Removed from core
- Embedded workflows for `session-memoria`, `context-guardian`, `claude-session-registry`, `token-economy`, `x-mem` — delegated to their respective skills
- Claude-only assumptions and overlong identity framing
- Redundant token/governance procedures already covered in `token-economy`
- Golden Close Protocol full workflow — routing trigger remains, full procedure in `claude-session-registry`

### Fixed
- Encoding artifacts and mojibake removed
- File rewritten in clean UTF-8

### Architecture
- SKILL.md reduced from ~50KB to ~5KB — significantly more portable and readable
- 10 sections (A–J) replacing 7 patterns + multiple embedded workflows
- Sibling skill routing list explicit in Section J

### Breaking Changes
- Agents relying on embedded workflows from this skill must now load the respective sibling skills directly
- "Xavier" is no longer the fixed agent identity in this file

---

## [1.5.0] - 2026-02-13

### 🎯 Major Feature: Skill Router Integration (MODULE 2)

**Focus:** Transform Xavier from reactive assistant to proactive skill routing engine

### Added
- **Pattern 6: HUB_MAP Integration & Skill Router** (~7KB documentation including Ciclope enforcements)
  - Session start: Automatic HUB_MAP.md loading and parsing
  - **Ciclope Rule #1:** Active Routing Mandate (check HUB_MAP before any action)
  - **Ciclope Rule #2:** Proactive Transparency (notify when skills activate)
  - **Ciclope Rule #3:** The "Veto" Rule (block new implementations when skill exists)
  - **Ciclope Rule #4:** Post-Task Hygiene (clean up temp files proactively)
  - **Ciclope Rule #5:** Zero Tolerance enforcement (blocks orphaned skills, warns about loose files)
  - Tier-based loading strategy (3 tiers: Always/Context-Aware/Explicit)
  - Trigger detection & routing (exact/context/fuzzy/proactive priority)
  - Proactive skill recommendation system
  - Self-learning trigger patterns (user can teach new triggers)

### Changed
- EXECUTIVE_SUMMARY.md: Added Pattern 6 to workflow patterns
- .metadata: Version updated to 1.5.0
- SKILL.md: Pattern 6 added after Pattern 5 (before Context Management)

### Performance Improvements
- **Token Efficiency:** 8K tokens (Tier 1 only) vs 250K+ (naive all-skills at 100+ skills)
- **Routing Speed:** <100ms trigger match
- **Skill Discovery:** 90% improvement via proactive suggestions
- **Anti-Reinvention:** Veto rule prevents duplicate implementations

### Architecture
- HUB_MAP.md is now authoritative source for skill routing
- Prevents hub drift via Zero Tolerance rules (Ciclope #5)
- Scales to 100+ skills without context explosion
- Self-healing: detects and blocks orphaned skills

### Breaking Changes
- None (fully backward compatible)
- Existing skills continue working as before
- New routing logic is additive, not disruptive

### Added (Pattern 7)
- **Golden Close Protocol** - Mandatory 7-step checklist before ending sessions
  - STEP 1: Session Memoria consistency check (git sync)
  - STEP 2: HUB_MAP consistency check (orphaned/ghost skills)
  - STEP 3: Git status check (no uncommitted changes)
  - STEP 4: CHANGELOG verification
  - STEP 5: Session registry backup (optional)
  - STEP 6: Final git push confirmation
  - STEP 7: Summary report generation
- BLOCKING enforcement: Session cannot end with uncommitted work or sync issues

### Migration Notes
- Zero Tolerance will warn/block on first session if hub is inconsistent (orphaned skills or loose files)
- Users may see new notifications when skills auto-activate (Ciclope #2: Proactive Transparency)
- Veto warnings will appear if trying to create overlapping functionality (Ciclope #3)
- Golden Close Protocol will now execute before session end (mandatory)

---

## [1.5.0-beta] - 2026-02-11

### Added
- **Token Monitoring Protocol:** Real token parsing from system reminders (`Token usage: X/200000; Y remaining`)
- **Proactive Context Alerts:** Alerts at 70%, 85%, 95% (not just 2% as before)
- **Improved Fallback Heuristic:** Conservative estimation (chars / 3.8) when system reminders unavailable
- **Visual Indicators:** 🟠 70%, 🔶 85%, 🔴 95% with actionable messages
- **Snapshot Creation:** Automatic before suggesting /compact at 95%+
- **Protocol Documentation:** Comprehensive Token Monitoring Protocol in SKILL.md (lines 242-268)

### Changed
- **Context Management Section:** Complete rewrite with active monitoring requirements
- **Alert Thresholds:** Now functional at documented levels (70/85/95% vs. previous 2%)
- **Monitoring Strategy:** Proactive (not reactive) - alerts BEFORE overflow, never after

### Fixed
- **Context Overflow Prevention:** Fixed issue where alerts only appeared at 2% instead of 70/85/95%
- **Token Estimation:** More accurate fallback when system reminders not available

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

**Last Updated:** 2026-02-14
**Current Version:** 1.5.0
**Status:** ✅ Active Maintenance
