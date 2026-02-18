# Feature Release Checklist

**⚠️ USE THIS BEFORE EVERY RELEASE - NO EXCEPTIONS ⚠️**

This checklist prevents README drift and ensures all documentation stays 100% synchronized with each release.

---

## 📋 Pre-Release Validation (MANDATORY)

### Core Documentation Files

- [ ] **CHANGELOG.md**
  - [ ] New version section added with release date
  - [ ] Complete feature list documented
  - [ ] Breaking changes noted (if any)
  - [ ] Credits and contributors listed

- [ ] **README.md** - Validate ALL sections
  - [ ] Version badge updated (`[![Version](https://img.shields.io/badge/version-X.X.X-blue.svg)]`)
  - [ ] "Current Version" section updated (line ~710)
  - [ ] "Major Milestones" section updated with new release (line ~726)
  - [ ] "Production Skills" count updated (line ~500)
  - [ ] "Skills by Status" section lists ALL current skills (line ~513)
  - [ ] "Architecture" section matches actual folder structure (line ~285-367)
  - [ ] HUB_MAP.md version reference updated (line ~352)
  - [ ] EXECUTIVE_SUMMARY.md version reference updated (line ~351)
  - [ ] Setup script descriptions reflect current skill count (line ~132, ~156)
  - [ ] Any new features documented in appropriate sections

- [ ] **HUB_MAP.md**
  - [ ] Version number updated in header
  - [ ] New skills added to routing table (if applicable)
  - [ ] Trigger phrases documented
  - [ ] Dependencies updated
  - [ ] Skill count matches README

### Consistency Checks

- [ ] **Skills Count Consistency**
  - [ ] Count actual skill folders: `ls -d */` (exclude `.git`, `docs`, `scripts`, etc.)
  - [ ] README "Production Skills" count matches actual
  - [ ] HUB_MAP skill count matches actual
  - [ ] Setup scripts reference correct count

- [ ] **Version Consistency**
  - [ ] README version = CHANGELOG version = Git tag version
  - [ ] All version badges updated
  - [ ] No references to old versions in docs

