#!/usr/bin/env bash
# security-reviewx self-test
# Validates that the executing agent/environment has all required capabilities
# Exit 0 = all checks pass, Exit 1 = one or more checks failed

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
PASS=0
FAIL=0

check() {
  local name="$1"
  local result="$2"
  if [ "$result" -eq 0 ]; then
    echo "  [PASS] $name"
    ((PASS++))
  else
    echo "  [FAIL] $name"
    ((FAIL++))
  fi
}

echo "=== security-reviewx Self-Test ==="
echo ""

# 1. Pattern library accessible
PATTERN_COUNT=$(find "$SKILL_ROOT/patterns" -name "*.json" 2>/dev/null | wc -l)
check "Pattern library accessible ($PATTERN_COUNT JSON files)" "$([ "$PATTERN_COUNT" -ge 7 ] && echo 0 || echo 1)"

# 2. VERSION file exists
check "Pattern VERSION file exists" "$([ -f "$SKILL_ROOT/patterns/VERSION" ] && echo 0 || echo 1)"

# 3. All pattern files valid JSON
JSON_VALID=0
for f in "$SKILL_ROOT/patterns/"*.json; do
  if ! node -e "const fs=require('fs');const p=process.argv[1];JSON.parse(fs.readFileSync(p,'utf8'))" "$f" 2>/dev/null; then
    JSON_VALID=1
    echo "    Invalid JSON: $f"
  fi
done
check "All pattern files valid JSON" "$JSON_VALID"

# 4. Git available
git --version >/dev/null 2>&1
check "Git available" "$?"

# 5. Reports directory exists
check "Reports directory exists" "$([ -d "$SKILL_ROOT/reports" ] && echo 0 || echo 1)"

# 6. Can determine repo root
git rev-parse --show-toplevel >/dev/null 2>&1
check "Can determine repo root" "$?"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  echo "SELF-TEST: FAIL — fix issues before scanning"
  exit 1
else
  echo "SELF-TEST: PASS — ready to scan"
  exit 0
fi
