# Quick Start Guide

Get Claude Code authentication configured in under 5 minutes.

## For Claude Subscription Users (Pro/Max/Teams/Enterprise)

**You have a Claude subscription? You're all set!**

```bash
# 1. Start Claude Code
claude

# 2. When prompted, select "Claude.ai"
# 3. Browser opens automatically - sign in
# 4. Return to terminal - you're ready!
```

**Important**: Make sure `ANTHROPIC_API_KEY` is NOT set in your environment, as it takes precedence over subscription authentication.

### Quick Check for Conflicting Credentials

```bash
# Unix/macOS/Linux
echo $ANTHROPIC_API_KEY
# If you see an API key, remove it:
unset ANTHROPIC_API_KEY

# Windows PowerShell
$env:ANTHROPIC_API_KEY
# If you see an API key, remove it:
setx ANTHROPIC_API_KEY ""
```

## For API Key Users (Pay-as-you-go)

### Step 1: Get Your API Key

1. Visit: https://console.anthropic.com
2. Sign in or create account
3. Navigate to "API Keys"
4. Click "Create Key"
5. Copy the key (starts with `sk-ant-`)
6. Add billing credits to your account

### Step 2: Run Setup Script

**Unix/macOS/Linux:**
```bash
chmod +x setup-claude-auth.sh
./setup-claude-auth.sh
```

**Windows:**
```batch
setup-claude-auth.bat
```

### Step 3: Reload Environment

**Unix/macOS/Linux:**
```bash
# zsh (macOS default)
source ~/.zshrc

# bash
source ~/.bash_profile  # macOS
source ~/.bashrc        # Linux
```

**Windows:**
```batch
# Close and reopen Command Prompt or PowerShell
```

### Step 4: Verify

```bash
# Start Claude Code
claude

# Inside Claude Code, check status
/status
```

You should see: "Authentication: API Key (ANTHROPIC_API_KEY)"

## Manual Configuration (Advanced)

If you prefer to set the API key manually:

**Unix/macOS/Linux (zsh):**
```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"' >> ~/.zshrc
source ~/.zshrc
```

**Unix/macOS/Linux (bash):**
```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"' >> ~/.bash_profile
source ~/.bash_profile
```

**Windows (permanent):**
```batch
setx ANTHROPIC_API_KEY "sk-ant-api03-your-key-here"
```

Then restart your terminal/command prompt.

## Troubleshooting

### Problem: "Authentication failed"

**Check which credential is active:**
```bash
claude
/status
```

**Check environment variables:**
```bash
# Unix
env | grep ANTHROPIC

# Windows
set | findstr ANTHROPIC
```

### Problem: "Unexpected API charges"

**Cause**: API key takes precedence over subscription

**Solution**: Remove API key
```bash
# Unix
unset ANTHROPIC_API_KEY

# Windows
setx ANTHROPIC_API_KEY ""
```

### Problem: "No valid credentials found"

**Solutions:**
1. Ensure API key is set in environment
2. Run `/login` in Claude Code
3. Check that API key is valid at https://console.anthropic.com
4. Verify billing credits are available

## Next Steps

- **Monitor usage**: https://console.anthropic.com
- **Check token costs**: `/usage` in Claude Code
- **Read full docs**: See [README.md](README.md)
- **Advanced config**: OAuth tokens, cloud providers, custom helpers

## Support

- **Documentation**: https://docs.claude.com/en/docs/claude-code/overview
- **Issues**: https://github.com/your-repo/claude-auth-setup/issues
- **Support**: https://support.claude.com
