# Data Model

**Project:** {{PROJECT_NAME}}
**Last updated:** {{DATE}}

What data exists, how it's structured, where it lives, and what relationships hold. Covers raw datasets, processed datasets, feature definitions, model artifacts, and experiment results.

For data projects this is the most load-bearing spec file. Schemas drift silently and silent drift is how silent bugs ship to production.

Not in this file:
- Operations on the data (that's in [behaviors.md](behaviors.md))
- How the data is accessed programmatically (that's in [interfaces.md](interfaces.md))
- Tunable parameters (that's in [configuration.md](configuration.md))

---

## Datasets

### Dataset: <name> (e.g. `data/raw/transactions/`, `data/processed/features-v3.parquet`)

- **Layer:** raw / processed / external / interim
- **Source:** where it comes from (vendor, scrape, prior pipeline step)
- **Format:** parquet / csv / jsonl / image directory / etc.
- **Partitioning:** how it's split on disk (by date, ticker, fold)
- **Size / cardinality:** approximate row count, file size, growth rate
- **Mutability:** immutable / append-only / regenerated each run
- **Owner:** which pipeline step writes it
- **Consumers:** which steps read it

#### Schema

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| | | | |

#### Quality contract

- What's guaranteed: ranges, monotonicity, key uniqueness, no-leakage rules
- How it's enforced: schema check, hash, validation step
- What's known to be dirty: documented quirks consumers must handle

> Add one section per dataset that matters. Group raw datasets, then processed, then external — readers usually scan top-down looking for "where does this come from."

---

## Features

> If features are reused across multiple models or experiments, document them here as named contracts. A feature definition that exists only in one notebook is implementation; a feature used in three places is a spec entity.

### Feature set: <name> (e.g. `price_momentum_v2`)

- **Source dataset:** where the underlying data comes from
- **Definition:** the formula / transformation, precise enough to recompute
- **Lookback window:** how much past data is required
- **Refresh cadence:** how often it's recomputed
- **Schema:**

| Column | Type | Range | Notes |
|--------|------|-------|-------|
| | | | |

---

## Model artifacts

> Trained models that are referenced by id elsewhere in the spec. Don't list every experiment's model — just the ones that have downstream consumers.

### Model: <name / id>

- **Architecture:** model class, hyperparameters that define it
- **Training data:** dataset id + split rule + seed used
- **Storage:** where the artifact lives (`models/<name>.pkl`, MLflow URI, etc.)
- **Inputs:** expected feature schema (link to a feature set above)
- **Outputs:** prediction shape and meaning
- **Performance contract:** the floor metrics it must meet to be considered shippable
- **Versioning:** how new versions are named and selected

---

## Experiment results

> The schema for `experiments/results/<id>/`. This is what makes results comparable across runs.

```
experiments/results/<id>/
├── config.yaml         # full run configuration (must match experiments/configs/<id>.yaml)
├── metrics.json        # numeric metrics — same keys across all runs in this project
├── plots/              # standard plots — same set per run for visual comparison
├── model.<ext>         # the trained artifact (or pointer to remote storage)
└── run-info.json       # git sha, library versions, hostname, wall time, seed
```

| File | Required | Schema |
|------|----------|--------|
| `config.yaml` | yes | mirror of the input config + any defaults filled in at runtime |
| `metrics.json` | yes | flat dict of metric_name → number; keys defined in [configuration.md](configuration.md) |
| `run-info.json` | yes | `{git_sha, python_version, library_versions, hostname, wall_seconds, seed}` |
| `model.<ext>` | conditional | required if behavior produces a usable artifact |
| `plots/` | optional | standard set of plots — list them here so all runs produce the same images |

---

## Data invariants

> Properties that must hold across the data model. Examples:
>
> - Every row in `data/processed/<set>` traces back to a row in `data/raw/<source>` via a stable id.
> - `train_X` and `test_X` row sets are disjoint by construction (asserted at split time).
> - All metric keys present in any `metrics.json` are documented in [configuration.md](configuration.md).
> - Model artifact loadable via `joblib.load(...)` produces deterministic predictions on a fixed sample.

-
