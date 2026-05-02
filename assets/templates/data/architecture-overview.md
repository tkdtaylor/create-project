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

## Diagrams

Visual data lineage and pipeline flows live in [diagrams.md](diagrams.md). Add or update diagrams whenever a pipeline step is added, removed, or reordered.

## Authoritative spec

The source-of-truth spec lives in [`docs/spec/`](../spec/) — start there for what the pipeline *does and is* today (behaviors, datasets and schemas, interfaces, configuration). This overview is the narrative tour; the spec is the structured snapshot used for onboarding, drift checks, and reproducibility audits.

## Key decisions

See `docs/architecture/decisions/` for ADRs.

## Data sources

> TODO: list data sources, formats, update frequency, access requirements

## Reproducibility

- All experiments use explicit random seeds
- Experiment configs in `experiments/configs/` capture all parameters
- Data pipeline is deterministic given the same raw input
- Model artifacts in `models/` are gitignored — rebuild from config + data
