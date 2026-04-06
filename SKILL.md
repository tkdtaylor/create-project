---
name: create-project
description: Invoke immediately when a user announces they are starting or creating something new — any phrasing like "start a project", "set up a project", "create a project", "I'm starting a new [X]", "set up a [X] project for me", or "scaffold a codebase". The domain doesn't matter — software builds (CLI, API, data pipeline, library), research investigations (competitive analysis, literature review), or non-technical work (planning, tracking, decision-making) all qualify. The key signal is the user declaring a fresh start, not asking for help with existing work. Scaffolds the full workspace: directories, task files, CLAUDE.md, git init, and tooling recommendations. Do not invoke when the user is modifying, debugging, adding features to, or writing config for an existing codebase.
---

# Create Project

Scaffolds a new project with a structure matched to what's actually being built. The core principle is the same across all types: separate **inputs** (what guides the work) from **outputs** (what the work produces), and break work into small, focused tasks.

## Secrets handling — never accept sensitive values in chat

**Never ask the user to paste a PAT, API key, password, or any other secret into the conversation.** The user should edit files like `.env` directly themselves. Your job is to create the file with blank placeholders and tell the user which values to fill in and where to source each one.

This applies to:
- GitHub personal access tokens (`GIT_TOKEN`)
- Anthropic API keys (`ANTHROPIC_API_KEY`)
- Database connection strings with passwords
- Any third-party service credentials

If a user offers a secret in chat, refuse politely and ask them to put it directly into the relevant file instead. Do not echo, log, or write secrets to transcript files.

---

## Step 1 — Interview the user

The goal of this step is to reach **high confidence** that you understand the project well enough to make a plan and execute it — not just to collect a name and type. Do not rush to scaffold. A project built on a fuzzy goal produces wasted structure.

Check `$ARGUMENTS` and the current directory name for any starting context.

### 1a — Open the interview

Start with a single opening message. Don't fire every question at once — lead with what you need most and let the conversation develop naturally:

- What are they building or investigating, and why?
- Who is it for — themselves, a team, end users, stakeholders?
- What does **done** look like? How will they know it worked?

### 1b — Probe until the goal is unambiguous

After each answer, evaluate whether you could write the first task right now with clear acceptance criteria. If not, keep asking. Good follow-up angles:

- **Scope**: What's in, what's explicitly out?
- **Constraints**: Deadlines, tech choices already decided, dependencies on other systems?
- **Unknowns**: What are they most uncertain about? Is there prior work, existing code, or research to build on?
- **Success bar**: What would make this a failure even if it's "done"?

Push on vague answers. "Build an API" is not enough — what does it serve, what data flows through it, what calls it? "Do some research" is not enough — what decision does the research inform, and what form does the output take?

Keep rounds short. One or two focused questions per message — don't interrogate in walls of text.

### 1c — Confirm understanding before proceeding

Once you believe you have enough to plan, write a concise summary:

- What is being built / investigated
- Who it's for and what problem it solves
- What the end state looks like (definition of done)
- Any key constraints or known unknowns

Then ask: *"Does this capture it accurately, or is there anything missing before I set up the project?"*

Do not move to Step 2 until the user confirms the summary is correct. If they correct or expand it, update your understanding and re-confirm.

### Project types

| Type | Choose when... |
|------|---------------|
| **technical** | Building software — web app, CLI, API, library, script, automation |
| **data** | Data science or machine learning — model training, data pipelines, analytics, experiment-driven work with notebooks and datasets |
| **research** | Synthesizing information — literature review, competitive analysis, topic investigation, report writing, summarizing documents |
| **other** | Neither fits well — planning, tracking, organising, decision support. Uses the research base structure but with domain-specific top-level folders. Ask one follow-up: "What are the main categories you need to track?" then create named folders for those (e.g. `contractors/`, `costs/`, `timeline/` for a renovation; `decisions/`, `stakeholders/`, `risks/` for a project plan). |

Determine the project type from the conversation — only ask explicitly if it is genuinely unclear after the interview.

---

## Step 2 — Set up project structure

Based on the project type, read the appropriate reference file and follow it completely before returning to Step 3:

- **technical** → read and follow `$CLAUDE_SKILL_DIR/references/tech-project.md`
- **data** → read and follow `$CLAUDE_SKILL_DIR/references/data-project.md`
- **research** or **other** → read and follow `$CLAUDE_SKILL_DIR/references/research-project.md`

The reference file covers: directory structure, template files, CLAUDE.md, first task offer, and git initialization.

---

## Step 3 — Configure tooling & enrich CLAUDE.md

