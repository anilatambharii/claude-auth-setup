@echo off
setlocal enabledelayedexpansion

REM ############################################################################
REM Claude Code Authentication Setup Script
REM 
REM Purpose: Interactive setup for Claude Code authentication when enterprise
REM          subscription is not available. Supports API key configuration
REM          with secure environment variable management.
REM
REM Platform: Windows 10/11, Windows Server
REM Author: Ambharii Technologies LLC
REM License: MIT
REM Version: 1.0.0
REM
REM Usage:
REM   setup-claude-auth.bat
REM
REM ############################################################################

set "SCRIPT_VERSION=1.0.0"
set "ANTHROPIC_CONSOLE_URL=https://console.anthropic.com"
set "CLAUDE_AI_URL=https://claude.ai"
set "DOCS_URL=https://docs.claude.com/en/docs/claude-code/overview"

REM ############################################################################
REM Color Configuration (Windows 10+)
REM ############################################################################

REM Check if running in Windows Terminal or modern console
for /f "tokens=4-5 delims=. " %%i in ('ver') do set "VERSION=%%i.%%j"
if "%VERSION%" geq "10.0" (
    set "SUPPORTS_COLOR=1"
) else (
    set "SUPPORTS_COLOR=0"
)

REM ############################################################################
REM Utility Functions
REM ############################################################################

:print_header
echo.
echo ========================================================================
echo   Claude Code Authentication Setup v%SCRIPT_VERSION%
echo ========================================================================
echo.
goto :eof

:print_section
echo.
echo ------------------------------------------------------------------------
echo   %~1
echo ------------------------------------------------------------------------
echo.
goto :eof

:log_info
echo [INFO] %~1
goto :eof

:log_success
echo [SUCCESS] %~1
goto :eof

:log_warning
echo [WARNING] %~1
goto :eof

:log_error
echo [ERROR] %~1
goto :eof

:prompt_yes_no
set "prompt_text=%~1"
:prompt_yes_no_loop
set /p "response=%prompt_text% (y/n): "
if /i "!response!"=="y" set "%~2=1" & goto :eof
if /i "!response!"=="yes" set "%~2=1" & goto :eof
if /i "!response!"=="n" set "%~2=0" & goto :eof
if /i "!response!"=="no" set "%~2=0" & goto :eof
echo Please answer yes or no.
goto prompt_yes_no_loop

:prompt_input
set "prompt_text=%~1"
set "var_name=%~2"
set "default_value=%~3"

if not "!default_value!"=="" (
    set /p "response=%prompt_text% [!default_value!]: "
    if "!response!"=="" set "response=!default_value!"
) else (
    set /p "response=%prompt_text%: "
)

set "%var_name%=!response!"
goto :eof

REM ############################################################################
REM Detection Functions
REM ############################################################################

:check_existing_credentials
set "found_credentials=0"

if defined ANTHROPIC_API_KEY (
    call :log_info "Found: ANTHROPIC_API_KEY (currently set)"
    set "found_credentials=1"
)

if defined ANTHROPIC_AUTH_TOKEN (
    call :log_info "Found: ANTHROPIC_AUTH_TOKEN (currently set)"
    set "found_credentials=1"
)

if defined CLAUDE_CODE_OAUTH_TOKEN (
    call :log_info "Found: CLAUDE_CODE_OAUTH_TOKEN (currently set)"
    set "found_credentials=1"
)

set "%~1=!found_credentials!"
goto :eof

:check_claude_code_installed
where claude >nul 2>&1
if %errorlevel%==0 (
    set "%~1=1"
) else (
    set "%~1=0"
)
goto :eof

:check_node_installed
where node >nul 2>&1
if %errorlevel%==0 (
    set "%~1=1"
) else (
    set "%~1=0"
)
goto :eof

:check_npm_installed
where npm >nul 2>&1
if %errorlevel%==0 (
    set "%~1=1"
) else (
    set "%~1=0"
)
goto :eof

REM ############################################################################
REM Configuration Functions
REM ############################################################################

:set_user_env_variable
set "var_name=%~1"
set "var_value=%~2"

REM Set for current session
set "%var_name%=%var_value%"

REM Set permanently using setx
setx %var_name% "%var_value%" >nul 2>&1
if %errorlevel%==0 (
    call :log_success "Set %var_name% in user environment variables"
) else (
    call :log_error "Failed to set %var_name% permanently"
    call :log_warning "Variable is set for current session only"
)

goto :eof

:remove_user_env_variable
set "var_name=%~1"

REM Clear from current session
set "%var_name%="

REM Remove from registry
reg delete "HKCU\Environment" /v %var_name% /f >nul 2>&1
if %errorlevel%==0 (
    call :log_success "Removed %var_name% from user environment variables"
) else (
    call :log_info "%var_name% not found in user environment variables"
)

goto :eof

REM ############################################################################
REM Main Workflow Functions
REM ############################################################################

