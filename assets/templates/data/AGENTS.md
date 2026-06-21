# {{PROJECT_NAME}} — Agent briefing (canonical)

This is the **canonical, harness-neutral briefing** for {{PROJECT_NAME}}. It is the
single source of truth for project context, commands, conventions, the task and
experiment workflow, verification expectations, commit rules, and the load-bearing
process rules every agent must follow.

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
data/          <- datasets (raw is immutable, processed is derived)
  raw/           original data — never modify
  processed/     cleaned and transformed
  external/      third-party sources
notebooks/     <- Jupyter notebooks for exploration (numbered: 01-*, 02-*)
src/           <- reusable Python modules
  data/          loading and preprocessing
  features/      feature engineering
  models/        model definitions and training
  evaluation/    metrics and evaluation utilities
experiments/   <- experiment tracking
  configs/       experiment configuration files (YAML/TOML)
  results/       metrics, plots, and artifacts per run
models/        <- saved model artifacts (gitignored)
tests/         <- unit tests for src/ modules
artifacts/     <- reports, exported plots, presentations
docs/          <- spec + planning + history (the source-of-truth side)
  spec/          authoritative current-state snapshot — SPEC.md, behaviors, architecture, data-model, interfaces, configuration
  architecture/  narrative overview, diagrams.md, ADRs, tech stack
  plans/         roadmap
  tasks/         active, backlog, completed task files
    test-specs/  TDD specs for src/ code
  agent-rules.md process rules + project retros (the growing log of lessons)
