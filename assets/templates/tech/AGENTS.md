# {{PROJECT_NAME}} — Agent briefing (canonical)

This is the **canonical, harness-neutral briefing** for {{PROJECT_NAME}}. It is the
single source of truth for project context, commands, conventions, the task
workflow, verification expectations, commit rules, and the load-bearing process
rules every agent must follow.

Every coding-agent harness loads this file:

- **Codex** auto-loads `AGENTS.md` (this file).
- **Antigravity / Gemini** load it via `GEMINI.md` (a symlink to this file).
- **Claude Code** loads `CLAUDE.md`, which imports this file (`@AGENTS.md`) and adds
  the Claude-specific mechanics (skills, subagents, hooks, plan mode).

Keep this file harness-neutral. Anything that only one harness understands belongs
in that harness's layer (`CLAUDE.md` for Claude Code), not here.

## What this is

{{PROJECT_DESCRIPTION}}

## Project structure

```
src/          ← code outputs (what you write)
artifacts/    ← non-code outputs (rendered diagrams, exports, schemas)
docs/         ← spec + planning + history (the source-of-truth side)
  spec/           authoritative current-state snapshot — SPEC.md, behaviors, architecture, data-model, interfaces, configuration
  architecture/   narrative overview, diagrams.md, ADRs, tech stack
  plans/          roadmap, sprints
  tasks/          active, backlog, completed task files
    test-specs/   TDD specs — always written before implementation
  agent-rules.md  process rules + project retros (the growing log of lessons)
```

The key distinction: `docs/` is the input side (read before you act, and the
artifact that survives a rewrite), `src/` is the output side (what gets produced).

`docs/spec/` is **dual-natured** — it's the output of every task that changes
externally-visible behavior, *and* the input to onboarding, drift audits, and (in
the limit) regenerating the codebase from scratch. The code is one realization of
the spec. Spec and code that disagree means one of them is wrong; fix it in the same
change.

## Tech stack

{{TECH_STACK}}

## Commands

```bash
# TODO: fill in — how to run tests
# TODO: fill in — how to build / compile
# TODO: fill in — how to start dev server / run the app
# TODO: fill in — how to lint / format
```

## Design principles

This project follows **Unix philosophy** as its default design approach — favoring
**composability over monolithic design**. Complex behavior should emerge from
combining small, independent components that communicate through standardized
interfaces, not by growing one large one. The full statement lives in
`docs/architecture/overview.md` under *Design principles*; the short version is four
structural properties to design for:

- **Modularity** — independent units that can be built, understood, and changed on
  their own
- **Interface standardization** — stable, well-defined contracts between components
  (typed signatures, versioned APIs, plain-text formats)
- **Maintainability** — changes in one module should not cascade across unrelated
  ones
- **Reusability** — components should be liftable into another project without
  entanglement

Derived working rules:

- **One thing, well** — each module, service, and function has a single clear
  responsibility
- **Small, composable pieces** over large configurable ones
- **Plain text** for configs, intermediate artifacts, and data interchange where
  possible
- **Explicit over implicit** — surface assumptions in code and types, not in
  comments
- **Fail fast, crash loudly** on unexpected state — never silently paper over it
- **Test in isolation** — every component runnable without the whole stack
- **Defer premature decisions** — no abstractions until the second or third concrete
  use case demands them

**Monolithic is a legitimate choice when deliberate** — the Linux kernel itself is
monolithic for good reasons (performance, correctness, tight internal coupling that
plug-ins would undermine). The same can apply to a hot-path runtime core, a state
machine, or a cryptographic primitive. The principle is "prefer composability at
user-facing or cross-module boundaries, and document any deviation with an ADR."
Accidental monolithic drift is not the same as a deliberate monolithic decision.

## Conventions

- Task files are named `NNN-short-name.md` (zero-padded, sequential across all task
  states)
- Every task has a paired test spec; no implementation starts without one
- Tasks follow Unix philosophy — one task, one responsibility; break things smaller
  when in doubt
- ADRs live in `docs/architecture/decisions/` — add one whenever a significant
  design decision is made
- **Spec is updated in the same commit as the code change.** A task that changes
  externally-visible behavior, the data model, an interface, or configuration is not
  done until the matching `docs/spec/` file reflects the new state. Stale spec
  entries are rewritten in place — never appended to. The ADR carries the history;
  the spec carries the current truth.