:show_welcome
call :print_header

echo This script helps you configure Claude Code authentication when you don't
echo have an enterprise Claude subscription.
echo.
echo Claude Code Authentication Priority Order:
echo   1. Cloud provider credentials (Bedrock, Vertex AI, Foundry)
echo   2. ANTHROPIC_AUTH_TOKEN (for LLM gateways/proxies)
echo   3. ANTHROPIC_API_KEY (for direct API access)
echo   4. apiKeyHelper (custom credential scripts)
echo   5. CLAUDE_CODE_OAUTH_TOKEN (from 'claude setup-token')
echo   6. Subscription OAuth (from '/login' in Claude Code)
echo.
echo This script will help you configure ANTHROPIC_API_KEY for direct API access.
echo.

call :log_info "Press Enter to continue..."
pause >nul

goto :eof

:check_subscription_status
call :print_section "Subscription Status Check"

echo Do you have any of the following Claude subscriptions?
echo   * Claude Pro
echo   * Claude Max
echo   * Claude for Teams
echo   * Claude for Enterprise
echo.

call :prompt_yes_no "Do you have a Claude subscription?" has_subscription

if "!has_subscription!"=="1" (
    call :print_section "Subscription Login Instructions"
    
    echo Great! You can use your subscription to authenticate Claude Code.
    echo.
    echo Steps:
    echo   1. Run: claude
    echo   2. When prompted, select "Claude.ai" as your login method
    echo   3. A browser will open for authentication
    echo   4. Sign in with your Claude.ai credentials
    echo   5. Return to terminal to confirm connection
    echo.
    echo Important: Make sure ANTHROPIC_API_KEY is NOT set in your environment,
    echo as it takes precedence over subscription authentication.
    echo.
    
    call :check_existing_credentials has_credentials
    
    if "!has_credentials!"=="1" (
        echo.
        call :prompt_yes_no "Do you want to remove existing credentials to use subscription login?" remove_creds
        
        if "!remove_creds!"=="1" (
            if defined ANTHROPIC_API_KEY call :remove_user_env_variable "ANTHROPIC_API_KEY"
            if defined ANTHROPIC_AUTH_TOKEN call :remove_user_env_variable "ANTHROPIC_AUTH_TOKEN"
            if defined CLAUDE_CODE_OAUTH_TOKEN call :remove_user_env_variable "CLAUDE_CODE_OAUTH_TOKEN"
            call :log_success "Removed conflicting credentials"
        )
    )
    
    call :log_info "You can now run 'claude' to start Claude Code with your subscription"
    set "%~1=1"
) else (
    set "%~1=0"
)

goto :eof

:setup_api_key
call :print_section "API Key Setup"

echo To use Claude Code without a subscription, you'll need an API key from
echo the Anthropic Console.
echo.
echo Steps to get your API key:
echo   1. Visit: %ANTHROPIC_CONSOLE_URL%
echo   2. Sign in or create an account
echo   3. Navigate to "API Keys" section
echo   4. Click "Create Key"
echo   5. Copy your API key (it starts with 'sk-ant-')
echo   6. Add billing credits to your account
echo.

call :prompt_yes_no "Do you have your API key ready?" has_key

if "!has_key!"=="0" (
    call :log_info "Please get your API key first, then run this script again"
    echo.
    call :log_info "Opening Anthropic Console in browser..."
    start "" "%ANTHROPIC_CONSOLE_URL%"
    exit /b 0
)

set /p "api_key=Enter your Anthropic API key: "

REM Validate API key format
echo !api_key! | findstr /r "^sk-ant-" >nul
if !errorlevel! neq 0 (
    call :log_error "Invalid API key format. Anthropic API keys start with 'sk-ant-'"
    exit /b 1
)

REM Configure environment variable
call :set_user_env_variable "ANTHROPIC_API_KEY" "!api_key!"

call :log_success "API key configured successfully!"

goto :eof

:verify_installation
call :print_section "Installation Verification"

call :check_claude_code_installed is_installed

if "!is_installed!"=="0" (
    call :log_warning "Claude Code is not installed on this system"
    echo.
    echo To install Claude Code:
    echo   npm install -g @anthropic-ai/claude-code
    echo.
    echo For more information, visit:
    echo   %DOCS_URL%
    echo.
    
    call :prompt_yes_no "Do you want to install Claude Code now?" install_now
    
    if "!install_now!"=="1" (
        call :check_npm_installed has_npm
        
        if "!has_npm!"=="1" (
            call :log_info "Installing Claude Code..."
            npm install -g @anthropic-ai/claude-code
            
            if !errorlevel!==0 (
                call :log_success "Claude Code installed successfully!"
            ) else (
                call :log_error "Installation failed"
                exit /b 1
            )
        ) else (
            call :log_error "npm is not installed. Please install Node.js first."
            echo Visit: https://nodejs.org
            exit /b 1
        )
    ) else (
        call :log_info "Skipping installation"
    )
) else (
    call :log_success "Claude Code is already installed"
)

