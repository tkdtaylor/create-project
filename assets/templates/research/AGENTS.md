# {{PROJECT_NAME}} — Agent briefing (canonical)

This is the **canonical, harness-neutral briefing** for {{PROJECT_NAME}}. It is the
single source of truth for project context, the research approach, conventions, the
task workflow, source-handling rules, commit rules, and the load-bearing process
rules every agent must follow.

Every coding-agent harness loads this file:

- **Codex** auto-loads `AGENTS.md` (this file).
- **Antigravity / Gemini** load it via `GEMINI.md` (a symlink to this file).
- **Claude Code** loads `CLAUDE.md`, which imports this file (`@AGENTS.md`) and adds
  the Claude-specific mechanics (subagents, plan mode, hooks).

Keep this file harness-neutral. Anything that only one harness understands belongs
in that harness's layer (`CLAUDE.md` for Claude Code), not here.

## What this is

{{PROJECT_DESCRIPTION}}

## Project structure

```
sources/       <- input materials (never edited — treat as read-only)
  local/         files the user provided
  web/           saved pages and downloaded references
notes/         <- working synthesis (scratchpad — can be messy)
  by-topic/      notes organized by research area
outputs/       <- final deliverables
  templates/     output structure templates (decision brief, research report, learning plan)
  drafts/        work in progress
  final/         completed and approved pieces
docs/          <- project management
  research-log.md   running log of searches and findings
  outline.md        target structure for the output
  agent-rules.md    process rules + project retros (the growing log of lessons)
  tasks/            active, backlog, completed
```

The key distinction: `sources/` and `docs/` are the input side, `notes/` and
`outputs/` are the output side.

## Research approach

> TODO: fill in specifics — e.g. primary domains to search, databases or journals to prioritize, geographic or time scope, intended audience for the output.

## Output templates

When starting a new output, copy the matching template from `outputs/templates/` to `outputs/drafts/` and fill it in:

- **Decision brief** (`outputs/templates/decision-brief.md`) — comparing options with a structured recommendation
- **Deep research report** (`outputs/templates/deep-research.md`) — in-depth investigation with methodology, findings, and analysis
- **Learning plan** (`outputs/templates/learning-plan.md`) — three-phase syllabus (Apprentice → Journeyman → Master)

If the output doesn't match any template, create a free-form document in `outputs/drafts/` — templates are a starting point, not a constraint.

## Conventions

- Log every search in `docs/research-log.md` — include the query, platform, date, and key result
- Save web sources worth keeping to `sources/web/` as markdown with URL + date at the top
- Notes in `notes/` are working material; only move content to `outputs/` when it's ready to share
- Tasks define a research question, not a deliverable — done means the question is **answered**, not just "searched"
- Distinguish 🟡 (sources gathered) from ✅ (question answered with citations). The `progress-tracker.md` ladder spells out which level each task earns; default to 🟡 when synthesis is incomplete — never inflate to ✅ because "I looked into it"

## Working in this project

Every research task runs on its own branch — working directly on `main` is blocked by the `no-commit-on-main.py` hook so concurrent sessions never overwrite each other's notes. `scripts/start-task.sh` is how you set it up.

1. Start each session by reading the active task file and `docs/research-log.md`
2. Check `docs/outline.md` for the target output structure
3. Implement via your harness's task-execution flow — its Step 0 runs `scripts/start-task.sh <NNN> <slug>` to create branch `task/NNN-<slug>` (or a worktree under concurrent sessions). When it prints `WORKTREE <path>`, your next command must be `cd <path>`.
4. Log every search before moving on — even dead ends
5. Save sources before synthesizing — don't rely on memory
6. When the task is done, **close it** with `scripts/finish-task.sh <NNN> <slug>` (add `--local` to merge without pushing) — it merges `task/NNN-<slug>` into `main`, deletes the branch, removes the worktree if any, and verifies all three actually happened (exiting non-zero if anything is left behind) rather than relying on you to remember each step
7. **Commit and push after each milestone** — never start the next task without committing

## Commit rules

**You must commit and push after every milestone.** Do not batch multiple tasks into one commit. Do not continue to the next task until the current one is committed and pushed.