- [ ] **Folder Structure Consistency**
  - [ ] Architecture section in README documents ALL skill folders
  - [ ] No orphaned folders (exist but not documented)
  - [ ] No ghost folders (documented but don't exist)

### Git & GitHub

- [ ] **Git Commit**
  - [ ] All documentation files staged (`git add CHANGELOG.md README.md HUB_MAP.md ...`)
  - [ ] Descriptive commit message with Co-Authored-By
  - [ ] Pushed to remote (`git push origin main`)

- [ ] **GitHub Release**
  - [ ] Tag created with `gh release create vX.X.X`
  - [ ] Release notes comprehensive and well-formatted
  - [ ] Links to documentation included
  - [ ] Upgrade instructions provided (if applicable)

### Memory & Learning

- [ ] **X-MEM Update** (if applicable)
  - [ ] Capture new learnings in `xavier-memory/MEMORY.md`
  - [ ] Document error patterns discovered
  - [ ] Update behavioral guidelines

---

## 🤖 Automation (Run These Scripts)

### Step 1: Validate README Consistency

```bash
cd claude-intelligence-hub
bash scripts/validate-readme.sh
```

**Expected output:** `✅ README.md validation passed!`

If errors found:
- Fix each error listed
- Re-run validation until all pass
- NEVER skip validation errors

### Step 2: Create GitHub Release (After Validation Passes)

```bash
gh release create vX.X.X \
  --title "vX.X.X - Feature Name" \
  --notes "$(cat release-notes.md)"
```

---

## ⚠️ Common Drift Patterns to Check

### Pattern #1: Skill Count Mismatch
- **Symptom:** README says "6 collections" but we have 8 skill folders
- **Fix:** Update README line ~500 and line ~513

### Pattern #2: Version Reference Lag
- **Symptom:** HUB_MAP.md version says v1.9.0 but latest is v2.1.0
- **Fix:** Update README line ~352

### Pattern #3: Architecture Section Incomplete
- **Symptom:** New skill folder added but not documented in Architecture section
- **Fix:** Add folder documentation in README line ~285-367

### Pattern #4: Major Milestones Missing
- **Symptom:** Latest release not listed in Version History
- **Fix:** Add milestone entry in README line ~726

### Pattern #5: Setup Script Descriptions Outdated
- **Symptom:** Setup script still says "installs 5 mandatory skills" but we have 8
- **Fix:** Update README line ~132 and ~156

### Pattern #6: Architecture Tree Missing Real Folder (validate-readme.sh false-green)
- **Symptom:** New skill folder exists on disk but is absent from the `## 🏗️ Hub Architecture` tree. `validate-readme.sh` reports ✅ anyway.
- **Root cause:** The old Check 5 ran `grep "$DIR_NAME/" README.md` against the **entire file**. Any mention of the folder (skills table, prose, etc.) was enough to pass — even if the tree section itself was missing the entry.
- **Fix:** The validator now extracts the architecture section via `awk` and checks only within that block. If you ever see this pattern recur, re-audit `validate-readme.sh` Check 5 to confirm it's still using the scoped `awk` extraction.
- **Manual check:** Search for the folder name only inside the ` ``` ` block under `## 🏗️ Hub Architecture`.

### Pattern #7: Governance/Non-Skill Folder Silently Excluded from Architecture Check
- **Symptom:** A folder exists on disk (e.g. `token-economy/`) but is never flagged as undocumented because it was hardcoded as an exception in `validate-readme.sh`.
- **Root cause:** The old Check 5 had `[[ "$skill_dir" == "token-economy/" ]]` as an explicit skip. The folder was never validated, so it could go undocumented indefinitely.
- **Fix:** The skip list in Check 5 now only contains true infrastructure directories (`scripts/`, `docs/`, `.git/`, `.github/`, `.claude/`). Every other folder — including governance modules — must appear in the architecture tree or the check fails.
- **Rule:** Never add a skill or governance folder to the skip list. If it lives in the repo root, it belongs in the architecture tree.

### Pattern #8: Ghost Folder in Architecture Tree
- **Symptom:** The architecture tree documents a folder (e.g. `python-claude-skills/`, `git-claude-skills/`) that does not exist on disk. Validator previously had no ghost detection.
- **Root cause:** Placeholder entries added for "future" skills were never cleaned up when those skills stayed unbuilt.
- **Fix:** `validate-readme.sh` Check 5 now scans the tree for `📁 folder-name/` entries and verifies each one exists on disk. Non-existent entries raise a WARNING.
- **Rule:** Do not add placeholder folder entries to the architecture tree. Use the `📋 Planned:` line in the Skills by Status section instead.

### Pattern #9: SKILL.md Missing Version Header (integrity-check.sh Check 6 false failure)
- **Symptom:** `integrity-check.sh` reports `VERSION DRIFT: <skill>` with `.metadata: v1.0.0` and `SKILL.md: v` (blank). Skill version appears as empty even though `.metadata` is correct.
- **Root cause:** Check 6 extracts the version from SKILL.md by grepping for `^\*\*Version:\*\*`. If the SKILL.md was created without this line, grep returns empty — producing the misleading drift error.
- **Fix:** Add `**Version:** X.X.X` as the second line of the SKILL.md header (after the `# Skill Name` title). Running `bash scripts/sync-versions.sh <skill-name>` will then keep it in sync with `.metadata`.
- **Rule:** Every SKILL.md must have a `**Version:** X.X.X` line. Check when creating new skills or the integrity check will false-fail on Check 6.

### Pattern #10: New Root Document Not in integrity-check.sh Approved List
- **Symptom:** `integrity-check.sh` Check 3 flags a legitimate root-level file (e.g. `CIH-ROADMAP.md`, `AUDIT_TRAIL.md`, `DEVELOPMENT_IMPACT_ANALYSIS.md`) as "CLUTTER: unauthorized root file" even though it was intentionally added.
- **Root cause:** `scripts/integrity-check.sh` has a hardcoded `approved_files` array. Any new `.md` file added to the repo root that isn't in that list triggers a false clutter warning.
- **Fix:** Add the new filename to the `approved_files` array in `scripts/integrity-check.sh` (around line 93) at the same time you add the file to the repo.
- **Rule:** Every time a new document is intentionally added to the repo root, update `approved_files` in the same commit. Never let the approval list drift behind the actual root contents.

---

## 📊 Validation Script Output Examples

### ✅ GOOD (All checks pass)

```
🔍 Validating README.md consistency...
✅ Production skills count: 8 (matches actual folders)
✅ Version consistency: v2.1.0 (README = CHANGELOG)
✅ Architecture section: All folders documented
✅ README.md validation passed!
```

### ❌ BAD (Errors found)

```
🔍 Validating README.md consistency...
❌ ERROR: Production skills count mismatch
   Actual folders: 8
   README claims: 6
❌ ERROR: Version mismatch
   README: v2.0.0
   CHANGELOG: v2.1.0
⚠️  WARNING: Folder 'xavier-memory/' not documented in Architecture section

❌ Found 3 validation errors
   Fix these issues before releasing
```

---

## 🎯 Quick Reference Checklist

Before EVERY release, ask yourself:

1. ✅ Did I run `bash scripts/validate-readme.sh`?
2. ✅ Did all validation checks pass?
3. ✅ Did I update CHANGELOG, README, and HUB_MAP?
4. ✅ Did I verify skill counts match across all docs?
5. ✅ Did I add the new version to Major Milestones?
6. ✅ Did I commit and push everything to GitHub?
7. ✅ Did I create the GitHub release with comprehensive notes?

**If ANY answer is NO → STOP and complete that step first.**

---

## 📝 Template: Release Commit Message

```bash
git commit -m "$(cat <<'EOF'
docs: update all documentation to vX.X.X

- Updated CHANGELOG.md with vX.X.X release notes
- Updated README.md (version, skills count, milestones, architecture)
- Updated HUB_MAP.md to vX.X.X
- Validated consistency with validate-readme.sh (all checks passed)

Changes:
- [List key changes here]

All documentation now 100% current and aligned with vX.X.X.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## 🚨 Emergency: README Already Drifted

If you discover README is already outdated:

1. **Audit ALL sections** using this checklist
2. **Fix ALL inconsistencies** (don't skip any)
3. **Run validation script** to confirm fixes
4. **Commit with message:** `fix: correct README drift - update all outdated sections to vX.X.X`
5. **Update X-MEM** with lessons learned

---

## 🧠 Why This Matters

**User frustration quote:**
> "I don't want to keep reminding you to maintain these documents all fully 100% updated every time it's needed. How can we resolve this critical issue?"

**Answer:** Follow this checklist religiously. Every. Single. Release.

**Result:**
- ✅ README always 100% current
- ✅ No skill count mismatches
- ✅ No version drift
- ✅ No missing documentation
- ✅ Happy users

---

**REMEMBER:** This checklist exists because we identified a pattern of README drift causing user frustration. Don't let it happen again.

**Last Updated:** February 18, 2026 (v2.5.0 — added Patterns #6–#10 from validator and integrity-check post-mortems)
