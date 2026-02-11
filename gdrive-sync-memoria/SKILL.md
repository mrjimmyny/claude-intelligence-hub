# Google Drive Sync for Session-Memoria

**Skill ID:** `gdrive-sync-memoria`
**Version:** 1.0.0
**Auto-load:** No (manual trigger or proactive reminder)
**Dependencies:** session-memoria

---

## Purpose

Integrates Google Drive with session-memoria to automatically import summaries and documents from ChatLLM Teams (ABACUS.AI) into Jimmy's knowledge base.

**Hybrid strategy:** Use ChatLLM Teams for heavy processing (token-intensive tasks), then import the resulting .md summaries into session-memoria via Google Drive.

**Workflow:**
1. Jimmy creates summaries in ChatLLM Teams (English or Portuguese)
2. Saves .md files to Google Drive folder `_tobe_registered`
3. Xavier syncs files → processes → creates session-memoria entries
4. Renames files with `_pushed_session_memoria` suffix
5. Moves processed files to `_registered_claude_session_memoria`
6. Git commit + push changes

---

## Configuration

**File:** `config/drive_folders.json`

```json
{
  "input_folder": "_tobe_registered",
  "input_folder_id": "1Lmf51XNKbnzdBYlR0VgsWhP6YjgF3si7",
  "processed_folder": "_registered_claude_session_memoria",
  "processed_folder_id": "1fF4kTEUTEbG-Jf9tGdV5Ur7bnnW1bmLN",
  "rclone_remote": "gdrive-jimmy",
  "preserve_original_language": true,
  "auto_categorize": true,
  "max_tags": 5,
  "summary_max_length": 120
}
```

**Required setup (one-time):**
- rclone installed and configured
- Remote named `gdrive-jimmy` with full Google Drive access
- Folders `_tobe_registered` and `_registered_claude_session_memoria` created

---

## Triggers (Portuguese)

### Manual
- `/gdrive-sync`
- "Xavier, sincroniza o Google Drive"
- "X, processa arquivos do ChatLLM"
- "Importa os resumos do Google Drive"

### Proactive Reminder
Track last sync in session-memoria/knowledge/metadata.json:

```json
"gdrive_sync": {
  "enabled": true,
  "last_sync": "2026-02-11 22:00:00",
  "total_synced": 15,
  "last_count": 3
}
```

