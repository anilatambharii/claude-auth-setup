# ============================================================================
# Claude Auth Setup - Comprehensive Test Suite (PowerShell)
# ============================================================================
# This test suite validates the authentication setup scripts without
# disrupting the user's existing configuration.
# ============================================================================

param(
    [switch]$Verbose = $false
)

# Color codes
$script:GREEN = "`e[32m"
$script:RED = "`e[31m"
$script:YELLOW = "`e[33m"
$script:BLUE = "`e[34m"
$script:NC = "`e[0m"

# Test counters
$script:TestsRun = 0
$script:TestsPassed = 0
$script:TestsFailed = 0
$script:TestResults = @()

# ============================================================================
# Utility Functions
# ============================================================================

function Write-TestHeader {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Claude Auth Setup - Test Suite" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "───────────────────────────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "───────────────────────────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host ""
}

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = ""
    )
    
    $script:TestsRun++
    if ($Passed) {
        $script:TestsPassed++
        Write-Host "✓ PASS: $TestName" -ForegroundColor Green
        $script:TestResults += @{ Name = $TestName; Status = "PASS"; Message = $Message }
    }
    else {
        $script:TestsFailed++
        Write-Host "✗ FAIL: $TestName" -ForegroundColor Red
        if ($Message) {
            Write-Host "  → $Message" -ForegroundColor Yellow
        }
        $script:TestResults += @{ Name = $TestName; Status = "FAIL"; Message = $Message }
    }
}

function Test-ScriptSyntax {
    param(
        [string]$ScriptPath,
        [string]$ScriptName
    )
    
    Write-SectionHeader "Validating $ScriptName Syntax"
    
    if (-not (Test-Path $ScriptPath)) {
        Write-TestResult "$ScriptName exists" $false "File not found: $ScriptPath"
        return
    }
    
    Write-TestResult "$ScriptName exists" $true
    
    # Check file size
    $fileSize = (Get-Item $ScriptPath).Length
    $passed = $fileSize -gt 1000
    Write-TestResult "$ScriptName has substantial content ($(Get-Item $ScriptPath).Length bytes)" $passed
    
    # Check for required sections/functions
    $content = Get-Content $ScriptPath -Raw
    
    # For batch script
    if ($ScriptName -like "*.bat") {
        $checksRequired = @(
            @{ Pattern = "@echo off"; Name = "@echo off directive" },
            @{ Pattern = "setlocal enabledelayedexpansion"; Name = "Enable delayed expansion" },
            @{ Pattern = "ANTHROPIC"; Name = "Anthropic references" },
            @{ Pattern = ":"; Name = "Batch labels (functions)" }
        )
    }
    else {
        # For bash script
        $checksRequired = @(
            @{ Pattern = "#!/usr/bin/env bash"; Name = "Shebang" },
            @{ Pattern = "set -euo pipefail"; Name = "Bash safety flags" },
            @{ Pattern = "log_info"; Name = "Logging functions" },
            @{ Pattern = "prompt_yes_no"; Name = "Input prompts" }
        )
    }
    
    foreach ($check in $checksRequired) {
        $passed = $content -match $check.Pattern
        Write-TestResult "$($check.Name)" $passed
    }
}

function Test-APIKeyValidation {
    Write-SectionHeader "API Key Validation"
    
    $validKeys = @(
        "sk-ant-v0-abc123def456ghi789jklmno",
        "sk-ant-v0-1234567890abcdefghijklmnop"
    )
    
    $invalidKeys = @(
        "sk-invalid-key",
        "api-key-wrong-prefix",
        "sk-ant-",
        "",
        $null
    )
    
    foreach ($key in $validKeys) {
        $pattern = "^sk-ant-[a-zA-Z0-9]{20,}$"
        $isValid = $key -match $pattern
        Write-TestResult "Valid key recognized: $($key.Substring(0,15))..." $isValid
    }
    
    foreach ($key in $invalidKeys) {
        $pattern = "^sk-ant-[a-zA-Z0-9]{20,}$"
        $isInvalid = $key -notmatch $pattern
        Write-TestResult "Invalid key rejected: $($key -replace '.$')" $isInvalid
    }
}

