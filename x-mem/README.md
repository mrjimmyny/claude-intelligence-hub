# X-MEM Protocol

**Version:** 1.0.0
**Type:** Knowledge Management (Self-Learning)
**Status:** Production

---

## Overview

X-MEM (eXperience MEMory) is a self-learning protocol that captures tool failures and success patterns across Claude sessions. It prevents repeated errors by building institutional knowledge of what works and what doesn't.

**Think of it as:** A developer's notebook that Claude actively consults when tools fail.

---

## Why X-MEM?

**Problem:** Claude forgets failures across sessions. Same errors repeat, wasting time.

**Solution:** X-MEM records failures + successes in structured format, enables proactive recall when patterns recur.

**Benefits:**
- ⏱️ **Faster debugging:** Recall past failures instantly
- 🧠 **Learning across sessions:** Build knowledge over time
- 🎯 **Proactive suggestions:** "I've seen this error before. Try X."
- 📊 **Pattern recognition:** Identify common failure modes

---

## Quick Start

### 1. Record Your First Failure

When a command fails:

```
/xmem:record failure
```

Claude will prompt for:
- Tool name (e.g., `rclone`)
- Command attempted
- Error message
- Pattern to avoid (what NOT to do)
- Tags

### 2. Search Past Failures

```
/xmem:search tool=rclone
/xmem:search tag=git-commit
/xmem:search network timeout
```

### 3. Let X-MEM Help Proactively

X-MEM automatically detects tool failures and offers to recall past experiences:

```
🔍 I found 2 previous failures with this tool. Review? (yes/no)
```

---

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/xmem:load` | Load X-MEM context | `/xmem:load tool=git` |
| `/xmem:record` | Record failure/success | `/xmem:record failure` |
| `/xmem:search` | Search entries | `/xmem:search rclone` |
| `/xmem:stats` | Show statistics | `/xmem:stats` |
| `/xmem:compact` | Prune stale entries | `/xmem:compact` |

---

## Data Structure

```
x-mem/
├── data/
│   ├── failures.jsonl    # Tool failures (NDJSON)
│   ├── successes.jsonl   # Success patterns (NDJSON)
│   └── index.json        # Fast search index
└── scripts/
    ├── xmem-search.sh    # Search helper
    ├── xmem-compact.sh   # Compaction utility
    └── xmem-stats.sh     # Statistics generator