goto :eof

:test_configuration
call :print_section "Configuration Test"

call :check_claude_code_installed is_installed

if "!is_installed!"=="0" (
    call :log_warning "Claude Code not installed. Skipping test."
    goto :eof
)

call :log_info "Testing configuration..."
echo.

echo Current authentication status:
if defined ANTHROPIC_API_KEY (
    echo   ANTHROPIC_API_KEY: [SET]
) else (
    echo   ANTHROPIC_API_KEY: [NOT SET]
)

if defined ANTHROPIC_AUTH_TOKEN (
    echo   ANTHROPIC_AUTH_TOKEN: [SET]
) else (
    echo   ANTHROPIC_AUTH_TOKEN: [NOT SET]
)

if defined CLAUDE_CODE_OAUTH_TOKEN (
    echo   CLAUDE_CODE_OAUTH_TOKEN: [SET]
) else (
    echo   CLAUDE_CODE_OAUTH_TOKEN: [NOT SET]
)

echo.

if defined ANTHROPIC_API_KEY (
    call :log_success "API key is configured in your environment"
    echo.
    call :log_info "To verify authentication, run:"
    echo   claude
    echo.
    call :log_info "Then in Claude Code, run:"
    echo   /status
    echo.
    call :log_info "This will show which authentication method is active."
) else (
    call :log_warning "No credentials found in current environment"
    echo.
    call :log_info "You may need to:"
    echo   1. Close and reopen this command prompt window, OR
    echo   2. Log out and log back in to Windows
    echo.
    call :log_info "This ensures the new environment variables are loaded."
)

goto :eof

:show_next_steps
call :print_section "Next Steps"

echo Configuration complete! Here's what to do next:
echo.
echo 1. RELOAD YOUR ENVIRONMENT
echo    Close this window and open a NEW command prompt or PowerShell window
echo    to load the updated environment variables.
echo.
echo 2. START CLAUDE CODE
echo    claude
echo.
echo 3. VERIFY AUTHENTICATION
echo    Inside Claude Code, run:
echo    /status
echo.
echo    This shows which authentication method is active and your account details.
echo.
echo 4. MONITOR USAGE
echo    If using API billing, monitor your usage at:
echo    %ANTHROPIC_CONSOLE_URL%
echo.
echo    Heavy sessions can use significant tokens. Use /usage in Claude Code
echo    to check token consumption for the current session.
echo.
echo 5. TROUBLESHOOTING
echo    If you encounter issues:
echo    * Check /status to see which credential is active
echo    * Run /logout and /login to re-authenticate
echo    * Verify your API key at %ANTHROPIC_CONSOLE_URL%
echo    * Check the docs at %DOCS_URL%
echo.
echo IMPORTANT NOTES:
echo * API key authentication uses pay-as-you-go billing (not subscription credits)
echo * Environment variables take precedence over subscription authentication
echo * To switch to subscription: remove ANTHROPIC_API_KEY and run /login
echo.

call :log_success "Setup completed successfully!"

goto :eof

:show_advanced_options
call :print_section "Advanced Configuration Options"

echo Additional configuration options available:
echo.
echo 1. OAUTH TOKEN (for CI/CD pipelines)
echo    Generate a long-lived OAuth token:
echo    claude setup-token
echo.
echo    Then set: setx CLAUDE_CODE_OAUTH_TOKEN "your-token"
echo.
echo 2. CUSTOM CREDENTIAL HELPER
echo    For dynamic credential management, configure apiKeyHelper in
echo    Claude Code settings to call a custom script that outputs your API key.
echo.
echo 3. CLOUD PROVIDER AUTHENTICATION
echo    For AWS Bedrock, Google Vertex AI, or Microsoft Foundry:
echo    * Set provider-specific environment variables
echo    * No browser login needed
echo    * Refer to provider documentation for setup
echo.
echo 4. LLM GATEWAY/PROXY
echo    For custom LLM gateways or proxies:
echo    setx ANTHROPIC_AUTH_TOKEN "your-bearer-token"
echo.
echo For more information, visit: %DOCS_URL%
echo.

goto :eof

REM ############################################################################
REM Main Function
REM ############################################################################

:main

REM Show welcome screen
call :show_welcome

REM Check for existing installation
call :verify_installation

REM Check subscription status
call :check_subscription_status has_subscription

if "!has_subscription!"=="0" (
    REM No subscription - set up API key
    call :setup_api_key
)

REM Test configuration
call :test_configuration

REM Show advanced options
echo.
call :prompt_yes_no "Would you like to see advanced configuration options?" show_advanced

if "!show_advanced!"=="1" (
    call :show_advanced_options
)

REM Show next steps
call :show_next_steps

echo.
call :log_success "All done! Happy coding with Claude!"
echo.

pause
exit /b 0

REM ############################################################################
REM Entry Point
REM ############################################################################

call :main
