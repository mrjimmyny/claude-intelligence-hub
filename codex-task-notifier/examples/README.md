# Email Templates — Reference Examples

Ready-to-use HTML email templates for agents sending emails via `gws gmail +send --html`.

## Templates

| # | Template | Use When |
|---|----------|----------|
| 1 | `01-executive-summary.html` | Session summary, findings, deliverables |
| 2 | `02-table-report.html` | Structured data with clean table headers/columns |
| 3 | `03-status-update.html` | Quick bullet-point status update |
| 4 | `04-project-portfolio.html` | Multi-project overview with priorities |
| 5 | `05-finding-alert.html` | Critical finding notification |

## Usage

```bash
# Read the template, replace placeholders, send via gws CLI
gws gmail +send \
  --to mrjimmyny@gmail.com \
  --subject "Your Subject" \
  --body "<paste-html-here>" \
  --html
```

**CRITICAL:** Always include `--html` flag. Without it, HTML renders as raw text.

## Design Principles

- **Font:** Segoe UI / Arial / sans-serif
- **Max width:** 680px centered
- **Accent color:** #e63946 (red) for headers/dividers
- **Header color:** #1a1a2e (dark navy)
- **Table borders:** #dee2e6 (light gray)
- **Alternating rows:** #f8f9fa (very light gray)
- **Status colors:** #d4edda (green/success), #fff3cd (yellow/warning), #f8d7da (red/danger)
- **Footer:** 12px, #888 gray, session info
