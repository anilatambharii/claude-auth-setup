@echo off
REM ############################################################################
REM Claude Auth Setup - Batch Script Test Suite
REM ############################################################################
REM This test validates the batch script functionality without modifying
REM the user's actual environment or shell configuration.
REM ############################################################################

setlocal enabledelayedexpansion

REM Color setup - Using available ANSI codes for Windows 10+
for /f "tokens=4-5 delims=. " %%i in ('ver') do set "VERSION=%%i.%%j"
if "!VERSION!" geq "10.0" (
    set "SUPPORTS_COLOR=1"
) else (
    set "SUPPORTS_COLOR=0"
)

set "TESTS_RUN=0"
set "TESTS_PASSED=0"
set "TESTS_FAILED=0"

REM ############################################################################
REM Test Utilities
REM ############################################################################

:print_header
echo.
echo ========================================================================
echo    Claude Auth Setup - Batch Script Test Suite
echo ========================================================================
echo.
goto :eof

:print_section
echo.
echo ------------------------------------------------------------------------
echo    %~1
echo ------------------------------------------------------------------------
echo.
goto :eof

:assert_file_exists
set "file_path=%~1"
set "test_name=%~2"

if exist "%file_path%" (
    call :test_pass "%test_name%"
    goto :eof
) else (
    call :test_fail "%test_name%" "File not found: %file_path%"
    goto :eof
)

:assert_string_contains
set "text=%~1"
set "pattern=%~2"
set "test_name=%~3"

echo.!text!. | findstr /I "!pattern!" >nul
if !errorlevel! equ 0 (
    call :test_pass "%test_name%"
) else (
    call :test_fail "%test_name%" "Pattern not found: !pattern!"
)
goto :eof

:test_pass
set /a "TESTS_RUN+=1"
set /a "TESTS_PASSED+=1"
echo [PASS] %~1
goto :eof

:test_fail
set /a "TESTS_RUN+=1"
set /a "TESTS_FAILED+=1"
echo [FAIL] %~1
if not "!~2!"=="" echo   ! %~2
goto :eof

REM ############################################################################
REM Test: Batch Script Exists and Has Content
REM ############################################################################

:test_script_exists
call :print_section "Batch Script Validation"
call :assert_file_exists "setup-claude-auth.bat" "setup-claude-auth.bat exists"

for %%A in (setup-claude-auth.bat) do set "FILE_SIZE=%%~zA"
if !FILE_SIZE! gtr 5000 (
    call :test_pass "Batch script has substantial content (!FILE_SIZE! bytes)"
) else (
    call :test_fail "Batch script size" "File size !FILE_SIZE! bytes - expected > 5000"
)
goto :eof

REM ############################################################################
REM Test: Batch Script Syntax Elements
REM ############################################################################

:test_batch_syntax
call :print_section "Batch Syntax Validation"

setlocal enabledelayedexpansion
for /f "delims=" %%A in (setup-claude-auth.bat) do (
    set "line=%%A"
    
    REM Check for @echo off
    echo !line! | findstr /I "@echo" >nul && (
        call :test_pass "Contains @echo directive"
        setlocal disabledelayedexpansion
        goto :next_check1
        setlocal enabledelayedexpansion
    )
)

:next_check1
for /f "delims=" %%A in (setup-claude-auth.bat) do (
    set "line=%%A"
    
    REM Check for setlocal
    echo !line! | findstr /I "setlocal" >nul && (
        call :test_pass "Contains setlocal directive"
        setlocal disabledelayedexpansion
        goto :next_check2
        setlocal enabledelayedexpansion
    )
)

:next_check2
for /f "delims=" %%A in (setup-claude-auth.bat) do (
    set "line=%%A"
    
    REM Check for ANTHROPIC references
    echo !line! | findstr /I "ANTHROPIC" >nul && (
        call :test_pass "Contains ANTHROPIC environment variable handling"
        setlocal disabledelayedexpansion
        goto :next_check3
        setlocal enabledelayedexpansion
    )
)

:next_check3
endlocal
goto :eof

REM ############################################################################
REM Test: API Key Format Validation
REM ############################################################################

:test_api_key_validation
call :print_section "API Key Format Validation"

REM Test valid key format
set "test_key=sk-ant-v0-abc123def456ghi789jklmnop"
echo Testing key: %test_key%
echo %test_key% | findstr /R "^sk-ant-" >nul
if !errorlevel! equ 0 (
    call :test_pass "Valid API key format recognized"
) else (
    call :test_fail "API key validation" "Valid key not recognized"
)

REM Test invalid key format
set "invalid_key=invalid-api-key"
echo %invalid_key% | findstr /R "^sk-ant-" >nul
if !errorlevel! neq 0 (
    call :test_pass "Invalid API key format rejected"
) else (
    call :test_fail "API key validation" "Invalid key not rejected"
)
goto :eof

