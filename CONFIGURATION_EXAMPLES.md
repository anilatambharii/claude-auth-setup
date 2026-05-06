# Claude Code Authentication Configuration Examples
# 
# This file demonstrates various authentication configurations.
# Choose ONE method and configure it in your shell configuration file
# (e.g., ~/.zshrc, ~/.bash_profile) or Windows environment variables.
#
# IMPORTANT: Only one authentication method should be active at a time.
# Higher priority methods override lower priority ones.

################################################################################
# PRIORITY ORDER (highest to lowest):
# 1. Cloud provider credentials (Bedrock, Vertex AI, Foundry)
# 2. ANTHROPIC_AUTH_TOKEN (LLM gateways/proxies)
# 3. ANTHROPIC_API_KEY (direct API access)
# 4. apiKeyHelper (custom scripts)
# 5. CLAUDE_CODE_OAUTH_TOKEN (long-lived OAuth)
# 6. Subscription OAuth (/login in Claude Code)
################################################################################

################################################################################
# METHOD 1: SUBSCRIPTION AUTHENTICATION (Recommended for individuals)
################################################################################
# 
# Best for: Claude Pro, Max, Teams, or Enterprise subscribers
# Billing: Fixed monthly subscription fee
# Setup: Browser-based login (easiest)
# 
# Configuration:
#   1. Ensure NO environment variables are set (especially ANTHROPIC_API_KEY)
#   2. Run: claude
#   3. Select "Claude.ai" when prompted
#   4. Sign in via browser
#
# To verify:
#   claude
#   /status
#
# To switch accounts:
#   /logout
#   /login

################################################################################
# METHOD 2: API KEY AUTHENTICATION (Pay-as-you-go)
################################################################################
#
# Best for: API usage, pay-per-token billing, no subscription
# Billing: Per-token charges on Anthropic Console account
# Setup: Set environment variable
#
# Get your API key from: https://console.anthropic.com
#
# Unix/macOS/Linux (add to ~/.zshrc or ~/.bash_profile):
export ANTHROPIC_API_KEY="sk-ant-api03-your-actual-key-here"

# Windows (run in Command Prompt):
# setx ANTHROPIC_API_KEY "sk-ant-api03-your-actual-key-here"
#
# Windows (PowerShell):
# [Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "sk-ant-api03-your-actual-key-here", "User")
#
# To verify:
#   claude
#   /status
#   # Should show: "Authentication: API Key (ANTHROPIC_API_KEY)"

################################################################################
# METHOD 3: OAUTH TOKEN (For CI/CD and headless environments)
################################################################################
#
# Best for: CI/CD pipelines, automated scripts, headless servers
# Billing: Uses subscription credits
# Setup: Generate token, set environment variable
#
# Generate token (valid for 1 year):
#   claude setup-token
#
# Unix/macOS/Linux (add to ~/.zshrc or ~/.bash_profile):
export CLAUDE_CODE_OAUTH_TOKEN="your-oauth-token-here"

# Windows (run in Command Prompt):
# setx CLAUDE_CODE_OAUTH_TOKEN "your-oauth-token-here"
#
# To verify:
#   claude
#   /status

################################################################################
# METHOD 4: BEARER TOKEN (For LLM gateways and proxies)
################################################################################
#
# Best for: Custom LLM gateways, API proxies, enterprise middleware
# Billing: Depends on gateway configuration
# Setup: Set bearer token
#
# Unix/macOS/Linux (add to ~/.zshrc or ~/.bash_profile):
export ANTHROPIC_AUTH_TOKEN="your-bearer-token-here"

# Windows (run in Command Prompt):
# setx ANTHROPIC_AUTH_TOKEN "your-bearer-token-here"
#
# Optional: Set custom base URL
export ANTHROPIC_BASE_URL="https://your-gateway.example.com/v1"
#
# Windows:
# setx ANTHROPIC_BASE_URL "https://your-gateway.example.com/v1"

