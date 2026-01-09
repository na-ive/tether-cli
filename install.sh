#!/bin/bash

# ==========================================
# TETHER INSTALLER v1.0.0
# Context Engine for AI-Powered Development
# ==========================================

set -euo pipefail

# --- CONFIG ---
VERSION="1.0.0"
PUBLIC_INSTALLER_URL="https://raw.githubusercontent.com/na-ive/tether-cli/main/install.sh"
DEFAULT_STARTER_REPO="https://github.com/na-ive/tether-cli.git"

# Colors
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly RED='\033[0;31m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Paths
readonly CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tether"
readonly BIN_DIR="$HOME/.local/bin"
readonly LIB_DIR="$HOME/.local/lib/tether"
readonly CONFIG_DIR="$HOME/.config/tether"
readonly EXECUTABLE_NAME="tether-cli"

# ==========================================
# HELPER FUNCTIONS
# ==========================================

log_info() { echo -e "${BLUE}[i] $*${NC}"; }
log_success() { echo -e "${GREEN}[+] $*${NC}"; }
log_warn() { echo -e "${YELLOW}[!] $*${NC}"; }
log_error() { echo -e "${RED}[x] $*${NC}" >&2; }
log_step() { echo -e "\n${BOLD}${CYAN}>>> $*${NC}"; }

show_header() {
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════╗
║                                       ║
║         TETHER  INSTALLER             ║
║                                       ║
║   Context Engine for AI Development   ║
║              v1.0.0                   ║
║                                       ║
╚═══════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Required: $1"
        echo "Install $1 and try again."
        exit 1
    fi
}

validate_url() {
    [[ "$1" =~ ^https?:// ]] && return 0 || return 1
}

cleanup_on_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Installation failed (exit code: $exit_code)"
        log_info "Cleaning up..."
        rm -f "$BIN_DIR/$EXECUTABLE_NAME"
    fi
}

trap cleanup_on_error EXIT

# ==========================================
# DEPENDENCY CHECKS
# ==========================================

check_dependencies() {
    log_step "Checking Dependencies"
    
    local missing=()
    
    for cmd in git curl claude; do
        if command -v "$cmd" &> /dev/null; then
            echo "  [+] $cmd"
        else
            missing+=("$cmd")
            echo "  [ ] $cmd"
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo ""
        log_error "Missing dependencies: ${missing[*]}"
        echo ""
        echo "Install instructions:"
        for cmd in "${missing[@]}"; do
            case "$cmd" in
                git) echo "  * git: sudo pacman -S git (Arch) / sudo apt install git (Ubuntu)" ;;
                curl) echo "  * curl: sudo pacman -S curl (Arch) / sudo apt install curl (Ubuntu)" ;;
                claude) echo "  * claude: Visit https://claude.ai/download" ;;
            esac
        done
        exit 1
    fi
    
    log_success "All dependencies satisfied"
}

# ==========================================
# KNOWLEDGE BASE SETUP
# ==========================================

setup_knowledge_base() {
    log_step "Setting Up Knowledge Base"
    
    if [ -d "$CACHE_DIR/.git" ]; then
        log_info "Existing knowledge base found"
        echo ""
        echo "Options:"
        echo "  [1] Keep existing (recommended)"
        echo "  [2] Sync from remote"
        echo "  [3] Replace with new repo"
        echo ""
        read -p "Choice [1-3]: " choice < /dev/tty
        
        case $choice in
            2)
                log_info "Syncing from remote..."
                if (cd "$CACHE_DIR" && git pull --quiet); then
                    log_success "Knowledge base updated"
                else
                    log_warn "Sync failed, using local version"
                fi
                ;;
            3)
                log_warn "This will DELETE existing rules!"
                read -p "Type 'yes' to confirm: " confirm < /dev/tty
                [[ "$confirm" != "yes" ]] && return
                rm -rf "$CACHE_DIR"
                clone_repo
                ;;
            *)
                log_info "Using existing knowledge base"
                ;;
        esac
    else
        clone_repo
    fi
}

