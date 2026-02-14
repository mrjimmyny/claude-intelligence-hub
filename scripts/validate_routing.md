# Skill Routing Validation Test Suite

**Version:** 1.0.0
**Created:** 2026-02-14
**Purpose:** Comprehensive validation of Tier 2 skill routing infrastructure
**Coverage:** All 5 Ciclope Rules (#1-5)
**Runtime:** ~10 minutes (manual execution)

---

## 🎯 Overview

This test suite validates the Module 2 Governance and Routing Infrastructure by simulating real-world user interactions and verifying that:

1. **Active Routing** (Ciclope Rule #1): Skills are automatically loaded when triggers are detected
2. **Proactive Transparency** (Ciclope Rule #2): Context-based suggestions work correctly
3. **Veto Rules** (Ciclope Rule #3): Duplicate implementations are blocked
4. **Golden Close Protocol** (Ciclope Rule #4): Sessions end with proper skill routing
5. **Zero Tolerance** (Ciclope Rule #5): Hub integrity is maintained

---

## Test Scenario 1: session-memoria Trigger Detection (Tier 2)

### 🎭 User Input Simulation
```
User: "Xavier, registre isso no meu conhecimento permanente"
```

### ✅ Expected Behavior
1. Xavier detects trigger phrase "registre isso" (from HUB_MAP.md Tier 2 triggers)
2. session-memoria skill loads automatically (auto-load trigger)
3. SKILL.md content executes Pattern 4: Session-Memoria Registration workflow
4. User sees 8-step workflow execution (arquivo, frontmatter, tags, etc.)
5. Git commit created with session summary
6. No manual intervention required

### 🔍 Test Commands (Read-Only Verification)

```bash
# Verify trigger exists in HUB_MAP.md
grep -A5 "registre isso" claude-intelligence-hub/HUB_MAP.md

# Expected output: Trigger listed under session-memoria Tier 2 triggers
# Line should contain: "registre isso" | "registra isso" | "salva isso"

# Verify skill has auto-load enabled
grep "auto_load" claude-intelligence-hub/session-memoria/.metadata

# Expected: "auto_load": true

# Verify Pattern 4 workflow documented
grep -A20 "Pattern 4: Session-Memoria Registration" claude-intelligence-hub/session-memoria/SKILL.md

# Expected: 8-step workflow documented (Passo 1-8)
```

### ✔️ Pass Criteria
- [ ] Trigger phrase found in HUB_MAP.md Tier 2 section
- [ ] session-memoria .metadata has auto_load: true
- [ ] SKILL.md contains complete Pattern 4 workflow (8 steps)
- [ ] No errors in grep output

### 📊 Validates
- **Ciclope Rule #1:** Active Routing (trigger → auto-load → execution)
- **Ciclope Rule #2:** Transparency (user sees workflow execution)

---

## Test Scenario 2: Context-Based Proactive Suggestion

### 🎭 Context Simulation
```
# Simulated environment
Current directory: C:\Users\jimmy\project-name\
Files present: report.pbip, data-model.bim
User task: "Help me document this Power BI project"
```

### ✅ Expected Behavior
1. Xavier detects `.pbip` file extension in working directory
2. HUB_MAP.md Pattern 6 (Context-Based Activation) triggers
3. Xavier proactively suggests: "I notice you're working with a Power BI project (.pbip). Would you like me to load the pbi-claude-skills for specialized Power BI assistance?"
4. If user accepts: pbi-claude-skills loads, specialized workflows available
5. If user declines: Xavier proceeds with general-purpose tools

### 🔍 Test Commands (Read-Only Verification)

```bash
# Verify context detection pattern exists
grep -A10 "Context-Based Activation" claude-intelligence-hub/HUB_MAP.md

# Expected: Pattern 6 documented with file extension triggers

# Verify pbi-claude-skills is production-ready
ls -la claude-intelligence-hub/pbi-claude-skills/

# Expected: README.md, SKILL.md, .metadata present

# Verify HUB_MAP.md lists pbi-claude-skills triggers
grep -A5 "pbi-claude-skills" claude-intelligence-hub/HUB_MAP.md

# Expected: File extensions listed (.pbip, .bim, etc.)
```

### ✔️ Pass Criteria
- [ ] Pattern 6 (Context-Based Activation) documented in HUB_MAP.md
- [ ] pbi-claude-skills has complete documentation (README, SKILL.md)
- [ ] File extension triggers documented in HUB_MAP.md
- [ ] Suggestion is optional (user can decline)

### 📊 Validates
- **Ciclope Rule #2:** Proactive Transparency (context → suggestion → user choice)
- **Ciclope Rule #1:** Active Routing (context detection works)

---

## Test Scenario 3: Veto Rule Enforcement

### 🎭 User Input Simulation
```
User: "Xavier, create a Python script to sync files from my Google Drive to a local folder. I want it to run automatically every hour."
```

### ✅ Expected Behavior
1. Xavier detects intent: "Google Drive sync automation"
2. Ciclope Rule #3 (Veto) activates: Checks if skill exists for this task
3. HUB_MAP.md search finds: gdrive-sync-memoria (v1.0.0) - Production Ready
4. Xavier **BLOCKS** implementation and responds:
   ```
   I notice you're requesting Google Drive sync functionality. This capability already exists in the gdrive-sync-memoria skill (v1.0.0).

   Existing solution:
   - Automatic sync using rclone (gdrive-jimmy: remote)
   - Folders: _tobe_registered → _registered_claude_session_memoria
   - Session-memoria integration built-in
   - Git push automation included

   Would you like me to:
   1. Execute the existing skill (/gdrive-sync)
   2. Show you the documentation (gdrive-sync-memoria/SKILL.md)
   3. Explain how to customize the existing sync workflow

   ⚠️ Creating a duplicate implementation would violate Ciclope Rule #3 (Zero Tolerance for Duplication).
   ```
5. User chooses option 1, 2, or 3
6. No duplicate code written

### 🔍 Test Commands (Read-Only Verification)

```bash
# Verify gdrive-sync-memoria exists and is production-ready
ls -la claude-intelligence-hub/gdrive-sync-memoria/

# Expected: README.md, SKILL.md, sync-gdrive.sh, .metadata

# Verify skill is marked Production Ready in HUB_MAP.md
grep -A10 "gdrive-sync-memoria" claude-intelligence-hub/HUB_MAP.md

# Expected: Status: ✅ Production Ready

# Verify Ciclope Rule #3 documented in jimmy-core-preferences
grep -A15 "Ciclope Rule #3" claude-intelligence-hub/jimmy-core-preferences/SKILL.md

# Expected: Veto rule documented with "block duplicate implementations"
```

### ✔️ Pass Criteria
- [ ] gdrive-sync-memoria skill exists with complete documentation
- [ ] Skill marked as Production Ready in HUB_MAP.md
- [ ] Ciclope Rule #3 documented in jimmy-core-preferences SKILL.md
- [ ] Rule explicitly states: "Veto duplicate implementations"

### 📊 Validates
- **Ciclope Rule #3:** Veto Rules (block duplicate functionality)
- **Ciclope Rule #1:** Active Routing (skill detection before implementation)

---

## Test Scenario 4: Zero Tolerance Hub Validation

### 🎭 Trigger Simulation
```
# Automatic trigger: Session start (every Xavier session)
# OR manual trigger: User requests "/hub-check"
```

### ✅ Expected Behavior
1. Xavier reads HUB_MAP.md on session initialization
2. Pattern 7 (Golden Close Protocol) activates
3. Hub integrity checks run:
   - All skills listed in HUB_MAP.md exist in ~/.claude/skills/user/
   - All .metadata files match HUB_MAP.md versions
   - No orphaned skills (exist in filesystem but not in HUB_MAP.md)
   - No version drift between .metadata and SKILL.md headers
4. If issues found: Xavier articulates disorder and proposes fix
5. If clean: Silent success (no user notification needed)

### 🔍 Test Commands (Read-Only Verification)

```bash
# List all skills in HUB_MAP.md (Production Ready tier)
grep -E "^\d+\. " claude-intelligence-hub/HUB_MAP.md | grep -E "v[0-9]+\.[0-9]+\.[0-9]+"

# Expected output: List of skills with versions
# Example: 1. jimmy-core-preferences (v1.5.0)

# List all skills in filesystem
ls -1d ~/.claude/skills/user/*/

# Expected: Matching list with HUB_MAP.md

# Check for version alignment (jimmy-core-preferences example)
echo "=== SKILL.md version ===" && grep "Version:" claude-intelligence-hub/jimmy-core-preferences/SKILL.md
echo "=== .metadata version ===" && grep "version" claude-intelligence-hub/jimmy-core-preferences/.metadata
echo "=== HUB_MAP.md version ===" && grep "jimmy-core-preferences (v" claude-intelligence-hub/HUB_MAP.md

# Expected: All three show v1.5.0

# Detect orphaned skills (exist in filesystem but not in HUB_MAP.md)
for skill in ~/.claude/skills/user/*/; do
  skill_name=$(basename "$skill")
  grep -q "$skill_name" claude-intelligence-hub/HUB_MAP.md || echo "⚠️ Orphaned: $skill_name"
done

# Expected: No output (no orphaned skills)
```

### ✔️ Pass Criteria
- [ ] All skills in HUB_MAP.md exist in filesystem
- [ ] All skills in filesystem are documented in HUB_MAP.md
- [ ] Versions match across .metadata, SKILL.md, and HUB_MAP.md
- [ ] Golden Close Protocol documented in jimmy-core-preferences SKILL.md

### 📊 Validates
- **Ciclope Rule #5:** Zero Tolerance for hub drift
- **Ciclope Rule #4:** Golden Close Protocol (session-level validation)

---

## 🧪 Test Execution Workflow

### Manual Execution Steps

1. **Pre-Test Setup**
   ```bash
   cd claude-intelligence-hub
   git status  # Ensure clean working tree
   ```

2. **Run Test Scenario 1**
   - Execute verification commands
   - Record pass/fail status
   - Note any anomalies

3. **Run Test Scenario 2**
   - Repeat for Scenario 2 commands
   - Verify context detection logic

4. **Run Test Scenario 3**
   - Repeat for Scenario 3 commands
   - Confirm veto rule enforcement

5. **Run Test Scenario 4**
   - Repeat for Scenario 4 commands
   - Check hub integrity

6. **Post-Test Summary**
   ```bash
   # Generate test report
   echo "=== Module 2 Validation Results ==="
   echo "Scenario 1 (Trigger Detection): [PASS/FAIL]"
   echo "Scenario 2 (Context Suggestion): [PASS/FAIL]"
   echo "Scenario 3 (Veto Rule): [PASS/FAIL]"
   echo "Scenario 4 (Hub Integrity): [PASS/FAIL]"
   echo ""
   echo "Overall Status: [PASS/FAIL]"
   ```

---

## 📋 Regression Prevention Checklist

Before releasing Module 2 updates, verify:

- [ ] **Test Scenario 1 passes:** Tier 2 triggers detected and routed
- [ ] **Test Scenario 2 passes:** Context-based suggestions work
- [ ] **Test Scenario 3 passes:** Duplicate implementations blocked
- [ ] **Test Scenario 4 passes:** Hub integrity maintained
- [ ] **All Ciclope Rules (#1-5) validated**
- [ ] **No version drift** (run Scenario 4 commands)
- [ ] **HUB_MAP.md up-to-date** (all production skills listed)
- [ ] **No orphaned skills** (filesystem matches HUB_MAP.md)

---

## 🔧 Troubleshooting

### Scenario 1 Fails (Trigger Not Detected)
**Symptom:** grep finds no trigger in HUB_MAP.md
**Fix:** Add trigger to HUB_MAP.md Tier 2 section for session-memoria
**Root cause:** HUB_MAP.md outdated or trigger removed accidentally

### Scenario 2 Fails (Context Not Detected)
**Symptom:** Pattern 6 not documented in HUB_MAP.md
**Fix:** Document Context-Based Activation pattern
**Root cause:** Pattern 6 missing from HUB_MAP.md

### Scenario 3 Fails (Veto Not Enforced)
**Symptom:** Ciclope Rule #3 not documented
**Fix:** Add veto rule to jimmy-core-preferences SKILL.md
**Root cause:** Governance rules incomplete

### Scenario 4 Fails (Version Drift Detected)
**Symptom:** .metadata version ≠ SKILL.md version
**Fix:** Synchronize versions (see Module 2 plan Step 1)
**Root cause:** Manual edit didn't update all files

---

## 📈 Success Metrics

### Quantitative
- **100% test scenarios pass** (4/4)
- **0 orphaned skills** detected
- **0 version mismatches** found
- **5/5 Ciclope Rules validated**

### Qualitative
- User confidence in skill routing
- Zero duplicate implementations created
- Hub integrity maintained over time
- Transparent skill activation (user always knows why)

---

## 🔄 Maintenance

### Monthly Review
- Re-run all 4 test scenarios
- Update expected outputs if skills evolved
- Add new scenarios for new patterns

### Quarterly Deep Dive
- Validate against production usage patterns
- Interview user (Jimmy) for pain points
- Refine test scenarios based on real-world edge cases

### On Skill Addition
- Add new skill to Scenario 4 validation commands
- Update HUB_MAP.md skill count in test expectations

---

**Test Suite Status:** ✅ Complete
**Last Validated:** 2026-02-14
**Next Review:** 2026-03-14 (Monthly)
**Maintained by:** Xavier & Jimmy
