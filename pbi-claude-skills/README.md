# Power BI Claude Skills

> **Status:** 🚧 In Development

Centralized skills and templates for Power BI PBIP projects using Claude Code.

## 📚 Skills Available (Coming Soon)

| Skill | Comando | Descrição |
|-------|---------|-----------|
| **pbi-add-measure** | `/pbi-add-measure nome "DAX" "formato"` | Adiciona medida DAX |
| **pbi-query-structure** | `/pbi-query-structure tabelas [tipo]` | Consulta estrutura |
| **pbi-discover** | `/pbi-discover` | Descoberta rápida do projeto |
| **pbi-index-update** | `/pbi-index-update` | Regenera índice completo |
| **pbi-context-check** | `/pbi-context-check` | Verifica contexto/tokens |

## 🛠️ Structure

```
pbi-claude-skills/
├── skills/          # Reusable Claude Code skills
├── templates/       # Project templates (.claudecode, pbi_config, etc.)
├── scripts/         # PowerShell automation scripts
└── docs/            # Documentation (INSTALLATION, MIGRATION, etc.)
```

## 📖 Documentation

See [docs/](docs/) for complete guides.

---

**Part of:** [Claude Intelligence Hub](https://github.com/mrjimmyny/claude-intelligence-hub)