clone_repo() {
    echo ""
    echo "Knowledge Base Setup:"
    echo ""
    echo "  For first-time users:"
    echo "     Press ENTER to clone the Starter Kit (examples & templates)"
    echo ""
    echo "  For private rules:"
    echo "     Paste your private repo URL"
    echo ""
    read -p "Repo URL: " user_input < /dev/tty
    
    local repo_url="${user_input:-$DEFAULT_STARTER_REPO}"
    
    if ! validate_url "$repo_url"; then
        log_error "Invalid URL format"
        exit 1
    fi
    
    log_info "Cloning: $repo_url"
    
    if ! git clone --depth 1 --quiet "$repo_url" "$CACHE_DIR" 2>/dev/null; then
        log_error "Clone failed"
        echo ""
        echo "Possible issues:"
        echo "  * Private repo (setup git credentials)"
        echo "  * Network problem"
        echo "  * Invalid URL"
        exit 1
    fi
    
    echo "$VERSION" > "$CACHE_DIR/.version"
    log_success "Knowledge base initialized"
    
    # Show next steps if using starter kit
    if [[ "$repo_url" == "$DEFAULT_STARTER_REPO" ]]; then
        echo ""
        log_info "You're using the Starter Kit (examples only)"
        echo ""
        echo "  To customize:"
        echo "  1. Fork this repo to create your own"
        echo "  2. Add your team's conventions"
        echo "  3. Run installer again with your repo URL"
        echo ""
    fi
}

# ==========================================
# DIRECTORY STRUCTURE
# ==========================================

create_directories() {
    log_step "Creating Directory Structure"
    
    mkdir -p "$BIN_DIR"
    mkdir -p "$LIB_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$CACHE_DIR"/{sessions,backups,context}
    
    log_success "Directories created"
}

# ==========================================
# MODULE GENERATION
# ==========================================

generate_utils_module() {
    cat << 'EOFUTILS' > "$LIB_DIR/utils.sh"
#!/bin/bash
# utils.sh - Helper functions

# Prevent double sourcing
if [ -n "${UTILS_LOADED:-}" ]; then return; fi
readonly UTILS_LOADED=true

# Color codes
readonly C_GREEN='\033[0;32m'
readonly C_BLUE='\033[0;34m'
readonly C_YELLOW='\033[1;33m'
readonly C_CYAN='\033[0;36m'
readonly C_RED='\033[0;31m'
readonly C_BOLD='\033[1m'
readonly C_DIM='\033[2m'
readonly C_NC='\033[0m'

# Logging functions
log_info() { echo -e "${C_BLUE}[i] $*${C_NC}"; }
log_success() { echo -e "${C_GREEN}[+] $*${C_NC}"; }
log_warn() { echo -e "${C_YELLOW}[!] $*${C_NC}"; }
log_error() { echo -e "${C_RED}[x] $*${C_NC}" >&2; }
log_step() { echo -e "${C_BOLD}${C_CYAN}>>> $*${C_NC}"; }

# Parse config files safely (no 'source')
parse_config() {
    local key="$1"
    local file="$2"
    grep "^${key}=" "$file" 2>/dev/null | head -n1 | cut -d'=' -f2- | tr -d '"' | tr -d "'"
}

# Parse YAML-like config simply (for .tether/project.yaml)
parse_yaml_key() {
    local key="$1"
    local file="$2"
    grep "^  ${key}:" "$file" 2>/dev/null | head -n1 | cut -d':' -f2 | tr -d ' '
}

# Check if file should be protected
is_protected_file() {
    local file="$1"
    local protected_patterns=(
        ".env" ".env.*" "*.key" "*.pem"
        "secrets.json" "credentials.json"
        "*.p12" "*.pfx"
    )
    
    for pattern in "${protected_patterns[@]}"; do
        if [[ "$file" == $pattern ]]; then
            return 0
        fi
    done
    return 1
}

# Format file size
format_size() {
    local size=$1
    if [ $size -lt 1024 ]; then
        echo "${size}B"
    elif [ $size -lt 1048576 ]; then
        echo "$((size / 1024))KB"
    else
        echo "$((size / 1048576))MB"
    fi
}

# Get timestamp
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}
EOFUTILS
}

