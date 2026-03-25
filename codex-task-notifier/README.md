# codex-task-notifier

Local Windows-first notifier for Codex task completion emails.

## Scope

- capture raw notification payloads;
- normalize payloads into an internal envelope;
- classify final task outcome as `success` or `failure` when safe;
- dedupe repeated final events;
- render and send HTTPS email with provider failover;
- persist raw, normalized, delivery, and validation evidence locally.

## Install flow

1. Run `scripts\install-codex-task-notifier.ps1`.
2. Populate HTTPS provider env vars for `Resend` and `Mailgun`.
3. Validate with `scripts\validate-codex-task-notifier.ps1`.
4. Keep the Codex UI normal.
5. Use `scripts\send-manual-notification.ps1` when you want an explicit task-end email from inside a Codex task.
6. Keep the TUI `notify` hook only as a legacy path when useful.

## Recommended behavior

- The Codex UI remains untouched. `codex` and `emma` keep using the normal CLI surface.
- When you want email for a specific long-running task, ask the agent to run `scripts\send-manual-notification.ps1` after it finishes the main task.
- This keeps the workflow explicit, simple, and independent of undocumented TUI internals.
- Example commands (by agent and model):
  ```
  # Emma (Codex) — standard coding (DEFAULT model)
  powershell -NoProfile -ExecutionPolicy Bypass -File C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1 -TaskTitle "Review X" -Summary "The requested review finished." -AgentName "Emma" -LlmModel "GPT-5.2-codex"

  # Emma (Codex) — complex orchestration
  powershell ... -AgentName "Emma" -LlmModel "GPT-5.3-codex"

  # Emma (Codex) — architecture/planning
  powershell ... -AgentName "Emma" -LlmModel "GPT-5.4"

  # Magneto (Claude Code) — standard coding
  powershell ... -AgentName "Magneto" -LlmModel "Claude Sonnet 4.6"

  # Forge (Gemini) — implementation
  powershell ... -AgentName "Forge" -LlmModel "Gemini 2.5 Flash"
  ```
- Example task instruction:
  `Execute a tarefa abaixo. Quando terminar tudo, envie um email usando C:\ai\_skills\codex-task-notifier\scripts\send-manual-notification.ps1 com um titulo curto e um resumo objetivo do resultado.`
- Short trigger phrases that should work in `C:\ai`:
  `email me when done`
  `send completion email`
  `send an email at the end`
  `send me an email when done`
  `me avise por email no final`
  `me manda um email`
  `mande um email quando terminar`
- Current template:
  `{{agent_name}} - Task Finished - [SHORT ID SESSION]-[MACHINE ID]`
  Body must follow the standard structure: greeting, status, task details/summary, trace block, and closing salutation.
- Agents should not freestyle the email body outside the template.
- If a round needs richer reporting, enrich the `Summary` content or update the template/documentation first.

## Optional behavior

- `scripts\run-codex-with-email.ps1` remains in the repo only as an experimental monitored-launcher path.
- The Codex TUI `notify` hook also remains supported, but it is a compatibility trail only.
- Neither path is the recommended default while the UI-preservation requirement is mandatory.

## Resend CLI

The Resend CLI (`resend-cli` v1.6.0) is installed globally (`npm install -g resend-cli`) and provides a cross-platform alternative for sending emails via Resend without PowerShell. Useful for Linux agents, Codex sessions, or quick ad-hoc sends. Authenticate with `resend login --key $CTN_RESEND_API_KEY` or pass `--api-key` per command. See `SKILL.md` for full usage guide.

## Baseline transport routing

- active channel: `https`
- provider order: `Resend -> Mailgun`
- legacy path preserved: `smtp`

- primary recipient: `mrjimmyny@gmail.com`
- preferred sender: `notify@mrjimmyny.org`
- sender fallback: `misteranalista@gmail.com`
