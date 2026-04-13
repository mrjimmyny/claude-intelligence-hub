# bi-datavizx — Operations Guide with Examples

> A comprehensive, example-driven reference for every operation available in the bi-datavizx skill. Each operation includes a plain-language explanation, who benefits from it, and practical examples showing exactly what happens when you use it.

**Version:** 1.0 | **Skill version:** 1.1.0 | **Audience:** All levels

**Companion documents:**
- [README.md](./README.md) — overview, installation, prerequisites, FAQ
- [SKILL.md](./SKILL.md) — full operational reference (modules, commands, governance rules, DAX standards)

---

## How bi-datavizx Works

Think of Power BI as having two sides:

- **The frontend** — how your dashboard looks: colors, backgrounds, layout, fonts. This is handled by [bi-designerx](../bi-designerx/).
- **The backend** — how your dashboard works: where the data comes from, how it is modeled, what calculations exist, how the report is structured. This is handled by **bi-datavizx**.

bi-datavizx wraps two powerful external engines:
- **pbi-cli** — controls Power BI Desktop (the application you install on your computer)
- **pbir-cli** — controls PBIR files directly (no Desktop needed)

You never have to learn these engines. You just use `bdvx` commands, and bi-datavizx routes your request to the right engine automatically.

### Who uses bi-datavizx?

You — through any AI agent (Claude Code, Codex, or Gemini). You tell the agent what you want in plain language, and the agent translates it into `bdvx` commands. You can also run commands directly if you prefer.

---

## 1. Project Discovery and Intelligence

These operations help you find, understand, and navigate your Power BI projects without opening Power BI Desktop.

---

### 1.1 Discover Projects

**What it does:** Scans a folder on your computer and finds all Power BI projects (`.pbip` files) inside it, including nested subfolders.

**Who benefits:** Everyone. Before you can work on a project, you need to know it exists and where it lives.

**Example 1 — Finding all projects in a workspace:**
```
Command:  bdvx project discover C:/projects/finance
Output:   Found 3 PBIP projects:
          1. C:/projects/finance/budget-2026/budget.pbip
          2. C:/projects/finance/monthly-kpis/kpis.pbip
          3. C:/projects/finance/cash-flow/cashflow.pbip
```

**Example 2 — Scanning a personal folder:**
```
Command:  bdvx project discover C:/users/jimmy/reports
Output:   Found 1 PBIP project:
          1. C:/users/jimmy/reports/hr-dashboard/hr.pbip
```

---

### 1.2 Build Structural Index

**What it does:** Creates a compact summary file called `POWER_BI_INDEX.md` that lists everything in your project — every table, measure, relationship, page, and visual — in a single organized document. This is the key to making the AI agent work 50-97% faster (fewer tokens consumed per query).

**Who benefits:** Everyone, especially teams working on large models. A project with 37 tables and 618 measures becomes instantly navigable.

**Example 1 — Building an index for a complex project:**
```
Command:  bdvx project index-build C:/projects/hr-kpis
Output:   Index built successfully:
          - Tables: 37
          - Measures: 618
          - Relationships: 42
          - Pages: 12
          - Visuals: 89
          - Index saved to: C:/projects/hr-kpis/POWER_BI_INDEX.md
          - Token savings estimate: 94% on structural queries
```

**Example 2 — Rebuilding after model changes:**
```
Command:  bdvx project index-build C:/projects/hr-kpis --rebuild
Output:   Index rebuilt. Changes detected:
          - 2 new measures added
          - 1 table renamed (employees -> team_members)
          - Token savings estimate: 93%
```

---

### 1.3 Query Project Structure

**What it does:** Lets you ask questions about your project structure and get instant answers from the index — without opening the actual model files.

**Who benefits:** Everyone. Beginners can explore a model they did not build. Advanced users can quickly find specific items in large models.

**Example 1 — Finding all measures related to revenue:**
```
Command:  bdvx project query measures --filter "revenue" --project C:/projects/sales
Output:   Found 8 measures matching "revenue":
          1. [Sales].[Total Revenue]         — TOTALYTD(...)
          2. [Sales].[Revenue YoY %]         — DIVIDE(...)
          3. [Sales].[Revenue MTD]           — TOTALMTD(...)
          4. [Sales].[Revenue per Employee]  — DIVIDE(...)
          ... (4 more)
```

**Example 2 — Listing all visuals on a specific page:**
```
Command:  bdvx project query visuals --page "Executive Summary" --project C:/projects/sales
Output:   Found 7 visuals on "Executive Summary":
          1. Card — Total Revenue
          2. Card — Active Customers
          3. Clustered Bar Chart — Revenue by Region
          4. Line Chart — Revenue Trend (12 months)
          5. Table — Top 10 Products
          6. Slicer — Date Range
          7. Slicer — Region
```

---

### 1.4 Validate Index Integrity

**What it does:** Checks that the index still matches the actual project files on disk. If something changed (a table was renamed, a page was deleted), it detects the drift and auto-regenerates the index.

**Who benefits:** Teams where multiple people edit the same project. Catches stale information before it causes problems.

**Example:**
```
Command:  bdvx project validate C:/projects/sales
Output:   Validation result: 2 drifts detected
          - Table "dim_customer" renamed to "dim_clients" in model
          - Page "Overview" deleted from report
          Index auto-regenerated. All paths now valid.
```

---

### 1.5 Watch for Changes

**What it does:** Monitors your project folder in real time. When you (or Power BI Desktop) save changes, the index updates automatically in the background.

**Who benefits:** Advanced users working in active development sessions where the model changes frequently.

**Example:**
```
Command:  bdvx project discover C:/projects/sales --watch
Output:   Watching C:/projects/sales for changes...
          [11:32:15] Detected: new measure "Gross Margin %" added to [Sales]
          [11:32:15] Index updated (619 measures -> 620 measures)
          [11:35:02] Detected: page "Regional Breakdown" added to report
          [11:35:02] Index updated (12 pages -> 13 pages)
```

---

## 2. Credential and Security Management

These operations manage the passwords, API keys, and tokens your project needs to connect to data sources — securely, without ever exposing secrets in plain text.

---

### 2.1 Store a Credential

**What it does:** Saves a secret (password, API key, OAuth token) in Windows Credential Manager, encrypted by Windows itself. The secret never appears in any config file, log, or chat message.

**Who benefits:** Everyone who connects to external data sources (BigQuery, SharePoint, Fabric, etc.).

