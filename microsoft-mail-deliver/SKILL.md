---
name: microsoft-mail-deliver
description: Microsoft-native email delivery protocol for CIH agents. Use when Jimmy explicitly wants the email to go through Microsoft 365, especially for outbound business emails, Microsoft-only batch sends, or saved-recipient workflows.
command: /microsoft-mail-deliver
aliases: [/mmd]
---

# microsoft-mail-deliver

**Version:** 1.0.0
**Status:** Production
**Published by:** Emma (Codex) on behalf of Jimmy

## Purpose

Route Microsoft-originated email work through the validated `up4a@up4aoffice.com` path, with a frozen business-email contract and a persistent known-recipient registry that any CIH agent can reuse.

## Use This Skill When

- Jimmy says `via Microsoft`, `do Microsoft`, `manda email pelo Microsoft`, `manda email do up4a`, or equivalent
- the task is a Microsoft-originated business email on Jimmy's behalf
- Jimmy wants to add, list, remove, or reuse saved Microsoft recipients
- Jimmy wants one Microsoft batch email sent to the saved recipient set via `To = all`

## Do Not Use This Skill For

- generic task-end self-notifications when Jimmy did **not** ask for Microsoft
- Gmail/Resend/Mailgun transport selection
- improvising recipients, title, or signature contract from memory
- claiming inbox delivery from Graph `202 Accepted` alone

Task-end notifications remain on `codex-task-notifier` unless Jimmy explicitly changes the transport to Microsoft.

## Active Runtime

- Technical root: `C:\ai\_skills\microsoft-mail-deliver\`
- Published skill root: `C:\ai\claude-intelligence-hub\microsoft-mail-deliver\`
- Project docs: `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\`
- Active sender profile: `up4a`
- Active mailbox: `up4a@up4aoffice.com`

## Business Email Contract

For Microsoft business emails sent on Jimmy's behalf:

- `To`: exactly the recipient(s) Jimmy provides
- `Cc`: always include `jaderson.almeida@br.havasvillage.com`
- title: mandatory; do not send if Jimmy did not define it
- subject: always uppercase
- greeting: mandatory time-of-day salutation
- identity line: `Agente <name>, <platform>, <LLM model>`
- intro: the email is being sent at Jimmy's request and replies should go to `jaderson.almeida@br.havasvillage.com`
- tone: formal, short, direct, executive
- signature: `Atenciosamente,` + identity line + `On behalf of Jimmy`

## Known-Recipient Registry

The skill owns a persistent Microsoft recipient registry:

- registry file: `C:\ai\_skills\microsoft-mail-deliver\data\known-recipients.json`
- manager script: `C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1`
- chat display rule: numbered, alphabetical, markdown table
- saved-list selector: `all`, `@all`, `known:all`, `known-recipients:all`

Required behaviors:

- `Add`: deduplicate and never create a second copy of the same address
- `List` / `Summary`: show the canonical alphabetical list
- `Remove` / `Delete`: remove saved addresses cleanly
- `Resolve`: expand `all` into one ready-to-send `To` string

## Operational Entrypoints

- `scripts\validate-microsoft-mail-deliver.ps1`
- `scripts\send-microsoft-mail.ps1`
- `scripts\compose-microsoft-business-email.ps1`
- `scripts\send-microsoft-business-email.ps1`
- `scripts\manage-known-recipients.ps1`

## Examples

```powershell
# Send one business email via Microsoft
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\microsoft-mail-deliver\scripts\send-microsoft-business-email.ps1 `
  -To "person@contoso.com" `
  -Title "PROJECT STATUS" `
  -MainContent "Short executive update."

# Add saved recipients
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1' -Action Add -Emails @('a@contoso.com','b@contoso.com')"

# Show the saved list in the chat-ready format
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1' -Action Summary -OutputFormat MarkdownTable"

# Send one Microsoft batch email to every saved recipient
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\microsoft-mail-deliver\scripts\send-microsoft-business-email.ps1 `
  -To all `
  -Title "SMOKE TEST MICROSOFT BATCH" `
  -MainContent "Controlled Microsoft-only batch validation."
```

## Validation Status

Validated in real work on `2026-03-26`:

- delegated auth works on the active `up4a` profile
- the business-email wrapper works
- the known-recipient registry works
- one Microsoft-only batch send to the saved list worked as a single email with one non-duplicated mandatory `Cc`

## Known Limitation

- Gmail multi-recipient external batches remain under dated observation until `2026-03-29`
- Graph `202 Accepted` means transport acceptance only, not final inbox proof

## Required Reading

1. `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\PROJECT_CONTEXT.md`
2. `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\status-atual.md`
3. `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\next-step.md`
4. `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\decisoes.md`
