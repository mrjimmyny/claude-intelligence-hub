# Codex Auto-Approval Configuration

## Overview
This document describes the global auto-approval system configured for OpenAI Codex (Emma's CLI).

## Configuration File Location
`C:\Users\jaderson.almeida\.codex\config.json`

## What This Config Does

The configuration enables intelligent auto-approval for Codex operations:

### ✅ Auto-Approved Operations (Safe)
These operations execute immediately without user confirmation:
- **File operations**: `read`, `write`, `create`, `edit`, `list`, `search`
- **Version control**: `git` operations (add, commit, push, pull, etc.)
- **Package managers**: `npm`, `pip` install/update operations
- **Shell commands**: `bash`, `powershell`, `execute`
- **Build/Test**: `build`, `test`, `run`, `update`

### ⚠️ Manual Approval Required (Destructive)
These operations require explicit user confirmation:
- **Delete operations**: `delete`, `remove`, `rm`, `rmdir`, `del`
- **Destructive actions**: `destroy`, `drop`, `truncate`
- **Move/Rename**: `move`, `mv`, `cut`, `rename`
- **Uninstall**: `uninstall`

## Permission Tiers

1. **File Operations**: `auto-approve-safe` - Reads/writes/edits proceed automatically
2. **Shell Commands**: `auto-approve-safe` - Safe shell operations proceed automatically
3. **Git Operations**: `auto-approve` - All git operations proceed automatically
4. **Destructive Operations**: `require-approval` - Always requires user confirmation

## Session Defaults

- **Auto Commit**: `false` - Manual git commits (automatic approval, but not automatic execution)
- **Verbose Logging**: `false` - Minimal output for cleaner UX

## How to Verify It's Working

1. **Test auto-approval**: Ask Emma to read or create a file - should execute immediately
2. **Test manual approval**: Ask Emma to delete a file - should prompt for confirmation
3. **Check config**:
   ```powershell
   Get-Content "$env:USERPROFILE\.codex\config.json" | ConvertFrom-Json
   ```

## How to Modify Permissions

To add a new auto-approved command:
1. Open `C:\Users\jaderson.almeida\.codex\config.json`
2. Add the command to the `allowedCommands` array
3. Save the file (changes take effect immediately)

To require approval for a currently auto-approved command:
1. Remove it from `allowedCommands`
2. Add it to `requireApproval`

## Configuration Schema

```json
{
  "autoApprove": {
    "enabled": boolean,
    "allowedCommands": string[],
    "requireApproval": string[]
  },
  "globalPermissions": {
    "fileOperations": "auto-approve-safe" | "require-approval",
    "shellCommands": "auto-approve-safe" | "require-approval",
    "gitOperations": "auto-approve" | "require-approval",
    "destructiveOperations": "auto-approve" | "require-approval"
  },
  "sessionDefaults": {
    "autoCommit": boolean,
    "verboseLogging": boolean
  }
}
```

## Troubleshooting

**Config not taking effect?**
- Restart Emma (Codex CLI)
- Verify JSON syntax: `Get-Content "$env:USERPROFILE\.codex\config.json" | ConvertFrom-Json`
- Check file permissions on the config file

**Operations still requiring approval?**
- Ensure `autoApprove.enabled` is `true`
- Verify the command is listed in `allowedCommands`
- Check that it's not in `requireApproval` (takes precedence)

## Created By
Xavier (Claude Code) - 2026-02-15
Mission: `MISSION_CONFIGURE_CODEX_AUTO_APPROVAL.md`