**Example:**
```
Command:  bdvx credential set bdvx/finance/bigquery/service-account
Prompt:   Enter credential value: ********
Output:   Credential stored successfully.
          Key: bdvx/finance/bigquery/service-account
          Machine: DESKTOP-PC
          Stored at: 2026-04-12 11:30
```

---

### 2.2 Retrieve a Credential

**What it does:** Fetches a stored credential at runtime so the skill can connect to a data source. The value is decrypted in memory, used for the current operation, and never written anywhere.

**Who benefits:** This happens automatically when you run data operations. You do not need to run this manually.

**Example (automatic, behind the scenes):**
```
Internal: bdvx credential get bdvx/finance/bigquery/service-account
Result:   Credential resolved. Injecting into BigQuery client environment.
          (value never logged, never displayed)
```

---

### 2.3 List Credentials

**What it does:** Shows which credentials you have stored — key names only, never the actual values. Includes the machine where each credential lives and when it was last rotated.

**Who benefits:** Administrators and anyone managing multiple data sources across machines.

**Example:**
```
Command:  bdvx credential list
Output:   Stored credentials (3):
          Key                                      Machine        Last rotated
          bdvx/finance/bigquery/service-account     DESKTOP-PC     2026-04-10
          bdvx/finance/sharepoint/graph-token       DESKTOP-PC     2026-04-08
          bdvx/hr/bigquery/read-only                LAPTOP-01      2026-03-28
```

---

### 2.4 Rotate a Credential

**What it does:** Replaces an existing credential with a new value. The old value is archived for 30 days (in case you need to roll back), and the rotation event is logged in the audit trail.

**Who benefits:** Security-conscious teams that rotate credentials periodically, or anyone whose API key expired.

**Example:**
```
Command:  bdvx credential rotate bdvx/finance/bigquery/service-account
Prompt:   Enter new credential value: ********
Output:   Credential rotated.
          Old value archived until: 2026-05-12
          Audit event: credential_rotated (audit_id: a_8f3c2e1b)
```

---

### 2.5 Revoke a Credential

**What it does:** Permanently removes a credential from the store. This cannot be undone, so it requires your explicit confirmation.

**Who benefits:** Anyone decommissioning a data source or rotating to a completely new credential scheme.

**Example:**
```
Command:  bdvx credential revoke bdvx/old-project/sharepoint/token
Prompt:   This is irreversible. Type "yes" to confirm: yes
Output:   Credential revoked.
          Audit event: credential_revoked (audit_id: a_2d4b7e3f)
```

---

### 2.6 Probe Credential Validity

**What it does:** Tests whether a stored credential still works for a given data source without running a full data operation. A quick health check.

**Who benefits:** Anyone troubleshooting connection failures or verifying credentials after a rotation.

**Example:**
```
Command:  bdvx data-ingest credential-probe --source finance-bq --kind bigquery
Output:   Credential probe result:
          Source: finance-bq
          Credential key: bdvx/finance/bigquery/service-account
          Status: valid
          Provider: Windows Credential Manager
```

---

## 3. Data Ingestion (Connecting to Data Sources)

These operations automate the process of connecting Power BI to external data sources — the part that traditionally requires manual clicks through Power Query Editor.

---

### 3.1 Import from BigQuery

**What it does:** Connects to a Google BigQuery dataset, reads the schema (columns, types), and generates the Power Query / M code needed to bring that data into your Power BI project. Zero manual steps.

**Who benefits:** Anyone who needs BigQuery data in Power BI. Eliminates the manual process of creating a connection, selecting tables, and mapping columns.

**Example 1 — Importing a BigQuery table:**
```
Command:  bdvx data-ingest bigquery import \
            --source finance-bq \
            --path "analytics.finance.monthly_revenue" \
            --destination C:/projects/finance/report.pbip
Output:   Import plan generated:
          Source: analytics.finance.monthly_revenue (BigQuery)
          Columns: 8 (date, region, product_line, revenue, cost, margin, units, currency)
          Inferred types: date->Date, revenue->Decimal, units->Int64, ...
          M expression: generated (132 lines)
          Status: ready for write — run with --apply to write
```

**Example 2 — Importing from a custom SQL query:**
```
Command:  bdvx data-ingest bigquery import \
            --source finance-bq \
            --path "SELECT date, SUM(revenue) AS total FROM analytics.finance.daily GROUP BY date" \
            --destination C:/projects/finance/report.pbip
Output:   Import plan generated:
          Source: Custom SQL query (BigQuery)
          Columns: 2 (date, total)
          M expression: generated (45 lines, includes query folding)
          Status: ready for write
```

---

### 3.2 Import from SharePoint

**What it does:** Connects to a SharePoint list or document library, reads its structure, and generates the M code for import.

**Who benefits:** Teams that maintain data in SharePoint lists (common in corporate environments).

**Example:**
```
Command:  bdvx data-ingest sharepoint import \
            --source hr-sharepoint \
            --site "sites/HR-Portal" \
            --list "Employee Directory" \
            --destination C:/projects/hr/report.pbip
Output:   Import plan generated:
          Source: Employee Directory (SharePoint list)
          Columns: 15 (name, department, title, hire_date, location, ...)
          Inferred types: hire_date->Date, name->Text, ...
          M expression: generated (87 lines)
          Status: ready for write
```

---

### 3.3 Create M Expression

**What it does:** Generates a new Power Query / M expression from a source specification with proper parameters and validation rules.

**Who benefits:** Intermediate to advanced users building data pipelines from scratch.

**Example:**
```
Command:  bdvx data-ingest m create \
            --source finance-bq \
            --kind bigquery \
            --parameters '{"dataset": "analytics.finance", "table": "monthly_revenue"}'
Output:   M expression created:
          let
              Source = GoogleBigQuery.Database("analytics"),
              finance = Source{[Name="finance"]}[Data],
              monthly_revenue = finance{[Name="monthly_revenue"]}[Data],
              #"Changed Type" = Table.TransformColumnTypes(monthly_revenue, ...)
          in
              #"Changed Type"

          Parameters: dataset=analytics.finance, table=monthly_revenue
          Validation: syntax OK, types resolved
```

---

### 3.4 Update M Expression

**What it does:** Modifies an existing Power Query expression and shows you a diff of what will change before applying.

**Who benefits:** Anyone who needs to change a data source connection, add a filter, or modify transformation logic.

**Example:**
```
Command:  bdvx data-ingest m update \
            --project C:/projects/finance/report.pbip \
            --object "monthly_revenue" \
            --parameters '{"table": "monthly_revenue_v2"}'
Output:   Diff (before -> after):
          - finance{[Name="monthly_revenue"]}[Data],
          + finance{[Name="monthly_revenue_v2"]}[Data],
          Status: diff generated — run with --apply to write
```

