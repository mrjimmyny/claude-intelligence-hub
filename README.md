# Claude Intelligence Hub

> 🧠 Centralized Claude Code skills hub for multiple project types

A hierarchical repository of reusable Claude Code skills, templates, and automation scripts for various development contexts.

## 🎯 What is this?

This hub organizes Claude Code skills by project type, making them easy to discover, reuse, and maintain across multiple projects. Instead of duplicating skills in each project, you clone once and update everywhere.

## 📦 Available Skill Collections

| Collection | Status | Description |
|------------|--------|-------------|
| **[pbi-claude-skills](pbi-claude-skills/)** | 🚧 In Development | Power BI PBIP projects |
| **[python-claude-skills](python-claude-skills/)** | 📋 Planned | Python development |
| **[git-claude-skills](git-claude-skills/)** | 📋 Planned | Git workflows |

## ⚡ Quick Start

### For Power BI Projects

```powershell
# 1. Clone this hub
git clone https://github.com/mrjimmyny/claude-intelligence-hub.git

# 2. Run setup script for your project
cd claude-intelligence-hub/pbi-claude-skills
.\scripts\setup_new_project.ps1 -ProjectPath "C:\path\to\your\pbi\project"

# 3. Start using skills
cd C:\path\to\your\pbi\project
claude
/pbi-discover
```

See [pbi-claude-skills/README.md](pbi-claude-skills/README.md) for details.

## 🏗️ Hub Architecture

```
claude-intelligence-hub/
├── pbi-claude-skills/           # Power BI skills
│   ├── skills/                  # Reusable .md skills
│   ├── templates/               # Project templates
│   ├── scripts/                 # Automation (PowerShell)
│   └── docs/                    # Guides
├── python-claude-skills/        # (Future) Python skills
├── git-claude-skills/           # (Future) Git skills
├── docs/                        # Global documentation
└── CHANGELOG.md                 # Version history
```

## 🔄 Updating Skills

**Single project:**
```powershell
cd your-project\.claude\_hub
git pull
```

**All projects:**
```powershell
cd claude-intelligence-hub\pbi-claude-skills
.\scripts\update_all_projects.ps1
```

## 📖 Documentation

- [Power BI Skills Guide](pbi-claude-skills/README.md)
- [Contributing Guidelines](docs/CONTRIBUTING.md) _(coming soon)_
- [Architecture Overview](docs/ARCHITECTURE.md) _(coming soon)_
- [Changelog](CHANGELOG.md)

## 🤝 Contributing

Contributions are welcome! This is a public repository designed to help the Claude Code community.

1. Fork the project
2. Create your feature branch: `git checkout -b feature/new-skill`
3. Commit your changes: `git commit -m 'Add: new-skill for X'`
4. Push to branch: `git push origin feature/new-skill`
5. Open a Pull Request

## 💡 Why a Hub?

**Before (per-project skills):**
- ❌ Duplicate skills across 9 projects
- ❌ Manual updates (5 min × 9 projects = 45 min)
- ❌ No version control
- ❌ Risk of data loss

**After (centralized hub):**
- ✅ Single source of truth
- ✅ `git pull` = 5 seconds to update all
- ✅ Full version history
- ✅ Automatic GitHub backup

## 📄 License

MIT License - see [LICENSE](LICENSE)

## 🙏 Credits

Developed using [Claude Code](https://claude.ai/code) by Anthropic.

---

**Current Version:** v1.0.0 (In Development)
**Last Updated:** 2026-02-08
