# Google Drive Sync for Session-Memoria

**Version:** 1.0.0

Automatically import summaries and documents from ChatLLM Teams (ABACUS.AI) into session-memoria via Google Drive.

---

## Quick Start

### Prerequisites

1. **rclone installed:**
   ```bash
   scoop install rclone
   # Or download from https://rclone.org/downloads/
   ```

2. **Google Drive remote configured:**
   ```bash
   rclone config
   # Create remote named "gdrive-jimmy" with full Drive access
   ```

3. **Required folders in Google Drive:**
   - `_tobe_registered` (input folder for new files)
   - `_registered_claude_session_memoria` (processed files archive)

### Usage

**Manual sync:**
```
/gdrive-sync
```

Or natural language:
```
Xavier, sincroniza o Google Drive
X, processa arquivos do ChatLLM
Importa os resumos do Google Drive
```

**Automatic reminders:**
Xavier will proactively suggest syncing if >3 days since last sync.

---

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    ChatLLM Teams (ABACUS.AI)                │
│                  Heavy processing, summaries                │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │   Google Drive Folder  │
              │   "_tobe_registered"   │
              └───────────┬────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  gdrive-sync-memoria  │
              │  1. Download files    │
              │  2. Parse content     │
              │  3. Create entries    │
              │  4. Update indexes    │
              │  5. Git commit+push   │
              │  6. Move to processed │
              └───────────┬───────────┘
                          │
                          ▼
         ┌────────────────────────────────┐
         │     Session-Memoria            │
         │  Knowledge base (searchable)   │
         └────────────────────────────────┘
```

---

## Workflow Details

### 1. Prepare Files (ChatLLM Teams)

Create `.md` files with this structure:

```markdown
# Title of Summary

Brief description or introduction...

## Key Points

- Point 1
- Point 2

## Details

Full content, code examples, etc.
```

**Language:** Keep original (English, Portuguese, or any language)
**NO translation needed** - Xavier preserves original content

### 2. Upload to Google Drive

Save `.md` files to folder: `_tobe_registered`

### 3. Sync (Xavier)

Trigger sync via `/gdrive-sync` or wait for proactive reminder.

**Xavier will:**
- ✅ Download all `.md` files
- ✅ Parse content and extract metadata
- ✅ Auto-categorize (Power BI, Python, Gestão, etc.)
- ✅ Auto-tag (up to 5 relevant tags)
- ✅ Create session-memoria entries
- ✅ Update all indexes
- ✅ Git commit + push changes
- ✅ Rename files with `_pushed_session_memoria` suffix
- ✅ Move to `_registered_claude_session_memoria` folder

### 4. Verify

Check session-memoria:
```
/memoria search [keyword]
```

Or browse indexes:
```
session-memoria/knowledge/indexes/by-category/
session-memoria/knowledge/indexes/by-date/
session-memoria/knowledge/indexes/by-tag/
```

---

## Configuration

**File:** `config/drive_folders.json`

```json
{
  "input_folder": "_tobe_registered",
  "processed_folder": "_registered_claude_session_memoria",
  "rclone_remote": "gdrive-jimmy",
  "preserve_original_language": true,
  "auto_categorize": true,
  "max_tags": 5,
  "summary_max_length": 120
}
```

**Customization:**
- Change folder names (update IDs accordingly)
- Adjust max_tags (1-10)
- Adjust summary_max_length (50-200)

---

## Setup Guide

### Step 1: Install rclone

**Windows (Scoop):**
```powershell
scoop install rclone
```

**Windows (Manual):**
1. Download from https://rclone.org/downloads/
2. Extract to `C:\Program Files\rclone\`
3. Add to PATH

**Verify:**
```bash
rclone version
```

---

### Step 2: Configure Google Drive

```bash
rclone config
```

**Interactive setup:**

```
n) New remote
name> gdrive-jimmy

Type of storage:
Storage> drive

Google Application Client Id:
client_id> [Press Enter - use default]

OAuth Client Secret:
client_secret> [Press Enter - use default]

Scope:
1 / Full access
scope> 1

ID of root folder:
root_folder_id> [Press Enter - entire drive]

Service Account Credentials:
service_account_file> [Press Enter - none]

Edit advanced config?
y/n> n

Use auto config?
y/n> y

[Browser opens for OAuth authentication]
[Sign in to Google account]
[Grant permissions]

Configure this as a team drive?
y/n> n

--------------------
[gdrive-jimmy]
type = drive
scope = drive
--------------------
y/e/d> y (Yes this is OK)
```

---

### Step 3: Create Google Drive Folders

**Option A: Via rclone**
```bash
rclone mkdir gdrive-jimmy:_tobe_registered
rclone mkdir gdrive-jimmy:_registered_claude_session_memoria
```

**Option B: Via Google Drive web UI**
1. Go to https://drive.google.com
2. Create folder: `_tobe_registered`
3. Create folder: `_registered_claude_session_memoria`

**Get folder IDs:**
```bash
rclone lsf gdrive-jimmy: --dirs-only --absolute --format pi
```

Copy folder IDs to `config/drive_folders.json`.

---

### Step 4: Test Connection

```bash
# List folders
rclone lsd gdrive-jimmy:

# List files in input folder
rclone lsf gdrive-jimmy:_tobe_registered/

# Create test file
echo "# Test Summary" > test.md
rclone copy test.md gdrive-jimmy:_tobe_registered/

