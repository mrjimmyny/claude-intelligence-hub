#!/usr/bin/env bash
# README Validation Script - Prevents Documentation Drift
# Created: 2026-02-15
# Purpose: Catch common README drift patterns before releases

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Validating README.md consistency..."
echo ""

ERRORS=0
WARNINGS=0

# Change to repository root
cd "$(dirname "$0")/.."

# ============================================================================
# Check 1: Production Skills Count
# ============================================================================

echo -n "📦 Checking production skills count... "

# Count actual skill folders (exclude non-skill directories and governance tools)
ACTUAL_SKILLS=$(find . -maxdepth 1 -type d \
    ! -name '.' \
    ! -name '..' \
    ! -name '.git' \
    ! -name '.github' \
    ! -name '.claude' \
    ! -name 'docs' \
    ! -name 'scripts' \
    ! -name 'node_modules' \
    ! -name 'token-economy' \
    | grep -E '\./[a-z]+-' \
    | wc -l)

# Extract count from README "Production Skills** | 8 collections"
README_SKILLS=$(grep "Production Skills" README.md | grep -oE '[0-9]+ collections' | grep -oE '[0-9]+' | head -1 || echo "0")

if [[ "$ACTUAL_SKILLS" -eq "$README_SKILLS" ]]; then
    echo -e "${GREEN}✓${NC} $ACTUAL_SKILLS skills (matches actual folders)"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}ERROR: Production skills count mismatch${NC}"
    echo "   Actual skill folders: $ACTUAL_SKILLS"
    echo "   README claims: $README_SKILLS"
    echo "   Fix: Update README.md line ~500 (Current Statistics table)"
    ERRORS=$((ERRORS + 1))
fi

# ============================================================================
# Check 2: Skills by Status Section
# ============================================================================

echo -n "📊 Checking Skills by Status section... "

# Extract skills list from "Production Ready: 8 (...)" line
SKILLS_COUNT=$(grep "Production Ready:" README.md | grep -oE '[0-9]+' | head -1 || echo "0")

if [[ "$ACTUAL_SKILLS" -eq "$SKILLS_COUNT" ]]; then
    echo -e "${GREEN}✓${NC} $SKILLS_COUNT skills listed"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}ERROR: Skills by Status count mismatch${NC}"
    echo "   Actual skill folders: $ACTUAL_SKILLS"
    echo "   Skills by Status section claims: $SKILLS_COUNT"
    echo "   Fix: Update README.md line ~513 (Skills by Status)"
    ERRORS=$((ERRORS + 1))
fi

# ============================================================================
# Check 3: Version Consistency (README vs CHANGELOG)
# ============================================================================

echo -n "🏷️  Checking version consistency... "

