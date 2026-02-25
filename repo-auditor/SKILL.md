---
name: repo-auditor
description: Deterministic deep repository audit protocol for content, consistency, and completeness. Use when an audit must be reproducible across agents with literal bash commands, strict checkpoints, recovery gates, and verified release publication.
command: /repo-auditor
aliases: [/audit, /repo-audit, /validate]
---

# Repo Auditor
**Version:** 2.0.0

## Objective
Transform repository audits from surface checks into deep protocol execution:
- Content validation
- Cross-file consistency checks
- Completeness and release verification

Use the principle: `Rigor without rigidity`.

## Fixed Glossary (Mandatory)

| Term | Definition |
|---|---|
| `PHASE` | Mandatory sequential stage of the audit protocol. |
| `CHECKPOINT` | Gate at the end of each `PHASE` that decides if progression is allowed. |
| `PASS` | Objective criterion satisfied with command evidence. |
| `FAIL` | Objective criterion not satisfied. |
| `WARNING` | Non-blocking divergence that must be logged and reported. |
| `CRITICAL ERROR` | `FAIL` in content, cross-file, or release validation; blocks progression. |
| `BLOCKED` | Audit state that cannot proceed until recovery is completed. |
| `RECOVERED` | A `CRITICAL ERROR` that was auto-fixed and re-validated successfully. |
| `SAVE` | Persisted state at the end of each phase to support resume flow. |

## Cross-Agent Principles (Mandatory)

1. Use explicit instructions, never implicit instructions.
2. Use literal bash commands whenever possible.
3. Require mandatory checkpoints with gate logic.
4. Declare absolute prohibitions with no ambiguity.
5. Generate verifiable fingerprints with content hashes (`git hash-object`).
6. Keep naming consistent with the fixed glossary.
7. Run a cross-agent sanity test:
If Claude, Gemini, and Codex execute the same instructions, they must produce the same result.

## Execution Modes (Set in PHASE 0)

| Mode | Description | File modifications | Release publication |
|---|---|---|---|
| `AUDIT_AND_FIX` | Audit and auto-fix trivial issues | Yes | Yes |
| `AUDIT_ONLY` | Audit and report only | No | No |
| `DRY_RUN` | Simulate the audit and log intended actions | No | No |

Default mode: `AUDIT_AND_FIX`.

## Mandatory Critical Files (Set in PHASE 0)

Absence of required files is a `CRITICAL ERROR`.

Required:
- `README.md` (repository root)
- `CHANGELOG.md`
- `AUDIT_TRAIL.md`
- `HUB_MAP.md` (if applicable for repository type)
- `<SKILL_DIR>/.metadata` for each skill
- `<SKILL_DIR>/SKILL.md` for each skill
- `<SKILL_DIR>/README.md` for each skill

Expected (absence is `WARNING`):
- `LICENSE` or `LICENSE.md`
- `.gitignore`
- `EXECUTIVE_SUMMARY.md` (if referenced by another document)

The agent may add files to the critical list when context requires it.
The agent may not remove files from the base list above.

## Recovery Protocol (When State = `BLOCKED`)

1. Log phase, checkpoint, exact error, and timestamp in `AUDIT_TRAIL.md`.
2. Auto-fix only if all conditions are true:
- The fix is trivial (number update, version correction, list completion).
- The fix does not alter repository logic or structure.
3. After any auto-fix:
- Re-generate fingerprint for the corrected file.
- Re-run all validations that apply to that file.
- Verify no unrelated file changed.
- If the fix introduces a new error, revert the fix and report.
4. If checkpoint passes after fix, log status as `RECOVERED`.
5. If fix is not trivial, stop and report:
- Exact error description
- Location (`file:line`)
- Proposed correction
- Await user instruction
6. Never move to next phase with unresolved `BLOCKED` state.

## Global Execution Rules

### Bash Error Handling
- Inspect exit code for every command.
- If exit code is non-zero and not expected:
1. Log command, exit code, and stderr to `AUDIT_TRAIL.md`.
2. Diagnose root cause (`command not found`, missing file, permission, etc.).
3. If command is critical for validation: set `BLOCKED`.
4. If command is auxiliary: log `WARNING` and continue with a documented fallback.
- Never ignore empty output when non-empty output is expected.

### Scope Protection
- Audit only files inside PHASE 0 scope.
- For out-of-scope issues:
1. Log as `OUT_OF_SCOPE`.
2. Do not modify.
3. Report as recommendation.
- Do not modify CI/CD, runtime configs, source code, or tests unless explicitly included in scope.

### Post-Fix Revalidation
After any automated correction:
1. Recompute fingerprint with hash.
2. Re-run every applicable validation.
3. Verify no unrelated file changed.
4. Revert and report if a new error appears.

## Required Protocol Phases

### PHASE 0: Scope and Preparation
Objective: define audit parameters and validate preconditions.

#### 0.1 Register audit parameters
Record this block in `AUDIT_TRAIL.md`:
```yaml
target_repo: <name>
target_version: <vX.Y.Z>
audit_date: <YYYY-MM-DD>
audit_agent: <AGENT_NAME> (<MODEL_ID>)
audit_mode: <AUDIT_AND_FIX | AUDIT_ONLY | DRY_RUN>
```

#### 0.2 Validate branch
Command:
```bash
git branch --show-current
```
Criteria:
- `PASS`: current branch is `main` or explicitly approved branch.
- `FAIL`: feature/hotfix branch without explicit authorization -> `BLOCKED`.

#### 0.3 Validate repository state
Commands:
```bash
git status --porcelain
git fetch origin && git rev-list --left-right --count HEAD...origin/main
```
Criteria:
- `PASS`: clean working tree.
- `WARNING`: working tree changes or local/remote divergence.

#### 0.4 Validate GitHub auth (if release required)
Command:
```bash
gh auth status
```
Criteria:
- `PASS`: authenticated.
- `FAIL`: unauthenticated with mode not in `AUDIT_ONLY` or `DRY_RUN` -> `BLOCKED`.

#### 0.5 Build critical file list
Use base required and expected lists.
Add repository-specific files if needed.
Record final list in `AUDIT_TRAIL.md`.

#### CHECKPOINT 0
Criteria:
- Branch validated: `PASS` or `FAIL`
- GitHub auth validated (if applicable): `PASS` or `FAIL`
- Critical file list declared: `YES` or `NO`
Gate:
- Any `FAIL` => `BLOCKED`

