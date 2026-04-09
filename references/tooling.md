# Tooling Catalog

Reference for Step 3 — matching project signals to tools from the Claude Code ecosystem. Use this to populate recommendations and the CLAUDE.md `## Recommended tooling` section.

## Preference order

When recommending tools, prefer them in this order:

1. **Skills** — lightweight, on-demand, no background process. The default choice.
2. **Hooks** — for automated behaviors that run on specific events.
3. **Agents** — for reusable role-based workflows within the project.
4. **External CLI tools** — standalone tools invoked via Bash (e.g. `dep-scan`, `gh`, `psql`).
5. **MCP servers — almost never.** See the redundancy table below.

**Why skills first:** a skill adds zero cost when not in use — it's just a markdown file on disk that Claude loads when the user describes a matching task. An MCP server adds tools to every session (context overhead), often needs auth configuration, and runs as a background process.

**Why MCPs are almost always redundant:** most things people install MCPs for are already covered by built-in tools or CLI commands that Claude can invoke via Bash. The GitHub MCP is redundant with `gh`. Search MCPs are redundant with WebSearch. Database MCPs are redundant with `psql`/`sqlite3`. See the full comparison table in the MCP Servers section below.

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

### Additional skills worth evaluating

These workflow skills from [everything-claude-code](https://github.com/affaan-m/everything-claude-code) cover common patterns. Recommend when the project signal matches:

| Project signal | Skill | What it does |
|----------------|-------|-------------|
| Any project starting implementation | `search-first` | Research-before-coding: search npm/PyPI/GitHub before writing custom code. Decision matrix: Adopt / Extend / Compose / Build |
| Long autonomous sessions | `autonomous-loops` | Patterns for `claude -p` pipelines, continuous PR loops, de-sloppify cleanup |
| Complex verification needs | `verification-loop` | 6-phase chain: Build → Type Check → Lint → Test → Security Scan → Diff Review |
| Subagents losing context | `iterative-retrieval` | Dispatch → Evaluate → Refine → Loop (max 3 cycles) for subagent refinement |

**Language/framework pattern skills** (same source — install per-project as needed): `coding-standards` (TS/React), `python-patterns`, `golang-patterns`, `rust-patterns`, `springboot-patterns`, `swift-patterns`, `laravel-patterns`, `docker-patterns`, `api-design`, `codebase-onboarding`, `eval-harness`.

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

Most things MCPs do can already be done with built-in tools or CLI commands via Bash. **Only recommend an MCP when there is genuinely no built-in or CLI alternative.**

### Redundancy table

| Common suggestion | Already covered by | Verdict |
|---|---|---|
| `github` MCP | `gh` CLI via Bash — already installed and authenticated | **Skip** — `gh pr view`, `gh issue list`, etc. are equivalent |
| `brave-search` / `tavily` / `exa` | Built-in WebSearch tool | **Skip** |
| `fetch` | Built-in WebFetch tool | **Skip** |
| `memory` | `docs/research-log.md` + project docs structure | **Skip** |
| `filesystem` | Bash `cat`/`ls` — Claude already has shell access | **Skip** |
| `postgres` | `psql` CLI via Bash | **Skip** — the CLI is lighter and already available |
| `sqlite` | `sqlite3` CLI via Bash | **Skip** |

### MCPs that add genuine capability

These MCPs provide functionality that built-in tools and CLI commands cannot replicate. Recommend only when the project actually needs the capability.

| MCP | Install | When to recommend | Why it's not redundant |
|-----|---------|-------------------|----------------------|
| `puppeteer` | `claude mcp add puppeteer npx @modelcontextprotocol/server-puppeteer` | Web UI projects that need browser-based testing | No CLI equivalent for live browser automation and screenshots |
| `playwright` | `claude mcp add playwright npx @playwright/mcp@latest --extension` | Web UI projects with complex interaction testing (preferred over puppeteer for new projects) | Full browser automation with Chromium/Firefox/WebKit, visual regression testing, network interception. More capable than puppeteer. |
| `context7` | `claude mcp add context7 npx @upstash/context7-mcp@latest` | Projects using frameworks with fast-moving APIs (Next.js, Supabase, SvelteKit, etc.) | Fetches live, version-pinned documentation — prevents the agent from hallucinating deprecated APIs. Built-in WebSearch returns blog posts and Stack Overflow, not authoritative docs. |
| `sequential-thinking` | `claude mcp add sequential-thinking npx @modelcontextprotocol/server-sequential-thinking` | Complex architectural decisions, multi-constraint optimization | Provides a structured scratchpad for chain-of-thought reasoning that persists across tool calls. Useful for design decisions where the agent needs to weigh many factors. |
| `supabase` | `claude mcp add supabase npx supabase@latest -- mcp` | Supabase projects (database management, edge functions, auth) | Direct Supabase Management API access — schema introspection, migration management, and edge function deployment that the generic `psql` CLI doesn't cover. |

### MCPs for specialized workflows

These are niche but high-value when the project matches. Don't recommend proactively — suggest only if the user's workflow clearly benefits.

| MCP | Install | When to recommend | What it does |
|-----|---------|-------------------|-------------|
| `firecrawl` | `claude mcp add firecrawl npx firecrawl-mcp` | Research projects that need structured web scraping | Crawls and extracts structured data from websites. WebFetch gets a single page; Firecrawl navigates, extracts, and structures content across multiple pages. |
| `cloudflare` | See [Cloudflare MCP docs](https://developers.cloudflare.com/mcp/) | Projects deploying to Cloudflare (Workers, Pages, R2, D1) | Manages Cloudflare resources directly — deploy Workers, query D1, manage R2 buckets. CLI alternative exists (`wrangler`) but the MCP provides tighter integration. |
| `fal-ai` | `claude mcp add fal-ai npx @fal-ai/mcp-server` | Projects generating images, video, or audio | Access to fal.ai model inference — image generation, style transfer, video synthesis. No CLI equivalent. |
| `clickhouse` | `claude mcp add clickhouse npx @clickhouse/mcp-server` | Analytics projects with ClickHouse databases | Optimized ClickHouse integration with query execution, schema inspection, and cluster management. More capable than raw `clickhouse-client`. |

### When to actually recommend an MCP

An MCP is worth the overhead only when:
- The capability genuinely has no built-in tool or CLI equivalent
- The user specifically asks for one
- The integration requires a persistent stateful connection that CLI calls can't replicate

**Keep the total under 10 MCPs per project** — each one adds tools to the context window and increases token overhead per turn.

For everything else, prefer the built-in tool or CLI. If the user asks about a specific MCP, explain what built-in alternative already covers it and let them decide.

### Finding MCPs if the user wants one

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
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction |
| `Stop` | When Claude finishes a response turn |
| `Notification` | When Claude sends a notification |

### Hooks that ship with the scaffold

The following hooks are pre-configured in every scaffolded project. All hooks support profile gating via `CLAUDE_HOOK_PROFILE` (minimal/standard/strict) and `CLAUDE_DISABLED_HOOKS` environment variables.

| Hook | Event | Matcher | Profile | What it does |
|------|-------|---------|---------|-------------|
| `protect-secrets` | PreToolUse | Write\|Edit | minimal | Blocks writes to private keys, SSH keys, service accounts, auth token files |
| `block-no-verify` | PreToolUse | Bash | minimal | Blocks `--no-verify` and `--no-gpg-sign` flags on git commands |
| `config-protection` | PreToolUse | Write\|Edit | minimal | Blocks modifications to linter/formatter config files (tech/data only) |
| `restructure-plan` | PostToolUse | ExitPlanMode | standard | Splits plan steps into task files, creates test spec stubs, backs up plan |
| `edit-tracker` | PostToolUse | Edit\|Write | strict | Accumulates edited file paths for batch processing at Stop (tech/data only) |
| `pre-compact` | PreCompact | — | standard | Blocks compaction if uncommitted changes exist |
| `post-compact` | PostCompact | — | standard | Re-injects active task, spec, and branch context after compaction |
| `periodic-checkpoint` | Stop | — | standard | Reminds agent to commit every 15 turns if uncommitted changes exist |
| `strategic-compact` | Stop | — | standard | Suggests `/compact` after ~25 turns to prevent bad auto-compaction timing |
| `batch-format-typecheck` | Stop | — | strict | Batch-runs format+typecheck on all files edited this turn (tech/data only) |
| `desktop-notify` | Stop | — | strict | Sends OS desktop notification when Claude finishes responding |

### Hook profiles

Users can control hook intensity at runtime without editing `settings.json`:

```bash
# Only critical safety hooks
export CLAUDE_HOOK_PROFILE=minimal

# Safety + workflow hooks (default)
export CLAUDE_HOOK_PROFILE=standard

# Everything including formatting and notifications
export CLAUDE_HOOK_PROFILE=strict

# Disable specific hooks regardless of profile
export CLAUDE_DISABLED_HOOKS=desktop-notify,batch-format-typecheck
```

### Custom hook patterns by project type

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

### Agents that ship with the scaffold

The following agents are already created during project setup (Step T2/D2) from templates. Step 3d should detect available models and update their `model:` fields — don't recreate them, just configure them.

| Agent | Project types | Tier | Already shipped? |
|-------|--------------|------|-----------------|
| task-executor | tech, data, research | fast | Yes |
| architect | tech, data | deep | Yes |
| code-reviewer | tech, data | balanced | Yes |
| security-auditor | tech, data | deep | Yes |

### Additional technical project agents

Beyond the agents that ship with the scaffold, suggest these additional agents when the project type warrants them. Choose the subset that matches what this project will actually need.

**task-planner** *(tier: balanced)*
Takes a feature description and produces a paired task file + test spec following the project's naming conventions. Asks clarifying questions about edge cases and acceptance criteria before writing anything — the output is a well-scoped task, not a vague to-do.
Invoke: *"use the task-planner to break down [feature]"*
Best for: features with unclear scope, anything that touches multiple layers, or when you're not sure where to start.

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

### Language-specific code reviewers

For projects with a dominant language, a language-specific reviewer catches framework idiom violations that the generic code-reviewer misses. These are optional — only suggest when the project is clearly single-language or has a primary language.

**typescript-reviewer** *(tier: balanced)*
Reviews TypeScript code for strict-mode compliance, `any` escape hatches, improper type assertions, React hook dependency arrays, and Next.js-specific patterns (server vs client components, data fetching). Reports issues as critical/warning/suggestion with confidence filtering (only reports >80% confident findings).

**python-reviewer** *(tier: balanced)*
Reviews Python code for type hint coverage, Pythonic idioms (prefer list comprehensions over map/filter, use context managers), Django/FastAPI-specific patterns, and data science conventions (reproducibility, data leakage in ML pipelines).

**go-reviewer** *(tier: balanced)*
Reviews Go code for error handling patterns (wrapped errors, sentinel errors), goroutine lifecycle management, interface design (accept interfaces return structs), and idiomatic Go (early returns, table-driven tests, no init functions).

**rust-reviewer** *(tier: balanced)*
Reviews Rust code for ownership patterns, unnecessary cloning, proper error handling (Result/Option usage, no unwrap in non-test code), and idiomatic Rust (iterators over manual loops, derive macros).

To create one, use this template and fill in language-specific review criteria:

```markdown
---
name: <language>-reviewer
description: Reviews <language> code for idiomatic patterns, framework conventions, and common pitfalls
model: <set during project setup>
# model-tier: balanced
---

# Role

<Language> code reviewer with deep knowledge of <language> idioms, <framework> conventions, and common pitfalls.

# Instructions

1. Read the files being reviewed
2. Apply these review perspectives (report only findings you are >80% confident about):
   - **Correctness**: logic errors, off-by-one, race conditions
   - **Idioms**: language-specific patterns and conventions
   - **Framework**: <framework>-specific best practices
   - **Performance**: <language>-specific performance patterns
   - **Security**: input validation, injection, auth patterns

# Output format

Report findings as:
- **CRITICAL** — must fix before merging
- **WARNING** — should fix, creates tech debt
- **SUGGESTION** — optional improvement

For each finding: file, line range, category, description, suggested fix.
```

### Technical project subtype guidance

The scaffold ships architect, code-reviewer, and security-auditor by default. Use this table to decide which **additional** agents to create:

| Project subtype | Ships by default | Add these |
|----------------|-----------------|-----------|
| REST / GraphQL API | architect, code-reviewer, security-auditor | docs-writer |
| CLI tool | architect, code-reviewer, security-auditor | task-planner, qa, docs-writer |
| Library / SDK | architect, code-reviewer, security-auditor | docs-writer, dependency-auditor |
| Data pipeline | architect, code-reviewer, security-auditor | qa, dependency-auditor |
| Web app (frontend-heavy) | architect, code-reviewer, security-auditor | qa |
| Internal script / one-off | architect, code-reviewer, security-auditor | task-planner — others likely overkill |

Additionally, if the project has a clear primary language, offer to create a language-specific reviewer from the templates above.

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
