# Session Memoria - Index Template

## Index Structure

Each index file follows this pattern:

### Entry Format
```
[YYYY-MM-DD-NNN] HH:MM | Category | Summary
Tags: tag1, tag2, tag3
→ [Read entry](../entries/YYYY/MM/YYYY-MM-DD_topic-slug.md)
```

### Grouping
Entries are grouped by the index type:
- **by-date.md**: Grouped by YYYY-MM (newest first)
- **by-category.md**: Grouped by category (alphabetical)
- **by-tag.md**: Grouped by tag with frequency count

### Maintenance
- Auto-updated on every entry save
- Manual updates discouraged (use skill commands)
- Validation on each update
