# Claude Intelligence Hub - Repository Reorganization Roadmap

**Status:** Planning Phase - Awaiting Approval
**Created:** 2026-02-16
**Session:** d5a7912e-aff9-4216-929b-85581cb90512
**Estimated Duration:** 3-4 hours (across 2 sessions)

---

## 🎯 OBJECTIVE

Reorganize the claude-intelligence-hub repository from a flat structure to a hierarchical, categorized structure that separates:
- System infrastructure (xavier-memory, x-mem protocol)
- Mandatory skills (session-memoria, registry, gdrive-sync, etc.)
- Project-specific skills (pbi-claude-skills)
- Infrastructure tooling (scripts, templates, CI/CD)
- Documentation (guides, architecture, checklists)

---

## 📊 CURRENT STATE

**8 Skills Identified:**
1. `jimmy-core-preferences/` - v1.5.0 (mandatory, Tier 1)
2. `session-memoria/` - v1.2.0 (mandatory)
3. `x-mem/` - v1.0.0 (mandatory protocol)
4. `gdrive-sync-memoria/` - v1.0.0 (mandatory)
5. `claude-session-registry/` - (mandatory)
6. `xavier-memory/` - v1.1.0 (system infrastructure)
7. `xavier-memory-sync/` - (infrastructure)
8. `pbi-claude-skills/` - v1.3.0 (project-specific)

**Critical Dependencies:**
- Hard links: `xavier-memory/MEMORY.md` → `~/.claude/projects/*/memory/MEMORY.md`
- Junction points: All skills → `~/.claude/skills/user/*`
- 17 scripts with hardcoded paths

---

## 🏗️ TARGET STRUCTURE

```
claude-intelligence-hub/
├── system/                          # Core infrastructure (never changes)
│   ├── xavier-memory/               # Global memory with hard links
│   └── x-mem/                       # Self-learning protocol
│
├── mandatory-skills/                # Skills required in ALL projects
│   ├── jimmy-core-preferences/      # Core AI behavior (Tier 1)
│   ├── session-memoria/             # Knowledge management
│   ├── gdrive-sync-memoria/         # Google Drive integration
│   ├── claude-session-registry/     # Session tracking
│   └── xavier-memory-sync/          # Memory operations
│
├── project-skills/                  # Optional, project-specific
│   └── pbi-claude-skills/           # Power BI optimization
│
├── infrastructure/                  # Setup, deployment, CI/CD
│   ├── scripts/                     # Automation scripts
│   ├── templates/                   # Reusable templates
│   └── ci-cd/                       # GitHub Actions (moved from .github/workflows/)
│
├── docs/                            # Central documentation
│   ├── architecture/                # System design
│   ├── guides/                      # How-to guides
│   ├── checklists/                  # Process checklists
│   └── archive/                     # Deprecated docs
│
├── .github/                         # GitHub metadata (stays in root)
├── README.md                        # Main docs (root)
├── HUB_MAP.md                       # Index (root)
├── CHANGELOG.md                     # History (root)
└── EXECUTIVE_SUMMARY.md             # Summary (root)
```

---

## 📋 PHASED IMPLEMENTATION PLAN

### **PHASE 0: PREPARATION (30 minutes)**

**Goal:** Ensure clean state, full backup, and documentation before changes.

**Tasks:**

1. **Pre-flight Checks**
   - [ ] Git status clean (no uncommitted changes)
   - [ ] All tests passing
   - [ ] All skills loadable
   - [ ] Xavier memory status: healthy

2. **Complete Backup**
   - [ ] Git commit + push current state
   - [ ] Google Drive sync (xavier-memory)
   - [ ] Create local zip archive: `claude-intelligence-hub-backup-2026-02-16.zip`
   - [ ] Store backup in safe location (outside repo)

3. **Document Current State**
   - [ ] List all junction points: `dir C:\Users\jaderson.almeida\.claude\skills\user\ /AL > junctions-before.txt`
   - [ ] List all hard links: `fsutil hardlink list xavier-memory\MEMORY.md > hardlinks-before.txt`
   - [ ] Capture current paths in all scripts (grep search results)

