# Agent Orchestration Protocol (AOP)

**Version:** 4.0.0-rc.1 | **Status:** Production-Validated (v3.0.0), Release Candidate (v4.0.0-rc.1) | **Category:** Multi-Agent Coordination

AOP is a methodology for coordinating independent headless agent processes via shell commands. An Orchestrator launches one or more Executor agents as separate OS processes, monitors their completion via artifact polling, and verifies their work before reporting back to the user. v4.0 adds multi-executor orchestration with DAG-based task dependencies, deadlock detection, priority scheduling, and fan-in/fan-out coordination.

Full reference: [SKILL.md](./SKILL.md) | Worked examples: [AOP_WORKED_EXAMPLES.md](./AOP_WORKED_EXAMPLES.md) | Version history: [CHANGELOG.md](./CHANGELOG.md)

---

## What AOP Is — and What It Is NOT

| Aspect | Internal Sub-agent (NOT AOP) | AOP Headless Session (Real AOP) |
| :--- | :--- | :--- |
| **Process** | Child of parent session | Independent OS process |
| **Context** | Shares parent context | Clean, isolated context |
| **Launch** | Agent tool / internal API call | `claude -p` / `codex exec` / `gemini -p` in shell |
| **Completion** | Synchronous return | Requires polling (Pillar 4) |
| **Pillar 1 compliant** | No | Yes |

**Rule:** If the Orchestrator does not run a shell command (`Bash` tool, terminal, PowerShell), it is NOT AOP. Internal sub-agent tools are useful — they are just a different pattern.

---

## Quick Start

```bash
# Step 1: Write executor prompt to a file
SESSION_ID="$(date +%s | tail -c 5)"
PROMPT_FILE="AOP_PROMPT_${SESSION_ID}.md"
ARTIFACT="AOP_COMPLETE_${SESSION_ID}.json"

cat > "${PROMPT_FILE}" << 'PROMPT_EOF'
You are an Executor Agent. Your working directory: /c/ai/target-project

WRITE SCOPE: /c/ai/target-project/src/, /c/ai/target-project/AOP_COMPLETE_${SESSION_ID}.json

TASK:
[detailed task instructions here]

COMPLETION REQUIREMENT:
As your LAST action, write AOP_COMPLETE_${SESSION_ID}.json with status SUCCESS.
PROMPT_EOF

# Step 2: Launch headless executor
cd /c/ai/target-project
cat "${PROMPT_FILE}" | claude -p --dangerously-skip-permissions --model claude-sonnet-4-6 &
EXECUTOR_PID=$!
echo "Executor PID: $EXECUTOR_PID"

# Step 3: Poll for completion artifact
POLLS=0; MAX_POLLS=20
while [ $POLLS -lt $MAX_POLLS ]; do
  test -f "${ARTIFACT}" && test -s "${ARTIFACT}" && { echo "Done."; cat "${ARTIFACT}"; break; }
  POLLS=$((POLLS+1))
  [ $POLLS -le 4 ] && sleep 30 || sleep 60
done
[ $POLLS -ge $MAX_POLLS ] && kill "${EXECUTOR_PID}"

# Step 4: Cleanup after success
rm -f "${PROMPT_FILE}" "${ARTIFACT}"
```

---

## The Seven Pillars

AOP is structured around seven operational pillars. Each pillar has a definition, an implementation command, and a verification test. See [SKILL.md](./SKILL.md) for the full actionable checklist.

| Pillar | Core Rule |
| :--- | :--- |
| **1. Environment Isolation** | Executors are independent OS processes — not sub-agents of the parent session |
| **2. Absolute Referencing** | All paths are absolute. Relative paths cause silent failures |
| **3. Permission Bypass** | Bypass flags are used only in pre-approved trusted workspaces |
| **4. Active Vigilance** | Orchestrator polls for a completion artifact — never waits synchronously |
| **5. Integrity Verification** | Orchestrator independently verifies outputs, not just the artifact status |
| **6. Closeout Protocol** | Always returns explicit `SUCCESS` or `FAIL` with concrete evidence |
| **7. Constraint Adaptation** | If Orchestrator cannot access a resource, it delegates to a properly-scoped executor |

---

## Multi-Executor Orchestration (v4.0)

v4.0 introduces full multi-executor coordination:

- **Parallel Dispatch** — Fan-out N executors with disjoint write paths, fan-in results into a single aggregation artifact.
- **Task Dependencies (DAG)** — Declare `depends_on` relationships between tasks. The DAG engine dispatches tasks in dependency order with cycle detection.
- **Priority Scheduling** — CRITICAL/HIGH/MEDIUM/LOW priority levels with weight-based secondary sorting and priority-adjusted timeouts.
- **Bounded Concurrency** — `MAX_CONCURRENT` limits parallel executor count with priority-ordered dispatch queue.
- **Deadlock Detection** — 4-stage escalation (NORMAL → WARN → ESCALATE → DEADLOCK) monitors stalled workflows.
- **Crash Recovery** — Orchestrator State File enables resumption after Orchestrator crash.
- **Event-Driven Detection** — Fast-polling (3s) or file watcher (<1s) for multi-executor artifact monitoring.

