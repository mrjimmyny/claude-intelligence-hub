---
name: token-economy
version: 1.0.0
description: Adapter skill exposing token governance rules from HUB sources.
---

# token-economy

Version: 1.0.0-adapter
Type: Codex adapter skill
Purpose: Expose Token Economy governance as a Codex-ready skill without modifying HUB source.

## Source of truth (read-only)

- HUB Token Economy README:
  - `token-economy/README.md` under resolved HUB root
- HUB Token Economy Budget Rules:
  - `token-economy/budget-rules.md` under resolved HUB root

## Usage

Apply token-discipline rules from the source documents:

1. Prefer targeted reads over full-file loads.
2. Keep standard responses concise; split very long outputs.
3. Monitor context budget and alert on high usage.
4. Enforce bounded query/loading patterns.

## Notes

- This adapter exists because HUB `token-economy` is not packaged with a root `SKILL.md`.
- Do not edit HUB source files from this adapter.
