# Claude Code Authentication Setup Scripts

Robust cross-platform scripts for configuring Claude Code authentication when enterprise subscriptions are not available.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Cross-Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue)](https://github.com)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green)](https://www.gnu.org/software/bash/)
[![Windows: Batch](https://img.shields.io/badge/Windows-Batch-blue)](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)

## Overview

These scripts provide an interactive, user-friendly setup process for Claude Code authentication, supporting both subscription-based and API key-based access patterns. Built for enterprise-grade reliability with comprehensive error handling, credential validation, and secure environment variable management.

### Key Features

- **Cross-platform support**: Native scripts for Unix-like systems (macOS, Linux, WSL) and Windows
- **Interactive guided setup**: Step-by-step prompts with validation and helpful error messages
- **Multiple authentication methods**: Supports subscriptions, API keys, OAuth tokens, and cloud providers
- **Secure credential management**: Proper environment variable handling with backup and rollback
- **Production-ready**: Comprehensive error handling, logging, and verification steps
- **Enterprise-grade documentation**: Clear instructions for troubleshooting and advanced configurations

## Authentication Architecture

Claude Code supports multiple authentication methods with a well-defined priority order:

```
Priority Order (highest to lowest):
1. Cloud provider credentials (AWS Bedrock, Google Vertex AI, Microsoft Foundry)
2. ANTHROPIC_AUTH_TOKEN (for LLM gateways/proxies)
3. ANTHROPIC_API_KEY (direct API access)
4. apiKeyHelper (custom credential scripts)
5. CLAUDE_CODE_OAUTH_TOKEN (long-lived OAuth tokens)
6. Subscription OAuth (Claude Pro/Max/Teams/Enterprise)
```

### Authentication Methods Comparison

| Method | Use Case | Billing | Setup Complexity |
|--------|----------|---------|------------------|
| **Subscription OAuth** | Individual users with Claude Pro/Max/Teams/Enterprise | Fixed monthly subscription | Low - browser login |
| **API Key** | Pay-as-you-go usage, CI/CD pipelines | Per-token API charges | Low - environment variable |
| **OAuth Token** | Headless environments, long-running scripts | Subscription credits | Medium - `claude setup-token` |
| **Cloud Providers** | Enterprise AWS/GCP/Azure deployments | Provider-specific billing | High - IAM configuration |
| **Auth Token** | Custom LLM gateway/proxy integration | Varies by gateway | Medium - bearer token setup |

## Installation

### Prerequisites

**For Unix/macOS/Linux:**
- Bash shell (version 4.0 or higher recommended)
- curl or wget (for documentation access)
- Node.js and npm (if installing Claude Code)

**For Windows:**
- Windows 10 or higher
- PowerShell 5.1 or higher (for advanced features)
- Node.js and npm (if installing Claude Code)

### Download Scripts

```bash
# Unix/macOS/Linux
curl -O https://raw.githubusercontent.com/your-repo/claude-auth-setup/main/setup-claude-auth.sh
chmod +x setup-claude-auth.sh

# Windows (PowerShell)
Invoke-WebRequest -Uri https://raw.githubusercontent.com/your-repo/claude-auth-setup/main/setup-claude-auth.bat -OutFile setup-claude-auth.bat
```

Or clone the repository:

```bash
git clone https://github.com/your-repo/claude-auth-setup.git
cd claude-auth-setup
```

## Usage

### Unix/macOS/Linux

```bash
# Make script executable
chmod +x setup-claude-auth.sh

# Run the setup script
./setup-claude-auth.sh
```

### Windows

```batch
# Run from Command Prompt
setup-claude-auth.bat

# Or from PowerShell
.\setup-claude-auth.bat
```

### Interactive Setup Flow

The script guides you through the following steps:

1. **Installation Verification**
   - Checks if Claude Code is installed
   - Offers to install via npm if missing
   - Verifies Node.js and npm availability

2. **Subscription Status Check**
   - Prompts if you have a Claude subscription (Pro/Max/Teams/Enterprise)
   - If yes: Provides subscription login instructions
   - If no: Proceeds to API key setup

3. **Credential Configuration**
   - For subscriptions: Ensures no conflicting API keys are set
   - For API keys: Prompts for Anthropic Console API key
   - Validates key format (must start with `sk-ant-`)
   - Configures appropriate environment variables

4. **Configuration Test**
   - Displays current authentication status
   - Shows which credentials are active
   - Provides verification commands

5. **Next Steps & Documentation**
   - Instructions for reloading environment variables
   - Commands to start Claude Code and verify authentication
   - Troubleshooting guidance

## Configuration Details

### Environment Variables

**ANTHROPIC_API_KEY**
- **Priority**: 3rd (after cloud providers and auth tokens)
- **Use case**: Direct API access with pay-as-you-go billing
- **Format**: `sk-ant-api03-...` (starts with `sk-ant-`)
- **Billing**: Per-token charges on Anthropic Console account

```bash
# Unix/macOS/Linux
export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"

# Windows
setx ANTHROPIC_API_KEY "sk-ant-api03-your-key-here"
```

**ANTHROPIC_AUTH_TOKEN**
- **Priority**: 2nd (higher than API key)
- **Use case**: LLM gateways, proxies, custom authentication
- **Format**: Bearer token format
- **Billing**: Depends on gateway/proxy configuration

**CLAUDE_CODE_OAUTH_TOKEN**
- **Priority**: 5th (lower than API key)
- **Use case**: CI/CD pipelines, headless environments
- **Format**: OAuth token generated by `claude setup-token`
- **Billing**: Uses subscription credits

### Shell Configuration Files

The scripts automatically detect and configure the appropriate shell configuration file:

**macOS:**
- zsh: `~/.zshrc`
- bash: `~/.bash_profile`

**Linux:**
- bash: `~/.bashrc`
- zsh: `~/.zshrc`

**Windows:**
- User environment variables (persisted in registry)
- System-wide: `HKEY_CURRENT_USER\Environment`

### Automatic Backups

Before modifying configuration files, the scripts create timestamped backups:

```
~/.zshrc.backup.20250505_143022
```

This allows easy rollback if needed.

## Verification Commands

### Check Active Authentication

Inside Claude Code:
```
/status
```

This displays:
- Current authentication method
- Account email and organization
- Active model and workspace

### Check Environment Variables

**Unix/macOS/Linux:**
```bash
# Check if API key is set
echo $ANTHROPIC_API_KEY

# Check all Claude-related variables
env | grep ANTHROPIC
env | grep CLAUDE_CODE
```

**Windows:**
```batch
# Command Prompt
echo %ANTHROPIC_API_KEY%

# PowerShell
$env:ANTHROPIC_API_KEY
```

### Verify Claude Code Installation

```bash
# Check version
claude --version

# Check help
claude --help
```

## Troubleshooting

### Common Issues

#### 1. "API key not recognized after setup"

**Cause**: Environment variables not loaded in current session

**Solution:**
```bash
# Unix/macOS/Linux - reload config
source ~/.zshrc  # or ~/.bash_profile

# Windows - open new Command Prompt/PowerShell window
```

#### 2. "Authentication failed with valid API key"

**Cause**: Higher-priority credential is set (e.g., ANTHROPIC_AUTH_TOKEN)

**Solution:**
```bash
# Check for conflicting credentials
/status  # in Claude Code

# Remove conflicting variables
unset ANTHROPIC_AUTH_TOKEN  # Unix
setx ANTHROPIC_AUTH_TOKEN ""  # Windows
```

#### 3. "Unexpected API charges with subscription"

**Cause**: ANTHROPIC_API_KEY takes precedence over subscription

**Solution:**
```bash
# Remove API key to use subscription
unset ANTHROPIC_API_KEY  # Unix

# Windows
setx ANTHROPIC_API_KEY ""
# Then restart Command Prompt
```

#### 4. "Browser doesn't open for OAuth login"

**Cause**: Headless environment or default browser not configured

**Solution:**
- Press `c` in Claude Code to copy login URL
- Paste URL into any browser
- Complete authentication
- Return to terminal and paste the code

### Advanced Troubleshooting

**Check credential priority:**
```bash
# Start Claude Code
claude

# Inside Claude Code
/status

# Look for: "Authentication: [method]"
# Possible values:
# - "Subscription (OAuth)"
# - "API Key (ANTHROPIC_API_KEY)"
# - "Bearer Token (ANTHROPIC_AUTH_TOKEN)"
# - "Cloud Provider"
```

**Verify API key validity:**
1. Visit: https://console.anthropic.com
2. Navigate to "API Keys" section
3. Check if key is active and has billing credits

**Reset authentication:**
```bash
# Inside Claude Code
/logout
/login

# Select authentication method
# Follow prompts
```

## Advanced Configuration

### OAuth Token for CI/CD

For environments where browser login is not available:

```bash
# Generate long-lived OAuth token (valid for 1 year)
claude setup-token

# Set environment variable
export CLAUDE_CODE_OAUTH_TOKEN="your-token-here"  # Unix
setx CLAUDE_CODE_OAUTH_TOKEN "your-token-here"    # Windows
```

### Custom Credential Helper

For dynamic credential management (e.g., from HashiCorp Vault):

1. Create credential script:
```bash
#!/bin/bash
# get-api-key.sh
vault kv get -field=api_key secret/claude
```

2. Configure in Claude Code settings:
```json
{
  "apiKeyHelper": "~/scripts/get-api-key.sh",
  "apiKeyHelperTimeout": 30
}
```

### Cloud Provider Authentication

**AWS Bedrock:**
```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION="us-east-1"
# AWS credentials from ~/.aws/credentials or IAM role
```

**Google Vertex AI:**
```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION="us-central1"
export ANTHROPIC_VERTEX_PROJECT_ID="your-gcp-project-id"
# Google Cloud credentials from gcloud auth
```

**Microsoft Foundry:**
```bash
export CLAUDE_CODE_USE_FOUNDRY=1
# Azure credentials configuration
```

### Custom API Base URL

For proxies or custom endpoints:

```bash
export ANTHROPIC_BASE_URL="https://your-proxy.example.com"
```

## Security Best Practices

### 1. Never Commit API Keys

```bash
# Add to .gitignore
echo "*.env" >> .gitignore
echo ".env.local" >> .gitignore

# Use environment-specific files
# .env.development (git-ignored)
# .env.production (git-ignored)
```

### 2. Use Minimal Scope

- Create separate API keys for different environments
- Use workspace-specific keys for cost tracking
- Rotate keys regularly (every 90 days recommended)

### 3. Monitor Usage

```bash
# Inside Claude Code - check token usage
/usage

# On Anthropic Console
# Visit: https://console.anthropic.com
# Navigate to: Usage & Billing
```

### 4. Secure Storage

**For local development:**
- Use OS keychain/credential manager
- Consider tools like `pass` (Unix) or Windows Credential Manager

**For CI/CD:**
- Use GitHub Actions secrets
- Use GitLab CI/CD variables
- Use environment-specific secret stores

### 5. Credential Isolation

```bash
# Development
export ANTHROPIC_API_KEY="sk-ant-dev-..."

# Production
export ANTHROPIC_API_KEY="sk-ant-prod-..."

# Never mix environments
```

## Usage Monitoring & Cost Management

### Track Token Usage

```bash
# Real-time usage in current session
/usage  # in Claude Code

# Response shows:
# - Input tokens
# - Output tokens
# - Total cost estimate
```

### Cost Estimation

**API Pricing (as of 2025):**
- Claude Sonnet: ~$3 per million input tokens, ~$15 per million output tokens
- Claude Opus: ~$15 per million input tokens, ~$75 per million output tokens
- Claude Haiku: ~$0.25 per million input tokens, ~$1.25 per million output tokens

**Subscription Pricing:**
- Claude Pro: $20/month (fixed)
- Claude Max: $30/month (fixed)
- Claude Teams: $30/user/month
- Claude Enterprise: Custom pricing

### Budget Alerts

Set up budget alerts in Anthropic Console:
1. Visit: https://console.anthropic.com
2. Navigate to: Settings → Billing
3. Configure: Budget alerts and spending limits

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature`
3. **Test thoroughly**: Verify on Windows, macOS, and Linux
4. **Follow coding standards**: Match existing style and documentation
5. **Submit a pull request**: Include description of changes and test results

### Development Setup

```bash
# Clone repository
git clone https://github.com/your-repo/claude-auth-setup.git
cd claude-auth-setup

# Test Unix script
./setup-claude-auth.sh

# Test Windows script (in Windows environment)
setup-claude-auth.bat
```

### Testing Checklist

- [ ] Subscription authentication flow works correctly
- [ ] API key validation catches invalid formats
- [ ] Environment variables persist after script completion
- [ ] Backup/rollback functionality works
- [ ] Error messages are clear and actionable
- [ ] Cross-platform compatibility verified

## License

MIT License - see [LICENSE](LICENSE) file for details

## Support & Resources

### Official Documentation
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code/overview
- **API Documentation**: https://docs.claude.com/en/api/overview
- **Support Center**: https://support.claude.com

### Additional Resources
- **Anthropic Console**: https://console.anthropic.com
- **Claude.ai**: https://claude.ai
- **NPM Package**: https://www.npmjs.com/package/@anthropic-ai/claude-code

### Community
- **GitHub Issues**: Report bugs and request features
- **Discussions**: Share tips and ask questions

## Changelog

### Version 1.0.0 (2025-05-05)
- Initial release
- Cross-platform support (Windows, macOS, Linux)
- Interactive setup with validation
- Comprehensive documentation
- Security best practices
- Advanced configuration options

## Acknowledgments

Built with reference to:
- Anthropic's official Claude Code documentation
- Community feedback and contributions
- Production deployment patterns from enterprise environments

---

**Author**: Ambharii Technologies LLC  
**Maintainer**: Anil Prasad  
**Contact**: GitHub Issues  
**Website**: https://github.com/your-repo/claude-auth-setup