generate_ui_module() {
    cat << 'EOFUI' > "$LIB_DIR/ui.sh"
#!/bin/bash
# ui.sh - CLI UI components

# Source removed - already loaded by main executable

# Show header
show_header() {
    echo -e "${C_BLUE}tether v1.0.0${C_NC}"
}

# Show diff with colors
show_diff() {
    local file="$1"
    
    echo -e "${C_BOLD}File: $file${C_NC}"
    
    if ! git diff --color=always "$file" 2>/dev/null; then
        git diff --no-index /dev/null "$file" 2>/dev/null | tail -n +5
    fi
    echo ""
}

# Show file change summary
show_change_summary() {
    local added=0
    local removed=0
    local modified=0
    
    while IFS= read -r line; do
        case "$line" in
            A*) ((added++)) ;;
            D*) ((removed++)) ;;
            M*) ((modified++)) ;;
        esac
    done < <(git status --short 2>/dev/null)
    
    echo -e "${C_BOLD}Changes Summary${C_NC}"
    echo "┌─────────────────────────────┐"
    [ $added -gt 0 ] && echo "│ ${C_GREEN}Added:${C_NC}    $added files"
    [ $modified -gt 0 ] && echo "│ ${C_YELLOW}Modified:${C_NC} $modified files"
    [ $removed -gt 0 ] && echo "│ ${C_RED}Removed:${C_NC}  $removed files"
    echo "└─────────────────────────────┘"
    echo ""
}

# Progress indicator
show_progress() {
    local message="$1"
    echo -ne "${C_CYAN}[*] $message...${C_NC}\r"
}

clear_progress() {
    echo -ne "\033[2K\r"
}

# Confirmation prompt
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        read -p "$prompt [Y/n]: " response
        [[ -z "$response" || "$response" =~ ^[Yy] ]]
    else
        read -p "$prompt [y/N]: " response
        [[ "$response" =~ ^[Yy] ]]
    fi
}

# Show file list with icons
show_file_list() {
    while IFS= read -r line; do
        local status="${line:0:2}"
        local file="${line:3}"
        
        case "$status" in
            "A ")  echo -e "  ${C_GREEN}[+] $file${C_NC}" ;;
            "M ")  echo -e "  ${C_YELLOW}[~] $file${C_NC}" ;;
            "D ")  echo -e "  ${C_RED}[-] $file${C_NC}" ;;
            *)     echo -e "  ${C_CYAN}[?] $file${C_NC}" ;;
        esac
    done < <(git status --short 2>/dev/null)
}
EOFUI
}

generate_detect_module() {
    cat << 'EOFDETECT' > "$LIB_DIR/detect.sh"
#!/bin/bash
# detect.sh - Project detection

# Source removed - already loaded by main executable

detect_package_manager() {
    if [ -f "pnpm-lock.yaml" ]; then echo "pnpm"
    elif [ -f "yarn.lock" ]; then echo "yarn"
    elif [ -f "bun.lockb" ]; then echo "bun"
    elif [ -f "package-lock.json" ]; then echo "npm"
    else echo "unknown"; fi
}

detect_language() {
    if [ -f "tsconfig.json" ]; then echo "typescript"
    elif [ -f "go.mod" ]; then echo "go"
    elif [ -f "Cargo.toml" ]; then echo "rust"
    elif [ -f "package.json" ]; then echo "javascript"
    else echo "unknown"; fi
}

# Detect Framework (Separated Web & Mobile logic later in core)
detect_framework() {
    # 1. MOBILE CHECK
    if [ -f "app.json" ] || [ -f "app.config.js" ]; then
        if grep -q '"expo"' package.json 2>/dev/null; then echo "expo"; return; fi
    fi
    if [ -f "android/build.gradle" ] && [ -f "ios/Podfile" ]; then echo "react-native"; return; fi

    # 2. WEB CHECK
    if [ ! -f "package.json" ]; then echo "none"; return; fi

    if grep -q '"next"' package.json; then
        if [ -d "app" ] || [ -d "src/app" ]; then echo "next-app"; else echo "next-pages"; fi
    elif grep -q '"nuxt"' package.json; then echo "nuxt"
    elif grep -q '"vite"' package.json; then
        if grep -q '"react"' package.json; then echo "react-vite"
        elif grep -q '"vue"' package.json; then echo "vue-vite"
        else echo "vite"; fi
    elif grep -q '"@angular/core"' package.json; then echo "angular"
    elif grep -q '"react"' package.json; then echo "react"
    elif grep -q '"vue"' package.json; then echo "vue"
    else echo "unknown"; fi
}

# Detect Styling Foundation (Tools only: Tailwind, etc)
detect_styling_foundation() {
    if [ ! -f "package.json" ]; then echo "none"; return; fi
    
    if grep -q '"nativewind"' package.json; then echo "nativewind"
    elif grep -q '"tailwindcss"' package.json; then echo "tailwind"
    elif grep -q '"styled-components"' package.json; then echo "styled-components"
    elif grep -q '"@emotion"' package.json; then echo "emotion"
    elif grep -q '"sass"' package.json; then echo "sass"
    else echo "css"; fi
}

run_project_detection() {
    log_step "Analyzing Project"
    
    local pm=$(detect_package_manager)
    local lang=$(detect_language)
    local fw=$(detect_framework)
    local foundation=$(detect_styling_foundation)
    
    # Design System is strictly MANUAL/CONFIG based (Brutalism, Material, etc)
    local system="none" 
    
    echo "  Package Manager: $pm"
    echo "  Language: $lang"
    echo "  Framework: $fw"
    echo "  Styling Foundation: $foundation"
    
    # Save to project config
    local config_dir=".tether"
    local config_file="$config_dir/project.yaml"
    local tokens_file="$config_dir/design-tokens.md"
    
    mkdir -p "$config_dir"
    
    # 1. Project Config (Machine Readable)
    cat > "$config_file" << EOF
# Auto-detected project configuration
detected_at: $(date +"%Y-%m-%d %H:%M:%S")

project:
  package_manager: $pm
  language: $lang
  framework: $fw
  styling_foundation: $foundation
  design_system: $system  # Edit this manually (e.g., brutalism, material-you)

conventions:
  indent: 2
  quotes: single
  semi: true
EOF

    # 2. Design Tokens (Human/AI Readable - Special MD)
    if [ ! -f "$tokens_file" ]; then
        cat > "$tokens_file" << EOF
# Design Tokens & Theming
This file contains project-specific styling rules. The AI will use this context.

## Colors
- Primary: #000000
- Secondary: #ffffff
- Accent: #3b82f6

## Typography
- Font Family: Inter, sans-serif
- Base Size: 16px

## Components
(Add specific component rules here, e.g., "Buttons should always have rounded-md")
EOF
        log_info "Created template: $tokens_file"
    else
        log_info "Existing tokens file found: $tokens_file"
    fi
    
    log_success "Project configuration saved"
}
EOFDETECT
}