---

### 3.5 Preview M Expression

**What it does:** Runs a candidate M expression against the data source and returns the first N rows so you can verify the data before committing changes.

**Who benefits:** Everyone. "Show me the data before you change anything" is always a good idea.

**Example:**
```
Command:  bdvx data-ingest m preview --source finance-bq --expression "..." --top 5
Output:   Preview (top 5 rows):
          | date       | region     | revenue    | margin  |
          |------------|------------|------------|---------|
          | 2026-03-01 | LATAM      | 1,234,567  | 42.3%   |
          | 2026-03-01 | EMEA       | 2,345,678  | 38.1%   |
          | 2026-03-01 | NA         | 3,456,789  | 45.7%   |
          | 2026-02-01 | LATAM      | 1,198,432  | 41.8%   |
          | 2026-02-01 | EMEA       | 2,287,654  | 37.5%   |
          Total rows in source: 36
```

---

### 3.6 Diff M Expression

**What it does:** Compares a candidate expression against what is currently in the project, line by line.

**Who benefits:** Code reviewers and anyone validating changes before they go live.

**Example:**
```
Command:  bdvx data-ingest m diff --project C:/projects/finance/report.pbip --object "monthly_revenue"
Output:   Diff:
          Line 3:  - finance{[Name="monthly_revenue"]}[Data],
                   + finance{[Name="monthly_revenue_v2"]}[Data],
          Line 7:  + #"Added Filter" = Table.SelectRows(#"Changed Type", each [date] >= #date(2025, 1, 1)),
          Summary: 1 line changed, 1 line added, 0 lines removed
```

---

### 3.7 Rollback M Expression

**What it does:** Restores a previous version of an M expression if a recent change introduced problems.

**Who benefits:** Anyone who needs to undo a data source change quickly.

**Example:**
```
Command:  bdvx data-ingest m rollback --project C:/projects/finance/report.pbip --object "monthly_revenue"
Output:   Rolled back "monthly_revenue" to previous version.
          Rollback reference: rollback-2026-04-12T11:45:00
          Change log entry created.
```

---

### 3.8 Set Refresh Configuration

**What it does:** Binds a data source expression to a refresh policy so Power BI knows how and when to update the data (e.g., incremental refresh for large tables).

**Who benefits:** Intermediate to advanced users managing refresh schedules.

**Example:**
```
Command:  bdvx data-ingest m refresh-config-set \
            --project C:/projects/finance/report.pbip \
            --object "monthly_revenue" \
            --policy "incremental-monthly"
Output:   Refresh config applied:
          Object: monthly_revenue
          Policy: incremental-monthly (last 12 months full, older archive)
          Change log entry created.
```

---

### 3.9 Detect Schema Drift

**What it does:** Compares the current schema of your BigQuery or SharePoint source against a saved snapshot and reports any changes. Catches data source changes before they break your reports.

**Who benefits:** Everyone who connects to external data. Data sources change without warning; this operation catches those changes early.

**Example 1 — Detecting a new column added upstream:**
```
Command:  bdvx data-ingest drift detect --source finance-bq --kind bigquery
Output:   Schema drift detected (1 change):
          [LOW]  Column added: "currency_code" (STRING) in analytics.finance.monthly_revenue
          Last snapshot: 2026-04-10
          Current scan: 2026-04-12
          Recommendation: review and update M expression if needed
```

**Example 2 — Detecting a dropped column (high severity):**
```
Command:  bdvx data-ingest drift detect --source hr-sharepoint --kind sharepoint
Output:   Schema drift detected (1 change):
          [HIGH] Column dropped: "employee_id" in Employee Directory
          Impact: 3 measures reference this column
          Recommendation: URGENT — update model before next refresh
```

---

### 3.10 Check Source Health

**What it does:** Runs a quick connectivity and latency check against a configured data source.

**Who benefits:** Anyone troubleshooting "why isn't my data refreshing?" problems.

**Example:**
```
Command:  bdvx data-ingest source-health check --source finance-bq --kind bigquery
Output:   Source health:
          Source: finance-bq (BigQuery)
          Status: ok
          Latency: 145ms
          Last error: none
```

---

## 4. Semantic Model Operations (Tables, Measures, DAX)

These operations work with the data model inside your Power BI project — the tables, columns, measures, relationships, and calculations that power your reports.

---

### 4.1 Connect to Live Model

**What it does:** Opens a live connection to the semantic model running inside Power BI Desktop so the skill can read and modify it in real time.

**Who benefits:** Advanced users who need to interact with the live model for DAX testing, measure debugging, or real-time model changes.

**Example:**
```
Command:  bdvx desktop connect --project C:/projects/sales/report.pbip
Output:   Connected to live model.
          Desktop: Power BI Desktop (running, PID 12345)
          Model: Sales Report (37 tables, 618 measures)
          Session: TOM/ADOMD active
```

---

### 4.2 Execute DAX Query

**What it does:** Runs a DAX query against the live model and returns the results.

**Who benefits:** Intermediate to advanced users testing calculations, validating data, or debugging measures.

**Example 1 — Testing a simple measure:**
```
Command:  bdvx desktop dax execute --query "EVALUATE ROW(\"Total\", [Total Revenue])"
Output:   | Total      |
          |------------|
          | 12,345,678 |
          Execution time: 23ms
```

**Example 2 — Testing a more complex query:**
```
Command:  bdvx desktop dax execute --query "
            EVALUATE
            SUMMARIZECOLUMNS(
              dim_date[Year],
              dim_date[Month],
              \"Revenue\", [Total Revenue],
              \"Margin %\", [Gross Margin %]
            )
            ORDER BY dim_date[Year], dim_date[Month]"
Output:   | Year | Month | Revenue    | Margin % |
          |------|-------|------------|----------|
          | 2025 | Jan   | 1,023,456  | 42.1%    |
          | 2025 | Feb   | 1,198,765  | 43.5%    |
          | ...  | ...   | ...        | ...      |
          12 rows returned. Execution time: 45ms
```

---

### 4.3 Validate DAX Syntax

**What it does:** Checks if a DAX expression is syntactically correct before you commit it to the model. Catches typos and function errors early.

**Who benefits:** Everyone writing DAX — from beginners writing their first measure to experts writing complex calculations.