4. **Create Rollback Script**
   - [ ] Document exact Git commit hash before reorganization
   - [ ] Create `ROLLBACK_PROCEDURE.md` with step-by-step restore instructions
   - [ ] Test backup restoration ability (verify zip opens)

**Verification:**
- ✅ Backup zip created and verified
- ✅ Current state documented (junctions, hard links)
- ✅ Rollback procedure ready

**Exit Criteria:** All backups complete, all documentation captured, rollback plan ready.

---

### **PHASE 1: CREATE NEW STRUCTURE (45 minutes)**

**Goal:** Create new folder structure WITHOUT moving any files yet. Prepare ground.

**Tasks:**

1. **Create Target Directories**
   ```bash
   cd ~/Downloads/claude-intelligence-hub

   # Create top-level directories
   mkdir -p system
   mkdir -p mandatory-skills
   mkdir -p project-skills
   mkdir -p infrastructure/{scripts,templates,ci-cd}
   mkdir -p docs/{architecture,guides,checklists,archive}
   ```

2. **Move Documentation First (Low Risk)**
   - [ ] Move `WINDOWS_JUNCTION_SETUP.md` → `docs/guides/`
   - [ ] Move feature checklists → `docs/checklists/`
   - [ ] Move `HANDOVER_GUIDE.md`, `PROJECT_FINAL_REPORT.md` → `docs/guides/`
   - [ ] Git commit: "refactor: reorganize documentation into docs/ structure"

3. **Test Git Operations**
   - [ ] Verify Git tracks moves correctly (`git status` shows renames, not deletions)
   - [ ] Push documentation changes
   - [ ] Verify no errors

**Verification:**
- ✅ All new directories created
- ✅ Documentation moved successfully
- ✅ Git push successful

**Exit Criteria:** New structure exists, documentation moved, Git working correctly.

**Resume Point:** If session ends here, next session starts at Phase 2.

---

### **PHASE 2: MOVE SYSTEM INFRASTRUCTURE (60 minutes)**

**Goal:** Move xavier-memory and x-mem to `system/`. This is CRITICAL due to hard links.

**Critical Files:**
- `system/xavier-memory/MEMORY.md` (master for hard links)
- `system/xavier-memory/setup_memory_junctions.bat` (creates hard links)
- `system/xavier-memory/sync-to-gdrive.sh` (Google Drive backup)
- `system/x-mem/` (protocol, may be referenced by other skills)

**Tasks:**

1. **Delete All Existing Hard Links**
   ```powershell
   # For each project with hard link
   Remove-Item -Force "C:\Users\jaderson.almeida\.claude\projects\*\memory\MEMORY.md"

   # Verify deletion
   fsutil hardlink list "C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\xavier-memory\MEMORY.md"
   # Should show only 1 path (master itself)
   ```

2. **Move xavier-memory**
   ```bash
   cd ~/Downloads/claude-intelligence-hub
   git mv xavier-memory system/
   git commit -m "refactor: move xavier-memory to system/ directory"
   ```

3. **Update xavier-memory Scripts (Hardcoded Paths)**

   **File: `system/xavier-memory/setup_memory_junctions.bat`**
   - Line 11: Update `set MASTER_MEMORY=...`
   ```batch
   OLD: set MASTER_MEMORY=%USERPROFILE%\Downloads\claude-intelligence-hub\xavier-memory\MEMORY.md
   NEW: set MASTER_MEMORY=%USERPROFILE%\Downloads\claude-intelligence-hub\system\xavier-memory\MEMORY.md
   ```

   **File: `system/xavier-memory/sync-to-gdrive.sh`**
   - Line ~12: Update `LOCAL_MEMORY=...`
   ```bash
   OLD: LOCAL_MEMORY="$HOME/Downloads/claude-intelligence-hub/xavier-memory/MEMORY.md"
   NEW: LOCAL_MEMORY="$HOME/Downloads/claude-intelligence-hub/system/xavier-memory/MEMORY.md"
   ```
   - Line ~13: Update `BACKUP_DIR=...`
   ```bash
   OLD: BACKUP_DIR="$HOME/Downloads/claude-intelligence-hub/xavier-memory/backups"
   NEW: BACKUP_DIR="$HOME/Downloads/claude-intelligence-hub/system/xavier-memory/backups"
   ```

