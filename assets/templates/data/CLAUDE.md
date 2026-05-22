# {{PROJECT_NAME}}

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
```

The key distinction: `data/raw/` and `docs/` are inputs (read before you act). `src/`, `notebooks/`, `experiments/`, and `models/` are outputs.

`docs/spec/` is **dual-natured** — it's the output of every task or experiment that changes the pipeline contract, *and* the input to onboarding, drift audits, and (in the limit) regenerating the codebase from scratch with the same scientific results. Reproducibility is non-negotiable for data projects: every parameter that affects results must be in the spec.

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
- ADRs in `docs/architecture/decisions/` for significant design decisions (model choice, data pipeline architecture, etc.)
- Set random seeds explicitly in every experiment for reproducibility
- **Spec is updated in the same commit as the code change.** A task or experiment that changes the pipeline contract — datasets, features, model architecture, metric definitions, configuration — is not done until the matching `docs/spec/` file reflects the new state. Stale entries are rewritten in place; the ADR carries history.
- **Diagrams update with the pipeline.** When a step is added, removed, or reordered, update `docs/architecture/diagrams.md` in the same commit.

## Working in this project

1. Start each session by reading the relevant task file (including its **Verification plan**) and its test spec
2. Check `docs/architecture/overview.md` for system context
3. Write the test spec before implementation code for `src/` modules
4. Log experiments in the experiment tracker before and after running
5. Use the **task-executor** agent to implement — it commits at status **🟡 (code merged)** by default
6. After the executor returns, use **spec-verifier** on the task — it returns APPROVE or BLOCK based on per-assertion evidence
7. If spec-verifier APPROVEs **and** the verification plan's L5/L6 evidence is recorded (end-to-end pipeline run on a fixture with measured metric, or operator observation), promote the row to **✅ (verified)** in `coverage-tracker.md` in a **separate commit** titled `verify: confirm task NNN — <fixture + metric>`
8. **Commit and push after each milestone** — never start the next task without committing

The separation between 🟡 (feat / experiment commit) and ✅ (verify commit) is the load-bearing rule: it makes "code merged" and "pipeline runs end-to-end" two distinct artifacts in git history. The most common data-project failure is "the feature/model passed unit tests but the pipeline never ingests it" — the verify commit closes that gap explicitly.

## Commit rules

**You must commit and push after every milestone.** Do not batch multiple tasks into one commit. Do not continue to the next task until the current one is committed and pushed.

| Milestone | What to stage | Message |
|-----------|--------------|---------|
| ADR written | `docs/architecture/decisions/NNN-*.md`, any superseded spec entries rewritten in `docs/spec/` | `docs: add ADR NNN — <decision title>` |
| Test spec written | `docs/tasks/test-specs/NNN-*-test-spec.md`, updated `coverage-tracker.md` | `test: add spec for task NNN — <name>` |
| Task code merged (🟡) | `src/`, `tests/`, moved task file, `coverage-tracker.md` row set to **🟡**, **and any affected `docs/spec/` files** | `feat: complete task NNN — <name>` |
| Task verified (✅) | `coverage-tracker.md` row promoted from 🟡 → ✅ with `Verified by` column filled (end-to-end pipeline run command + measured metric + fixture/run ID, or operator observation) | `verify: confirm task NNN — <fixture + metric>` |
| Experiment run | `experiments/`, updated `experiment-tracker.md`, **and any affected `docs/spec/` files (new feature, new metric, schema change)** | `experiment: <hypothesis> — <key result>` |
| Notebook added | `notebooks/` | `explore: add NNN — <topic>` |
| Diagram updated | `docs/architecture/diagrams.md` (with date bump at top) | `docs: refresh diagrams — <what changed>` |
| Spec rewritten standalone | `docs/spec/<file>.md` | `spec: <what changed and why now>` |

After each milestone:
```bash
git add <relevant files>
git commit -m "<message>"
git push
```

## Experiment workflow

For ML experiments (training runs, hyperparameter searches, model comparisons):

1. Create a config in `experiments/configs/<id>-<name>.yaml` with parameters, data source, and hypothesis
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

For exploratory research before committing to an approach (comparing frameworks, evaluating data strategies, prototyping architectures):

1. Copy `experiments/EXPERIMENT-TEMPLATE.md` to `experiments/<NNN>-<short-name>/EXPERIMENT.md`
2. Fill in the Problem, Hypothesis, and Target sections
3. Work through the lifecycle phases: IDENTIFY → RESEARCH → HYPOTHESIZE → PLAN → IMPLEMENT → EVALUATE → DECIDE
4. Keep all experiment artifacts (throwaway code, scratch notebooks, intermediate data) inside the experiment folder
5. Record findings as you go — don't wait until the end
6. At DECIDE, choose an outcome:
   - **GO** — create tasks in the project backlog, port validated patterns to `src/`
   - **NO-GO** — document why, record as a failed approach in the tracker
   - **ITERATE** — refine hypothesis, adjust parameters, run again

**Rule: port results, not files.** Experiment artifacts stay in the sandbox. Only actionable outcomes (code patterns, validated configs, documented decisions) move to the project.

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

When a response completes a logical milestone that leaves follow-on work (a task planned but not executed, an experiment run pending analysis, an ADR drafted awaiting implementation, a handoff to another session or agent), end the response with a **fenced code block** containing the exact resume command. Not inline backticks, not a prose description, not a vague pointer — a fenced code block is what renders the copy button in the VSCode chat UI. Inline code does not get that affordance.

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
- Write the test spec before implementation code for `src/` modules
- Fill in the **Verification plan** section of the task file *before* writing code — fixture path, command, acceptance metric, threshold
- Commit and push after every milestone (task, experiment, spec, ADR)
- Set random seeds explicitly for reproducibility
- Keep `data/raw/` immutable — derive everything into `data/processed/`
- Log experiments in the tracker before running them
- **Update `docs/spec/` in the same commit as any pipeline change** — new datasets, schema changes, new features, new metrics, hyperparameter contracts, model artifact contracts
- **Update `docs/architecture/diagrams.md` when pipeline shape changes** — steps added, removed, or reordered
- **Default new task status to 🟡 on the feat commit; ✅ only after spec-verifier APPROVE + end-to-end pipeline run on a fixture (or operator-observed live behaviour), in a separate `verify:` commit**
- **Run `spec-verifier` on every task** before promoting to ✅ — its APPROVE/BLOCK verdict is the gate, not the executor's self-judgement

### Ask first
- Modifying files in `docs/plans/`, `docs/tasks/`, or `docs/architecture/decisions/` — they are planning and historical documents
- Deleting or regenerating processed data
- Adding dependencies not in the tech stack
- Changing the data pipeline architecture
- Reorganizing `docs/spec/` (splitting files, renaming sections) — the structure is a stable contract; restructure deliberately, not opportunistically

### Never
- Modify files in `data/raw/` — they are immutable source data
- Combine unrelated changes in one task or commit
- Skip the test spec for `src/` code — even for "small" changes
- Commit large data files or model artifacts to git (use `.gitignore`)
- Force push or rewrite published git history
- Add a `Co-Authored-By` line to commits unless explicitly asked
- Run `git checkout -- <path>` (or `git checkout <ref> -- <path>`) over a dirty working tree — it silently overwrites uncommitted work and the reflog cannot recover it. To *compare* to a prior commit, use `git diff <ref> -- <path>`, `git show <ref>:<path>`, or `git worktree add ../baseline <ref>`. To *discard* changes, `git stash` first. A `protect-checkout` hook blocks this automatically, but the rule stands even if the hook is disabled.
- **Append to spec entries instead of rewriting them.** When a feature definition or hyperparameter changes, edit the spec entry to reflect the new truth. The ADR carries history; the spec is a snapshot.
- **Add future-tense statements to the spec.** The spec is what *is*, not what *will be*. Planned experiments and unfinished work go in `docs/plans/` and the experiment tracker.
- **Mark a task ✅ on the same commit as the feature work or experiment run.** ✅ is reserved for the separate `verify:` commit after spec-verifier APPROVE plus an end-to-end pipeline run on a fixture with the measured metric meeting the acceptance threshold. "Trained the model" is not the same as "the pipeline integrates the model" — the verify commit is where that distinction lives.
- **Claim a verification level you did not actually reach.** If the pipeline wasn't run end-to-end, the row says `pending` or `N/A`, not ✅. Unit tests on the transform are L2; the pipeline run is L5.

## Data-specific rationalizations

Generic process rationalizations live in `docs/architecture/agent-rules.md`. These are the data/ML-specific excuses to refuse:

| Excuse | Reality |
|--------|---------|
| "This is just a quick data transformation, no test needed" | If it goes in `src/`, it needs a test spec. Notebooks are for quick exploration. |
| "I'll log the experiment later" | Log it now. You'll forget the parameters and the result won't be reproducible. |
| "I don't need a config file for this experiment" | Yes you do. Without it, you can't reproduce the run or compare with future experiments. |
| "The raw data has a small issue, I'll just fix it in place" | Never. Copy to processed/ and fix it there. Raw data is immutable. |
| "I'll set the random seed later" | Set it now. Every experiment must be reproducible from day one. |
| "The new metric is obvious — don't need to add it to the catalog" | Yes you do. Unnamed metrics drift in definition between runs. The catalog is the contract. |

## Agent rules and retros

Process-level rules, common rationalizations, and project-specific retros all live in `docs/architecture/agent-rules.md`. The `inject-retros.py` SessionStart hook reads that file and surfaces relevant entries at the start of every session, so adding an entry there is how a one-time mistake becomes a permanent guard. The starter file ships with rules covering parallel-dispatch worktree isolation, the `git checkout -- <path>` hazard, smoke-test rationalization, dead-code delegates, and a "Common rationalizations" table.

Data projects are especially prone to silent failure modes (subtle data leakage, wrong train/test split, frozen random seed in the wrong place) — those are the most valuable retros to add to `agent-rules.md` because they are invisible in the moment.

When dispatching parallel agents in one message, run `scripts/verify-worktree-isolation.sh <agent-id> [<agent-id> ...]` after they complete to confirm none bypassed the worktree flag.