| Milestone | What to stage | Message |
|-----------|--------------|---------|
| Task completed | `sources/`, `notes/`, `docs/tasks/`, `docs/research-log.md` | `research: complete task NNN — <name>` |
| Outline updated | `docs/outline.md` | `docs: update outline — <what changed>` |
| Draft written | `outputs/drafts/` | `docs: draft <section or output name>` |

After each milestone:
```bash
git add <relevant files>
git commit -m "<message>"
git push
```

Do **not** add a `Co-Authored-By` line to commits unless explicitly asked.

## Load-bearing process rules

These are the rules that exist specifically to stop a preventable mistake. The
**full treatment, with the incident that motivated each, lives in
`docs/agent-rules.md`** — read it. The essentials, so they reach you even without
that file loaded:

- **Commit after every milestone — now, not "after the next task too."** Batched
  commits are impossible to untangle. Log the search now too — even empty results
  prevent duplicate work next session.
- **Sources are read-only.** Never edit anything under `sources/` — they are
  reference material, not drafts. Save a web source before synthesizing from it; do
  not rely on memory.
- **Verify AI-sourced claims before they reach an output.** A model-generated fact,
  quote, or citation is a lead, not evidence — confirm it against a real source and
  cite that source. Unverifiable claims stay in `notes/`, never in `outputs/`.
- **"Done" means the question is answered, not "searched."** Default a task to 🟡
  while synthesis is incomplete; promote to ✅ only when the research question has a
  stated, sourced answer. Never inflate because "I looked into it."
- **Never `git checkout -- <path>` over uncommitted work.** It silently overwrites
  and the reflog cannot recover it. Use `git stash`, `git worktree add <ref>`, or
  `git diff <ref> -- <path>` / `git show <ref>:<path>` instead.
- **Git status must be clean before declaring a task complete.** `git status` must
  report `nothing to commit, working tree clean`. The common miss: `cp` instead of
  `git mv` when moving a task file leaves the original undeleted.

## Boundaries

### Always
- Log every search in `docs/research-log.md` — including empty results
- Save sources to `sources/web/` with URL and date before synthesizing
- Commit and push after every milestone (task completed, draft written, outline updated)
- Read the task file (including its **Verification plan**) and research log before starting work
- Default a task's progress-tracker row to 🟡 if synthesis is incomplete; only promote to ✅ when the research question has a stated, sourced answer
- Start every task on its own branch via `scripts/start-task.sh <NNN> <slug>`

### Ask first
- Modifying `docs/outline.md` — structural changes affect the whole project
- Writing to `outputs/drafts/` — only when findings are ready to draft
- Adding a new research direction not in the current task

### Never
- Edit files in `sources/` — they are reference material, not drafts
- Write to `outputs/final/` — that requires user review first
- Skip logging a search — dead ends prevent duplicate work
- Combine multiple tasks into one commit
- Add a `Co-Authored-By` line to commits unless explicitly asked
- Commit directly to `main`. Every task commit lands on `task/NNN-<slug>`. For a standalone fix to a typo or outline tweak that doesn't warrant a task, include `[allow-main]` in the commit message.
- Run `git checkout -- <path>` over a dirty working tree

## Common rationalizations

These are excuses agents use to skip steps. Don't fall for them.

| Excuse | Reality |
|--------|---------|
| "This source isn't worth saving" | Save it. You'll forget why you dismissed it, and someone else may find it useful. |
| "I'll log the search later" | Log now. Empty searches matter — they prevent duplicate work next session. |
| "I'll commit after the next task too" | No. Commit now. Batched commits are impossible to untangle later. |
| "The outline doesn't need updating for this" | If your findings change the structure, update the outline. |
| "I'll just quickly look into this tangent" | Stay on your task. Note it for later — don't scope-creep. |
| "This note is too rough to save" | Notes are supposed to be rough. Save it in `notes/` — don't lose the synthesis. |
| "The model said it, so it's probably right" | Verify it against a real source before it enters an output. A model claim is a lead, not a citation. |

## Task format for research projects

Research tasks define a question to answer, not a feature to build. A task is done
when the question is answered, not when a certain amount of effort has been spent.
See `task-template.md` for the format — the key fields are **Research question**,
**Scope**, and **Done when**.

## Resuming in a new session

Paste into the new session:
- The active task file (`docs/tasks/active/NNN-*.md`)
- `docs/research-log.md` (current status and what's been tried)
- `docs/outline.md` (the target structure)