**Example:**
```
Command:  bdvx desktop dax validate --expression "TOTALYTD([Total Revenue], dim_date[Date])"
Output:   Syntax: VALID
          Functions used: TOTALYTD (time intelligence)
          References: [Total Revenue] (measure), dim_date[Date] (column)
```

---

### 4.4 Context7 DAX Lookup

**What it does:** Before writing any DAX measure, the skill consults the latest DAX documentation (via Context7) to make sure the function syntax is current and correct. This prevents the AI from using outdated or incorrect DAX patterns.

**Who benefits:** Everyone. This runs automatically in the background — you do not need to invoke it manually.

**Example (automatic, behind the scenes):**
```
Internal: Consulting Context7 for TOTALYTD function...
Result:   TOTALYTD(<expression>, <dates> [, <filter>] [, <year_end_date>])
          Confirmed: syntax matches current documentation
          Proceeding with measure creation.
```

---

### 4.5 Create / Modify Tables

**What it does:** Adds a new table or modifies an existing one in the semantic model.

**Who benefits:** Advanced users building or restructuring data models.

**Example — Adding a calculated table:**
```
Command:  bdvx desktop table add --name "dim_date_extended" \
            --expression "CALENDAR(DATE(2020,1,1), DATE(2030,12,31))"
Output:   Table created: dim_date_extended
          Columns: 1 (Date)
          Rows: 4,018 (estimated)
          Change log entry created.
```

---

### 4.6 Create / Modify Measures

**What it does:** Adds a new DAX measure or updates an existing one. Every measure request follows a structured template to ensure clarity: objective, numerator, denominator, granularity, filters, expected output.

**Who benefits:** Everyone who works with DAX measures — from simple SUM/AVERAGE to complex time intelligence.

**Example 1 — Creating a simple measure:**
```
Command:  bdvx desktop measure add \
            --table "Sales" \
            --name "Total Revenue" \
            --expression "SUM(fact_sales[revenue])" \
            --format "#,##0"
Output:   Measure created: [Sales].[Total Revenue]
          DAX: SUM(fact_sales[revenue])
          Format: #,##0
          Context7 check: PASS (SUM syntax confirmed)
          Change log entry created.
```

**Example 2 — Creating a YoY comparison measure:**
```
Command:  bdvx desktop measure add \
            --table "Sales" \
            --name "Revenue YoY %" \
            --expression "
              VAR CurrentYear = [Total Revenue]
              VAR PriorYear = CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(dim_date[Date]))
              RETURN DIVIDE(CurrentYear - PriorYear, PriorYear)
            " \
            --format "0.0%"
Output:   Measure created: [Sales].[Revenue YoY %]
          Context7 check: PASS (SAMEPERIODLASTYEAR, DIVIDE confirmed)
          Change log entry created.
```

---

### 4.7 Create / Modify Relationships

**What it does:** Defines or changes relationships between tables — the connections that tell Power BI how tables relate to each other.

**Who benefits:** Intermediate to advanced users designing star schemas or snowflake models.

**Example:**
```
Command:  bdvx desktop relationship add \
            --from "fact_sales[customer_id]" \
            --to "dim_customer[customer_id]" \
            --cardinality "many-to-one" \
            --cross-filter "single"
Output:   Relationship created:
          fact_sales[customer_id] -> dim_customer[customer_id]
          Cardinality: Many-to-One
          Cross-filter: Single direction
          Change log entry created.
```

---

### 4.8 Create Calculation Groups

**What it does:** Builds calculation groups for time intelligence (YTD, QTD, MTD, prior year) or unit conversions. Calculation groups let you reuse the same logic across many measures without duplicating DAX.

**Who benefits:** Advanced users who want to avoid creating dozens of duplicated time-intelligence measures.

**Example:**
```
Command:  bdvx desktop calcgroup add \
            --name "Time Intelligence" \
            --items '["Current", "YTD", "QTD", "MTD", "Prior Year", "YoY %"]'
Output:   Calculation group created: Time Intelligence
          Items: 6 (Current, YTD, QTD, MTD, Prior Year, YoY %)
          Applied to: all measures in the model
          Change log entry created.
```

---

### 4.9 Manage Hierarchies

**What it does:** Creates or modifies dimension hierarchies for drill-down navigation.

**Who benefits:** Anyone building reports with drill-down capabilities (Year > Quarter > Month > Day).

**Example:**
```
Command:  bdvx desktop hierarchy add \
            --table "dim_date" \
            --name "Date Hierarchy" \
            --levels '["Year", "Quarter", "Month", "Day"]'
Output:   Hierarchy created: dim_date[Date Hierarchy]
          Levels: Year -> Quarter -> Month -> Day
          Change log entry created.
```

---

### 4.10 Export / Import / Diff TMDL

**What it does:** Exports the entire semantic model as TMDL files (the modern, git-friendly format), imports TMDL changes back, or diffs two versions to see what changed.

**Who benefits:** Advanced users who version-control their models in git, or teams collaborating on the same model.

**Example — Exporting and diffing:**
```
Command:  bdvx desktop export-tmdl --project C:/projects/sales/report.pbip
Output:   TMDL exported to: C:/projects/sales/report.pbip/definition/
          Files: 42 (tables, measures, relationships, roles)

Command:  bdvx desktop diff-tmdl --project C:/projects/sales/report.pbip
Output:   TMDL diff (vs. last export):
          + New measure: [Sales].[Gross Margin %]
          ~ Modified: dim_date table (1 column added)
          - Removed: [Sales].[Old Revenue Calc] (deleted)
          3 changes total
```

---

### 4.11 TMDL Transactions

**What it does:** Groups multiple model changes into a single transaction. If something goes wrong, the entire set of changes is rolled back — no partial updates.

**Who benefits:** Advanced users making coordinated changes (e.g., renaming a column AND updating all measures that reference it).

**Example:**
```
Command:  bdvx desktop tmdl-transaction begin
Output:   Transaction started (txn_id: t_3f8a2b1c)

Command:  bdvx desktop column rename --table "fact_sales" --old "rev" --new "revenue"
Command:  bdvx desktop measure update --name "Total Revenue" --expression "SUM(fact_sales[revenue])"
Command:  bdvx desktop tmdl-transaction commit
Output:   Transaction committed. 2 changes applied atomically.
```

---

### 4.12 Manage Row-Level Security

**What it does:** Creates, tests, or removes RLS roles that control which rows different users can see.

