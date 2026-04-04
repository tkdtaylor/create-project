# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Setup

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run tests
# TODO: fill in
```

## Project structure

| Directory | Purpose |
|-----------|---------|
| `data/raw/` | Original, immutable data |
| `data/processed/` | Cleaned and transformed data |
| `notebooks/` | Jupyter notebooks for exploration |
| `src/` | Reusable Python modules |
| `experiments/` | Experiment configs and results |
| `models/` | Saved model artifacts |
| `tests/` | Unit tests |
| `docs/` | Architecture, plans, and task tracking |

## Data

> TODO: describe data sources, format, and how to obtain

## Experiments

See `docs/tasks/experiment-tracker.md` for the experiment log.

Each experiment has:
- A config file in `experiments/configs/`
- Results (metrics, plots) in `experiments/results/`
