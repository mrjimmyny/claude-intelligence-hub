---
name: microsoft-mail-deliver
description: Microsoft-native task-end email delivery skill for CIH agents. Use when the goal is to send explicit completion emails through Microsoft 365 services instead of Gmail, Resend, or Mailgun, while preserving the native Codex workflow and enterprise governance constraints.
command: /microsoft-mail-deliver
aliases: [/mmd]
---

# microsoft-mail-deliver

**Version:** 1.1.0
**Stage:** Published

## Objective

Provide the Microsoft-native email protocol for CIH agents when Jimmy explicitly wants the send to happen through Microsoft 365 instead of the default Gmail/Resend/Mailgun notifier stack.

## Current Direction

The active implementation target is:
- Microsoft Graph delegated auth from the local machine using the `up4a` profile by default

Fallback order:
- `havas_pending` delegated profile after tenant approval
- Power Automate bridge
- Microsoft Graph app-only
- SMTP AUTH with OAuth

## Non-Negotiable Rules

1. Never store secrets, tokens, or passwords in markdown or git.
2. Never replace or wrap the native `codex` command.
3. Prefer already-licensed Microsoft services before paid add-ons.
4. Keep enterprise approval requirements explicit.
5. Do not claim tenant permissions that have not been validated.
6. If Jimmy says `via Microsoft` or equivalent, use this protocol and do not ask whether Gmail/Resend/Mailgun should be used.
7. For outbound business emails on Jimmy's behalf:
   - `To` must be exactly the recipient(s) Jimmy provides
   - `Cc` must always include `jaderson.almeida@br.havasvillage.com`
   - title is mandatory; if Jimmy does not provide it, do not send
   - subject is always uppercase
   - body must follow the frozen executive format defined in `templates\business-email-contract.json`

## Required Paths

