#!/usr/bin/env bash
# ============================================================
# validate-trail.sh
# repo-auditor - AUDIT_TRAIL structural validator
#
# Usage:
#   bash scripts/validate-trail.sh [path/to/AUDIT_TRAIL.md]
#
# Returns:
#   0 when structure is valid
#   1 when required fields or gate constraints are invalid
# ============================================================

set -euo pipefail

TRAIL_FILE="${1:-AUDIT_TRAIL.md}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

errors=0
warnings=0

print_header() {
  echo ""
  echo "=================================================="
  echo "  REPO-AUDITOR - validate-trail.sh"
  echo "=================================================="
  echo ""
}

require_key() {
  local key="$1"
  if ! rg -q "^${key}:" "$TRAIL_FILE"; then
    echo -e "${RED}x Missing required key: ${key}${NC}"
    errors=$((errors + 1))
  else
    echo -e "${GREEN}ok ${key}${NC}"
  fi
}

warn() {
  local message="$1"
  echo -e "${YELLOW}! ${message}${NC}"
  warnings=$((warnings + 1))
}

fail() {
  local message="$1"
  echo -e "${RED}x ${message}${NC}"
  errors=$((errors + 1))
}

print_header

if [ ! -f "$TRAIL_FILE" ]; then
  echo -e "${RED}x AUDIT_TRAIL file not found: ${TRAIL_FILE}${NC}"
  exit 1
fi

echo -e "${BLUE}Trail file:${NC} $TRAIL_FILE"
echo ""

echo "-- Required Keys --"
required_keys=(
  audit_version
  audit_date
  audit_agent
  audit_mode
  target_repo
  target_branch
  target_version
  audit_result
  critical_errors_open
  warnings_found
  phase_0_status
  phase_1_status
  phase_1_2_status
  phase_1_5_status
  phase_2_status
  phase_3_status
  phase_3_6_status
)

for key in "${required_keys[@]}"; do
  require_key "$key"
done

echo ""
echo "-- Status Validation --"

check_status() {
  local key="$1"
  local allowed="$2"
  local value
  value=$(awk -F': ' -v k="$key" '$1==k {print $2; exit}' "$TRAIL_FILE")

  if [ -z "$value" ]; then
    fail "${key} has no value"
    return
  fi

  if [[ "$value" == "<"* ]]; then
    warn "${key} is still a template placeholder (${value})"
    return
  fi

  if ! echo "$value" | rg -q "^(${allowed})$"; then
    fail "${key} has invalid value '${value}'"
  else
    echo -e "${GREEN}ok ${key}=${value}${NC}"
  fi
}

check_status "audit_result" "PASS|PASS_WITH_WARNINGS|FAIL"
check_status "phase_0_status" "PASS|FAIL|BLOCKED"
check_status "phase_1_status" "PASS|FAIL|PASS_WITH_WARNINGS|BLOCKED"
check_status "phase_1_2_status" "PASS|FAIL|PASS_WITH_WARNINGS|BLOCKED"
check_status "phase_1_5_status" "PASS|FAIL|PASS_WITH_WARNINGS|BLOCKED"
check_status "phase_2_status" "PASS|FAIL|PASS_WITH_WARNINGS|BLOCKED"
check_status "phase_3_status" "PASS|FAIL|PASS_WITH_WARNINGS|BLOCKED"
check_status "phase_3_6_status" "PASS|FAIL|SKIPPED|BLOCKED"

echo ""
echo "-- Gate Consistency --"

audit_result=$(awk -F': ' '$1=="audit_result" {print $2; exit}' "$TRAIL_FILE")
critical_errors_open=$(awk -F': ' '$1=="critical_errors_open" {print $2; exit}' "$TRAIL_FILE")

if [[ "$audit_result" == "PASS" || "$audit_result" == "PASS_WITH_WARNINGS" ]]; then
  if [[ "$critical_errors_open" =~ ^[0-9]+$ ]]; then
    if [ "$critical_errors_open" -ne 0 ]; then
      fail "audit_result is ${audit_result} but critical_errors_open is ${critical_errors_open}"
    else
      echo -e "${GREEN}ok audit_result and critical_errors_open are consistent${NC}"
    fi
  else
    warn "critical_errors_open is not numeric (${critical_errors_open})"
  fi
fi

blocked_phases=$(rg -n "^phase_[0-9_]+_status:\s*BLOCKED$" "$TRAIL_FILE" | wc -l | tr -d ' ')
if [ "$blocked_phases" -gt 0 ] && [ "$audit_result" != "FAIL" ] && [[ "$audit_result" != "<"* ]]; then
  fail "One or more phases are BLOCKED but audit_result is ${audit_result}"
fi

echo ""
echo "-- Fingerprint Structure --"

fingerprint_entries=$(rg -n "^  - file:" "$TRAIL_FILE" | wc -l | tr -d ' ')
line_entries=$(rg -n "^    total_lines:" "$TRAIL_FILE" | wc -l | tr -d ' ')
hash_entries=$(rg -n "^    content_hash:" "$TRAIL_FILE" | wc -l | tr -d ' ')

if [ "$fingerprint_entries" -gt 0 ]; then
  if [ "$line_entries" -lt "$fingerprint_entries" ] || [ "$hash_entries" -lt "$fingerprint_entries" ]; then
    fail "fingerprints block is incomplete for one or more entries"
  else
    echo -e "${GREEN}ok fingerprints entries are structurally complete${NC}"
  fi
else
  warn "No fingerprint entries detected in current file"
fi

echo ""
echo "=================================================="
if [ "$errors" -eq 0 ]; then
  echo -e "${GREEN}AUDIT VALID${NC}"
  echo -e "Warnings: ${warnings}"
  echo "=================================================="
  echo ""
  exit 0
else
  echo -e "${RED}AUDIT INVALID${NC}"
  echo -e "Errors: ${errors} | Warnings: ${warnings}"
  echo "=================================================="
  echo ""
  exit 1
fi