4. **Recreate Hard Links**
   ```batch
   cd C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\system\xavier-memory
   setup_memory_junctions.bat
   ```

5. **Verify Hard Links**
   ```powershell
   fsutil hardlink list "C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\system\xavier-memory\MEMORY.md"
   # Should show N+1 paths (master + all projects)
   ```

6. **Test Memory Backup**
   ```bash
   cd ~/Downloads/claude-intelligence-hub/system/xavier-memory
   bash sync-to-gdrive.sh
   # Should complete without errors
   ```

7. **Move x-mem**
   ```bash
   cd ~/Downloads/claude-intelligence-hub
   git mv x-mem system/
   git commit -m "refactor: move x-mem protocol to system/ directory"
   ```

8. **Test x-mem Scripts**
   - [ ] Run `system/x-mem/scripts/xmem-search.sh` (verify works)
   - [ ] Check for any hardcoded paths in x-mem scripts
   - [ ] Update paths if necessary

9. **Git Push**
   ```bash
   git push origin main
   ```

**Verification:**
- ✅ xavier-memory moved to system/
- ✅ Hard links recreated and working (N+1 paths)
- ✅ Memory backup script works
- ✅ x-mem moved and functional
- ✅ Git push successful

**Exit Criteria:** System infrastructure moved, hard links working, all tests passing.

**Resume Point:** If session ends here, next session starts at Phase 3.

---

### **PHASE 3: MOVE MANDATORY SKILLS (45 minutes)**

**Goal:** Move all mandatory skills to `mandatory-skills/`. Update junction points.

**Skills to Move:**
1. jimmy-core-preferences
2. session-memoria
3. gdrive-sync-memoria
4. claude-session-registry
5. xavier-memory-sync

**Tasks:**

1. **Delete All Existing Junction Points**
   ```powershell
   # List current junctions
   Get-ChildItem "C:\Users\jaderson.almeida\.claude\skills\user\" |
       Where-Object {$_.Attributes -match "ReparsePoint"}

   # Delete each junction
   Remove-Item "C:\Users\jaderson.almeida\.claude\skills\user\jimmy-core-preferences"
   Remove-Item "C:\Users\jaderson.almeida\.claude\skills\user\session-memoria"
   Remove-Item "C:\Users\jaderson.almeida\.claude\skills\user\gdrive-sync-memoria"
   Remove-Item "C:\Users\jaderson.almeida\.claude\skills\user\claude-session-registry"
   Remove-Item "C:\Users\jaderson.almeida\.claude\skills\user\xavier-memory-sync"

   # Verify deletion
   dir "C:\Users\jaderson.almeida\.claude\skills\user\"
   # Should be empty or show only other skills
   ```

2. **Move Skills (One by One for Safety)**
   ```bash
   cd ~/Downloads/claude-intelligence-hub

   # Move each skill with Git
   git mv jimmy-core-preferences mandatory-skills/
   git commit -m "refactor: move jimmy-core-preferences to mandatory-skills/"

   git mv session-memoria mandatory-skills/
   git commit -m "refactor: move session-memoria to mandatory-skills/"

   git mv gdrive-sync-memoria mandatory-skills/
   git commit -m "refactor: move gdrive-sync-memoria to mandatory-skills/"

   git mv claude-session-registry mandatory-skills/
   git commit -m "refactor: move claude-session-registry to mandatory-skills/"

   git mv xavier-memory-sync mandatory-skills/
   git commit -m "refactor: move xavier-memory-sync to mandatory-skills/"
   ```