- Skill root: `C:\ai\_skills\microsoft-mail-deliver\`
- Project docs: `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\`
- Active profile config: `C:\ai\_skills\microsoft-mail-deliver\config.profiles.json`
- Sender scripts:
  - `C:\ai\_skills\microsoft-mail-deliver\scripts\validate-microsoft-mail-deliver.ps1`
  - `C:\ai\_skills\microsoft-mail-deliver\scripts\send-microsoft-mail.ps1`
  - `C:\ai\_skills\microsoft-mail-deliver\scripts\compose-microsoft-business-email.ps1`
  - `C:\ai\_skills\microsoft-mail-deliver\scripts\send-microsoft-business-email.ps1`
  - `C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1`
- Contract file:
  - `C:\ai\_skills\microsoft-mail-deliver\templates\business-email-contract.json`
- Known recipients registry:
  - `C:\ai\_skills\microsoft-mail-deliver\data\known-recipients.json`

## Natural Language Trigger

If Jimmy asks for email `via Microsoft`, `do Microsoft`, `pelo up4a`, or equivalent, interpret that as:
- transport = `microsoft-mail-deliver`
- default runtime profile = `up4a`
- `havas_pending` stays preserved for future reactivation only

Do not ask whether Gmail/Resend/Mailgun should be used unless Jimmy explicitly asks to compare transports.

## Outbound Email Contract

For business emails sent on Jimmy's behalf through this skill:

- Greeting:
  - `Olá, bom dia / boa tarde / boa noite.`
  - `Agente <name>, <platform>, <LLM model>`
- Mandatory intro: explain the email is being sent at Jimmy's request and replies should go to `jaderson.almeida@br.havasvillage.com`
- Body style: formal, professional, executive, short, direct, simple wording
- Signature:
  - `Atenciosamente,`
  - `Agente <name>, <platform>, <LLM model>`
  - `On behalf of Jimmy`

Runtime notes:
- `scripts\send-microsoft-mail.ps1` uppercases the subject before delivery
- `scripts\send-microsoft-mail.ps1` defaults `Cc` to `jaderson.almeida@br.havasvillage.com`
- both `To` and `Cc` accept multiple recipients separated by comma or semicolon
- `scripts\send-microsoft-mail.ps1` also accepts the selectors `all`, `@all`, `known:all`, and `known-recipients:all` to expand Jimmy's saved Microsoft recipient registry into one comma-separated `To` list
- `scripts\send-microsoft-mail.ps1` supports attachments
- `scripts\send-microsoft-mail.ps1` now supports `-MessageFormat Auto|Json|Mime`; `Auto` promotes multi-external-`To` sends to MIME so Exchange receives a standards-based message body instead of the JSON payload path
- `scripts\send-microsoft-business-email.ps1` is the standard business-email entrypoint and composes the mandatory greeting / intro / signature automatically
- `scripts\manage-known-recipients.ps1` is the canonical registry manager for Jimmy's saved Microsoft recipient list:
  - `-Action Add` adds one or many addresses (accepts `-Enabled $true/$false` and `-Level operational/middle/high`)
  - `-Action List` returns the current registry
  - `-Action Summary -OutputFormat MarkdownTable` renders the numbered alphabetical table for chat (includes Enabled and Level columns)
  - `-Action Remove` / `-Action Delete` removes one or many addresses
  - `-Action Update` changes `enabled` and/or `level` for existing recipients (requires `-Emails` plus at least one of `-Enabled` or `-Level`)
  - `-Action Resolve -Emails all` returns the ready-to-send comma-separated `To` string — **only enabled recipients are included when using `known:all`** (FND-0048 second safety layer)
- Graph `202 Accepted` is treated as transport acceptance only, not final delivery proof
- external sends from `onmicrosoft.com` sender profiles remain unverified until recipient confirmation or mailbox/admin evidence exists
- external multi-recipient batch delivery now prefers the MIME transport path; split-send remains diagnostic only and is NOT the approved final behavior

## Critical Safety Rules (FND-0048 — Non-Negotiable)

These rules apply to ALL agents using this skill. No exceptions. No interpretation.

### Rule 1 — `known:all` Requires Explicit Jimmy Approval

The `known:all` / `all` / `@all` / `known-recipients:all` selectors MUST NOT be used unless Jimmy **explicitly and literally** writes in the current message that the email should go to the list/all recipients. Examples of valid authorization:
- "send to all", "send to the list", "known:all", "manda pra lista"

If Jimmy says "send me an email" or "me manda um email" — that means send to Jimmy ONLY, not to any list. **The script enforces this:** `send-microsoft-mail.ps1` will BLOCK `known:all` unless `-ConfirmKnownAll` switch is passed.

**Second safety layer (v1.1.0):** Even when `known:all` is authorized and `-ConfirmKnownAll` is passed, recipients with `enabled: false` in the registry are **automatically excluded** from the resolved list. Only `enabled: true` recipients receive batch emails. Direct targeting of a specific disabled email is still possible (explicit choice).

### Rule 2 — Default Recipient

When Jimmy does NOT specify a recipient, the default is:
```
up4a@up4aoffice.com
```
This is Jimmy's own Microsoft email. This is NOT `mrjimmyny@gmail.com` (that belongs to the Codex Task Notifier protocol). Each skill has its own default — do not mix them.

### Rule 3 — Title is Mandatory

No email may be sent without a title/subject provided by Jimmy. If Jimmy does not specify a title, the agent MUST ask for one. Do NOT fabricate a title. The `send-microsoft-business-email.ps1` already enforces this at script level.

### Rule 4 — Pre-Send Confirmation

Before sending any email, the agent MUST present a summary to Jimmy for approval:
```
To: [recipient]
Subject: [UPPERCASE SUBJECT]
Body preview: [first 2 lines]
```
Then wait for Jimmy's "ok" / "dispara" / "go" before executing. Exception: Jimmy may pre-authorize the send in the same message where he defines all parameters (to, subject, body).

### Rule 5 — HTML Auto-Detection

`send-microsoft-mail.ps1` now auto-detects HTML in the Body parameter. If the body contains HTML tags, `BodyContentType` is automatically promoted from `Text` to `HTML`. Agents should still use `send-microsoft-business-email.ps1` for formatted emails (it always sends as HTML).

### Rule 6 — Skill Exclusivity

When Jimmy says "via Microsoft" or "protocolo Microsoft", the agent MUST use this skill and ONLY this skill. Do not fall back to gws CLI, Resend, Mailgun, or codex-task-notifier. If this skill is not available, do NOT send. Report the failure instead.

## Known Recipient Registry Schema (v1.1.0)

Each recipient in `known-recipients.json` has these fields:

| Field | Type | Description |
|---|---|---|
| `email` | string | Recipient email address |
| `enabled` | boolean | `true` = can receive batch emails, `false` = excluded from `known:all` |
| `level` | string | Classification: `operational`, `middle`, `high` |
| `added_at_local` | string | Local timestamp when added |
| `added_at_utc` | string | UTC timestamp when added |

**`enabled` flag behavior:**
- `known:all` resolves to ONLY `enabled: true` recipients
- Direct targeting of a specific email ignores the flag (explicit choice)
- Default for new recipients: `enabled: true`, `level: "operational"`

**`level` classifications:**
- `operational` — day-to-day contacts
- `middle` — managers
- `high` — directors/executives

## Known Recipient Registry Protocol

When Jimmy asks to add, list, remove, update, or resolve Microsoft recipients:

- use `C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1`
- store the canonical list in `C:\ai\_skills\microsoft-mail-deliver\data\known-recipients.json`
- when Jimmy asks to show the list in chat, render it as a numbered alphabetical markdown table
- when Jimmy asks to send to everybody already saved, use `To = all` through `send-microsoft-business-email.ps1` or `send-microsoft-mail.ps1`
- do not improvise a fresh list from memory if the registry already exists; consult the registry first

Examples:

```powershell
# Add recipients
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1' -Action Add -Emails @('a@contoso.com','b@contoso.com')"

