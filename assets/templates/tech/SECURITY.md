# Security Policy

> This file is a starter template. **For private/internal-only projects**, replace the
> reporting channels with your internal escalation path (on-call, incident tracker) and
> delete the GitHub-advisories option. Fill every {{PLACEHOLDER}} before publishing.

## Supported versions

| Version | Security fixes |
|---------|---------------|
| `main` (pre-release) | ✅ Yes |

> Update this table once tagged releases exist — state which release lines receive fixes.

## Reporting a vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**
A public report exposes the flaw to everyone before a fix is available.

### Option 1 — GitHub private vulnerability reporting (preferred)

Use GitHub's built-in private advisory flow:
<https://github.com/{{GITHUB_OWNER}}/{{PROJECT_NAME}}/security/advisories/new>

> Maintainer: enable **Settings → Code security and analysis → Private vulnerability
> reporting** so this button exists, then delete this callout.

### Option 2 — Email

Send a report to <{{SECURITY_CONTACT_EMAIL}}> with:

- A concise description of the vulnerability
- Reproduction steps
- The commit, tag, or `main` state you observed it on
- Your assessment of severity (CVSS or plain English is fine)

## Response expectations

- **Acknowledgement:** within 7 days of receipt.
- **Status update:** within 30 days (triaged, confirmed, or declined with reasoning).
- **Fix shipped:** within 90 days for confirmed vulnerabilities; critical issues
  (CVSS ≥ 9.0) target a 14-day patch window.

## Scope

> List what is in and out of scope. Good in-scope examples: authentication/authorization
> bypasses, injection paths, data exposure, anything that violates a documented security
> invariant of this project. Good out-of-scope examples: vulnerabilities in upstream
> dependencies (report upstream), findings requiring an already-compromised host,
> missing hardening on explicitly non-production surfaces.

**In scope:**

- {{IN_SCOPE_ITEM}}

**Out of scope:**

- {{OUT_OF_SCOPE_ITEM}}

## Recognition

Reporters are credited in the changelog and release notes unless they request
anonymity.
