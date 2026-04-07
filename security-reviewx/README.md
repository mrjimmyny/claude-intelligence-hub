# security-reviewx

> **Version:** 1.0.0 | **Status:** Production | **Type:** Global, Cross-Agent, Cross-Machine

Deterministic, modular security scanning skill. Detects exposed secrets, sensitive data, credentials, and security vulnerabilities in repositories before publication to GitHub.

## Quick Start

```
/security-reviewx                    # STANDARD scan on current repo
/security-reviewx --mode quick       # QUICK scan (M1-M4 only)
/security-reviewx --mode deep        # DEEP scan (all 7 modules + git history)
/security-reviewx --target {path}    # Scan specific directory
```

## Modules

| Module | Code | Scope |
|--------|------|-------|
| SECRET_SCAN | M1 | API keys, tokens, passwords, private keys, connection strings |
| PII_SCAN | M2 | Emails, phones, CPF, CNPJ, SSN, credit cards, IPs |
| FILE_SCAN | M3 | Dangerous files (.env, .pem), .gitignore completeness |
| PATH_SCAN | M4 | Hardcoded Windows/Unix/Mac paths, hostnames, IPs |
| CONFIG_SCAN | M5 | SSL bypass, debug flags, default creds, CORS, HTTP |
| CODE_SCAN | M6 | Injection, eval, XSS, SQL injection, weak crypto |
| GIT_HISTORY_SCAN | M7 | Deleted secrets in git history (DEEP mode only) |

## Scan Modes

| Mode | Modules | Use Case |
|------|---------|----------|
| QUICK | M1-M4 | Fast pre-push check |
| STANDARD | M1-M6 | Regular security review |
| DEEP | M1-M7 | Full audit with git history |

## Pattern Library

76 enabled patterns across 7 JSON files in `patterns/`. Extensible via `patterns/custom.json`.

## Severity Model

| Level | Impact | Action |
|-------|--------|--------|
| CRITICAL | Exposed credentials, secrets | Immediate rotation required |
| HIGH | PII, SSL bypass, injection | Must fix before publication |
| MEDIUM | Hardcoded paths, debug flags | Must fix (blocks publication) |
| LOW | Backup files, OS artifacts | Mandatory cleanup |

**Verdict:** Any unallowlisted finding at ANY severity = FAIL.

## Principle

**Detect and report. NEVER auto-fix without explicit human authorization.**

## Documentation

Full protocol: see `SKILL.md`

## Tested

- 3 agents: Magneto (Claude Opus 4.6), Codex (GPT-5.4), Magneto-M2 (Claude Opus 4.6)
- 2 machines: BR-SPO-DCFC264, win112022
- Seed repo: 33-35 findings across M1-M6
- False positive repo: 0 findings, 13/13 correctly filtered
- Performance: 15s scan on 361 files
