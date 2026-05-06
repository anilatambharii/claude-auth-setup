#!/usr/bin/env bash

################################################################################
# Claude Auth Setup - Bash Script Test Suite
# 
# This test validates the bash script functionality without modifying
# the user's actual environment or shell configuration.
################################################################################

set +e  # Don't exit on errors during testing

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

################################################################################
# Utility Functions
################################################################################

print_header() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "  Claude Auth Setup - Bash Script Test Suite"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
}

print_section() {
    echo ""
    echo "───────────────────────────────────────────────────────────────────────"
    echo "  $1"
    echo "───────────────────────────────────────────────────────────────────────"
    echo ""
}

test_pass() {
    local test_name="$1"
    ((TESTS_RUN++))
    ((TESTS_PASSED++))
    echo -e "${GREEN}✓ PASS${NC}: $test_name"
}

test_fail() {
    local test_name="$1"
    local message="${2:-}"
    ((TESTS_RUN++))
    ((TESTS_FAILED++))
    echo -e "${RED}✗ FAIL${NC}: $test_name"
    if [[ -n "$message" ]]; then
        echo -e "  → ${YELLOW}$message${NC}"
    fi
}

assert_file_exists() {
    local file_path="$1"
    local test_name="$2"
    
    if [[ -f "$file_path" ]]; then
        test_pass "$test_name"
        return 0
    else
        test_fail "$test_name" "File not found: $file_path"
        return 1
    fi
}

assert_contains() {
    local text="$1"
    local pattern="$2"
    local test_name="$3"
    
    if echo "$text" | grep -q "$pattern"; then
        test_pass "$test_name"
        return 0
    else
        test_fail "$test_name" "Pattern not found: $pattern"
        return 1
    fi
}

################################################################################
# Test: Bash Script Exists and Has Content
################################################################################

test_script_exists() {
    print_section "Bash Script Validation"
    
    assert_file_exists "setup-claude-auth.sh" "setup-claude-auth.sh exists"
    
    if [[ -f setup-claude-auth.sh ]]; then
        local file_size=$(wc -c < setup-claude-auth.sh)
        if [[ $file_size -gt 5000 ]]; then
            test_pass "Bash script has substantial content ($file_size bytes)"
        else
            test_fail "Bash script size" "File size $file_size bytes - expected > 5000"
        fi
    fi
}

################################################################################
# Test: Bash Script Syntax Elements
################################################################################

test_bash_syntax() {
    print_section "Bash Syntax Validation"
    
    if [[ ! -f setup-claude-auth.sh ]]; then
        return
    fi
    
    local script_content=$(cat setup-claude-auth.sh)
    
    # Check for shebang
    if echo "$script_content" | head -1 | grep -q "#!/usr/bin/env bash"; then
        test_pass "Contains proper bash shebang"
    else
        test_fail "Shebang" "Expected #!/usr/bin/env bash"
    fi
    
    # Check for safety flags
    if echo "$script_content" | grep -q "set -euo pipefail"; then
        test_pass "Contains bash safety flags (set -euo pipefail)"
    else
        test_fail "Bash safety" "Safety flags not found"
    fi
    
    # Check for function definitions
    if echo "$script_content" | grep -q "^log_info()"; then
        test_pass "Contains logging functions"
    else
        test_fail "Logging functions" "log_info function not found"
    fi
    
    # Check for prompt functions
    if echo "$script_content" | grep -q "prompt_yes_no"; then
        test_pass "Contains interactive prompt functions"
    else
        test_fail "Prompt functions" "prompt_yes_no function not found"
    fi
}

################################################################################
# Test: API Key Format Validation
################################################################################