#### CHECKPOINT 0.SAVE
```yaml
phase_completed: 0
timestamp: <YYYY-MM-DD HH:MM>
status: <PASS | BLOCKED>
```

### PHASE 1: Inventory and Reading
Objective: list tracked files, generate fingerprints, guarantee complete file access.

#### 1.1 List tracked files
Primary command:
```bash
git ls-files > /tmp/repo_files.txt
wc -l /tmp/repo_files.txt
```
Fallback:
```bash
rg --files --glob "!.git/" --glob "!node_modules/" --glob "!.venv/" > /tmp/repo_files.txt
```
Record tracked file count in `AUDIT_TRAIL.md`.

#### 1.2 Generate fingerprints for each critical file
Run for each critical file:
```bash
wc -l <FILE>
head -n 1 <FILE>
tail -n 1 <FILE>
git hash-object <FILE>
```
Record:
```yaml
- file: <FILE>
  total_lines: <N>
  first_line: "<TEXT>"
  last_line: "<TEXT>"
  content_hash: <SHA>
```

#### 1.3 Validate existence of critical files
Command per file:
```bash
test -f <FILE> && echo "EXISTS" || echo "MISSING"
```
Criteria:
- Missing required file -> `CRITICAL ERROR` -> `BLOCKED`
- Missing expected file -> `WARNING`

#### 1.4 Validate encoding
Command per critical file:
```bash
file --mime-encoding <FILE>
```
Criteria:
- `PASS`: `utf-8` or `us-ascii`
- `WARNING`: any other encoding

#### CHECKPOINT 1
Criteria:
- All required critical files exist: `PASS` or `FAIL`
- Fingerprints generated for all critical files: `YES` or `NO`
Gate:
- Any missing required file => `CRITICAL ERROR` => `BLOCKED`

#### CHECKPOINT 1.SAVE
```yaml
phase_completed: 1
timestamp: <YYYY-MM-DD HH:MM>
status: <PASS | PASS_WITH_WARNINGS | BLOCKED>
files_fingerprinted: <count>
warnings_count: <N>
```

### PHASE 1.2: Structural Per-File Validation
Objective: validate required structure for each critical file.
Do not perform semantic content checks in this phase.

#### 1.2.1 Validate root `README.md`
Commands:
```bash
rg -c "^## " README.md
rg -n "^## " README.md
rg -n "v[0-9]+\.[0-9]+\.[0-9]+" README.md
```
Required structure:
- Main title at line 1 (`# `)
- Skill table section (`Available Skills` or equivalent)
- Architecture section (`Hub Architecture` or equivalent)
- Declared version matches target audit version
Criteria:
- Missing section or mismatched version => `CRITICAL ERROR`

#### 1.2.2 Validate `CHANGELOG.md`
Commands:
```bash
rg -n "^## \[${VERSION}\]" CHANGELOG.md
rg -n "^## \[${VERSION}\].*[0-9]{4}-[0-9]{2}-[0-9]{2}" CHANGELOG.md
```
Criteria:
- Missing target version entry => `CRITICAL ERROR`
- Missing date format => `WARNING`

#### 1.2.3 Validate `.metadata` files for all skills
Commands for each `<SKILL_PATH>/.metadata`:
```bash
rg -n "^name:\s*\S+" <SKILL_PATH>/.metadata
rg -n "^version:\s*\S+" <SKILL_PATH>/.metadata
rg -n "^status:\s*\S+" <SKILL_PATH>/.metadata
rg -n "^description:\s*\S+" <SKILL_PATH>/.metadata
```
Cross-check metadata name vs directory:
```bash
METADATA_NAME=$(rg -o "^name:\s*(.+)" <SKILL_PATH>/.metadata -r '$1' | tr -d ' ')
DIR_NAME=$(basename <SKILL_PATH>)
echo "metadata_name=${METADATA_NAME} dir_name=${DIR_NAME}"
```
Criteria:
- Any missing or empty mandatory field => `CRITICAL ERROR`
- Semantic mismatch between metadata name and directory => `WARNING`

#### 1.2.4 Validate other critical files
Commands:
```bash
wc -l <FILE>
head -n 1 <FILE>
```
Criteria:
- Empty required file or invalid markdown header in required `.md` file => `CRITICAL ERROR`
- Same issue in expected file => `WARNING`

#### 1.2.5 Validate slash command definitions
Objective: Ensure ALL skills have slash commands defined and command documentation is synchronized.

**Critical Issue This Addresses:**
This validation prevents skills from being created without slash command definitions, ensuring consistent CLI access across all skills.

**Part A: Validate SKILL.md frontmatter contains command definitions**

For each skill directory:
```bash
skill_dir="<SKILL_PATH>"
skill_name=$(basename "$skill_dir")

# Check if SKILL.md exists
if [ ! -f "${skill_dir}/SKILL.md" ]; then
  echo "❌ MISSING: ${skill_name}/SKILL.md does not exist"
  exit 1
fi

# Check for frontmatter with command definition
if ! grep -q "^command:" "${skill_dir}/SKILL.md"; then
  echo "❌ MISSING COMMAND: ${skill_name}/SKILL.md lacks 'command:' in frontmatter"
fi
```

Record missing commands:
```bash
: > /tmp/skills_missing_commands.txt
for skill_dir in */; do
  if [[ -f "${skill_dir}.metadata" ]]; then
    skill_name=$(basename "$skill_dir" /)
    if ! grep -q "^command:" "${skill_dir}SKILL.md" 2>/dev/null; then
      echo "$skill_name" >> /tmp/skills_missing_commands.txt
    fi
  fi
done

MISSING_COMMANDS=$(wc -l < /tmp/skills_missing_commands.txt | tr -d ' ')
```

Criteria:
- `PASS` if `MISSING_COMMANDS == 0`
- Otherwise: `CRITICAL ERROR` => `BLOCKED`

**Part B: Validate command mapping documentation synchronization**

Extract commands from SKILL.md frontmatter:
```bash
: > /tmp/skill_commands_actual.tsv
for skill_dir in */; do
  if [[ -f "${skill_dir}.metadata" ]]; then
    skill_name=$(basename "$skill_dir" /)
    command=$(grep "^command:" "${skill_dir}SKILL.md" 2>/dev/null | sed 's/command: *//; s/"//g')

    if [ -n "$command" ]; then
      echo -e "${skill_name}\t${command}" >> /tmp/skill_commands_actual.tsv
    fi
  fi
done
```

