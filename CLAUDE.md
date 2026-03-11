# Claude Intelligence Hub — Agent Instructions

These rules are MANDATORY for any agent working in this repository.
Claude Code loads this file automatically at the start of every session in this directory.

---

## Version Sync Protocol

**TRIGGER:** Any time you modify a skill's `SKILL.md`, `.metadata`, scripts, or documentation inside a skill directory — automatically follow these steps. Do not wait to be asked.

### Step-by-step (always in this order):

1. **Update `.metadata` first** (this is the source of truth for version)
2. **Run sync script** — syncs `SKILL.md` and `HUB_MAP.md` automatically:
   ```bash
   bash scripts/sync-versions.sh <skill-name>
   ```
3. **Add entry to `CHANGELOG.md`** under a new hub version `[X.Y.Z] - YYYY-MM-DD`
4. **Update hub version** in `README.md` (version badge + skill table + file tree references)
5. **Update hub version** in `EXECUTIVE_SUMMARY.md` (Version header + Component Versions line + document footer)
6. **Run integrity check locally** — must show 6/6 PASSED before committing:
   ```bash
   bash scripts/integrity-check.sh
   ```
7. **Commit everything in a single commit** using the format:
   ```
   chore(release): bump hub to vX.Y.Z + <skill> to vA.B.C
   ```

### Hub version bump rules:

| Change type | Bump |
|-------------|------|
| Bug fix, doc update, tooling | Patch (Z) |
| Skill version bump, new feature in existing skill | Patch (Z) |
| New skill added | Minor (Y) |
| Breaking change, skill removed, major protocol change | Major (X) |

---

## Files That Must Stay in Sync

Every skill version change requires updating ALL of these:

| File | What to update |
|------|----------------|
| `<skill>/.metadata` | `version` field (source of truth) |
| `<skill>/SKILL.md` | `**Version:**` line in body |
| `HUB_MAP.md` | version reference next to skill name |
| `CHANGELOG.md` | new `[hub-version]` entry with description |
| `README.md` | version badge, skill table row, file tree comment |
| `EXECUTIVE_SUMMARY.md` | `Version:` header, `Component Versions:` line, footer version |

---

## Before Every Commit

ALWAYS run the integrity check before committing. Never skip this:

```bash
bash scripts/integrity-check.sh
```

Must show: `✅ Passed: 6 | ❌ Failed: 0`

If it fails: **do not commit**. Fix the version drift or missing files first.

---

## Validation Phrases — What the User Might Say

Users and agents may trigger validation using natural language. When you hear any of these, execute the corresponding action immediately without asking for confirmation:

| User says | You do |
|-----------|--------|
| `"Run the hub integrity check"` | `bash scripts/integrity-check.sh` — report 6 checks pass/fail |
| `"Run integrity check and confirm CI is passing"` | Run the script above + `gh run list --limit 3` to show GitHub Actions status |
| `"Is the repo clean?"` / `"Is everything green?"` | Same as "Run the hub integrity check and confirm CI" |
| `"Run repo-auditor"` | Invoke `/repo-auditor --mode AUDIT_AND_FIX` |
| `"Check everything before release"` | Run integrity check + repo-auditor, report both results |

**Key distinction to always remember:**
- `integrity-check.sh` = structural/version validation (fast, CI-level, runs in seconds)
- `repo-auditor` = deep content audit (thorough, skill-level, takes longer)

They are complementary, not the same tool.

---

## Adding a Root-Level File

The integrity check enforces an approved list of root files. If you need to add a new file to the root:

1. Add the filename to the `approved_files` array in `scripts/integrity-check.sh` (keep alphabetical)
2. Add the file
3. Run `bash scripts/integrity-check.sh` to confirm it passes
4. Commit both changes together

---

## docx-indexer Routing

When the user mentions any of these phrases, use the `docx-indexer` skill to query or operate on `docx-index.json`:

- "índice de documentos" / "índice de arquivos" / "document index"
- "consulta o índice" / "check the index"
- "onde está o arquivo X" / "where is file X" / "find file X"
- "atualiza o índice" / "update the index" / "scan the workspace"
- "quantos arquivos" / "how many files"
- "lista os arquivos" / "list files"
- "summary do arquivo" / "file summary" / "keywords do arquivo"
- "enriquece o indice" / "enrich the index"

**Index location:** `C:\ai\_skills\docx-indexer\index\docx-index.json`
**Scripts location:** `C:\ai\_skills\docx-indexer\scripts\`

For queries (find, list, count, summary, keywords), read `docx-index.json` directly - no need to run scripts.
For scan updates, run `scan.py`. For enrichment updates, run `enrich.py`. For integrity checks, run `validate.py`.

---

## Script Conventions (PowerShell)

When editing `.ps1` scripts that run on PowerShell 5.1:

- **No emoji characters** — they cause parse errors in PS 5.1
- **Variable colon ambiguity** — use `${VarName}:` not `$VarName:` inside double-quoted strings
- **Skills location** — always `~/.claude/skills/` root, never `skills/user/` subdirectory
- **Windows junctions** — use `New-Item -ItemType Junction` or `cmd /c mklink /J`, never `New-Item -ItemType SymbolicLink`
