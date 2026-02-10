# Jimmy Core Preferences

> 🎯 **Master Skill** - Universal preferences and working style for Claude across all projects

## What is This?

This is the **central intelligence hub** for how Claude should work with Jimmy. Instead of repeating preferences in every conversation or project, this skill serves as a permanent reference that Claude automatically loads at the start of every session.

Think of it as Claude's "instruction manual" for working with you.

---

## 🎯 Purpose

- ✅ **Eliminate repetition** - Stop reminding Claude of the same things
- ✅ **Maintain consistency** - Same working style across all projects
- ✅ **Enable learning** - Claude updates this as it learns your preferences
- ✅ **Stay synchronized** - GitHub keeps it safe and version-controlled

---

## 📦 What's Inside

| Section | Description |
|---------|-------------|
| **Core Principles** | Fundamental rules (honesty, objectivity, proactivity) |
| **Do's & Don'ts** | Clear guidance on communication and work style |
| **Workflow Patterns** | How to handle common scenarios |
| **Context Management** | Rules for managing conversation limits |
| **Tool Preferences** | Git, code quality, documentation standards |
| **Learning System** | How Claude updates this skill automatically |

---

## 🚀 How It Works

### 1. **Auto-Load at Session Start**
When you start Claude Code (or any Claude session), this skill is automatically loaded first, giving Claude immediate context about your preferences.

### 2. **Dynamic Updates**
When you say things like:
- "Remember to always do X"
- "Don't do Y anymore"
- "This is important for future sessions"

Claude will:
1. Update this skill
2. Commit changes to GitHub
3. Notify you briefly: `✓ Added to jimmy-core-preferences`

### 3. **Sync Everywhere**
Because this lives in your `claude-intelligence-hub` GitHub repo:
- ✅ Works on any machine (just clone the repo)
- ✅ Never lost (version controlled)
- ✅ Can be reviewed/edited manually
- ✅ History of all changes (via git log)

---

## 📁 File Structure

```
jimmy-core-preferences/
├── README.md              ← You are here (human docs)
├── SKILL.md               ← Main file Claude reads
├── CHANGELOG.md           ← History of updates
└── .metadata              ← Version and config info
```

---

## 🔧 Setup Instructions

### Initial Setup (First Time)

1. **Clone the claude-intelligence-hub repo** (if not already):
   ```bash
   git clone https://github.com/mrjimmyny/claude-intelligence-hub.git
   ```

2. **Link to Claude Code** (local copy):
   ```bash
   # Option 1: Symlink (recommended)
   ln -s ~/path/to/claude-intelligence-hub/jimmy-core-preferences ~/.claude/skills/user/jimmy-core-preferences

   # Option 2: Copy
   cp -r ~/path/to/claude-intelligence-hub/jimmy-core-preferences ~/.claude/skills/user/
   ```

3. **Verify it's loaded**:
   Open Claude Code and check:
   ```
   /skills list
   ```
   You should see `jimmy-core-preferences` in the list.

### Keeping It Updated

**Option A: Automatic (Recommended)**
- Claude automatically updates the skill during sessions
- Changes are committed to GitHub
- Just `git pull` periodically in your local repo

**Option B: Manual**
- Edit `SKILL.md` directly in GitHub
- Pull changes to local machine
- Changes apply on next Claude session

---

## 🎛️ Configuration

### Auto-Load Settings

This skill is configured to load automatically at session start with **highest priority**. This is controlled in `.metadata`:

```json
{
  "auto_load": true,
  "priority": "highest"
}
```

### Customization

You can edit `SKILL.md` to:
- Add new rules
- Modify communication style preferences
- Update workflow patterns
- Refine context management rules

**Best Practice:** Make changes via Claude during sessions so they're properly documented and committed.

---

## 💡 Usage Examples

### Example 1: Teaching Claude a New Preference

**You say:**
> "Xavier, from now on, always use single quotes in JavaScript, not double quotes."

**Claude does:**
1. Updates `SKILL.md` → "Code Quality" section
2. Adds: "JavaScript: Use single quotes (`'`) not double (`\"`)"
3. Commits to GitHub
4. Responds: `✓ Registered preference: JS single quotes`

### Example 2: Context Management

**Scenario:** Long conversation approaching context limit

**Claude proactively says:**
> "We're at ~75% context capacity. Should we continue or would you like me to compact and create a summary?"

*(Based on rules in Context Management section)*

### Example 3: Challenging Your Idea

**You say:**
> "Let's refactor everything to use global variables for simplicity."

**Claude responds:**
> "I understand you want simplicity, but global variables will cause these issues:
> 1. [Issue A]
> 2. [Issue B]
> 
> Instead, consider these approaches:
> - **Option 1:** Module pattern (clean, maintainable)
> - **Option 2:** Dependency injection (testable)
> - **Option 3:** React Context (if using React)
> 
> Which aligns best with your priority?"

*(Following "Radical Honesty" principle)*

---

## 🔄 Update Workflow

```
┌─────────────────────────────────────────┐
│  You mention a new preference           │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Claude identifies if it's:             │
│  - Universal (goes here)                │
│  - Project-specific (goes to project)   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Updates SKILL.md                       │
│  Updates CHANGELOG.md                   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Commits to GitHub                      │
│  (if in Claude Code session)            │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Confirms to you briefly                │
│  ✓ Added to jimmy-core-preferences      │
└─────────────────────────────────────────┘
```

---

## 📊 Maintenance

### Weekly
- Review `CHANGELOG.md` to see what Claude learned
- Pull latest from GitHub if using multiple machines

### Monthly
- Read through `SKILL.md` to ensure it's still accurate
- Remove outdated rules
- Consolidate similar rules

### As Needed
- Add new sections when you identify patterns
- Refactor for clarity
- Share updates across your team (if applicable)

---

## 🤝 Contributing (If Team Usage)

If you're using this in a team context:

1. Fork or branch for team member preferences
2. Use pull requests for major changes
3. Discuss significant preference conflicts
4. Maintain clear commit messages

---

## 🔗 Related Skills

This Master Skill works alongside domain-specific skills:

- **[pbi-claude-skills](../pbi-claude-skills/)** - Power BI workflows
- **[python-claude-skills](../python-claude-skills/)** - Python development
- **[git-claude-skills](../git-claude-skills/)** - Git workflows

Domain skills **extend** (not replace) these core preferences.

---

## 📝 Version History

See [CHANGELOG.md](./CHANGELOG.md) for detailed version history.

**Current Version:** 1.0.0  
**Status:** ✅ Production Ready  
**Last Updated:** 2025-02-09

---

## 📄 License

MIT License - Part of the [claude-intelligence-hub](https://github.com/mrjimmyny/claude-intelligence-hub) repository.

---

## 🙏 Credits

Created using [Claude Code](https://claude.ai/code) by Anthropic.  
Maintained by: [@mrjimmyny](https://github.com/mrjimmyny)

---

**Questions?** Open an issue in the [main repository](https://github.com/mrjimmyny/claude-intelligence-hub/issues).