3. **Update Setup Scripts (Junction Point Paths)**

   **File: `infrastructure/scripts/setup_local_env.ps1`** (will be moved in Phase 4)

   Currently in `scripts/setup_local_env.ps1`:
   - Update lines referencing skill paths
   ```powershell
   # Example changes needed:
   OLD: "$HubPath\jimmy-core-preferences"
   NEW: "$HubPath\mandatory-skills\jimmy-core-preferences"

   OLD: "$HubPath\session-memoria"
   NEW: "$HubPath\mandatory-skills\session-memoria"

   # Repeat for all 5 mandatory skills
   ```

4. **Update gdrive-sync-memoria Internal References**

   **File: `mandatory-skills/gdrive-sync-memoria/sync-gdrive.sh`**
   - Check for references to `session-memoria/knowledge/metadata.json`
   - Update relative paths if necessary:
   ```bash
   OLD: "$HUB_DIR/session-memoria/knowledge/metadata.json"
   NEW: "$HUB_DIR/mandatory-skills/session-memoria/knowledge/metadata.json"
   ```

5. **Recreate Junction Points**
   ```powershell
   # Recreate each junction with NEW paths
   New-Item -ItemType Junction -Path "C:\Users\jaderson.almeida\.claude\skills\user\jimmy-core-preferences" `
            -Target "C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\mandatory-skills\jimmy-core-preferences"

   New-Item -ItemType Junction -Path "C:\Users\jaderson.almeida\.claude\skills\user\session-memoria" `
            -Target "C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\mandatory-skills\session-memoria"

   New-Item -ItemType Junction -Path "C:\Users\jaderson.almeida\.claude\skills\user\gdrive-sync-memoria" `
            -Target "C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\mandatory-skills\gdrive-sync-memoria"

   New-Item -ItemType Junction -Path "C:\Users\jaderson.almeida\.claude\skills\user\claude-session-registry" `
            -Target "C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\mandatory-skills\claude-session-registry"

   New-Item -ItemType Junction -Path "C:\Users\jaderson.almeida\.claude\skills\user\xavier-memory-sync" `
            -Target "C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\mandatory-skills\xavier-memory-sync"
   ```

6. **Verify Junction Points**
   ```powershell
   # List junctions
   Get-ChildItem "C:\Users\jaderson.almeida\.claude\skills\user\" |
       Where-Object {$_.Attributes -match "ReparsePoint"} |
       ForEach-Object {
           Write-Host "$($_.Name) -> $($_.Target)"
       }
   # Should show all 5 skills pointing to mandatory-skills/
   ```

7. **Test Skills Load in New Session**
   - [ ] Start new Claude Code session
   - [ ] Verify all skills load (check triggers work)
   - [ ] Test: "Xavier, memory status" (xavier-memory-sync)
   - [ ] Test: "X, busca tema teste" (session-memoria)
   - [ ] Exit session

8. **Git Push**
   ```bash
   git push origin main
   ```

**Verification:**
- ✅ All 5 mandatory skills moved
- ✅ Junction points recreated (show correct targets)
- ✅ Skills loadable in new Claude session
- ✅ Triggers work correctly
- ✅ Git push successful

**Exit Criteria:** Mandatory skills moved, junction points working, all skills loadable.

**Resume Point:** If session ends here, next session starts at Phase 4.

---

### **PHASE 4: MOVE PROJECT SKILLS & INFRASTRUCTURE (30 minutes)**

**Goal:** Move pbi-claude-skills to project-skills/. Move scripts, templates, CI/CD to infrastructure/.

**Tasks:**

1. **Move pbi-claude-skills**
   ```bash
   cd ~/Downloads/claude-intelligence-hub
   git mv pbi-claude-skills project-skills/
   git commit -m "refactor: move pbi-claude-skills to project-skills/"
   ```

2. **Update pbi-claude-skills Setup Script**

   **File: `project-skills/pbi-claude-skills/scripts/setup_new_project.ps1`**
   - Line ~13: Update hub URL (if needed)
   - Check for any hardcoded paths to hub root
   ```powershell
   # Update any references like:
   OLD: "$env:USERPROFILE\Downloads\claude-intelligence-hub\pbi-claude-skills"
   NEW: "$env:USERPROFILE\Downloads\claude-intelligence-hub\project-skills\pbi-claude-skills"
   ```

3. **Move Infrastructure Files**
   ```bash
   cd ~/Downloads/claude-intelligence-hub

   # Move scripts (already exists, so move contents)
   git mv scripts/* infrastructure/scripts/
   rmdir scripts

   # Move templates
   git mv templates/* infrastructure/templates/
   rmdir templates

   # Move CI/CD workflows (optional - can keep in .github)
   # git mv .github/workflows/* infrastructure/ci-cd/
   # Leave .github/workflows/ as-is (GitHub expects it there)

   git commit -m "refactor: move scripts and templates to infrastructure/"
   ```

4. **Update Script Paths (scripts now in infrastructure/scripts/)**

   **Files to Update:**
   - `infrastructure/scripts/setup_local_env.ps1` (update HubPath usage)
   - `infrastructure/scripts/setup_local_env.sh` (update HubPath usage)
   - `infrastructure/scripts/sync-versions.sh` (update relative paths)
   - Any other scripts referencing old paths

   **Example updates in setup_local_env.ps1:**
   ```powershell
   # No change to $HubPath variable (still points to repo root)
   # But update references to scripts themselves:
   OLD: ". $HubPath\scripts\setup_local_env.ps1"
   NEW: ". $HubPath\infrastructure\scripts\setup_local_env.ps1"
   ```

5. **Test Setup Scripts**
   ```powershell
   cd C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\infrastructure\scripts
   .\setup_local_env.ps1
   # Should recreate all junctions successfully
   ```

6. **Git Push**
   ```bash
   git push origin main
   ```

**Verification:**
- ✅ pbi-claude-skills moved to project-skills/
- ✅ Scripts moved to infrastructure/scripts/
- ✅ Templates moved to infrastructure/templates/
- ✅ Setup scripts work from new location
- ✅ Git push successful

**Exit Criteria:** All project skills and infrastructure moved, scripts functional.

**Resume Point:** If session ends here, next session starts at Phase 5.

---

### **PHASE 5: UPDATE DOCUMENTATION (60 minutes)**

**Goal:** Update ALL documentation to reflect new structure. Ensure consistency.

**Critical Files to Update:**

1. **README.md**
   - Update folder structure diagram
   - Update skill installation paths
   - Update quick start instructions
   - Update junction setup commands

2. **HUB_MAP.md**
   - Regenerate complete index with new paths
   - Update skill locations
   - Update script locations
   - Run `infrastructure/scripts/sync-versions.sh` (if it updates HUB_MAP)

3. **CHANGELOG.md**
   - Add entry for v2.0.0 (major restructure)
   ```markdown
   ## [2.0.0] - 2026-02-16

   ### Changed (BREAKING)
   - **Major repository restructure**: Separated system, mandatory-skills, project-skills, infrastructure
   - Hard links recreated at new paths
   - Junction points updated for new structure
   - All scripts updated with new paths

   ### Migration
   - See REORGANIZATION_ROADMAP.md for migration steps
   - Existing installations require re-running setup scripts
   ```

4. **docs/guides/WINDOWS_JUNCTION_SETUP.md**
   - Update junction creation commands with new paths
   - Update examples

5. **docs/guides/HANDOVER_GUIDE.md**
   - Update folder references
   - Update setup instructions

6. **All SKILL.md Files**
   - Update cross-references to other skills
   - Update example paths
   - Update related documentation links

7. **GOVERNANCE.md (system/xavier-memory/)**
   - Update paths to backup locations
   - Update sync script references

8. **EXECUTIVE_SUMMARY.md**
   - Update architecture diagram (if applicable)
   - Update folder counts

**Tasks:**

1. **Update README.md**
   ```markdown
   # Update structure section
   OLD:
   claude-intelligence-hub/
   ├── jimmy-core-preferences/
   ├── session-memoria/
   ...

   NEW:
   claude-intelligence-hub/
   ├── system/
   │   ├── xavier-memory/
   │   └── x-mem/
   ├── mandatory-skills/
   │   ├── jimmy-core-preferences/
   ...
   ```

2. **Regenerate HUB_MAP.md**
   - [ ] Manually update or use automation
   - [ ] Verify all paths correct
   - [ ] Verify all versions match .metadata files

3. **Update All SKILL.md Cross-References**
   - [ ] Search for references to old paths: `grep -r "claude-intelligence-hub/" mandatory-skills/*/SKILL.md`
   - [ ] Update each reference

4. **Run Validation**
   ```bash
   cd ~/Downloads/claude-intelligence-hub
   bash infrastructure/scripts/validate-readme.sh
   # Should pass all checks
   ```

5. **Git Commit Documentation Updates**
   ```bash
   git add -A
   git commit -m "docs: update all documentation for v2.0.0 structure"
   git push origin main
   ```

**Verification:**
- ✅ README.md accurate
- ✅ HUB_MAP.md reflects new structure
- ✅ CHANGELOG.md updated
- ✅ All cross-references valid
- ✅ validate-readme.sh passes
- ✅ Git push successful

**Exit Criteria:** All documentation updated, validation passing.

**Resume Point:** If session ends here, next session starts at Phase 6.

---

### **PHASE 6: FINAL TESTING & VERIFICATION (45 minutes)**

**Goal:** Comprehensive end-to-end testing to ensure NOTHING is broken.

**Test Categories:**

1. **Hard Links Test**
   ```powershell
   # Verify hard link count
   fsutil hardlink list "C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\system\xavier-memory\MEMORY.md"
   # Should show N+1 paths

   # Test editing propagation
   echo "# Test edit $(date)" >> C:\Users\jaderson.almeida\Downloads\claude-intelligence-hub\system\xavier-memory\MEMORY.md

   # Verify edit appears in project
   tail C:\Users\jaderson.almeida\.claude\projects\C--Users-jaderson-almeida-Downloads\memory\MEMORY.md
   # Should show test edit

   # Revert test edit
   git restore system/xavier-memory/MEMORY.md
   ```

2. **Junction Points Test**
   ```powershell
   # List all junctions
   Get-ChildItem "C:\Users\jaderson.almeida\.claude\skills\user\" |
       Where-Object {$_.Attributes -match "ReparsePoint"} |
       ForEach-Object {
           Write-Host "Testing: $($_.Name)"
           Test-Path "$($_.FullName)\SKILL.md"
       }
   # All should return True
   ```

3. **Skills Load Test**
   - [ ] Start fresh Claude Code session
   - [ ] Verify all skills load (check system messages)
   - [ ] Test each skill trigger:
     - "Xavier, memory status" (xavier-memory-sync)
     - "X, busca tema teste" (session-memoria)
     - "Xavier, sincroniza Google Drive" (gdrive-sync-memoria)
   - [ ] Exit session

4. **Backup Protocol Test**
   ```bash
   cd ~/Downloads/claude-intelligence-hub/system/xavier-memory
   bash sync-to-gdrive.sh
   # Should complete: Git check → Local backup → Google Drive sync
   ```

5. **Session Registry Test**
   - [ ] Start new session
   - [ ] Make some changes
   - [ ] Exit and copy session ID
   - [ ] Test: "Xavier, registra sessão [SESSION_ID]"
   - [ ] Verify entry created in `mandatory-skills/claude-session-registry/registry/`

6. **Scripts Test**
   ```bash
   cd ~/Downloads/claude-intelligence-hub/infrastructure/scripts

   # Test version sync
   bash sync-versions.sh jimmy-core-preferences

   # Test integrity check
   bash integrity-check.sh

   # Test README validation
   bash validate-readme.sh
   ```

7. **Git Operations Test**
   ```bash
   # Verify Git status clean
   git status
   # Should show: "nothing to commit, working tree clean"

   # Verify remote sync
   git fetch origin main
   git status
   # Should show: "Your branch is up to date with 'origin/main'"

   # Test pull
   git pull origin main
   # Should show: "Already up to date"
   ```

8. **CI/CD Test**
   - [ ] Push to GitHub (already done)
   - [ ] Check GitHub Actions run successfully
   - [ ] Verify integrity checks pass

**Verification Checklist:**
- [ ] Hard links: ✅ Working (N+1 paths, edits propagate)
- [ ] Junction points: ✅ All skills accessible
- [ ] Skills load: ✅ All triggers functional
- [ ] Backup protocol: ✅ Git + Google Drive sync working
- [ ] Session registry: ✅ Can register sessions
- [ ] Scripts: ✅ All scripts executable from new locations
- [ ] Git: ✅ Clean, synced with remote
- [ ] CI/CD: ✅ Pipelines passing

**Exit Criteria:** ALL tests passing, NO broken functionality.

---

### **PHASE 7: CLEANUP & FINALIZATION (15 minutes)**

**Goal:** Remove temporary files, update metadata, create release.

**Tasks:**

1. **Remove Temporary Files**
   - [ ] Delete `junctions-before.txt` (if created)
   - [ ] Delete `hardlinks-before.txt` (if created)
   - [ ] Delete any test files created during testing

2. **Update .metadata Files**
   - [ ] Update `system/xavier-memory/.metadata` to v1.2.0 (if needed)
   - [ ] Update other .metadata files if structure change affects them

3. **Create Git Tag for v2.0.0**
   ```bash
   git tag -a v2.0.0 -m "feat: major repository restructure - organized by category

   - Separated system infrastructure (xavier-memory, x-mem)
   - Organized mandatory skills into mandatory-skills/
   - Organized project skills into project-skills/
   - Consolidated infrastructure into infrastructure/
   - Reorganized documentation into docs/

   BREAKING CHANGES:
   - Hard links recreated at new paths
   - Junction points updated
   - All scripts updated with new paths
   - Requires re-running setup scripts for existing installations

   See REORGANIZATION_ROADMAP.md for migration details."

   git push origin v2.0.0
   ```

4. **Create GitHub Release**
   ```bash
   gh release create v2.0.0 \
       --title "v2.0.0 - Major Repository Restructure" \
       --notes "## 🎯 Major Reorganization

   The claude-intelligence-hub has been reorganized from a flat structure to a hierarchical, categorized structure for better clarity and maintainability.

   ### ✅ What Changed
   - **System infrastructure** moved to \`system/\`
   - **Mandatory skills** moved to \`mandatory-skills/\`
   - **Project skills** moved to \`project-skills/\`
   - **Infrastructure** consolidated in \`infrastructure/\`
   - **Documentation** reorganized in \`docs/\`

   ### ⚠️ Breaking Changes
   - Hard links recreated at new paths
   - Junction points updated
   - All scripts updated with new paths

   ### 🔧 Migration Required
   Existing installations must re-run setup scripts:
   \`\`\`bash
   cd ~/Downloads/claude-intelligence-hub/infrastructure/scripts
   ./setup_local_env.ps1  # Windows
   # or
   bash setup_local_env.sh  # Unix
   \`\`\`

   See \`REORGANIZATION_ROADMAP.md\` for complete migration details.

   ### 📊 Full Testing Completed
   - ✅ Hard links working
   - ✅ Junction points functional
   - ✅ All skills loadable
   - ✅ Backup protocol working
   - ✅ All scripts functional
   - ✅ CI/CD passing"
   ```