# Verify upload
rclone lsf gdrive-jimmy:_tobe_registered/
```

**Expected:** `test.md` appears in list

---

### Step 5: First Sync

**In Claude Code:**
```
/gdrive-sync
```

**Expected output:**
```
🔄 Sincronizando Google Drive...

📥 Encontrado 1 arquivo:
- test.md

Processando...

✅ Sincronização completa!

📝 Entry criada: 2026-02-11-001
📂 Categoria: Other
🔄 Git push: success
📦 Arquivo movido para _registered_claude_session_memoria
```

**Verify in session-memoria:**
```
/memoria search test
```

---

## Troubleshooting

### Issue: "rclone: command not found"

**Solution:**
```bash
# Install rclone
scoop install rclone

# Or add to PATH manually
setx PATH "%PATH%;C:\Program Files\rclone"
```

---

### Issue: "didn't find section in config file"

**Cause:** Remote name mismatch

**Solution:**
```bash
# Check configured remotes
rclone listremotes

# Should show: gdrive-jimmy:

# If different name, update config/drive_folders.json:
{
  "rclone_remote": "your-remote-name"
}
```

---

### Issue: "403 Forbidden" from Google Drive

**Cause:** OAuth token expired or insufficient permissions

**Solution:**
```bash
# Re-authenticate
rclone config reconnect gdrive-jimmy:

# Or delete and recreate remote
rclone config delete gdrive-jimmy
rclone config
```

---

### Issue: Files not syncing

**Debug steps:**

1. **Check rclone access:**
   ```bash
   rclone lsf gdrive-jimmy:_tobe_registered/
   ```
   Should list files.

2. **Check logs:**
   ```bash
   cat gdrive-sync-memoria/logs/sync_history.log
   ```
   Look for errors.

3. **Check metadata:**
   ```bash
   cat session-memoria/knowledge/metadata.json | jq .gdrive_sync
   ```
   Verify `last_sync` and `total_synced`.

4. **Check git status:**
   ```bash
   cd claude-intelligence-hub
   git status
   git log -1
   ```

---

### Issue: Git push fails

**Cause:** Network issues, authentication, or merge conflicts

**Solution:**
```bash
cd claude-intelligence-hub

# Pull latest changes
git pull origin main

# Retry push
git push origin main
```

**If still fails:**
Xavier will alert you. Entries are saved locally, you can manually push later.

---

## File Structure

```
gdrive-sync-memoria/
├── .metadata                    # Skill configuration
├── SKILL.md                     # Claude instructions (10KB)
├── README.md                    # This file
├── CHANGELOG.md                 # Version history
├── config/
│   └── drive_folders.json       # Google Drive folder configuration
├── logs/                        # Sync logs (git-ignored)
│   ├── .gitkeep
│   └── sync_history.log         # Auto-generated
└── temp/                        # Temporary downloads (git-ignored)
    ├── .gitkeep
    └── *.md                     # Auto-deleted after processing
```

---

## Security & Privacy

**OAuth tokens:**
- Stored in `~/.config/rclone/rclone.conf`
- Auto-refreshed by rclone
- Revoke access: [Google Account](https://myaccount.google.com/permissions)

**Sensitive data:**
- ❌ Do NOT upload files with passwords, API keys, credentials
- ✅ Review files before uploading to Google Drive
- ✅ Use private GitHub repo for sensitive knowledge

**Git commits:**
- All entries are visible in git history
- Use private repo if needed
- Never commit secrets to session-memoria

---

## Performance

**Typical sync times:**
- 1 file: ~10 seconds
- 5 files: ~30 seconds
- 10 files: ~1 minute

**Bottlenecks:**
- Google Drive API latency
- Git push to remote

**Optimization:**
- Server-side file operations (fast)
- Batch git commits (one commit per sync)

---

## Logs

**Location:** `gdrive-sync-memoria/logs/sync_history.log`

**Not version controlled** (git-ignored)

**Example:**
```
[2026-02-11 22:15:00] INFO START: Sync initiated
[2026-02-11 22:15:02] INFO FOUND: 3 files in _tobe_registered
[2026-02-11 22:15:05] SUCCESS PROCESS: file1.md → 2026-02-11-001 (Power BI)
[2026-02-11 22:15:10] ERROR SKIP: corrupt.md - File is empty
[2026-02-11 22:15:15] SUCCESS PROCESS: file2.md → 2026-02-11-002 (Python)
[2026-02-11 22:15:20] SUCCESS COMMIT: Git commit successful
[2026-02-11 22:15:25] SUCCESS PUSH: Git push successful
[2026-02-11 22:15:30] INFO COMPLETE: Synced 2/3 files, 1 skipped
```

---

## Monitoring

**Last sync status:**
Check `session-memoria/knowledge/metadata.json`:

```json
"gdrive_sync": {
  "enabled": true,
  "last_sync": "2026-02-11T22:30:00Z",
  "total_synced": 18,
  "last_count": 3,
  "last_error": null
}
```

**Proactive reminders:**
Xavier will remind you if >3 days since last sync.

**Disable reminders:**
```
Xavier, desabilita lembretes do Google Drive
```

Sets `gdrive_sync.enabled = false` in metadata.json.

---

## Support

**Issues:**
- Check [Troubleshooting](#troubleshooting) section
- Review `logs/sync_history.log`
- Ask Xavier: "X, debug o sync do Google Drive"

**Feature requests:**
Suggest improvements to Jimmy based on usage patterns.

---

## License

Part of Jimmy's Claude Intelligence Hub
Version 1.0.0 - February 2026
