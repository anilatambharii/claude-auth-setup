# LinkedIn Post

**📎 Attach when posting:** `images/cover-linkedin.png` (1200×627, primary).
Optional second image for a carousel: `images/card-features.png` or `images/diagram-priority-chain.png`.

---

I just open-sourced a tool I wish existed six months ago.

If you use Claude Code, you've probably hit the auth footgun: Claude Code supports six different ways to authenticate, with a strict priority order. Set the wrong combination and you'll silently rack up per-token API charges on top of your $20/month Pro subscription.

The most common support thread in the Claude Code community is some variation of:

  → "My Anthropic Console bill went from $0 to $47 last month and I don't know why."

The "why" is almost always a stale ANTHROPIC_API_KEY from a tutorial someone followed weeks ago, silently overriding their subscription auth.

So I built **claude-auth-setup** — a cross-platform installer (Bash, Batch, PowerShell) that:

✅ Detects your existing auth state before changing anything
✅ Asks the right question first ("Do you have a subscription?") and branches from there
✅ Validates API key format before persisting it
✅ Backs up your shell config with a timestamp before any edit
✅ Prints a one-line rollback command, so nothing is unrecoverable
✅ Works on macOS (zsh/bash), Linux, and Windows (cmd/PowerShell)

Lessons from shipping it:

▸ Documentation tells you the rules. A setup script enforces them. Skimmable docs lose; opinionated installers win.

▸ Cross-platform shell scripting is a tax. Three days for 200 lines of branching logic across bash, batch, and PowerShell — and I still shipped two PowerShell parser bugs I caught only on a fresh Windows VM.

▸ "Production-grade" at 17KB means four things: idempotency, inspectability, reversibility, testability. Same bar as a 17MB service.

▸ Onboard with one yes/no question, not a menu of six options. Conversion went from "bad" to "essentially everyone finishes."

It's MIT-licensed. If you onboard developers onto Claude Code, or you're an individual user who'd like one less footgun, I'd love your feedback.

Repo and full write-up in the comments.

#ClaudeCode #DeveloperTooling #OpenSource #DevEx #Anthropic #ShellScripting #Automation