- **Diagrams update with the code.** When a component boundary moves or a runtime
  flow changes, update `docs/architecture/diagrams.md` in the same commit. Use the
  `architect` agent's drift-audit mode periodically to catch silent drift.

## Working in this project

Every task lives on its own branch (or worktree under concurrent sessions). Working
directly on `main` is blocked by the `no-commit-on-main` hook —
`scripts/start-task.sh` is how you pick the right isolation for the moment.

1. Start each session by reading the relevant task file (including its
   **Verification plan**) and its test spec
2. Check `docs/architecture/overview.md` for system context
3. Write the test spec before any implementation code
4. Implement via your harness's task-execution flow. Its Step 0 runs
   `scripts/start-task.sh <NNN> <slug>` to set up either:
   - `BRANCH task/NNN-<slug>` (solo session — the common case), or
   - `WORKTREE .claude/worktrees/NNN-<slug>/` (concurrent session detected; `cd` in)

   Commit at status **🟡 (code merged)** on the task branch.
5. After the executor returns, run the **spec-verifier** role on the task — it
   returns APPROVE or BLOCK based on per-assertion evidence
6. If spec-verifier APPROVEs **and** the verification plan's L5/L6 evidence is
   recorded (validation-harness output or runtime observation), promote the row to
   **✅ (verified)** in `coverage-tracker.md` in a **separate commit** titled
   `verify: confirm task NNN — <evidence>` (still on the task branch)
7. **Close the task** when ready with `scripts/finish-task.sh <NNN> <slug>` (add
   `--local` to merge without pushing — e.g. to avoid re-triggering CI on every task
   in a run). It merges `task/NNN-<slug>` into `main`, deletes the branch, removes
   the worktree, and **verifies all three actually happened**, exiting non-zero if
   anything is left behind. Prefer it over a bare `git merge`: a forgotten merge or a
   leftover branch/worktree becomes a hard error instead of silent drift. (On a clean
   `git merge` the `auto-cleanup-merge` hook also cleans up, but `finish-task.sh` is
   the explicit, checked path.) If it reports a merge conflict, resolve it and re-run.
8. **Commit and push after each milestone** — never start the next task without
   committing the current one first

The separation between the task branch and `main` is the load-bearing rule for
multi-session safety. Two sessions on different `task/*` branches can work in
parallel without stepping on each other; two sessions both editing `main` cannot.

The separation between 🟡 (feat commit) and ✅ (verify commit) is the load-bearing
rule: it makes "merged" and "verified" two distinct artifacts in git history, so
neither can silently substitute for the other. **Never** mark ✅ in the same commit
as the feature work — the verification step must be its own observable event.

## Commit rules

**You must commit and push after every milestone.** Do not batch multiple tasks into
one commit. Do not continue to the next task until the current one is committed and
pushed.

All commits below land on the **task branch** (`task/NNN-<slug>`), never on `main`
directly. The merge to `main` happens after the verify step, in a separate explicit
operation.

| Milestone | What to stage | Message | Branch |
|-----------|--------------|---------|--------|
| ADR written | `docs/architecture/decisions/NNN-*.md`, any superseded spec entries rewritten in `docs/spec/` | `docs: add ADR NNN — <decision title>` | task branch |
| Test spec written | `docs/tasks/test-specs/NNN-*-test-spec.md`, updated `coverage-tracker.md` | `test: add spec for task NNN — <name>` | task branch |
| Task code merged (🟡) | `src/` changes, moved task file, `coverage-tracker.md` row set to **🟡**, **and any affected `docs/spec/` files** | `feat: complete task NNN — <name>` | task branch |
| Task verified (✅) | `coverage-tracker.md` row promoted from 🟡 → ✅ with `Verified by` column filled (harness command + final assertion, or operator observation) | `verify: confirm task NNN — <evidence>` | task branch |
| Diagram updated | `docs/architecture/diagrams.md` (with date bump at top) | `docs: refresh diagrams — <what changed>` | task branch (or `[allow-main]` for standalone doc fixes) |
| Spec rewritten standalone | `docs/spec/<file>.md` | `spec: <what changed and why now>` | task branch (or `[allow-main]` for standalone doc fixes) |
| Merged into main | (after `git merge task/NNN-<slug>` on `main`) | (uses the default `Merge branch …` message) | `main` |

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
  commits are impossible to untangle. One task, one commit.