generate_context_module() {
    cat << 'EOFCONTEXT' > "$LIB_DIR/context.sh"
#!/bin/bash
# context.sh - Context assembly

# Source removed - already loaded by main executable

TETHER_LIB="${XDG_CACHE_HOME:-$HOME/.cache}/tether"

# Load and assemble context
assemble_context() {
    local stack="$1"
    local design_system="$2"
    local design_foundation="$3"
    local temp_file
    temp_file=$(mktemp)
    
    # 1. GLOBAL RULES
    if [ -d "$TETHER_LIB/global" ]; then
        echo "=== GLOBAL RULES ===" >> "$temp_file"
        cat "$TETHER_LIB/global/"*.md 2>/dev/null >> "$temp_file" || true
        echo -e "\n" >> "$temp_file"
    elif [ -d "$TETHER_LIB/base" ]; then # Fallback
        echo "=== GLOBAL RULES ===" >> "$temp_file"
        cat "$TETHER_LIB/base/"*.md 2>/dev/null >> "$temp_file" || true
        echo -e "\n" >> "$temp_file"
    fi
    
    # 2. STACK RULES (Strict Web vs Mobile Separation)
    if [ -n "$stack" ] && [ "$stack" != "none" ]; then
        local found_stack=false
        
        # Check WEB Stacks
        if [ -f "$TETHER_LIB/stacks/web/$stack.md" ]; then
            echo "=== WEB STACK: $stack ===" >> "$temp_file"
            cat "$TETHER_LIB/stacks/web/$stack.md" >> "$temp_file"
            found_stack=true
        elif [ -d "$TETHER_LIB/stacks/web/$stack" ]; then
            echo "=== WEB STACK: $stack ===" >> "$temp_file"
            cat "$TETHER_LIB/stacks/web/$stack/"*.md 2>/dev/null >> "$temp_file" || true
            found_stack=true
            
        # Check MOBILE Stacks
        elif [ -f "$TETHER_LIB/stacks/mobile/$stack.md" ]; then
            echo "=== MOBILE STACK: $stack ===" >> "$temp_file"
            cat "$TETHER_LIB/stacks/mobile/$stack.md" >> "$temp_file"
            found_stack=true
        elif [ -d "$TETHER_LIB/stacks/mobile/$stack" ]; then
            echo "=== MOBILE STACK: $stack ===" >> "$temp_file"
            cat "$TETHER_LIB/stacks/mobile/$stack/"*.md 2>/dev/null >> "$temp_file" || true
            found_stack=true
        fi
        
        if [ "$found_stack" = true ]; then
             echo -e "\n" >> "$temp_file"
        fi
    fi
    
    # 3. DESIGN SYSTEM (Philosophy/Theming - e.g. Brutalism)
    if [ -n "$design_system" ] && [ "$design_system" != "none" ]; then
        local system_path="$TETHER_LIB/designs/systems/$design_system.md"
        if [ -f "$system_path" ]; then
            echo "=== DESIGN PHILOSOPHY: $design_system ===" >> "$temp_file"
            cat "$system_path" >> "$temp_file"
            echo -e "\n" >> "$temp_file"
        fi
    fi
    
    # 4. DESIGN FOUNDATION (Tools - e.g. Tailwind)
    if [ -n "$design_foundation" ] && [ "$design_foundation" != "none" ]; then
        local found_path="$TETHER_LIB/designs/foundations/$design_foundation.md"
        if [ -f "$found_path" ]; then
            echo "=== STYLING TOOL: $design_foundation ===" >> "$temp_file"
            cat "$found_path" >> "$temp_file"
            echo -e "\n" >> "$temp_file"
        fi
    fi
    
    # 5. PROJECT SPECIFIC DESIGN TOKENS (The Special MD)
    if [ -f ".tether/design-tokens.md" ]; then
        echo "=== PROJECT DESIGN TOKENS & THEMING ===" >> "$temp_file"
        cat ".tether/design-tokens.md" >> "$temp_file"
        echo -e "\n" >> "$temp_file"
    fi
    
    # 6. General Project Context
    if [ -f ".tether-context.md" ]; then
        echo "=== PROJECT GOAL ===" >> "$temp_file"
        cat ".tether-context.md" >> "$temp_file"
        echo -e "\n" >> "$temp_file"
    fi
    
    # 7. Project Config (YAML)
    if [ -f ".tether/project.yaml" ]; then
        echo "=== TECHNICAL CONFIG ===" >> "$temp_file"
        cat ".tether/project.yaml" >> "$temp_file"
        echo -e "\n" >> "$temp_file"
    fi
    
    cat "$temp_file"
    rm -f "$temp_file"
}

# Get context size
get_context_size() {
    local stack="$1"
    local design_system="$2"
    local design_foundation="$3"
    assemble_context "$stack" "$design_system" "$design_foundation" | wc -c
}
EOFCONTEXT
}

