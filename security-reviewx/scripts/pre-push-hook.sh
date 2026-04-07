#!/usr/bin/env bash
# ============================================================
# security-reviewx pre-push hook — QUICK mode scan
#
# Install: cp this file to .git/hooks/pre-push && chmod +x .git/hooks/pre-push
# Skip:    git push --no-verify (logged as finding in next full scan)
#
# Behavior:
#   - Runs QUICK scan (M1-M4: secrets, PII, files, paths)
#   - CRITICAL findings → BLOCK push (exit 1)
#   - HIGH/MEDIUM/LOW → WARN but allow push (exit 0)
#   - No findings → PASS (exit 0)
#
# Cross-machine: Uses relative paths. Works anywhere C:\ai\ exists.
# ============================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}🔒 security-reviewx pre-push scan (QUICK mode)${NC}"
echo "================================================"

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PATTERN_DIR=""

# Find pattern library — check multiple locations
for dir in \
  "$HOME/.claude/skills/security-reviewx/patterns" \
  "/c/ai/claude-intelligence-hub/security-reviewx/patterns" \
  "C:/ai/claude-intelligence-hub/security-reviewx/patterns"; do
  if [ -d "$dir" ]; then
    PATTERN_DIR="$dir"
    break
  fi
done

if [ -z "$PATTERN_DIR" ]; then
  echo -e "${YELLOW}⚠️  Pattern library not found. Skipping scan.${NC}"
  exit 0
fi

CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0
LOW_COUNT=0

# M1: SECRET_SCAN — check for critical patterns
echo -n "M1 SECRET_SCAN... "
while IFS= read -r pattern; do
  if [ -n "$pattern" ]; then
    matches=$(git diff --cached --diff-filter=ACM -U0 HEAD 2>/dev/null | grep -cE "$pattern" 2>/dev/null || true)
    if [ "$matches" -gt 0 ]; then
      CRITICAL_COUNT=$((CRITICAL_COUNT + matches))
    fi
  fi
done <<'PATTERNS'
sk-ant-api[0-9]{2}-[A-Za-z0-9_-]{20,}
AKIA[0-9A-Z]{16}
ghp_[A-Za-z0-9]{36}
-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----
PATTERNS
if [ "$CRITICAL_COUNT" -gt 0 ]; then
  echo -e "${RED}FAIL ($CRITICAL_COUNT critical)${NC}"
else
  echo -e "${GREEN}PASS${NC}"
fi

# M2: PII_SCAN — check for high-severity patterns
echo -n "M2 PII_SCAN... "
PII_MATCHES=$(git diff --cached --diff-filter=ACM -U0 HEAD 2>/dev/null | grep -cE '[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}' 2>/dev/null || true)
if [ "$PII_MATCHES" -gt 0 ]; then
  HIGH_COUNT=$((HIGH_COUNT + PII_MATCHES))
  echo -e "${YELLOW}WARN ($PII_MATCHES high)${NC}"
else
  echo -e "${GREEN}PASS${NC}"
fi

# M3: FILE_SCAN — check for dangerous files being added
echo -n "M3 FILE_SCAN... "
DANGEROUS=$(git diff --cached --name-only --diff-filter=A HEAD 2>/dev/null | grep -cE '\.(pem|key|p12|pfx|env)$' 2>/dev/null || true)
if [ "$DANGEROUS" -gt 0 ]; then
  CRITICAL_COUNT=$((CRITICAL_COUNT + DANGEROUS))
  echo -e "${RED}FAIL ($DANGEROUS dangerous files)${NC}"
else
  echo -e "${GREEN}PASS${NC}"
fi

# M4: PATH_SCAN — check for hardcoded paths
echo -n "M4 PATH_SCAN... "
PATH_MATCHES=$(git diff --cached --diff-filter=ACM -U0 HEAD 2>/dev/null | grep -cE '[A-Z]:\\Users\\[^\\{[:space:]]+\\' 2>/dev/null || true)
if [ "$PATH_MATCHES" -gt 0 ]; then
  MEDIUM_COUNT=$((MEDIUM_COUNT + PATH_MATCHES))
  echo -e "${YELLOW}WARN ($PATH_MATCHES medium)${NC}"
else
  echo -e "${GREEN}PASS${NC}"
fi

# Verdict
echo "================================================"
TOTAL=$((CRITICAL_COUNT + HIGH_COUNT + MEDIUM_COUNT + LOW_COUNT))

if [ "$CRITICAL_COUNT" -gt 0 ]; then
  echo -e "${RED}❌ BLOCKED: $CRITICAL_COUNT CRITICAL findings detected.${NC}"
  echo -e "${RED}   Fix critical issues before pushing.${NC}"
  echo -e "${YELLOW}   Skip with: git push --no-verify (not recommended)${NC}"
  exit 1
elif [ "$TOTAL" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  WARNING: $TOTAL non-critical findings (H:$HIGH_COUNT M:$MEDIUM_COUNT L:$LOW_COUNT)${NC}"
  echo -e "${YELLOW}   Push allowed. Run full scan to review: /security-reviewx${NC}"
  exit 0
else
  echo -e "${GREEN}✅ PASS: No security findings detected.${NC}"
  exit 0
fi
