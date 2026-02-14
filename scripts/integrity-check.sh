#!/bin/bash

# Claude Intelligence Hub - Integrity Check Tool
# Validates hub consistency: orphaned files, ghost skills, version drift

echo "🔍 HUB INTEGRITY CHECK"
echo "Running: $(date '+%Y-%m-%d %H:%M')"
echo ""

# Initialize counters
total_checks=5
passed=0
failed=0

# Navigate to hub root
cd "$(dirname "$0")/.." || exit 1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ═══════════════════════════════════════
# CHECK 1: Orphaned Directories
# ═══════════════════════════════════════
echo "═══════════════════════════════════════"
echo "CHECK 1: Orphaned Directories"
echo "═══════════════════════════════════════"

orphans_found=0
for dir in */; do
    # Skip hidden and special directories
    if [[ "$dir" == "." || "$dir" == ".git/" || "$dir" == ".claude/" || "$dir" == "scripts/" ]]; then
        continue
    fi

    skill_name=$(basename "$dir" /)

    # Check if skill exists in HUB_MAP
    if ! grep -q "^### [0-9]*\. $skill_name$" HUB_MAP.md 2>/dev/null; then
        echo -e "${RED}❌ ORPHAN: $skill_name (directory exists but not in HUB_MAP)${NC}"
        orphans_found=1
    fi
done

if [ $orphans_found -eq 0 ]; then
    echo -e "${GREEN}✅ All directories documented in HUB_MAP${NC}"
    ((passed++))
else
    echo -e "${RED}Fix: Add skill to HUB_MAP or delete directory${NC}"
    ((failed++))
fi
echo ""

# ═══════════════════════════════════════
# CHECK 2: Ghost Skills
# ═══════════════════════════════════════
echo "═══════════════════════════════════════"
echo "CHECK 2: Ghost Skills"
echo "═══════════════════════════════════════"

ghosts_found=0
if [ -f "HUB_MAP.md" ]; then
    while IFS= read -r line; do
        # Extract skill name from "### N. skill-name"
        skill=$(echo "$line" | sed 's/^### [0-9]*\. //')

        if [ ! -d "$skill" ]; then
            echo -e "${RED}👻 GHOST: $skill (in HUB_MAP but no directory)${NC}"
            ghosts_found=1
        fi
    done < <(grep "^### [0-9]*\." HUB_MAP.md)
fi

if [ $ghosts_found -eq 0 ]; then
    echo -e "${GREEN}✅ All HUB_MAP skills have directories${NC}"
    ((passed++))
else
    echo -e "${RED}Fix: Remove from HUB_MAP or create directory${NC}"
    ((failed++))
fi
echo ""

# ═══════════════════════════════════════
# CHECK 3: Loose Root Files
# ═══════════════════════════════════════
echo "═══════════════════════════════════════"
echo "CHECK 3: Loose Root Files"
echo "═══════════════════════════════════════"

# Approved files in root
approved_files=(
    "CHANGELOG.md"
    "EXECUTIVE_SUMMARY.md"
    "HUB_MAP.md"
    "README.md"
    "LICENSE"
    "WINDOWS_JUNCTION_SETUP.md"
    ".gitignore"
)

loose_found=0
for file in *.md *.txt LICENSE .gitignore; do
    if [ -f "$file" ]; then
        # Check if file is in approved list
        is_approved=0
        for approved in "${approved_files[@]}"; do
            if [ "$file" == "$approved" ]; then
                is_approved=1
                break
            fi
        done

        if [ $is_approved -eq 0 ]; then
            echo -e "${YELLOW}🗑️ CLUTTER: $file (unauthorized root file)${NC}"
            loose_found=1
        fi
    fi
done

if [ $loose_found -eq 0 ]; then
    echo -e "${GREEN}✅ No unauthorized files in root${NC}"
    ((passed++))
else
    echo -e "${YELLOW}Fix: Move to skill directory or delete${NC}"
    ((failed++))
fi
echo ""

# ═══════════════════════════════════════
# CHECK 4: Version Consistency
# ═══════════════════════════════════════
echo "═══════════════════════════════════════"
echo "CHECK 4: Version Consistency"
echo "═══════════════════════════════════════"

drift_found=0
for skill_dir in */; do
    # Skip non-skill directories
    if [[ "$skill_dir" == "." || "$skill_dir" == ".git/" || "$skill_dir" == ".claude/" || "$skill_dir" == "scripts/" ]]; then
        continue
    fi

    metadata_file="${skill_dir}.metadata"
    if [ -f "$metadata_file" ]; then
        # Extract version from .metadata (assuming JSON format)
        skill_version=$(grep '"version"' "$metadata_file" | sed 's/.*"version": *"\([^"]*\)".*/\1/')
        skill_name=$(basename "$skill_dir" /)

        # Check if EXECUTIVE_SUMMARY mentions this version
        if [ -f "EXECUTIVE_SUMMARY.md" ]; then
            if ! grep -q "$skill_name.*$skill_version" EXECUTIVE_SUMMARY.md; then
                echo -e "${YELLOW}📊 VERSION DRIFT: $skill_name is v$skill_version but EXECUTIVE_SUMMARY may be outdated${NC}"
                drift_found=1
            fi
        fi
    fi
