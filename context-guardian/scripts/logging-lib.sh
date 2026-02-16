#!/bin/bash
# Context Guardian - Logging Infrastructure Library
# Source this file in all scripts: source "$(dirname "$0")/logging-lib.sh"

# Initialize logging
LOG_DIR="$HOME/.claude/context-guardian/logs"
mkdir -p "$LOG_DIR"

# Generate log filename based on calling script
SCRIPT_NAME=$(basename "${BASH_SOURCE[1]}" .sh 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/${SCRIPT_NAME}_${TIMESTAMP}.log"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Logging functions
log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

log_info() {
    local message="$@"
    log "INFO" "$message"
    echo -e "${CYAN}ℹ${NC} $message"
}

log_warn() {
    local message="$@"
    log "WARN" "$message"
    echo -e "${YELLOW}⚠${NC} $message"
}

log_error() {
    local message="$@"
    log "ERROR" "$message"
    echo -e "${RED}❌${NC} $message"
}

log_success() {
    local message="$@"
    log "SUCCESS" "$message"
    echo -e "${GREEN}✅${NC} $message"
}

log_debug() {
    local message="$@"
    log "DEBUG" "$message"
    if [ "$DEBUG" = "true" ]; then
        echo -e "${GRAY}🔍 $message${NC}"
    fi
}

# Banner function
log_banner() {
    local title="$1"
    local separator="============================================================"

    echo ""
    echo -e "${CYAN}${separator}${NC}"
    echo -e "${CYAN}${title}${NC}"
    echo -e "${CYAN}${separator}${NC}"
    echo ""

    log "BANNER" "$title"
}

# Summary function
log_summary() {
    local status="$1"
    local message="$2"

    echo ""
    if [ "$status" = "success" ]; then
        echo -e "${GREEN}============================================================${NC}"
        echo -e "${GREEN}✅ SUCCESS: $message${NC}"
        echo -e "${GREEN}============================================================${NC}"
    else
        echo -e "${RED}============================================================${NC}"
        echo -e "${RED}❌ FAILED: $message${NC}"
        echo -e "${RED}============================================================${NC}"
    fi
    echo ""
    echo -e "${GRAY}Full log: $LOG_FILE${NC}"
    echo ""

    log "SUMMARY" "$status: $message"
}

# Export log file path for scripts to access
export LOG_FILE
export LOG_DIR

# Log script start
log "START" "Script started: ${BASH_SOURCE[1]}"
log_info "Logging to: $LOG_FILE"
