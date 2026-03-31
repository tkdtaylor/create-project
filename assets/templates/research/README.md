# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Structure

| Directory | Purpose |
|-----------|---------|
| `sources/` | Input materials — local files and saved web references (never edited) |
| `notes/` | Working synthesis — Claude's scratchpad while researching |
| `outputs/` | Final deliverables — drafts and completed pieces |
| `docs/` | Project management — tasks, outline, research log |

## Navigation

- [Research log](research-log.md) — what's been searched, found, and reviewed
- [Outline](outline.md) — structure of the intended output
- [Active tasks](tasks/active/) — what's being worked on now
- [Progress tracker](tasks/progress-tracker.md) — overall status

## Workflow

1. Pick a task from [`tasks/active/`](tasks/active/) or [`tasks/backlog/`](tasks/backlog/)
2. Check the [research log](research-log.md) to avoid duplicating previous searches
3. Paste the task file + research log + outline into a new Claude session
4. Research, synthesize, and add notes to `notes/by-topic/`
5. When the task's research question is answered, move it to [`tasks/completed/`](tasks/completed/) and update the log

Sources live in `sources/` and are never modified. Notes are working material. Only move content to `outputs/` when it's ready to share.