This step runs after the type-specific setup and uses the full project context — type, description, tech stack — to do three things: enrich the CLAUDE.md that was just created, recommend ecosystem tools, and surface anything that would make future sessions more productive.

Read `$CLAUDE_SKILL_DIR/references/tooling.md` before starting — it contains the full catalog and matching logic for all recommendations below.

### Tool preference order

When recommending tools in the steps below, apply this preference order:

1. **Skills** — lightweight, on-demand, no background process. The default choice.
2. **Hooks** — for automated behaviors that should happen every time (pre-commit, post-edit, etc.)
3. **Agents** — for reusable role-based workflows within the project
4. **External CLI tools** — standalone tools invoked via Bash (e.g. `dep-scan`, `gh`, `psql`)
5. **MCP servers — almost never.** Most things people install MCPs for are already covered by built-in tools (WebSearch, WebFetch) or CLI commands via Bash (`gh`, `psql`, `sqlite3`). The only MCP that consistently adds value is `puppeteer` for browser automation. Do not recommend GitHub, search, fetch, database, or memory MCPs — they are redundant.

### 3a — Enrich CLAUDE.md

Read the `CLAUDE.md` at the project root. Append a `## Recommended tooling` section. This section stays in CLAUDE.md so future sessions know what tools are available without being told again.

Use the project context to write real content — not a copy of the catalog, but a curated short list with a sentence on why each tool is relevant *to this specific project*. Follow the tool preference order above. Include:

- **Skills**: name, trigger phrase, why it applies here *(list these first)*
- **Hooks**: what event, what it runs, stub command
- **Agents**: name, when to invoke, tier *(covered in 3d)*
- **External CLI tools**: name, purpose, install command — e.g. `dep-scan` for any project with external package dependencies

Do not include an MCP section unless the project has a genuine need that no built-in tool or CLI covers (see 3c).

Cap it at what's genuinely useful. Three targeted suggestions beat ten generic ones. If nothing in the catalog clearly applies, say so and skip the section.

Example format to append:

```markdown
## Recommended tooling

### Skills
- **code-scanner** — run before shipping. Trigger: "scan this for vulnerabilities"
- **simplify** — review changed code after heavy implementation. Trigger: "simplify this module"

### Hooks
- Pre-commit lint: runs `npm run lint` before every git commit (add via `/update-config`)

### External tools
- **dep-scan** — scans npm/pypi/cargo/go packages for supply-chain attacks before install. Use `npmds` / `pipds` / `cargods` / `gods` wrappers. Install: `curl -fsSL https://raw.githubusercontent.com/tkdtaylor/dep-scan/main/install.sh | bash`
```

### 3b — Installed skills *(recommend first)*

```bash
ls ~/.claude/skills/
```

Read the `name` and `description` frontmatter from each skill's `SKILL.md`. Cross-reference against the project using the matching table in `references/tooling.md`. Present relevant installed skills as a short table: name, one-line description, why it applies.

Then check for skills in the catalog that are *not* installed but would be useful. Suggest installing them before moving on to MCP recommendations — skills are the preferred tooling type.

### 3c — MCP servers *(rarely needed)*

Most things MCPs do are already covered by built-in tools (WebSearch, WebFetch) or CLI commands via Bash (`gh`, `psql`, `sqlite3`). See the comparison table in `references/tooling.md` — the only MCP that consistently adds value is `puppeteer` for browser automation.

**Do not recommend an MCP if a built-in tool or CLI covers the need.** The GitHub MCP is not needed when `gh` is available. Search MCPs are not needed when WebSearch exists. Database MCPs are not needed when the CLI client is available via Bash.

Only recommend an MCP when:
- The user specifically asks for one
- The capability genuinely has no built-in or CLI alternative (e.g. `puppeteer` for web UI testing)

If the project is a web app that needs browser testing, recommend `puppeteer`. For everything else, skip this section.

### 3d — Hooks and agents

**Hooks** run shell commands automatically in response to Claude Code events (before/after tool calls, on session start, etc.). Suggest hooks that would genuinely reduce friction for this project type. Use the catalog in `references/tooling.md` for patterns, then tailor to the actual tech stack.

To configure hooks: tell the user to use `/update-config` or point them to `.claude/settings.json`.

**Agents** are reusable instruction sets that let Claude take on a specific role or workflow for this project. They live in `.claude/agents/` and are invoked naturally in conversation: *"use the architect agent to review this design"*.

#### Step 1 of 3d — Detect available models (always run, even if no new agents are created)

The type-specific setup (T2/D2/R2) copied a `task-executor.md` agent with `model: inherit` and a `# model-tier: fast` comment. Before creating any additional agents, detect the models available in the current session and **update all existing agents in `.claude/agents/`** to use the best-matching model for their tier.

