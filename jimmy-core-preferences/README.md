# Jimmy Core Preferences

> Global Cross-Agent Operating Framework for all agents working with Jimmy.

## What is This?

`jimmy-core-preferences` is the central operating framework for how any AI agent should work with Jimmy. It is not Claude-specific. It applies to Claude Code, Codex/OpenAI, Gemini, and other agents across different interfaces.

Instead of repeating the same rules in every session, this skill serves as a permanent, version-controlled reference loaded at the start of the interaction.

---

## Purpose

- Eliminate repetition across sessions
- Keep cross-agent behavior consistent
- Preserve documentary awareness in the Obsidian operating layer
- Standardize prompt creation and delegation
- Enforce hybrid session governance and daily-report discipline

---

## What's Inside

| Section | Description |
|---|---|
| **A. Purpose, Scope and Precedence** | What this skill is, where it applies, what overrides what |
| **B. Universal Operating Posture** | Radical honesty, objectivity, anti-yes-man, proactive intelligence |
| **C. Communication Compression** | Short responses by default; artifacts as files, not chat dumps |
| **D. Cross-Agent Bootstrap and Fallback** | How to load this skill when native auto-load is not available |
| **E. Prompt Creation and Delegation** | English, file-first, path-specific, unambiguous prompts |
| **F. Project Documentary Workspace** | Baseline folder structure plus operational state layer for formal projects |
| **G. Session Log and Daily Report** | Mandatory hybrid session documentation and daily-report protocol |
| **H. Proactive Reminder Cadence** | Conditional reminders for claude-session-registry, context-guardian, docx-indexer |
| **I. Power BI / DAX Domain Overlay** | DAX/PBI-specific rules activated on relevant work |
| **J. Skill Evolution Governance** | How and when to update this skill |

---

## Hybrid Documentary Model

The current documentary model is hybrid:

- `1 session doc per day + agent`
- never create session docs per project
- every session doc must declare `Context Type: Project|General`
- `Project` must be the real project name or `GENERAL`
- the same session doc may contain multiple `Project` and `General` work blocks
- daily reports remain global by day and must separate `Project Work` and `General Work`
- formal projects may expose these files at the project root:
  - `PROJECT_CONTEXT.md`
  - `status-atual.md`
  - `next-step.md`
  - `decisoes.md`

---

## How It Works

### Auto-Load (Claude Code)

When Claude Code starts, this skill loads automatically with highest priority.

### Cross-Agent Loading (Codex, Gemini, etc.)

For agents without native auto-load:

1. Jimmy provides: `C:\ai\obsidian\CIH\_skills-cross-agent-machines\README.md`
2. The agent reads the router and loads only the needed skills from `C:\ai\claude-intelligence-hub`

### Dynamic Updates

When Jimmy adds or changes a global rule:

1. Update `SKILL.md`
2. Update supporting docs if needed
3. Commit and push
4. Confirm briefly

---

## File Structure

```text
jimmy-core-preferences/
|-- README.md
|-- SKILL.md
|-- CHANGELOG.md
|-- EXECUTIVE_SUMMARY.md
|-- SETUP_GUIDE.md
`-- .metadata
```

---

## Setup

See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for installation instructions.

Quick setup on Windows:

```cmd
cmd /c mklink /J "%USERPROFILE%\.claude\skills\user\jimmy-core-preferences" "C:\ai\claude-intelligence-hub\jimmy-core-preferences"
```

Use Junction points on Windows, not Symbolic Links.

---

## Version History

See [CHANGELOG.md](./CHANGELOG.md) for the detailed history.

**Current Version:** 2.0.1
**Status:** Production
**Last Updated:** 2026-03-12

### Latest Changes in v2.0.1

- Clarified the hybrid session model: `1 session doc per day + agent`, never per project
- Added required `Context Type: Project|General` and `Project` rules
- Added mandatory `Project Work` vs `General Work` split in daily reports
- Added the formal project operational state layer at the project root

### Major Changes in v2.0.0

- Repositioned from a Claude/Xavier-centric master skill to a global cross-agent operating framework
- Added prompt creation and delegation standards
- Added project documentary workspace protocol
- Added session log and daily report protocol
- Added proactive reminder cadence
- Added Power BI / DAX overlay

---

## Related

- [Claude Intelligence Hub](https://github.com/mrjimmyny/claude-intelligence-hub)
- [Cross-Agent Skills README](C:\ai\obsidian\CIH\_skills-cross-agent-machines\README.md)
- [HUB_MAP.md](../HUB_MAP.md)