**Who benefits:** Anyone building reports with data security requirements (e.g., regional managers see only their region's data).

**Example:**
```
Command:  bdvx desktop role add \
            --name "LATAM Manager" \
            --table "dim_region" \
            --filter "[region] = \"LATAM\""
Output:   RLS role created: LATAM Manager
          Filter: dim_region[region] = "LATAM"
          Test: run "bdvx desktop role test --name 'LATAM Manager'" to verify
```

---

### 4.13 Set Up Incremental Refresh

**What it does:** Configures incremental refresh policies on tables so only new or changed data is refreshed, saving time and capacity.

**Who benefits:** Anyone working with large datasets where full refreshes are slow or expensive.

**Example:**
```
Command:  bdvx desktop refresh-policy set \
            --table "fact_sales" \
            --incremental-range "3 months" \
            --archive-range "2 years"
Output:   Incremental refresh configured:
          Table: fact_sales
          Incremental: last 3 months (refreshed every cycle)
          Archive: 2 years (refreshed once, then read-only)
          Change log entry created.
```

---

### 4.14 Run Diagnostics

**What it does:** Starts/stops trace sessions and collects model statistics for performance analysis.

**Who benefits:** Advanced users optimizing query performance or debugging slow reports.

**Example:**
```
Command:  bdvx desktop model stats --project C:/projects/sales/report.pbip
Output:   Model statistics:
          Total memory: 245 MB
          Largest table: fact_sales (180 MB, 12.3M rows)
          Highest cardinality column: fact_sales[transaction_id] (12.3M distinct)
          Dictionary compression ratio: 8.2x average
```

---

### 4.15 DAX Authoring Standards Linter (v1.1.0)

**What it does:** Scans all DAX measures in a project against 10 formatting and authoring rules (DAX001 through DAX010). Returns violations with rule ID, severity, location, and auto-fix suggestions.

**Who benefits:** Everyone writing DAX. Enforces a consistent, readable style across all measures — especially valuable for teams.

**Example:**
```
Command:  bdvx model-ops dax lint --project C:/projects/sales/report.pbip
Output:   DAX lint: 618 measures scanned
          Violations: 4
          [DAX003] [Sales].[Revenue YoY %] — missing VAR prefix convention
          [DAX007] [Sales].[Total Revenue] — format string uses legacy pattern
          [DAX009] [HR].[Headcount] — DIVIDE not used for safe division
          [DAX010] [Sales].[Margin %] — inconsistent decimal format
          Auto-fix available: run with --fix to apply corrections
```

---

### 4.16 DAX Formatter

**What it does:** Reformats DAX expressions to match the authoring standards — consistent indentation, line breaks, casing.

**Who benefits:** Anyone inheriting a project with inconsistently formatted DAX, or teams standardizing their codebase.

**Example:**
```
Command:  bdvx model-ops dax format --project C:/projects/sales/report.pbip \
            --measure "[Sales].[Revenue YoY %]"
Output:   Formatted: [Sales].[Revenue YoY %]
          Changes: 3 (indentation, line breaks, VAR alignment)
          Diff shown. Run with --apply to write.
```

---

## 5. Report Operations (Pages, Visuals, Themes, Filters)

These operations work with the visual report layer — pages, charts, tables, slicers, themes, filters, and formatting.

---

### 5.1 Create a New Report

**What it does:** Creates a new Power BI report from scratch with its folder structure and basic configuration.

**Who benefits:** Anyone starting a new report project.

**Example:**
```
Command:  bdvx desktop report create --name "Sales Dashboard" --path C:/projects/sales/
Output:   Report created: Sales Dashboard
          Path: C:/projects/sales/Sales Dashboard.Report/
          Structure: definition.pbir, report.json, pages/ (empty)
          Status: validated (structure OK)
```

---

### 5.2 Validate Report Structure

**What it does:** Checks that a report's internal structure is correct — valid JSON, proper references, no orphan visuals.

**Who benefits:** Anyone who has been editing report files manually or wants to verify integrity after changes.

**Example:**
```
Command:  bdvx desktop report validate --project C:/projects/sales/report.pbip
Output:   Validation: PASS (0 errors, 1 warning)
          Warning: Visual "card_old_revenue" on page "Archive" references
                   measure [Sales].[Old Revenue Calc] which no longer exists.
```

---

### 5.3 Add / Rename / Reorder Pages

**What it does:** Creates new report pages, renames existing ones, or changes their display order.

**Who benefits:** Everyone building or organizing reports.

**Example 1 — Adding a page:**
```
Command:  bdvx desktop report add-page --name "Regional Breakdown" --position 3
Output:   Page added: "Regional Breakdown" (position 3 of 13)
          Change log entry created.
```

**Example 2 — Renaming a page:**
```
Command:  bdvx desktop report rename-page --old "Overview" --new "Executive Summary"
Output:   Page renamed: "Overview" -> "Executive Summary"
          All bookmarks and navigation links updated.
```

---

### 5.4 Add / Configure Visuals

**What it does:** Adds a chart, table, card, or any of the 32 native Power BI visual types to a page, and configures its properties.

**Who benefits:** Everyone building reports. Instead of clicking through menus, you describe what you want.

**Example 1 — Adding a card visual:**
```
Command:  bdvx desktop visual add \
            --page "Executive Summary" \
            --type "card" \
            --field "[Sales].[Total Revenue]" \
            --title "Total Revenue"
Output:   Visual added: card "Total Revenue" on page "Executive Summary"
          Bound field: [Sales].[Total Revenue]
          Change log entry created.
```

**Example 2 — Adding a clustered bar chart:**
```
Command:  bdvx desktop visual add \
            --page "Regional Breakdown" \
            --type "clusteredBarChart" \
            --axis "dim_region[Region]" \
            --values "[Sales].[Total Revenue]" \
            --title "Revenue by Region"
Output:   Visual added: clusteredBarChart "Revenue by Region"
          Axis: dim_region[Region]
          Values: [Sales].[Total Revenue]
```

---

### 5.5 Bulk Visual Operations

**What it does:** Applies the same change to multiple visuals at once using pattern matching.

**Who benefits:** Advanced users who need to update formatting or properties across many visuals simultaneously.

**Example:**
```
Command:  bdvx desktop visual set \
            --glob "Executive Summary/**/*.Visual" \
            --property "titleFontSize" \
            --value 14
Output:   Bulk update: 7 visuals updated on "Executive Summary"
          Property: titleFontSize -> 14
          Change log: 7 entries created.
```

---

### 5.6 Apply Theme

**What it does:** Applies a Power BI theme (colors, fonts, element defaults) to the entire report, with a diff showing what will change before applying.

**Who benefits:** Everyone. Themes give your report a consistent professional look in one step.

**Example:**
```
Command:  bdvx report-ops theme apply \
            --project C:/projects/sales/report.pbip \
            --theme "corporate-dark.json"
Output:   Theme diff (before -> after):
          - Background: #FFFFFF -> #1A1A2E
          - Primary text: #333333 -> #E0E0E0
          - Accent color: #4472C4 -> #E63946
          - Font family: Segoe UI -> Segoe UI Semibold
          Status: diff generated — run with --apply to write
```

---

### 5.7 Configure Filters

**What it does:** Sets up report-level, page-level, or visual-level filters with a preview of the filter state.

**Who benefits:** Everyone who needs to set default filters on their reports.

**Example:**
```
Command:  bdvx report-ops filters set \
            --scope "page" \
            --page "Executive Summary" \
            --field "dim_date[Year]" \
            --type "categorical" \
            --values "[2025, 2026]"
Output:   Filter configured:
          Scope: page (Executive Summary)
          Field: dim_date[Year]
          Type: categorical
          Values: 2025, 2026
          Before: no filter on this field
          After: 2 values selected
```

---

### 5.8 Set Background / Wallpaper

**What it does:** Applies or replaces the background image on a report page.

**Who benefits:** Anyone using custom backgrounds from bi-designerx or corporate templates.

**Example:**
```
Command:  bdvx report-ops background set \
            --page "Executive Summary" \
            --asset "C:/projects/sales/assets/bg-executive.png"
Output:   Background applied:
          Page: Executive Summary
          Asset: bg-executive.png (1920x1080, 245 KB)
          Previous: none
          Change log entry created.
```

---

### 5.9 Manage Bookmarks

**What it does:** Creates, deletes, reorders, or toggles visibility of report bookmarks — saved states of the report that users can switch between.

**Who benefits:** Anyone building interactive reports with multiple views.

**Example:**
```
Command:  bdvx desktop bookmarks add \
            --name "LATAM View" \
            --capture-filters true \
            --capture-visuals true
Output:   Bookmark created: "LATAM View"
          Captured: current filter state + visual visibility
          Position: 4 of 4
```

---

### 5.10 Visual Formatting

**What it does:** Applies detailed visual-level formatting — borders, shadows, padding, title styles — from a structured specification.

**Who benefits:** Anyone who needs pixel-perfect formatting without clicking through property panels.

**Example:**
```
Command:  bdvx report-ops visuals format \
            --target "Executive Summary/kpi-revenue" \
            --border-radius 8 \
            --shadow "medium" \
            --padding 12
Output:   Visual formatted: kpi-revenue
          Border radius: 8px
          Shadow: medium (2px 2px 4px rgba(0,0,0,0.15))
          Padding: 12px
          Change log entry created.
```

---

## 6. bi-designerx Handoff (Design-to-Report Bridge)

These operations connect the visual design process ([bi-designerx](../bi-designerx/)) with the report implementation (bi-datavizx).

---

### 6.1 Validate Design Pack

**What it does:** Checks that a design pack produced by bi-designerx is complete and well-formed before attempting to apply it. Reports any unmapped pages or visuals.

**Who benefits:** Anyone applying a design to a report. Catches problems before they waste time.

**Example:**
```
Command:  bdvx report-ops handoff validate \
            --pack C:/projects/sales/design-pack/
Output:   Design pack validation: PASS
          Schema version: bidx-pack/1
          Pages mapped: 5/5
          Visuals mapped: 34/34
          Assets referenced: 5 backgrounds, 2 icon sets
          Unmapped targets: 0
          Status: ready for apply
```

---

### 6.2 Preview Design Application

**What it does:** Shows what the design pack would change in the report without actually applying anything.

**Who benefits:** Everyone. A dry run before committing design changes.

**Example:**
```
Command:  bdvx report-ops handoff preview --pack C:/projects/sales/design-pack/
Output:   Preview (dry run):
          Page "Executive Summary":
            - Background: none -> bg-executive.png
            - 7 visuals: font/color/position updates
          Page "Regional Breakdown":
            - Background: none -> bg-regional.png
            - 5 visuals: font/color/position updates
          Total changes: 12 visual updates, 2 background sets
          No destructive changes detected.
```

---

### 6.3 Apply Design Pack to Report

**What it does:** Takes the approved visual design from bi-designerx (backgrounds, layouts, visual placements, style tokens) and applies it to the actual Power BI report. This is the bridge between "how it looks" and "how it works."

**Who benefits:** Everyone. This is the moment the design becomes reality in the report.

**Example:**
```
Command:  bdvx report-ops handoff apply --pack C:/projects/sales/design-pack/
Output:   Design pack applied successfully:
          Pages updated: 5
          Visuals formatted: 34
          Backgrounds set: 5
          Change log: 39 entries created
          Report validated: PASS (structure intact)
```

---

## 7. Fabric / Premium Operations

These operations work with Power BI in the cloud (Microsoft Fabric / Power BI Premium) for quality checks, optimization, and publishing.

---

### 7.1 Scan Workspace

**What it does:** Scans a Fabric/Premium workspace and produces a structural summary of all datasets, reports, and items.

**Who benefits:** Administrators and anyone managing multiple reports in a workspace.

**Example:**
```
Command:  bdvx fabric scan --workspace "Finance Reports"
Output:   Workspace: Finance Reports
          Items: 12
            - Semantic models: 4
            - Reports: 6
            - Dataflows: 2
          Last refresh: 2026-04-12 06:00
```

---

### 7.2 Run Best Practice Analyzer (BPA)

**What it does:** Analyzes your semantic model against Microsoft best practices and returns a list of issues with severity and recommended fixes.

**Who benefits:** Everyone. Even experienced developers miss best practices. BPA catches common issues automatically.

**Example:**
```
Command:  bdvx fabric bpa --workspace "Finance Reports" --dataset "Sales Model"
Output:   BPA results: 3 findings
          [HIGH]   Measure "Old Calc" has no format string — users see raw numbers
          [MEDIUM] Table "staging_temp" is hidden but has no description
          [LOW]    Column "dim_date[DateKey]" should be marked as a date column
          Recommendation: fix HIGH items before publishing
```

---

### 7.3 IBCS Compliance Check

**What it does:** Checks your report against International Business Communication Standards (IBCS) — a global standard for how business charts should be formatted.

**Who benefits:** Companies that follow IBCS notation standards. This is opt-in, not automatic.

**Example:**
```
Command:  bdvx fabric ibcs --workspace "Finance Reports" --report "Monthly KPIs"
Output:   IBCS check: 5 findings
          [FAIL] Bar chart on "Revenue" page uses 3D effect (IBCS requires flat)
          [FAIL] Line chart uses more than 3 colors (IBCS maximum: 3)
          [PASS] Variance charts use correct AC/PY notation
          [PASS] Units are displayed in chart titles
          [WARN] Waterfall chart missing subtotal bar
```

---

### 7.4 Vertipaq Analysis

**What it does:** Analyzes the in-memory storage engine (Vertipaq) to show how much memory each table, column, and relationship consumes.

**Who benefits:** Advanced users optimizing model performance — "why is my model using 2 GB of RAM?"

**Example:**
```
Command:  bdvx fabric vertipaq --workspace "Finance Reports" --dataset "Sales Model"
Output:   Vertipaq analysis:
          Total model size: 245 MB
          Top 5 columns by size:
            1. fact_sales[description]    — 89 MB (high cardinality: 2.1M distinct)
            2. fact_sales[transaction_id] — 45 MB (unique per row)
            3. fact_sales[customer_name]  — 23 MB
            4. dim_product[product_desc]  — 12 MB
            5. fact_sales[date]           — 8 MB
          Recommendation: consider removing [description] or moving to DirectQuery
```

---

### 7.5 Manage Perspectives

**What it does:** Creates or modifies model perspectives that control which subset of tables and measures different user groups see.

**Who benefits:** Organizations with large models where different teams need different views.

**Example:**
```
Command:  bdvx fabric perspective add \
            --name "Sales Team" \
            --tables '["fact_sales", "dim_customer", "dim_product", "dim_date"]' \
            --measures '["Total Revenue", "Units Sold", "Avg Order Value"]'
Output:   Perspective created: Sales Team
          Tables: 4 (of 37 total)
          Measures: 3 (of 618 total)
          Users assigned to this perspective will see a simplified model.
```

---

### 7.6 Publish Report to Fabric

**What it does:** Publishes a local report to a Fabric workspace. This is a destructive action (it changes a shared environment), so it requires your explicit authorization.

**Who benefits:** Anyone who is ready to deploy a report to production.

**Example:**
```
Command:  bdvx desktop publish \
            --project C:/projects/sales/report.pbip \
            --workspace "Finance Reports"

[SAFETY GATE] STOP — Destructive action detected.
  Operation: publish report to Fabric workspace
  Target: Finance Reports / Sales Dashboard
  Impact: replaces the current published version
  Reversibility: previous version can be restored from git
  Awaiting your explicit authorization...

User authorization: "go — publish Sales Dashboard to Finance Reports"

Output:   Published successfully.
          Workspace: Finance Reports
          Report: Sales Dashboard
          Published at: 2026-04-12 14:30
```

---

### 7.7 Download Report from Fabric

**What it does:** Downloads a report from a Fabric workspace to your local machine for offline editing.

**Who benefits:** Anyone who needs to edit a report that currently only exists in the cloud.

**Example:**
```
Command:  bdvx desktop download \
            --workspace "Finance Reports" \
            --report "Sales Dashboard" \
            --destination C:/projects/sales/
Output:   Downloaded: Sales Dashboard
          Destination: C:/projects/sales/Sales Dashboard.Report/
          Files: 42
```

---

## 8. Documentation and Reporting

These operations auto-generate documentation from your project's current state — no manual writing required.

---

### 8.1 Generate Model Dictionary

**What it does:** Creates a human-readable document listing every table, column, measure, and relationship in your model.

**Who benefits:** Teams doing knowledge transfer, compliance reviews, or onboarding new analysts.

**Example:**
```
Command:  bdvx docs dictionary generate --project C:/projects/sales/report.pbip
Output:   Model Dictionary generated:
          File: C:/projects/sales/docs/model-dictionary.md
          Content:
            - 37 tables documented (columns, types, descriptions)
            - 618 measures documented (DAX, format string, dependencies)
            - 42 relationships documented
            - 5 RLS roles documented
```

---

### 8.2 Generate Source Summary

**What it does:** Produces a summary of each data source: origin, health status, last drift check, and credential state.

**Who benefits:** Administrators and anyone maintaining data pipelines.

**Example:**
```
Command:  bdvx docs sources summarize --project C:/projects/sales/report.pbip
Output:   Source Summary generated:
          File: C:/projects/sales/docs/source-summary.md
          Sources:
            1. finance-bq (BigQuery) — healthy, no drift, credential valid
            2. hr-sharepoint (SharePoint) — healthy, 1 low-severity drift, credential valid
            3. static-csv (local file) — healthy, no drift, no credential needed
```

---

### 8.3 Generate Change Report

**What it does:** Creates a report of everything that changed in the current work round.

**Who benefits:** Anyone doing code reviews, audit trails, or stakeholder updates.

**Example:**
```
Command:  bdvx docs changes generate --project C:/projects/sales/report.pbip --round "Sprint 14"
Output:   Change Report — Sprint 14:
          File: C:/projects/sales/docs/change-report-sprint-14.md
          Summary:
            - 3 measures added
            - 1 page renamed
            - 2 visuals reformatted
            - 1 theme applied
            - 1 design pack applied (bi-designerx handoff)
          Total changes: 8
```

---

### 8.4 Export Model Diagram (SVG)

**What it does:** Exports a visual diagram of your data model showing tables, relationships, and cardinality.

**Who benefits:** Anyone who needs a visual representation of the model for documentation, reviews, or presentations.

**Example:**
```
Command:  bdvx docs diagram export --project C:/projects/sales/report.pbip
Output:   Diagram exported:
          File: C:/projects/sales/docs/model-diagram.svg
          Tables: 37 (positioned using force-directed layout)
          Relationships: 42 (with cardinality labels)
          Format: SVG (scalable, embeddable in Markdown/HTML)
```

---

### 8.5 Export Architecture (JSON)

**What it does:** Produces a machine-readable JSON export of the project architecture for integration with other tools.

**Who benefits:** DevOps teams, compliance reviewers, or anyone building automated pipelines on top of Power BI projects.

**Example:**
```
Command:  bdvx docs architecture export --project C:/projects/sales/report.pbip
Output:   Architecture export:
          File: C:/projects/sales/docs/architecture-export.json
          Content: tables, measures, relationships, pages, visuals,
                   data sources, refresh policies, RLS roles, perspectives
```

---

## 9. Governance and Safety

These operations protect your work from accidental damage and ensure full traceability of every change.

---

### 9.1 Destructive Action Gate

**What it does:** Automatically blocks any operation that deletes, removes, or overwrites something. Nothing is destroyed without your explicit written authorization for that specific item.

**Who benefits:** Everyone. This is the primary safety net for all Power BI work.

**How it works:**
```
1. You (or the AI agent) requests a delete operation
2. The skill STOPS and shows you:
   - Exactly what will be deleted
   - What will break as a result
   - Whether it can be undone
   - How many items are affected
3. You write "go — delete [specific item]"
4. Only then does the skill execute
5. The result is confirmed
6. The next delete requires a NEW authorization
```

---

### 9.2 Scan-First Default

**What it does:** Every write operation shows you a preview/diff of what will change before applying.

**Who benefits:** Everyone. No surprises.

**Example:**
```
Any write command first outputs:
  Diff (before -> after):
    - [current state]
    + [proposed state]
  Status: diff generated — run with --apply to write
```

---

### 9.3 Audit Log

**What it does:** Every command is logged in an append-only audit trail with timestamps, who ran it, what changed, and whether it was destructive.

**Who benefits:** Compliance teams, managers reviewing changes, and anyone doing post-incident analysis.

**Example entry:**
```json
{
  "ts": "2026-04-12T11:30:00-03:00",
  "agent": "claude-code",
  "command": "desktop.measure.add",
  "args_digest": "sha256:a1b2c3...",
  "result": "ok",
  "irreversible": false,
  "approved_by": null
}
```

---

### 9.4 Regression Test Pack

**What it does:** A built-in test suite that detects if a model or report change violates design rules.

**Who benefits:** Teams that want automated quality gates before publishing.

**Example:**
```
Command:  bdvx governance regression-test --project C:/projects/sales/report.pbip
Output:   Regression tests: 45 PASS, 1 FAIL
          FAIL: Measure [Sales].[Total Revenue] lost its format string
                after the last model update. Expected: "#,##0". Found: none.
```

---

## 10. Integration

These operations connect bi-datavizx to the broader governance infrastructure.

---

### 10.1 Create a Finding

**What it does:** When the skill discovers a bug, gap, or drift, it registers a finding ticket in the findings index.

**Example:**
```
Command:  bdvx finding new --title "Measure format string missing after import" --severity "medium"
Output:   Finding created: FND-0085
          Title: Measure format string missing after import
          Severity: medium
          Index updated: findings-master-index.md
```

---

### 10.2 Dispatch a Review

**What it does:** Sends a document to another AI agent for independent review via the AOP (Agent Orchestration Protocol).

**Example:**
```
Command:  bdvx integration aop-dispatch \
            --target "bdvx-sdd-v1.0.md" \
            --reviewer "codex" \
            --effort "medium"
Output:   Review dispatched.
          Task: bdvx-sdd-review
          Reviewer: Codex
          Effort: medium
          Expected return: ~10 minutes
```

---

### 10.3 Render TB-01 Verdict

**What it does:** When there is a disagreement between options, produces a structured verdict using the TB-01 principle: "the winner is the one that brings more real value without harming any existing part."

**Example:**
```
Command:  bdvx integration tb-01 \
            --issue "Should we use TMDL or BIM as the model source?" \
            --option-a "TMDL (modern, git-friendly)" \
            --option-b "BIM (legacy, single file)" \
            --verdict "A"
Output:   TB-01 Verdict:
          Issue: Model source format
          Winner: Option A (TMDL)
          Rationale: TMDL brings more real value (git diffability,
                     granular versioning) without harming any existing
                     feature. BIM is legacy and loses data granularity.
```

---

## 11. Migration and Setup

---

### 11.1 Migrate from pbi-claude-skills (Legacy — Superseded)

> **Note:** `pbi-claude-skills` has been removed from the Hub and fully superseded by bi-datavizx v1.1.0. This migration path exists for projects still referencing the old skill.

**What it does:** Analyzes a project using the older pbi-claude-skills, groups migration items by safety tier, and guides you through the transition.

**Example:**
```
Command:  bdvx migrate-from pbi-claude-skills --project C:/projects/sales/
Output:   Migration analysis:
          Safe (auto-apply): 12 items
            - Config format upgrade (pbi_config.json -> bdvx_config.json)
            - Index format upgrade (POWER_BI_INDEX.md v1 -> v2)
            - ... (10 more)
          Review required: 3 items
            - Custom validators (need manual review)
            - Hard-coded paths (need path update)
            - ... (1 more)
          Manual: 1 item
            - Custom hooks (not portable, rebuild recommended)

          Auto-applying 12 safe items... Done.
          Review the remaining 4 items and confirm each one.
```

---

### 11.2 Check Version

**What it does:** Reports the current version of bi-datavizx and both backend engines, verifying they match the expected locked versions.

**Example:**
```
Command:  bdvx core version
Output:   bi-datavizx: 1.1.0 (commit abc1234)
          pbi-cli: v3.10.10 (commit 6642cf1) — MATCH (locked)
          pbir-cli: v0.9.7 — MATCH (locked)
          Python: 3.11.9
          pywin32: 306
          semantic-link-labs: 0.14.2
          All versions verified.
```

---

## Quick Reference

| Category | Operations | Key Benefit |
|---|---|---|
| Project Discovery | 5 | Find projects and build a structural index that saves 50-97% of AI tokens |
| Credential Management | 6 | Securely store and manage secrets in Windows Credential Manager |
| Data Ingestion | 10 | Import from BigQuery and SharePoint with zero manual steps |
| Semantic Model | 16 | Full model CRUD: tables, measures, DAX, relationships, TMDL, RLS |
| DAX Standards | 2 | Format and lint DAX with 10 rules (DAX001-DAX010) |
| Report Operations | 10 | Pages, visuals, themes, filters, backgrounds, bookmarks, formatting |
| bi-designerx Handoff | 3 | Validate, preview, and apply design packs from bi-designerx |
| Fabric / Premium | 7 | Workspace scanning, BPA, IBCS, Vertipaq, perspectives, publish |
| Documentation | 5 | Auto-generate model dictionaries, source summaries, diagrams |
| Governance | 4 | Destructive-action gates, scan-first defaults, audit log, regression tests |
| Integration | 3 | Findings tracking, review dispatch, arbitration verdicts |
| Migration / Setup | 3 | Legacy migration, version check, cross-machine sync |

**Total: ~70 operations across 11 categories**

---

*bi-datavizx v1.1.0 | Published in [Claude Intelligence Hub](../)*
