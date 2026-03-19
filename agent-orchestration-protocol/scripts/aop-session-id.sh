#!/usr/bin/env bash
# ============================================================
# aop-session-id.sh — Collision-safe AOP session ID generation
# ============================================================
#
# Purpose:  Generate an 8-character hex session ID using
#           nanosecond-seeded SHA256 hashing with macOS fallback.
#
# Usage:    source scripts/aop-session-id.sh
#           echo "$SESSION_ID"
#
# Dependencies: sha256sum (coreutils) or shasum (macOS)
#
# Example:
#   source scripts/aop-session-id.sh
#   echo "Session: $SESSION_ID"   # e.g. "Session: a1b2c3d4"
# ============================================================

# Primary: nanosecond-seeded (Linux, Git Bash, WSL)
if date +%s%N &>/dev/null && [ "$(date +%N)" != "N" ]; then
  SESSION_ID="$(date +%s%N | sha256sum | head -c 8)"
else
  # Fallback: second + PID (macOS where %N is not supported)
  SESSION_ID="$(echo "$(date +%s)_$$" | shasum -a 256 | head -c 8)"
fi

echo "SESSION_ID=${SESSION_ID}"