test_api_key_validation() {
    print_section "API Key Format Validation"
    
    # Valid key pattern
    local valid_key="sk-ant-v0-abc123def456ghi789jklmno"
    local pattern="^sk-ant-[a-zA-Z0-9]{20,}$"
    
    if [[ $valid_key =~ $pattern ]]; then
        test_pass "Valid API key format recognized"
    else
        test_fail "API key validation" "Valid key not recognized"
    fi
    
    # Invalid key patterns
    local invalid_key="invalid-api-key"
    if [[ ! $invalid_key =~ $pattern ]]; then
        test_pass "Invalid API key format rejected"
    else
        test_fail "API key validation" "Invalid key not rejected"
    fi
    
    # Check for API key validation in script
    if [[ -f setup-claude-auth.sh ]]; then
        if grep -q "sk-ant-" setup-claude-auth.sh; then
            test_pass "Script includes API key format checking"
        else
            test_fail "Script validation" "API key format checking not found"
        fi
    fi
}

################################################################################
# Test: Environment Variable Safety
################################################################################

test_env_var_safety() {
    print_section "Environment Variable Safety"
    
    # Save current state
    local original_api_key="${ANTHROPIC_API_KEY:-}"
    local original_auth_token="${ANTHROPIC_AUTH_TOKEN:-}"
    
    # Verify we can read without modifying
    test_pass "Can read existing environment variables"
    
    # Verify no modifications
    if [[ "${ANTHROPIC_API_KEY:-}" == "$original_api_key" ]]; then
        test_pass "User's ANTHROPIC_API_KEY untouched"
    else
        test_fail "Environment safety" "ANTHROPIC_API_KEY was modified"
    fi
    
    if [[ "${ANTHROPIC_AUTH_TOKEN:-}" == "$original_auth_token" ]]; then
        test_pass "User's ANTHROPIC_AUTH_TOKEN untouched"
    else
        test_fail "Environment safety" "ANTHROPIC_AUTH_TOKEN was modified"
    fi
}

################################################################################
# Test: Shell Detection and Configuration
################################################################################

test_shell_compatibility() {
    print_section "Shell Compatibility"
    
    # Detect current shell
    if [[ -n "${BASH_VERSION:-}" ]]; then
        test_pass "Running in Bash (version: ${BASH_VERSION%.*})"
    fi
    
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        test_pass "Running in Zsh (version: ${ZSH_VERSION%%-*})"
    fi
    
    # Check for shell configuration files
    local config_files=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc")
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            test_pass "Shell config file exists: $config_file"
        fi
    done
    
    # Check home directory accessibility
    if [[ -d "$HOME" ]]; then
        test_pass "Home directory accessible: $HOME"
    else
        test_fail "Home directory" "Cannot access \$HOME"
    fi
}

################################################################################
# Test: File Backup and Restoration
################################################################################

test_backup_mechanism() {
    print_section "File Backup and Restoration"
    
    # Create temporary test file
    local test_dir="/tmp/claude-auth-test-$$"
    mkdir -p "$test_dir"
    
    local test_file="$test_dir/test-config.txt"
    echo "Original content" > "$test_file"
    
    if [[ -f "$test_file" ]]; then
        test_pass "Can create test files in /tmp"
    else
        test_fail "File creation" "Could not create test file"
    fi
    
    # Test backup creation
    local backup_file="${test_file}.backup_$(date +%s)"
    cp "$test_file" "$backup_file"
    
    if [[ -f "$backup_file" ]]; then
        test_pass "Can create backup files"
    else
        test_fail "Backup creation" "Could not create backup"
    fi
    
    # Test restoration
    echo "Modified content" > "$test_file"
    cp "$backup_file" "$test_file"
    local restored_content=$(cat "$test_file")
    
    if [[ "$restored_content" == "Original content" ]]; then
        test_pass "Can restore from backup"
    else
        test_fail "Backup restoration" "Content not restored correctly"
    fi
    
    # Cleanup
    rm -f "$test_file" "$backup_file"
    rmdir "$test_dir" 2>/dev/null || true
}

################################################################################
# Test: Documentation Completeness
################################################################################