generate_git_module() {
    cat << 'EOFGIT' > "$LIB_DIR/git.sh"
#!/bin/bash
# git.sh - Git operations

# Source removed - already loaded by main executable

GIT_AUTO_COMMIT="${GIT_AUTO_COMMIT:-true}"
GIT_AUTO_PUSH="${GIT_AUTO_PUSH:-false}"
GIT_REQUIRE_REVIEW="${GIT_REQUIRE_REVIEW:-false}"

# Check if in git repo
check_git_repo() {
    git rev-parse --git-dir &>/dev/null
}

# Generate commit message
generate_commit_message() {
    local type="${1:-feat}"
    local scope="${2:-}"
    local description="${3:-tether: AI-generated changes}"
    
    if [ -n "$scope" ]; then
        echo "${type}(${scope}): ${description} [tether]"
    else
        echo "${type}: ${description} [tether]"
    fi
}

# Show dry run preview
git_dry_run() {
    show_header
    echo -e "${C_BOLD}DRY RUN - No changes will be made${C_NC}\n"
    
    if ! git diff --quiet 2>/dev/null && ! git diff --cached --quiet 2>/dev/null; then
        show_change_summary
        show_file_list
        
        echo -e "\n${C_BOLD}Git commit message:${C_NC}"
        echo "  $(generate_commit_message)"
        
        echo ""
        confirm "View detailed diff?" && {
            while IFS= read -r file; do
                show_diff "$file"
            done < <(git diff --name-only)
        }
    else
        log_info "No changes to preview"
    fi
}

# Commit changes
git_commit_changes() {
    local message="$1"
    local auto="${2:-false}"
    
    if ! check_git_repo; then
        log_warn "Not a git repository"
        return 1
    fi
    
    # Check for protected files
    local protected_found=false
    while IFS= read -r file; do
        if is_protected_file "$file"; then
            log_error "Protected file detected: $file"
            protected_found=true
        fi
    done < <(git diff --name-only 2>/dev/null)
    
    if [ "$protected_found" = true ]; then
        log_error "Cannot commit protected files"
        return 1
    fi
    
    # Show changes if not auto
    if [ "$auto" != "true" ]; then
        show_change_summary
        show_file_list
        echo ""
        
        if ! confirm "Commit these changes?"; then
            log_info "Commit cancelled"
            return 1
        fi
    fi
    
    # Stage and commit
    git add -A
    git commit -m "$message" --quiet
    
    log_success "Changes committed"
    
    # Auto push if enabled
    if [ "$GIT_AUTO_PUSH" = "true" ]; then
        git_push
    fi
}

# Push changes
git_push() {
    if ! check_git_repo; then
        return 1
    fi
    
    local branch
    branch=$(git branch --show-current)
    
    log_info "Pushing to $branch..."
    
    if git push origin "$branch" --quiet 2>/dev/null; then
        log_success "Pushed to remote"
    else
        log_warn "Push failed (check remote/credentials)"
    fi
}

# Rollback last commit
git_rollback() {
    local mode="${1:-soft}"
    
    if ! check_git_repo; then
        log_error "Not a git repository"
        return 1
    fi
    
    # Check if last commit was tether-generated
    local last_msg
    last_msg=$(git log -1 --pretty=%B 2>/dev/null)
    
    if [[ ! "$last_msg" =~ \[tether\] ]]; then
        log_warn "Last commit was not generated by Tether"
        if ! confirm "Rollback anyway?"; then
            return 1
        fi
    fi
    
    echo -e "\n${C_BOLD}Last commit:${C_NC}"
    git log -1 --oneline
    echo ""
    
    if ! confirm "Rollback this commit?"; then
        log_info "Rollback cancelled"
        return 1
    fi
    
    case "$mode" in
        soft)
            git reset --soft HEAD~1
            log_success "Commit undone (changes kept)"
            ;;
        hard)
            git reset --hard HEAD~1
            log_success "Commit undone (changes discarded)"
            ;;
        *)
            log_error "Invalid mode: $mode"
            return 1
            ;;
    esac
}