5. **Update Session Memoria**
   - [ ] Register this reorganization session
   - [ ] Create entry documenting the restructure

6. **Backup Final State**
   ```bash
   cd ~/Downloads/claude-intelligence-hub/system/xavier-memory
   bash sync-to-gdrive.sh
   # Final backup to Google Drive
   ```

**Verification:**
- ✅ Temporary files removed
- ✅ Git tag created
- ✅ GitHub release published
- ✅ Final backup completed

**Exit Criteria:** Repository clean, release published, final backup done.

---

## 🎯 SUCCESS CRITERIA

At the end of all phases, verify:

### Functional
- [x] Hard links working (fsutil shows N+1 paths)
- [x] All skills loadable in Claude Code
- [x] All scripts execute without errors
- [x] Backup protocol works (Git + Google Drive)
- [x] Session registry functional
- [x] Session memoria functional

### Documentation
- [x] README.md accurate and current
- [x] HUB_MAP.md reflects new structure
- [x] All SKILL.md cross-references valid
- [x] validate-readme.sh passes
- [x] CHANGELOG.md updated

### Integration
- [x] New session loads memory correctly
- [x] Skills invokable via triggers
- [x] Git operations work (commit, push, pull)
- [x] CI/CD pipelines pass

---

## 🔄 ROLLBACK PROCEDURE

