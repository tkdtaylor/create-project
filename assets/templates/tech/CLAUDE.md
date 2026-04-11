# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Project structure

```
src/          ← code outputs (what you write)
artifacts/    ← non-code outputs (diagrams, schemas, exports)
docs/         ← documentation inputs (what guides your work)
  architecture/   system design, ADRs, tech stack
  plans/          roadmap, sprints
  tasks/          active, backlog, completed task files
    test-specs/   TDD specs — always written before implementation
```

The key distinction: `docs/` is the input side (read before you act), `src/` is the output side (what gets produced).

## Tech stack

{{TECH_STACK}}

## Commands

```bash
# TODO: fill in — how to run tests
# TODO: fill in — how to build / compile
# TODO: fill in — how to start dev server / run the app
# TODO: fill in — how to lint / format
```

## Conventions

- Task files are named `NNN-short-name.md` (zero-padded, sequential across all task states)
- Every task has a paired test spec; no implementation starts without one
- Tasks follow Unix philosophy — one task, one responsibility; break things smaller when in doubt (see Design principles below)
- ADRs live in `docs/architecture/decisions/` — add one whenever a significant design decision is made

## Design principles

This project follows **Unix philosophy** as its default design approach — favoring **composability over monolithic design**. Complex behavior should emerge from combining small, independent components that communicate through standardized interfaces, not by growing one large one. The full statement lives in `docs/architecture/overview.md` under *Design principles*; the short version is:

Four structural properties to design for:

- **Modularity** — independent units that can be built, understood, and changed on their own
- **Interface standardization** — stable, well-defined contracts between components (typed signatures, versioned APIs, plain-text formats)
- **Maintainability** — changes in one module should not cascade across unrelated ones
- **Reusability** — components should be liftable into another project without entanglement

Derived working rules:

- **One thing, well** — each module, service, and function has a single clear responsibility
- **Small, composable pieces** over large configurable ones
- **Plain text** for configs, intermediate artifacts, and data interchange where possible
- **Explicit over implicit** — surface assumptions in code and types, not in comments
- **Fail fast, crash loudly** on unexpected state — never silently paper over it
- **Test in isolation** — every component runnable without the whole stack
- **Defer premature decisions** — no abstractions until the second or third concrete use case demands them

**Monolithic is a legitimate choice when deliberate** — the Linux kernel itself is monolithic for good reasons (performance, correctness, tight internal coupling that plug-ins would undermine). The same can apply to a hot-path runtime core, a state machine, or a cryptographic primitive. The principle is "prefer composability at user-facing or cross-module boundaries, and document any deviation with an ADR." Accidental monolithic drift is not the same as a deliberate monolithic decision — the architect agent flags the former, accepts the latter.

## Working in this project

1. Start each session by reading the relevant task file and its test spec
2. Check `docs/architecture/overview.md` for system context
3. Write the test spec before any implementation code
4. Move tasks to `completed/` and update `coverage-tracker.md` when done
5. **Commit and push immediately after each milestone** — never start the next task without committing the current one first

## Commit rules

**You must commit and push after every milestone.** Do not batch multiple tasks into one commit. Do not continue to the next task until the current one is committed and pushed.

| Milestone | What to stage | Message |
|-----------|--------------|---------|
| ADR written | `docs/architecture/decisions/NNN-*.md` | `docs: add ADR NNN — <decision title>` |
| Test spec written | `docs/tasks/test-specs/NNN-*-test-spec.md`, updated `coverage-tracker.md` | `test: add spec for task NNN — <name>` |
| Task completed | `src/` changes, moved task file, updated `coverage-tracker.md` | `feat: complete task NNN — <name>` |

After each milestone:
```bash
git add <relevant files>
git commit -m "<message>"
git push
```

## Plan mode

When you exit plan mode, a hook automatically restructures the plan:
- Each step becomes a task file in `docs/tasks/backlog/`
- Test spec stubs are created for each task
- The plan is replaced with a lightweight skeleton to save context tokens
- The full plan is backed up to `docs/plans/`

Use the **task-executor** agent to work through tasks one at a time. Each agent call is ephemeral — it reads the task file, does the work, commits, and reports back without bloating the main conversation.

```
use task-executor — task: docs/tasks/backlog/NNN-name.md, spec: docs/tasks/test-specs/NNN-name-test-spec.md
```

