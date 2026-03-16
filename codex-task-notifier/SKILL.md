---
name: codex-task-notifier
description: Local Windows-first notifier for Codex task completion emails. Sends explicit task-end emails through an HTTPS pipeline (Resend -> Mailgun) without altering the Codex native UI. Use when the user asks to be notified by email at the end of a Codex task.
command: /codex-task-notifier
aliases: [/ctn]
---

# codex-task-notifier
**Version:** 1.0.0

## Objective

Send an explicit email notification at the end of a Codex task using the local HTTPS pipeline (Resend -> Mailgun failover), without modifying the Codex native UI or wrapping the `codex` command.

The recommended flow is: the agent runs `scripts\send-manual-notification.ps1` at the end of the task when the user has requested email notification.

## Non-Negotiable Rules

1. Never replace or wrap the `codex` command in any shell profile.
2. Never alter the Codex native TUI or UI surface.
3. Never store credentials (API keys, passwords) in markdown or git.
4. Always use the HTTPS channel (`Resend -> Mailgun`). SMTP is legacy fallback only.
5. Email subject must use the dynamic-agent pattern: `<AgentName> - Task Finished - <SHORT_ID>-<MACHINE_ID>`.

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

## Usage Example

```powershell
# Run at the end of a Codex task when email was requested
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1 `
  -TaskTitle "Review X" `
  -Summary "The requested review finished. Open Codex to inspect the final answer." `
  -AgentName "Magneto" `
  -LlmModel "Claude Sonnet 4.6"
```

Expected outcome: `delivery.status = sent`, email delivered to `mrjimmyny@gmail.com`.

## Transport Routing

- Active channel: `https`
- Provider order: `Resend -> Mailgun`
- Legacy path preserved: `smtp` (not active by default)
- Primary recipient: `mrjimmyny@gmail.com`
- Preferred sender: `notify@mrjimmyny.org`

## Cross-Machine Notes

- `C:\ai` is stable across machines — do not change.
- Runtime dirs under `%USERPROFILE%` are created automatically by the installer.
- Credentials must be re-set per machine (never shared via files or git).
- See `05-operationalization/codex-task-notifier-second-machine-onboarding-checklist-magneto-2026-03-15-v1.0.md` in the project docs for the full M2 onboarding checklist.
