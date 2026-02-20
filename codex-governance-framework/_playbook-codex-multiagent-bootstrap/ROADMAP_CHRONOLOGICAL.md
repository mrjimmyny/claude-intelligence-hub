# Roadmap Chronological

## Timeline Overview

This roadmap follows the actual architecture evolution from Phase 0 to Phase 5.

### Phase 0: Skill Contract Standardization

- Standardized skill file format and loading behavior.
- Objective: remove ambiguous skill parsing behavior.

### Route A: Institutional Centralization

- Centralized core authority in HUB.
- Objective: remove fragmented adapter-level authority.

### Phase 1: Canonical Catalog Authority

- Introduced `core_catalog.json` authority pattern.
- Objective: remove hardcoded bootstrap mappings.

### Phase 2: Deterministic Sync

- Added `sync` mode with drift classification and reconciliation.
- Objective: force convergence to canonical state.

### Phase 3: Read-Only Audit

- Added `audit` mode and explicit drift contract codes.
- Objective: detect drift without mutation.

### Phase 4: Automated Onboarding

- Added deterministic `onboard` orchestration.
- Objective: transform drifted machines to compliant state safely.

### Phase 5: Version Discipline and Release Governance

- Added release governance baseline `v1.0.0`.
- Added compatibility contract file and explicit out-of-range abort.
- Added deterministic artifact packaging and hash verification.

## Current Position

- Local governance baseline is institutionalized.
- Remote governance is intentionally deferred to a future controlled phase.
