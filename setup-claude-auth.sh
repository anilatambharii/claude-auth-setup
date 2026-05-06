#!/usr/bin/env bash

################################################################################
# Claude Code Authentication Setup Script
# 
# Purpose: Interactive setup for Claude Code authentication when enterprise
#          subscription is not available. Supports API key configuration
#          with secure environment variable management.
#
# Platform: macOS, Linux, WSL
# Author: Ambharii Technologies LLC
# License: MIT
# Version: 1.0.0
#
# Usage:
#   chmod +x setup-claude-auth.sh
#   ./setup-claude-auth.sh
#
################################################################################

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_VERSION="1.0.0"
readonly ANTHROPIC_CONSOLE_URL="https://console.anthropic.com"
readonly CLAUDE_AI_URL="https://claude.ai"
readonly DOCS_URL="https://docs.claude.com/en/docs/claude-code/overview"

################################################################################
# Utility Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "  Claude Code Authentication Setup v${SCRIPT_VERSION}"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
}

print_section() {
    echo ""
    echo "─────────────────────────────────────────────────────────────────────"
    echo "  $1"
    echo "─────────────────────────────────────────────────────────────────────"
    echo ""
}

prompt_yes_no() {
    local prompt="$1"
    local response
    
    while true; do
        read -p "${prompt} (y/n): " response
        case "${response,,}" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

prompt_input() {
    local prompt="$1"
    local variable_name="$2"
    local default_value="${3:-}"
    local response
    
    if [[ -n "$default_value" ]]; then
        read -p "${prompt} [${default_value}]: " response
        response="${response:-$default_value}"
    else
        read -p "${prompt}: " response
    fi
    
    eval "$variable_name='$response'"
}

prompt_secure_input() {
    local prompt="$1"
    local variable_name="$2"
    local response
    
    read -s -p "${prompt}: " response
    echo ""
    eval "$variable_name='$response'"
}

################################################################################
# Detection Functions
################################################################################

detect_shell() {
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        echo "zsh"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

get_shell_config_file() {
    local shell_type
    shell_type=$(detect_shell)
    
    case "$shell_type" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        *)
            log_warning "Unknown shell. Using ~/.profile"
            echo "$HOME/.profile"
            ;;
    esac
}

check_existing_credentials() {
    local found_credentials=()
    
    if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
        found_credentials+=("ANTHROPIC_API_KEY (currently set)")
    fi
    
    if [[ -n "${ANTHROPIC_AUTH_TOKEN:-}" ]]; then
        found_credentials+=("ANTHROPIC_AUTH_TOKEN (currently set)")
    fi
    
    if [[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
        found_credentials+=("CLAUDE_CODE_OAUTH_TOKEN (currently set)")
    fi
    
    if [[ ${#found_credentials[@]} -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

get_existing_credentials_list() {
    local credentials=()
    
    if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
        credentials+=("ANTHROPIC_API_KEY")
    fi
    
    if [[ -n "${ANTHROPIC_AUTH_TOKEN:-}" ]]; then
        credentials+=("ANTHROPIC_AUTH_TOKEN")
    fi
    
    if [[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
        credentials+=("CLAUDE_CODE_OAUTH_TOKEN")
    fi
    
    printf '%s\n' "${credentials[@]}"
}

check_claude_code_installed() {
    if command -v claude &> /dev/null; then
        return 0
    else
        return 1
    fi
}

################################################################################
# Configuration Functions
################################################################################

backup_shell_config() {
    local config_file="$1"
    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "$config_file" ]]; then
        cp "$config_file" "$backup_file"
        log_success "Backed up existing config to: $backup_file"
    fi
}

add_env_variable() {
    local var_name="$1"
    local var_value="$2"
    local config_file
    config_file=$(get_shell_config_file)
    
    # Create backup
    backup_shell_config "$config_file"
    
    # Check if variable already exists in config
    if grep -q "export ${var_name}=" "$config_file" 2>/dev/null; then
        log_warning "Variable $var_name already exists in $config_file"
        if prompt_yes_no "Do you want to replace it?"; then
            # Remove old line
            sed -i.tmp "/export ${var_name}=/d" "$config_file"
            rm -f "${config_file}.tmp"
        else
            log_info "Skipping $var_name configuration"
            return 0
        fi
    fi
    
    # Add new variable
    echo "" >> "$config_file"
    echo "# Claude Code API Key (added by setup-claude-auth.sh on $(date))" >> "$config_file"
    echo "export ${var_name}=\"${var_value}\"" >> "$config_file"
    
    log_success "Added $var_name to $config_file"
}

remove_env_variable() {
    local var_name="$1"
    local config_file
    config_file=$(get_shell_config_file)
    
    if [[ ! -f "$config_file" ]]; then
        log_warning "Config file $config_file does not exist"
        return 0
    fi
    
    if grep -q "export ${var_name}=" "$config_file"; then
        backup_shell_config "$config_file"
        sed -i.tmp "/export ${var_name}=/d" "$config_file"
        rm -f "${config_file}.tmp"
        log_success "Removed $var_name from $config_file"
    else
        log_info "$var_name not found in $config_file"
    fi
}

################################################################################
# Main Workflow Functions
################################################################################

show_welcome() {
    print_header
    
    cat << EOF
This script helps you configure Claude Code authentication when you don't
have an enterprise Claude subscription.

Claude Code Authentication Priority Order:
  1. Cloud provider credentials (Bedrock, Vertex AI, Foundry)
  2. ANTHROPIC_AUTH_TOKEN (for LLM gateways/proxies)
  3. ANTHROPIC_API_KEY (for direct API access)
  4. apiKeyHelper (custom credential scripts)
  5. CLAUDE_CODE_OAUTH_TOKEN (from 'claude setup-token')
  6. Subscription OAuth (from '/login' in Claude Code)

This script will help you configure ANTHROPIC_API_KEY for direct API access.

EOF

    log_info "Press Enter to continue..."
    read -r
}

check_subscription_status() {
    print_section "Subscription Status Check"
    
    echo "Do you have any of the following Claude subscriptions?"
    echo "  • Claude Pro"
    echo "  • Claude Max"
    echo "  • Claude for Teams"
    echo "  • Claude for Enterprise"
    echo ""
    
    if prompt_yes_no "Do you have a Claude subscription?"; then
        print_section "Subscription Login Instructions"
        
        cat << EOF
Great! You can use your subscription to authenticate Claude Code.

Steps:
  1. Run: claude
  2. When prompted, select "Claude.ai" as your login method
  3. A browser will open for authentication
  4. Sign in with your Claude.ai credentials
  5. Return to terminal to confirm connection

Important: Make sure ANTHROPIC_API_KEY is NOT set in your environment,
as it takes precedence over subscription authentication.

EOF
        
        if check_existing_credentials; then
            log_warning "Found existing credentials in environment:"
            get_existing_credentials_list | while read -r cred; do
                echo "  • $cred"
            done
            echo ""
            
            if prompt_yes_no "Do you want to remove these to use subscription login?"; then
                for cred in $(get_existing_credentials_list); do
                    remove_env_variable "$cred"
                    unset "$cred"
                done
                log_success "Removed conflicting credentials"
            fi
        fi
        
        log_info "You can now run 'claude' to start Claude Code with your subscription"
        return 0
    else
        return 1
    fi
}

setup_api_key() {
    print_section "API Key Setup"
    
    cat << EOF
To use Claude Code without a subscription, you'll need an API key from
the Anthropic Console.

Steps to get your API key:
  1. Visit: ${ANTHROPIC_CONSOLE_URL}
  2. Sign in or create an account
  3. Navigate to "API Keys" section
  4. Click "Create Key"
  5. Copy your API key (it starts with 'sk-ant-')
  6. Add billing credits to your account

EOF
    
    if ! prompt_yes_no "Do you have your API key ready?"; then
        log_info "Please get your API key first, then run this script again"
        echo ""
        log_info "Opening Anthropic Console in browser..."
        
        # Try to open browser
        if command -v open &> /dev/null; then
            open "$ANTHROPIC_CONSOLE_URL"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$ANTHROPIC_CONSOLE_URL"
        else
            log_info "Please visit: $ANTHROPIC_CONSOLE_URL"
        fi
        
        exit 0
    fi
    
    local api_key
    prompt_secure_input "Enter your Anthropic API key" api_key
    
    # Validate API key format
    if [[ ! "$api_key" =~ ^sk-ant- ]]; then
        log_error "Invalid API key format. Anthropic API keys start with 'sk-ant-'"
        exit 1
    fi
    
    # Configure environment variable
    add_env_variable "ANTHROPIC_API_KEY" "$api_key"
    
    # Set for current session
    export ANTHROPIC_API_KEY="$api_key"
    
    log_success "API key configured successfully!"
}

verify_installation() {
    print_section "Installation Verification"
    
    if ! check_claude_code_installed; then
        log_warning "Claude Code is not installed on this system"
        echo ""
        echo "To install Claude Code:"
        echo "  npm install -g @anthropic-ai/claude-code"
        echo ""
        echo "For more information, visit:"
        echo "  $DOCS_URL"
        echo ""
        
        if prompt_yes_no "Do you want to install Claude Code now?"; then
            if command -v npm &> /dev/null; then
                log_info "Installing Claude Code..."
                npm install -g @anthropic-ai/claude-code
                log_success "Claude Code installed successfully!"
            else
                log_error "npm is not installed. Please install Node.js first."
                echo "Visit: https://nodejs.org"
                exit 1
            fi
        else
            log_info "Skipping installation"
        fi
    else
        log_success "Claude Code is already installed"
    fi
}

test_configuration() {
    print_section "Configuration Test"
    
    if ! check_claude_code_installed; then
        log_warning "Claude Code not installed. Skipping test."
        return 0
    fi
    
    log_info "Testing configuration..."
    echo ""
    
    # Source the config file to get latest environment
    local config_file
    config_file=$(get_shell_config_file)
    
    if [[ -f "$config_file" ]]; then
        # shellcheck disable=SC1090
        source "$config_file"
    fi
    
    cat << EOF
Current authentication status:
  ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:+[SET]} ${ANTHROPIC_API_KEY:-[NOT SET]}
  ANTHROPIC_AUTH_TOKEN: ${ANTHROPIC_AUTH_TOKEN:+[SET]} ${ANTHROPIC_AUTH_TOKEN:-[NOT SET]}
  CLAUDE_CODE_OAUTH_TOKEN: ${CLAUDE_CODE_OAUTH_TOKEN:+[SET]} ${CLAUDE_CODE_OAUTH_TOKEN:-[NOT SET]}

EOF
    
    if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
        log_success "API key is configured in your environment"
        echo ""
        log_info "To verify authentication, run:"
        echo "  claude"
        echo ""
        log_info "Then in Claude Code, run:"
        echo "  /status"
        echo ""
        log_info "This will show which authentication method is active."
    else
        log_warning "No credentials found in current environment"
        echo ""
        log_info "You may need to:"
        echo "  1. Open a new terminal window, OR"
        echo "  2. Run: source $(get_shell_config_file)"
    fi
}

show_next_steps() {
    print_section "Next Steps"
    
    cat << EOF
Configuration complete! Here's what to do next:

1. RELOAD YOUR SHELL CONFIGURATION
   Run one of these commands in your terminal:
   
   ${GREEN}source $(get_shell_config_file)${NC}
   
   OR open a new terminal window

2. START CLAUDE CODE
   ${GREEN}claude${NC}
   
3. VERIFY AUTHENTICATION
   Inside Claude Code, run:
   ${GREEN}/status${NC}
   
   This shows which authentication method is active and your account details.

4. MONITOR USAGE
   If using API billing, monitor your usage at:
   ${ANTHROPIC_CONSOLE_URL}
   
   Heavy sessions can use significant tokens. Use ${GREEN}/usage${NC} in Claude Code
   to check token consumption for the current session.

5. TROUBLESHOOTING
   If you encounter issues:
   • Check /status to see which credential is active
   • Run /logout and /login to re-authenticate
   • Verify your API key at ${ANTHROPIC_CONSOLE_URL}
   • Check the docs at ${DOCS_URL}

IMPORTANT NOTES:
• API key authentication uses pay-as-you-go billing (not subscription credits)
• Environment variables take precedence over subscription authentication
• To switch to subscription: unset ANTHROPIC_API_KEY and run /login

EOF

    log_success "Setup completed successfully!"
}

show_advanced_options() {
    print_section "Advanced Configuration Options"
    
    cat << EOF
Additional configuration options available:

1. OAUTH TOKEN (for CI/CD pipelines)
   Generate a long-lived OAuth token:
   ${GREEN}claude setup-token${NC}
   
   Then set: export CLAUDE_CODE_OAUTH_TOKEN="your-token"

2. CUSTOM CREDENTIAL HELPER
   For dynamic credential management, configure apiKeyHelper in
   Claude Code settings to call a custom script that outputs your API key.

3. CLOUD PROVIDER AUTHENTICATION
   For AWS Bedrock, Google Vertex AI, or Microsoft Foundry:
   • Set provider-specific environment variables
   • No browser login needed
   • Refer to provider documentation for setup

4. LLM GATEWAY/PROXY
   For custom LLM gateways or proxies:
   ${GREEN}export ANTHROPIC_AUTH_TOKEN="your-bearer-token"${NC}

For more information, visit: ${DOCS_URL}

EOF
}

cleanup_and_exit() {
    echo ""
    log_info "Setup cancelled by user"
    exit 0
}

################################################################################
# Main Function
################################################################################

main() {
    # Set up trap for clean exit
    trap cleanup_and_exit INT TERM
    
    # Show welcome screen
    show_welcome
    
    # Check for existing installation
    verify_installation
    
    # Check subscription status
    if ! check_subscription_status; then
        # No subscription - set up API key
        setup_api_key
    fi
    
    # Test configuration
    test_configuration
    
    # Show advanced options
    echo ""
    if prompt_yes_no "Would you like to see advanced configuration options?"; then
        show_advanced_options
    fi
    
    # Show next steps
    show_next_steps
    
    echo ""
    log_success "All done! Happy coding with Claude!"
    echo ""
}

################################################################################
# Entry Point
################################################################################

main "$@"
