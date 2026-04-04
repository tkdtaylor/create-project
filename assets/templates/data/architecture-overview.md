# Architecture Overview — {{PROJECT_NAME}}

> Generated: {{DATE}}

## System purpose

{{PROJECT_DESCRIPTION}}

## Data flow

```
data/raw/ → [preprocessing] → data/processed/ → [feature engineering] → [model training] → models/
                                                                                              ↓
                                                                     experiments/results/ ← [evaluation]
```

## Components

| Component | Location | Responsibility |
|-----------|----------|---------------|
| Data loading | `src/data/` | Read raw data, validate schema, output processed datasets |
| Feature engineering | `src/features/` | Transform processed data into model-ready features |
| Model definitions | `src/models/` | Model architecture, training loops, hyperparameter configs |
| Evaluation | `src/evaluation/` | Metrics computation, result formatting, comparison utilities |

## Key decisions

See `docs/architecture/decisions/` for ADRs.

## Data sources

> TODO: list data sources, formats, update frequency, access requirements

## Reproducibility

- All experiments use explicit random seeds
- Experiment configs in `experiments/configs/` capture all parameters
- Data pipeline is deterministic given the same raw input
- Model artifacts in `models/` are gitignored — rebuild from config + data
