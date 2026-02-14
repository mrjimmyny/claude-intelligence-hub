# Token Economy - Module 3 Governance

**Version:** 1.0.0
**Purpose:** Enforce strict token budget discipline across all Claude Intelligence Hub operations
**Status:** Active (Module 3 Phase 2)

---

## Overview

Token Economy is a governance layer that enforces token budget discipline to minimize context waste and maximize efficiency across Claude sessions.

**Key Goals:**
- Reduce token usage by 30-50% per session
- Prevent full context loads when partial reads suffice
- Enforce response size limits (< 3K tokens standard)
- Provide visibility into token consumption

---

## Core Principles

### 1. Load Only What You Need

**BAD:**
```
Read: HUB_MAP.md (full file, 695 lines, ~3.5K tokens)
```

**GOOD:**
```
Read: HUB_MAP.md (lines 1-20, index only, ~500 tokens)
```

**Savings:** 86% (3,000 tokens saved)

### 2. Use Appropriate Tools

**BAD:**
```
Read: logs/sync.log (5000 lines, ~25K tokens)
```

**GOOD:**
```
Bash: tail -50 logs/sync.log (~1K tokens)
```

**Savings:** 96% (24,000 tokens saved)

### 3. Enforce Response Limits

**Standard Response Target:** < 1.5K tokens
**Complex Task Ceiling:** < 3K tokens
**Requires Permission:** > 3K tokens

**If response would exceed 3K:**
1. Stop generation
2. Ask: "Split into parts (A, B, C) or grant permission?"
3. Wait for user choice

---

## Token Budget Thresholds

| Context Usage | Action |
|---------------|--------|
| **0-50%** (0-100K) | Work normally |
| **50-75%** (100K-150K) | Warning: "Context at 50%, monitor closely" |
| **75-90%** (150K-180K) | Alert: "Context at 75%, consider /compact" |
| **90%+** (180K+) | Critical: "Context at 90%, /compact required" |

---

## File Loading Discipline

### Decision Tree

```
File to load?
├─ Is it HUB_MAP.md?
│  ├─ Yes: Load index only (lines 1-20) ✅
│  └─ No: Continue
├─ Is it >500 lines?
│  ├─ Yes: Load section with offset/limit ✅
│  └─ No: Load full file ✅
├─ Is it a log file?
│  ├─ Yes: Load last 50 lines only (tail) ✅
│  └─ No: Continue
└─ Load as appropriate ✅
```

### Common File Patterns

| File Type | Size | Load Strategy | Token Cost |
|-----------|------|---------------|------------|
| **HUB_MAP.md** | 695 lines | Index only (1-20) | ~500 |
| **SKILL.md** | 300+ lines | Section read (offset/limit) | ~800 |
| **Log files** | 1000+ lines | tail -50 | ~1K |
| **Index files** | <100 lines | Full read | ~300 |
| **CHANGELOG.md** | 100-200 lines | Full read | ~500 |

---

## Pre-Flight Token Check

**MANDATORY before ANY skill load:**

1. **Estimate Context Usage:**
   - Parse system reminder: "Token usage: X/200000"
   - Calculate percentage: (X / 200000) × 100

2. **Threshold Check:**
   - If > 100K (50%): Warn user
   - If > 150K (75%): Recommend /compact
   - If > 180K (90%): Require /compact

3. **HUB_MAP.md Load:**
   - Load ONLY lines 1-20 (index)
   - Token cost: ~500

4. **Skill Section Load:**
   - Identify section range from index
   - Load ONLY that range
   - Token cost: ~800 per section

5. **Skill File Load:**
   - Apply file loading discipline
   - Total budget per skill: < 3K tokens

---

## Response Size Targets

### By Task Type

| Task Type | Target Tokens | Example |
|-----------|---------------|---------|
| Simple query | < 500 | "What is X?" |
| Standard analysis | < 1.5K | "Explain how Y works" |
| Code generation | < 2K | "Write function Z" |
| Complex task | < 3K | "Refactor module A" |
| Multi-part | Split at 3K | "Design system B" |

### Violation Handling

**If response would exceed 3K tokens:**

1. **Stop generation** at 2.5K tokens
2. **Notify user:**
   ```
   Response would exceed 3K tokens (limit: 3K standard).

   Options:
   A) Split into parts (continue in next message)
   B) Grant permission for long response (one-time)
   C) Summarize instead

   Your choice?
   ```
3. **Wait for user confirmation**
4. **Log permission grant** (track patterns)

---

## Token Usage Visibility

### On User Request

