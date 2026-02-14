# Token Budget Rules - Module 3 Governance

**Version:** 1.0.0
**Purpose:** Strict token usage rules for Claude Intelligence Hub
**Status:** Enforced (Module 3 Phase 2)

---

## Token Budget Thresholds

### Context Limits

| Level | Token Count | Percentage | Action |
|-------|-------------|------------|--------|
| **Ideal** | < 1,500 | < 1% | Target for standard responses |
| **Acceptable** | 1,500 - 3,000 | 1-2% | Allowed for complex tasks |
| **Warning** | 3,000 - 5,000 | 2-3% | Requires user permission |
| **Critical** | > 5,000 | > 3% | Blocked (ask user to split task) |

**Context Warning Threshold:** 50% of 200K limit = 100K tokens

### Per-Operation Limits

| Operation | Token Limit | Enforcement |
|-----------|-------------|-------------|
| **Standard response** | 1,500 | Soft (target) |
| **Complex task** | 3,000 | Hard (requires permission) |
| **Skill load** | 3,000 | Hard (pre-flight check) |
| **X-MEM query** | 15,000 | Hard (index + results) |
| **File read** | Variable | By file loading discipline |

---

## File Loading Discipline

### DO ✅

**Load strategically:**
- HUB_MAP.md index only (lines 1-20 for skill list)
- Skill sections (e.g., lines 51-96 for session-memoria)
- Use offset/limit parameters in Read tool
- Load logs: last 50 lines only (`tail -50`)
- Prefer Grep with context (-A/-B flags) over full Read

**Example:**
```
✅ Read: HUB_MAP.md (lines 1-20, ~500 tokens)
✅ Read: SKILL.md (lines 1-100, overview section, ~800 tokens)
✅ Bash: tail -50 logs/sync.log (~1K tokens)
✅ Grep: "error" logs/sync.log (-A 3 -B 3, ~500 tokens)
```

### DON'T ❌

**Avoid wasteful loads:**
- Load entire HUB_MAP.md (695 lines = ~3.5K tokens wasted)
- Load full skill files when section suffices
- Load historical files "just in case"
- Read files >500 lines without offset/limit
- Load unrelated documentation

**Example:**
```
❌ Read: HUB_MAP.md (full, 695 lines, 3.5K tokens)
❌ Read: logs/sync.log (full, 5000 lines, 25K tokens)
❌ Read: CHANGELOG.md (not needed for current task)
❌ Read: session-memoria/SKILL.md (full, when only need triggers)
```

---

## Response Size Targets

### By Task Type

**Standard Task:**
- Analysis: < 1K tokens
- Code generation: < 2K tokens
- Documentation: < 1.5K tokens
- **Target:** Stay under 1.5K tokens per response

**Complex Task:**
- Multi-file changes: < 3K tokens
- Architectural design: < 5K tokens (with permission)
- Comprehensive guides: Split into multiple responses
- **Target:** Get permission before exceeding 3K tokens

### Response Structure

**For responses approaching 3K tokens:**

```markdown
[Main content - 2.5K tokens]

---

⚠️ Response approaching 3K token limit.

Remaining topics:
- Topic A (est. 1.5K tokens)
- Topic B (est. 1K tokens)

Continue with:
A) Topic A only
B) Topic B only
C) Both (split into part 2)
D) Summary instead

Your choice?
```

---

## Pre-Flight Checks (MANDATORY)

### Before Loading Any Skill

**Execute this workflow:**

1. **Estimate Current Context Usage:**
   - Parse system reminder: `Token usage: X/200000`
   - Calculate percentage: `(X / 200000) × 100`
   - Determine remaining: `200000 - X`

2. **Threshold Check:**
   - If `X > 100000` (50%):
     - ⚠️ WARNING: "Context budget at {X}%. Continue or /compact first?"
     - Wait for user confirmation
     - Log warning in session transcript
   - If `X < 100000` (50%):
     - Proceed silently (no warning needed)

3. **Load HUB_MAP.md Index ONLY:**
   - Read: `HUB_MAP.md` (lines 1-20)
   - Token cost: ~500 tokens
   - **DO NOT** load full HUB_MAP.md (waste: 3,000 tokens)

4. **Identify Skill Section:**
   - From HUB_MAP.md index: find skill section range
   - Example: `session-memoria` → lines 51-96
   - Load ONLY that range (not full file)
   - Token cost: ~800 tokens per skill section