Single-executor workflows continue to work with the simpler v3.0 patterns. See [SKILL.md](./SKILL.md) for the full protocol.

---

## File-Based Prompt Pattern

The file-based prompt is the production-proven default for complex executor instructions. Piping a `.md` file avoids all shell escaping issues with code blocks, JSON, tables, and special characters.

```bash
# Write prompt to file — avoids escaping issues
cat > AOP_PROMPT_${SESSION_ID}.md << 'EOF'
[full executor instructions here]
EOF

# Pipe file into headless executor
cat AOP_PROMPT_${SESSION_ID}.md | claude -p --dangerously-skip-permissions --model claude-sonnet-4-6 &
```

Use inline `claude -p "..."` only for simple instructions with no special characters or code blocks.

For the complete prompt template with `write_paths` declaration and completion artifact schema, see [SKILL.md — Execution Standard](./SKILL.md#execution-standard).

---

## Polling and Completion

Polling is artifact-based — the Executor writes a JSON file as its last action. The Orchestrator polls for this file:

```bash
test -f AOP_COMPLETE_${SESSION_ID}.json && test -s AOP_COMPLETE_${SESSION_ID}.json
```

**Key rules:**
- Non-empty check is mandatory (`test -s`): a 0-byte file means the executor crashed mid-write.
- Maximum 20 polls (~14 min). After timeout, kill the executor and escalate.
- Adaptive intervals: 30s for the first 4 polls, then 60s.

For the full polling loop, error recovery, and rollback protocol, see [SKILL.md — Polling and Error Recovery](./SKILL.md#polling--completion).

---

## Security Boundaries

Every executor session requires:

1. **Trusted workspace verification** — confirm the target path is in the pre-approved allow-list before launching with bypass flags.
2. **`write_paths` declaration** — every executor prompt must declare what it is allowed to write.
3. **Post-execution git diff check** — compare files written against the declared scope.

Bypass flags skip interactive prompts — they do NOT grant new capabilities or OS-level permissions.

Do not use bypass flags for production repositories without a PR review step, system directories, credential stores, or paths outside the trusted allow-list.

Full details in [SKILL.md — Security Boundaries](./SKILL.md#security-boundaries).

---

## Production Case Studies

Real-world executions are documented in [orchestrations/](./orchestrations/). Each case study includes a JSON execution report, documentation, metrics, and pillar verification.

**Featured Case Studies:**

- **[Chain Delegation with Sub-Orchestration](./orchestrations/2026-02-25_chain-delegation/)** — Multi-level delegation where an Executor acts as both Executor and Sub-Orchestrator, delegating to a third agent. Demonstrates cross-LLM orchestration (Claude → Codex → Gemini) with 100% success rate.

- **[docx-indexer W1+W2 Production Execution](./orchestrations/2026-03-16_docx-indexer-w1w2/)** — First real production AOP: an Opus 4.6 Orchestrator launches a Sonnet 4.6 headless Executor to implement 11 code findings across 8 files. File-based prompt, artifact-based polling, documentation delegation. 372/372 tests maintained.

---

## Cross-LLM Reference

AOP works with any orchestrator CLI. See [SKILL.md — Cross-LLM Command Reference](./SKILL.md#cross-llm-command-reference) for the full table including known quirks.

| Task | Claude Code | Codex | Gemini |
| :--- | :--- | :--- | :--- |
| Headless execution | `claude -p "..."` | `codex exec "..."` | `gemini -p "..."` |
| File-based prompt | `cat FILE \| claude -p` | `cat FILE \| codex exec` | `cat FILE \| gemini -p --approval-mode yolo` |
| Bypass flag | `--dangerously-skip-permissions` | `--dangerously-bypass-approvals-and-sandbox` | `--approval-mode yolo` |
| Default model | `claude-sonnet-4-6` (Tier 2) | `gpt-5.2-codex` (Tier 2 — DEFAULT) | `gemini-2.5-flash` (Tier 2) |
| Background | Append `&` | Append `&` | Append `&` |

> **Model Selection:** All dispatches MUST select the appropriate model. See SKILL.md § Model Selection for the full cross-provider equivalence table (Tier 1 through Tier 3, with Codex-specific Tier 1.5 and 2.5). The LLM Model Selection Guide v2.2.0 has 36 task examples and official Codex routing logic.

---

## Lessons from Production

1. **Sub-agents are not AOP.** Internal sub-agent tools run inside the parent session. Real AOP requires `claude -p` / `codex exec` / `gemini -p` launching an independent OS process.
2. **File-based prompts for complex instructions.** Write the executor prompt to a `.md` file and pipe via `cat file | claude -p`. Eliminates all escaping issues with code, tables, and special characters.
3. **Artifact-based completion detection.** Have the Executor write a JSON file as its last step. The Orchestrator polls for this file. More reliable than parsing stdout.
4. **Executors handle documentation reliably.** With precise instructions (absolute paths, exact content, formatting rules), executors update structured documents as reliably as code.
5. **Prompt quality determines success.** The more precise the prompt (exact scope, verification steps, completion format), the fewer iterations needed.

---

**Version:** 4.0.0-rc.1 | **Status:** Release Candidate | **Last Updated:** 2026-03-18
See [CHANGELOG.md](./CHANGELOG.md) for full version history.