**User:** "How's our token budget?"

**Response:**
```
📊 Current Session Token Budget

Used: ~45K tokens (22.5%)
Remaining: ~155K tokens (77.5%)
Safe Budget (50%): 100K tokens

Status: ✅ Healthy
```

### Automatic Warnings

**At 50% (100K tokens):**
```
⚠️ Context budget at 50% (100K tokens used)
Consider compacting if session will be long.
```

**At 75% (150K tokens):**
```
⚠️⚠️ Context budget at 75% (150K tokens used)
Recommend /compact to preserve context for critical work.
```

**At 90% (180K tokens):**
```
🚨 CRITICAL: Context budget at 90% (180K tokens used)
/compact REQUIRED to continue session safely.
```

---

## Integration with X-MEM

**X-MEM Token Accounting:**
- Index load: ~500 tokens (always)
- Search results: ~200 tokens per entry
- **Hard limit: 15K tokens per X-MEM query**

**If X-MEM query would exceed 15K:**
1. Show top 70 entries only (15K / 200 = 75, buffer = 70)
2. Display: "Showing 70 of 150 entries (15K token limit)"
3. Offer: "Refine search or load next page?"

---

## Best Practices

### DO ✅

- Load HUB_MAP.md index only (never full file)
- Use offset/limit for files >500 lines
- Use `tail -50` for log files
- Check context at 50% threshold
- Target <1.5K tokens per response
- Ask permission before exceeding 3K tokens

### DON'T ❌

- Load entire HUB_MAP.md (3.5K token waste)
- Load files "just in case" without clear need
- Read full historical logs or archives
- Exceed 3K token responses without permission
- Skip pre-flight token checks before skill loads
- Load documentation not directly related to task

---

## Examples

### Example 1: Efficient Skill Load

**Task:** Load session-memoria skill

**BAD Approach:**
```
1. Read: HUB_MAP.md (full, 695 lines) → 3.5K tokens
2. Read: session-memoria/SKILL.md (full, 400 lines) → 2K tokens
3. Read: session-memoria/README.md (200 lines) → 1K tokens
Total: ~6.5K tokens
```

**GOOD Approach:**
```
1. Read: HUB_MAP.md (lines 1-20, index only) → 500 tokens
2. Read: HUB_MAP.md (lines 51-96, session-memoria section) → 800 tokens
3. Read: session-memoria/SKILL.md (lines 1-100, overview) → 1K tokens
Total: ~2.3K tokens
```

**Savings:** 65% (4.2K tokens saved)

### Example 2: Log File Access

**Task:** Check rclone sync errors

**BAD Approach:**
```
Read: logs/rclone-sync.log (5000 lines) → 25K tokens
```

**GOOD Approach:**
```
Bash: tail -50 logs/rclone-sync.log → 1K tokens
```

**Savings:** 96% (24K tokens saved)

### Example 3: Response Size Control

**Task:** Explain Module 3 architecture

**Uncontrolled:**
```
[Xavier writes 8,000 token response covering everything]
Result: User overwhelmed, context budget damaged
```

**Controlled:**
```
[Xavier writes 2,500 token overview]
Xavier: "This covers the high-level architecture (2.5K tokens).

Would you like me to:
A) Deep dive into X-MEM Protocol (adds ~2K)
B) Deep dive into Token Economy (adds ~1.5K)
C) Deep dive into Incremental Indexing (adds ~1.5K)
D) All of the above (split into 3 parts)

Your choice?"
```

**Result:** User controls depth, context budget preserved

---

## Monitoring & Enforcement

### Automatic Monitoring

Token economy rules are enforced via:
- **jimmy-core-preferences Section 7** - Pre-flight checks
- **MEMORY.md patterns** - File loading discipline
- **System reminders** - Context usage tracking

### Manual Checks

**To verify token efficiency:**
```bash
# Check file sizes
ls -lh claude-intelligence-hub/*.md

# Count SKILL.md lines
wc -l */SKILL.md

# Review recent reads
# (check session transcript for Read tool calls)
```

---

## Version History

**1.0.0 (2026-02-14)** - Initial release
- Token budget thresholds defined
- File loading discipline documented
- Pre-flight check protocol
- Response size targets
- Integration with Section 7 (jimmy-core-preferences)

---

## Related Documentation

- **jimmy-core-preferences/SKILL.md** - Section 7 (enforcement rules)
- **MEMORY.md** - Token budget patterns
- **HUB_MAP.md** - Skill routing (load index only!)

---

**Remember:** Every token saved is context preserved for critical work.