# List recipients as the chat-ready markdown table
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1' -Action Summary -OutputFormat MarkdownTable"

# Remove recipients
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1' -Action Remove -Emails @('a@contoso.com')"

# Resolve all saved recipients into one ready-to-send To string (enabled only)
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1' -Action Resolve -Emails @('all') -OutputFormat RecipientString"

# Update a recipient's enabled flag and level
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1' -Action Update -Emails @('a@contoso.com') -Enabled $false -Level 'high'"

# Send one business email to all saved Microsoft recipients
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\microsoft-mail-deliver\scripts\send-microsoft-business-email.ps1 -To all -Title 'SMOKE TEST MICROSOFT BATCH' -MainContent 'Controlled Microsoft-only batch validation.'
```

## Required Reading Before Implementation

1. `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\PROJECT_CONTEXT.md`
2. `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\01-manifesto\microsoft-mail-deliver-manifesto-contract-emma-2026-03-25-v1.0.md`
3. `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\02-planning\microsoft-mail-deliver-discovery-and-option-matrix-emma-2026-03-25-v1.0.md`
4. `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\03-spec\microsoft-mail-deliver-solution-direction-spec-emma-2026-03-25-v0.1.md`

## Current Outcome

Published v1.1.0 around the `up4a@up4aoffice.com` runtime:
- delegated auth validated
- `/me` probe validated
- sender entrypoints validated
- persistent known-recipient registry validated with `enabled`/`level` fields (v1.1.0)
- real Microsoft-only batch send validated with `To = all` and one non-duplicated mandatory `Cc`
- `known:all` resolution filters disabled recipients (second safety layer, v1.1.0)
- `Update` action available for changing recipient status without remove/re-add

Known limitation kept explicit:
- Gmail multi-recipient external batches remain under dated post-release observation until `2026-03-29`
- Graph `202 Accepted` remains transport acceptance, not guaranteed inbox delivery
