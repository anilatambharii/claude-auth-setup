# Contributing to Claude Code Authentication Setup Scripts

Thank you for considering contributing to this project! This document provides guidelines for contributing to ensure a smooth and effective collaboration.

## Code of Conduct

Be respectful, constructive, and professional in all interactions. We are committed to providing a welcoming and inclusive environment for all contributors.

## How to Contribute

### Reporting Bugs

Before creating a bug report, please:

1. **Check existing issues**: Search the issue tracker to see if the problem has already been reported
2. **Verify the bug**: Ensure the issue is reproducible
3. **Gather information**: Collect relevant details about your environment

**Bug Report Template:**
```
**Environment**
- OS: [e.g., Windows 11, macOS 14, Ubuntu 22.04]
- Shell: [e.g., bash 5.1, zsh 5.8, PowerShell 7.2]
- Claude Code Version: [e.g., 1.2.3]
- Script Version: [e.g., 1.0.0]

**Description**
[Clear description of the bug]

**Steps to Reproduce**
1. [First step]
2. [Second step]
3. [...]

**Expected Behavior**
[What you expected to happen]

**Actual Behavior**
[What actually happened]

**Screenshots/Logs**
[If applicable, add screenshots or log output]

**Additional Context**
[Any other relevant information]
```

### Suggesting Enhancements

Enhancement suggestions are always welcome! Please:

1. **Check existing suggestions**: Search issues and discussions
2. **Provide clear use case**: Explain why this enhancement would be useful
3. **Consider scope**: Ensure it aligns with project goals

**Enhancement Template:**
```
**Feature Description**
[Clear description of the proposed feature]

**Use Case**
[Explain the problem this solves or the value it provides]

**Proposed Solution**
[How you envision this working]

**Alternatives Considered**
[Other approaches you've thought about]

**Additional Context**
[Any other relevant information]
```

### Pull Requests

We actively welcome pull requests! Follow this process:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**: Follow coding standards (see below)
4. **Test thoroughly**: Verify on all supported platforms
5. **Update documentation**: Reflect changes in README.md and other docs
6. **Commit with clear messages**: Use conventional commit format
7. **Push to your fork**: `git push origin feature/your-feature-name`
8. **Open a pull request**: Provide detailed description

## Development Guidelines

### Coding Standards

#### Shell Scripts (Unix/macOS/Linux)

**Style Guide:**
- Use 4-space indentation
- Follow Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
- Use `shellcheck` for linting: https://www.shellcheck.net

**Best Practices:**
```bash
# Use 'set -euo pipefail' at the top of scripts
set -euo pipefail

# Quote variables
echo "$VARIABLE"

# Use functions for reusability
function_name() {
    local variable="value"
    echo "$variable"
}

# Add comments for complex logic
# This function validates API key format
validate_api_key() {
    # Implementation
}

# Use readonly for constants
readonly SCRIPT_VERSION="1.0.0"

# Prefer [[ ]] over [ ]
if [[ "$var" == "value" ]]; then
    # ...
fi
```

**Testing:**
```bash
# Run shellcheck
shellcheck setup-claude-auth.sh

# Test on multiple shells
bash setup-claude-auth.sh
zsh setup-claude-auth.sh

# Test error handling
# (deliberately trigger errors to verify graceful failures)
```

#### Batch Scripts (Windows)

**Style Guide:**
- Use 4-space indentation
- Use UPPERCASE for environment variables
- Use lowercase for labels and function names

**Best Practices:**
```batch
@echo off
setlocal enabledelayedexpansion

REM Use REM for comments
REM Multiple lines should have REM on each line

REM Use labels for functions
:function_name
    REM Implementation
    goto :eof

REM Quote paths with spaces
set "PATH_VAR=C:\Program Files\Example"

REM Use %~1 to remove quotes from parameters
set "param=%~1"

REM Check errorlevel after commands
command
if %errorlevel% neq 0 (
    echo Error occurred
    exit /b 1
)
```

**Testing:**
```batch
# Test on different Windows versions
# Windows 10, Windows 11, Windows Server

# Test in different shells
# Command Prompt, PowerShell

# Verify environment variable persistence
setx TEST_VAR "value"
# Close and reopen terminal
echo %TEST_VAR%
```

### Documentation Standards

**README.md Updates:**
- Keep table of contents current
- Update version numbers
- Add new features to feature list
- Update examples if behavior changes