**Reminder logic:**
- If `last_sync` is null OR > 3 days ago:
  - "Jimmy, faz 3 dias sem sincronizar Google Drive. Quer processar agora?"
  - Only remind once per session (don't spam)

---

## Workflow (8 Steps)

### Pre-flight Validations

Before starting sync, verify:

1. **rclone configured?**
   ```bash
   rclone version
   rclone lsd gdrive-jimmy:
   ```
   - If fails: "❌ rclone não configurado. Execute: `rclone config`"

2. **Git repo clean?**
   ```bash
   cd claude-intelligence-hub
   git status
   ```
   - If dirty: Alert Jimmy (uncommitted changes exist)
   - Proceed anyway (sync adds new files)

3. **metadata.json valid?**
   ```bash
   cat session-memoria/knowledge/metadata.json | jq .
   ```
   - If invalid: "❌ metadata.json corrupted. Cannot proceed."

If all validations pass → proceed with sync.

---

### Step 1: List Files in Input Folder

```bash
rclone lsf gdrive-jimmy:_tobe_registered/ --files-only --include "*.md"
```

**Output:** List of .md filenames (one per line)

**If empty:**
- "✅ Nenhum arquivo pendente no Google Drive."
- Update `gdrive_sync.last_sync` in metadata.json
- Exit gracefully

**If files found:**
- Log count: "📥 Encontrados X arquivos para processar"
- Proceed to Step 2 for each file

---

### Step 2: Download File

For each file from Step 1:

```bash
rclone copy "gdrive-jimmy:_tobe_registered/[FILENAME]" ./gdrive-sync-memoria/temp/ -v
```

**Validations:**
- File exists in temp/?
- File size > 0 bytes?
- File is valid UTF-8?

**If validation fails:**
- Log error: `logs/sync_history.log`
- Skip file, continue next
- Error format: `[TIMESTAMP] ERROR: [FILENAME] - [REASON]`

---

### Step 3: Parse File Content

**Read file:**
```bash
cat ./gdrive-sync-memoria/temp/[FILENAME]
```

**Extract metadata:**

1. **Title:**
   - First H1 heading (`# Title`)
   - If no H1: use filename (without .md)
   - Max 80 chars

2. **Content:**
   - Full markdown content (preserve original)
   - NO translation (keep English, Portuguese, or any language)
   - Strip excessive whitespace (max 2 consecutive newlines)

3. **Category (auto-infer):**
   - Scan content for keywords:
     - "Power BI", "DAX", "Power Query", "M language" → `Power BI`
     - "Python", "script", "pandas", "numpy" → `Python`
     - "project", "team", "gestão", "management" → `Gestão`
     - "API", "endpoint", "REST", "GraphQL" → `API Development`
     - "SQL", "database", "query" → `Database`
     - Default → `Other`
   - If multiple matches: use first match
   - Jimmy can recategorize later via session-memoria

4. **Tags (auto-extract):**
   - Extract up to 5 tags from content
   - Prioritize: section headers, bold terms, code blocks
   - Format: kebab-case
   - Examples: `power-bi`, `dax-measures`, `python-automation`
   - If <5 tags: supplement with category-based defaults

5. **Summary:**
   - Extract from first paragraph OR
   - Generate concise summary from content
   - **Preserve original language** (NO translation)
   - Max 120 chars
   - Focus: what problem does this solve? what knowledge is captured?

---

### Step 4: Create Session-Memoria Entry

**Follow existing Save workflow** (session-memoria SKILL.md, lines 141-243)

**Entry ID generation:**
```
YYYY-MM-DD-NNN
Example: 2026-02-11-001
```

**Frontmatter template:**
```yaml
---
id: 2026-02-11-001
title: [Extracted title]
summary: [Generated summary - original language]
category: [Auto-inferred category]
tags:
  - [tag-1]
  - [tag-2]
  - [tag-3]
date: 2026-02-11
source: chatllm-teams-gdrive
original_filename: [FILENAME]
language: [auto-detected: en, pt, etc.]
---

[Full original content]
```

**File path:**
```
session-memoria/knowledge/entries/2026/02/2026-02-11-001.md
```

**Index updates (same as normal Save):**

1. **by-date index:**
   ```
   session-memoria/knowledge/indexes/by-date/2026-02.md
   ```
   Append:
   ```markdown
   ## 2026-02-11
   - [2026-02-11-001](../../entries/2026/02/2026-02-11-001.md) - [summary] `#tag-1` `#tag-2`
   ```

2. **by-category index:**
   ```
   session-memoria/knowledge/indexes/by-category/[category].md
   ```
   Append:
   ```markdown
   - [2026-02-11-001](../../entries/2026/02/2026-02-11-001.md) - [summary]
   ```

3. **by-tag indexes:**
   For each tag, update:
   ```
   session-memoria/knowledge/indexes/by-tag/[tag].md
   ```
   Append:
   ```markdown
   - [2026-02-11-001](../../entries/2026/02/2026-02-11-001.md) - [summary]
   ```

4. **metadata.json:**
   ```json
   {
     "total_entries": [increment by 1],
     "last_updated": "2026-02-11T22:30:00Z",
     "last_entry_id": "2026-02-11-001",
     "gdrive_sync": {
       "last_sync": "2026-02-11T22:30:00Z",
       "total_synced": [increment by 1],
       "last_count": [files processed this run]
     }
   }
   ```

---

### Step 5: Rename File in Google Drive

```bash
original="[FILENAME].md"
renamed="${original%.md}_pushed_session_memoria.md"

rclone moveto \
  "gdrive-jimmy:_tobe_registered/$original" \
  "gdrive-jimmy:_tobe_registered/$renamed" \
  --drive-server-side-across-configs
```

**Why rename before move?**
- Atomic operation visibility
- If Step 6 fails, file is marked as processed (won't re-process)
- Easy to identify processed files in input folder

**Validation:**
- File renamed successfully?
- Original file no longer exists in input folder?

---

### Step 6: Move to Processed Folder

```bash
renamed="${original%.md}_pushed_session_memoria.md"

rclone moveto \
  "gdrive-jimmy:_tobe_registered/$renamed" \
  "gdrive-jimmy:_registered_claude_session_memoria/$renamed" \
  --drive-server-side-across-configs
```

**Server-side move benefits:**
- Fast (no download/upload)
- Preserves metadata
- Atomic operation

**Validation:**
- File exists in processed folder?
- File removed from input folder?

---

### Step 7: Git Commit + Push

**After processing ALL files in batch:**

```bash
cd claude-intelligence-hub

git add session-memoria/knowledge/

git commit -m "feat(session-memoria): sync from Google Drive - [COUNT] files

Processed files:
- [FILENAME_1]
- [FILENAME_2]
- [...]

Source: ChatLLM Teams via gdrive-sync-memoria
Categories: [list unique categories]
Total entries added: [COUNT]"

git push origin main
```

**Retry logic:**
- Retry up to 3 times with exponential backoff (2s, 4s, 8s)
- If all retries fail:
  - "⚠️ Git push failed. Entries created locally but not synced."
  - Log error to `logs/sync_history.log`
  - Alert Jimmy (requires manual intervention)

**Why batch commit vs. per-file?**
- Reduces commit noise
- Atomic sync operation
- Easier rollback if needed

---

### Step 8: Cleanup and Logging

**Delete temp files:**
```bash
rm -f ./gdrive-sync-memoria/temp/*.md
```

**Log success:**
```
[2026-02-11 22:30:15] SUCCESS: Synced 3 files
- file1.md → 2026-02-11-001 (Power BI)
- file2.md → 2026-02-11-002 (Python)
- file3.md → 2026-02-11-003 (Other)
```

**Update metadata.json:**
```json
"gdrive_sync": {
  "last_sync": "2026-02-11T22:30:15Z",
  "total_synced": 18,  // previous: 15
  "last_count": 3,
  "last_error": null
}
```

**User feedback:**
```
✅ Sincronização completa!

📥 3 arquivos processados
📝 Entries criadas: 2026-02-11-001, 002, 003
📂 Categorias: Power BI (1), Python (1), Other (1)
🔄 Git push: success
📦 Arquivos movidos para _registered_claude_session_memoria

Próxima sincronização sugerida: 2026-02-14
```

---

## Error Handling

### Network Failures

**Scenario:** rclone commands timeout or fail

**Strategy:** Retry with exponential backoff

```python
max_retries = 3
backoff = [2, 4, 8]  # seconds

for attempt in range(max_retries):
    result = rclone_command()
    if result.success:
        break
    if attempt < max_retries - 1:
        sleep(backoff[attempt])
    else:
        log_error("Network failure after 3 retries")
        alert_jimmy("❌ Falha de rede ao acessar Google Drive")
        abort_sync()
```

**Logged in:** `logs/sync_history.log`

---

### Malformed Files

**Scenarios:**
- Empty file (0 bytes)
- Corrupted UTF-8
- No markdown content
- Title extraction fails

**Strategy:** Skip file, log error, continue next

```
[2026-02-11 22:15:30] ERROR: corrupt.md - File is empty (0 bytes)
[2026-02-11 22:15:35] ERROR: bad_encoding.md - Invalid UTF-8 encoding
```

**User alert (end of sync):**
```
⚠️ 2 arquivos ignorados (ver logs/sync_history.log):
- corrupt.md (empty file)
- bad_encoding.md (encoding error)
```

**DO NOT:**
- Stop entire sync due to one bad file
- Attempt to "fix" corrupted files automatically
- Move bad files to processed folder

**Leave bad files in input folder** for Jimmy to manually review.

---

### Git Push Failures

**Scenario:** Network issues, merge conflicts, auth failures

**Strategy:**
1. Retry up to 3 times (2s, 4s, 8s backoff)
2. If all fail:
   - Log error
   - Alert Jimmy
   - **DO NOT delete local changes**

**Alert message:**
```
⚠️ Git push failed após 3 tentativas

✅ Entries criadas localmente:
- session-memoria/knowledge/entries/2026/02/2026-02-11-001.md
- session-memoria/knowledge/entries/2026/02/2026-02-11-002.md

❌ Sincronização remota pendente

Ação necessária:
1. Verificar conectividade
2. Executar manualmente: cd claude-intelligence-hub && git push
```

**Recovery path:**
- Jimmy can manually run `git push` later
- Local entries are safe
- Files already moved in Google Drive (won't re-process)

---

### Duplicate Files

**Scenario:** File with same name already processed

**Detection:**
- Check if `[FILENAME]_pushed_session_memoria.md` exists in input folder
- Check if file exists in processed folder

**Strategy:**
- Skip file
- Log warning: "⚠️ [FILENAME] already processed (duplicate)"
- Continue next file

**Why not auto-delete?**
- Jimmy may have intentionally uploaded updated version
- Manual review safer than auto-deletion

---

### Validation Failures

**Pre-flight failures:**

| Check | Failure Action |
|-------|----------------|
| rclone not configured | Abort sync, show setup instructions |
| metadata.json corrupted | Abort sync, alert Jimmy |
| Git repo not found | Abort sync, show error |

**Per-file failures:**

| Check | Failure Action |
|-------|----------------|
| File empty | Skip, log error |
| Invalid UTF-8 | Skip, log error |
| Summary > 120 chars | Truncate to 120 |
| Tags > 5 | Keep first 5 |
| Title > 80 chars | Truncate to 80 |

---

## Logging

**File:** `logs/sync_history.log`

**Format:**
```
[YYYY-MM-DD HH:MM:SS] [LEVEL] [FILENAME] - Message
```

**Examples:**
```
[2026-02-11 22:15:00] INFO START: Sync initiated
[2026-02-11 22:15:02] INFO FOUND: 3 files in _tobe_registered
[2026-02-11 22:15:05] SUCCESS PROCESS: file1.md → 2026-02-11-001 (Power BI)
[2026-02-11 22:15:10] ERROR SKIP: corrupt.md - File is empty (0 bytes)
[2026-02-11 22:15:15] SUCCESS PROCESS: file2.md → 2026-02-11-002 (Python)
[2026-02-11 22:15:20] SUCCESS COMMIT: Git commit successful
[2026-02-11 22:15:25] SUCCESS PUSH: Git push successful
[2026-02-11 22:15:30] INFO COMPLETE: Synced 2/3 files, 1 skipped
```

**Rotation:**
- Keep last 1000 lines
- Rotate when > 100KB
- Archive old logs (sync_history_YYYYMMDD.log)

**NOT version controlled** (git-ignored)

---

## Proactive Monitoring

**Trigger reminder when:**
1. `gdrive_sync.last_sync` is null (never synced)
2. `gdrive_sync.last_sync` > 3 days ago
3. Not already reminded this session

**Reminder message:**
```
Jimmy, faz 3 dias sem sincronizar Google Drive.

Última sincronização: 2026-02-08 (3 dias atrás)
Total sincronizado: 15 arquivos

Quer processar novos arquivos agora?
```

**User responses:**
- "Sim" / "Processa" / "Vai" → Execute sync
- "Não" / "Depois" → Skip (don't remind again this session)
- "Desabilita lembretes" → Set `gdrive_sync.enabled = false` in metadata.json

---

## Integration with Session-Memoria

**Entry metadata additions:**

Standard session-memoria frontmatter + these fields:

```yaml
source: chatllm-teams-gdrive
original_filename: power-bi-summary.md
language: en  # or pt, auto-detected
sync_date: 2026-02-11T22:15:05Z
```

**Why track original_filename?**
- Debugging (trace back to Google Drive file)
- Avoid duplicate processing
- Audit trail

**Why track language?**
- Helps future AI understand content context
- Enables language-specific search/filtering
- Preserves intent (no translation artifacts)

---

## Usage Examples

### Example 1: Manual Sync

**Jimmy:**
```
Xavier, sincroniza o Google Drive
```

**Xavier:**
```
🔄 Sincronizando Google Drive...

📥 Encontrados 2 arquivos:
- power-bi-best-practices.md
- python-automation-summary.md

Processando...

✅ Sincronização completa!

📝 Entries criadas:
- 2026-02-11-001: Power BI Best Practices (Power BI)
- 2026-02-11-002: Python Automation Summary (Python)

🔄 Git push: success
📦 Arquivos movidos para _registered_claude_session_memoria
```

---

### Example 2: Proactive Reminder

**Xavier (proactive):**
```
Jimmy, faz 3 dias sem sincronizar Google Drive.

Última sincronização: 2026-02-08
Total sincronizado: 15 arquivos

Quer processar novos arquivos agora?
```

**Jimmy:**
```
Vai
```

**Xavier:**
```
🔄 Sincronizando...

✅ Nenhum arquivo pendente no Google Drive.
Tudo atualizado!
```

---

### Example 3: Error Handling

**Xavier:**
```
🔄 Sincronizando Google Drive...

📥 Encontrados 3 arquivos

⚠️ Erros encontrados:
- empty-file.md: Arquivo vazio (0 bytes) - ignorado
- corrupt.md: Encoding inválido - ignorado

✅ 1 arquivo processado:
- 2026-02-11-001: DAX Measures Guide (Power BI)

📋 Ver detalhes: gdrive-sync-memoria/logs/sync_history.log
```

---

## Setup Instructions (One-Time)

### 1. Install rclone

**Windows (Scoop):**
```bash
scoop install rclone
```

**Or manual download:**
https://rclone.org/downloads/

**Verify:**
```bash
rclone version
```

---

### 2. Configure Google Drive Remote

```bash
rclone config
```

**Interactive prompts:**
```
n) New remote
name> gdrive-jimmy
Storage> drive  (Google Drive)
client_id> [Enter] (use default)
client_secret> [Enter] (use default)
scope> 1  (Full access)
root_folder_id> [Enter] (entire drive)
service_account_file> [Enter] (none)
Advanced config? n
Use auto config? y  (Opens browser for OAuth)

[Authenticate in browser]

Configure as team drive? n
```

**Verify:**
```bash
rclone lsd gdrive-jimmy:
```

Should list all folders in Google Drive.

---

### 3. Verify Folder Access

```bash
rclone lsf gdrive-jimmy:_tobe_registered/
rclone lsf gdrive-jimmy:_registered_claude_session_memoria/
```

**If folders don't exist:**
```bash
rclone mkdir gdrive-jimmy:_tobe_registered
rclone mkdir gdrive-jimmy:_registered_claude_session_memoria
```

---

### 4. Update .gitignore

Add to `claude-intelligence-hub/.gitignore`:
```
gdrive-sync-memoria/logs/
gdrive-sync-memoria/temp/
```

**Commit:**
```bash
git add .gitignore
git commit -m "chore: ignore gdrive-sync-memoria temp files"
```

---

### 5. First Sync Test

**Create test file:**
```bash
echo "# Test Summary from ChatLLM" > test.md
rclone copy test.md gdrive-jimmy:_tobe_registered/
```

**Run sync:**
```
/gdrive-sync
```

**Expected:**
- ✅ File downloaded to temp/
- ✅ Entry created in session-memoria
- ✅ Indexes updated
- ✅ Git commit + push
- ✅ File moved to _registered_claude_session_memoria

---

## Security Considerations

**rclone authentication:**
- Uses OAuth tokens (stored in `~/.config/rclone/rclone.conf`)
- Token refresh automatic
- Revoke access: Google Account settings → Apps

**Sensitive data:**
- NO passwords/API keys in .md files
- Review files before uploading to Google Drive
- gdrive-sync-memoria does NOT filter secrets (Jimmy's responsibility)

**Git commits:**
- All entries are public (if repo is public)
- Review content before pushing
- Use private repo for sensitive knowledge

---

## Troubleshooting

### "rclone: command not found"

**Solution:**
```bash
# Install rclone
scoop install rclone

# Or add to PATH manually
```

---

### "Failed to create file system: didn't find section in config file"

**Solution:**
```bash
# Remote not configured
rclone config

# Or check spelling: gdrive-jimmy (exact match)
```

---

### "403 Forbidden" from Google Drive

**Solution:**
```bash
# Re-authenticate
rclone config reconnect gdrive-jimmy:

# Or delete and re-create remote
rclone config delete gdrive-jimmy
rclone config  # Create new
```

---

### "metadata.json: Permission denied"

**Solution:**
```bash
# File locked by another process
# Close Claude Code, VS Code, or text editors
# Retry sync
```

---

### Files not appearing in session-memoria

**Debug checklist:**
1. Check `logs/sync_history.log` for errors
2. Verify entry created: `session-memoria/knowledge/entries/YYYY/MM/`
3. Verify indexes updated: `session-memoria/knowledge/indexes/`
4. Check git status: `git log -1 --oneline`
5. Verify metadata.json updated

---

## Performance

**Typical sync times:**

| Files | Duration |
|-------|----------|
| 1 file | ~10 seconds |
| 5 files | ~30 seconds |
| 10 files | ~60 seconds |
| 20 files | ~2 minutes |

**Bottlenecks:**
- Network latency (Google Drive API)
- Git push (remote sync)
- Entry parsing (minimal)

**Optimization:**
- Server-side move (no download/upload)
- Batch git commits
- Parallel processing (future enhancement)

---

## Future Enhancements (v2.0)

**Not in scope for v1.0:**
- [ ] Parallel file processing
- [ ] Web UI for monitoring
- [ ] Auto-delete old files from processed folder
- [ ] Conflict resolution (duplicate titles)
- [ ] Multi-language translation (preserve original + add PT/EN)
- [ ] Image embedding support
- [ ] PDF conversion support
- [ ] Automated categorization via AI (Claude API)

**Request features:**
Jimmy can suggest enhancements based on usage patterns.

---

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

**Current version:** 1.0.0 (2026-02-11)