5. **Load Skill Files:**
   - Read skill's "Related files" from HUB_MAP.md section
   - Apply file loading discipline:
     - Files >500 lines: Load by section (offset/limit)
     - Logs: Last 50 lines (`tail -50`)
     - Indices: Full load OK (usually <100 lines)
   - **Total budget per skill activation: < 3K tokens**

### Pre-Flight Check Example

**Task:** Load session-memoria skill

**Step 1: Context Check**
```
System reminder: Token usage: 45000/200000
Percentage: 22.5%
Status: ✅ Under 50%, safe to proceed
```

**Step 2: HUB_MAP Index Load**
```
Read: HUB_MAP.md (lines 1-20)
Cost: ~500 tokens
Found: session-memoria at section ### 2 (lines 51-96)
```

**Step 3: Skill Section Load**
```
Read: HUB_MAP.md (lines 51-96)
Cost: ~800 tokens
Related files:
- session-memoria/SKILL.md (execution instructions)
- session-memoria/data/index.json (tier index)
```

**Step 4: Skill File Load**
```
Read: session-memoria/SKILL.md (lines 1-150, overview + commands)
Cost: ~1.2K tokens

Read: session-memoria/data/index.json (full, 50 lines)
Cost: ~300 tokens
```

**Total Cost: ~2.8K tokens** ✅ (under 3K limit)

---

## File Loading Decision Tree

```
File to load?
│
├─ Is it HUB_MAP.md?
│  ├─ Need full content? → REJECT (use index)
│  ├─ Need index only? → Read lines 1-20 ✅
│  └─ Need specific section? → Read lines X-Y ✅
│
├─ Is it >500 lines?
│  ├─ Need full file? → Ask permission
│  ├─ Need section? → Read with offset/limit ✅
│  └─ Not sure? → Start with first 100 lines ✅
│
├─ Is it a log file?
│  ├─ Need full history? → REJECT (use tail)
│  ├─ Need recent entries? → tail -50 ✅
│  └─ Need specific error? → Grep with context ✅
│
├─ Is it indexed (index.json)?
│  └─ Full load OK (usually <100 lines) ✅
│
├─ Is it documentation?
│  ├─ Directly related to task? → Full load OK ✅
│  ├─ Nice to have? → Skip for now
│  └─ Historical reference? → REJECT
│
└─ Default: Load strategically (offset/limit)
```

---

## Violation Handling

### Detected Violation: Loading Full File When Section Available

**Trigger:** About to `Read: HUB_MAP.md` (without offset/limit)

**Action:**
1. Stop the load
2. Report: "This file is 695 lines (~3.5K tokens). Load section instead?"
3. Offer: "Which section? (lines X-Y) or full file (requires permission)"
4. Wait for user choice

**Example:**
```
⚠️ FILE LOAD WARNING

You're about to load: HUB_MAP.md (full file)
Size: 695 lines (~3,500 tokens)

Alternatives:
A) Index only (lines 1-20, ~500 tokens) - Recommended
B) Specific section (e.g., lines 51-96 for session-memoria)
C) Full file (requires permission)

Your choice?
```

### Token Budget Exceeded Without Permission

**Trigger:** Response would exceed 3K tokens

**Action:**
1. Stop response generation at 2.5K tokens
2. Report: "Response would exceed 3K tokens (limit: 3K standard)"
3. Offer: "Split into parts? Or grant permission for long response?"
4. Wait for user confirmation

**Example:**
```
⚠️ RESPONSE SIZE WARNING

Current response: ~2,800 tokens
Remaining content: ~1,500 tokens
Total: ~4,300 tokens (exceeds 3K limit)

Options:
A) Split into Part 1 (current) + Part 2 (remaining)
B) Grant permission for long response (one-time)
C) Summarize remaining content instead

Your choice?
```

---

## Common Patterns

### Pattern 1: HUB_MAP.md Access

**BAD:**
```
Read: HUB_MAP.md
Result: 695 lines loaded (~3.5K tokens)
Waste: 3,000 tokens (if only needed index)
```

**GOOD:**
```
Read: HUB_MAP.md (lines 1-20)
Result: 20 lines loaded (~500 tokens)
Savings: 3,000 tokens (86% reduction)
```

### Pattern 2: Log File Access

**BAD:**
```
Read: logs/rclone-sync.log
Result: 5000 lines loaded (~25K tokens)
Waste: 24,000 tokens (if only needed recent errors)
```