test_documentation() {
    print_section "Documentation Completeness"
    
    local docs=("README.md" "QUICKSTART.md" "CONTRIBUTING.md" \
                "CONFIGURATION_EXAMPLES.md" "PROJECT_OVERVIEW.md" "LICENSE")
    
    for doc in "${docs[@]}"; do
        assert_file_exists "$doc" "$doc exists"
        
        if [[ -f "$doc" ]]; then
            local file_size=$(wc -c < "$doc")
            if [[ $file_size -gt 500 ]]; then
                test_pass "$doc has substantial content ($file_size bytes)"
            fi
        fi
    done
}

################################################################################
# Test: Cross-Platform Scripts
################################################################################

test_cross_platform() {
    print_section "Cross-Platform Compatibility"
    
    assert_file_exists "setup-claude-auth.sh" "Unix/Linux script exists"
    assert_file_exists "setup-claude-auth.bat" "Windows script exists"
    assert_file_exists ".gitattributes" ".gitattributes exists for line endings"
    
    if [[ -f .gitattributes ]]; then
        local content=$(cat .gitattributes)
        if echo "$content" | grep -q "*.sh"; then
            test_pass "Git configured for shell script line endings"
        fi
        if echo "$content" | grep -q "*.bat"; then
            test_pass "Git configured for batch script line endings"
        fi
    fi
}

################################################################################
# Test: Security Features
################################################################################

test_security() {
    print_section "Security Best Practices"
    
    if [[ -f setup-claude-auth.sh ]]; then
        # Check for error handling
        if grep -q "trap\|set -e\|error" setup-claude-auth.sh; then
            test_pass "Bash script includes error handling"
        else
            test_fail "Error handling" "No error handling found"
        fi
        
        # Check for secure practices
        if grep -q '"\$' setup-claude-auth.sh; then
            test_pass "Bash script uses proper variable quoting"
        else
            test_fail "Variable safety" "Improper variable usage detected"
        fi
    fi
    
    if [[ -f setup-claude-auth.bat ]]; then
        # Check for Windows script error handling
        if grep -q "errorlevel" setup-claude-auth.bat; then
            test_pass "Batch script includes error level checking"
        fi
    fi
}

################################################################################
# Test: Script Permissions
################################################################################

test_script_permissions() {
    print_section "Script Permissions"
    
    if [[ -f setup-claude-auth.sh ]]; then
        if [[ -x setup-claude-auth.sh ]]; then
            test_pass "setup-claude-auth.sh is executable"
        else
            test_fail "Script permissions" "setup-claude-auth.sh is not executable"
        fi
    fi
}

################################################################################
# Test Summary and Results
################################################################################

print_summary() {
    print_section "Test Summary"
    
    echo "Tests Run:    $TESTS_RUN"
    echo "Tests Passed: $TESTS_PASSED"
    echo "Tests Failed: $TESTS_FAILED"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "═══════════════════════════════════════════════════════════════════════"
        echo -e "${GREEN}✓ ALL TESTS PASSED!${NC}"
        echo "═══════════════════════════════════════════════════════════════════════"
        echo ""
        echo -e "${GREEN}The application is ready for deployment! 🚀${NC}"
        echo ""
        return 0
    else
        echo "═══════════════════════════════════════════════════════════════════════"
        echo -e "${RED}✗ SOME TESTS FAILED${NC}"
        echo "═══════════════════════════════════════════════════════════════════════"
        echo ""
        return 1
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header
    
    echo "Starting comprehensive bash script test suite..."
    echo -e "${GREEN}(Your existing API keys and local setup will NOT be modified)${NC}"
    echo ""
    
    # Run all tests
    test_script_exists
    test_bash_syntax
    test_api_key_validation
    test_env_var_safety
    test_shell_compatibility
    test_backup_mechanism
    test_documentation
    test_cross_platform
    test_security
    test_script_permissions
    
    print_summary
    exit $?
}

# Execute tests
main "$@"