1. **List models accessible in this session.** In Claude Code, check via the `/model` command output or the model config. In other tools (Cursor, Windsurf, etc.), the model is usually a UI setting — in that case leave everything on `inherit`.

2. **Map tiers to concrete model identifiers** using the guidance in `references/tooling.md`:
   - `fast` → fastest capable model (e.g. `haiku` or `sonnet` if haiku unavailable)
   - `balanced` → middle-tier model (e.g. `sonnet`)
   - `deep` → most capable model (e.g. `opus`)
   - If you can only see one model or can't determine the options, use `inherit` for every tier.

3. **Update every file in `.claude/agents/`** — read each file, find the `# model-tier:` comment, and set the `model:` field to the mapped value. **Preserve the `# model-tier:` comment so future users can see why the model was chosen and adjust it if they switch tools or gain access to different models.**

4. **Report to the user** what mapping you applied, e.g. *"Agents configured: task-executor (tier: fast) → sonnet. Available models: sonnet, opus."*

#### Step 2 of 3d — Add new agents

Use the subtype guidance table in `references/tooling.md` to select 3–4 agents that fit this specific project — not a generic list. For a REST API project that's different from a CLI tool or data pipeline. Present each one in CLAUDE.md with a one-liner on what it does and when to invoke it.

Then ask: *"Would you like me to create these agent files now? I can write `.claude/agents/<name>.md` for each so you can start using them immediately."*

If yes: write each agent file using the format in `references/tooling.md`, setting the `model:` field from the tier mapping you established in Step 1 and including the `# model-tier:` comment. Populate the instructions with project-specific context — reference actual file paths, the tech stack, and the project's CLAUDE.md conventions. Don't use generic placeholder text.

For **research projects**, always create source-evaluator and outline-builder at minimum. gap-analyst is worth adding if the project has a well-defined output (report, paper, analysis).

If no new agents are warranted (e.g. a simple one-off script), still run Step 1 to configure the task-executor's model, then skip creating additional agents.

After completing 3a–3d, commit everything created or modified in this step:
```bash
git add CLAUDE.md
test -d .claude/agents/ && git add .claude/agents/ || true
git diff --cached --quiet || git commit -m "chore: add project agents and tooling recommendations"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

---

## File naming conventions (all project types)

| Type | Pattern | Example |
|------|---------|---------|
| Task | `NNN-short-name.md` | `003-summarize-chapter-2.md` |
| ADR (tech only) | `NNN-decision-title.md` | `001-use-postgres.md` |
| Sprint (tech only) | `YYYY-MM-sprint-N.md` | `2026-01-sprint-1.md` |

Numbers are zero-padded to three digits, sequential across all task states combined (active + backlog + completed).

---

## Adding tasks later

When asked to add a task to an existing project:
1. Count files across `tasks/active/`, `tasks/backlog/`, and `tasks/completed/` to find the next ID
2. For **technical projects**: create the test spec first, then the task file
3. For **research projects**: create the task file directly — the research question and "done when" criteria serve as the spec
4. Add a row to the coverage or progress tracker
5. Commit and push immediately:
   ```bash
   git add docs/tasks/
   git commit -m "test: add spec for task NNN — <name>"
   git push
   ```

**Important: you must commit and push after every milestone. Never start the next task without committing the current one first. Do not batch multiple tasks into a single commit.**

When a **technical** task is completed:
1. Move the task file from `tasks/active/` to `tasks/completed/`
2. Update the status in `coverage-tracker.md`
3. Commit and push before starting anything else:
   ```bash
   git add src/ docs/tasks/ docs/tasks/test-specs/coverage-tracker.md
   git commit -m "feat: complete task NNN — <name>"
   git push
   ```

When a **research** task is completed:
1. Move the task file from `tasks/active/` to `tasks/completed/`
2. Update the status in `progress-tracker.md`
3. Commit and push before starting anything else:
   ```bash
   git add sources/ notes/ docs/tasks/ docs/research-log.md docs/tasks/progress-tracker.md
   git commit -m "research: complete task NNN — <name>"
   git push
   ```

When an ADR is written (tech), commit and push immediately:
```bash
git add docs/architecture/decisions/
git commit -m "docs: add ADR NNN — <decision title>"
git push
```

When an outline is updated (research), commit and push immediately:
```bash
git add docs/outline.md
git commit -m "docs: update outline — <what changed>"
git push
```
