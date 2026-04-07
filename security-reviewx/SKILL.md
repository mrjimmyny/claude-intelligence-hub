---
name: security-reviewx
description: Comprehensive security review skill — scans repositories for exposed secrets, PII, dangerous files, hardcoded paths, config vulnerabilities, and code vulnerabilities before publication to GitHub
version: 1.0.0
global: true
cross_agent: true
---

# security-reviewx

**Version:** 1.0.0
**Type:** Global, Cross-Agent, Cross-Machine
**Pattern Library:** v1.0.0

Deterministic, modular security scanning skill. Detects exposed secrets, sensitive data, credentials, and security vulnerabilities in repositories.

**Principle:** Detect and report. NEVER auto-fix without explicit human authorization.

## 1. Invocation

This skill accepts both CLI syntax and natural language:

| Invocation | Mode | Description |
|---|---|---|
| `/security-reviewx` | STANDARD | Default — modules M1-M6 on current repo |
| `/security-reviewx --mode quick` | QUICK | Fast — modules M1-M4 only |
| `/security-reviewx --mode deep` | DEEP | Full — all 7 modules including git history |
| `/security-reviewx --target {path}` | (any) | Scan specific directory |
| `/security-reviewx --module M1,M3` | CUSTOM | Run only specified modules |
| Natural language | (inferred) | "scan this repo for secrets", "run full security review", "check skill X for exposed data" |

**Arguments:**

| Arg | Default | Description |
|---|---|---|
| `--mode` | `standard` | `quick`, `standard`, `deep` |
| `--target` | repo root | Directory to scan |
| `--module` | (all for mode) | Comma-separated: `M1,M3,M5` |
| `--format` | `both` | `md`, `json`, `both` |
| `--full` | false | Force full scan (ignore incremental state) |

## 2. Execution Protocol

**Every scan follows these 8 steps exactly. No steps may be skipped.**

### Step 1: INIT

```
1. Determine {REPO_ROOT}:
   - If --target provided: use that path
   - Otherwise: git rev-parse --show-toplevel (or cwd if not a git repo)

2. Load pattern library:
   - Read all JSON files from {SKILL_ROOT}/patterns/
   - Validate each has required fields (id, regex, severity, enabled)
   - Count total enabled patterns

3. Load allowlist:
   - Check for {REPO_ROOT}/.security-reviewx-allowlist.json
   - If exists: parse and validate entries
   - Flag expired entries (approved_date + default_expiry_days < today)

4. Check incremental state:
   - Read {SKILL_ROOT}/.scan-state.json if exists
   - If --full flag: ignore state, scan everything
   - If state exists and not --full: determine files changed since last scan
     via: git diff --name-only {last_commit}..HEAD

5. Generate Scan ID (UUID)

6. Record start time
```

### Step 2: FILE DISCOVERY

```
1. List all files in {REPO_ROOT} (or --target):
   - Respect .gitignore (use: git ls-files + git ls-files --others --exclude-standard)
   - If not a git repo: list all files, skip node_modules/, .git/, __pycache__/

2. If incremental mode: filter to only changed files

3. Categorize each file:
   - text: readable text files
   - binary: non-text files
   - config: .env*, config.*, settings.*, *.yml, *.yaml, *.toml, *.ini
   - script: .sh, .ps1, .bat, .cmd

4. Build file manifest:
   { path, size_bytes, type, extension }

5. Count files for reporting
```

### Step 3: MODULE EXECUTION

Execute modules based on scan mode:

| Mode | Modules |
|---|---|
| QUICK | M1, M2, M3, M4 |
| STANDARD | M1, M2, M3, M4, M5, M6 |
| DEEP | M1, M2, M3, M4, M5, M6, M7 |
| CUSTOM | Only specified modules |

**For each module:**

```
1. Load patterns for this module from pattern library
2. Filter to enabled patterns only
3. For each file in manifest:
   a. Check if file matches pattern's file_types filter
   b. Check if file is in pattern's exclude_paths
   c. If incremental: check if file was modified since last scan
   d. Search file content for pattern regex
   e. For each match:
      - Check false_positive_hints (skip if matched)
      - Create finding record:
        {
          id: "SRX-{sequential}",
          module: "{module_code}",
          severity: "{from pattern}",
          file: "{relative path}",
          line: {line number},
          pattern_id: "{from pattern}",
          evidence_redacted: "{first 4 chars}...{last 4 chars}",
          category: "{from pattern}",
          recommendation: "{from pattern}",
          allowlisted: false
        }
```

**Module-specific logic:**

