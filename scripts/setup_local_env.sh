#!/bin/bash

# setup_local_env.sh
# Claude Intelligence Hub - Fresh Machine Setup Script
# Version: 1.0.0
# Platform: macOS/Linux (Bash 4+)
# Purpose: Idempotent setup of 5 mandatory core skills + optional skills

set -e  # Exit on error

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════

MANDATORY_SKILLS=(
    "jimmy-core-preferences"
    "session-memoria"
    "x-mem"
    "gdrive-sync-memoria"
    "claude-session-registry"
)

OPTIONAL_SKILLS=(
    "pbi-claude-skills"
)

SCRIPT_VERSION="1.0.0"
HUB_PATH="${HUB_PATH:-$HOME/Downloads/claude-intelligence-hub}"
SKILLS_PATH="${SKILLS_PATH:-$HOME/.claude/skills/user}"
FORCE=false
SKIP_OPTIONAL=false
SKIP_VALIDATION=false
LOG_FILE="$(dirname "$0")/setup_local_env.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ═══════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"

    case "$level" in
        ERROR)   echo -e "${RED}${message}${NC}" ;;
        SUCCESS) echo -e "${GREEN}${message}${NC}" ;;
        WARNING) echo -e "${YELLOW}${message}${NC}" ;;
        INFO)    echo -e "${CYAN}${message}${NC}" ;;
        *)       echo "$message" ;;
    esac
}

is_symlink() {
    [ -L "$1" ]
}

create_symlink() {
    local link="$1"
    local target="$2"
    local skill_name="$3"

    # Check if target exists
    if [ ! -d "$target" ]; then
        log ERROR "ERROR: Target directory not found: $target"
        return 1
    fi

    # Check if link already exists
    if [ -e "$link" ] || [ -L "$link" ]; then
        if is_symlink "$link"; then
            if [ "$FORCE" = false ]; then
                log WARNING "  ⏭️  $skill_name: Symlink already exists (use --force to recreate)"
                return 0
            fi
            log INFO "  🔄 $skill_name: Removing existing symlink..."
            rm -f "$link"
        else
            log WARNING "  ⚠️  $skill_name: Directory exists but is NOT a symlink"
            if [ "$FORCE" = false ]; then
                log WARNING "    Use --force to delete and recreate as symlink"
                return 1
            fi
            log WARNING "  🗑️  $skill_name: Removing non-symlink directory..."
            rm -rf "$link"
        fi
    fi

    # Create symlink
    log INFO "  🔗 $skill_name: Creating symlink..."
    if ln -s "$target" "$link"; then
        log SUCCESS "  ✅ $skill_name: Symlink created successfully"
        return 0
    else
        log ERROR "ERROR: Failed to create symlink for $skill_name"
        return 1
    fi
}