################################################################################
# METHOD 5: AWS BEDROCK
################################################################################
#
# Best for: AWS-based deployments, enterprises using Bedrock
# Billing: AWS Bedrock pricing
# Setup: Configure AWS credentials + Bedrock variables
#
# Prerequisites:
#   - AWS CLI configured with credentials
#   - Bedrock API access enabled in your AWS account
#
# Unix/macOS/Linux (add to ~/.zshrc or ~/.bash_profile):
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION="us-east-1"
# AWS credentials from ~/.aws/credentials or IAM role

# Windows (run in Command Prompt):
# setx CLAUDE_CODE_USE_BEDROCK 1
# setx AWS_REGION "us-east-1"
#
# To verify:
#   claude
#   /status
#   # Should show Bedrock authentication

################################################################################
# METHOD 6: GOOGLE VERTEX AI
################################################################################
#
# Best for: GCP-based deployments, enterprises using Vertex AI
# Billing: Google Cloud Vertex AI pricing
# Setup: Configure GCP credentials + Vertex variables
#
# Prerequisites:
#   - gcloud CLI configured
#   - Vertex AI API enabled
#   - Anthropic models enabled in your GCP project
#
# Unix/macOS/Linux (add to ~/.zshrc or ~/.bash_profile):
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION="us-central1"
export ANTHROPIC_VERTEX_PROJECT_ID="your-gcp-project-id"
# Google Cloud credentials from gcloud auth

# Windows (run in Command Prompt):
# setx CLAUDE_CODE_USE_VERTEX 1
# setx CLOUD_ML_REGION "us-central1"
# setx ANTHROPIC_VERTEX_PROJECT_ID "your-gcp-project-id"

################################################################################
# METHOD 7: MICROSOFT FOUNDRY
################################################################################
#
# Best for: Azure-based deployments, enterprises using Foundry
# Billing: Microsoft Azure pricing
# Setup: Configure Azure credentials + Foundry variables
#
# Prerequisites:
#   - Azure CLI configured
#   - Foundry access enabled
#
# Unix/macOS/Linux (add to ~/.zshrc or ~/.bash_profile):
export CLAUDE_CODE_USE_FOUNDRY=1
# Additional Azure authentication variables as needed

# Windows (run in Command Prompt):
# setx CLAUDE_CODE_USE_FOUNDRY 1

################################################################################
# METHOD 8: CUSTOM CREDENTIAL HELPER (Advanced)
################################################################################
#
# Best for: Dynamic credentials, vault integration, rotating keys
# Billing: Depends on credential source
# Setup: Create script that outputs API key, configure helper
#
# Example helper script (~/scripts/get-api-key.sh):
#   #!/bin/bash
#   # Fetch API key from HashiCorp Vault
#   vault kv get -field=api_key secret/claude/api-key
#
# Configure in Claude Code settings (location varies by platform):
# {
#   "apiKeyHelper": "~/scripts/get-api-key.sh",
#   "apiKeyHelperTimeout": 30,
#   "apiKeyHelperRefreshInterval": 300
# }
#
# The script is called:
#   - On Claude Code startup
#   - Every 5 minutes (default refresh interval)
#   - On HTTP 401 responses
#
# Script requirements:
#   - Must be executable
#   - Must output valid API key to stdout
#   - Must exit with code 0 on success

################################################################################
# ADVANCED: CUSTOM MODEL CONFIGURATION
################################################################################
#
# Override default model:
export CLAUDE_CODE_MODEL="claude-opus-4-6"
# Available models:
#   - claude-opus-4-6 (most capable, highest cost)
#   - claude-sonnet-4-6 (balanced, recommended)
#   - claude-haiku-4-5 (fast, lowest cost)

# Windows:
# setx CLAUDE_CODE_MODEL "claude-opus-4-6"

