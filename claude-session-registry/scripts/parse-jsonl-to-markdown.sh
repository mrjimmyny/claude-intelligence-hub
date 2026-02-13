#!/bin/bash
# parse-jsonl-to-markdown.sh
# Converts Claude session .jsonl files to human-readable markdown transcripts
#
# Usage: parse-jsonl-to-markdown.sh <session_id> <jsonl_file> <output_md> <metadata_json>
#
# Arguments:
#   session_id      - UUID of the session
#   jsonl_file      - Path to .jsonl session file
#   output_md       - Path to output markdown file
#   metadata_json   - JSON string with session metadata (date, tags, summary, etc.)
#
# Example:
#   bash parse-jsonl-to-markdown.sh \
#     "338633b3-36fb-43c9-8bdd-701f93fba9f2" \
#     "~/.claude/projects/C--Users-jaderson-almeida-Downloads/338633b3-36fb-43c9-8bdd-701f93fba9f2.jsonl" \
#     "~/claude-session-backups/transcripts/2026/02/338633b3-36fb-43c9-8bdd-701f93fba9f2.md" \
#     '{"session_id":"...","date":"2026-02-12","tags":"#critical",...}'

set -euo pipefail

# Find jq (check multiple locations)
if command -v jq &> /dev/null; then
    JQ="jq"
elif [ -f "$HOME/bin/jq.exe" ]; then
    JQ="$HOME/bin/jq.exe"
elif [ -f "$HOME/bin/jq" ]; then
    JQ="$HOME/bin/jq"
else
    echo "❌ Error: jq not found. Please install jq."
    echo "💡 Download from: https://jqlang.github.io/jq/download/"
    exit 1
fi

# Arguments
SESSION_ID="${1:-}"
JSONL_FILE="${2:-}"
OUTPUT_MD="${3:-}"
METADATA_JSON="${4:-}"

# Validate arguments
if [ -z "$SESSION_ID" ] || [ -z "$JSONL_FILE" ] || [ -z "$OUTPUT_MD" ] || [ -z "$METADATA_JSON" ]; then
    echo "❌ Error: Missing required arguments"
    echo "Usage: $0 <session_id> <jsonl_file> <output_md> <metadata_json>"
    exit 1
fi

# Expand tilde in paths
JSONL_FILE="${JSONL_FILE/#\~/$HOME}"
OUTPUT_MD="${OUTPUT_MD/#\~/$HOME}"

# Validate jsonl file exists
if [ ! -f "$JSONL_FILE" ]; then
    echo "❌ Error: JSONL file not found: $JSONL_FILE"
    exit 1
fi

# Ensure output directory exists
OUTPUT_DIR=$(dirname "$OUTPUT_MD")
mkdir -p "$OUTPUT_DIR"

# Extract metadata fields using jq
SESSION_DATE=$(echo "$METADATA_JSON" | $JQ -r '.date // "Unknown"')
SESSION_TIME=$(echo "$METADATA_JSON" | $JQ -r '.time // "Unknown"')
SESSION_TAGS=$(echo "$METADATA_JSON" | $JQ -r '.tags // ""')
SESSION_SUMMARY=$(echo "$METADATA_JSON" | $JQ -r '.summary // "No summary provided"')
SESSION_PROJECT=$(echo "$METADATA_JSON" | $JQ -r '.project // "Unknown"')
SESSION_MACHINE=$(echo "$METADATA_JSON" | $JQ -r '.machine // "Unknown"')
SESSION_BRANCH=$(echo "$METADATA_JSON" | $JQ -r '.branch // ""')
SESSION_COMMIT=$(echo "$METADATA_JSON" | $JQ -r '.commit // ""')
IS_CRITICAL=$(echo "$METADATA_JSON" | $JQ -r '.tags // "" | contains("#critical")')

# Get current timestamp for backup_date
BACKUP_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Initialize counters
TOTAL_MESSAGES=0
USER_MESSAGES=0
ASSISTANT_MESSAGES=0
TOOL_CALLS=0

# Temporary file for conversation content
TEMP_CONV=$(mktemp)
trap "rm -f $TEMP_CONV" EXIT

echo "🔍 Parsing JSONL file: $JSONL_FILE"

