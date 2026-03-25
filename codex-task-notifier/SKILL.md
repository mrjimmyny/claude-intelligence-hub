---
name: codex-task-notifier
description: Local Windows-first notifier for Codex task completion emails. Sends explicit task-end emails through an HTTPS pipeline (Resend -> Mailgun) without altering the Codex native UI. Use when the user asks to be notified by email at the end of a Codex task.
command: /codex-task-notifier
aliases: [/ctn]
---

# codex-task-notifier
**Version:** 1.2.0

## Objective

Send an explicit email notification at the end of a Codex task using the local HTTPS pipeline (Resend -> Mailgun failover), without modifying the Codex native UI or wrapping the `codex` command.

The recommended flow is: the agent runs `scripts\send-manual-notification.ps1` at the end of the task when the user has requested email notification.

## Non-Negotiable Rules

1. Never replace or wrap the `codex` command in any shell profile.
2. Never alter the Codex native TUI or UI surface.
3. Never store credentials (API keys, passwords) in markdown or git.
4. Always use the HTTPS channel (`Resend -> Mailgun`). SMTP is legacy fallback only.
5. Email subject must use the dynamic-agent pattern: `<AgentName> - Task Finished - <SHORT_ID>-<MACHINE_ID>`.
6. **Email sending order (R-14):** gws CLI (default, `--html` for HTML) → Resend CLI/PS → GWS Gmail MCP (last resort). See `jimmy-core-preferences` Section R (R-14).
7. **CRITICAL:** When using gws CLI with HTML body, ALWAYS include `--html` flag: `gws gmail +send --to X --subject Y --body "<html>" --html`. Without it, HTML renders as raw text (FND-0033).

## Natural Language Triggers

When the user says any of these (English or Portuguese), run `send-manual-notification.ps1`:

| User says | Action |
|-----------|--------|
| `email me when done` | Run `send-manual-notification.ps1` at task end |
| `send completion email` | Run `send-manual-notification.ps1` at task end |
| `send an email at the end` | Run `send-manual-notification.ps1` at task end |
| `send me an email when done` | Run `send-manual-notification.ps1` at task end |
| `me avise por email no final` | Run `send-manual-notification.ps1` ao final da tarefa |
| `me manda um email` | Run `send-manual-notification.ps1` ao final da tarefa |
| `mande um email quando terminar` | Run `send-manual-notification.ps1` ao final da tarefa |
| `send the result by email` | Run with `-Attachment` if there's an output file |
| `email me the infographic` | Run with `-Attachment <file>` |
| `me manda o resultado por email` | Run with `-Attachment <arquivo>` |

## Required Paths

- Skill root: `C:\ai\_skills\codex-task-notifier\`
- Main script: `C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1`
- Installer: `C:\ai\_skills\codex-task-notifier\scripts\install-codex-task-notifier.ps1`
- Validator: `C:\ai\_skills\codex-task-notifier\scripts\validate-codex-task-notifier.ps1`
- Runtime (dynamic per user): `%USERPROFILE%\.codex-task-notifier\`

`C:\ai` is the only fixed path. All paths under `%USERPROFILE%` are resolved dynamically at runtime.

## Required Environment Variables

Must be set in User scope on each machine before the first use:

| Variable | Required | Description |
|---|---|---|
| `CTN_RESEND_API_KEY` | Yes (tier 1) | Resend API key |
| `CTN_RESEND_FROM` | Yes (tier 1) | Sender address for Resend (`notify@mrjimmyny.org`) |
| `CTN_MAILGUN_API_KEY` | Yes (tier 2) | Mailgun API key |
| `CTN_MAILGUN_FROM` | Yes (tier 2) | Sender address for Mailgun |
| `CTN_MAILGUN_DOMAIN` | Yes (tier 2) | Mailgun sending domain (`mg.mrjimmyny.org`) |
| `CTN_MAILGUN_BASE_URL` | No | Mailgun API base URL (default: `https://api.mailgun.net`) |

## Install on a New Machine

