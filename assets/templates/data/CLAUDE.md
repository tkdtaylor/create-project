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
docs/          <- documentation
  architecture/  system design, ADRs, tech stack
  plans/         roadmap
  tasks/         active, backlog, completed task files
    test-specs/  TDD specs for src/ code
```

The key distinction: `data/raw/` and `docs/` are inputs (read before you act). `src/`, `notebooks/`, `experiments/`, and `models/` are outputs.

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

## Working in this project

1. Start each session by reading the relevant task file and its test spec
2. Check `docs/architecture/overview.md` for system context
3. Write the test spec before implementation code for `src/` modules
4. Log experiments in the experiment tracker before and after running
5. **Commit and push after each milestone** — never start the next task without committing

## Commit rules

**You must commit and push after every milestone.** Do not batch multiple tasks into one commit. Do not continue to the next task until the current one is committed and pushed.

| Milestone | What to stage | Message |
|-----------|--------------|---------|
| ADR written | `docs/architecture/decisions/NNN-*.md` | `docs: add ADR NNN — <decision title>` |
| Test spec written | `docs/tasks/test-specs/NNN-*-test-spec.md`, updated `coverage-tracker.md` | `test: add spec for task NNN — <name>` |
| Task completed | `src/`, `tests/`, moved task file, updated `coverage-tracker.md` | `feat: complete task NNN — <name>` |
| Experiment run | `experiments/`, updated `experiment-tracker.md` | `experiment: <hypothesis> — <key result>` |
| Notebook added | `notebooks/` | `explore: add NNN — <topic>` |

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

## Boundaries

### Always
- Write the test spec before implementation code for `src/` modules
- Commit and push after every milestone (task, experiment, spec, ADR)
- Set random seeds explicitly for reproducibility
- Keep `data/raw/` immutable — derive everything into `data/processed/`
- Log experiments in the tracker before running them

### Ask first
- Modifying files in `docs/` — they are planning documents
- Deleting or regenerating processed data
- Adding dependencies not in the tech stack
- Changing the data pipeline architecture

### Never
- Modify files in `data/raw/` — they are immutable source data
- Combine unrelated changes in one task or commit
- Skip the test spec for `src/` code — even for "small" changes
- Commit large data files or model artifacts to git (use `.gitignore`)
- Force push or rewrite published git history
- Add a `Co-Authored-By` line to commits unless explicitly asked

## Common rationalizations

These are excuses agents use to skip steps. Don't fall for them.

| Excuse | Reality |
|--------|---------|
| "I'll commit after the next task too" | No. Commit now. Batched commits are impossible to untangle later. |
| "This is just a quick data transformation, no test needed" | If it goes in `src/`, it needs a test spec. Notebooks are for quick exploration. |
| "I'll log the experiment later" | Log it now. You'll forget the parameters and the result won't be reproducible. |
| "I don't need a config file for this experiment" | Yes you do. Without it, you can't reproduce the run or compare with future experiments. |
| "The raw data has a small issue, I'll just fix it in place" | Never. Copy to processed/ and fix it there. Raw data is immutable. |
| "I'll set the random seed later" | Set it now. Every experiment must be reproducible from day one. |
