# Substack Newsletter

**📎 Featured image (header):** `images/cover-substack.png` (1200×630).
**Inline images** (insert at the marked points in the body): `images/diagram-priority-chain.png` and `images/card-quote-bill.png`.

**Subject line options (pick one):**
- The Claude Code auth footgun nobody told you about
- I built an installer for the docs everyone skips
- 17KB of bash, three days of work, one less surprise bill

**Subtitle:** *Why I built a cross-platform auth installer for Claude Code, and what shipping it taught me about production tooling at small scale.*

---

Hey friends,

Quick story before the main piece:

Last month I was on a call with a developer who'd been using Claude Code for six weeks. He's a Pro subscriber — $20/month, fixed cost, no surprises. Except his Anthropic Console showed him owing $47 for the month. He couldn't explain it. Neither could I, at first. Until I asked him to run `env | grep ANTHROPIC`.

There it was. `ANTHROPIC_API_KEY=sk-ant-...` — set three weeks earlier when he'd followed a tutorial that wanted him to test something, then forgotten about. That single line, in his `.zshrc`, was overriding his subscription on every Claude Code invocation. He'd been quietly paying twice for the same product.

This is, by the data I have, the #1 most common Claude Code support issue. And the fix is to unset one variable. The diagnosis is the hard part.

I got tired of explaining this on calls. So I shipped a tool.

---

## What I built

[`claude-auth-setup`](https://github.com/your-repo/claude-auth-setup) — a cross-platform installer that:

- Detects what auth state you're in
- Tells you what's about to happen before it happens
- Backs up your shell config before editing it
- Validates everything before persisting
- Works on macOS, Linux, and Windows (cmd + PowerShell)

It's MIT licensed. ~17KB of bash, ~14KB of batch. No runtime dependencies. Five interactive prompts. Done.

*[INSERT IMAGE: `images/diagram-priority-chain.png`]*

The full write-up — the design decisions, the cross-platform surprises, the test suite philosophy — is on Medium. Link at the bottom.

## The four things I want you to take from this

If you don't read the rest, take these:

**1. Documentation tells you the rules. Scripts enforce them.** When the consequence of skimming a doc is a surprise bill, "we have a doc that explains it" is not a defense. Build the right outcome into the tool.

**2. Onboard with one yes/no question, not a menu.** First version of the installer presented six auth methods as a flat menu. Most users had no idea which applied to them. The redesign asked one question — "Do you have a subscription?" — and branched. Conversion went from bad to "essentially everyone finishes."

**3. Cross-platform is a tax. Pay it consciously.** Three days for ~200 lines of branching logic across bash, batch, and PowerShell. Worth it for the user base, but underestimate it and you'll ship buggy code on the platform you don't dev on. (I shipped two PowerShell parser bugs I caught only on a fresh Windows VM.)

**4. "Production-grade" is the same checklist regardless of size.** Idempotency, inspectability, reversibility, testability. A 17KB script that meets all four is more trustworthy than a 17MB service that meets two.

## What's next

A few people have asked for:
- A homebrew formula
- A `winget` package
- An interactive auth-state diagnostic that doesn't change anything (just tells you what's happening)

The diagnostic is the one I'm most interested in. Auth confusion isn't unique to Claude Code — almost every CLI with multiple auth methods has this problem. There might be a more general tool here.

If any of that is interesting to you, hit reply. I read everything.

## Read the full piece

→ **Medium:** [How I built a cross-platform setup script for Claude Code auth](#)
→ **GitHub:** [github.com/your-repo/claude-auth-setup](https://github.com/your-repo/claude-auth-setup)

If this resonated, forward it to the developer in your life who got a surprise bill last month. They'll thank you.

— Anil

P.S. The best bug report I got after shipping was: *"It worked. Why didn't this exist already?"* I don't know either. But it does now.

---

*You're getting this because you subscribed for posts about the unglamorous parts of shipping production tools. If you'd rather not — unsubscribe link at the bottom, no hard feelings.*