# Parse JSONL line by line
while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Extract message type
    MSG_TYPE=$(echo "$line" | $JQ -r '.type // empty')

    # Skip file-history-snapshot (noise)
    if [ "$MSG_TYPE" = "file-history-snapshot" ]; then
        continue
    fi

    # Increment total messages (excluding snapshots)
    TOTAL_MESSAGES=$((TOTAL_MESSAGES + 1))

    # Parse based on type
    case "$MSG_TYPE" in
        user)
            USER_MESSAGES=$((USER_MESSAGES + 1))

            # Extract timestamp (if available)
            TIMESTAMP=$(echo "$line" | $JQ -r '.timestamp // ""')
            if [ -n "$TIMESTAMP" ]; then
                # Format timestamp to readable format
                FORMATTED_TIME=$(date -d "$TIMESTAMP" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$TIMESTAMP")
            else
                FORMATTED_TIME=""
            fi

            # Extract message content
            MESSAGE=$(echo "$line" | $JQ -r '.message // ""')

            # Write to temp file
            echo "" >> "$TEMP_CONV"
            if [ -n "$FORMATTED_TIME" ]; then
                echo "### 👤 User [$FORMATTED_TIME]" >> "$TEMP_CONV"
            else
                echo "### 👤 User" >> "$TEMP_CONV"
            fi
            echo "" >> "$TEMP_CONV"
            echo "$MESSAGE" >> "$TEMP_CONV"
            ;;

        assistant)
            ASSISTANT_MESSAGES=$((ASSISTANT_MESSAGES + 1))

            # Extract timestamp
            TIMESTAMP=$(echo "$line" | $JQ -r '.timestamp // ""')
            if [ -n "$TIMESTAMP" ]; then
                FORMATTED_TIME=$(date -d "$TIMESTAMP" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$TIMESTAMP")
            else
                FORMATTED_TIME=""
            fi

            # Extract thinking block (if present)
            THINKING=$(echo "$line" | $JQ -r '.thinking // empty')

            # Extract text response
            TEXT=$(echo "$line" | $JQ -r '.text // ""')

            # Extract tool uses
            TOOL_USES=$(echo "$line" | $JQ -c '.tool_uses // []')
            TOOL_COUNT=$(echo "$TOOL_USES" | $JQ 'length')

            # Write to temp file
            echo "" >> "$TEMP_CONV"
            if [ -n "$FORMATTED_TIME" ]; then
                echo "### 🤖 Assistant [$FORMATTED_TIME]" >> "$TEMP_CONV"
            else
                echo "### 🤖 Assistant" >> "$TEMP_CONV"
            fi
            echo "" >> "$TEMP_CONV"

            # Add thinking block if present
            if [ -n "$THINKING" ]; then
                echo "**💭 Thinking:**" >> "$TEMP_CONV"
                echo '```' >> "$TEMP_CONV"
                echo "$THINKING" >> "$TEMP_CONV"
                echo '```' >> "$TEMP_CONV"
                echo "" >> "$TEMP_CONV"
            fi

            # Add text response
            if [ -n "$TEXT" ]; then
                echo "$TEXT" >> "$TEMP_CONV"
                echo "" >> "$TEMP_CONV"
            fi

            # Add tool calls if present
            if [ "$TOOL_COUNT" -gt 0 ]; then
                TOOL_CALLS=$((TOOL_CALLS + TOOL_COUNT))
                echo "**🔧 Tool Calls:** ($TOOL_COUNT)" >> "$TEMP_CONV"

                # Parse each tool use
                for i in $(seq 0 $((TOOL_COUNT - 1))); do
                    TOOL_NAME=$(echo "$TOOL_USES" | $JQ -r ".[$i].name // \"Unknown\"")
                    TOOL_INPUT=$(echo "$TOOL_USES" | $JQ -r ".[$i].input // {}")

                    # Format based on common tools
                    case "$TOOL_NAME" in
                        Read)
                            FILE_PATH=$(echo "$TOOL_INPUT" | $JQ -r '.file_path // ""')
                            echo "- 📖 **Read** → \`$FILE_PATH\`" >> "$TEMP_CONV"
                            ;;
                        Write)
                            FILE_PATH=$(echo "$TOOL_INPUT" | $JQ -r '.file_path // ""')
                            echo "- ✍️ **Write** → \`$FILE_PATH\`" >> "$TEMP_CONV"
                            ;;
                        Edit)
                            FILE_PATH=$(echo "$TOOL_INPUT" | $JQ -r '.file_path // ""')
                            echo "- ✏️ **Edit** → \`$FILE_PATH\`" >> "$TEMP_CONV"
                            ;;
                        Bash)
                            COMMAND=$(echo "$TOOL_INPUT" | $JQ -r '.command // ""' | head -c 60)
                            echo "- 💻 **Bash** → \`$COMMAND...\`" >> "$TEMP_CONV"
                            ;;
                        Grep)
                            PATTERN=$(echo "$TOOL_INPUT" | $JQ -r '.pattern // ""')
                            echo "- 🔍 **Grep** → \`$PATTERN\`" >> "$TEMP_CONV"
                            ;;
                        Glob)
                            PATTERN=$(echo "$TOOL_INPUT" | $JQ -r '.pattern // ""')
                            echo "- 📁 **Glob** → \`$PATTERN\`" >> "$TEMP_CONV"
                            ;;
                        Task)
                            SUBAGENT=$(echo "$TOOL_INPUT" | $JQ -r '.subagent_type // ""')
                            PROMPT=$(echo "$TOOL_INPUT" | $JQ -r '.prompt // ""' | head -c 40)
                            echo "- 🤖 **Task** ($SUBAGENT) → \`$PROMPT...\`" >> "$TEMP_CONV"
                            ;;
                        *)
                            echo "- 🔧 **$TOOL_NAME**" >> "$TEMP_CONV"
                            ;;
                    esac
                done
                echo "" >> "$TEMP_CONV"
            fi
            ;;

        tool_result)
            # Extract tool result (abbreviated)
            TOOL_NAME=$(echo "$line" | $JQ -r '.tool_name // "Unknown"')
            IS_ERROR=$(echo "$line" | $JQ -r '.is_error // false')

            if [ "$IS_ERROR" = "true" ]; then
                ERROR_MSG=$(echo "$line" | $JQ -r '.content // "Unknown error"' | head -c 100)
                echo "  ❌ **Error:** $ERROR_MSG" >> "$TEMP_CONV"
                echo "" >> "$TEMP_CONV"
            fi
            # Don't show successful tool results (too verbose)
            ;;

        *)
            # Unknown type, skip silently
            ;;
    esac

