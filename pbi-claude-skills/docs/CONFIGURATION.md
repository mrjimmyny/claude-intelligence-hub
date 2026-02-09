# Configuration Guide - pbi_config.json

Complete reference for `pbi_config.json` configuration file.

## 📋 Overview

`pbi_config.json` parametrizes project-specific values, making skills portable across different Power BI projects.

**Location:** Project root directory

---

## 🔑 Complete Schema

```json
{
  "project": {
    "name": "your_project_name",
    "type": "pbip",
    "semantic_model": {
      "name": "YourProject.SemanticModel",
      "path": "YourProject.SemanticModel/definition"
    }
  },
  "tables": {
    "main_dax": "DAX",
    "dax_variants": [
      "DAX_Variance_PCT",
      "DAX_Variance_ABS",
      "DAX_Texts"
    ]
  },
  "index": {
    "file": "POWER_BI_INDEX.md",
    "auto_update": true
  },
  "data_source": {
    "type": "GoogleBigQuery",
    "connection_name": "BigQuery Connection"
  },
  "conventions": {
    "measure_naming": "snake_case",
    "prefixes": ["tot_", "avg_", "pct_"],
    "suffixes": ["_cy", "_py", "_yoy"]
  }
}
```

---

## 📖 Field Reference

### `project.name`
- **Type:** String
- **Required:** Yes
- **Description:** Project name (used in logs and messages)
- **Example:** `"hr_kpis_board_v2"`

### `project.type`
- **Type:** String
- **Required:** Yes
- **Values:** `"pbip"` (Power BI Project)
- **Description:** Project format type

### `project.semantic_model.name`
- **Type:** String
- **Required:** Yes
- **Description:** Name of the `.SemanticModel` directory
- **Example:** `"hr_kpis_board_v2.SemanticModel"`
- **How to find:** `Get-ChildItem -Directory -Filter "*.SemanticModel"`

### `project.semantic_model.path`
- **Type:** String
- **Required:** Yes
- **Description:** Relative path to definition directory
- **Example:** `"hr_kpis_board_v2.SemanticModel/definition"`
- **Pattern:** `"{semantic_model.name}/definition"`

### `tables.main_dax`
- **Type:** String
- **Required:** Yes
- **Description:** Name of primary DAX measures table
- **Default:** `"DAX"`
- **Example:** `"DAX"` or `"Measures"`

### `tables.dax_variants`
- **Type:** Array[String]
- **Required:** No
- **Description:** Additional DAX tables (variants)
- **Example:** `["DAX_Variance_PCT", "DAX_Texts"]`

### `index.file`
- **Type:** String
- **Required:** Yes
- **Description:** Name of index file
- **Default:** `"POWER_BI_INDEX.md"`

### `index.auto_update`
- **Type:** Boolean
- **Required:** No
- **Description:** Auto-update index after changes
- **Default:** `true`

### `data_source.type`
- **Type:** String
- **Required:** No
- **Description:** Type of data source (documentation only)
- **Examples:** `"GoogleBigQuery"`, `"SQL Server"`, `"Azure SQL"`

### `conventions.measure_naming`
- **Type:** String
- **Required:** No
- **Values:** `"snake_case"`, `"camelCase"`, `"PascalCase"`
- **Description:** Naming convention for measures

### `conventions.prefixes`
- **Type:** Array[String]
- **Required:** No
- **Description:** Common measure prefixes
- **Example:** `["tot_", "avg_", "pct_", "sum_"]`

### `conventions.suffixes`
- **Type:** Array[String]
- **Required:** No
- **Description:** Common measure suffixes
- **Example:** `["_cy", "_py", "_yoy", "_mom"]`

---

## ✅ Validation

```powershell
# Validate JSON syntax
Get-Content pbi_config.json | ConvertFrom-Json

# Validate structure (using hub script)
cd .claude\_hub\pbi-claude-skills\scripts
.\validate_skills.ps1
```

---

## 🔧 Common Configurations

### Simple Project

```json
{
  "project": {
    "name": "sales_dashboard",
    "type": "pbip",
    "semantic_model": {
      "name": "SalesDashboard.SemanticModel",
      "path": "SalesDashboard.SemanticModel/definition"
    }
  },
  "tables": {
    "main_dax": "Measures"
  },
  "index": {
    "file": "POWER_BI_INDEX.md"
  }
}
```

### Complex Project (Multiple DAX Tables)

```json
{
  "project": {
    "name": "hr_analytics",
    "type": "pbip",
    "semantic_model": {
      "name": "HRAnalytics.SemanticModel",
      "path": "HRAnalytics.SemanticModel/definition"
    }
  },
  "tables": {
    "main_dax": "DAX",
    "dax_variants": [
      "DAX_KPIs",
      "DAX_Forecasting",
      "DAX_Variance"
    ]
  },
  "index": {
    "file": "INDEX.md",
    "auto_update": true
  },
  "data_source": {
    "type": "Azure SQL Database",
    "connection_name": "HR_DB_Prod"
  },
  "conventions": {
    "measure_naming": "snake_case",
    "prefixes": ["tot_", "avg_", "pct_", "max_", "min_"],
    "suffixes": ["_cy", "_py", "_yoy", "_qoq", "_mom"]
  }
}
```

---

## 🚨 Troubleshooting

### Error: "Invalid JSON syntax"

```powershell
# Test JSON parsing
try {
    Get-Content pbi_config.json | ConvertFrom-Json
    Write-Host "JSON is valid"
} catch {
    Write-Host "JSON Error: $($_.Exception.Message)"
}
```

**Common issues:**
- Missing comma
- Trailing comma (not allowed in JSON)
- Unescaped quotes
- Incorrect encoding (use UTF-8)

### Error: "Semantic model not found"

**Check path:**
```powershell
Test-Path "YourProject.SemanticModel\definition"
```

**If false:**
```json
// Correct the path in pbi_config.json
{
  "project": {
    "semantic_model": {
      "path": "CorrectName.SemanticModel/definition"  // ← Fix here
    }
  }
}
```

---

## 💡 Best Practices

1. **Commit to Git:** Version control your config
2. **Document conventions:** Use `conventions` section
3. **Validate after edit:** Run `ConvertFrom-Json` test
4. **Team consistency:** Same config format across team

---

**Questions?** https://github.com/mrjimmyny/claude-intelligence-hub/issues
