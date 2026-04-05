# Tooling Catalog

Reference for Step 3 — matching project signals to tools from the Claude Code ecosystem. Use this to populate recommendations and the CLAUDE.md `## Recommended tooling` section.

## Preference order

When recommending tools, prefer them in this order:

1. **Skills** — lightweight, on-demand, no background process. The default choice.
2. **Hooks** — for automated behaviors that run on specific events.
3. **Agents** — for reusable role-based workflows within the project.
4. **MCP servers** — only when a skill can't do the job.

**Why skills first:** a skill adds zero cost when not in use — it's just a markdown file on disk that Claude loads when the user describes a matching task. An MCP server adds tools to every session (context overhead), often needs auth configuration, and runs as a background process. Skills are easier to install, easier to share, and don't affect cold-start performance.

**When to prefer an MCP:** only when you need something a skill genuinely cannot provide via task descriptions alone:
- Live data access (databases, streaming APIs, real-time metrics)
- Authenticated external services where the auth must persist across calls
- Tool integration that requires stateful connections

If a skill already exists for the need, always recommend the skill.

---

## Skills

Skills are instruction sets that extend Claude's behavior for specific workflows. They're invoked by describing a task that matches their description. **This is the preferred tool type — recommend a skill whenever one covers the need.**

### Matching table

| Project signal | Skill | Why |
|----------------|-------|-----|
| Any project | `skill-creator` | Build custom skills for this project's recurring workflows — especially useful once the project has repeated multi-step patterns |
| Any project (if hooks will be configured) | `update-config` | Adds/edits hooks in `.claude/settings.json` without manual JSON editing. Relevant whenever a hook is being recommended. |
| Technical project, pre-shipping | `code-scanner` | Scans for supply-chain attacks, backdoors, and credential harvesting in dependencies and new packages |
| Technical project with iterative code changes | `simplify` | Reviews changed code for over-engineering, dead code, and reuse opportunities — good to suggest after heavy implementation sprints |
| Any technical project | `agent-skills` collection | Production-grade SDLC workflow skills — spec writing, TDD, code review, debugging, security hardening, git workflow, and more. Not a single skill but a collection to install individually as needed. See [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) |
| Building with Claude API or Anthropic SDK | `claude-api` | Best-practice patterns for Claude API usage, streaming, tool use, and agent loops |
| Binary analysis, CTF, security research | `reverse-engineer` | Ghidra-based decompilation in a sandboxed Docker container |
| Project with recurring checks or polling | `loop` | Runs a prompt or command on a configurable interval — useful for build status, test-watch, or research progress checks |
| Project needing scheduled automation | `schedule` | Creates cron-style scheduled Claude agents — useful for daily report generation, automated syncs, or timed reminders |

### How to find more

Web search: `Claude Code skill [domain]` or `site:github.com .skill [domain]`

To install a `.skill` file: drag it into Claude Code, or `claude skill install <path>`.

---

## External CLI tools

Standalone tools that aren't skills or MCPs but are worth recommending during project setup.

### dep-scan

**Purpose:** Scans dependencies for supply-chain attacks (typosquatting, malicious install scripts, suspicious maintainer changes, known vulnerabilities) *before* they are installed. Six security policies: package age, install scripts, typosquatting, OSV.dev vulnerability checks, maintainer changes, dependency confusion.

**Supported ecosystems:** npm, PyPI, crates.io, Go modules

**Install:**
```bash
curl -fsSL https://raw.githubusercontent.com/tkdtaylor/dep-scan/main/install.sh | bash
```

**Usage:** Use drop-in wrappers (`npmds`, `pipds`, `cargods`, `gods`) that scan before installing, or invoke the CLI directly in CI.

**Recommend for:**
- **Technical projects** using npm (`package.json`), PyPI (`requirements.txt`, `pyproject.toml`), Cargo (`Cargo.toml`), or Go modules (`go.mod`)
- **Data/ML projects** — they install from PyPI and often pull in large dependency trees where a single malicious package can exfiltrate training data or credentials

**Not relevant for:**
- Projects with no external dependencies
- Pure research projects that don't install packages
- Non-code projects (planning, tracking, "other")