Extract commands from HUB_MAP.md:
```bash
grep "| \*\*" HUB_MAP.md | grep -o "| \`/[^`]*\`" | sed 's/| `//; s/`//' | sort > /tmp/hub_map_commands.txt
```

Extract commands from README.md Quick Commands section:
```bash
awk '/^## 🎮 Quick Commands/,/^---/' README.md | grep "| \*\*" | grep -o "| \`/[^`]*\`" | sed 's/| `//; s/`//' | sort > /tmp/readme_commands.txt
```

Extract commands from COMMANDS.md:
```bash
grep "| \`/" COMMANDS.md | grep -o "\`/[^`]*\`" | sed 's/`//g' | sort -u > /tmp/commands_md_list.txt
```

Cross-validate:
```bash
TOTAL_SKILLS=$(wc -l < /tmp/skill_commands_actual.tsv | tr -d ' ')
HUB_MAP_COUNT=$(wc -l < /tmp/hub_map_commands.txt | tr -d ' ')
README_COUNT=$(wc -l < /tmp/readme_commands.txt | tr -d ' ')
COMMANDS_MD_COUNT=$(wc -l < /tmp/commands_md_list.txt | tr -d ' ')

echo "Skill commands defined: ${TOTAL_SKILLS}"
echo "HUB_MAP.md commands: ${HUB_MAP_COUNT}"
echo "README.md commands: ${README_COUNT}"
echo "COMMANDS.md commands: ${COMMANDS_MD_COUNT}"
```

Criteria:
- `PASS` if all counts match: `TOTAL_SKILLS == HUB_MAP_COUNT == README_COUNT == COMMANDS_MD_COUNT`
- Mismatch => `CRITICAL ERROR` (command documentation out of sync)

**Part C: Validate command uniqueness (no duplicates)**

```bash
cut -f2 /tmp/skill_commands_actual.tsv | sort | uniq -d > /tmp/duplicate_commands.txt
DUPLICATE_COUNT=$(wc -l < /tmp/duplicate_commands.txt | tr -d ' ')

if [ "$DUPLICATE_COUNT" -gt 0 ]; then
  echo "❌ DUPLICATE COMMANDS FOUND:"
  cat /tmp/duplicate_commands.txt
fi
```

Criteria:
- `PASS` if `DUPLICATE_COUNT == 0`
- Otherwise: `CRITICAL ERROR` (command collision)

Recovery (if mode is `AUDIT_AND_FIX`):
- For Part A (missing commands): Cannot auto-fix (requires human decision on command name)
- For Part B (doc sync): Can auto-fix by regenerating command tables in HUB_MAP, README, COMMANDS.md
- For Part C (duplicates): Cannot auto-fix (requires human resolution)

Record:
```yaml
slash_command_validation:
  skills_total: <N>
  skills_missing_commands: <N>
  missing_command_list:
    - skill: <name>
  command_doc_sync:
    hub_map: <N>
    readme: <N>
    commands_md: <N>
    status: <PASS | FAIL>
  duplicate_commands: <N>
  status: <PASS | FAIL>
```

#### 1.2.6 Validate root file authorization
Objective: Ensure ALL files in repository root are explicitly approved to prevent clutter and maintain organization.

**Critical Issue This Addresses:**
This validation prevents unauthorized files from being added to the repository root, enforcing the Zero Tolerance policy for root file clutter. This is the same check performed by `scripts/integrity-check.sh` CHECK 3.

**Part A: Extract approved files list from integrity-check.sh**

```bash
# Extract approved_files array from scripts/integrity-check.sh
APPROVED_LIST=$(sed -n '/^approved_files=(/,/^)/p' scripts/integrity-check.sh | \
  grep -v '^approved_files=(' | \
  grep -v '^)' | \
  sed 's/[" ]//g' | \
  sort > /tmp/approved_root_files.txt)

APPROVED_COUNT=$(wc -l < /tmp/approved_root_files.txt | tr -d ' ')
echo "Approved root files: ${APPROVED_COUNT}"
```

**Part B: Find all actual root files**

```bash
# List all files in root (excluding directories and hidden files)
: > /tmp/actual_root_files.txt
for file in *.md *.txt LICENSE .gitignore; do
  if [ -f "$file" ]; then
    echo "$file" >> /tmp/actual_root_files.txt
  fi
done

ACTUAL_COUNT=$(wc -l < /tmp/actual_root_files.txt | tr -d ' ')
echo "Actual root files: ${ACTUAL_COUNT}"
```

**Part C: Detect unauthorized files**

```bash
: > /tmp/unauthorized_root_files.txt
while IFS= read -r actual_file; do
  if ! grep -q "^${actual_file}$" /tmp/approved_root_files.txt; then
    echo "$actual_file" >> /tmp/unauthorized_root_files.txt
    echo "❌ UNAUTHORIZED: ${actual_file} (not in scripts/integrity-check.sh approved_files)"
  fi
done < /tmp/actual_root_files.txt

UNAUTHORIZED_COUNT=$(wc -l < /tmp/unauthorized_root_files.txt | tr -d ' ')
```

**Part D: Detect orphaned approved files**

```bash
: > /tmp/orphaned_approved_files.txt
while IFS= read -r approved_file; do
  if [ ! -f "$approved_file" ]; then
    echo "$approved_file" >> /tmp/orphaned_approved_files.txt
    echo "⚠️ ORPHAN: ${approved_file} (in approved list but file doesn't exist)"
  fi
done < /tmp/approved_root_files.txt

ORPHANED_COUNT=$(wc -l < /tmp/orphaned_approved_files.txt | tr -d ' ')
```

Criteria:
- `PASS` if `UNAUTHORIZED_COUNT == 0`
- `WARNING` if `ORPHANED_COUNT > 0` (cleanup approved list)
- Otherwise: `CRITICAL ERROR` (unauthorized root files)

Recovery (if mode is `AUDIT_AND_FIX`):
- Cannot auto-fix unauthorized files (requires human decision: approve or delete)
- Can auto-fix orphaned entries by removing from approved_files array

Record:
```yaml
root_file_validation:
  approved_count: <N>
  actual_count: <N>
  unauthorized_count: <N>
  unauthorized_files:
    - file: <name>
  orphaned_approved_count: <N>
  orphaned_approved_files:
    - file: <name>
  status: <PASS | FAIL | WARNING>
  fix_instruction: "Add to scripts/integrity-check.sh approved_files array"
