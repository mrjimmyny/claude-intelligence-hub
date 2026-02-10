# Setup Guide - Session Memoria

**Version:** 1.0.0
**Last updated:** 2026-02-10

---

## Prerequisites

Before installing session-memoria, ensure you have:

- ✅ Claude Code CLI installed
- ✅ Git configured and working
- ✅ Access to `claude-intelligence-hub` repository
- ✅ `jimmy-core-preferences` skill installed

---

## Installation

### Option 1: Clone from GitHub (Recommended)

1. **Navigate to skills directory:**
   ```bash
   cd ~/.claude/skills/user
   ```

2. **Clone the repository:**
   ```bash
   git clone https://github.com/mrjimmyny/claude-intelligence-hub.git
   ```

3. **Create symlink (optional, for auto-sync):**
   ```bash
   ln -s ~/claude-intelligence-hub/session-memoria ~/.claude/skills/user/session-memoria
   ```

### Option 2: Direct Copy

1. **Navigate to intelligence hub:**
   ```bash
   cd ~/claude-intelligence-hub
   ```

2. **Copy to skills directory:**
   ```bash
   cp -r session-memoria ~/.claude/skills/user/
   ```

---

## Verification

### Check Installation

1. **Verify skill is detected:**
   ```bash
   claude skills list
   ```

   You should see `session-memoria` in the list.

2. **Verify file structure:**
   ```bash
   cd ~/.claude/skills/user/session-memoria
   ls -la
   ```

   Expected files:
   ```
   .metadata
   SKILL.md
   README.md
   CHANGELOG.md
   SETUP_GUIDE.md
   templates/
   knowledge/
   ```

3. **Verify Git integration:**
   ```bash
   cd ~/claude-intelligence-hub
   git status
   ```

   Should show session-memoria tracked by Git.

---

## Configuration

### Default Settings

The `.metadata` file contains default configuration:

```json
{
  "settings": {
    "auto_push": true,           // Auto-push to GitHub after commit
    "default_language": "pt-BR",  // Portuguese
    "max_tags": 5,                // Max tags per entry
    "alert_thresholds": {
      "warning": 500,              // Warning at 500 entries
      "critical": 1000             // Critical at 1000 entries
    }
  }
}
```

### Customize Settings

Edit `.metadata` to change:

- **auto_push:** Set to `false` to disable automatic push
- **max_tags:** Increase/decrease max tags per entry
- **alert_thresholds:** Adjust warning/critical levels

---

## Initial Setup

### 1. Verify Git Configuration

Ensure Git is configured in `claude-intelligence-hub`:

```bash
cd ~/claude-intelligence-hub
git config user.name
git config user.email
```

If not set:
```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### 2. Verify Remote

Check Git remote is configured:

```bash
git remote -v
```

Should show:
```
origin  https://github.com/mrjimmyny/claude-intelligence-hub.git (fetch)
origin  https://github.com/mrjimmyny/claude-intelligence-hub.git (push)
```

### 3. Test Permissions

Verify write permissions:

```bash
cd ~/claude-intelligence-hub/session-memoria/knowledge/entries
mkdir -p test/01
touch test/01/test.md
rm -rf test
```

If errors occur, check directory permissions.

---

## Testing

### Test Save Workflow

1. **Start Claude Code:**
   ```bash
   claude
   ```

2. **Test trigger:**
   ```
   You: "Xavier, registre isso: teste de instalação do session-memoria"
   ```

3. **Verify:**
   - Xavier should detect trigger
   - Suggest metadata
   - Create entry after confirmation
   - Show entry ID

4. **Check files created:**
   ```bash
   cd ~/claude-intelligence-hub/session-memoria/knowledge
   ls -la entries/2026/02/
   cat index/by-date.md
   cat metadata.json
   ```

### Test Search Workflow

1. **Search for test entry:**
   ```
   You: "Xavier, busca tema teste"
   ```

2. **Verify:**
   - Search results shown
   - Entry preview displayed
   - Can view full entry

### Test Stats Command

1. **View statistics:**
   ```
   You: /session-memoria stats
   ```

2. **Verify:**
   - Total entries: 1
   - Category distribution shown
   - Tags listed

---

## Integration with jimmy-core-preferences

### Update Core Preferences

Add to `jimmy-core-preferences/SKILL.md`:

```markdown
## Knowledge Management Integration

### Session Memoria Triggers

Jimmy should recognize when to use session-memoria:

**Proactive Offering:**
- When user mentions important decisions
- When valuable insights are shared
- When project ideas are discussed

**Proactive Recall:**
- When user asks about past conversations
- When current topic relates to previous entries
```

### Reload Skills

After updating jimmy-core-preferences:

```bash
claude reload
```

Or restart Claude Code.

---

## Troubleshooting

### Skill Not Detected

**Problem:** `session-memoria` doesn't appear in skills list

**Solutions:**
1. Check file location: `~/.claude/skills/user/session-memoria`
2. Verify `.metadata` file exists and is valid JSON
3. Restart Claude Code
4. Check Claude Code logs

### Git Commit Fails

**Problem:** Auto-commit fails with permission errors

**Solutions:**
1. Verify Git credentials configured
2. Check GitHub token/SSH key
3. Test manual commit:
   ```bash
   cd ~/claude-intelligence-hub
   git add .
   git commit -m "test"
   git push
   ```
4. If fails, set `auto_push: false` in `.metadata`

### Entry Not Created

**Problem:** Save workflow completes but no file created

**Solutions:**
1. Check directory permissions
2. Verify path in error message
3. Check disk space
4. Try manual file creation:
   ```bash
   cd ~/claude-intelligence-hub/session-memoria/knowledge/entries
   mkdir -p 2026/02
   touch 2026/02/test.md
   ```

### Search Returns No Results

**Problem:** Search doesn't find existing entries

**Solutions:**
1. Verify entry added to indices (check `index/by-*.md` files)
2. Try exact entry ID search
3. Check case sensitivity (should be case-insensitive)
4. Verify Grep tool is working:
   ```bash
   cd ~/claude-intelligence-hub/session-memoria/knowledge/index
   grep -i "test" by-date.md
   ```

### Metadata.json Corrupted

**Problem:** `metadata.json` contains invalid data

**Solutions:**
1. Backup current file:
   ```bash
   cp metadata.json metadata.json.backup
   ```
2. Restore from template (in SKILL.md)
3. Manually reconstruct stats from index files
4. Set counters back to 0 if needed

---

## Maintenance

### Regular Checks

**Weekly:**
- Review new entries for quality
- Check tag consistency
- Verify Git sync working

**Monthly:**
- Review statistics
- Check growth rate
- Consolidate similar tags if needed

**Every 6 months:**
- Evaluate alert thresholds
- Consider archiving old entries (when > 1000)
- Review category distribution

### Backup

Session memoria is Git-backed, but for extra safety:

```bash
# Full backup
cd ~/claude-intelligence-hub
tar -czf session-memoria-backup-$(date +%Y%m%d).tar.gz session-memoria/

# Backup to external location
rsync -av ~/claude-intelligence-hub/session-memoria /path/to/backup/
```

### Updates

When new versions are released:

1. **Check changelog:**
   ```bash
   cat ~/claude-intelligence-hub/session-memoria/CHANGELOG.md
   ```

2. **Pull latest:**
   ```bash
   cd ~/claude-intelligence-hub
   git pull origin main
   ```

3. **Review breaking changes**

4. **Test with new version**

---

## Uninstallation

To remove session-memoria:

1. **Backup data first:**
   ```bash
   cp -r ~/claude-intelligence-hub/session-memoria ~/session-memoria-backup
   ```

2. **Remove from skills:**
   ```bash
   rm -rf ~/.claude/skills/user/session-memoria
   ```

3. **Remove from intelligence hub (optional):**
   ```bash
   cd ~/claude-intelligence-hub
   git rm -r session-memoria
   git commit -m "remove session-memoria skill"
   git push
   ```

---

## Support

### Getting Help

1. **Check documentation:**
   - README.md (usage guide)
   - SKILL.md (technical details)
   - CHANGELOG.md (known issues)

2. **GitHub Issues:**
   - Report bugs: https://github.com/mrjimmyny/claude-intelligence-hub/issues
   - Request features: Use "enhancement" label

3. **Community:**
   - Discussions: GitHub Discussions
   - Questions: Use "question" label in issues

---

## Next Steps

After successful installation:

1. ✅ Create first entry (test save workflow)
2. ✅ Test search functionality
3. ✅ View statistics
4. ✅ Integrate with jimmy-core-preferences
5. ✅ Start capturing knowledge!

---

**Installation complete! 🎉**

Xavier is now equipped with permanent memory. Start building your knowledge base!

---

**Skill maintained by Xavier**
**Version:** 1.0.0
**Last updated:** 2026-02-10