```powershell
# 1. Confirm the workspace exists under C:\ai
Test-Path C:\ai\_skills\codex-task-notifier   # must return True

# 2. Run installer (creates runtime dirs, copies settings template)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\codex-task-notifier\scripts\install-codex-task-notifier.ps1

# 3. Set credentials in User env (do NOT store API keys in files)
[Environment]::SetEnvironmentVariable('CTN_RESEND_API_KEY', '<key>', 'User')
[Environment]::SetEnvironmentVariable('CTN_RESEND_FROM',    'notify@mrjimmyny.org', 'User')
[Environment]::SetEnvironmentVariable('CTN_MAILGUN_API_KEY', '<key>', 'User')
[Environment]::SetEnvironmentVariable('CTN_MAILGUN_FROM',    'notify@mg.mrjimmyny.org', 'User')
[Environment]::SetEnvironmentVariable('CTN_MAILGUN_DOMAIN',  'mg.mrjimmyny.org', 'User')
[Environment]::SetEnvironmentVariable('CTN_MAILGUN_BASE_URL','https://api.mailgun.net', 'User')

# 4. Validate (open a new shell first to pick up User env)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\codex-task-notifier\scripts\validate-codex-task-notifier.ps1
# Expected: 3/3 PASS, resend_ready=true, mailgun_ready=true
```

## Usage Examples

### Basic Examples (by agent)

```powershell
# Magneto (Claude Code) — standard task completion
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1 `
  -TaskTitle "Review X" `
  -Summary "The requested review finished. Open Codex to inspect the final answer." `
  -AgentName "Magneto" `
  -LlmModel "Claude Sonnet 4.6"

# Magneto (Claude Code) — with file attachment
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1 `
  -TaskTitle "Infographic Generated" `
  -Summary "Corporate infographic created and attached." `
  -AgentName "Magneto" `
  -LlmModel "Claude Opus 4.6" `
  -Attachment "C:\ai\_skills\notebooklmx\test-output\phase03-batch2\style-08-collage.png"

# Emma (Codex) — standard coding task
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1 `
  -TaskTitle "API Endpoint Implemented" `
  -Summary "Implemented /api/v2/users endpoint with full CRUD. Tests pass 12/12." `
  -AgentName "Emma" `
  -LlmModel "GPT-5.2-codex"

# Emma (Codex) — complex multi-agent orchestration
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1 `
  -TaskTitle "AOP Parallel Dispatch Complete" `
  -Summary "5-agent parallel workflow finished. All agents completed successfully. Report consolidated." `
  -AgentName "Emma" `
  -LlmModel "GPT-5.3-codex"

# Emma (Codex) — architecture/planning task
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1 `
  -TaskTitle "Architecture Review Done" `
  -Summary "Microservice architecture reviewed. 3 recommendations documented in decisoes.md." `
  -AgentName "Emma" `
  -LlmModel "GPT-5.4"

# Forge (Gemini) — implementation task
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1 `
  -TaskTitle "Module Refactored" `
  -Summary "Auth middleware refactored per compliance requirements. All tests green." `
  -AgentName "Forge" `
  -LlmModel "Gemini 2.5 Flash"