get_skill_version() {
    local skill_path="$1"
    local metadata_file="$skill_path/.metadata"

    if [ -f "$metadata_file" ]; then
        local version=$(grep -o '"version":\s*"[^"]*"' "$metadata_file" | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
        echo "${version:-unknown}"
    else
        echo "unknown"
    fi
}

# ═══════════════════════════════════════════════════════════════
# SECTION 1: PRE-FLIGHT VALIDATION
# ═══════════════════════════════════════════════════════════════

preflight_checks() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  CLAUDE INTELLIGENCE HUB - LOCAL ENVIRONMENT SETUP${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    log INFO "Script Version: $SCRIPT_VERSION"
    log INFO "Hub Path: $HUB_PATH"
    log INFO "Skills Path: $SKILLS_PATH"
    log INFO "Force Mode: $FORCE"
    echo ""

    # Check if hub directory exists
    if [ ! -d "$HUB_PATH" ]; then
        log ERROR "ERROR: Hub directory not found: $HUB_PATH"
        log ERROR "Please clone the repository first:"
        log ERROR "  git clone https://github.com/mrjimmyny/claude-intelligence-hub.git $HUB_PATH"
        return 1
    fi

    # Check if HUB_MAP.md exists
    if [ ! -f "$HUB_PATH/HUB_MAP.md" ]; then
        log ERROR "ERROR: HUB_MAP.md not found. Invalid hub directory?"
        return 1
    fi

    # Create skills directory if it doesn't exist
    if [ ! -d "$SKILLS_PATH" ]; then
        log INFO "Creating skills directory: $SKILLS_PATH"
        mkdir -p "$SKILLS_PATH"
    fi

    log SUCCESS "✅ Pre-flight checks passed"
    echo ""
    return 0
}

# ═══════════════════════════════════════════════════════════════
# SECTION 2: MANDATORY CORE SKILLS SETUP
# ═══════════════════════════════════════════════════════════════

install_mandatory_skills() {
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  STEP 1: MANDATORY CORE SKILLS (Auto-Install)${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    local success_count=0
    local failed_skills=()

    for skill in "${MANDATORY_SKILLS[@]}"; do
        local target_path="$HUB_PATH/$skill"
        local link_path="$SKILLS_PATH/$skill"

        if create_symlink "$link_path" "$target_path" "$skill"; then
            local version=$(get_skill_version "$target_path")
            log INFO "    Version: $version"
            ((success_count++))
        else
            failed_skills+=("$skill")
        fi
        echo ""
    done

    echo -e "${GRAY}─────────────────────────────────────────────────────────────${NC}"
    log INFO "Mandatory Skills: $success_count/${#MANDATORY_SKILLS[@]} installed"

    if [ ${#failed_skills[@]} -gt 0 ]; then
        log WARNING "⚠️  Failed skills: ${failed_skills[*]}"
        return 1
    fi

    log SUCCESS "✅ All mandatory skills installed successfully"
    echo ""
    return 0
}

# ═══════════════════════════════════════════════════════════════
# SECTION 3: OPTIONAL SKILLS PROMPT
# ═══════════════════════════════════════════════════════════════

install_optional_skills() {
    if [ "$SKIP_OPTIONAL" = true ]; then
        log INFO "Skipping optional skills (--skip-optional flag)"
        echo ""
        return 0
    fi

    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  STEP 2: OPTIONAL SKILLS (User Selection)${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    for skill in "${OPTIONAL_SKILLS[@]}"; do
        local target_path="$HUB_PATH/$skill"

        # Check if skill exists in hub
        if [ ! -d "$target_path" ]; then
            log WARNING "⏭️  $skill: Not available in hub (skipping)"
            continue
        fi

        # Get skill description
        local description
        case "$skill" in
            pbi-claude-skills) description="Power BI optimization and DAX development" ;;
            *) description="Optional skill" ;;
        esac

        echo -e "${GRAY}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${GRAY}│ Skill: ${WHITE}$skill${NC}"
        echo -e "${GRAY}│ Description: ${WHITE}$description${NC}"
        echo -e "${GRAY}└─────────────────────────────────────────────────────────────┘${NC}"

        read -p "Install $skill? (Y/N): " response

        if [[ "$response" =~ ^[Yy]$ ]]; then
            local link_path="$SKILLS_PATH/$skill"
            if create_symlink "$link_path" "$target_path" "$skill"; then
                local version=$(get_skill_version "$target_path")
                log INFO "    Version: $version"
            fi
        else
            log INFO "  ⏭️  $skill: Skipped by user"
        fi
        echo ""
    done

    echo ""
    return 0
}

# ═══════════════════════════════════════════════════════════════
# SECTION 4: POST-SETUP VALIDATION
# ═══════════════════════════════════════════════════════════════

post_setup_validation() {
    if [ "$SKIP_VALIDATION" = true ]; then
        log WARNING "Skipping validation (--skip-validation flag)"
        echo ""
        return 0
    fi

    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  STEP 3: POST-SETUP VALIDATION${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Check symlinks
    log INFO "Validating symlinks..."
    local symlinks_valid=true

    for skill in "${MANDATORY_SKILLS[@]}"; do
        local link_path="$SKILLS_PATH/$skill"

        if ! is_symlink "$link_path"; then
            log ERROR "  ❌ $skill: Symlink NOT found or invalid"
            symlinks_valid=false
        else
            log SUCCESS "  ✅ $skill: Symlink valid"
        fi
    done
    echo ""

    # Run integrity-check.sh if available
    local integrity_script="$HUB_PATH/scripts/integrity-check.sh"
    if [ -f "$integrity_script" ]; then
        log INFO "Running hub integrity check..."
        echo ""

        pushd "$HUB_PATH" > /dev/null
        if bash "$integrity_script"; then
            log SUCCESS "✅ Hub integrity check passed"
        else
            log WARNING "⚠️  Hub integrity check reported issues"
        fi
        popd > /dev/null
        echo ""
    fi

    [ "$symlinks_valid" = true ] && return 0 || return 1
}

# ═══════════════════════════════════════════════════════════════
# SECTION 5: SUCCESS SUMMARY
# ═══════════════════════════════════════════════════════════════

show_summary() {
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✅ SETUP COMPLETE!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    echo -e "${CYAN}📍 Installed Skills:${NC}"
    local installed_count=0

    for dir in "$SKILLS_PATH"/*; do
        if [ -d "$dir" ] && is_symlink "$dir"; then
            local skill_name=$(basename "$dir")
            local version=$(get_skill_version "$dir")
            echo -e "  ${GREEN}✓${NC} ${WHITE}$skill_name${NC} ${GRAY}($version)${NC}"
            ((installed_count++))
        fi
    done

    echo ""
    echo -e "${CYAN}📊 Summary:${NC}"
    echo -e "  ${WHITE}• Total skills installed: $installed_count${NC}"
    echo -e "  ${WHITE}• Mandatory core skills: ${#MANDATORY_SKILLS[@]}${NC}"
    echo -e "  ${GRAY}• Skills directory: $SKILLS_PATH${NC}"
    echo -e "  ${GRAY}• Hub directory: $HUB_PATH${NC}"
    echo ""

    echo -e "${CYAN}🚀 Next Steps:${NC}"
    echo -e "  ${WHITE}1. Start Claude Code in any project directory${NC}"
    echo -e "  ${WHITE}2. Skills will auto-load from ~/.claude/skills/user/${NC}"
    echo -e "  ${WHITE}3. To update skills: cd $HUB_PATH && git pull${NC}"
    echo ""

    echo -e "${GRAY}📝 Log file: $LOG_FILE${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# ARGUMENT PARSING
# ═══════════════════════════════════════════════════════════════

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --hub-path)
                HUB_PATH="$2"
                shift 2
                ;;
            --skills-path)
                SKILLS_PATH="$2"
                shift 2
                ;;
            --force|-f)
                FORCE=true
                shift
                ;;
            --skip-optional)
                SKIP_OPTIONAL=true
                shift
                ;;
            --skip-validation)
                SKIP_VALIDATION=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --hub-path PATH        Hub directory path (default: ~/Downloads/claude-intelligence-hub)"
                echo "  --skills-path PATH     Skills directory path (default: ~/.claude/skills/user)"
                echo "  --force, -f            Force recreate existing junctions/symlinks"
                echo "  --skip-optional        Skip optional skills prompt"
                echo "  --skip-validation      Skip post-setup validation"
                echo "  --help, -h             Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════

main() {
    parse_args "$@"

    # Initialize log
    : > "$LOG_FILE"
    log INFO "═══════════════════════════════════════════════════════════════"
    log INFO "Setup Local Environment - START"
    log INFO "═══════════════════════════════════════════════════════════════"

    # Pre-flight checks
    if ! preflight_checks; then
        log ERROR "Pre-flight checks failed. Exiting."
        exit 1
    fi

    # Install mandatory skills
    if ! install_mandatory_skills; then
        log ERROR "Mandatory skills installation failed. Review errors above."
        exit 1
    fi

    # Install optional skills
    install_optional_skills

    # Post-setup validation
    if ! post_setup_validation; then
        log WARNING "⚠️  Validation detected issues, but setup may still be functional"
    fi

    # Show summary
    show_summary

    log SUCCESS "Setup completed successfully"
    exit 0
}

# Run main function
main "$@"
