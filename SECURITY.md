# Security Policy

## Supported versions

create-project has not yet cut a tagged release; only the current `main`
branch receives security fixes.

| Version | Security fixes |
|---------|---------------|
| `main` | ✅ Yes |

## Reporting a vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

### Option 1 — GitHub private vulnerability reporting (preferred)

Use GitHub's built-in private advisory flow:
<https://github.com/tkdtaylor/create-project/security/advisories/new>

### Option 2 — Email

Send a report to <tools@taylorguard.me> with a description, reproduction
steps, the commit you observed it on, and your severity assessment.

## Response expectations

- **Acknowledgement:** within 7 days. **Status update:** within 30 days.
- **Fix shipped:** within 90 days for confirmed vulnerabilities (critical
  issues target 14 days).

## Scope

**In scope:** anything the scaffold writes into a user's project that would
weaken it — hook scripts that execute unexpected commands, templates that
embed insecure defaults (e.g. unverified curl-pipe installs), settings that
grant broader permissions than documented.

**Out of scope:** vulnerabilities in the tools the templates merely
recommend (report upstream), and findings requiring an already-compromised
host.

## Maintainer note

After merging this file, enable **Settings → Code security and analysis →
Private vulnerability reporting** so the "Report a vulnerability" button is
visible on the repo page.