```

### Model Reference for -LlmModel Parameter

| Agent | Model | When to Use |
|---|---|---|
| Magneto | `Claude Opus 4.6` | Architecture, audits, deep synthesis (Tier 1) |
| Magneto | `Claude Sonnet 4.6` | Standard implementation, coding (Tier 2 — DEFAULT) |
| Magneto | `Claude Haiku 4.5` | Mechanical tasks, templates (Tier 3) |
| Emma | `GPT-5.4` | Architecture, planning, reasoning (Tier 1) |
| Emma | `GPT-5.3-codex` | Complex multi-step, multi-agent orchestration (Tier 1.5) |
| Emma | `GPT-5.2-codex` | Standard coding, refactoring (Tier 2 — DEFAULT for Codex) |
| Emma | `GPT-5.1-codex` | High stability, consistent output (Tier 2.5) |
| Emma | `GPT-5.1-codex-max` | Large context, many files, long sessions (Tier 2.5) |
| Emma | `GPT-5-codex-mini` | Simple, repetitive, fast (Tier 3) |
| Emma | `GPT-5.4-mini` | Light reasoning with speed (Tier 2) |
| Forge | `Gemini 2.5 Pro` | Complex reasoning, large context (Tier 1) |
| Forge | `Gemini 2.5 Flash` | Standard implementation, agentic tasks (Tier 2) |
| Forge | `Gemini 2.5 Flash-Lite` | Mechanical, bulk, fast (Tier 3) |

Expected outcome: `delivery.status = sent`, email delivered to `mrjimmyny@gmail.com`.

## Attachment Support

The `-Attachment` parameter accepts a file path. When provided:

- **Resend** (tier 1): File is base64-encoded and sent in the JSON body as `attachments[]`
- **Mailgun** (tier 2): File is sent as multipart form data with field name `attachment`
- If the file path is invalid or the file does not exist, the email is sent **without** the attachment (no error)
- The existing failover chain (Resend -> Mailgun) works identically with or without attachments

## Transport Routing

- Active channel: `https`
- Provider order: `Resend -> Mailgun`
- Legacy path preserved: `smtp` (not active by default)
- Primary recipient: `mrjimmyny@gmail.com`
- Preferred sender: `notify@mrjimmyny.org`

## Resend CLI (Alternative Channel)

As of 2026-03-24, the **Resend CLI** (`resend-cli` v1.6.0) is installed globally and available as an alternative to the PowerShell HTTP pipeline for Resend operations.

**Installation (already done on M1):**
```powershell
# Windows (PowerShell)
irm https://resend.com/install.ps1 | iex
# Or via npm (cross-platform)
npm install -g resend-cli
```

**Authentication for agents:**
```bash
# Authenticate using existing CTN_RESEND_API_KEY (no browser needed)
resend login --key $CTN_RESEND_API_KEY
# Or pass key inline per command
resend emails send --api-key $CTN_RESEND_API_KEY ...
```

**Send email via CLI:**
```bash
resend emails send \
  --from "notify@mrjimmyny.org" \
  --to "mrjimmyny@gmail.com" \
  --subject "Magneto - Task Finished" \
  --html "<p>Task completed successfully.</p>"
```

**Key features for agents:**
- `--json` flag or piped output → machine-readable JSON (ideal for automated validation)
- `--api-key` flag → direct auth without browser login
- `--quiet` → suppresses spinners, implies JSON
- Idempotency keys supported for safe retries
- 53 commands across 13 resources (emails, domains, API keys, contacts, broadcasts, webhooks, etc.)

**When to use Resend CLI vs PowerShell pipeline:**
| Scenario | Recommended |
|---|---|
| Standard task-end notification | PowerShell `send-manual-notification.ps1` (production-proven) |
| Quick ad-hoc email from any agent | `resend emails send` CLI (simpler, no PS dependency) |
| Agents without PowerShell (Linux, Codex) | Resend CLI (cross-platform via npm) |
| Email with attachment | PowerShell pipeline (base64 handling built-in) |
| Domain/API key management | Resend CLI (`resend domains`, `resend api-keys`) |

**Important:** The PowerShell pipeline remains the primary production path with full failover (Resend → Mailgun). The Resend CLI is a complementary tool, not a replacement. It does NOT have Mailgun failover built in.

## Email Templates (examples/)

Ready-to-use HTML templates at `examples/`. Agents MUST use these as reference when composing HTML emails — they define the visual standard Jimmy expects.

| Template | Use When |
|---|---|
| `01-executive-summary.html` | Session summary with findings, deliverables, files changed |
| `02-table-report.html` | Structured data with clean table headers, columns, metrics |
| `03-status-update.html` | Quick bullet-point status (completed/in-progress/next/blockers) |
| `04-project-portfolio.html` | Multi-project overview with status pills and priorities |
| `05-finding-alert.html` | Critical finding notification with full detail card |

**Design rules:** Segoe UI font, 680px max-width, #e63946 accent, #1a1a2e headers, alternating row backgrounds (#f8f9fa), status colors (#d4edda green, #fff3cd yellow, #f8d7da red). See `examples/README.md` for full guide.

**How to use:** Read the relevant template, replace `{{PLACEHOLDER}}` values with actual data, pass as `--body` with `--html` flag via gws CLI.

## Cross-Machine Notes

- `C:\ai` is stable across machines — do not change.
- Runtime dirs under `%USERPROFILE%` are created automatically by the installer.
- Credentials must be re-set per machine (never shared via files or git).
- See `05-operationalization/codex-task-notifier-second-machine-onboarding-checklist-magneto-2026-03-15-v1.0.md` in the project docs for the full M2 onboarding checklist.