### End handoffs with a resume command

When a response completes a logical milestone that leaves follow-on work (a task planned but not executed, an ADR drafted awaiting implementation, a handoff to another session or agent), end the response with a **fenced code block** containing the exact resume command. Not inline backticks, not a prose description, not a vague pointer — a fenced code block is what renders the copy button in the VSCode chat UI. Inline code does not get that affordance.

**Verify the path exists before writing the resume block.** Glob `docs/tasks/backlog/NNN-*.md` (and the matching `docs/tasks/test-specs/NNN-*-test-spec.md`) and copy the real filenames into the block. Do NOT infer filenames from the plan or from a prior message — the plan-mode hook may rename task files as it writes them out, and a wrong path wastes a whole task-executor round trip when the user or future session blindly pastes it.

If there is genuinely nothing to resume (the work is fully shipped, nothing follows), skip the block. This is a rule for real handoffs, not a ritual at the end of every message.

## Hook profiles

Hooks run automatically and are gated by profile level. Control via environment variables:

```bash
export CLAUDE_HOOK_PROFILE=minimal    # Safety hooks only (secret protection, block-no-verify, config-protection, protect-checkout)
export CLAUDE_HOOK_PROFILE=standard   # + workflow hooks (plan restructuring, compaction, checkpoints) — default
export CLAUDE_HOOK_PROFILE=strict     # + formatting, notifications (batch-format-typecheck, desktop-notify)
export CLAUDE_DISABLED_HOOKS=desktop-notify,batch-format-typecheck  # Disable specific hooks
```

## Boundaries

### Always
- Write the test spec before any implementation code
- Commit and push after every milestone (task completed, spec written, ADR written)
- Read the task file and test spec before starting work on a task
- Create an ADR for significant design decisions

### Ask first
- Modifying files in `docs/` — they are planning documents, not implementation
- Deleting or renaming existing source files
- Adding dependencies not already in the tech stack
- Changing the project structure beyond what a task requires

### Never
- Create files in `src/` without a corresponding task and test spec
- Combine unrelated changes in one task or commit
- Skip the test spec — even for "small" changes
- Force push or rewrite published git history
- Add a `Co-Authored-By` line to commits unless explicitly asked
- Run `git checkout -- <path>` (or `git checkout <ref> -- <path>`) over a dirty working tree — it silently overwrites uncommitted work and the reflog cannot recover it. To *compare* to a prior commit, use `git diff <ref> -- <path>`, `git show <ref>:<path>`, or `git worktree add ../baseline <ref>`. To *discard* changes, `git stash` first. A `protect-checkout` hook blocks this automatically, but the rule stands even if the hook is disabled.

## Common rationalizations

These are excuses agents use to skip steps. Don't fall for them.

| Excuse | Reality |
|--------|---------|
| "I'll commit after the next task too" | No. Commit now. Batched commits are impossible to untangle later. |
| "This task is too small for a test spec" | The spec defines done — without it you're guessing. Write one. |
| "I'll add tests later" | Later never comes. The test spec comes first, always. |
| "These two tasks are related, I'll do them together" | One task, one commit. If it feels too granular, the tasks are scoped correctly. |
| "The architecture doc doesn't need updating" | If you made a non-obvious design decision, write an ADR. |
| "I'll just quickly fix this other thing I noticed" | Stay on your task. Note it for later — don't scope-creep. |

## Failure modes

Project-specific lessons learned. Add an entry here whenever work is lost or significant time is wasted to a preventable mistake — especially the kind where the agent rationalized the action in the moment and only recognized the footgun in retrospect. Each entry should capture:

- **What happened** — the concrete sequence of actions, not a generalization
- **Why it wasn't caught** — which check, hook, or rule should have blocked it but didn't
- **The rule that prevents it next time** — phrased as a directive, not a wish

If the rule can be enforced by a hook, tooling change, or a Boundaries entry, wire it up and link it from the failure mode entry. An internalized failure mode (codified into a hook, baked into Boundaries, or made structurally impossible) can be archived or deleted once the guard is in place.

This section is empty at project creation and grows with the project's history. A growing list of entries is not a sign of a bad project — it is a sign of an *honest* one. Resist the urge to cherry-pick only the "interesting" failures; the boring ones are usually the ones that repeat.

> *No entries yet.*