**M3 (FILE_SCAN):** Also checks:
- File extension against dangerous patterns (match on filename, not content)
- File size for binary threshold (FILE-BIN-001)
- .gitignore contents against required patterns (FILE-GI-*)

**M7 (GIT_HISTORY_SCAN):**
```
1. Determine scan range:
   - If incremental and scan state has last_commit: scan from last_commit to HEAD
   - If --full or no state: scan last 500 commits (configurable)

2. For each commit in range:
   git diff-tree -p {commit_hash}

3. Scan ADDED lines (+ prefix) using SECRET_SCAN patterns

4. If a pattern matches in a REMOVED line but the file no longer contains it:
   → Finding: "Secret was committed and then removed — still in git history"
   → Severity: CRITICAL

5. Also check commit messages for GIT-MSG-001 pattern
```

### Step 4: DEDUPLICATION

```
1. Sort all findings by file, then line number
2. For same file + same line + multiple patterns:
   - Keep the finding with highest severity
   - Note deduplicated patterns in finding metadata
3. Same file + same pattern + different lines:
   - Keep all (each is a distinct finding)
```

### Step 5: ALLOWLIST FILTERING

```
1. For each finding:
   a. Check allowlist for matching entry:
      - file matches
      - line matches (or wildcard)
      - pattern_id matches
   b. If match found:
      - Check if entry is expired (approved_date + expiry > today)
      - If expired: mark finding as "EXPIRED_ALLOWLIST" (severity: MEDIUM)
      - If active: mark finding as allowlisted=true
2. Expired allowlist entries generate their own findings
```

### Step 6: VERDICT

```
1. Count findings by severity (excluding allowlisted):
   - critical_count = count where severity=CRITICAL and allowlisted=false
   - high_count = count where severity=HIGH and allowlisted=false
   - medium_count = count where severity=MEDIUM and allowlisted=false
   - low_count = count where severity=LOW and allowlisted=false

2. Determine verdict:
   - PASS: all counts are 0
   - WARN: all non-allowlisted findings are in allowlist (net 0) but MEDIUM/LOW exist
   - FAIL: any non-allowlisted finding at ANY severity exists

3. Per-module verdict:
   - Each module: PASS if 0 non-allowlisted findings, FAIL otherwise
```

### Step 7: REPORT GENERATION

Generate reports per Section 3 of this skill (Report Templates).

**For WARN/FAIL verdicts:** Include the "Deep Dive — Findings Requiring Action" section with:
- Full context (5 lines before/after match)
- Risk assessment
- Specific remediation steps
- Priority ordering (CRITICAL → HIGH → MEDIUM → LOW)

### Step 8: OUTPUT & STATE UPDATE

```
1. Write markdown report:
   → {DOCUMENTAL_LAYER}/05-audits/srx-report-{YYYY-MM-DD}-{mode}-{short-uuid}.md

2. Write JSON report:
   → {SKILL_ROOT}/reports/srx-report-{YYYY-MM-DD}-{mode}-{short-uuid}.json

3. Update scan state:
   → {SKILL_ROOT}/.scan-state.json
   {
     "last_scan_date": "{YYYY-MM-DD HH:MM}",
     "last_scan_commit": "{HEAD commit hash}",
     "last_scan_mode": "{mode}",
     "last_scan_verdict": "{PASS/WARN/FAIL}",
     "last_scan_id": "{UUID}",
     "findings_count": {N}
   }

4. Display summary to user:
   Verdict: {PASS/WARN/FAIL}
   Findings: {critical} CRITICAL, {high} HIGH, {medium} MEDIUM, {low} LOW
   Allowed: {N}
   Report: {path to markdown report}
```

## 3. Report Templates

### 3.1 Markdown Report

See SPEC Section 11.2 for the full template. Key sections:

1. **Frontmatter** — scan metadata, verdict, counts, tags
2. **Executive Summary** — verdict, counts table, top issues, module status
3. **Detailed Findings** — table of all findings with redacted evidence
4. **Deep Dive** (WARN/FAIL only) — per-finding context, risk, remediation
5. **Remediation Checklist** — actionable checkbox list by severity
6. **Allowlist Status** — current entries, expirations
7. **Scan Metadata** — duration, files scanned, patterns loaded
8. **Wikilinks** — Obsidian graph integration

### 3.2 Evidence Redaction Rules

**NEVER expose full secrets in reports.** Redaction rules:

| Content Type | Redaction Method | Example |
|---|---|---|
| API key (>20 chars) | First 4 + "..." + last 4 | `sk-a...7x9Q` |
| Password (<20 chars) | First 2 + "****" | `pa****` |
| Email address | user + "@" + first 2 of domain + "****" | `user@ex****` |
| File path | Full path shown (paths are not secrets) | `/path/to/file.js:42` |
| Connection string | Protocol + "://" + "****" | `postgres://****` |
| Private key | "-----BEGIN ... KEY-----" only | Header line only |