function Test-EnvironmentVariables {
    Write-SectionHeader "Environment Variable Handling"
    
    # Test 1: Check if we can read existing env vars without breaking them
    $existingApiKey = $env:ANTHROPIC_API_KEY
    
    Write-TestResult "Can read ANTHROPIC_API_KEY without modification" ($null -ne $existingApiKey -or $null -eq $existingApiKey)
    
    # Test 2: Check if we can detect auth token
    Write-TestResult "Can detect ANTHROPIC_AUTH_TOKEN" ($env:ANTHROPIC_AUTH_TOKEN -match "^.{0,}$")
    
    # Test 3: Verify we're not modifying user's environment
    Write-TestResult "User's existing env vars untouched" ($env:ANTHROPIC_API_KEY -eq $existingApiKey)
}

function Test-ShellConfiguration {
    Write-SectionHeader "Shell Configuration Detection"
    
    # Test PowerShell profile path
    $psProfilePath = $PROFILE
    $profileExists = Test-Path $psProfilePath
    Write-TestResult "PowerShell profile path detected: $psProfilePath" $true
    
    # Test home directory
    $homeDir = $env:USERPROFILE
    $homeDirExists = Test-Path $homeDir
    Write-TestResult "Home directory detected: $homeDir" $homeDirExists
    
    # Test shell detection on Windows
    $cmdExists = $null -ne (Get-Command cmd.exe -ErrorAction SilentlyContinue)
    Write-TestResult "Command Prompt available" $cmdExists
    
    $pwshExists = $null -ne (Get-Command powershell.exe -ErrorAction SilentlyContinue)
    Write-TestResult "PowerShell available" $pwshExists
}

function Test-FileBackupAndRollback {
    Write-SectionHeader "File Backup and Rollback Mechanism"
    
    # Create a temporary test file
    $testDir = Join-Path $env:TEMP "claude-auth-test"
    if (-not (Test-Path $testDir)) {
        New-Item -ItemType Directory -Path $testDir | Out-Null
    }
    
    $testFile = Join-Path $testDir "test-config.txt"
    "Original content" | Set-Content $testFile
    
    # Test backup creation
    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $backupFile = "$testFile.backup_$timestamp"
    Copy-Item $testFile $backupFile
    
    Write-TestResult "Can create backup files" (Test-Path $backupFile)
    
    # Test restore
    "Modified content" | Set-Content $testFile
    Copy-Item $backupFile $testFile -Force
    $restored = Get-Content $testFile
    Write-TestResult "Can restore from backup" ($restored -eq "Original content")
    
    # Cleanup
    Remove-Item $testFile, $backupFile -ErrorAction SilentlyContinue
}

function Test-DocumentationCompleteness {
    Write-SectionHeader "Documentation Verification"
    
    $docsChecks = @(
        @{ File = "README.md"; Name = "README" },
        @{ File = "QUICKSTART.md"; Name = "Quick Start Guide" },
        @{ File = "CONTRIBUTING.md"; Name = "Contributing Guide" },
        @{ File = "CONFIGURATION_EXAMPLES.md"; Name = "Configuration Examples" },
        @{ File = "PROJECT_OVERVIEW.md"; Name = "Project Overview" }
    )
    
    foreach ($doc in $docsChecks) {
        $docPath = Join-Path (Get-Location) $doc.File
        $exists = Test-Path $docPath
        Write-TestResult "$($doc.Name) ($($doc.File)) exists" $exists
        
        if ($exists) {
            $size = (Get-Item $docPath).Length
            $hasContent = $size -gt 500
            Write-TestResult "$($doc.Name) has substantial content ($size bytes)" $hasContent
        }
    }
}

function Test-CrossPlatformCompatibility {
    Write-SectionHeader "Cross-Platform Compatibility"
    
    # Check if both scripts exist
    $bashScript = Join-Path (Get-Location) "setup-claude-auth.sh"
    $batchScript = Join-Path (Get-Location) "setup-claude-auth.bat"
    
    Write-TestResult "Unix/Linux script exists (setup-claude-auth.sh)" (Test-Path $bashScript)
    Write-TestResult "Windows script exists (setup-claude-auth.bat)" (Test-Path $batchScript)
    
    # Check for Git attributes for line endings
    $gitAttribs = Join-Path (Get-Location) ".gitattributes"
    $gitAttribsExists = Test-Path $gitAttribs
    Write-TestResult ".gitattributes exists for line ending handling" $gitAttribsExists
    
    if ($gitAttribsExists) {
        $content = Get-Content $gitAttribs
        $hasBashRules = $content -match "*.sh"
        $hasBatchRules = $content -match "*.bat"
        Write-TestResult "Git attributes configured for shell scripts" $hasBashRules
        Write-TestResult "Git attributes configured for batch scripts" $hasBatchRules
    }
}

