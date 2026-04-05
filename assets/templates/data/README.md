# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Tech stack

{{TECH_STACK}}

## Getting started

### Run in Docker (recommended)

If Docker was set up during project creation, the container has Claude Code, Python, Jupyter, and the project dependencies pre-installed:

```bash
# Open an interactive shell inside the container
docker compose -f docker/docker-compose.yml run --rm dev

# Or open the project in VS Code with the Dev Containers extension
# Command Palette → "Dev Containers: Reopen in Container"
```

### Run locally

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start Jupyter Lab
jupyter lab

# Run tests
pytest
```

See [CLAUDE.md](CLAUDE.md) for full command reference and data pipeline details.

## Data

> TODO: describe data sources, formats, how to obtain, and any access requirements.

Raw data lives in `data/raw/` and is **immutable**. All transformations go to `data/processed/`.

## Project structure

```
data/
  raw/            original data (immutable — never modify)
  processed/      cleaned and transformed data
  external/       third-party sources
notebooks/        Jupyter notebooks for exploration (numbered: 01-*, 02-*)
src/
  data/           loading and preprocessing
  features/       feature engineering
  models/         model definitions and training
  evaluation/     metrics and evaluation
experiments/
  configs/        experiment configuration files
  results/        metrics, plots, artifacts per run
models/           saved model artifacts (gitignored)
tests/            unit tests for src/ modules
docs/             architecture, plans, task tracking
```

## How to work on this project

This project has two parallel workflows:

**Code in `src/`** — follows TDD:
1. Pick a task from [`docs/tasks/active/`](docs/tasks/active/)
2. Read its test spec in [`docs/tasks/test-specs/`](docs/tasks/test-specs/)
3. Implement until all tests pass
4. Move task to `completed/` and commit

**Experiments** — follow the hypothesis → config → run → log cycle:
1. Create a config in [`experiments/configs/`](experiments/configs/) with parameters, data source, hypothesis
2. Add a row to [`docs/tasks/experiment-tracker.md`](docs/tasks/experiment-tracker.md)
3. Run the experiment — use explicit random seeds for reproducibility
4. Save results to [`experiments/results/<id>-<name>/`](experiments/results/)
5. Update the tracker with results and verdict

### Working with Claude Code

[CLAUDE.md](CLAUDE.md) is loaded automatically in every session. It contains project conventions, commit rules, and the dual code/experiment workflow.

Key workflow:
- Use **plan mode** to plan multi-task work — a hook will restructure plans into task files automatically
- Use the **task-executor** agent for individual tasks
- Notebooks are for exploration; move reusable logic to `src/` modules
- Every experiment gets logged and committed with an `experiment:` prefix

## Key files

- [CLAUDE.md](CLAUDE.md) — project context for Claude Code sessions
- [docs/architecture/overview.md](docs/architecture/overview.md) — data flow and system design
- [docs/tasks/experiment-tracker.md](docs/tasks/experiment-tracker.md) — experiment log
- [docs/tasks/test-specs/coverage-tracker.md](docs/tasks/test-specs/coverage-tracker.md) — test coverage by task