If critical issues occur at ANY phase:

### Quick Rollback (Git)
```bash
# Note commit hash before reorganization
ROLLBACK_COMMIT="0346b38"  # Update with actual hash

# Reset to pre-reorganization state
git reset --hard $ROLLBACK_COMMIT
git push --force origin main  # CAUTION

# Recreate hard links (old structure)
cd ~/Downloads/claude-intelligence-hub/xavier-memory
./setup_memory_junctions.bat

# Recreate junctions (old structure)
cd ~/Downloads/claude-intelligence-hub/scripts
./setup_local_env.ps1
```

### Full Rollback (Backup)
```bash
# If Git rollback fails
1. Delete entire claude-intelligence-hub directory
2. Extract backup: claude-intelligence-hub-backup-2026-02-16.zip
3. Re-run setup_memory_junctions.bat
4. Re-run setup_local_env.ps1
5. Verify all skills load
```

---

## 📅 ESTIMATED TIMELINE

| Phase | Duration | Cumulative | Session |
|-------|----------|------------|---------|
| Phase 0: Preparation | 30 min | 0:30 | Session 1 |
| Phase 1: New Structure | 45 min | 1:15 | Session 1 |
| Phase 2: System Infrastructure | 60 min | 2:15 | Session 1 |
| **Break / Resume Point** | - | - | **End Session 1** |
| Phase 3: Mandatory Skills | 45 min | 3:00 | Session 2 |
| Phase 4: Project Skills & Infra | 30 min | 3:30 | Session 2 |
| Phase 5: Documentation | 60 min | 4:30 | Session 2 |
| Phase 6: Testing | 45 min | 5:15 | Session 2 |
| Phase 7: Cleanup | 15 min | 5:30 | Session 2 |

**Total:** ~5.5 hours across 2 sessions

---

## 📊 RISK ASSESSMENT

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| Hard link data loss | HIGH | LOW | Full backup before changes |
| Broken skills (junctions) | MEDIUM | MEDIUM | Document current state, quick recreation |
| Script failures | MEDIUM | LOW | Test each script after path updates |
| Documentation drift | LOW | MEDIUM | Use validation scripts, checklist |

---

## 🎯 CRITICAL SUCCESS FACTORS

1. **Full backup before starting** (Git + Google Drive + local zip)
2. **Phase-by-phase approach** (test after each phase, can resume)
3. **Document current state** (junctions, hard links, paths)
4. **Test thoroughly** (functional, integration, end-to-end)
5. **Follow rollback plan** (if anything goes wrong)

---

**Status:** Ready for implementation (tomorrow's session)
**Next Step:** Begin Phase 0 (Preparation)

---

**End of Roadmap**
