#!/bin/bash
# Context Guardian - Backup Health Check Script
# Verifies backup integrity and health status

# Source logging library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging-lib.sh"

# Configuration
RCLONE_REMOTE="gdrive-jimmy"
GDRIVE_FOLDER="Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory"
CLAUDE_DIR="$HOME/.claude"

# Parse arguments
LOCAL_ONLY=false

for arg in "$@"; do
    case $arg in
        --local-only)
            LOCAL_ONLY=true
            ;;
    esac
done

# ==============================================================================
# Health Check Banner
# ==============================================================================

log_banner "Context Guardian - Backup Health Check"

# Color codes for status
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CHECKS_PASSED=0
CHECKS_WARNING=0
CHECKS_FAILED=0

# ==============================================================================
# Check 1: Google Drive Connectivity
# ==============================================================================

echo -n "Check 1: Google Drive Connectivity... "

if [ "$LOCAL_ONLY" = true ]; then
    echo -e "${YELLOW}SKIPPED${NC} (--local-only mode)"
    log_info "Check 1: SKIPPED (local-only mode)"
else
    if rclone lsd "${RCLONE_REMOTE}:${GDRIVE_FOLDER}" &> /dev/null; then
        echo -e "${GREEN}✅ CONNECTED${NC}"
        log_success "Check 1: Google Drive connected"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo -e "${RED}❌ FAILED${NC}"
        log_error "Check 1: Cannot connect to Google Drive"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
fi

# ==============================================================================
# Check 2: Metadata Integrity
# ==============================================================================

echo -n "Check 2: Metadata Integrity... "

TEMP_DIR="/tmp/context-guardian-verify-$$"
mkdir -p "$TEMP_DIR"

if [ "$LOCAL_ONLY" = false ]; then
    rclone copy "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/LATEST_GLOBAL.json" "$TEMP_DIR/" 2>/dev/null
fi

if [ -f "$TEMP_DIR/LATEST_GLOBAL.json" ] || [ -f "$CLAUDE_DIR/context-guardian/LATEST_GLOBAL.json" ]; then
    # Try remote first, fall back to local
    METADATA_FILE="$TEMP_DIR/LATEST_GLOBAL.json"
    [ ! -f "$METADATA_FILE" ] && METADATA_FILE="$CLAUDE_DIR/context-guardian/LATEST_GLOBAL.json"

    if jq empty "$METADATA_FILE" 2>/dev/null; then
        echo -e "${GREEN}✅ VALID JSON${NC}"
        log_success "Check 2: Metadata is valid JSON"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo -e "${RED}❌ CORRUPTED${NC}"
        log_error "Check 2: Metadata JSON is invalid"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
else
    echo -e "${RED}❌ NOT FOUND${NC}"
    log_error "Check 2: Metadata file not found"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# ==============================================================================
# Check 3: Backup Age
# ==============================================================================

echo -n "Check 3: Backup Age... "