```

#### CHECKPOINT 1.2
Criteria:
- `README.md` structure validated: `PASS` or `FAIL`
- `CHANGELOG.md` target version entry exists: `PASS` or `FAIL`
- `.metadata` mandatory fields complete for all skills: `PASS` or `FAIL`
- Slash command definitions present in all skills: `PASS` or `FAIL`
- Command documentation synchronized (HUB_MAP, README, COMMANDS.md): `PASS` or `FAIL`
- No duplicate command definitions: `PASS` or `FAIL`
- Root file authorization validated: `PASS` or `FAIL` or `WARNING`
Gate:
- Any `FAIL` in required file => `CRITICAL ERROR` => `BLOCKED`

#### CHECKPOINT 1.2.SAVE
```yaml
phase_completed: 1.2
timestamp: <YYYY-MM-DD HH:MM>
status: <PASS | PASS_WITH_WARNINGS | BLOCKED>
```

### PHASE 1.5: Content and Cross-File Consistency Validation
Objective: compare declared repository state against actual state.
This is the core phase and must include all seven validations below.

#### 1.5.1 Skill count (`README.md` vs repository)
Count real skills:
```bash
REAL_COUNT=$(find . -maxdepth 2 -name ".metadata" | grep -v "^\./\." | wc -l | tr -d ' ')
echo "REAL_COUNT=${REAL_COUNT}"
```
Extract declared count with semantic context:
```bash
DECLARED_LINE=$(rg -n "\b[0-9]+\s+(production\s+)?skills?\b" README.md | head -n 1)
echo "DECLARED_LINE=${DECLARED_LINE}"
DECLARED_COUNT=$(echo "$DECLARED_LINE" | rg -o "\b[0-9]+\b" | head -n 1)
echo "DECLARED_COUNT=${DECLARED_COUNT}"
```
If no contextual line is found:
1. Read full `README.md`.
2. Locate the explicit skill-count declaration line manually.
3. Extract number with semantic context.
4. Record exact line in `AUDIT_TRAIL.md`.
5. Do not use raw first-number extraction.

Criteria:
- `PASS` if `REAL_COUNT == DECLARED_COUNT`
- Otherwise: `CRITICAL ERROR`

Record:
```yaml
skill_count_validation: <PASS | FAIL>
real_count: <N>
declared_count: <N>
declared_line: "<full line text>"
```

#### 1.5.2 Version cross-check (`README` table vs `.metadata`)
Extract declared table entries:
```bash
rg -n "^\|\s*[a-zA-Z0-9._-]+\s*\|\s*v[0-9]+\.[0-9]+\.[0-9]+\s*\|" README.md > /tmp/readme_skill_versions_raw.txt
awk -F'|' '{gsub(/[ \t]/,"",$2); gsub(/[ \t]/,"",$3); print $2 "\t" $3}' /tmp/readme_skill_versions_raw.txt | sort -u > /tmp/readme_skill_versions.tsv
```
Compare each entry with metadata:
```bash
while IFS=$'\t' read -r SKILL_NAME TABLE_VERSION; do
  META_FILE="./${SKILL_NAME}/.metadata"
  META_VERSION=$(rg -o "^version:\s*(.+)" "${META_FILE}" -r '$1' | tr -d ' ')
  echo -e "${SKILL_NAME}\t${TABLE_VERSION}\t${META_VERSION}"
done < /tmp/readme_skill_versions.tsv > /tmp/version_crosscheck.tsv
```
Criteria:
- `PASS` if all table versions match `.metadata` versions.
- Any mismatch => `CRITICAL ERROR`.

Record each skill:
```yaml
- skill: <name>
  table_version: <vX.Y.Z>
  metadata_version: <vX.Y.Z>
  status: <PASS | FAIL>
```

#### 1.5.3 Architecture completeness (`README` tree vs repository)
Repository skills:
```bash
find . -maxdepth 2 -name ".metadata" | sed 's|/\.metadata||' | sed 's|^\./||' | sort > /tmp/skills_repo.txt
```
`README` architecture tree skills:
```bash
rg -n "Hub Architecture" README.md -A 200 | rg -o "[a-zA-Z0-9._-]+/" | sed 's|/||' | sort -u > /tmp/skills_tree.txt
```
Compare:
```bash
diff -u /tmp/skills_repo.txt /tmp/skills_tree.txt > /tmp/skills_architecture.diff || true
```
Criteria:
- Empty diff => `PASS`
- Non-empty diff => `CRITICAL ERROR`

Record full diff in `AUDIT_TRAIL.md`.

#### 1.5.4 Reference accuracy (version references in docs)
Map version references:
```bash
rg -n "v[0-9]+\.[0-9]+\.[0-9]+" . --glob "*.md" > /tmp/version_references.txt
```
For each reference that includes both target file and version:
1. Open referenced file.
2. Extract live version from referenced file.
3. Compare cited version vs live version.

Criteria:
- All references correct => `PASS`
- Any mismatch => `CRITICAL ERROR`

#### 1.5.5 Orphan file detection
List markdown files:
```bash
find . -name "*.md" -not -path "./.git/*" | sort > /tmp/all_docs.txt
```
Detect orphan documents:
```bash
while IFS= read -r FILE; do
  BASENAME=$(basename "$FILE")
  REFS=$(rg -l "$BASENAME" . --glob "*.md" | grep -v "^${FILE}$" | wc -l)
  if [ "$REFS" -eq 0 ]; then
    echo "ORPHAN:${FILE}"
  fi
done < /tmp/all_docs.txt > /tmp/orphans.txt
```
Known non-orphan exceptions:
- `LICENSE`
- `LICENSE.md`
- `.gitignore`
- root `README.md`
- `CHANGELOG.md`
- `AUDIT_TRAIL.md`

Criteria:
- Unexpected orphans => `WARNING`
- Not automatically `CRITICAL ERROR`

#### 1.5.6 Internal link validation
Extract markdown links:
```bash
rg -n "\[[^\]]+\]\(([^)]+)\)" . --glob "*.md" > /tmp/internal_links_raw.txt
```
Validate targets:
```bash
: > /tmp/broken_links.txt
while IFS= read -r ROW; do
  SRC_FILE=$(echo "$ROW" | cut -d: -f1)
  TARGET=$(echo "$ROW" | sed -E 's/.*\]\(([^)]+)\).*/\1/')
  if echo "$TARGET" | rg -q "^(http|https|mailto):"; then
    continue
  fi
  TARGET_PATH="${TARGET%%#*}"
  TARGET_PATH="${TARGET_PATH%%\?*}"
  if [ -z "$TARGET_PATH" ]; then
    continue
  fi
  SRC_DIR=$(dirname "$SRC_FILE")
  if [ ! -e "$SRC_DIR/$TARGET_PATH" ] && [ ! -e "$TARGET_PATH" ]; then
    echo "${SRC_FILE}|${TARGET}" >> /tmp/broken_links.txt
  fi
