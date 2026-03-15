---
name: llmx-auto-learn
version: 1.0.0
description: |
  Auto-learning skill that extracts and injects relevant knowledge from the user's own data at C:\ai into the current agent context. Use this skill proactively whenever:
  - The user invokes /llmxal or /llmx-auto-learn explicitly
  - The user starts a new task and says things like "load my context", "what do we know about X", "give me the background on X", "pick up where we left off", "load context for this project"
  - The user is resuming work after a break and needs to restore domain knowledge
  - The agent would give a meaningfully better response with knowledge from the user's own files (sessions, decisions, manifestos, specs, notes)
  - The user says something like "what have we decided about X", "what's our history with X", "what did we build for X"
  Cross-machine (root C:\ai is identical on all machines). Cross-agent (Claude Code native; other agents via skill-router).
command: /llmx-auto-learn
aliases: [/llmxal]
---

# llmx-auto-learn — Auto-Learning from Personal Knowledge Base

**Version:** 1.0.0
**Alias:** `/llmxal`
**Root data source:** `C:\ai`

---

## What This Skill Does

Every task you work on exists in a broader context of decisions, sessions, specs, and patterns you've already built. This skill bridges the gap between "cold start" and informed, contextual work. When invoked, it:

1. **Reads the task** — understands what the user is trying to do
2. **Hunts for relevant knowledge** — searches `C:\ai` for files related to the task
3. **Extracts key content** — pulls the most relevant sections without loading entire files
4. **Synthesizes a knowledge brief** — a compact, actionable summary of what's already known
5. **Injects the context** — presents the brief before proceeding, so the work is grounded in the user's actual history

Think of it as a distillation pass over your own intellectual capital, applied to the task at hand.

---

## Execution Protocol

### Step 1 — Understand the Task

Read the current user request carefully. Extract:
- **Domain keywords** (project name, technology, concept, person)
- **Task type** (new project, resuming work, decision needed, implementation, question)
- **Urgency** (quick context load vs. deep dive)

### Step 2 — Hunt for Relevant Knowledge

Search `C:\ai` using this priority order. Stop when you have enough context (aim for 3–7 high-quality sources, not exhaustive coverage).

**Priority 1 — Project documents** (most specific to the task):
```
C:\ai\obsidian\CIH\projects\**\PROJECT_CONTEXT.md
C:\ai\obsidian\CIH\projects\**\decisoes.md
C:\ai\obsidian\CIH\projects\**\status-atual.md
C:\ai\obsidian\CIH\projects\**\01-manifesto-contract\*.md
```

**Priority 2 — Session logs** (what actually happened):
```
C:\ai\obsidian\CIH\projects\skills\daily-doc-information\ai-sessions\2026-*\session-*.md
```
Limit to the 3 most recent sessions matching the domain keywords. Read `## Snapshot Atual` and `## Handoff` sections only — skip the full execution logs unless needed.

**Priority 3 — Skills and specs** (what we built):
```
C:\ai\claude-intelligence-hub\**\SKILL.md
C:\ai\_skills\**\*.md
C:\ai\obsidian\CIH\projects\**\03-spec\*.md
```

**Priority 4 — Quick notes** (raw ideas and drafts):
```
C:\ai\obsidian\CIH\quick-notes\*.md
```

**Search strategy:**
- Use Grep with domain keywords across the priority paths above
- Prefer files modified recently (Glob with mtime sort)
- If a keyword hits a large file, read only the relevant sections (not the whole file)

### Step 3 — Extract Without Overloading

From each found file, extract only the high-signal parts:
- **Decision logs:** the decisions themselves, not the rationale unless it's short
- **Status files:** the "Completed" and "In Progress" sections, skip "Blocked" unless relevant
- **Session docs:** `Snapshot Atual` + `Handoff` sections
- **Manifestos:** the executive contract + final decisions sections
- **Skill docs:** the description + purpose sections

Target: extracted knowledge should fit in ~600 tokens total. If you're over, drop the lowest-priority sources.

### Step 4 — Synthesize the Knowledge Brief

Structure the brief as:

```
## Knowledge Brief — [Task Topic]

### What we know
- [Key fact 1] (source: filename)
- [Key fact 2] (source: filename)
- ...

### Relevant decisions already made
- [Decision]: [short rationale] (source: filename)
- ...

### Where we left off (if resuming)
- [Last known state] (source: session-XXXX)

### What's missing / needs confirmation
- [Gap 1]
- ...
```

Keep it tight. The brief is a launching pad, not a report.

### Step 5 — Proceed with the Task

After presenting the brief, immediately continue with what the user asked. Don't wait for the user to say "ok, now do X" — the brief is context injection, not a conversation pause.

If something critical is missing from the knowledge base, call it out in "What's missing" and ask the user the minimum necessary question before proceeding.

---

## Cross-Machine Notes

The root `C:\ai` is the same absolute path on all machines. Use it directly.

For any user-specific paths that come up during execution, resolve dynamically:
- User home: `$env:USERPROFILE` (PowerShell) or `%USERPROFILE%` (cmd)
- Machine ID: `$env:COMPUTERNAME`
- Never hardcode `C:\Users\{username}\` — always derive from env vars

---

## Cross-Agent Compatibility

This skill is natively loaded in Claude Code (auto via `~/.claude/skills/`).

For other agents (Codex, Gemini, Abacus, etc.): trigger via the skill-router protocol.
The skill-router will direct the agent to this skill's SKILL.md and the agent should follow the Execution Protocol above.

The protocol is intentionally LLM-agnostic — any capable agent can follow the Steps 1–5 above using standard file tools (read, grep, glob).

---

## When NOT to Use This Skill

- When the user explicitly says "start fresh" or "ignore previous context"
- When the task is purely generic (no CIH-specific context needed)
- When the user has already loaded context in the current session

---

## Quick Reference

| Trigger | Action |
|---|---|
| `/llmxal` or `/llmx-auto-learn` | Full knowledge extraction for current task |
| "what do we know about X" | Focused search on topic X |
| "load context for [project]" | Priority 1 search on that project |
| "pick up where we left off" | Priority 2 (sessions) first, then Priority 1 |
| "what did we decide about X" | Focus on decisoes.md + manifesto files |

---

## Wikilinks (Obsidian)

[[llmx-auto-learn]] | [[llmxal-manifesto-contract-magneto-2026-03-15-v1.0]] | [[PROJECT_CONTEXT]]