################################################################################
# VERIFICATION COMMANDS
################################################################################
#
# After configuring, verify your setup:
#
# 1. Start Claude Code:
#    claude
#
# 2. Check authentication status:
#    /status
#
# 3. Check token usage (for API billing):
#    /usage
#
# 4. Check environment variables:
#    Unix/macOS/Linux:
#      env | grep ANTHROPIC
#      env | grep CLAUDE_CODE
#    
#    Windows (Command Prompt):
#      set | findstr ANTHROPIC
#      set | findstr CLAUDE_CODE
#    
#    Windows (PowerShell):
#      Get-ChildItem Env: | Where-Object {$_.Name -like "*ANTHROPIC*"}
#      Get-ChildItem Env: | Where-Object {$_.Name -like "*CLAUDE_CODE*"}

################################################################################
# TROUBLESHOOTING
################################################################################
#
# Wrong authentication method active:
#   - Check priority order at top of file
#   - Remove higher-priority credentials you don't want
#   - Restart terminal/shell after changes
#
# Environment variables not persisting:
#   Unix/macOS/Linux:
#     - Ensure added to correct config file (~/.zshrc, ~/.bash_profile)
#     - Run: source ~/.zshrc (or appropriate file)
#   Windows:
#     - Close and reopen Command Prompt/PowerShell
#     - Or log out and log back in
#
# API charges when using subscription:
#   - ANTHROPIC_API_KEY takes precedence over subscription
#   - Remove API key: unset ANTHROPIC_API_KEY (Unix) or setx ANTHROPIC_API_KEY "" (Windows)
#   - Verify: /status should show "Subscription (OAuth)"
#
# Invalid credentials error:
#   - Verify key at https://console.anthropic.com
#   - Check billing credits are available
#   - Ensure key format is correct (starts with sk-ant-)
#   - Check key hasn't expired

################################################################################
# SECURITY BEST PRACTICES
################################################################################
#
# 1. Never commit API keys to git:
#    - Add to .gitignore: *.env, .env.local
#    - Use environment variables, not hardcoded values
#
# 2. Use minimal scope:
#    - Create separate keys for dev/staging/prod
#    - Use workspace-specific keys for cost tracking
#
# 3. Rotate keys regularly:
#    - Recommended: every 90 days
#    - After any suspected compromise: immediately
#
# 4. Monitor usage:
#    - Check Anthropic Console regularly
#    - Set up budget alerts
#    - Use /usage in Claude Code frequently
#
# 5. Secure storage:
#    - Use OS keychain/credential manager when possible
#    - For CI/CD: use secret management (GitHub Secrets, etc.)
#
# 6. Least privilege:
#    - Only grant access to those who need it
#    - Review access regularly

################################################################################
# COST MANAGEMENT
################################################################################
#
# Estimate your usage:
#   - Casual use: ~$5-20/month
#   - Regular development: ~$20-100/month
#   - Heavy use: $100+/month
#
# Cost-saving tips:
#   1. Use Haiku for simple tasks (cheaper)
#   2. Use Sonnet for balanced price/performance (recommended)
#   3. Reserve Opus for complex tasks only
#   4. Monitor /usage regularly
#   5. Set budget alerts in Console
#
# Pricing (approximate, as of 2025):
#   Claude Haiku:  $0.25/M input,  $1.25/M output tokens
#   Claude Sonnet: $3/M input,     $15/M output tokens
#   Claude Opus:   $15/M input,    $75/M output tokens
#
# Subscription alternatives:
#   Claude Pro: $20/month (unlimited, subject to fair use)
#   Claude Max: $30/month (higher limits)
#   Claude Teams: $30/user/month
#   Claude Enterprise: Custom pricing

################################################################################
# REFERENCES
################################################################################
#
# Official Documentation:
#   - Claude Code: https://docs.claude.com/en/docs/claude-code/overview
#   - Authentication: https://code.claude.com/docs/en/authentication
#   - API Reference: https://docs.claude.com/en/api/overview
#
# Console and Support:
#   - Anthropic Console: https://console.anthropic.com
#   - Support Center: https://support.claude.com
#   - Claude.ai: https://claude.ai
#
# Community:
#   - GitHub: https://github.com/anthropics
#   - NPM Package: https://www.npmjs.com/package/@anthropic-ai/claude-code