## 4. Allowlist Management

### 4.1 File Location

Default: `{REPO_ROOT}/.security-reviewx-allowlist.json`

### 4.2 Adding Entries

When a finding is a confirmed false positive, the agent proposes an allowlist entry:

```json
{
  "id": "ALW-{sequential}",
  "file": "{relative path}",
  "line": {line number},
  "pattern_id": "{pattern that matched}",
  "match_hash": "{sha256 first 8 chars of matched content}",
  "reason": "{why this is safe — must be non-empty}",
  "approved_by": "Jimmy",
  "approved_date": "{YYYY-MM-DD}",
  "expires": "{YYYY-MM-DD — default 90 days from approval}",
  "permanent": false
}
```

**Rules:**
1. Only Jimmy can approve new entries
2. Agent proposes, Jimmy confirms
3. `reason` MUST be non-empty and specific
4. `permanent: true` requires explicit justification
5. Allowlist file itself is scanned (meta-scan)

## 5. Self-Test Protocol

Before any scan, the skill validates the agent has all required capabilities:

```
SELF-TEST CHECKLIST:
  [ ] Can read files (test: read this SKILL.md)
  [ ] Can search/grep (test: search for "security-reviewx" in SKILL.md)
  [ ] Can write files (test: write a temp file, delete it)
  [ ] Can parse JSON (test: parse patterns/VERSION)
  [ ] Can generate UUID (test: generate one)
  [ ] Pattern library accessible (test: count files in patterns/)
  [ ] Git available (test: git --version — required for DEEP mode only)
```

If any check fails: report which capability is missing, skip dependent modules.

## 6. Cross-Agent Adaptation

This skill uses generic instructions. Agents adapt to their tools:

| Instruction | Implementation |
|---|---|
| "Search for pattern X in files" | Use Grep/rg/search_files tool |
| "Read file Y" | Use Read/cat/read_file tool |
| "Write report to Z" | Use Write/write_file tool |
| "List files matching *.json" | Use Glob/find/list_files tool |
| "Get git log" | Use Bash/shell tool: `git log` |

## 7. Scan State (Incremental)

File: `{SKILL_ROOT}/.scan-state.json`

After each scan, this file is updated with:
- Last scan timestamp (Brasilia time)
- Last scanned commit hash
- Mode used
- Verdict
- Finding count

On subsequent scans:
- **QUICK/STANDARD:** Only scan files modified since `last_scan_commit`
- **DEEP:** Scan git history from `last_scan_commit` forward
- **--full flag:** Ignore state, scan everything
- **First run:** No state file → full scan automatically

## 8. Error Handling

| Error | Behavior |
|---|---|
| Pattern library not found | ABORT — cannot scan |
| Pattern file invalid JSON | SKIP that file, log WARNING, continue |
| File unreadable | SKIP file, log in report |
| Module crashes | SKIP module, log ERROR, continue remaining |
| Git not available (DEEP) | SKIP M7, log WARNING, run remaining |
| No files found | ABORT — nothing to scan |
| Allowlist invalid | SKIP allowlist, treat all findings as non-allowed |

## 9. Output Routing

| Artifact | Layer | Path |
|---|---|---|
| Reports (markdown) | Documental | `obsidian/CIH/projects/skills/security-reviewx/05-audits/` |
| Reports (JSON) | Technical | `_skills/security-reviewx/reports/` |
| Scan state | Technical | `_skills/security-reviewx/.scan-state.json` |
| Pattern library | Technical | `_skills/security-reviewx/patterns/` |
| Allowlist | Repo config | `{REPO_ROOT}/.security-reviewx-allowlist.json` |

## 10. Integration

### 10.1 Findings System

When the scan produces CRITICAL or HIGH findings, the agent SHOULD register them in `findings-master-index.md` with type=INT and the appropriate severity.

### 10.2 Session Documentation

When invoked during a session, log the scan in the session doc:
- History row: "Security review scan: {mode}, verdict: {VERDICT}, {N} findings"
- If findings: set `has_findings: true` in session doc

### 10.3 Pre-Commit Recommendation

After any FAIL scan, recommend adding a pre-commit hook. The skill does NOT install hooks automatically — it generates the config and suggests installation.

---

## Wikilinks

[[projects]] | [[skills]] | [[security-reviewx]] | [[PROJECT_CONTEXT]] | [[security-reviewx-manifesto-v1.0]] | [[security-reviewx-spec-v1.0]]