```

The key distinction: `data/raw/` and `docs/` are inputs (read before you act).
`src/`, `notebooks/`, `experiments/`, and `models/` are outputs.

`docs/spec/` is **dual-natured** — it's the output of every task or experiment that
changes the pipeline contract, *and* the input to onboarding, drift audits, and (in
the limit) regenerating the codebase from scratch with the same scientific results.
Reproducibility is non-negotiable for data projects: every parameter that affects
results must be in the spec.

## Tech stack

{{TECH_STACK}}

## Commands

```bash
# TODO: fill in — how to run training
# TODO: fill in — how to run evaluation
# TODO: fill in — how to run tests
# TODO: fill in — how to start notebook server (e.g. jupyter lab)
# TODO: fill in — how to lint / format
```

## Conventions

- Notebooks are for exploration; move reusable logic to `src/` modules
- Number notebooks sequentially: `01-data-exploration.ipynb`, `02-feature-analysis.ipynb`
- Data in `data/raw/` is immutable — never modify originals
- Every experiment has a config in `experiments/configs/` and results in `experiments/results/`
- Record experiment results in `docs/tasks/experiment-tracker.md`
- Code in `src/` follows TDD — test spec before implementation
- ADRs in `docs/architecture/decisions/` for significant design decisions (model
  choice, data pipeline architecture, etc.)
- Set random seeds explicitly in every experiment for reproducibility
- **Spec is updated in the same commit as the code change.** A task or experiment
  that changes the pipeline contract — datasets, features, model architecture, metric
  definitions, configuration — is not done until the matching `docs/spec/` file
  reflects the new state. Stale entries are rewritten in place; the ADR carries
  history.
- **Diagrams update with the pipeline.** When a step is added, removed, or reordered,
  update `docs/architecture/diagrams.md` in the same commit.

## Working in this project

Every task lives on its own branch (or worktree under concurrent sessions). Working
directly on `main` is blocked by the `no-commit-on-main` hook —
`scripts/start-task.sh` is how you pick the right isolation for the moment.

1. Start each session by reading the relevant task file (including its
   **Verification plan**) and its test spec
2. Check `docs/architecture/overview.md` for system context
3. Write the test spec before implementation code for `src/` modules
4. Log experiments in the experiment tracker before and after running
5. Implement via your harness's task-execution flow. Its Step 0 runs
   `scripts/start-task.sh <NNN> <slug>` to set up either:
   - `BRANCH task/NNN-<slug>` (solo session — the common case), or
   - `WORKTREE .claude/worktrees/NNN-<slug>/` (concurrent session detected; `cd` in)

   Commit at status **🟡 (code merged)** on the task branch. **Note for data work:**
   paths to `data/raw/`, `data/processed/`, and model artifacts may resolve
   differently from a worktree — use absolute paths or `$(git rev-parse
   --show-toplevel)` when in doubt.
6. After the executor returns, run the **spec-verifier** role on the task — it
   returns APPROVE or BLOCK based on per-assertion evidence
7. If spec-verifier APPROVEs **and** the verification plan's L5/L6 evidence is
   recorded (end-to-end pipeline run on a fixture with measured metric, or operator
   observation), promote the row to **✅ (verified)** in `coverage-tracker.md` in a
   **separate commit** titled `verify: confirm task NNN — <fixture + metric>` (still
   on the task branch)
8. **Close the task** when ready with `scripts/finish-task.sh <NNN> <slug>` (add
   `--local` to merge without pushing). It merges `task/NNN-<slug>` into `main`,
   deletes the branch, removes the worktree, and **verifies all three actually
   happened**, exiting non-zero if anything is left behind — so a forgotten merge or
   leftover branch/worktree is a hard error, not silent drift. (On a clean `git
   merge` the `auto-cleanup-merge` hook also cleans up, but `finish-task.sh` is the
   explicit, checked path.) If it reports a merge conflict, resolve it and re-run.
9. **Commit and push after each milestone** — never start the next task without
   committing

The separation between task branch and `main` is the load-bearing rule for
multi-session safety. Two sessions on different `task/*` branches can run experiments
in parallel without their results files clobbering each other; two sessions both
writing to `experiments/` on `main` can.

The separation between 🟡 (feat / experiment commit) and ✅ (verify commit) is the
load-bearing rule: it makes "code merged" and "pipeline runs end-to-end" two distinct
artifacts in git history. The most common data-project failure is "the feature/model
passed unit tests but the pipeline never ingests it" — the verify commit closes that
gap explicitly.

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
| Task code merged (🟡) | `src/`, `tests/`, moved task file, `coverage-tracker.md` row set to **🟡**, **and any affected `docs/spec/` files** | `feat: complete task NNN — <name>` | task branch |
| Task verified (✅) | `coverage-tracker.md` row promoted from 🟡 → ✅ with `Verified by` column filled (end-to-end pipeline run command + measured metric + fixture/run ID, or operator observation) | `verify: confirm task NNN — <fixture + metric>` | task branch |
| Experiment run | `experiments/`, updated `experiment-tracker.md`, **and any affected `docs/spec/` files (new feature, new metric, schema change)** | `experiment: <hypothesis> — <key result>` | task branch |
| Notebook added | `notebooks/` | `explore: add NNN — <topic>` | task branch (or `[allow-main]` for ad-hoc exploration) |
| Diagram updated | `docs/architecture/diagrams.md` (with date bump at top) | `docs: refresh diagrams — <what changed>` | task branch (or `[allow-main]` for standalone fixes) |
| Spec rewritten standalone | `docs/spec/<file>.md` | `spec: <what changed and why now>` | task branch (or `[allow-main]` for standalone fixes) |
| Merged into main | (after `git merge task/NNN-<slug>` on `main`) | (default `Merge branch …` message) | `main` |

After each milestone:
```bash
git add <relevant files>
git commit -m "<message>"
git push
```

Do **not** add a `Co-Authored-By` line to commits unless explicitly asked.

## Experiment workflow

For ML experiments (training runs, hyperparameter searches, model comparisons):

1. Create a config in `experiments/configs/<id>-<name>.yaml` with parameters, data
   source, and hypothesis
2. Add a row to `docs/tasks/experiment-tracker.md` with status "running"
3. Run the experiment
4. Save results (metrics, plots) to `experiments/results/<id>-<name>/`
5. Update the tracker row with results and verdict
6. Commit:
   ```bash
   git add experiments/ docs/tasks/experiment-tracker.md
   git commit -m "experiment: <hypothesis> — <key result>"
   git push
   ```

## Experiment sandbox

For exploratory research before committing to an approach (comparing frameworks,
evaluating data strategies, prototyping architectures):

1. Copy `experiments/EXPERIMENT-TEMPLATE.md` to
   `experiments/<NNN>-<short-name>/EXPERIMENT.md`
2. Fill in the Problem, Hypothesis, and Target sections
3. Work through the lifecycle phases: IDENTIFY → RESEARCH → HYPOTHESIZE → PLAN →
   IMPLEMENT → EVALUATE → DECIDE
4. Keep all experiment artifacts (throwaway code, scratch notebooks, intermediate
   data) inside the experiment folder
5. Record findings as you go — don't wait until the end
6. At DECIDE, choose an outcome:
   - **GO** — create tasks in the project backlog, port validated patterns to `src/`
   - **NO-GO** — document why, record as a failed approach in the tracker
   - **ITERATE** — refine hypothesis, adjust parameters, run again

**Rule: port results, not files.** Experiment artifacts stay in the sandbox. Only
actionable outcomes (code patterns, validated configs, documented decisions) move to
the project.

## Load-bearing process rules

These are the rules that exist specifically to stop a preventable mistake. The
**full treatment, with the incident that motivated each, lives in
`docs/agent-rules.md`** — read it. The essentials, so they reach you even without
that file loaded:

- **Commit after every milestone — now, not "after the next task too."** Batched
  commits are impossible to untangle. One task, one commit.
- **Test spec before implementation — always** for `src/` code. No "this is too small
  for a spec." The spec defines done; without it you're guessing.
- **Never work directly on the default branch.** First action of any task is
  `scripts/start-task.sh <NNN> <slug>`, which puts you on `task/NNN-<slug>` or in a
  worktree. When it prints `WORKTREE <path>`, your **next command must be `cd
  <path>`** — editing the parent repo's `data/processed/` while believing you're
  isolated is the silent corruption this rule exists to prevent.
- **"Done" means the pipeline runs end-to-end, not "code merged."** The verification
  ladder: (1) code merged → (2) unit tests pass → (3) the static check gate passes →
  (4) CI → (5) end-to-end pipeline run on a fixture with the measured metric meeting
  threshold → (6) operator-observed live behaviour. Levels 1–4 are 🟡; only 5 or 6
  flips a row to ✅. "Trained the model" is not "the pipeline integrates the model."
- **Reproducibility is non-negotiable.** Set the random seed now, not later. Log the
  experiment config before running. Every parameter that affects results lives in a
  config and in the spec — unnamed metrics and unset seeds make runs impossible to
  compare.
- **Keep `data/raw/` immutable.** Never fix a data issue in place — copy to
  `data/processed/` and fix it there.
- **No smoke tests where the spec asks for assertions.** If the spec says a transform
  produces a specific value or a metric clears a threshold, the test must verify
  that, not merely that the call doesn't error. If constructing the state is hard,
  that's a blocker to report — not a license to downgrade the test.
- **Trace producer→consumer before declaring done on cross-module state.** A unit
  test on a transform proves the transform; it does not prove the pipeline ingests
  it. Grep the write site and the read site and identify the live path.
- **Never `git checkout -- <path>` over uncommitted work.** It silently overwrites
  and the reflog cannot recover it. Use `git stash`, `git worktree add <ref>`, or
  `git diff <ref> -- <path>` / `git show <ref>:<path>` instead. A `protect-checkout`
  hook blocks this; the rule stands even if the hook is off.
- **Git status must be clean before declaring a task complete.** `git status` must
  report `nothing to commit, working tree clean`.

## Data-specific rationalizations

Generic process rationalizations live in `docs/agent-rules.md`. These are the
data/ML-specific excuses to refuse:

| Excuse | Reality |
|--------|---------|
| "This is just a quick data transformation, no test needed" | If it goes in `src/`, it needs a test spec. Notebooks are for quick exploration. |
| "I'll log the experiment later" | Log it now. You'll forget the parameters and the result won't be reproducible. |
| "I don't need a config file for this experiment" | Yes you do. Without it, you can't reproduce the run or compare with future experiments. |
| "The raw data has a small issue, I'll just fix it in place" | Never. Copy to processed/ and fix it there. Raw data is immutable. |
| "I'll set the random seed later" | Set it now. Every experiment must be reproducible from day one. |
| "The new metric is obvious — don't need to add it to the catalog" | Yes you do. Unnamed metrics drift in definition between runs. The catalog is the contract. |

## Boundaries

### Always
- Write the test spec before implementation code for `src/` modules
- Fill in the **Verification plan** section of the task file *before* writing code —
  fixture path, command, acceptance metric, threshold
- Commit and push after every milestone (task, experiment, spec, ADR)
- Set random seeds explicitly for reproducibility
- Keep `data/raw/` immutable — derive everything into `data/processed/`
- Log experiments in the tracker before running them
- **Update `docs/spec/` in the same commit as any pipeline change** — new datasets,
  schema changes, new features, new metrics, hyperparameter contracts, model artifact
  contracts
- **Update `docs/architecture/diagrams.md` when pipeline shape changes** — steps
  added, removed, or reordered
- **Default new task status to 🟡 on the feat commit; ✅ only after spec-verifier
  APPROVE + end-to-end pipeline run on a fixture (or operator-observed live
  behaviour), in a separate `verify:` commit**
- **Run `spec-verifier` on every task** before promoting to ✅ — its APPROVE/BLOCK
  verdict is the gate, not the executor's self-judgement
- **Start every task on its own branch via `scripts/start-task.sh <NNN> <slug>`**

### Ask first
- Modifying files in `docs/plans/`, `docs/tasks/`, or
  `docs/architecture/decisions/` — they are planning and historical documents
- Deleting or regenerating processed data
- Adding dependencies not in the tech stack
- Changing the data pipeline architecture
- Reorganizing `docs/spec/` (splitting files, renaming sections) — the structure is
  a stable contract; restructure deliberately, not opportunistically

### Never
- Modify files in `data/raw/` — they are immutable source data
- Combine unrelated changes in one task or commit
- Skip the test spec for `src/` code — even for "small" changes
- Commit large data files or model artifacts to git (use `.gitignore`)
- Force push or rewrite published git history
- Add a `Co-Authored-By` line to commits unless explicitly asked
- Append to spec entries instead of rewriting them (the ADR carries history; the spec
  is a snapshot)
- Add future-tense statements to the spec (the spec is what *is*; planned experiments
  and unfinished work go in `docs/plans/` and the experiment tracker)
- Mark a task ✅ on the same commit as the feature work or experiment run
- Claim a verification level you did not actually reach (unit tests on a transform
  are L2; the pipeline run is L5)
- Commit directly to `main` (use `[allow-main]` in the message for genuine main-only
  fixes — a standalone spec rewrite, a data-immutability tweak in a config)
- Run `git checkout -- <path>` over a dirty working tree
