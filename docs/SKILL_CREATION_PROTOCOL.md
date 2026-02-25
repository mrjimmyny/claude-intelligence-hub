# 📜 Skill Creation & Governance Protocol
**Version:** 1.0.0
**Status:** ✅ MANDATORY
**Applicable to:** All Elite League Agents (Xavier, Forge, Magneto, Emma, Ciclope)

---

## 🎯 Objective
To ensure 100% repository integrity and eliminate "Red X" (CI/CD failures) on GitHub. This protocol defines the absolute minimum requirements for any new skill or module added to the Claude Intelligence Hub.

---

## 🛠️ The Mandatory Trio (Every Skill)
Every skill folder MUST contain these three files. Absence of any of these will trigger a **Critical Integrity Failure**.

### 1. `.metadata` (JSON/YAML)
Technical identity for routing and versioning.
```json
{
  "name": "skill-name",
  "version": "1.0.0",
  "description": "Short description",
  "status": "production",
  "auto_load": false
}
```

### 2. `SKILL.md` (Markdown)
The "Core Logic". Contains the behavioral instructions for the AI.
- Must include a `Version` field in the header.
- Must use consistent terminology (Glossary).

### 3. `README.md` (Markdown)
The "User Manual".
- Must include: Purpose, Features, Triggers, and Version History.

---

## 📏 The Four Golden Rules of Synchronization

### Rule 1: Single Version Truth
The version string (e.g., `v1.3.0`) MUST be identical in:
1. `<skill>/.metadata`
2. `<skill>/SKILL.md`
3. `<skill>/README.md`
4. `HUB_MAP.md` (Skill Entry)
5. `EXECUTIVE_SUMMARY.md` (Header & Table)

### Rule 2: Naming Integrity
The folder name MUST match the `name` field in `.metadata` exactly. No exceptions.

### Rule 3: Sequential Registry
Every new skill must be added to `HUB_MAP.md` as the next sequential number (e.g., #14, #15), including its Triggers and Loading Tier.

### Rule 4: Global Counter Update
The "Production Skills" count must be incremented in:
1. Root `README.md` (Current Statistics)
2. `EXECUTIVE_SUMMARY.md` (Achievements Table)

### Rule 5: Static Structure (MOVE RESTRICTION)
Agents are STRICTLY FORBIDDEN from moving files or directories without explicit approval. Any structural change must be proposed and approved by Jimmy first.

---

## 🚀 Pre-Commit Checklist (Agent Self-Audit)
Before pushing any change, the agent MUST verify:
- [ ] Folder contains `.metadata`, `SKILL.md`, and `README.md`.
- [ ] Version numbers match in all 5 locations.
- `HUB_MAP.md` is updated with the new skill.
- [ ] Skill count is incremented in root docs.
- [ ] `scripts/integrity-check.sh` (if available) passes locally.

---

## 🚑 Failure Recovery
If a commit fails (Red X):
1. Read the CI/CD log on GitHub.
2. Identify which "Rule" was broken.
3. Apply the **Zero Drift** fix (sync versions).
4. Update `AUDIT_TRAIL.md` with the correction.

---
*Maintained by Forge for the Elite League*