**Repo:** [tkdtaylor/dep-scan](https://github.com/tkdtaylor/dep-scan)

---

## MCP Servers

MCP (Model Context Protocol) servers extend what Claude can do in a session — giving it access to tools, databases, APIs, and services. They're configured in `.claude/settings.json` or via `claude mcp add`.

**Before recommending an MCP, check if a skill covers the need.** MCPs add context overhead to every session and require auth configuration. Only use them for things skills genuinely can't do: live data, authenticated services, or stateful integrations.

### Catalog

#### Web & research

| Server | What it unlocks | Install |
|--------|----------------|---------|
| `brave-search` | Web search with Brave — good for research and fact-checking | `claude mcp add brave-search -e BRAVE_API_KEY=<key> npx @modelcontextprotocol/server-brave-search` |
| `tavily` | Search API tuned for LLM use — returns clean, relevant results | `claude mcp add tavily npx tavily-mcp` (requires `TAVILY_API_KEY`) |
| `exa` | Semantic web search — finds pages by meaning, not just keywords | `claude mcp add exa npx exa-mcp-server` (requires `EXA_API_KEY`) |
| `fetch` | Fetch any URL and return clean markdown — no API key needed | `claude mcp add fetch npx @modelcontextprotocol/server-fetch` |

#### Memory & knowledge

| Server | What it unlocks | Install |
|--------|----------------|---------|
| `memory` | Persistent knowledge graph across sessions — store and recall entities and relationships | `claude mcp add memory npx @modelcontextprotocol/server-memory` |

#### Development

| Server | What it unlocks | Install |
|--------|----------------|---------|
| `github` | Read/write GitHub repos, PRs, issues, code search — without leaving Claude | `claude mcp add github -e GITHUB_TOKEN=<token> npx @modelcontextprotocol/server-github` |
| `postgres` | Query and inspect a Postgres database | `claude mcp add postgres npx @modelcontextprotocol/server-postgres <connection-string>` |
| `sqlite` | Read and query SQLite files | `claude mcp add sqlite npx @modelcontextprotocol/server-sqlite --db-path <path>` |
| `puppeteer` | Browser automation — useful for testing web UIs or scraping | `claude mcp add puppeteer npx @modelcontextprotocol/server-puppeteer` |

#### Productivity & files

| Server | What it unlocks | Install |
|--------|----------------|---------|
| `filesystem` | Scoped file access outside the current directory | `claude mcp add filesystem npx @modelcontextprotocol/server-filesystem <allowed-paths>` |
| `obsidian` | Read and write an Obsidian vault — useful for research and note-heavy projects | See `mcp-obsidian` on npm |
| `gdrive` | Read files from Google Drive | `claude mcp add gdrive npx @modelcontextprotocol/server-gdrive` |

### Matching by project type

Only recommend these MCPs if no skill covers the need. For each one listed below, the justification is in the parentheses — if that rationale doesn't apply to the project, skip it.

**Research project:**
- `brave-search` / `tavily` / `exa` (live web search with a specific provider — WebSearch tool or a search skill covers this for most cases; only recommend if the user wants a specific provider or needs features WebSearch doesn't have)
- `fetch` (one-off URL fetching — WebFetch tool covers this; only recommend if the project will be fetching many URLs programmatically)
- `memory` (persistent knowledge graph — only if findings genuinely need cross-session recall beyond what `docs/research-log.md` provides)
- `filesystem` (scoped file access outside the project directory — genuine need, no skill alternative)
- `obsidian` (live Obsidian vault integration — genuine need if the user keeps notes there)

**Technical project:**
- `github` (live PR review, issue tracking, code search — genuine need, no skill can do this without the API)
- `postgres` / `sqlite` (live database queries during development — genuine need, no skill alternative)
- `puppeteer` (browser automation for testing — genuine need, no skill alternative)

**Both:**
- Most cross-cutting needs (scanning code, simplifying, writing docs, reviewing) are better served by skills — see the skills matching table above.

### Finding more

```
site:github.com modelcontextprotocol server
```

The official registry: https://github.com/modelcontextprotocol/servers

---

## Hooks

Hooks are shell commands that Claude Code runs automatically at specific points in a session. They're configured in `.claude/settings.json` (or via `/update-config`).

### Hook events

| Event | Fires when |
|-------|-----------|
| `PreToolUse` | Before Claude calls any tool |
| `PostToolUse` | After a tool call completes |
| `Stop` | When Claude finishes a response turn |
| `Notification` | When Claude sends a notification |

### Patterns by project type

**Technical projects:**

```json
// Run linter after every file edit
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{"type": "command", "command": "npm run lint --silent 2>&1 | head -20"}]
    }]
  }
}
```

```json
// Run tests after edits to src/
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{"type": "command", "command": "npm test --silent 2>&1 | tail -10"}]
    }]
  }
}
```

```json
// Warn before any Bash command (review before execute)
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{"type": "command", "command": "echo 'Review the command above before approving'"}]
    }]
  }
}
```

**Research projects:**

```json
// Append a timestamp to research-log.md when a WebSearch tool is used
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "WebSearch",
      "hooks": [{"type": "command", "command": "echo '- Search at '$(date '+%Y-%m-%d %H:%M') >> docs/research-log.md"}]
    }]
  }
}
```

Tell the user: hooks are configured in `.claude/settings.json`. Use `/update-config` to add them without editing the file manually.

---

## Agents

Custom agents are instruction sets for specialized sub-tasks within a project. They're invoked via the Agent tool with a path or defined agent type. Store them in `.claude/agents/` in the project root.

### When to suggest a custom agent

A custom agent is worth creating when:
- The same multi-step workflow will be repeated across many sessions
- The task requires a different context or set of constraints than the main session
- You want to isolate a risky or noisy operation (e.g. bulk file changes)

Always offer to **create the agent files** — not just list them in CLAUDE.md. Write each suggested agent to `.claude/agents/<name>.md` at the project root so the user can invoke them immediately. If the user declines, just document them in CLAUDE.md.

### Technical project agents

Suggest these as role-based agents that inhabit a specific perspective on the codebase. Choose the subset that matches what this project will actually need — not all are relevant to every project type.

**architect** *(tier: deep)*
Reviews proposed features, data model changes, and service boundaries against `docs/architecture/overview.md`. Flags design inconsistencies, identifies unexpected coupling, and drafts ADRs when a non-obvious decision was made. Knows the system's current shape and asks "does this fit?" before "how do we build this?".
Invoke: *"use the architect agent to review this design"* or *"draft an ADR for [decision]"*
Best for: API design, schema changes, adding new services, any choice that will be hard to reverse.

**task-planner** *(tier: balanced)*
Takes a feature description and produces a paired task file + test spec following the project's naming conventions. Asks clarifying questions about edge cases and acceptance criteria before writing anything — the output is a well-scoped task, not a vague to-do.
Invoke: *"use the task-planner to break down [feature]"*
Best for: features with unclear scope, anything that touches multiple layers, or when you're not sure where to start.

**code-reviewer** *(tier: balanced)*
Reviews changed files against the architecture docs, coding conventions, and the test spec for the current task. Flags drift from the agreed design, missing coverage, and common mistakes for this stack. Reads the task spec first so it understands what "done" means.
Invoke: *"use the code-reviewer on these changes"*
Best for: before committing a task, especially after a long implementation session.

**qa** *(tier: balanced)*
Reads the test spec for the current task, runs the test suite, and reports failures with context from the relevant source files. Identifies missing test cases based on the spec's acceptance criteria. Understands the difference between a test gap and a genuine bug.
Invoke: *"use the qa agent on task 003"*
Best for: after implementation is complete, before marking a task done.

**dependency-auditor** *(tier: fast)*
Reads the project's dependency manifest (`package.json`, `requirements.txt`, `go.mod`, etc.), identifies outdated or CVE-flagged packages, and proposes a pinned upgrade path. Checks for packages that have been abandoned or forked under suspicious names.
Invoke: *"use the dependency-auditor"*
Best for: before releases, after a long period without updates, or when adding a batch of new dependencies.

**docs-writer** *(tier: fast)*
Generates or updates README sections, API reference docs, inline docstrings, and changelog entries from the current source code. Follows the audience and tone set in CLAUDE.md. Doesn't invent behavior — only documents what the code actually does.
Invoke: *"use the docs-writer to document [module or endpoint]"*
Best for: libraries, public APIs, or any project where docs chronically lag behind the code.

**security-auditor** *(tier: deep)*
Reviews source code for OWASP Top 10 vulnerabilities, insecure defaults, secrets committed in code, and injection risks in user-facing paths. Works from source files — complements the `code-scanner` skill (which focuses on supply-chain attacks in dependencies rather than application code).
Invoke: *"use the security-auditor on the auth module"* or *"run a security pass before we ship"*
Best for: projects handling user input, authentication, payment data, or any externally-facing surface.

### Technical project subtype guidance

Not every agent fits every project. Pick 3–4 that genuinely apply:

| Project subtype | Recommended agents |
|----------------|--------------------|
| REST / GraphQL API | architect, code-reviewer, security-auditor, docs-writer |
| CLI tool | task-planner, qa, docs-writer |
| Library / SDK | code-reviewer, docs-writer, dependency-auditor |
| Data pipeline | architect, qa, dependency-auditor |
| Web app (frontend-heavy) | architect, code-reviewer, qa, security-auditor |
| Internal script / one-off | task-planner — others likely overkill |

### Research project agents

**source-evaluator** *(tier: balanced)*
Assesses a URL or document for relevance and credibility: source type (primary/secondary/tertiary), publication date, author credentials, methodology quality, and alignment with the active research question. Logs the verdict and key quotes to `docs/research-log.md`. Skips sources that are clearly out of scope rather than writing a full evaluation.
Invoke: *"use the source-evaluator on [URL or filename]"*
Best for: filtering a large batch of sources quickly, or vetting a high-stakes claim before including it in an output.

**outline-builder** *(tier: balanced)*
Takes accumulated notes from `notes/by-topic/` and proposes an updated `docs/outline.md` structured for the target output type (report, blog post, analysis, literature review). Highlights thin sections where notes are sparse and flags gaps that need more research before writing.
Invoke: *"use the outline-builder to update the outline"*
Best for: after a research sprint, before committing to a draft structure.

**gap-analyst** *(tier: deep)*
Reviews the current outline and notes to find what's missing: unanswered research questions, underexplored counterarguments, missing data points, and unsupported claims that need a source. Produces a prioritized list of gaps with suggested searches or sources to close each one.
Invoke: *"use the gap-analyst before I start writing"*
Best for: end-of-sprint checkpoint, especially when the outline feels complete but something seems off.

**summary-writer** *(tier: fast)*
Drafts a section of `outputs/drafts/` from the notes for that topic, following the tone and audience defined in CLAUDE.md. Stays faithful to the source material — flags anything that would require inference rather than just paraphrasing it in.
Invoke: *"use the summary-writer for [section name]"*
Best for: translating dense research notes into readable prose without losing nuance or accuracy.

### Model routing for agents

Agents should use the right model for the job — not the most expensive one for every task. Assign each agent a **tier** based on what it does, then map that tier to the best available model at project creation time.

#### Tiers

| Tier | Use for | Examples |
|------|---------|---------|
| **fast** | Scoped, mechanical work with clear instructions — the task spec defines what to do | task-executor, docs-writer, summary-writer |
| **balanced** | Moderate reasoning with some judgment calls | code-reviewer, qa, source-evaluator, outline-builder |
| **deep** | Complex reasoning, architecture decisions, ambiguous problems | architect, security-auditor, gap-analyst |

#### Configuring at project creation time

**Model detection must run during setup** — don't leave agents on `inherit` if better models are available. Step 3d of the main skill flow has a dedicated sub-step for this that runs even when no new agents are being created, so the pre-copied `task-executor.md` always gets its model field configured.

The approach depends on the tool:

- **Claude Code**: Check which models the session has access to (via the `/model` command or the visible model list). Use the `model` frontmatter field. Typical mapping:
  - `fast` → fastest capable model (`haiku` if available, else `sonnet`)
  - `balanced` → middle-tier model (`sonnet`)
  - `deep` → most capable model (`opus`)
- **Cursor / Windsurf / other tools**: Model selection is usually a UI setting, not per-agent config. Leave the `model` field as `inherit` and rely on the `# model-tier:` comment to document the recommendation for the user to configure in their tool.

**Always preserve the `# model-tier:` comment** — it documents *why* the model was chosen so the user (or a future setup pass) can adjust when they switch tools or gain access to new models.

If you're unsure what models are available or can only see one, default to `inherit` — it's always safe, and the tier comment preserves the intent for future adjustment.

#### Updating model assignments later

Model availability changes over time (new models ship, subscriptions change, tools get swapped). To re-run the model mapping on an existing project:

1. List the current files in `.claude/agents/`
2. Read each file's `# model-tier:` comment
3. Map the tier to the best currently-available model
4. Update the `model:` field, keep the comment

This can be done manually or scripted.

#### Agent file format

```markdown
---
name: agent-name
description: When to invoke this agent and what it does — be specific about the trigger phrases
model: <set during project setup based on available models>
# model-tier: fast | balanced | deep
---

# Role

One sentence on the perspective this agent brings.

# Instructions

What the agent does, step by step. Include what it reads first, how it reasons, and what it produces.

# Output format

Where results go and in what form.
```

Store at `.claude/agents/<name>.md`. Invoke in a session by describing what you want: *"use the architect agent to review this design"* or *"run the gap-analyst"*.