**Code Comments:**
```bash
################################################################################
# Section Header
# 
# Detailed description of what this section does and why it exists.
################################################################################

# Function-level comment: What the function does
function_name() {
    # Inline comment: Why this specific approach
    local variable="value"
}
```

**Commit Messages:**

Follow Conventional Commits: https://www.conventionalcommits.org

```
feat: add OAuth token support for CI/CD environments
fix: correct environment variable persistence on Windows 11
docs: update troubleshooting section with new solutions
test: add cross-platform integration tests
refactor: improve error handling in credential validation
chore: update dependencies and version numbers
```

### Testing Requirements

**Manual Testing Checklist:**

- [ ] **Unix/macOS/Linux**
  - [ ] bash on Linux (Ubuntu, CentOS, etc.)
  - [ ] zsh on macOS
  - [ ] bash on macOS
  - [ ] WSL (Windows Subsystem for Linux)

- [ ] **Windows**
  - [ ] Command Prompt (Windows 10)
  - [ ] Command Prompt (Windows 11)
  - [ ] PowerShell 5.1
  - [ ] PowerShell 7.x

- [ ] **Scenarios**
  - [ ] Fresh installation (Claude Code not installed)
  - [ ] Existing installation (Claude Code already present)
  - [ ] Subscription authentication flow
  - [ ] API key authentication flow
  - [ ] Conflicting credentials (API key + subscription)
  - [ ] Invalid API key format
  - [ ] Environment variable persistence
  - [ ] Backup and rollback functionality

**Test Script Template:**
```bash
#!/bin/bash
# test-auth-setup.sh

# Test 1: Fresh installation
echo "Test 1: Fresh installation"
# Uninstall Claude Code if present
npm uninstall -g @anthropic-ai/claude-code
# Run setup script
./setup-claude-auth.sh
# Verify installation
which claude

# Test 2: API key validation
echo "Test 2: API key validation"
# Test with invalid key
# Expected: Error message
# Test with valid key format
# Expected: Success

# ... more tests
```

### Cross-Platform Compatibility

**Key Considerations:**

1. **Path Separators**: Use appropriate separators for each platform
   - Unix: `/`
   - Windows: `\` (but `/` works in many contexts)

2. **Environment Variables**: Different syntax
   - Unix: `$VARIABLE` or `${VARIABLE}`
   - Windows Batch: `%VARIABLE%`
   - Windows PowerShell: `$env:VARIABLE`

3. **File Endings**: Use appropriate line endings
   - Unix: LF (`\n`)
   - Windows: CRLF (`\r\n`)
   - Configure `.gitattributes` to handle this

4. **Shell Detection**: Scripts should detect the current shell
   ```bash
   if [[ -n "${ZSH_VERSION:-}" ]]; then
       # zsh-specific code
   elif [[ -n "${BASH_VERSION:-}" ]]; then
       # bash-specific code
   fi
   ```

5. **Command Availability**: Check before using commands
   ```bash
   if command -v npm &> /dev/null; then
       # npm is available
   else
       # npm not found
   fi
   ```

## Documentation Contributions

Documentation improvements are highly valued! Areas that benefit from contributions:

- **Troubleshooting**: Add new solutions to common problems
- **Examples**: Provide real-world usage examples
- **Tutorials**: Step-by-step guides for specific scenarios
- **Screenshots**: Visual aids for complex procedures
- **Translations**: Documentation in other languages

## Feature Requests

Before implementing a new feature:

1. **Open an issue**: Discuss the feature first
2. **Get feedback**: Ensure alignment with project goals
3. **Design document**: For complex features, write a design doc
4. **Implementation**: Follow the PR process

## Release Process

(For maintainers)

1. **Version Bump**: Update version in scripts and README
2. **Changelog**: Update CHANGELOG.md with changes
3. **Testing**: Run full test suite on all platforms
4. **Documentation**: Ensure all docs are current
5. **Tag Release**: Create git tag with version number
6. **GitHub Release**: Create release with notes and artifacts

## Getting Help

- **Questions**: Open a GitHub Discussion
- **Issues**: Create a GitHub Issue
- **Contact**: See README.md for contact information

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in commit messages

Thank you for contributing to make Claude Code authentication easier for everyone!

---

**Questions?** Feel free to ask in GitHub Discussions or open an issue.