# Show Tether commit history
git_history() {
    if ! check_git_repo; then
        log_error "Not a git repository"
        return 1
    fi
    
    log_step "Tether Commit History"
    
    git log --all --grep="\[tether\]" --oneline --color=always | head -20
    
    echo ""
    local count
    count=$(git log --all --grep="\[tether\]" --oneline | wc -l)
    log_info "Total Tether commits: $count"
}
EOFGIT
}

generate_core_module() {
    cat << 'EOFCORE' > "$LIB_DIR/core.sh"
#!/bin/bash
# core.sh - Main application logic

VERSION="1.0.0"
TETHER_LIB="${XDG_CACHE_HOME:-$HOME/.cache}/tether"
PROJECT_CONFIG=".tether/project.yaml"

# Source removed - already loaded by main executable

# Load project config
load_config() {
    local stack="none"
    local design_system="none"
    local design_foundation="none"
    
    if [ -f "$PROJECT_CONFIG" ]; then
        # Parse YAML simply using helper
        stack=$(parse_yaml_key "framework" "$PROJECT_CONFIG")
        design_system=$(parse_yaml_key "design_system" "$PROJECT_CONFIG")
        design_foundation=$(parse_yaml_key "styling_foundation" "$PROJECT_CONFIG")
        
        if [ -n "$stack" ]; then
            echo -e "[i] Context: ${C_YELLOW}${stack}${C_NC} | Sys: ${C_YELLOW}${design_system}${C_NC} | Fnd: ${C_YELLOW}${design_foundation}${C_NC}"
        fi
    fi
    
    echo "$stack|$design_system|$design_foundation"
}

# Execute main prompt
execute_prompt() {
    local prompt="$*"
    local config
    config=$(load_config)
    
    # Split config string back to vars
    local stack="${config%%|*}"
    local rest="${config#*|}"
    local design_system="${rest%%|*}"
    local design_foundation="${rest#*|}"
    
    log_step "Processing with Claude"
    
    {
        assemble_context "$stack" "$design_system" "$design_foundation"
        echo "---"
        echo "CURRENT TASK: $prompt"
    } | claude
}

# Show version
show_version() {
    echo "Tether v$VERSION"
    echo "Context Engine for AI Development"
}

# Show help
show_help() {
    cat << EOF
Tether v$VERSION - Context Engine for AI Development

Usage: tether-cli [OPTIONS] "prompt"

Core Commands:
  tether-cli "prompt"               Execute prompt with context
  tether-cli new                    Setup new project (coming soon)
  
Git Commands:
  tether-cli commit                 Commit current changes
  tether-cli rollback [--hard]      Undo last Tether commit
  tether-cli history                Show Tether commit history
  tether-cli diff                   Show current changes
  
Project Commands:
  tether-cli detect                 Re-detect project settings
  tether-cli status                 Show project status
  
Update Commands:
  tether-cli --update-rules         Update knowledge base
  tether-cli --update-tool          Update CLI tool
  
Options:
  --dry-run                         Preview changes only
  --review                          Review before commit
  --no-commit                       Skip git commit
  --auto-commit                     Auto-commit changes
  --version                         Show version
  --help                            Show this help

Examples:
  tether-cli "create login page with validation"
  tether-cli "refactor auth system" --review
  tether-cli rollback --hard
  
Quick Alias Setup:
  Add to ~/.bashrc or ~/.zshrc:
    alias tether='tether-cli'
  
  Then use:
    tether "create component"
    tether detect
    tether rollback

Documentation: https://github.com/na-ive/tether-cli
EOF
}
EOFCORE
}

