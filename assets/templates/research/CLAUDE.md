# {{PROJECT_NAME}} — Claude Code layer

The canonical, harness-neutral briefing for this repo is **`AGENTS.md`**. Read it
first — it holds project context, the research approach, conventions, the task
workflow, source-handling rules, commit rules, boundaries, and the load-bearing
process rules. This file adds only what is **specific to Claude Code** (subagents,
plan mode, hooks).

@AGENTS.md

---

Everything below is Claude Code-specific and supplements `AGENTS.md`.

## Subagents

Use the **task-executor** agent to work through research tasks one at a time. Each
agent call is ephemeral — it reads the task file, does the research, logs findings,
and reports back without bloating the main conversation.

```
use task-executor — task: docs/tasks/backlog/NNN-name.md
```

The workflow (log-before-moving-on, `scripts/start-task.sh` for isolation, the
🟡→✅ progress ladder, `finish-task.sh` to close a task) is defined in `AGENTS.md`.

## Plan mode

When you exit plan mode, a hook automatically restructures the plan:
- Each step becomes a task file in `docs/tasks/backlog/`
- The plan is replaced with a lightweight skeleton to save context tokens
- The full plan is backed up to `docs/plans/`

### End handoffs with a resume command

When a response completes a logical milestone that leaves follow-on work (a task planned but not executed, a research thread paused for the next session, a source still to be reviewed), end the response with a **fenced code block** containing the exact resume command. Not inline backticks, not a prose description, not a vague pointer — a fenced code block is what renders the copy button in the VSCode chat UI. Inline code does not get that affordance.

**Verify the path exists before writing the resume block.** Glob `docs/tasks/backlog/NNN-*.md` and copy the real filename into the block. Do NOT infer filenames from the plan or from a prior message — the plan-mode hook may rename task files as it writes them out, and a wrong path wastes a whole task-executor round trip when the user or future session blindly pastes it.

If there is genuinely nothing to resume (the work is fully shipped, nothing follows), skip the block. This is a rule for real handoffs, not a ritual at the end of every message.

## Hook profiles

Hooks run automatically and are gated by profile level. Control via environment variables:

```bash
export CLAUDE_HOOK_PROFILE=minimal    # Safety hooks only (secret protection, block-no-verify)
export CLAUDE_HOOK_PROFILE=standard   # + workflow hooks (plan restructuring, compaction, checkpoints) — default
export CLAUDE_HOOK_PROFILE=strict     # + desktop notifications
export CLAUDE_DISABLED_HOOKS=desktop-notify  # Disable specific hooks
```

## Agent rules and retros

Process-level rules, common rationalizations, and project-specific retros live in
`docs/agent-rules.md` (their essentials are also inlined in `AGENTS.md` so every
harness sees them). The `inject-retros.py` SessionStart hook reads that file and
surfaces relevant entries at the start of every session, so adding an entry there is
how a one-time mistake becomes a permanent guard.
