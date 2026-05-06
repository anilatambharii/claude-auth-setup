# Slack Exec Summary

Slack uses its own flavored markdown (mrkdwn): single `*asterisks*` for bold, `_underscores_` for italic, backticks for code, and `<https://url|label>` for links. The version below is written in Slack mrkdwn — paste it directly into a channel.

There are three sizes: pick whichever fits the channel.

---

## A. Full exec summary (~250 words — for a project channel, #engineering, #devtools)

```
:rocket: *claude-auth-setup* — production-grade installer for Claude Code authentication

*What it is*
A cross-platform shell installer (Bash + Batch + PowerShell) that fixes the most common Claude Code auth misconfiguration: a stale `ANTHROPIC_API_KEY` silently overriding your Pro/Max subscription and racking up per-token charges on top of your fixed monthly bill.

*Why it matters*
Claude Code resolves credentials in a 6-method priority chain. Subscription OAuth is *last*. Anything higher — including a forgotten env var from a tutorial — wins. The result: developers paying $20/month for Pro *and* getting per-token Console charges they can't explain. The installer reconciles this in one interactive flow.

*What it does* (5 steps, ~30 seconds)
• Verifies Claude Code is installed (offers `npm i -g` if not)
• Asks one yes/no — _"do you have a subscription?"_ — and branches
• Detects existing env vars and explains conflicts before changing anything
• Validates API key format (`sk-ant-*` prefix + length)
• Backs up your shell config with a timestamp + prints a one-line rollback

*Value add*
:white_check_mark: Idempotent (safe to re-run)
:white_check_mark: Inspectable (asks before every mutation)
:white_check_mark: Reversible (timestamped backups, printed rollback)
:white_check_mark: Cross-platform (macOS · Linux · Windows)
:white_check_mark: Zero runtime deps · 38-test suite · MIT licensed

*How to use*
```bash
git clone <https://github.com/anilatambharii/claude-auth-setup>
cd claude-auth-setup
./setup-claude-auth.sh    # macOS / Linux
.\setup-claude-auth.bat   # Windows
```

*Repo:* <https://github.com/anilatambharii/claude-auth-setup>
*Write-up:* <https://medium.com/@anilatambharii/claude-auth-setup>

Open to feedback, issues, and PRs. :pray:
```

---

## B. Tight version (~120 words — for #general, #announcements, busy channels)

```
:wrench: Just open-sourced *claude-auth-setup* — a cross-platform installer that fixes the #1 Claude Code auth footgun.

*The problem:* Claude Code has 6 auth methods with a strict priority order. Subscription OAuth is last. A stale `ANTHROPIC_API_KEY` from any tutorial silently overrides your Pro subscription and starts billing per-token. No warning. No error.

*The fix:* one interactive script (Bash · Batch · PowerShell) that:
• Detects existing auth state
• Asks one branching question
• Backs up shell config before any edit
• Prints a one-line rollback

Idempotent, MIT licensed, 38-test suite, zero runtime deps.

```bash
git clone <https://github.com/anilatambharii/claude-auth-setup>
./setup-claude-auth.sh
```

Repo + write-up: <https://github.com/anilatambharii/claude-auth-setup>
Feedback welcome :pray:
```

---

## C. One-liner (for a thread reply or DM)

```
Shipped *claude-auth-setup* — cross-platform installer that fixes the silent `ANTHROPIC_API_KEY`-overrides-subscription footgun in Claude Code. Bash + Batch + PowerShell, MIT, idempotent, with backup/rollback. <https://github.com/anilatambharii/claude-auth-setup|Repo>.
```

---

## Posting tips

- *Pin it* if it's in a project or team channel — pinned messages survive the noise
- *Thread the deeper write-up* — post Version A as the top message, drop the Medium link as the first reply so the channel doesn't see two long messages back-to-back
- *Replace the Medium URL* with your actual published URL before posting (placeholder uses your handle)
- *Image attachment*: Slack auto-previews any image you upload. Attach `images/cover-linkedin.png` (1200×627) — it renders cleanly in Slack's preview pane
- *DM-friendly version*: Version C above. For onboarding new teammates onto Claude Code, just DM them this line
- *Slash command alternative*: if your team has a `/share` or `/post` command, you can wrap version A in a Block Kit message for richer formatting — happy to generate the JSON if useful