generate_main_executable() {
    log_step "Generating Main Executable"
    
    cat << 'EOFMAIN' > "$BIN_DIR/$EXECUTABLE_NAME"
#!/bin/bash
set -euo pipefail

# === PATHS ===
LIB_DIR="$HOME/.local/lib/tether"
TETHER_LIB="${XDG_CACHE_HOME:-$HOME/.cache}/tether"
SELF_URL="PUBLIC_INSTALLER_URL_PLACEHOLDER"

# === LOAD MODULES ===
for module in utils ui detect context git core; do
    if [ -f "$LIB_DIR/$module.sh" ]; then
        source "$LIB_DIR/$module.sh"
    else
        echo "Error: Missing module $module.sh"
        exit 1
    fi
done

# === PARSE FLAGS ===
DRY_RUN=false
REVIEW_MODE=false
NO_COMMIT=false
AUTO_COMMIT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --review) REVIEW_MODE=true; shift ;;
        --no-commit) NO_COMMIT=true; shift ;;
        --auto-commit) AUTO_COMMIT=true; shift ;;
        --version) show_version; exit 0 ;;
        --help|-h) show_help; exit 0 ;;
        --update-rules)
            log_info "Updating knowledge base..."
            if [ -d "$TETHER_LIB/.git" ]; then
                cd "$TETHER_LIB" && git pull && log_success "Rules updated"
            else
                log_error "No git repo in $TETHER_LIB"
            fi
            exit 0
            ;;
        --update-tool)
            log_info "Updating tool..."
            TEMP=$(mktemp)
            if curl -fsSL "$SELF_URL" -o "$TEMP"; then
                bash "$TEMP"
            else
                log_error "Update failed"
            fi
            rm -f "$TEMP"
            exit 0
            ;;
        new)
            shift
            log_error "Wizard feature coming in v1.1"
            exit 1
            ;;
        commit)
            shift
            git_commit_changes "$(generate_commit_message)" "$AUTO_COMMIT"
            exit 0
            ;;
        rollback)
            shift
            mode="soft"
            [ "${1:-}" = "--hard" ] && mode="hard" && shift
            git_rollback "$mode"
            exit 0
            ;;
        history)
            git_history
            exit 0
            ;;
        diff)
            git diff --color=always
            exit 0
            ;;
        detect)
            run_project_detection
            exit 0
            ;;
        status)
            load_config
            git status
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# === DRY RUN MODE ===
if [ "$DRY_RUN" = true ]; then
    git_dry_run
    exit 0
fi

# === MAIN EXECUTION ===
USER_PROMPT="$*"
if [ -z "$USER_PROMPT" ]; then
    show_help
    exit 1
fi

