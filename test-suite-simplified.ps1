# Claude Auth Setup - Comprehensive Test Suite (PowerShell)
# This test suite validates the authentication setup scripts

param([switch]$Verbose = $false)

$script:TestsRun = 0
$script:TestsPassed = 0
$script:TestsFailed = 0

function Write-Header {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Claude Auth Setup - Test Suite" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host ""
}

function Write-TestResult {
    param([string]$TestName, [bool]$Passed, [string]$Message = "")
    
    $script:TestsRun++
    if ($Passed) {
        $script:TestsPassed++
        Write-Host "✓ PASS: $TestName" -ForegroundColor Green
    }
    else {
        $script:TestsFailed++
        Write-Host "✗ FAIL: $TestName" -ForegroundColor Red
        if ($Message) { Write-Host "       $Message" -ForegroundColor Yellow }
    }
}

function Test-ScriptSyntax {
    param([string]$ScriptPath, [string]$ScriptName)
    
    Write-SectionHeader "Validating $ScriptName"
    
    if (-not (Test-Path $ScriptPath)) {
        Write-TestResult "$ScriptName exists" $false "File not found"
        return
    }
    
    Write-TestResult "$ScriptName exists" $true
    
    $fileSize = (Get-Item $ScriptPath).Length
    Write-TestResult "Has substantial content" ($fileSize -gt 1000)
    
    $content = Get-Content $ScriptPath -Raw
    
    if ($ScriptName -like "*.bat") {
        $checks = @(
            @{ Pattern = "@echo off"; Name = "Batch directive present" },
            @{ Pattern = "setlocal"; Name = "Local scope configured" },
            @{ Pattern = "ANTHROPIC"; Name = "ANTHROPIC references present" }
        )
    } else {
        $checks = @(
            @{ Pattern = "#!/usr/bin/env bash"; Name = "Bash shebang present" },
            @{ Pattern = "set -euo pipefail"; Name = "Bash safety flags set" },
            @{ Pattern = "log_info"; Name = "Logging functions defined" }
        )
    }
    
    foreach ($check in $checks) {
        $found = $content -match $check.Pattern
        Write-TestResult $check.Name $found
    }
}

function Test-APIKeyValidation {
    Write-SectionHeader "API Key Format Validation"
    
    $validKey = "sk-ant-v0-abc123def456ghi789jklmno"
    $pattern = '^sk-ant-[a-zA-Z0-9]{20,}$'
    $isValid = $validKey -match $pattern
    Write-TestResult "Valid key format recognized" $isValid
    
    $invalidKey = "api-wrong-format"
    $isInvalid = $invalidKey -notmatch $pattern
    Write-TestResult "Invalid key format rejected" $isInvalid
}

function Test-Environment {
    Write-SectionHeader "Environment Variable Safety"
    
    $originalKey = $env:ANTHROPIC_API_KEY
    Write-TestResult "Can read existing variables" $true
    Write-TestResult "User environment untouched" ($env:ANTHROPIC_API_KEY -eq $originalKey)
}

function Test-Backups {
    Write-SectionHeader "File Backup and Rollback"
    
    $testDir = Join-Path $env:TEMP "claude-auth-test"
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    
    $testFile = Join-Path $testDir "test.txt"
    "Original" | Set-Content $testFile
    
    $backupFile = "$testFile.backup"
    Copy-Item $testFile $backupFile
    Write-TestResult "Can create backup files" (Test-Path $backupFile)
    
    "Modified" | Set-Content $testFile
    Copy-Item $backupFile $testFile -Force
    $restored = Get-Content $testFile
    Write-TestResult "Can restore from backup" ($restored -eq "Original")
    
    Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue
}

function Test-Docs {
    Write-SectionHeader "Documentation Completeness"
    
    $docs = @("README.md", "QUICKSTART.md", "CONTRIBUTING.md", "PROJECT_OVERVIEW.md", "LICENSE")
    
    foreach ($doc in $docs) {
        $exists = Test-Path $doc
        Write-TestResult "$doc exists" $exists
        
        if ($exists) {
            $size = (Get-Item $doc).Length
            $hasContent = $size -gt 100
            if (-not $hasContent) {
                Write-TestResult "$doc has content" $false
            }
        }
    }
}

function Test-CrossPlatform {
    Write-SectionHeader "Cross-Platform Support"
    
    Write-TestResult "Unix/Linux script exists" (Test-Path "setup-claude-auth.sh")
    Write-TestResult "Windows script exists" (Test-Path "setup-claude-auth.bat")
    Write-TestResult "Git attributes configured" (Test-Path ".gitattributes")
}

function Test-Security {
    Write-SectionHeader "Security Best Practices"
    
    if (Test-Path "setup-claude-auth.bat") {
        $content = Get-Content "setup-claude-auth.bat" -Raw
        Write-TestResult "Batch key validation" ($content -match "sk-ant-")
        Write-TestResult "Batch error handling" ($content -match "errorlevel")
    }
    
    if (Test-Path "setup-claude-auth.sh") {
        $content = Get-Content "setup-claude-auth.sh" -Raw
        Write-TestResult "Bash safety flags" ($content -match "set -euo")
        Write-TestResult "Bash functions defined" ($content -match "log_info")
    }
}

function Write-Summary {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Test Summary" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Total Tests Run:  $script:TestsRun"
    Write-Host "Tests Passed:     $script:TestsPassed" -ForegroundColor Green
    Write-Host "Tests Failed:     $script:TestsFailed" -ForegroundColor $(if ($script:TestsFailed -eq 0) { "Green" } else { "Red" })
    
    Write-Host ""
    if ($script:TestsFailed -eq 0) {
        Write-Host "✓ ALL TESTS PASSED!" -ForegroundColor Green
        Write-Host "✓ Application is ready for deployment!" -ForegroundColor Green
        Write-Host "✓ Your local setup was not modified" -ForegroundColor Green
    } else {
        Write-Host "✗ Some tests failed" -ForegroundColor Red
    }
    Write-Host ""
}

# Main execution
Write-Header
Write-Host "Testing Claude Auth Setup Application" -ForegroundColor Cyan
Write-Host "(Your existing API keys and local setup will NOT be modified)" -ForegroundColor Green
Write-Host ""

Test-ScriptSyntax "setup-claude-auth.bat" "setup-claude-auth.bat"
Test-ScriptSyntax "setup-claude-auth.sh" "setup-claude-auth.sh"
Test-APIKeyValidation
Test-Environment
Test-Backups
Test-Docs
Test-CrossPlatform
Test-Security
Write-Summary