- **Test spec before implementation — always.** No "this is too small for a spec."
  The spec defines done; without it you're guessing.
- **Never work directly on the default branch.** First action of any task is
  `scripts/start-task.sh <NNN> <slug>`, which puts you on `task/NNN-<slug>` or in a
  worktree. When it prints `WORKTREE <path>`, your **next command must be `cd
  <path>`** — editing the parent repo while believing you're isolated is the silent
  failure.
- **"Done" means operationally verified, not "code merged."** The verification
  ladder: (1) code merged → (2) unit tests pass → (3) full fitness/check gate passes
  → (4) CI → (5) validation harness exercises the live path → (6) live binary
  observed. Levels 1–4 are 🟡; only 5 or 6 flips a row to ✅. Never claim a level you
  did not reach.
- **Trace producer→consumer before declaring done on cross-module state.** A test
  that sets a field by hand proves the gate works *given* the field; it does not
  prove the field is ever set on the live path. Grep the write site and the read
  site and identify the live path.
- **No smoke tests where the spec asks for assertions.** If the spec says "returns
  `Some(2)`", the test must verify that, not merely that the call doesn't panic. If
  constructing the state is hard, that's a blocker to report — not a license to
  downgrade the test.
- **No new warnings self-justified away.** A change that adds a linter/typecheck
  warning over baseline must fix the root cause or stop and report. "Acceptable
  false positive" is not a label you apply unilaterally — use an explicit suppression
  with a reason, or escalate.
- **Run it when the change is runtime-visible.** Logging, CLI/exit codes, TUI
  output, endpoints, file outputs, side effects — the static check gate is not
  verification. Run the binary path and quote the output.
- **Never `git checkout -- <path>` over uncommitted work.** It silently overwrites
  and the reflog cannot recover it. Use `git stash`, `git worktree add <ref>`, or
  `git diff <ref> -- <path>` / `git show <ref>:<path>` instead. A `protect-checkout`
  hook blocks this; the rule stands even if the hook is off.
- **Git status must be clean before declaring a task complete.** `git status` must
  report `nothing to commit, working tree clean`. The common miss: `cp` instead of
  `git mv` when moving a task file leaves the original undeleted.

## Boundaries

### Always
- Write the test spec before any implementation code
- Fill in the **Verification plan** of the task file *before* writing code — the
  highest verification level achievable, the harness command, the runtime
  observation
- Commit and push after every milestone
- Read the task file (including its Verification plan) and test spec before starting
- Create an ADR for significant design decisions
- **Update `docs/spec/` in the same commit** as any code change that alters
  externally-visible behavior, data model, interfaces, or configuration
- **Update `docs/architecture/diagrams.md` in the same commit** as any code change
  that moves a component boundary or alters a diagrammed runtime flow
- **Default new task status to 🟡 on the feat commit; ✅ only after spec-verifier
  APPROVE + recorded L5/L6 evidence, in a separate `verify:` commit**
- **Run `spec-verifier` on every task** before promoting to ✅ — its APPROVE/BLOCK
  verdict is the gate, not the executor's self-judgement
- **Start every task on its own branch via `scripts/start-task.sh <NNN> <slug>`**

### Ask first
- Modifying files in `docs/plans/`, `docs/tasks/`, or
  `docs/architecture/decisions/` — they are planning and historical documents
- Deleting or renaming existing source files
- Adding dependencies not already in the tech stack
- Changing the project structure beyond what a task requires
- Reorganizing `docs/spec/` (splitting files, renaming sections) — the structure is
  a stable contract; restructure deliberately, not opportunistically

### Never
- Create files in `src/` without a corresponding task and test spec
- Combine unrelated changes in one task or commit
- Skip the test spec — even for "small" changes
- Force push or rewrite published git history
- Add a `Co-Authored-By` line to commits unless explicitly asked
- Append to spec entries instead of rewriting them (the ADR keeps history; the spec
  is a snapshot)
- Add future-tense statements to the spec (the spec is what *is*; planned work goes
  in `docs/plans/` and `docs/tasks/`)
- Mark a task ✅ on the same commit as the feature work
- Claim a verification level you did not actually reach
- Commit directly to `main` (use `[allow-main]` in the message for genuine main-only
  fixes — standalone doc fixes, hotfixes)
- Run `git checkout -- <path>` over a dirty working tree