# Execute prompt
execute_prompt "$USER_PROMPT"

# Handle git operations
if [ "$NO_COMMIT" = false ] && check_git_repo; then
    if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
        log_info "No changes to commit"
    else
        if [[ "$REVIEW_MODE" == "true" || "$GIT_REQUIRE_REVIEW" == "true" ]]; then
            git_commit_changes "$(generate_commit_message)" false
        elif [[ "$AUTO_COMMIT" == "true" || "$GIT_AUTO_COMMIT" == "true" ]]; then
            git_commit_changes "$(generate_commit_message)" true
        fi
    fi
fi
EOFMAIN

    # Replace placeholders
    sed -i.bak "s|PUBLIC_INSTALLER_URL_PLACEHOLDER|$PUBLIC_INSTALLER_URL|g" "$BIN_DIR/$EXECUTABLE_NAME"
    rm -f "$BIN_DIR/$EXECUTABLE_NAME.bak"
    chmod +x "$BIN_DIR/$EXECUTABLE_NAME"
    log_success "Main executable created"
}

# ==========================================
# CONFIG FILES
# ==========================================

generate_config_files() {
    log_step "Generating Configuration Files"
    
    # Git config
    cat > "$CONFIG_DIR/git.yaml" << EOF
# Git Integration Settings
commit:
  auto: true
  auto_push: false
  require_review: false
  message_template: "{type}({scope}): {description} [tether]"
  protected_files:
    - ".env"
    - ".env.*"
    - "*.key"
    - "*.pem"
    - "secrets.json"
    - "credentials.json"
safety:
  max_file_size: "1MB"
  backup_before_destructive: true
  check_conflicts: true
EOF

    # Context config
    cat > "$CONFIG_DIR/context.yaml" << EOF
# Context Assembly Settings
ignore_patterns:
  - "node_modules/**"
  - ".git/**"
  - "dist/**"
  - "build/**"
  - "*.log"
  - ".next/**"
  - ".nuxt/**"
  - "android/**"
  - "ios/**"
max_context_size: "100KB"
smart_filtering: true
EOF

    log_success "Config files created"
}

# ==========================================
# PATH CHECK
# ==========================================

check_path() {
    log_step "Checking PATH Configuration"
    
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        log_warn "$BIN_DIR not in PATH"
        echo ""
        echo "Add this to your shell config (~/.bashrc or ~/.zshrc):"
        echo ""
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
        echo "Then run: source ~/.bashrc"
    else
        log_success "PATH configured correctly"
    fi
}

# ==========================================
# MAIN INSTALLATION FLOW
# ==========================================

main() {
    show_header
    check_dependencies
    setup_knowledge_base
    create_directories
    
    log_step "Generating Modules"
    generate_utils_module && echo "  [+] utils.sh"
    generate_ui_module && echo "  [+] ui.sh"
    generate_detect_module && echo "  [+] detect.sh"
    generate_context_module && echo "  [+] context.sh"
    generate_git_module && echo "  [+] git.sh"
    generate_core_module && echo "  [+] core.sh"
    
    log_success "All modules generated"
    
    generate_main_executable
    generate_config_files
    check_path
    
    echo ""
    echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║                                       ║${NC}"
    echo -e "${BOLD}${GREEN}║        INSTALLATION COMPLETE!         ║${NC}"
    echo -e "${BOLD}${GREEN}║                                       ║${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Locations:${NC}"
    echo "  * Data:    $CACHE_DIR"
    echo "  * Binary:  $BIN_DIR/$EXECUTABLE_NAME"
    echo "  * Modules: $LIB_DIR"
    echo "  * Config:  $CONFIG_DIR"
    echo ""
    echo -e "${BOLD}Quick Start:${NC}"
    echo "  tether-cli detect                    # Analyze project"
    echo "  tether-cli \"create login page\"       # Start coding"
    echo ""
    echo -e "${BOLD}Pro Tip - Setup Alias:${NC}"
    echo "  Add to ~/.bashrc or ~/.zshrc:"
    echo "    alias tether='tether-cli'"
    echo ""
    echo "  Then use:"
    echo "    tether \"create component\""
    echo "    tether detect"
    echo ""
    echo -e "${BOLD}Learn More:${NC}"
    echo "  tether-cli --help"
    echo "  https://github.com/na-ive/tether-cli"
    echo ""
}

main "$@"