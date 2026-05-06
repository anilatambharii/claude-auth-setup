# Reddit Posts

Reddit hates self-promo and corporate energy. These versions are intentionally informal, lead with the problem, and disclose authorship near the end. Pick the subreddit that fits your goal and use the matching post.

**📎 Image attachment** (Reddit allows one image per text post when "image upload" is enabled, otherwise embed the imgur link):
- Default: `images/cover-reddit.png`
- For r/programming or r/commandline (more diagram-friendly): `images/diagram-priority-chain.png`
- For r/devops (terminal-friendly): `images/card-terminal-tests.png`

If the sub is text-only, post the image to imgur first and add the link in a top-level comment.

---

## For r/ClaudeAI or r/Anthropic

**Title:** PSA: A stale `ANTHROPIC_API_KEY` will silently override your Pro subscription. I built a tool to fix it.

**Body:**

This is the #1 confusing thing about Claude Code auth and it costs people real money.

Claude Code resolves credentials in this order (high → low):
1. Cloud provider creds (Bedrock/Vertex/Foundry)
2. `ANTHROPIC_AUTH_TOKEN`
3. `ANTHROPIC_API_KEY`
4. `apiKeyHelper` script
5. `CLAUDE_CODE_OAUTH_TOKEN`
6. Subscription OAuth

Subscription is dead last. So if you're a Pro/Max subscriber and you ever set `ANTHROPIC_API_KEY` to test something — every Claude Code invocation goes through the API key instead. No warning. You just start getting per-token charges on top of your $20/month.

Quick check:

```bash
# macOS / Linux
env | grep ANTHROPIC

# Windows PowerShell
$env:ANTHROPIC_API_KEY
```

If anything shows up there and you didn't intend to use API key billing, that's why your Console bill is non-zero.

I got tired of debugging this on onboarding calls so I built an installer that detects + reconciles all of this correctly, with backups before any shell config edit. Cross-platform (bash + batch + PowerShell), MIT licensed.

Repo: github.com/your-repo/claude-auth-setup

Happy to answer questions in the comments. Also genuinely curious if anyone else has hit this — I keep being surprised by how widespread it is.

---

## For r/programming or r/commandline

**Title:** Cross-platform shell installer for Claude Code auth — bash + batch + PowerShell, with backup/rollback

**Body:**

I open-sourced an installer I wish existed when I started using Claude Code. Posting here because I think the cross-platform shell scripting decisions might be interesting to this sub even if you don't use Claude.

**The problem:** Claude Code supports 6 auth methods (cloud creds, auth token, API key, helper script, OAuth token, subscription OAuth). They have a strict priority order most users don't read about. Get it wrong and you silently misconfigure your billing.

**The installer:** Detects existing state, asks one yes/no question to branch ("subscription? y/n"), validates inputs, backs up shell config with a timestamp before any edit, prints a one-line rollback command.

**Things I learned that might be useful to others:**

- `setx` on Windows persists env vars to the registry but doesn't update the current session — write to both, and tell the user to open a new terminal
- `setx` has an undocumented 1024-char limit and silently truncates
- Shell detection: `$SHELL` covers 99% of cases, fall back to asking the user. Don't get clever with `ps -p $$ -o comm=` etc.
- PowerShell test scripts are a compatibility minefield across versions and encodings — write canonical tests in bash if you can, treat PS as a port
- For interactive installers: ONE yes/no question + branching beats a flat menu of N options. Massive conversion difference.

Repo: github.com/your-repo/claude-auth-setup
MIT licensed. ~17KB bash, ~14KB batch. Test suite included.

I'm the author. Happy to take feedback or PRs.

---

## For r/devops or r/sysadmin

**Title:** Open-sourced a Claude Code auth installer with proper backup/rollback semantics

**Body:**

For anyone deploying Claude Code in environments where you actually care about auth correctness (multiple users, mixed subscription/API billing, headless/CI):

I shipped `claude-auth-setup` — a cross-platform installer that handles the auth priority chain correctly and doesn't mutate user state without consent.

Features that might matter to this sub:

- **Idempotent** — running twice is a no-op, no duplicate exports
- **Backup before mutate** — every shell config edit produces a timestamped backup, with a printed `cp` rollback command
- **Inspectable** — shows the exact mutation before doing it, waits for `y/n`
- **CI-friendly** — separate path for `CLAUDE_CODE_OAUTH_TOKEN` (long-lived, generated via `claude setup-token`)
- **Cloud provider aware** — detects `CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`
- **No runtime deps** — pure bash / pure batch, plus a non-mutating PowerShell test suite

Test suite (bash) runs in <2s, validates without touching user state. 38 tests / 37 passing (the 1 failure is a regex bug in the test, not the installer — fix incoming).

Repo: github.com/your-repo/claude-auth-setup — MIT.

Genuinely interested in feedback from people running this at team scale. The CI/headless story specifically I'd like to harden.

---

**Notes for posting:**
- Don't crosspost the same post to multiple subs the same day — Reddit's anti-spam will throttle you
- Engage with comments within the first 2 hours, that's when ranking is decided
- If anyone asks "are you affiliated with Anthropic?" — be clear: no, this is independent open-source