done < "$JSONL_FILE"

echo "📊 Statistics:"
echo "   Total Messages: $TOTAL_MESSAGES"
echo "   User Messages: $USER_MESSAGES"
echo "   Assistant Messages: $ASSISTANT_MESSAGES"
echo "   Tool Calls: $TOOL_CALLS"

# Generate markdown output
cat > "$OUTPUT_MD" <<EOF
---
session_id: $SESSION_ID
date: $SESSION_DATE
time: $SESSION_TIME
tags: $SESSION_TAGS
is_critical: $IS_CRITICAL
backup_date: $BACKUP_DATE
project: $SESSION_PROJECT
machine: $SESSION_MACHINE
branch: $SESSION_BRANCH
commit: $SESSION_COMMIT
---

# Session: $SESSION_ID

**Summary:** $SESSION_SUMMARY

**Model:** claude-sonnet-4-5-20250929
**Date:** $SESSION_DATE $SESSION_TIME
**Project:** \`$SESSION_PROJECT\`
**Machine:** $SESSION_MACHINE
**Tags:** $SESSION_TAGS

EOF

# Add git context if available
if [ -n "$SESSION_BRANCH" ]; then
    echo "**Git Branch:** \`$SESSION_BRANCH\`  " >> "$OUTPUT_MD"
fi
if [ -n "$SESSION_COMMIT" ]; then
    echo "**Git Commit:** \`$SESSION_COMMIT\`  " >> "$OUTPUT_MD"
fi

cat >> "$OUTPUT_MD" <<EOF

---

## 💬 Conversation Transcript

EOF

# Append conversation content
cat "$TEMP_CONV" >> "$OUTPUT_MD"

# Add statistics section
cat >> "$OUTPUT_MD" <<EOF

---

## 📊 Session Statistics

- **Total Messages:** $TOTAL_MESSAGES
- **User Messages:** $USER_MESSAGES
- **Assistant Messages:** $ASSISTANT_MESSAGES
- **Tool Calls:** $TOOL_CALLS
- **Backup Date:** $BACKUP_DATE

---

## 🔗 Related Links

- [Session Registry](https://github.com/mrjimmyny/claude-intelligence-hub/tree/main/claude-session-registry)
- [Restore Guide](https://github.com/mrjimmyny/claude-session-backups/blob/main/docs/RESTORE_GUIDE.md)

EOF

# Add critical session note
if [ "$IS_CRITICAL" = "true" ]; then
    cat >> "$OUTPUT_MD" <<EOF

---

## ⚠️ Critical Session

This session was tagged as **critical** and has a full .jsonl backup available for restore.

**Restore instructions:** See [RESTORE_GUIDE.md](https://github.com/mrjimmyny/claude-session-backups/blob/main/docs/RESTORE_GUIDE.md)

EOF
fi

echo "✅ Markdown transcript generated: $OUTPUT_MD"
