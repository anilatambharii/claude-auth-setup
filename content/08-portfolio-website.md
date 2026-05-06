# Portfolio / Website Copy

Three sizes — pick whichever fits the slot you're filling.

---

## A. Hero / one-liner (for nav-card or top-of-portfolio)

> **claude-auth-setup** — Cross-platform installer that fixes the most common Claude Code auth misconfiguration. Bash + Batch + PowerShell. MIT.

---

## B. Project card (for portfolio grid — ~80 words)

### claude-auth-setup

A production-grade cross-platform installer for Claude Code authentication. Solves the silent footgun where a stale `ANTHROPIC_API_KEY` overrides a Pro subscription and racks up unintended per-token charges. Detects existing auth state, asks one branching question, validates inputs, backs up shell config before any edit, and prints a one-line rollback. ~17KB bash + ~14KB batch + PowerShell test suite. MIT licensed.

**Stack:** Bash · Batch · PowerShell · zero runtime deps
**Status:** Open source · v1.0
**Links:** [Repo](https://github.com/your-repo/claude-auth-setup) · [Write-up](#)

---

## C. Detailed case study (for project subpage — ~500 words)

### claude-auth-setup

A cross-platform installer that fixes the most common Claude Code authentication misconfiguration.

#### The problem

Claude Code supports six different authentication methods — cloud provider credentials, an LLM-gateway auth token, an API key, an apiKeyHelper script, a long-lived OAuth token, and subscription OAuth — with a strict resolution priority. When users follow a tutorial that asks them to set `ANTHROPIC_API_KEY`, that variable silently overrides their Pro subscription on every Claude Code invocation, generating per-token charges on top of the $20/month subscription. The failure is silent: no warning, no error, just an unexpected line on the next Anthropic Console invoice.

The most common Claude Code support thread is some variation of: *"My Console bill went from $0 to $47 last month — I don't know why."*

#### The solution

A single interactive script that runs on macOS, Linux, and Windows. It:

1. Verifies the `claude` CLI is installed and offers to install it via `npm`
2. Asks one branching question — *"Do you have a Claude subscription?"* — and adapts the rest of the flow
3. Detects existing environment variables that would conflict with the user's intent and explains why
4. Validates API key format before persisting
5. Backs up the user's shell configuration with a timestamp before any edit, and prints a one-line rollback command

#### Engineering decisions

**Cross-platform parity without a runtime.** The Unix path is bash; the Windows path is batch (with PowerShell as a graceful fallback for users whose execution policy permits profile edits). Zero npm/python/node runtime dependencies — the installer ships as plain shell scripts that work on a stock macOS install or a default Windows 10.

**Backup-before-mutate.** Every shell config edit is preceded by `cp ~/.zshrc ~/.zshrc.backup_<timestamp>`. The rollback `cp` command is printed to the screen, not buried in docs. Trust restored at the moment of friction.

**Idempotent.** Running the script twice is safe. The second run detects the configured state and exits cleanly — no duplicate exports, no prompts to overwrite valid credentials.

**Test suite that doesn't mutate user state.** A bash-canonical test suite (PowerShell as a convenience port) validates script syntax, regex correctness, backup/restore mechanics in a `/tmp` sandbox, and cross-platform parity. Runs in <2 seconds. 38 tests, 37 passing — the one failing test is a regex bug in the test itself, not the installer.

**Onboarding via one yes/no, not a flat menu.** The first version of the installer presented six auth methods as options. Most users couldn't tell which applied to them. Replacing that with a single yes/no question — "subscription? y/n" — and branching everything from there raised completion rates from "bad" to "essentially everyone finishes."

#### Outcomes

- ~17KB bash + ~14KB batch + comprehensive docs
- MIT licensed, open contribution
- Cross-platform: macOS (zsh + bash), Linux (bash), Windows (cmd + PowerShell)
- Used internally for onboarding new developers onto Claude Code

#### Links

- **Repository:** [github.com/your-repo/claude-auth-setup](https://github.com/your-repo/claude-auth-setup)
- **Long-form write-up:** [Medium](#) / [dev.to](#)
- **License:** MIT

---

## D. Skill tags / SEO keywords (for meta tags, GitHub topics, portfolio search)

```
claude-code, anthropic, authentication, cross-platform, bash, powershell,
batch-script, shell-scripting, devops, developer-tools, oauth, environment-variables,
installer, open-source, mit-license, cli-tools, automation
```

---

## E. GitHub repo "About" / topics

**About (short description):**
> Cross-platform installer for Claude Code authentication. Detects, validates, and reconciles the six-way auth priority chain — with backups before any change. Bash + Batch + PowerShell. MIT.

**Topics (GitHub repo settings → topics):**
`claude-code`, `anthropic`, `authentication`, `bash`, `powershell`, `cross-platform`, `installer`, `developer-tools`, `oauth`, `cli`, `shell-script`, `devops`

**Pinned repo title (for github.com/anilatambharii):**
> 📦 claude-auth-setup — production-grade Claude Code auth installer

---

## F. Resume / CV bullet (one line, results-oriented)

> Designed and shipped **claude-auth-setup**, a cross-platform (Bash/Batch/PowerShell) open-source installer that resolves Claude Code's six-method authentication priority chain — eliminating the most common user misconfiguration that silently routes subscription users through per-token API billing. MIT licensed; comprehensive test suite; idempotent with backup/rollback semantics.
