# microsoft-mail-deliver

Microsoft-native email delivery skill for CIH agents.

Published by Emma (Codex) on behalf of Jimmy on `2026-03-26`.

## Overview

`microsoft-mail-deliver` is the official Microsoft 365 email path for the CIH ecosystem. It gives any agent a stable answer to three recurring needs:

- send an email `via Microsoft` without re-opening transport discussions
- follow Jimmy's frozen business-email contract exactly
- reuse a persistent saved-recipient list through one canonical registry

This publication does not replace `codex-task-notifier`. It complements it.

## What This Skill Does

- routes explicit `via Microsoft` requests to the Microsoft 365 sender path
- uses the validated `up4a@up4aoffice.com` delegated Graph runtime
- sends Jimmy-originated business emails with the required `To` / `Cc` / subject / greeting / intro / signature contract
- supports a persistent known-recipient registry
- supports `To = all` for one-message Microsoft batch sends to the saved registry
- keeps delivery semantics honest: Graph `202 Accepted` is reported as acceptance, not guaranteed inbox delivery

## What This Skill Does Not Do

- it does not replace `codex-task-notifier` for default task-end notifications
- it does not guess missing recipients or invent a title
- it does not allow duplicate saved addresses in the registry
- it does not promise inbox delivery just because Graph returned `202`
- it does not solve the still-open Gmail multi-recipient reputation issue by pretending the issue is gone

## Routing Rule

Use `microsoft-mail-deliver` when Jimmy says things like:

- `via Microsoft`
- `do Microsoft`
- `manda email pelo Microsoft`
- `manda email do up4a`

Use `codex-task-notifier` when Jimmy asks for a normal completion email but does not choose Microsoft transport explicitly.

That split is intentional:

- `codex-task-notifier` = default completion notifier
- `microsoft-mail-deliver` = Microsoft transport and Microsoft business-email workflow

## Runtime Model

This published skill is protocol-first. The operational runtime lives in the technical workspace:

| Layer | Path | Role |
|---|---|---|
| Published skill | `C:\ai\claude-intelligence-hub\microsoft-mail-deliver\` | Global agent-facing protocol |
| Technical runtime | `C:\ai\_skills\microsoft-mail-deliver\` | Scripts, config, registry, local execution |
| Project docs | `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\` | Evidence, decisions, next-step governance |

Active published implementation target:

- profile: `up4a`
- mailbox: `up4a@up4aoffice.com`
- auth mode: Microsoft Graph delegated auth

## Business Email Contract

When the email is a Jimmy-originated business email sent through this skill:

- `To` must be exactly what Jimmy specified
- `Cc` must always include `jaderson.almeida@br.havasvillage.com`
- title is mandatory
- subject is uppercased before send
- the greeting must use time-of-day salutation
- the identity line must be `Agente <name>, <platform>, <LLM model>`
- the intro must say the email is being sent at Jimmy's request and that replies should go to `jaderson.almeida@br.havasvillage.com`
- the tone must stay short, professional, direct, and executive
- the signature must end with `On behalf of Jimmy`

## Known-Recipient Registry

The skill includes a persistent saved-recipient workflow so Jimmy never has to keep retyping the same Microsoft list.

Canonical assets:

- registry file: `C:\ai\_skills\microsoft-mail-deliver\data\known-recipients.json`
- manager script: `C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1`

Supported operations:

- `Add`
- `List`
- `Summary`
- `Remove`
- `Delete`
- `Resolve`

Registry rules:

- duplicates are blocked
- output is alphabetical
- chat output is a numbered markdown table
- `all`, `@all`, `known:all`, and `known-recipients:all` expand to the full saved list

## Main Scripts

| Script | Purpose |
|---|---|
| `validate-microsoft-mail-deliver.ps1` | Auth/runtime validation and smoke path |
| `send-microsoft-mail.ps1` | Low-level Microsoft sender |
| `compose-microsoft-business-email.ps1` | Contract-based HTML body builder |
| `send-microsoft-business-email.ps1` | Standard business-email wrapper |
| `manage-known-recipients.ps1` | Saved-recipient registry manager |

## Examples

### 1. Send one business email via Microsoft

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\microsoft-mail-deliver\scripts\send-microsoft-business-email.ps1 `
  -To "person@contoso.com" `
  -Title "PROJECT STATUS" `
  -MainContent "Short executive update in the required format."
```

### 2. Add saved recipients

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1' -Action Add -Emails @('a@contoso.com','b@contoso.com')"
```

### 3. Show the saved list as the required table

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\ai\_skills\microsoft-mail-deliver\scripts\manage-known-recipients.ps1' -Action Summary -OutputFormat MarkdownTable"
```

### 4. Send one Microsoft batch email to all saved recipients

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\microsoft-mail-deliver\scripts\send-microsoft-business-email.ps1 `
  -To all `
  -Title "SMOKE TEST MICROSOFT BATCH" `
  -MainContent "Controlled Microsoft-only batch validation."
```

## Real Validation Evidence

This first release was published only after real operational evidence on `2026-03-26`:

- delegated auth validated on the active profile
- direct sender validated
- business wrapper validated
- known-recipient registry validated
- Microsoft-only batch validated with `To = all`
- Jimmy confirmed the copied mailbox received exactly one email, not one per recipient

That was the publication gate.

## Current Limitation

One limitation remains explicitly open and documented:

- Gmail multi-recipient external batches on the active sender path are still under observation until `2026-03-29`

This does **not** block the published Microsoft-only workflow. It simply remains a tracked post-release item.

## Q&A

### Q: If Jimmy says only "email me when done", should agents use this skill?

No. That remains `codex-task-notifier` unless Jimmy explicitly switches transport to Microsoft.

### Q: If Jimmy says "via Microsoft", should agents ask whether Gmail/Resend/Mailgun should be used?

No. The transport was already chosen by Jimmy.

### Q: Can agents save a recipient twice?

No. The registry is duplicate-safe by design.

### Q: Does Graph `202 Accepted` prove inbox delivery?

No. It proves Microsoft accepted the send request. Final delivery still depends on downstream mail flow.

### Q: Can agents send to every saved Microsoft recipient without Jimmy retyping the list?

Yes. Use `To = all` or the equivalent selectors handled by the registry resolver.

## Required Reading

- `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\PROJECT_CONTEXT.md`
- `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\status-atual.md`
- `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\next-step.md`
- `C:\ai\obsidian\CIH\projects\skills\microsoft-mail-deliver\decisoes.md`

## Summary

`microsoft-mail-deliver` is now the official CIH answer for Microsoft-native email work:

- published
- cross-agent documented
- registry-backed
- batch-validated for Microsoft-only recipient sets
- explicit about its remaining limitation instead of hiding it