if [ -f "$METADATA_FILE" ]; then
    LAST_BACKUP=$(jq -r '.last_backup' "$METADATA_FILE")
    LAST_BACKUP_EPOCH=$(date -d "$LAST_BACKUP" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_BACKUP" +%s 2>/dev/null)
    NOW_EPOCH=$(date +%s)
    DIFF_SECONDS=$((NOW_EPOCH - LAST_BACKUP_EPOCH))
    DIFF_DAYS=$((DIFF_SECONDS / 86400))

    if [ $DIFF_DAYS -lt 7 ]; then
        echo -e "${GREEN}✅ FRESH${NC} (backed up $DIFF_DAYS days ago)"
        log_success "Check 3: Backup is fresh ($DIFF_DAYS days old)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo -e "${YELLOW}⚠️  STALE${NC} (backed up $DIFF_DAYS days ago)"
        log_warn "Check 3: Backup is stale ($DIFF_DAYS days old)"
        CHECKS_WARNING=$((CHECKS_WARNING + 1))
    fi
else
    echo -e "${RED}❌ UNKNOWN${NC} (no metadata)"
    log_error "Check 3: Cannot determine backup age"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# ==============================================================================
# Check 4: Checksum Verification
# ==============================================================================

echo -n "Check 4: Checksum Verification... "

if [ -f "$METADATA_FILE" ] && [ -f "$CLAUDE_DIR/settings.json" ]; then
    EXPECTED_SHA=$(jq -r '.files.settings_json.sha256' "$METADATA_FILE")
    ACTUAL_SHA=$(sha256sum "$CLAUDE_DIR/settings.json" | cut -d' ' -f1)

    if [ "$EXPECTED_SHA" = "$ACTUAL_SHA" ]; then
        echo -e "${GREEN}✅ MATCH${NC}"
        log_success "Check 4: Checksums match"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo -e "${YELLOW}⚠️  MISMATCH${NC} (local file modified)"
        log_warn "Check 4: Checksum mismatch (local modifications detected)"
        CHECKS_WARNING=$((CHECKS_WARNING + 1))
    fi
else
    echo -e "${YELLOW}⚠️  SKIPPED${NC} (no files to verify)"
    log_info "Check 4: Skipped (no files to verify)"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
fi

# ==============================================================================
# Check 5: Size Check
# ==============================================================================

echo -n "Check 5: Size Check... "

if [ -d "$CLAUDE_DIR" ]; then
    TOTAL_BYTES=$(du -sb "$CLAUDE_DIR" 2>/dev/null | cut -f1)
    TOTAL_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B "$TOTAL_BYTES" 2>/dev/null)

    if [ "$TOTAL_BYTES" -lt 104857600 ]; then  # < 100 MB
        echo -e "${GREEN}✅ REASONABLE${NC} ($TOTAL_SIZE_HUMAN)"
        log_success "Check 5: Size is reasonable ($TOTAL_SIZE_HUMAN)"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo -e "${YELLOW}⚠️  LARGE${NC} ($TOTAL_SIZE_HUMAN)"
        log_warn "Check 5: Size is large ($TOTAL_SIZE_HUMAN)"
        CHECKS_WARNING=$((CHECKS_WARNING + 1))
    fi
else
    echo -e "${RED}❌ NOT FOUND${NC}"
    log_error "Check 5: ~/.claude directory not found"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# ==============================================================================
# Check 6: Broken Symlinks
# ==============================================================================

echo -n "Check 6: Broken Symlinks... "

if [ -d "$CLAUDE_DIR/skills/user" ]; then
    BROKEN_COUNT=0
    BROKEN_SKILLS=""

    for skill in "$CLAUDE_DIR/skills/user"/*; do
        [ -e "$skill" ] || continue
        if [ -L "$skill" ]; then
            if [ ! -e "$skill" ]; then
                skill_name=$(basename "$skill")
                BROKEN_SKILLS="$BROKEN_SKILLS $skill_name"
                BROKEN_COUNT=$((BROKEN_COUNT + 1))
            fi
        fi
    done 2>/dev/null

    if [ $BROKEN_COUNT -eq 0 ]; then
        echo -e "${GREEN}✅ ALL VALID${NC}"
        log_success "Check 6: All symlinks are valid"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo -e "${RED}❌ BROKEN${NC} ($BROKEN_COUNT broken:$BROKEN_SKILLS)"
        log_error "Check 6: Found $BROKEN_COUNT broken symlink(s):$BROKEN_SKILLS"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
else
    echo -e "${YELLOW}⚠️  SKIPPED${NC} (no skills directory)"
    log_info "Check 6: Skipped (no skills directory)"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
fi

# ==============================================================================
# Overall Status
# ==============================================================================

echo ""
echo "============================================================"

TOTAL_CHECKS=$((CHECKS_PASSED + CHECKS_WARNING + CHECKS_FAILED))

if [ $CHECKS_FAILED -eq 0 ] && [ $CHECKS_WARNING -eq 0 ]; then
    echo -e "${GREEN}Overall Status: ✅ HEALTHY${NC}"
    log_summary "success" "All health checks passed"
    OVERALL_STATUS="HEALTHY"
elif [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${YELLOW}Overall Status: ⚠️  WARNINGS${NC}"
    log_summary "success" "Health checks passed with warnings"
    OVERALL_STATUS="WARNINGS"
else
    echo -e "${RED}Overall Status: ❌ UNHEALTHY${NC}"
    log_summary "failed" "Health checks failed"
    OVERALL_STATUS="UNHEALTHY"
fi

echo "============================================================"
echo ""
echo "Summary:"
echo "  Passed: $CHECKS_PASSED / $TOTAL_CHECKS"
echo "  Warnings: $CHECKS_WARNING / $TOTAL_CHECKS"
echo "  Failed: $CHECKS_FAILED / $TOTAL_CHECKS"
echo ""

# Cleanup
rm -rf "$TEMP_DIR"

# Exit code
if [ "$OVERALL_STATUS" = "UNHEALTHY" ]; then
    exit 1
else
    exit 0
fi
