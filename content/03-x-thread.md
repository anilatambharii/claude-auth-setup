# X (Twitter) Thread

**📎 Attach to tweets** (X allows up to 4 images per tweet):

| Tweet | Image |
|---|---|
| 1 (hook) | `images/cover-x.png` |
| 2 (priority chain) | `images/diagram-priority-chain.png` |
| 3 (the bill quote) | `images/card-quote-bill.png` |
| 4 (what it does) | `images/card-features.png` |
| 7 (test results) | `images/card-terminal-tests.png` |

For the single-tweet alt at the bottom, use `images/cover-x.png`.

---

## Option A — Long thread (8 tweets)

**1/**
Claude Code has 6 ways to authenticate.

They have a strict priority order most users never read about.

Set the wrong combo → your $20/mo Pro subscription gets silently overridden by a stale API key, and you start getting per-token charges.

I just shipped a tool that fixes this. 🧵

**2/**
The priority chain (high → low):

1. Cloud creds (Bedrock/Vertex/Foundry)
2. ANTHROPIC_AUTH_TOKEN
3. ANTHROPIC_API_KEY ← the footgun
4. apiKeyHelper
5. CLAUDE_CODE_OAUTH_TOKEN
6. Subscription OAuth ← what most users actually want

Notice where subscription falls? Last.

**3/**
The most common support thread in the Claude Code community:

"My Console bill went from $0 to $47 last month and I don't know why."

The why is always: a stale ANTHROPIC_API_KEY from a tutorial someone followed 3 weeks ago.

It overrides the subscription. Silently. No warning.

**4/**
So I built `claude-auth-setup` — a cross-platform installer that handles the whole thing:

- Detects existing auth state before touching anything
- Asks ONE question ("subscription? y/n") and branches from there
- Validates key format
- Backs up shell config w/ timestamp
- Works on macOS, Linux, Windows

**5/**
Lessons from shipping it:

→ Docs tell you the rules. Scripts enforce them.
→ Cross-platform shell scripting is a tax (3 days for 200 lines)
→ "Production-grade" at 17KB means the same things as at 17MB: idempotent, inspectable, reversible, testable
→ One yes/no question > a menu of 6

**6/**
The hardest platform was Windows.

`setx` persists env vars to the registry but doesn't update the current shell. Users run the script, run `claude`, see the same error, assume the script is broken.

Fix: write to BOTH the registry AND the current session, plus loud "open a new terminal" message.

**7/**
The test suite was the most fun part.

It validates the installer WITHOUT mutating user state. Sandboxes backup/restore in /tmp, dry-runs the regex validation, verifies cross-platform parity.

38 tests, 37 passing — the 1 failing test is a bug in the test suite, not the installer 😅

**8/**
MIT licensed. Works today.

If you onboard people onto Claude Code, or you've ever been surprised by an Anthropic Console bill, I'd love your feedback.

→ Repo: github.com/your-repo/claude-auth-setup
→ Write-up: [Medium link]

PRs and "didn't work on my machine" reports both welcome.

---

## Option B — Single punchy tweet (if you don't want a thread)

Just shipped `claude-auth-setup` — a cross-platform installer for Claude Code authentication.

Solves the #1 silent footgun: a stale ANTHROPIC_API_KEY overriding your Pro subscription and racking up per-token charges.

Bash + Batch + PowerShell. MIT licensed.

🔗 github.com/your-repo/claude-auth-setup