**GOOD:**
```
Bash: tail -50 logs/rclone-sync.log
Result: 50 lines loaded (~1K tokens)
Savings: 24,000 tokens (96% reduction)
```

### Pattern 3: Skill Documentation

**BAD:**
```
Read: session-memoria/SKILL.md (full, 400 lines, ~2K tokens)
Read: session-memoria/README.md (full, 200 lines, ~1K tokens)
Read: session-memoria/CHANGELOG.md (full, 150 lines, ~750 tokens)
Total: ~3.75K tokens
```

**GOOD:**
```
Read: HUB_MAP.md (lines 51-96, session-memoria section, ~800 tokens)
Read: session-memoria/SKILL.md (lines 1-100, overview, ~800 tokens)
Total: ~1.6K tokens
Savings: 2.15K tokens (57% reduction)
```

---

## Anti-Patterns (REJECT)

### Anti-Pattern 1: "Just in Case" Loading

**Example:**
```
❌ Load HUB_MAP.md (full) - "might need it later"
❌ Load CHANGELOG.md (full) - "good to know history"
❌ Load all SKILL.md files - "to understand architecture"
```

**Fix:** Load on-demand, only when directly needed for current task.

### Anti-Pattern 2: Full Log Reads

**Example:**
```
❌ Read: logs/sync.log (5000 lines)
❌ Read: .git/logs/HEAD (hundreds of lines)
```

**Fix:** Use `tail -50` for recent entries, `grep` for specific errors.

### Anti-Pattern 3: Exceeding Limits Without Permission

**Example:**
```
❌ Write 8,000 token response without asking
❌ Load 10 skills simultaneously (30K tokens)
```

**Fix:** Ask permission before exceeding 3K tokens per response or operation.

---

## Token Usage Visibility

### On Request

**User:** "How's our token budget?"

**Response:**
```
📊 Current Session Token Budget

Used: ~52K tokens (26%)
Remaining: ~148K tokens (74%)

Context Health: ✅ Healthy
Safe Budget (50%): 100K tokens
Next Warning: At 100K tokens (50%)

Recent Operations:
- Loaded x-mem skill: ~2.8K tokens
- Generated response: ~1.5K tokens
- Loaded HUB_MAP index: ~500 tokens
```

### Automatic Warnings

**At 50% (100K tokens):**
```
⚠️ Context budget at 50% (100K tokens used)

Remaining: 100K tokens (50%)
Status: Yellow - monitor closely
Recommendation: Continue normally, but consider /compact if session will be long
```

**At 75% (150K tokens):**
```
⚠️⚠️ Context budget at 75% (150K tokens used)

Remaining: 50K tokens (25%)
Status: Orange - action recommended
Recommendation: /compact to preserve context for critical work
```

**At 90% (180K tokens):**
```
🚨 CRITICAL: Context budget at 90% (180K tokens used)

Remaining: 20K tokens (10%)
Status: Red - action required
Requirement: /compact REQUIRED to continue session safely

Creating snapshot before compacting...
```

---

## Integration with X-MEM

### X-MEM Token Accounting

**Per X-MEM Query Budget:**
- Index load: ~500 tokens (always)
- Search results: ~200 tokens per entry
- **Hard limit: 15,000 tokens per query**

**Calculation:**
```
available_for_entries = 15000 - 500 (index) = 14500 tokens
max_entries = 14500 / 200 = 72.5 → 70 entries (safe buffer)
```

**If Query Exceeds Limit:**
1. Show top 70 entries only
2. Display: "Showing 70 of 150 entries (15K token limit reached)"
3. Offer: "Refine search or load next page? (/xmem:search --offset=70)"

---

## Success Metrics

**Token efficiency goals:**
- **30-50% reduction** in token usage per session
- **<3K tokens** per skill load (vs ~6K baseline)
- **<1.5K tokens** per standard response (vs ~3K baseline)
- **Zero violations** of hard limits (3K response, 15K X-MEM)

**Monitoring:**
- Track token usage per session
- Measure before/after Module 3 implementation
- Report savings weekly

---

## Version History

**1.0.0 (2026-02-14)** - Initial release
- Token budget thresholds defined
- File loading discipline rules
- Pre-flight check protocol
- Response size targets
- Violation handling procedures

---

**Remember:** Token discipline = Context longevity = Better results.
