# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Project structure

```
sources/       <- input materials (never edited — treat as read-only)
  local/         files the user provided
  web/           saved pages and downloaded references
notes/         <- working synthesis (scratchpad — can be messy)
  by-topic/      notes organized by research area
outputs/       <- final deliverables
  drafts/        work in progress
  final/         completed and approved pieces
docs/          <- project management
  research-log.md   running log of searches and findings
  outline.md        target structure for the output
  tasks/            active, backlog, completed
```

The key distinction: `sources/` and `docs/` are the input side, `notes/` and `outputs/` are the output side.

## Research approach

> TODO: fill in specifics — e.g. primary domains to search, databases or journals to prioritize, geographic or time scope, intended audience for the output.

## Conventions

- Log every search in `docs/research-log.md` — include the query, platform, date, and key result
- Save web sources worth keeping to `sources/web/` as markdown with URL + date at the top
- Notes in `notes/` are working material; only move content to `outputs/` when it's ready to share
- Tasks define a research question, not a deliverable — done means the question is answered

## Working in this project

1. Start each session by reading the active task file and `docs/research-log.md`
2. Check `docs/outline.md` for the target output structure
3. Log every search before moving on — even dead ends
4. Save sources before synthesizing — don't rely on memory
5. **Commit and push after each milestone** — never start the next task without committing

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

## Plan mode

When you exit plan mode, a hook automatically restructures the plan:
- Each step becomes a task file in `docs/tasks/backlog/`
- The plan is replaced with a lightweight skeleton to save context tokens
- The full plan is backed up to `docs/plans/`

Use the **task-executor** agent to work through tasks one at a time. Each agent call is ephemeral — it reads the task file, does the research, logs findings, and reports back without bloating the main conversation.

```
use task-executor — task: docs/tasks/backlog/NNN-name.md
```

## Boundaries

### Always
- Log every search in `docs/research-log.md` — including empty results
- Save sources to `sources/web/` with URL and date before synthesizing
- Commit and push after every milestone (task completed, draft written, outline updated)
- Read the task file and research log before starting work

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
