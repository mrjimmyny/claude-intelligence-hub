# Setup Instructions - Google Drive Sync

**Status:** ⚠️ rclone NOT installed yet
**Next Step:** Install rclone and configure Google Drive remote

---

## Step 1: Install rclone

### Option A: Using Scoop (Recommended)

```powershell
# If you don't have Scoop installed:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Install rclone
scoop install rclone
```

### Option B: Manual Installation

1. Download rclone from: https://rclone.org/downloads/
2. Extract to: `C:\Program Files\rclone\`
3. Add to PATH:
   ```powershell
   $env:PATH += ";C:\Program Files\rclone"
   setx PATH "$env:PATH;C:\Program Files\rclone"
   ```

### Verify Installation

```bash
rclone version
```

**Expected output:**
```
rclone v1.XX.X
- os/version: windows ...
- go/version: go1.XX.X
```

---

## Step 2: Configure Google Drive Remote

### Interactive Configuration

```bash
rclone config
```

**Follow these prompts:**

```
n/s/q> n                          # New remote
name> gdrive-jimmy                # Remote name (MUST be exactly this)

Type of storage:
Storage> drive                    # Google Drive

Google Application Client Id:
client_id> [Press Enter]          # Use default

OAuth Client Secret:
client_secret> [Press Enter]      # Use default

Scope:
1 / Full access
scope> 1                          # Full access

ID of root folder:
root_folder_id> [Press Enter]     # Entire drive

Service Account Credentials:
service_account_file> [Press Enter]  # None

Edit advanced config?
y/n> n                            # No

Use auto config?
y/n> y                            # Yes (Opens browser)

[Browser will open for OAuth]
-> Sign in to Google account
-> Grant permissions to rclone
-> Close browser when done

Configure this as a team drive?
y/n> n                            # No

--------------------
[gdrive-jimmy]
type = drive
scope = drive
--------------------

y/e/d> y                          # Yes, save config
```

---

## Step 3: Verify Google Drive Access

```bash
# List all folders in Google Drive
rclone lsd gdrive-jimmy:
```

**Expected:** List of folders from your Google Drive

```bash
# List specific folders
rclone lsf gdrive-jimmy:_tobe_registered/
rclone lsf gdrive-jimmy:_registered_claude_session_memoria/
```

**If folders don't exist, create them:**

```bash
rclone mkdir gdrive-jimmy:_tobe_registered
rclone mkdir gdrive-jimmy:_registered_claude_session_memoria
```

---

## Step 4: Get Folder IDs (Optional but Recommended)

```bash
rclone lsf gdrive-jimmy: --dirs-only --absolute --format pi
```

Copy the folder IDs for:
- `_tobe_registered`
- `_registered_claude_session_memoria`

Update `config/drive_folders.json` with the real IDs.

---

## Step 5: Test Upload/Download

### Create Test File

```bash
echo "# Test Summary from ChatLLM" > test.md
```

### Upload to Input Folder

```bash
rclone copy test.md gdrive-jimmy:_tobe_registered/
```

### Verify Upload

```bash
rclone lsf gdrive-jimmy:_tobe_registered/
```

**Expected:** `test.md` appears in list

### Test Download

```bash
rclone copy gdrive-jimmy:_tobe_registered/test.md ./gdrive-sync-memoria/temp/
```

**Verify:**
```bash
ls gdrive-sync-memoria/temp/
```

### Cleanup Test

```bash
rm test.md
rm gdrive-sync-memoria/temp/test.md
rclone delete gdrive-jimmy:_tobe_registered/test.md
```

---

## Step 6: First Real Sync

### Create Real .md File in ChatLLM Teams

Example content:
```markdown
# Power BI Best Practices Summary

## Key Points
- Use DAX measures instead of calculated columns when possible
- Keep model schema star-shaped for optimal performance
- Avoid bidirectional relationships unless absolutely necessary

## Details
[Full content from ChatLLM Teams analysis...]
```

### Upload to Google Drive

Save the .md file to Google Drive folder: `_tobe_registered`

### Run First Sync

In Claude Code:
```
/gdrive-sync
```

Or natural language:
```
Xavier, sincroniza o Google Drive
```

### Expected Outcome

```
🔄 Sincronizando Google Drive...

📥 Encontrado 1 arquivo:
- power-bi-best-practices.md

Processando...

✅ Sincronização completa!

📝 Entry criada: 2026-02-11-001
📂 Categoria: Power BI
🏷️ Tags: power-bi, dax, best-practices
🔄 Git push: success
📦 Arquivo movido para _registered_claude_session_memoria
```

### Verify in Session-Memoria

```
/memoria search power bi
```

**Expected:** Shows the new entry

---

## Troubleshooting

### Issue: "rclone: command not found"

**Cause:** rclone not in PATH

**Solution:**
```powershell
# Check installation
where.exe rclone

# If not found, add to PATH
setx PATH "$env:PATH;C:\Program Files\rclone"

# Restart terminal
```

---

### Issue: "didn't find section in config file"

**Cause:** Remote name mismatch

**Solution:**
```bash
# Check configured remotes
rclone listremotes

# Should show: gdrive-jimmy:
# If different, update config/drive_folders.json or reconfigure
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
# Follow setup steps again
```

---

### Issue: Browser doesn't open for OAuth

**Cause:** Auto-config may not work in some environments

**Solution:**
```bash
# Use manual config
rclone config

# When asked "Use auto config?"
y/n> n

# Copy the URL shown and open in browser manually
# Paste authorization code back in terminal
```

---

## Security Notes

### OAuth Tokens

- Stored in: `~/.config/rclone/rclone.conf` (Linux/Mac) or `%APPDATA%\rclone\rclone.conf` (Windows)
- Auto-refreshed by rclone
- Revoke access: [Google Account Permissions](https://myaccount.google.com/permissions)

### Best Practices

- ✅ Never commit rclone.conf to Git
- ✅ Review files before uploading to Google Drive
- ✅ Don't upload files with passwords, API keys, credentials
- ✅ Use private GitHub repo for sensitive knowledge

---

## Next Steps After Setup

1. ✅ Install rclone
2. ✅ Configure gdrive-jimmy remote
3. ✅ Verify access to Google Drive
4. ✅ Create test upload/download
5. ✅ Run first real sync
6. ✅ Verify entry in session-memoria

**Then you're ready to use the hybrid workflow:**

```
ChatLLM Teams → Google Drive → Xavier Sync → Session-Memoria
```

---

## Proactive Reminders

After setup, Xavier will remind you to sync if:
- Last sync > 3 days ago
- Never synced before

**To disable reminders:**
```
Xavier, desabilita lembretes do Google Drive
```

Sets `gdrive_sync.enabled = false` in `session-memoria/knowledge/metadata.json`.

---

## Support

**Issues:**
- Check `gdrive-sync-memoria/logs/sync_history.log`
- Ask Xavier: "X, debug o sync do Google Drive"

**Feature requests:**
- Suggest improvements based on usage patterns

---

**Setup Complete!** 🎉

You now have:
- ✅ Google Drive integration
- ✅ Automated sync workflow
- ✅ ChatLLM Teams → Session-Memoria pipeline
- ✅ Token-efficient hybrid strategy

**Happy syncing!**
