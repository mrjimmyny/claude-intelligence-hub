#!/usr/bin/env bash
# send-email.sh — Enforced email sender with HTML formatting
# Usage: send-email.sh --to <email> --subject <subject> --body <html>
# Always sends as HTML via gws CLI. Falls back to Resend CLI if gws fails.
#
# Part of: codex-task-notifier skill
# See: jimmy-core-preferences Section R (R-14)

set -euo pipefail

TO=""
SUBJECT=""
BODY=""
ATTACHMENT=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --to) TO="$2"; shift 2 ;;
    --subject) SUBJECT="$2"; shift 2 ;;
    --body) BODY="$2"; shift 2 ;;
    -a|--attach) ATTACHMENT="$2"; shift 2 ;;
    --help)
      echo "Usage: send-email.sh --to <email> --subject <subject> --body <html-body> [-a file]"
      echo ""
      echo "Sends HTML email via gws CLI (Tier 1), falls back to Resend CLI (Tier 2)."
      echo "ALWAYS sends as HTML. The --html flag is enforced automatically."
      exit 0
      ;;
    *) shift ;;
  esac
done

if [[ -z "$TO" || -z "$SUBJECT" || -z "$BODY" ]]; then
  echo "ERROR: --to, --subject, and --body are all required" >&2
  exit 1
fi

# --- Tier 1: gws CLI ---
echo "[send-email] Attempting Tier 1: gws CLI..."
GWS_ARGS=(gmail +send --to "$TO" --subject "$SUBJECT" --body "$BODY" --html)
if [[ -n "$ATTACHMENT" ]]; then
  GWS_ARGS+=(-a "$ATTACHMENT")
fi

if gws "${GWS_ARGS[@]}" 2>/dev/null; then
  echo "[send-email] SUCCESS via gws CLI (Tier 1)"
  exit 0
fi

echo "[send-email] gws CLI failed. Attempting Tier 2: Resend CLI..."

# --- Tier 2: Resend CLI ---
RESEND_KEY="${CTN_RESEND_API_KEY:-}"
if [[ -n "$RESEND_KEY" ]]; then
  if resend emails send \
    --api-key "$RESEND_KEY" \
    --from "notify@mrjimmyny.org" \
    --to "$TO" \
    --subject "$SUBJECT" \
    --html "$BODY" 2>/dev/null; then
    echo "[send-email] SUCCESS via Resend CLI (Tier 2)"
    exit 0
  fi
fi

echo "[send-email] All tiers failed. Email NOT sent." >&2
exit 1
