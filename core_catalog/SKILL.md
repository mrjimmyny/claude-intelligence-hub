---
name: core_catalog
version: 1.0.0
description: Centralized catalog of core system configurations and bootstrap data
command: /catalog
aliases: [/core]
---

# Core Catalog (Infrastructure Data)

**Version:** 1.0.0
**Purpose:** Centralized catalog of core system configurations and bootstrap data
**Category:** Infrastructure / Data
**Status:** Production

---

## 🎯 Overview

The **Core Catalog** serves as the foundational data layer for the Claude Intelligence Hub. It provides structured configuration and mapping data required for system initialization, bootstrap compatibility, and service coordination.

---

## 🏛️ Key Features

1. **Bootstrap Compatibility:** Mapping data for different environment configurations.
2. **Core Service Mapping:** Centralized registry of system-wide service identifiers.
3. **Initialization Data:** Static data structures used during the hub setup and deployment.

---

## 📂 Catalog Components

- `bootstrap_compat.json`: Environment-specific compatibility flags.
- `core_catalog.json`: Master service and resource registry.

---

## ⚠️ Usage Guidelines

This directory contains **internal system data**. 
- **DO NOT** modify these files manually unless performing system-wide configuration updates.
- All changes must be validated against the `setup_local_env` scripts.

---

**Version History:**
- **v1.0.0** - Initial structural data catalog.
