---
name: create-project
description: Invoke immediately when a user announces they are starting or creating something new — any phrasing like "start a project", "set up a project", "create a project", "I'm starting a new [X]", "set up a [X] project for me", or "scaffold a codebase". The domain doesn't matter — software builds (CLI, API, data pipeline, library), research investigations (competitive analysis, literature review), or non-technical work (planning, tracking, decision-making) all qualify. The key signal is the user declaring a fresh start, not asking for help with existing work. Scaffolds the full workspace: directories, task files, CLAUDE.md, git init, and tooling recommendations. Do not invoke when the user is modifying, debugging, adding features to, or writing config for an existing codebase.
---

# Create Project

Scaffolds a new project with a structure matched to what's actually being built. The core principle is the same across all types: separate **inputs** (what guides the work) from **outputs** (what the work produces), and break work into small, focused tasks.

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
| **technical** | Building software — web app, CLI, API, library, script, data pipeline, automation |
| **research** | Synthesizing information — literature review, competitive analysis, topic investigation, report writing, summarizing documents |
| **other** | Neither fits well — planning, tracking, organising, decision support. Uses the research base structure but with domain-specific top-level folders. Ask one follow-up: "What are the main categories you need to track?" then create named folders for those (e.g. `contractors/`, `costs/`, `timeline/` for a renovation; `decisions/`, `stakeholders/`, `risks/` for a project plan). |

Determine the project type from the conversation — only ask explicitly if it is genuinely unclear after the interview.

---

## Step 2 — Set up project structure

Based on the project type, read the appropriate reference file and follow it completely before returning to Step 3:

- **technical** → read and follow `$CLAUDE_SKILL_DIR/references/tech-project.md`
- **research** or **other** → read and follow `$CLAUDE_SKILL_DIR/references/research-project.md`

The reference file covers: directory structure, template files, CLAUDE.md, first task offer, and git initialization.

---

## Step 3 — Configure tooling & enrich CLAUDE.md

This step runs after the type-specific setup and uses the full project context — type, description, tech stack — to do three things: enrich the CLAUDE.md that was just created, recommend ecosystem tools, and surface anything that would make future sessions more productive.

Read `$CLAUDE_SKILL_DIR/references/tooling.md` before starting — it contains the full catalog and matching logic for all recommendations below.

### 3a — Enrich CLAUDE.md

Read the `CLAUDE.md` at the project root. Append a `## Recommended tooling` section. This section stays in CLAUDE.md so future sessions know what tools are available without being told again.

Use the project context to write real content — not a copy of the catalog, but a curated short list with a sentence on why each tool is relevant *to this specific project*. Include:

- **MCP servers**: name, one-line purpose, install command
- **Skills**: name, trigger phrase, why it applies here
- **Hooks**: what event, what it runs, stub command

Cap it at what's genuinely useful. Three targeted suggestions beat ten generic ones. If nothing in the catalog clearly applies, say so and skip the section.

Example format to append:

```markdown
## Recommended tooling

### MCP servers
- **brave-search** — web search during research sessions. Install: `claude mcp add brave-search ...`

### Skills
- **code-scanner** — run before shipping. Trigger: "scan this for vulnerabilities"

### Hooks
- Pre-commit lint: runs `npm run lint` before every git commit (add via `/update-config`)
```

### 3b — Installed skills

```bash
ls ~/.claude/skills/
```

Read the `name` and `description` frontmatter from each skill's `SKILL.md`. Cross-reference against the project using the matching table in `references/tooling.md`. Present relevant installed skills as a short table: name, one-line description, why it applies.

### 3c — MCP servers

Using the catalog in `references/tooling.md`, identify MCP servers that fit the project. For each:
- Name and what it unlocks
- Why it's relevant to this project
- Install command or link

Then do a targeted web search to catch anything not in the catalog:
- `Claude Code MCP [tech-stack or domain]`
- `site:github.com modelcontextprotocol server [relevant-domain]`

Surface anything relevant with source URL. Don't install — present options and let the user choose.

### 3d — Hooks and agents

**Hooks** run shell commands automatically in response to Claude Code events (before/after tool calls, on session start, etc.). Suggest hooks that would genuinely reduce friction for this project type. Use the catalog in `references/tooling.md` for patterns, then tailor to the actual tech stack.

To configure hooks: tell the user to use `/update-config` or point them to `.claude/settings.json`.

**Agents** are reusable instruction sets that let Claude take on a specific role or workflow for this project. They live in `.claude/agents/` and are invoked naturally in conversation: *"use the architect agent to review this design"*.

Use the subtype guidance table in `references/tooling.md` to select 3–4 agents that fit this specific project — not a generic list. For a REST API project that's different from a CLI tool or data pipeline. Present each one in CLAUDE.md with a one-liner on what it does and when to invoke it.

Then ask: *"Would you like me to create these agent files now? I can write `.claude/agents/<name>.md` for each so you can start using them immediately."*

If yes, write each agent file using the format in `references/tooling.md`. Populate the instructions with project-specific context — reference actual file paths, the tech stack, and the project's CLAUDE.md conventions. Don't use generic placeholder text.

For **research projects**, always create source-evaluator and outline-builder at minimum. gap-analyst is worth adding if the project has a well-defined output (report, paper, analysis).

If no agents are clearly warranted (e.g. a simple one-off script), say so and skip rather than padding.

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