done < /tmp/internal_links_raw.txt
```
Criteria:
- Broken link to critical file => `CRITICAL ERROR`
- Broken link to non-critical file => `WARNING`

#### 1.5.7 `CHANGELOG.md` completeness
Check release section content:
```bash
awk "/^## \[${VERSION}\]/{found=1; next} /^## \[/{found=0} found" CHANGELOG.md | rg "^- " | wc -l
```
Criteria:
- `PASS` if at least one bullet exists in target version entry.
- Empty target version entry => `CRITICAL ERROR`.

Cross-check correction coverage:
- If audit made corrections, ensure each correction is represented in target changelog section.
- Record corrected-items count vs changelog-items count.

#### 1.5.8 `EXECUTIVE_SUMMARY.md` Component Versions completeness
Objective: Validate that ALL skills in repository are documented in `EXECUTIVE_SUMMARY.md` Component Versions line.

**Critical Issue This Addresses:**
This validation was the missing gap that allowed 3 skills (`xavier-memory-sync`, `token-economy`, `codex-governance-framework`) to be absent from EXECUTIVE_SUMMARY.md Component Versions, causing CI/CD failures.

List all skills in repository:
```bash
find . -maxdepth 2 -name ".metadata" -not -path "./.git/*" | sed 's|/\.metadata||' | sed 's|^\./||' | sort > /tmp/repo_skills_list.txt
REPO_SKILL_COUNT=$(wc -l < /tmp/repo_skills_list.txt | tr -d ' ')
echo "Repository has ${REPO_SKILL_COUNT} skills"
```

Extract Component Versions line from EXECUTIVE_SUMMARY.md:
```bash
COMPONENT_LINE=$(grep "^\*\*Component Versions:\*\*" EXECUTIVE_SUMMARY.md)
echo "Component Versions line: ${COMPONENT_LINE}"
```

For each skill, validate it appears in Component Versions:
```bash
: > /tmp/missing_skills_in_executive.txt
while IFS= read -r skill_dir; do
  metadata_file="${skill_dir}/.metadata"
  if [ -f "$metadata_file" ]; then
    skill_version=$(grep '"version"' "$metadata_file" | sed 's/.*"version": *"\([^"]*\)".*/\1/')
    skill_name=$(basename "$skill_dir")

    # Check if version appears in Component Versions line
    if ! echo "$COMPONENT_LINE" | grep -q "v${skill_version}"; then
      echo "${skill_name}|v${skill_version}" >> /tmp/missing_skills_in_executive.txt
      echo "❌ MISSING: ${skill_name} v${skill_version} not in EXECUTIVE_SUMMARY Component Versions"
    fi
  fi