# Extract version from README "Current Version: vX.X.X"
README_VERSION=$(grep "Current Version:" README.md | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

# Extract latest version from CHANGELOG "## [X.X.X]"
CHANGELOG_VERSION=$(grep '## \[' CHANGELOG.md | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

if [[ "$README_VERSION" == "$CHANGELOG_VERSION" ]]; then
    echo -e "${GREEN}✓${NC} v$README_VERSION (README = CHANGELOG)"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}ERROR: Version mismatch${NC}"
    echo "   README: v$README_VERSION"
    echo "   CHANGELOG: v$CHANGELOG_VERSION"
    echo "   Fix: Update README.md line ~710 (Current Version section)"
    ERRORS=$((ERRORS + 1))
fi

# ============================================================================
# Check 4: Version Badge
# ============================================================================

echo -n "🔖 Checking version badge... "

BADGE_VERSION=$(grep 'badge/version-' README.md | grep -oE 'version-[0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

if [[ "$BADGE_VERSION" == "$README_VERSION" ]]; then
    echo -e "${GREEN}✓${NC} v$BADGE_VERSION"
else
    echo -e "${YELLOW}⚠${NC}"
    echo -e "${YELLOW}WARNING: Version badge outdated${NC}"
    echo "   Badge: v$BADGE_VERSION"
    echo "   Current: v$README_VERSION"
    echo "   Fix: Update README.md line ~7 (version badge)"
    WARNINGS=$((WARNINGS + 1))
fi

# ============================================================================
# Check 5: Architecture Section vs Actual Folders
# ============================================================================

echo -n "🏗️  Checking architecture section... "

MISSING_DOCS=()
for skill_dir in */; do
    # Skip non-skill directories and governance tools
    if [[ "$skill_dir" == "node_modules/" ]] || \
       [[ "$skill_dir" == "scripts/" ]] || \
       [[ "$skill_dir" == "docs/" ]] || \
       [[ "$skill_dir" == ".git/" ]] || \
       [[ "$skill_dir" == ".github/" ]] || \
       [[ "$skill_dir" == ".claude/" ]] || \
       [[ "$skill_dir" == "token-economy/" ]]; then
        continue
    fi

    # Check if folder is documented in Architecture section (with or without emoji)
    DIR_NAME="${skill_dir%/}"
    if ! grep -q "$DIR_NAME/" README.md; then
        MISSING_DOCS+=("$DIR_NAME")
    fi
done

if [[ ${#MISSING_DOCS[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} All skill folders documented"
else
    echo -e "${YELLOW}⚠${NC}"
    echo -e "${YELLOW}WARNING: Folders not documented in Architecture section:${NC}"
    for folder in "${MISSING_DOCS[@]}"; do
        echo "   - $folder/"
    done
    echo "   Fix: Add missing folders to README.md line ~285-367 (Architecture section)"
    WARNINGS=$((WARNINGS + 1))
fi

# ============================================================================
# Check 6: HUB_MAP.md Version Reference
# ============================================================================

echo -n "🗺️  Checking HUB_MAP.md version reference... "

# Get HUB_MAP.md reference from Architecture section (the line with "Skill routing dictionary")
HUBMAP_REF=$(grep 'Skill routing dictionary' README.md | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

# Get actual HUB_MAP.md version (format: **Version:** X.X.X)
if [[ -f "HUB_MAP.md" ]]; then
    HUBMAP_ACTUAL=$(grep '\*\*Version:\*\*' HUB_MAP.md | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")

    if [[ "$HUBMAP_REF" == "$HUBMAP_ACTUAL" ]]; then
        echo -e "${GREEN}✓${NC} v$HUBMAP_REF"
    else
        echo -e "${YELLOW}⚠${NC}"
        echo -e "${YELLOW}WARNING: HUB_MAP.md version reference mismatch${NC}"
        echo "   README references: v$HUBMAP_REF"
        echo "   HUB_MAP.md actual: v$HUBMAP_ACTUAL"
        echo "   Fix: Update README.md line ~352"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠${NC} HUB_MAP.md not found"
    WARNINGS=$((WARNINGS + 1))
fi

# ============================================================================
# Check 7: Major Milestones Section
# ============================================================================

echo -n "📅 Checking Major Milestones section... "

# Check if current version is in Major Milestones (search 20 lines after header)
if grep -A 20 "Major Milestones" README.md | grep -q "v$README_VERSION"; then
    echo -e "${GREEN}✓${NC} v$README_VERSION listed"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}ERROR: Current version not in Major Milestones${NC}"
    echo "   Current version: v$README_VERSION"
    echo "   Fix: Add milestone entry to README.md line ~726"
    ERRORS=$((ERRORS + 1))
fi

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "================================================================"

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}✅ README.md validation passed!${NC}"
    echo "   All consistency checks passed"
    echo "   Safe to proceed with release"
    echo "================================================================"
    exit 0
elif [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  README.md validation passed with warnings${NC}"
    echo "   Errors: $ERRORS"
    echo "   Warnings: $WARNINGS"
    echo ""
    echo "   Warnings are non-critical but should be fixed"
    echo "   Safe to proceed with release (recommended to fix warnings)"
    echo "================================================================"
    exit 0
else
    echo -e "${RED}❌ README.md validation FAILED${NC}"
    echo "   Errors: $ERRORS (MUST fix before release)"
    echo "   Warnings: $WARNINGS (recommended to fix)"
    echo ""
    echo "   Fix all errors listed above before proceeding"
    echo "   Run this script again after fixes"
    echo "================================================================"
    exit 1
fi