done

if [ $drift_found -eq 0 ]; then
    echo -e "${GREEN}✅ Versions consistent across .metadata and EXECUTIVE_SUMMARY${NC}"
    ((passed++))
else
    echo -e "${YELLOW}Fix: Update EXECUTIVE_SUMMARY.md with current versions${NC}"
    ((failed++))
fi
echo ""

# ═══════════════════════════════════════
# CHECK 5: SKILL.md Existence
# ═══════════════════════════════════════
echo "═══════════════════════════════════════"
echo "CHECK 5: SKILL.md Existence"
echo "═══════════════════════════════════════"

missing_skill_md=0
for skill_dir in */; do
    # Skip non-skill directories
    if [[ "$skill_dir" == "." || "$skill_dir" == ".git/" || "$skill_dir" == ".claude/" || "$skill_dir" == "scripts/" ]]; then
        continue
    fi

    skill_md="${skill_dir}SKILL.md"
    if [ ! -f "$skill_md" ]; then
        skill_name=$(basename "$skill_dir" /)
        echo -e "${RED}📄 MISSING: $skill_name lacks SKILL.md (Zero Tolerance violation)${NC}"
        missing_skill_md=1
    fi
done

if [ $missing_skill_md -eq 0 ]; then
    echo -e "${GREEN}✅ All skills have SKILL.md${NC}"
    ((passed++))
else
    echo -e "${RED}Fix: Create SKILL.md or remove skill${NC}"
    ((failed++))
fi
echo ""

# ═══════════════════════════════════════
# CHECK 6: Version Synchronization
# ═══════════════════════════════════════
echo "═══════════════════════════════════════"
echo "CHECK 6: Version Synchronization"
echo "═══════════════════════════════════════"

sync_issues=0
for skill_dir in */; do
    # Skip non-skill directories
    if [[ "$skill_dir" == ".git/" ]] || [[ "$skill_dir" == "scripts/" ]] || [[ "$skill_dir" == "token-economy/" ]] || [[ "$skill_dir" == ".claude/" ]]; then
        continue
    fi

    skill_name=$(basename "$skill_dir" /)
    metadata_file="${skill_dir}.metadata"
    skill_md="${skill_dir}SKILL.md"

    if [ -f "$metadata_file" ] && [ -f "$skill_md" ]; then
        # Extract versions
        metadata_ver=$(grep '"version"' "$metadata_file" | sed 's/.*"version": *"\([^"]*\)".*/\1/')
        skillmd_ver=$(grep '^\*\*Version:\*\*' "$skill_md" | head -1 | sed 's/.*Version:\*\* *\([0-9.]*\).*/\1/')
        hubmap_line=$(grep "$skill_name.*v[0-9]" HUB_MAP.md 2>/dev/null | head -1)

        if [ -n "$hubmap_line" ]; then
            hubmap_ver=$(echo "$hubmap_line" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/^v//')
        else
            hubmap_ver="NOT_FOUND"
        fi

        # Compare versions
        if [ "$metadata_ver" != "$skillmd_ver" ] || ([ "$hubmap_ver" != "NOT_FOUND" ] && [ "$metadata_ver" != "$hubmap_ver" ]); then
            echo -e "${RED}❌ VERSION DRIFT: $skill_name${NC}"
            echo "   .metadata: v$metadata_ver"
            echo "   SKILL.md:  v$skillmd_ver"
            if [ "$hubmap_ver" != "NOT_FOUND" ]; then
                echo "   HUB_MAP:   v$hubmap_ver"
            fi
            sync_issues=1
        fi
    fi
done

if [ $sync_issues -eq 0 ]; then
    echo -e "${GREEN}✅ All versions synchronized across .metadata, SKILL.md, HUB_MAP.md${NC}"
    ((passed++))
else
    echo -e "${RED}❌ Fix: Run sync-versions.sh <skill-name>${NC}"
    ((failed++))
fi
echo ""

# Update total checks count
total_checks=6

# ═══════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════
echo "═══════════════════════════════════════"
echo "SUMMARY"
echo "═══════════════════════════════════════"
echo "Total Checks: $total_checks"
echo -e "${GREEN}✅ Passed: $passed${NC}"
if [ $failed -gt 0 ]; then
    echo -e "${RED}❌ Failed: $failed${NC}"
else
    echo "❌ Failed: 0"
fi
echo ""

if [ $failed -gt 0 ]; then
    echo -e "${YELLOW}Action Required: Fix issues above${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Hub integrity verified - all checks passed${NC}"
    exit 0
fi