```

### Failure Entry Example

```json
{
  "id": "2026-02-14-001",
  "tool": "rclone",
  "action": "sync gdrive-jimmy:folder /local/path",
  "error": "Failed to create file system: didn't find section in config file",
  "pattern_avoid": "Verify remote name exists before sync",
  "tried_also": ["rclone ls", "rclone config show"],
  "tags": ["rclone", "gdrive", "config"],
  "ctx_hash": "rclone-sync-config-not-found"
}
```

### Success Entry Example

```json
{
  "id": "2026-02-14-002",
  "tool": "git",
  "pattern_name": "Atomic commit with Co-Authored-By",
  "key_steps": [
    "Stage specific files only",
    "Use HEREDOC for multi-line commit message",
    "Include Co-Authored-By trailer"
  ],
  "confidence": 0.95,
  "usage_count": 12,
  "tags": ["git", "commit"]
}
```

---

## Integration

**With jimmy-core-preferences:**
- Pattern 6 (Proactive Recall) automatically detects failures
- Suggests X-MEM searches when tools fail
- No manual intervention needed

**With session-memoria:**
- Cross-reference X-MEM entries in session knowledge
- Link failures to specific sessions
- Track learning progress over time

---

## Token Budget

**Design Goal:** Minimize token usage while maximizing value.

**Limits:**
- Index query: ~500 tokens (always)
- Per entry: ~200 tokens
- **Hard limit: 15,000 tokens per query**

**Typical Usage:**
- Proactive recall: 500-1,000 tokens
- Search query: 1,000-3,000 tokens
- Record operation: ~300 tokens

---

## Workflow Examples

### Example 1: Tool Failure Captured

**Scenario:** `rclone sync` fails with "remote not found"

**What Happens:**
1. Command fails (exit code ≠ 0)
2. Xavier detects failure via Pattern 6
3. Computes context hash: `rclone-sync-config-not-found`
4. Checks X-MEM index (500 tokens)
5. No match found
6. Xavier: "Record this failure in X-MEM?"
7. User: "yes"
8. Entry created, index updated, Git push

**Next Time:**
1. Same error occurs
2. Xavier: "🔍 I found 1 previous failure (2 days ago). Review?"
3. User: "yes"
4. Xavier shows entry + suggests solution
5. User tries solution → Success!

### Example 2: Success Pattern Learned

**Scenario:** Git commit works perfectly with HEREDOC format

**What Happens:**
1. User: `/xmem:record success`
2. Xavier prompts for pattern details
3. Entry created:
   - Pattern: "Git commit with HEREDOC"
   - Key steps documented
   - Confidence: 1.0 (first success)
4. Git push

**Future Sessions:**
1. User needs to commit
2. Xavier recalls pattern automatically
3. Applies proven approach
4. Increments `usage_count` on success

---

## Maintenance

**No daily maintenance required.** X-MEM is designed for hands-off operation.

**Optional Monthly Task:**
```
/xmem:compact
```

This removes:
- Duplicate entries (same ctx_hash within 7 days)
- Stale entries (older than 365 days)

**Backup:** Compaction creates backup in `data/backup/` before changes.

---

## Best Practices

### DO ✅
- Record failures that blocked progress >5 minutes
- Tag entries with relevant keywords
- Review X-MEM suggestions before debugging
- Record success patterns after solving complex issues
- Run `/xmem:stats` monthly to identify trends

### DON'T ❌
- Record trivial typos or one-off issues
- Skip pattern_avoid field (critical for learning)
- Ignore proactive recall suggestions
- Let X-MEM data grow unbounded (compact quarterly)

---

## FAQ

**Q: How is X-MEM different from session-memoria?**
A: session-memoria is human-readable knowledge (markdown). X-MEM is machine-optimized (NDJSON), focused on tool failures/successes.

**Q: Will X-MEM auto-record every failure?**
A: No. Auto-capture is disabled by default. Xavier suggests recording, you confirm.

**Q: How do I export X-MEM data?**
A: Data is in NDJSON format (plain text). Use: `cat data/failures.jsonl | jq .`

**Q: Can I manually edit NDJSON files?**
A: Yes, but use caution. Ensure valid JSON per line. Rebuild index after: `/xmem:compact --rebuild-index`

**Q: What if two sessions record same failure?**
A: Compaction detects duplicates via ctx_hash and merges/prunes.

---

## Troubleshooting

**Problem:** "Index out of sync" warning

**Solution:**
```
/xmem:compact --rebuild-index
```

**Problem:** Search returns no results (but entries exist)

**Cause:** Index not updated after manual NDJSON edit

**Solution:**
```
/xmem:compact --rebuild-index
```

**Problem:** Token limit exceeded during search

**Cause:** Too many matching entries (>70)

**Solution:** Refine search:
```
/xmem:search tool=rclone tag=config limit=20
```

---

## Version History

**1.0.0 (2026-02-14)** - Initial release
- Failure/success recording
- Index-based search
- Proactive recall integration (Pattern 6)
- NDJSON storage format
- 15K token budget enforcement

---

## Related Skills

- **jimmy-core-preferences** - Pattern 6 (Proactive Recall)
- **session-memoria** - Cross-reference knowledge entries
- **gdrive-sync-memoria** - Sync X-MEM data to cloud (future)

---

## License

Part of Claude Intelligence Hub
Author: Xavier (Claude) & Jimmy
Created: 2026-02-14
