# Show HN Post

HN audiences value: terse titles, working links, real tradeoffs in the body, no marketing language. Below are 3 title options + the body.

**📎 Images** — HN posts don't accept image attachments. Submit the URL only. If the discussion is going well, you can drop a comment with `images/diagram-priority-chain.png` hosted via the GitHub repo (raw URL or repo README) — but don't open with images.

---

## Title options (pick one — keep it under 80 chars)

- **Show HN: Cross-platform installer for Claude Code authentication**
- **Show HN: claude-auth-setup – fixes the silent API-key-overrides-subscription footgun**
- **Show HN: An installer for Claude Code's six-way auth priority chain**

(Recommend the first — most neutral, least marketing-y. HN punishes hype.)

---

## Body

Hi HN,

`claude-auth-setup` is a small (~17KB bash, ~14KB batch) cross-platform installer for Claude Code authentication. It exists because Claude Code supports six different auth methods with a strict priority order, and the most common user-visible failure mode is "I have a Pro subscription but I'm being charged per-token" — caused by a stale `ANTHROPIC_API_KEY` silently overriding subscription OAuth.

The installer does five things:

1. Verifies `claude` is installed (offers `npm i -g` if not)
2. Asks one yes/no question — "do you have a subscription?" — and branches from there
3. Detects existing env vars and conflicts before changing anything
4. Validates API key format (`sk-ant-` prefix + length) before persisting
5. Backs up your shell config with a timestamp before any edit, prints the rollback command

Tradeoffs and limitations, in case anyone is considering using it:

- **It edits your shell config.** Backup-before-write and a printed rollback `cp` command are the mitigations. If that's not acceptable for your environment, don't use it.
- **It cannot revoke `setx` on Windows from inside a non-admin session.** It writes to user-scope env (`HKEY_CURRENT_USER\Environment`), and rollback prints the exact `setx VAR ""` command rather than executing it.
- **PowerShell test suite has known parser bugs in older PS versions.** Canonical test suite is bash. PS is a convenience port.
- **No keychain integration yet.** Credentials live in env vars / shell config, same as the docs assume. A `keychain`/`Credential Manager` mode is the most-requested feature; not yet implemented.
- **38 tests in the suite, 37 passing.** The one failure is a regex bug in a test, not the installer. Will fix.

Why this rather than improving the docs: docs get skimmed; installers don't. The conversation that prompted this was a developer paying $20/month for Pro and an extra $47/month in API charges he didn't realize were hitting his Console because of a stale env var from a tutorial. Documentation explained this. He'd read the docs.

What I'd genuinely like feedback on:

- The auth-state diagnostic mode (read-only, "tell me what's happening, don't change anything") — does this generalize to other CLIs with similar priority-chain auth designs?
- The Windows persistence story — `setx` is the supported tool but its behavior is surprising. Anyone landed on a better pattern?
- Whether the test suite's "validate without mutating user state" approach is over-engineered for an installer this size.

MIT licensed. No telemetry. Repo: https://github.com/your-repo/claude-auth-setup

I'm the author and I'll be in the comments.

---

**Posting tips:**
- Submit between 7-10am ET on a weekday — that's when HN front-page decisions get made
- Don't ask for upvotes; HN will bury you. Just post and engage with comments
- If you get a top comment that says "but Claude Code already does X" — engage with it directly, don't get defensive. HN rewards honesty
- Have the repo's README ready to handle 100 visitors at once. Make sure the install command works on a fresh machine
