# Jimmy Core Preferences

> **Global Cross-Agent Operating Framework** — Universal preferences and operating rules for all agents working with Jimmy.

## What is This?

`jimmy-core-preferences` is the **central operating framework** for how any AI agent should work with Jimmy. It is not Claude-specific. It applies to any agent (Claude Code, Codex/OpenAI, Gemini, and others) across any interface.

Instead of repeating the same rules in every conversation or session, this skill serves as a permanent, version-controlled reference loaded at the start of every interaction.

---

## Purpose

- **Eliminate repetition** — agents do not need to be told the same rules every session
- **Cross-agent consistency** — same operating model for Claude, Codex, Gemini, and others
- **Documentary awareness** — agents know the Obsidian-based documentary system and follow it
- **Prompt governance** — clear rules for delegation prompts (English, file-first, path-specific)
- **Session governance** — every session is logged; daily reports are updated during the work

---

## What's Inside

| Section | Description |
|---|---|
| **A. Purpose, Scope and Precedence** | What this skill is, where it applies, what overrides what |
| **B. Universal Operating Posture** | Radical honesty, objectivity, anti-yes-man, proactive intelligence |
| **C. Communication Compression** | Short responses by default; artifacts as files, not chat dumps |
| **D. Cross-Agent Bootstrap and Fallback** | How to load this skill when native auto-load is not available |
| **E. Prompt Creation and Delegation** | English, file-first, path-specific, unambiguous prompts |
| **F. Project Documentary Workspace** | Baseline folder structure for project documentation |
| **G. Session Log and Daily Report** | Mandatory session documentation and daily report protocol |
| **H. Proactive Reminder Cadence** | Conditional reminders for claude-session-registry, context-guardian, docx-indexer |
| **I. Power BI / DAX Domain Overlay** | DAX/PBI-specific rules activated on relevant work |
| **J. Skill Evolution Governance** | How and when to update this skill |

---

## How It Works

### Auto-Load (Claude Code)

When you start Claude Code, this skill loads automatically with highest priority, giving the agent immediate context about Jimmy's operating framework.

### Cross-Agent Loading (Codex, Gemini, etc.)

For agents without native auto-load:
1. Jimmy provides: `C:\ai\obsidian\CIH\_skills-cross-agent-machines\README.md`
2. Agent reads the router and loads only the needed skills from `C:\ai\claude-intelligence-hub`

### Dynamic Updates

When Jimmy says things like "always do X" or "add this to preferences":
1. Agent updates `SKILL.md`
2. Commits and pushes to GitHub
3. Confirms briefly

---

## File Structure

```
jimmy-core-preferences/
├── README.md              <- You are here
├── SKILL.md               <- Main file agents read
├── CHANGELOG.md           <- Version history
├── EXECUTIVE_SUMMARY.md   <- Comprehensive overview
├── SETUP_GUIDE.md         <- Installation instructions
└── .metadata              <- Version and config
```

---

## Setup

See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for installation instructions.

**Quick setup (Windows — Junction, recommended):**

```cmd
cmd /c mklink /J "%USERPROFILE%\.claude\skills\user\jimmy-core-preferences" "C:\ai\claude-intelligence-hub\jimmy-core-preferences"
```

> **Windows note:** Use Junction points (`mklink /J`), not Symbolic Links. Claude Code uses `dirent.isDirectory()` internally and requires Junction points to resolve correctly.

---

## Version History

See [CHANGELOG.md](./CHANGELOG.md) for detailed version history.

**Current Version:** 2.0.0
**Status:** Production
**Last Updated:** 2026-03-11

### Major Changes in v2.0.0

- Repositioned from "Claude/Xavier-centric master skill" to **global cross-agent operating framework**
- Added: Prompt Creation and Delegation Standard (Section E)
- Added: Project Documentary Workspace Protocol (Section F)
- Added: Session Log and Daily Report Protocol (Section G)
- Added: Proactive Reminder Cadence (Section H)
- Added: Power BI / DAX Domain Overlay (Section I)
- Removed: embedded workflows belonging to sibling skills
- Removed: Claude-only assumptions and overlong identity framing
- Fixed: encoding artifacts and mojibake
- Result: cleaner, shorter, more portable across agents

---

## Related

- [Claude Intelligence Hub](https://github.com/mrjimmyny/claude-intelligence-hub) — source of truth
- [Cross-Agent Skills README](C:\ai\obsidian\CIH\_skills-cross-agent-machines\README.md) — bootstrap router for agents without native skill loading
- [HUB_MAP.md](../HUB_MAP.md) — full skill routing reference
