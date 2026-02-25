# 🗃️ Core Catalog (v1.0.0)

Centralized catalog of core system configurations and bootstrap data for the Claude Intelligence Hub.

---

## 🎯 Purpose

The **Core Catalog** is a system-level component that stores static configuration data, compatibility mappings, and initialization parameters used by the Hub's deployment and orchestration tools.

---

## 🏛️ Components

| File | Purpose |
|------|---------|
| `bootstrap_compat.json` | Environment-specific bootstrap compatibility flags |
| `core_catalog.json` | Master registry of core system services and data structures |

---

## 🚀 Usage

This is an **infrastructure-only** component. It does not have manual triggers or interactive workflows. It is consumed by:
- `scripts/setup_local_env.ps1`
- `scripts/setup_local_env.sh`
- Agent Orchestration Protocol (AOP) initialization

---

## 🛠️ Maintenance

Changes to the Core Catalog should only be made when:
1. Adding a new core system service.
2. Updating environment bootstrap requirements.
3. Modifying global configuration defaults.

**Note:** Always run `scripts/integrity-check.sh` after any modification to ensure synchronization.

---

**Version:** 1.0.0
**Status:** ✅ Production
**Last Updated:** 2026-02-25
