# Codex Governance Framework

---

## START HERE — If You Are New (No Technical Knowledge Required)

### What Is This Repository?

This is a rulebook for managing computer systems reliably.

Think of it like this:
- You have machines that need to work a certain way.
- You want to make changes to them safely.
- You want to know exactly what changed and be able to undo it.
- You never want silent failures (where something breaks and nobody notices).

**This framework gives you all of that.**

---

### What You Do NOT Need to Worry About

You do NOT need to:
- Understand the technical architecture (that's in the Technical Details section below).
- Learn PowerShell, JSON, or any programming language.
- Edit files manually.
- Remember complex commands.
- Figure out the right mode to use.
- Worry about making a mistake that silently breaks things.

**The framework prevents all of those problems.**

---

### Files You Should NEVER Edit Manually

Do NOT open and edit these files yourself:
- `.agents` (the framework manages this)
- `core_catalog.json` (ask the agent instead)
- `bootstrap_compat.json` (ask the agent instead)
- Any file in the `core_catalog/` folder

**Why?** Because if you edit them wrong, the system won't work. The framework has checks to catch mistakes, but only if you let the agent handle it.

---

### How You Interact With This System

You talk to the LLM agent in plain English.

That's it.

Examples:
- "Add a new skill called my-validator to GLOBAL CORE."
- "Run an audit to see what's different on my machines."
- "Sync all machines to the expected state."
- "What would change if I enabled onboard mode?"

**The agent handles everything else.**

The agent will:
1. Understand what you're asking.
2. Show you a plan.
3. Wait for you to approve.
4. Execute only what you approved.
5. Show you what changed.

---

### Example 1: Adding a New GLOBAL CORE Skill (5 Steps)

You want to add a new skill that validates system health.

**Step 1:** Write a file called `SKILL.md` in your skill folder. Describe what it does.

**Step 2:** Put your skill code in a folder (e.g., `my-health-validator/`).

**Step 3:** Talk to the agent: "Add my-health-validator as a new GLOBAL CORE skill."

**Step 4:** The agent shows you a plan. You say "approved" or ask questions.

**Step 5:** The agent adds it to the official catalog and runs checks. Done.

**Your skill is now in GLOBAL CORE and every machine will use it.**

---

### Example 2: Running Audit, Sync, or Onboard (5 Steps)

You want to check if your machines are set up correctly.

**Step 1:** Talk to the agent: "Run an audit to see what's different."

**Step 2:** The agent scans all machines and shows you differences (no changes made).

**Step 3:** If you want to fix those differences, say: "Sync the machines to the expected state."

**Step 4:** The agent shows you what will change before it changes anything.

**Step 5:** You say "approved" and the agent fixes everything. All changes are logged.

**Key point:** Audit shows differences. Sync fixes them. Nothing happens silently.

---

### Example 3: Updating a Skill Across Multiple Machines (4 Steps)

You found a bug in a skill. You fixed it. Now you need to deploy it.

**Step 1:** Update your skill code and update the version number (e.g., v1.0.0 → v1.0.1).

**Step 2:** Talk to the agent: "Deploy the updated version of my-skill to all machines."

**Step 3:** The agent shows you what will happen. You approve it.

**Step 4:** The agent updates the official catalog and all machines automatically get the new version.

**Result:** All machines run the new version. Old version is known and can be reverted if needed.

---

### GLOBAL CORE Skills vs. Optional Skillpacks

**GLOBAL CORE Skills:**
- Essential capabilities (like system auditing, machine setup).
- Every machine MUST have these.
- Lives in `core_catalog.json` (the official list).
- Cannot be disabled.
- Fully governed and versioned.

**Optional Skillpacks:**
- Extra capabilities that some machines might not need.
- Not in the official catalog yet.
- Can be tested and prepared before adding to GLOBAL CORE.
- Kept separate so the core stays stable.

**Think of it like this:**
- GLOBAL CORE = seat belts (every car has them, always on).
- Skillpacks = optional features (sunroof, fancy stereo—nice to have).

---

### The Framework Prevents Silent Mistakes

**Silent mistake** = something breaks and nobody notices until it's too late.

**This framework prevents that.**

Here's how:

- **Every change is logged.** You can see exactly what changed and when.
- **Audit mode is read-only.** You can check what's different without risk.
- **You always approve before changes.** The agent shows you the plan. You say yes or no.
- **Version numbers matter.** If something breaks, you know which version caused it and can roll back.
- **Failures are explicit.** If something goes wrong, the system stops and tells you (not silent).
- **Validation checks run automatically.** Bad changes get caught before they spread.

**Example of protection:**
You ask the agent to "sync machines." The agent will:
1. Show you what will change.
2. Wait for your approval.
3. Only then make changes.
4. Log every change.
5. If anything fails, stop immediately and report the error.

---

---

## What This Framework Does (Plain English)

Imagine you have important systems that need to stay consistent across multiple machines. The Codex Governance Framework is like having a playbook that:

- **Defines the "source of truth"** - one authoritative location (the HUB) that says what the correct state should be
- **Makes changes transparent** - any change must be intentional, logged, and verifiable
- **Prevents silent failures** - if something goes wrong, the system stops and reports it (fail-closed safety)
- **Enables safe rollback** - operators can understand exactly what changed and undo it if needed
- **Works with LLM agents** - you can talk to an intelligent agent in plain language to trigger governance operations

**In short**: This framework takes the guesswork out of infrastructure changes by using versioned contracts, deterministic processes, and operator-friendly playbooks.

---

## What Is a GLOBAL CORE Skill?

A **GLOBAL CORE skill** is a foundational capability that the governance framework relies on. Think of it as a building block.

Each GLOBAL CORE skill:
- Has a clear, documented purpose (what it does)
- Follows strict naming and metadata rules
- Must pass validation checks before being used
- Lives in the `core_catalog` (the official registry)
- Is version-controlled, so you always know what version you're running

**Example**: A skill that checks system drift, a skill that syncs state, or a skill that audits compliance.

---

## Quick Start

### 1. **Understand the Current State**
   - Read: `playbook/ARCHITECTURE_OVERVIEW.md`
   - This explains how the pieces fit together

### 2. **Learn the Operating Modes**
   - Read: `playbook/GOVERNANCE_PRINCIPLES.md`
   - This explains why the framework works the way it does

### 3. **See the Plan**
   - Read: `playbook/PHASE_SUMMARIES.md` and `playbook/ROADMAP_CHRONOLOGICAL.md`
   - This shows where we are and where we're going

### 4. **Trigger Operations**
   - Read the section below: **Talking to the LLM Agent**
   - Use copy-paste examples to request what you need

---

## How to Add a New GLOBAL CORE Skill (Step-by-Step)

### Prerequisites
- Your skill must have a clear, single purpose
- You must write a `SKILL.md` file documenting it
- You must follow semantic versioning (e.g., `v1.0.0`, `v1.0.1`)

### Steps

**Step 1: Create the Skill File Structure**
```
your-skill/
├── SKILL.md           (documentation file - required)
├── implementation/    (your code goes here)
└── tests/            (validation for your skill)
```

**Step 2: Write the SKILL.md File**
Your `SKILL.md` must include:
- **Purpose**: What does this skill do? (one sentence)
- **Activation triggers**: When should the LLM agent use this skill?
- **Authority constraints**: What is this skill NOT allowed to do?
- **Mode guidance**: How should it behave in different modes?
- **Prohibited actions**: What it never does

**Step 3: Add Your Skill to the Core Catalog**
Edit `core_catalog/core_catalog.json` and add an entry:
```json
{
  "skill_name": "your-skill",
  "version": "v1.0.0",
  "path": "path/to/your-skill",
  "required": true
}
```

**Step 4: Validate Against the Schema**
Your entry must:
- Use valid semantic versioning
- Have a unique path
- Match the catalog JSON schema
- Pass the deterministic loader check

**Step 5: Submit for Approval**
Talk to the LLM agent (see section below) and request:
- "Review and approve addition of the `[your-skill]` skill to GLOBAL CORE"
- The agent will confirm scope, present a plan, get approval, and execute

---

## Available Modes (Simple Table)

| Mode | Purpose | What Happens | Side Effects |
|------|---------|--------------|--------------|
| **on** | Normal operation | System is active and managing state | Changes may be made; fully logged |
| **off** | Safe deprovision | System is disabled, can be removed safely | No changes; compatibility checks skipped for clean removal |
| **sync** | Bring into alignment | Fixes drift between actual and expected state | Changes made to align; safe defaults used |
| **audit** | Check compliance (read-only) | Scans for drift without making any changes | None—purely informational |
| **onboard** | Guided setup | Audit → Sync → Audit sequence for clean deployment | Changes made; reports before and after state |

**Key principle**: Every mode logs its actions. Nothing happens silently.

---

## Talking to the LLM Agent (Copy-Paste Examples)

Use these natural language prompts when interacting with the agent:

### **Adding or Updating a Skill**
```
"Review the proposal to add [skill-name] as a new GLOBAL CORE skill.
Confirm scope, present an implementation plan, and execute with approval."
```

### **Auditing Current State**
```
"Run the governance audit in read-only mode.
Show me what's different between the expected state and the current state."
```

### **Synchronizing State**
```
"Sync the system to the canonical state defined in core_catalog.json.
Show me what will change, wait for approval, then execute."
```

### **Checking Compatibility**
```
"Verify that the current bootstrap version is compatible
with the version specified in core_catalog/bootstrap_compat.json."
```

### **Deploying a New Governance Version**
```
"Deploy v1.0.1 using the CI-ready governance contract.
Show me the plan, confirm all deterministic checks pass, and execute."
```

### **Rolling Back a Change**
```
"Revert the last change using the off mode.
Confirm this will safely remove the recent updates without breaking dependencies."
```

### **General Governance Help**
```
"What does [mode-name] mode do? When should I use it?"
```

---

## FAQ

**Q: Do I need to edit `.agents` files manually?**
A: No. The governance framework manages this. Talk to the LLM agent and request what you need.

**Q: What if I disagree with a governance decision?**
A: Governance decisions are documented in the planning/ folder. If you want to challenge one, request the agent to review and present alternatives.

**Q: Can I add a skill without going through the GLOBAL CORE process?**
A: You can write documentation for it, but it won't be active until it's added to `core_catalog.json` and approved. This separation keeps the framework stable.

**Q: What does "fail-closed safety" mean?**
A: If something goes wrong, the system stops instead of guessing. You'll get a clear error message so you know what to fix.

**Q: Why is everything versioned?**
A: Because predictability matters. If something breaks, you need to know exactly what changed. Versions let you roll back or understand the timeline.

**Q: How long does a sync take?**
A: It depends on what needs to change. The audit mode will show you what's different before sync runs, so you know what to expect.

**Q: Can the agent make changes without asking?**
A: No. The framework requires approval before any change happens. The agent will present a plan, wait for your confirmation, and only then execute.

**Q: What's the difference between audit and sync?**
A: **Audit** = look, don't touch. **Sync** = look, then fix. Both are safe; audit never changes anything.

**Q: Where do I find the current governance version?**
A: In `core_catalog/core_catalog.json`. The version field tells you what release is active.

---

## Technical Details

### Purpose

`codex-governance-framework` is the institutional documentation bundle for deterministic governance of the codex bootstrap architecture.

It defines structure, operating boundaries, and controlled next steps without changing runtime behavior by itself.

### Baseline and Compatibility Reference

- Baseline governance version: `v1.0.0`
- HUB compatibility reference commit: `e138718`

These references define the validated baseline used by this bundle.

### Relationship to codex-skill-adapter

- `codex-skill-adapter` is the runtime and packaging execution surface.
- This framework provides the governance contracts and operator guidance used to control that execution surface.
- This bundle is documentation-governance, not runtime activation.

### Folder Map

- `planning/`: institutional analysis and governance boundary documents.
- `next-steps/`: deferred but contract-defined milestone documents (including the `v1.0.1` CI-ready contract).
- `playbook/`: operator-facing execution references, phase summaries, architecture principles, and passive skill definition.

### Recommended Reading Order

1. `playbook/ARCHITECTURE_OVERVIEW.md`
2. `playbook/GOVERNANCE_PRINCIPLES.md`
3. `planning/EXECUTIVE_SUMMARY_CURRENT_STATE.md`
4. `playbook/ROADMAP_CHRONOLOGICAL.md`
5. `playbook/PHASE_SUMMARIES.md`
6. `playbook/STEP_BY_STEP_IMPLEMENTATION_GUIDE.md`
7. `next-steps/CONTRACT_v1.0.1_CI_READY_SCRIPT.md`
8. `playbook/SKILL.md`

### Current Governance Status

- Phase 5 baseline is complete.
- Phase 5.1 is deferred by governance decision.
- Skill remains passive and not catalog-activated in this state.

### Next Milestone

- `v1.0.1`: CI-ready governance check script contract implementation (`run-full-governance-check.ps1`) with deterministic output markers and stable exit semantics.

### Core Governance Principles

The framework enforces:

- **Contract-driven architecture**: Five explicit bootstrap modes (`on`, `off`, `sync`, `audit`, `onboard`) with fail-closed safety mechanisms
- **Compatibility governance**: Canonical authority maintained through `core_catalog.json` and separate compatibility contracts
- **Release discipline**: Semantic versioning with mandatory regression gates before any release tagging
- **Operational transparency**: Playbook-based procedures for rollout and rollback that operators can audit and execute
- **Deterministic verification**: All changes require verifiable, repeatable validation snapshots with explicit success markers

### Operational Flow

The system flows from contract definitions through bootstrap runtime operations (on/off/sync/audit/onboard modes) into structured execution logging, then regression validation before final release governance decisions involving semantic versioning and artifact verification.

### Skill Integration

New GLOBAL CORE skills must:

- Include a valid `SKILL.md` documentation file within their directory
- Be added to `core_catalog.json` with proper schema validation and semantic versioning
- Pass deterministic loader verification (regression gate with `FAIL_COUNT=0`)
- Include explicit authority constraints and prohibited action declarations
- Follow strict path uniqueness rules within the catalog

Skills can exist in documentation form before catalog activation, allowing preparation without premature exposure. Actual system integration represents a distinct governed change requiring separate approval.

### Mode Details

**Audit Mode**
- Read-only drift visibility without mutation
- Outputs findings with contract-coded status
- Safe compliance visibility mechanism without making changes
- Essential precursor to sync and onboard operations

**Sync Mode**
- Machine convergence to canonical state from `core_catalog.json`
- Deterministic reconciliation with safe-by-default behavior
- No silent mutations; all changes explicit and logged
- Supports optional purge operations under controlled governance

**Onboard Mode**
- Deterministic compliance onboarding through audit-before/sync/audit-after sequence
- Creates predictable machine compliance pathways
- Enforces purge lockouts and generates consolidated reports
- Combines visibility, action, and verification for clean deployments

**On/Off Modes**
- **On**: System actively manages state; changes logged and verifiable
- **Off**: Safe deprovision mode; allows version compatibility bypass for clean removal

### Authority and Validation

HUB serves as the canonical source for governance contracts and core definitions. The framework demands:

- Deterministic outcomes with explicit contract codes
- Fail-closed safety (failures trigger clear error states, not silent degradation)
- All modifications traceable with explicit bounds, logging, and audit trails
- Changes outside approved mission scope require separate approval processes

### Compatibility Controls

Version governance mechanisms compare catalog versions against allowable bootstrap ranges. Active modes (`on`, `sync`, `audit`, `onboard`) abort on mismatch; the `off` mode bypasses this check to allow safe deprovision.

### Structural Separation

Documentation and skill development precede formal activation. Actual system integration represents a distinct governed change requiring separate approval, preventing premature exposure of unvetted capabilities.

---

**For questions, feature requests, or to report issues, contact the repository maintainers.**