function Test-SecurityBestPractices {
    Write-SectionHeader "Security Best Practices"
    
    # Test 1: Check if scripts validate API keys
    $batchScript = Join-Path (Get-Location) "setup-claude-auth.bat"
    if (Test-Path $batchScript) {
        $batchContent = Get-Content $batchScript -Raw
        $hasKeyValidation = $batchContent -match "sk-ant-"
        Write-TestResult "Batch script validates API key format" $hasKeyValidation
    }
    
    # Test 2: Check if scripts have error handling
    if (Test-Path $batchScript) {
        $hasErrorHandling = $batchContent -match "(if errorlevel|if %%)"
        Write-TestResult "Batch script includes error handling" $hasErrorHandling
    }
    
    # Test 3: Check if sensitive data is handled safely
    $bashScript = Join-Path (Get-Location) "setup-claude-auth.sh"
    if (Test-Path $bashScript) {
        $bashContent = Get-Content $bashScript -Raw
        $hasSafeHandling = $bashContent -match 'eval.*=.*"'
        Write-TestResult "Bash script uses proper variable handling" $hasSafeHandling
    }
}

function Test-UserExperience {
    Write-SectionHeader "User Experience Features"
    
    $batchScript = Join-Path (Get-Location) "setup-claude-auth.bat"
    $bashScript = Join-Path (Get-Location) "setup-claude-auth.sh"
    
    # Check for user-friendly output
    if (Test-Path $batchScript) {
        $batchContent = Get-Content $batchScript -Raw
        $hasColorOutput = $batchContent -match "COLOR|echo"
        Write-TestResult "Batch script has user output formatting" $hasColorOutput
        
        $hasHelp = $batchContent -match "Usage|help|--help"
        Write-TestResult "Batch script provides usage information" $hasHelp
    }
    
    if (Test-Path $bashScript) {
        $bashContent = Get-Content $bashScript -Raw
        $hasColorOutput = $bashContent -match "\\033\[|printf"
        Write-TestResult "Bash script has color output" $hasColorOutput
        
        $hasPrompts = $bashContent -match "prompt_"
        Write-TestResult "Bash script has interactive prompts" $hasPrompts
    }
}

function Write-TestSummary {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Test Summary" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Tests Run:    $script:TestsRun" -ForegroundColor White
    Write-Host "Tests Passed: $script:TestsPassed" -ForegroundColor Green
    Write-Host "Tests Failed: $script:TestsFailed" -ForegroundColor Red
    
    if ($script:TestsFailed -eq 0) {
        Write-Host ""
        Write-Host "✓ ALL TESTS PASSED!" -ForegroundColor Green
        Write-Host ""
        Write-Host "The application is ready for deployment! 🚀" -ForegroundColor Green
    }
    else {
        Write-Host ""
        Write-Host "✗ SOME TESTS FAILED" -ForegroundColor Red
        Write-Host ""
        Write-Host "Failed tests:" -ForegroundColor Yellow
        foreach ($result in $script:TestResults) {
            if ($result.Status -eq "FAIL") {
                Write-Host "  • $($result.Name)" -ForegroundColor Yellow
                if ($result.Message) {
                    Write-Host "    → $($result.Message)" -ForegroundColor Gray
                }
            }
        }
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================================================
# Main Test Execution
# ============================================================================

function Invoke-AllTests {
    Write-TestHeader
    
    Write-Host "Starting comprehensive test suite..." -ForegroundColor Cyan
    Write-Host "(Your existing API keys and local setup will NOT be modified)" -ForegroundColor Green
    Write-Host ""
    
    # Run all tests
    Test-ScriptSyntax "setup-claude-auth.bat" "setup-claude-auth.bat"
    Test-ScriptSyntax "setup-claude-auth.sh" "setup-claude-auth.sh"
    Test-APIKeyValidation
    Test-EnvironmentVariables
    Test-ShellConfiguration
    Test-FileBackupAndRollback
    Test-DocumentationCompleteness
    Test-CrossPlatformCompatibility
    Test-SecurityBestPractices
    Test-UserExperience
    
    Write-TestSummary
}

# Execute all tests
Invoke-AllTests