done < /tmp/repo_skills_list.txt
```

Count missing skills:
```bash
MISSING_COUNT=$(wc -l < /tmp/missing_skills_in_executive.txt 2>/dev/null | tr -d ' ')
echo "Missing skills in EXECUTIVE_SUMMARY: ${MISSING_COUNT}"
```

Criteria:
- `PASS` if `MISSING_COUNT == 0`
- Otherwise: `CRITICAL ERROR` => `BLOCKED`

Recovery (if mode is `AUDIT_AND_FIX`):
If missing skills detected:
1. Read current Component Versions line
2. For each missing skill, append formatted name and version
3. Rewrite EXECUTIVE_SUMMARY.md with updated Component Versions line
4. Re-validate to confirm all skills now present
5. Log correction in AUDIT_TRAIL.md

Recovery commands:
```bash
if [ "$MISSING_COUNT" -gt 0 ] && [ "$AUDIT_MODE" = "AUDIT_AND_FIX" ]; then
  echo "Auto-fixing EXECUTIVE_SUMMARY.md Component Versions..."

  # Build the additions string
  ADDITIONS=""
  while IFS='|' read -r skill_name skill_version; do
    # Format skill name: convert hyphens to spaces and capitalize each word
    formatted_name=$(echo "$skill_name" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
    ADDITIONS="${ADDITIONS}, ${formatted_name} ${skill_version}"
  done < /tmp/missing_skills_in_executive.txt

  # Update the Component Versions line
  OLD_LINE=$(grep "^\*\*Component Versions:\*\*" EXECUTIVE_SUMMARY.md)
  NEW_LINE="${OLD_LINE}${ADDITIONS}"

  # Create backup
  cp EXECUTIVE_SUMMARY.md EXECUTIVE_SUMMARY.md.backup

  # Apply fix
  sed -i.bak "s|^\\*\\*Component Versions:\\*\\*.*|${NEW_LINE}|" EXECUTIVE_SUMMARY.md

  # Re-validate
  COMPONENT_LINE=$(grep "^\*\*Component Versions:\*\*" EXECUTIVE_SUMMARY.md)
  STILL_MISSING=0
  while IFS= read -r skill_dir; do
    skill_version=$(grep '"version"' "${skill_dir}/.metadata" | sed 's/.*"version": *"\([^"]*\)".*/\1/')
    if ! echo "$COMPONENT_LINE" | grep -q "v${skill_version}"; then
      STILL_MISSING=$((STILL_MISSING + 1))
    fi
  done < /tmp/repo_skills_list.txt

  if [ "$STILL_MISSING" -eq 0 ]; then
    echo "✅ RECOVERED: All skills now in EXECUTIVE_SUMMARY Component Versions"
    rm EXECUTIVE_SUMMARY.md.backup
  else
    echo "❌ RECOVERY FAILED: ${STILL_MISSING} skills still missing after fix"
    mv EXECUTIVE_SUMMARY.md.backup EXECUTIVE_SUMMARY.md
    exit 1
  fi
fi
```

Record:
```yaml
executive_summary_validation:
  repo_skill_count: <N>
  missing_in_component_versions: <N>
  missing_skills:
    - skill: <name>
      version: <vX.Y.Z>
  status: <PASS | FAIL | RECOVERED>
```

#### CHECKPOINT 1.5
Criteria:
- Skill count: `PASS` or `FAIL`
- Version cross-check: `PASS` or `FAIL`
- Architecture completeness: `PASS` or `FAIL`
- Reference accuracy: `PASS` or `FAIL`
- Internal links: `PASS` or `WARNING` or `FAIL`
- EXECUTIVE_SUMMARY Component Versions completeness: `PASS` or `FAIL` or `RECOVERED`
Gate:
- Any `FAIL` => `CRITICAL ERROR` => `BLOCKED`

#### CHECKPOINT 1.5.SAVE
```yaml
phase_completed: 1.5
timestamp: <YYYY-MM-DD HH:MM>
status: <PASS | PASS_WITH_WARNINGS | BLOCKED>
warnings_count: <N>
critical_errors_count: <N>
orphan_files_count: <N>
broken_links_count: <N>
```

### PHASE 2: Spot Check and Sampling
Objective: detect gaps not covered by deterministic checks.

#### 2.1 Build sample
Commands:
```bash
TOTAL=$(wc -l < /tmp/repo_files.txt)
N_PERCENT=$((TOTAL / 10))
N=$(( N_PERCENT > 10 ? N_PERCENT : 10 ))
sort --random-sort /tmp/repo_files.txt | head -n "$N" > /tmp/spot_check.txt
```
Fallback if `sort --random-sort` is unavailable:
```bash
shuf /tmp/repo_files.txt | head -n "$N" > /tmp/spot_check.txt
```

#### 2.2 Validate each sampled file
For each file in `/tmp/spot_check.txt`:
1. Generate fingerprint (`wc`, `head`, `tail`, `git hash-object`).
2. Compare against PHASE 1 fingerprint if available.
3. Validate baseline format (non-empty; markdown title for `.md`).
4. Validate encoding.

#### 2.3 Record sampling results
```yaml
spot_check_total: <N>
spot_check_passed: <N>
spot_check_warnings: <N>
spot_check_failures: <N>
```

#### CHECKPOINT 2
Criteria:
- No critical divergence between PHASE 1 and PHASE 2 fingerprints.
Gate:
- Any critical divergence => `CRITICAL ERROR` => `BLOCKED`

#### CHECKPOINT 2.SAVE
```yaml
phase_completed: 2
timestamp: <YYYY-MM-DD HH:MM>
status: <PASS | PASS_WITH_WARNINGS | BLOCKED>
```

### PHASE 3: Closure and Record
Objective: consolidate evidence, verify gates, and prepare release.

#### 3.1 Consolidate `AUDIT_TRAIL.md`
Fill template fields with all measured values and evidence.

#### 3.2 Verify all checkpoints
Re-read trail and assert:
- `CHECKPOINT 0`
- `CHECKPOINT 1`
- `CHECKPOINT 1.2`
- `CHECKPOINT 1.5`
- `CHECKPOINT 2`

Gate:
- Proceed only when each status is `PASS` or `PASS_WITH_WARNINGS`.
- Any unresolved `BLOCKED` status => remain `BLOCKED`.

#### 3.3 Record warnings
```yaml
warnings:
  - phase: <N>
    description: "<TEXT>"
    file: "<PATH>"
    recommended_action: "<TEXT>"
```

#### 3.4 Re-validate corrected files
If mode is `AUDIT_AND_FIX` and corrections were made:
1. List corrected files.
2. Recompute fingerprint for each.
3. Re-run all applicable checks.
4. Revert and report if a new error is introduced.

#### 3.5 Build executive summary
```yaml
audit_summary:
  total_files_audited: <N>
  critical_errors_found: <N>
  critical_errors_resolved: <N>
  critical_errors_open: <N>
  warnings_found: <N>
  files_corrected: <N>
  audit_result: <PASS | PASS_WITH_WARNINGS | FAIL>
```

#### 3.5.1 Generate Visual Audit Report
Objective: Create a clean, human-readable report summarizing audit results.

**Part A: Build validation results table**

```bash
cat > /tmp/audit_report.md << 'EOF'
# 📊 Repository Audit Report

**Repository:** $(basename $(pwd))
**Audit Date:** $(date '+%Y-%m-%d %H:%M')
**Audit Mode:** ${AUDIT_MODE}
**Audit Agent:** ${AUDIT_AGENT}

---

## ✅ Validation Results

| Phase | Check | Status | Details |
|-------|-------|--------|---------|
EOF

# Add each validation result
# PHASE 0
echo "| 0 | Branch Validation | ${PHASE0_BRANCH_STATUS} | Branch: ${CURRENT_BRANCH} |" >> /tmp/audit_report.md
echo "| 0 | Repository State | ${PHASE0_REPO_STATUS} | Working tree: ${WORKING_TREE_STATUS} |" >> /tmp/audit_report.md

# PHASE 1
echo "| 1 | File Inventory | ${PHASE1_INVENTORY_STATUS} | ${TRACKED_FILE_COUNT} files tracked |" >> /tmp/audit_report.md
echo "| 1 | Critical Files | ${PHASE1_CRITICAL_STATUS} | ${CRITICAL_FILES_EXIST}/${CRITICAL_FILES_TOTAL} exist |" >> /tmp/audit_report.md

# PHASE 1.2
echo "| 1.2 | README Structure | ${PHASE12_README_STATUS} | Version: ${README_VERSION} |" >> /tmp/audit_report.md
echo "| 1.2 | CHANGELOG Entry | ${PHASE12_CHANGELOG_STATUS} | Version ${VERSION} entry found |" >> /tmp/audit_report.md
echo "| 1.2 | Metadata Complete | ${PHASE12_METADATA_STATUS} | ${SKILLS_WITH_METADATA}/${TOTAL_SKILLS} skills |" >> /tmp/audit_report.md
echo "| 1.2 | Slash Commands | ${PHASE12_COMMANDS_STATUS} | ${SKILLS_WITH_COMMANDS}/${TOTAL_SKILLS} defined |" >> /tmp/audit_report.md
echo "| 1.2 | Command Docs Sync | ${PHASE12_CMDDOC_STATUS} | HUB_MAP/README/COMMANDS synchronized |" >> /tmp/audit_report.md
echo "| 1.2 | Command Uniqueness | ${PHASE12_CMDDUP_STATUS} | ${DUPLICATE_COMMANDS_COUNT} duplicates found |" >> /tmp/audit_report.md
echo "| 1.2 | Root File Authorization | ${PHASE12_ROOTFILES_STATUS} | ${UNAUTHORIZED_ROOT_COUNT} unauthorized |" >> /tmp/audit_report.md

# PHASE 1.5
echo "| 1.5 | Skill Count | ${PHASE15_SKILLCOUNT_STATUS} | Real: ${REAL_SKILL_COUNT}, Declared: ${DECLARED_SKILL_COUNT} |" >> /tmp/audit_report.md
echo "| 1.5 | Version Cross-Check | ${PHASE15_VERSIONS_STATUS} | ${VERSION_MISMATCHES} mismatches |" >> /tmp/audit_report.md
echo "| 1.5 | Architecture Complete | ${PHASE15_ARCH_STATUS} | All skills in tree |" >> /tmp/audit_report.md
echo "| 1.5 | Reference Accuracy | ${PHASE15_REFS_STATUS} | ${BROKEN_REFS} broken references |" >> /tmp/audit_report.md
echo "| 1.5 | Internal Links | ${PHASE15_LINKS_STATUS} | ${BROKEN_LINKS} broken links |" >> /tmp/audit_report.md
echo "| 1.5 | CHANGELOG Complete | ${PHASE15_CHANGELOG_STATUS} | ${CHANGELOG_ENTRIES} entries |" >> /tmp/audit_report.md
echo "| 1.5 | EXEC_SUMMARY Complete | ${PHASE15_EXECSUM_STATUS} | ${MISSING_IN_EXECSUM} skills missing |" >> /tmp/audit_report.md

cat >> /tmp/audit_report.md << 'EOF'

---

## 🔧 Corrections Applied

EOF

# List corrections
if [ ${FILES_CORRECTED} -gt 0 ]; then
  echo "**Total Files Corrected:** ${FILES_CORRECTED}" >> /tmp/audit_report.md
  echo "" >> /tmp/audit_report.md
  while IFS='|' read -r file action; do
    echo "- \`${file}\`: ${action}" >> /tmp/audit_report.md
  done < /tmp/corrections_log.txt
else
  echo "*No corrections needed - repository already compliant*" >> /tmp/audit_report.md
fi

cat >> /tmp/audit_report.md << 'EOF'

---

## ⚠️ Warnings

EOF

# List warnings
if [ ${WARNINGS_FOUND} -gt 0 ]; then
  echo "**Total Warnings:** ${WARNINGS_FOUND}" >> /tmp/audit_report.md
  echo "" >> /tmp/audit_report.md
  while IFS='|' read -r phase description file; do
    echo "- **Phase ${phase}**: ${description}" >> /tmp/audit_report.md
    [ -n "$file" ] && echo "  - File: \`${file}\`" >> /tmp/audit_report.md
  done < /tmp/warnings_log.txt
else
  echo "*No warnings - clean audit*" >> /tmp/audit_report.md
fi

cat >> /tmp/audit_report.md << 'EOF'

---

## 📈 Summary Statistics

EOF

cat >> /tmp/audit_report.md << EOF
- **Total Files Audited:** ${TOTAL_FILES_AUDITED}
- **Total Skills:** ${TOTAL_SKILLS}
- **Critical Errors Found:** ${CRITICAL_ERRORS_FOUND}
- **Critical Errors Resolved:** ${CRITICAL_ERRORS_RESOLVED}
- **Critical Errors Open:** ${CRITICAL_ERRORS_OPEN}
- **Warnings Found:** ${WARNINGS_FOUND}
- **Files Corrected:** ${FILES_CORRECTED}

---

## 🎯 Final Result

EOF

# Final verdict
if [ "${AUDIT_RESULT}" == "PASS" ]; then
  cat >> /tmp/audit_report.md << 'EOF'
```
✅ AUDIT PASSED
Repository meets all integrity requirements
```
EOF
elif [ "${AUDIT_RESULT}" == "PASS_WITH_WARNINGS" ]; then
  cat >> /tmp/audit_report.md << 'EOF'
```
⚠️ AUDIT PASSED WITH WARNINGS
Repository passes but has non-blocking issues
Review warnings above for recommended improvements
```
EOF
else
  cat >> /tmp/audit_report.md << 'EOF'
```
❌ AUDIT FAILED
Critical errors must be resolved before proceeding
See details above for required fixes
```
EOF
fi

cat >> /tmp/audit_report.md << 'EOF'

---

**Audit Protocol:** repo-auditor v2.0.0
**Audit Trail:** See AUDIT_TRAIL.md for detailed evidence
EOF
```

**Part B: Display report to user**

```bash
# Display visual report
cat /tmp/audit_report.md

# Save to AUDIT_TRAIL.md as appendix
echo "" >> AUDIT_TRAIL.md
echo "---" >> AUDIT_TRAIL.md
echo "" >> AUDIT_TRAIL.md
cat /tmp/audit_report.md >> AUDIT_TRAIL.md
```

**Part C: Generate summary banner**

```bash
if [ "${AUDIT_RESULT}" == "PASS" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ AUDIT COMPLETE - ALL CHECKS PASSED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Repository: COMPLIANT"
  echo "Total Checks: ${TOTAL_CHECKS}"
  echo "Passed: ${CHECKS_PASSED}"
  echo "Failed: 0"
  echo "Warnings: ${WARNINGS_FOUND}"
  echo ""
elif [ "${AUDIT_RESULT}" == "PASS_WITH_WARNINGS" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️ AUDIT COMPLETE - PASSED WITH WARNINGS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Repository: COMPLIANT (with warnings)"
  echo "Total Checks: ${TOTAL_CHECKS}"
  echo "Passed: ${CHECKS_PASSED}"
  echo "Failed: 0"
  echo "Warnings: ${WARNINGS_FOUND}"
  echo ""
  echo "⚠️ Review warnings in report above"
  echo ""
else
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ AUDIT FAILED - CRITICAL ERRORS FOUND"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Repository: NON-COMPLIANT"
  echo "Total Checks: ${TOTAL_CHECKS}"
  echo "Passed: ${CHECKS_PASSED}"
  echo "Failed: ${CHECKS_FAILED}"
  echo "Open Errors: ${CRITICAL_ERRORS_OPEN}"
  echo ""
  echo "❌ Fix critical errors before proceeding"
  echo ""
fi
```

#### CHECKPOINT 3
Criteria:
- All previous checkpoints passed: `YES` or `NO`
- Open critical errors: must be `0`
- Re-validation of corrections: `PASS` or `FAIL`
Gate:
- Any open critical error => `BLOCKED`

#### CHECKPOINT 3.SAVE
```yaml
phase_completed: 3
timestamp: <YYYY-MM-DD HH:MM>
status: <PASS | PASS_WITH_WARNINGS | BLOCKED>
```

### PHASE 3.6: Publish GitHub Release
Precondition:
- PHASE 3 status is `PASS`.
- Mode is not `AUDIT_ONLY`.
- Mode is not `DRY_RUN`.

#### 3.6.1 Verify or create tag
Commands:
```bash
TAG_EXISTS=$(git tag -l "v${VERSION}")
echo "TAG_EXISTS=${TAG_EXISTS}"
```
If tag does not exist:
```bash
git tag -a "v${VERSION}" -m "Release v${VERSION}"
git push origin "v${VERSION}"
```
Verify tag commit:
```bash
TAG_COMMIT=$(git log -1 --format="%H" "v${VERSION}")
HEAD_COMMIT=$(git log -1 --format="%H" HEAD)
echo "TAG=${TAG_COMMIT} HEAD=${HEAD_COMMIT}"
```
Criteria:
- `PASS` if `TAG_COMMIT == HEAD_COMMIT`
- Mismatch => `WARNING`; ask user before continuing

#### 3.6.2 Extract release notes
Command:
```bash
awk "/^## \[${VERSION}\]/{found=1; next} /^## \[/{found=0} found" CHANGELOG.md > /tmp/release-notes.md
wc -l /tmp/release-notes.md
```
Criteria:
- At least one line required.
- Empty release notes => `CRITICAL ERROR` => `BLOCKED`

#### 3.6.3 Create release
Command:
```bash
gh release create "v${VERSION}" \
  --title "v${VERSION}" \
  --notes-file /tmp/release-notes.md \
  --latest
```

#### 3.6.4 Verify publication
Commands:
```bash
gh release view "v${VERSION}"
gh api repos/{owner}/{repo}/releases/tags/v${VERSION} --jq '.html_url'
```
Criteria:
- `gh release view` must return release information.
- API call should return valid URL.
- If API call fails, wait 30 seconds and retry once; second failure => `WARNING`.
- Release create/view failure => `CRITICAL ERROR` => `BLOCKED`.

#### 3.6.5 Record release result
```yaml
release_published: <YES>
release_url: <URL>
release_tag: <vX.Y.Z>
release_tag_commit: <SHA>
release_tag_verified: <YES>
release_api_verified: <YES | NO>
```

#### CHECKPOINT 3.6
Criteria:
- Tag exists and is verified: `PASS` or `WARNING`
- Release notes contain content: `PASS` or `FAIL`
- `gh release create`: `PASS` or `FAIL`
- `gh release view`: `PASS` or `FAIL`
Gate:
- Any `FAIL` => `CRITICAL ERROR` => `BLOCKED`

#### CHECKPOINT 3.6.SAVE
```yaml
phase_completed: 3.6
timestamp: <YYYY-MM-DD HH:MM>
status: <PASS | BLOCKED | SKIPPED>
release_url: <URL | N/A>
```

## Absolute Prohibitions (P01-P13)

`P01`: Do not claim a file is correct without validating content against repository reality via bash.
`P02`: Do not mark an audit complete without release publication, except in `AUDIT_ONLY` and `DRY_RUN`.
`P03`: Do not assume counts or lists without bash verification.
`P04`: Do not ignore `FAIL` at any checkpoint.
`P05`: Do not use first-match extraction for semantic data without context validation.
`P06`: Do not ignore non-zero command exit codes.
`P07`: Do not modify files outside PHASE 0 scope.
`P08`: Do not advance phases with unresolved `CRITICAL ERROR`.
`P09`: Do not re-run completed phases without explicit logged reason.
`P10`: Do not create a release before verifying tag-to-commit correctness.
`P11`: Do not trust auto-fixes without full re-validation.
`P12`: Do not trust architecture lists and tables without counting actual directories and files.
`P13`: Do not use vague terms such as `check`, `updated`, or `relevant` without objective criteria.

## Severity Criteria

`CRITICAL ERROR` (blocks progression):
- Version mismatch across critical files
- Incorrect skill count
- Missing required critical files
- Incomplete architecture mapping
- Broken links to critical files
- Missing mandatory `.metadata` fields
- Missing target entry in `CHANGELOG.md`
- Failed release creation or release verification
- Skills missing from `EXECUTIVE_SUMMARY.md` Component Versions line
- Skills missing `command:` definition in SKILL.md frontmatter
- Command documentation out of sync across HUB_MAP, README, COMMANDS.md
- Duplicate slash command definitions (command collision)
- Unauthorized files in repository root (not in scripts/integrity-check.sh approved_files)

`WARNING` (non-blocking but mandatory to log):
- Non-critical orphan files
- Uncommitted workspace changes
- Local and remote divergence
- Broken links to non-critical files
- Formatting inconsistency with correct content
- Non-UTF-8 encoding
- Missing expected (non-required) files
- Missing date format in changelog entry
- Orphaned entries in approved_files list (files in list but don't exist)

## Resume Protocol for Interrupted Audits

If `AUDIT_TRAIL.md` reports `phase_completed: N` and status is passing:
1. Resume from `PHASE N+1`.
2. Do not re-run previous phases unless explicitly requested.
3. Log `RESUMED_FROM_PHASE_<N+1>`.
4. Keep prior fingerprints and evidence.

If `AUDIT_TRAIL.md` reports `BLOCKED` at `PHASE N`:
1. Read exact error details.
2. Apply recovery protocol.
3. If recovered, log `RECOVERED` and continue.
4. If not recoverable, stop and report to user.

## Output Contract

- Use `repo-auditor/AUDIT_TRAIL.md` as the canonical YAML audit record.
- Include all phase checkpoints and save records.
- Include full fingerprint list for critical files.
- Include all warnings, corrections, and out-of-scope findings.
- Do not claim completion unless checkpoint gates permit closure.