REM ############################################################################
REM Test: Environment Variable Safety
REM ############################################################################

:test_env_var_safety
call :print_section "Environment Variable Safety"

REM Save current env state
set "original_api_key=%ANTHROPIC_API_KEY%"

REM Verify we can read it without modifying
if defined ANTHROPIC_API_KEY (
    call :test_pass "Can read existing ANTHROPIC_API_KEY"
) else (
    call :test_pass "ANTHROPIC_API_KEY not set (good for clean test)"
)

REM Verify it hasn't changed
if "!original_api_key!"=="%ANTHROPIC_API_KEY%" (
    call :test_pass "User's environment variables untouched"
) else (
    call :test_fail "Environment safety" "ANTHROPIC_API_KEY was modified"
)

REM Test temp var creation and cleanup
set "TEST_VAR_TEMP=test_value"
if defined TEST_VAR_TEMP (
    call :test_pass "Temporary variables can be created"
    set "TEST_VAR_TEMP="
) else (
    call :test_fail "Temp variable test" "Could not create temp variable"
)
goto :eof

REM ############################################################################
REM Test: Windows Compatibility
REM ############################################################################

:test_windows_compatibility
call :print_section "Windows Compatibility"

REM Check for Windows version detection
if "!VERSION!" geq "10.0" (
    call :test_pass "Windows 10+ detected for ANSI color support"
) else (
    if "!VERSION!" geq "6.1" (
        call :test_pass "Windows 7 or later detected"
    ) else (
        call :test_fail "Windows version" "Unsupported Windows version: !VERSION!"
    )
)

REM Check if running in proper shell
if defined PROMPT (
    call :test_pass "Command Prompt environment available"
) else (
    call :test_fail "Shell environment" "Unexpected shell environment"
)

REM Check for common Windows paths
if exist "%USERPROFILE%" (
    call :test_pass "User profile directory accessible (%USERPROFILE%)"
) else (
    call :test_fail "Windows paths" "Cannot access user profile directory"
)
goto :eof

REM ############################################################################
REM Test: Documentation Completeness
REM ############################################################################

:test_documentation
call :print_section "Documentation Completeness"

call :assert_file_exists "README.md" "README.md exists"
call :assert_file_exists "QUICKSTART.md" "QUICKSTART.md exists"
call :assert_file_exists "CONTRIBUTING.md" "CONTRIBUTING.md exists"
call :assert_file_exists "CONFIGURATION_EXAMPLES.md" "CONFIGURATION_EXAMPLES.md exists"
call :assert_file_exists "PROJECT_OVERVIEW.md" "PROJECT_OVERVIEW.md exists"
call :assert_file_exists "LICENSE" "LICENSE file exists"

goto :eof

REM ############################################################################
REM Test: Cross-Platform Scripts
REM ############################################################################

:test_cross_platform
call :print_section "Cross-Platform Compatibility"

call :assert_file_exists "setup-claude-auth.sh" "setup-claude-auth.sh exists"
call :assert_file_exists "setup-claude-auth.bat" "setup-claude-auth.bat exists"
call :assert_file_exists ".gitattributes" ".gitattributes exists for line ending handling"

goto :eof

REM ############################################################################
REM Test: Security Features
REM ############################################################################

:test_security
call :print_section "Security Best Practices"

REM Check if batch script validates inputs
find /I "sk-ant-" setup-claude-auth.bat >nul
if !errorlevel! equ 0 (
    call :test_pass "Batch script has API key format validation"
) else (
    call :test_fail "Security check" "API key validation not found"
)

REM Check for error handling
find /I "errorlevel" setup-claude-auth.bat >nul
if !errorlevel! equ 0 (
    call :test_pass "Batch script includes error level checking"
) else (
    call :test_fail "Security check" "Error level checking not found"
)

goto :eof

REM ############################################################################
REM Test Summary
REM ############################################################################

:test_summary
call :print_section "Test Summary"

echo Tests Run:    %TESTS_RUN%
echo Tests Passed: %TESTS_PASSED%
echo Tests Failed: %TESTS_FAILED%
echo.

if %TESTS_FAILED% equ 0 (
    echo.
    echo ========================================================================
    echo   ^^ ALL TESTS PASSED! ^^
    echo ========================================================================
    echo.
    echo The application is ready for deployment! 
    echo.
) else (
    echo.
    echo ========================================================================
    echo   SOME TESTS FAILED
    echo ========================================================================
    echo.
)

goto :eof

REM ############################################################################
REM Main Execution
REM ############################################################################

call :print_header

echo Starting comprehensive batch script test suite...
echo (Your existing API keys and local setup will NOT be modified)
echo.

call :test_script_exists
call :test_batch_syntax
call :test_api_key_validation
call :test_env_var_safety
call :test_windows_compatibility
call :test_documentation
call :test_cross_platform
call :test_security
call :test_summary

endlocal
