# {{PROJECT_NAME}} — Authoritative Spec

**Project:** {{PROJECT_NAME}}
**Last updated:** {{DATE}}

## What this directory is

`docs/spec/` is the **authoritative current-state snapshot** of {{PROJECT_NAME}}. It answers the question:

> "If the code and notebooks were deleted tomorrow, what would I need to write down to rebuild this work — and reproduce its results?"

The spec is dual-natured:

- **Output of current sessions** — every completed task or experiment that changes the data pipeline, the model contract, an interface, or a configuration must update the relevant spec file in the same commit.
- **Input to future sessions** — used for onboarding, drift audits against the code, and (in the limit) regenerating the codebase from scratch with the same scientific results.

The code is one *realization* of this spec. If the spec and code disagree, one of them is wrong — fix the wrong one in that same change. **Reproducibility is non-negotiable for data projects: the spec must capture every parameter that affects results.**

## Spec vs. ADRs vs. overview

| Doc | Purpose | Lifecycle |
|-----|---------|-----------|
| [`docs/spec/`](.) | What the system **does and is** today | Snapshot — supersede in place, never append |
| [`docs/architecture/decisions/`](../architecture/decisions/) | **Why** decisions were made | Append-only history; ADRs can be superseded by later ADRs |
| [`docs/architecture/overview.md`](../architecture/overview.md) | Narrative tour of the system | Snapshot, but optimized for human reading |
| [`docs/architecture/diagrams.md`](../architecture/diagrams.md) | Visual data lineage and pipelines | Snapshot, part of the spec |

When a model architecture or feature set is replaced, the spec just reflects the new choice. The ADRs preserve the reasoning trail; the spec preserves the current truth.

## The four files

| File | Covers | Read this when |
|------|--------|---------------|
| [behaviors.md](behaviors.md) | What the pipeline does — training, evaluation, inference behaviors and their observable contracts | You need to know what should happen when you run X |
| [data-model.md](data-model.md) | Datasets, schemas, feature definitions, model artifacts, experiment results | You need to know what data exists and how it's structured |
| [interfaces.md](interfaces.md) | CLI runners, notebook entrypoints, model serving APIs, public Python modules | You need to know how to invoke or extend the pipeline |
| [configuration.md](configuration.md) | Experiment configs, hyperparameters, dataset paths, environment variables | You need to know what's tunable and how to reproduce a run |

The spec **starts at four files and grows organically**. If a topic outgrows its file (e.g. data-model.md becomes too large because the project has many feature sets), split it: `data-model-features.md`, `data-model-artifacts.md`. Don't force everything into the original four.

## Maintenance rules

1. **Update in the same commit as the code change.** A task that changes the pipeline is not done until the spec reflects it. The Boundaries section of `CLAUDE.md` enforces this.
2. **Supersede in place. Never append.** When a hyperparameter, feature definition, or model architecture changes, rewrite the spec entry — don't add a "previously this was X" note. The ADR carries that history.
3. **No future tense.** The spec describes what *is*, not what *will be*. Roadmap and planned experiments live in `docs/plans/` and the experiment tracker.
4. **No implementation rationale.** "We chose this loss function because Y" belongs in an ADR. The spec just says "uses cross-entropy loss."
5. **Capture every reproducibility-affecting parameter.** Random seeds, data split rules, library versions where they matter, hardware assumptions where they matter. If it changes results, it goes in the spec.
6. **Audit drift periodically.** Use the `architect` agent's drift-audit mode to check the spec against the code. Drift accumulates silently; catch it before it gets large.

## Project summary

> Replace this with a 2–4 sentence description of what {{PROJECT_NAME}} does — what data it ingests, what it produces, and the scientific or business question it answers.

{{PROJECT_DESCRIPTION}}

## Top-level invariants

> List the load-bearing rules that hold across the entire pipeline. These are the things that, if violated, invalidate the work — not just one experiment. Examples:
>
> - `data/raw/` is immutable. All transformations write to `data/processed/`.
> - Train/test/holdout splits are fixed at the dataset level by deterministic seed; no leakage between splits.
> - Every experiment writes its full config (including seed and library versions) into `experiments/results/<id>/config.yaml`.
> - No model is evaluated against data it has seen during training or hyperparameter search.

-

## Non-goals

> What this project deliberately does **not** do. Distinct from constraints — these are scope decisions. Helps prevent scope creep and wrong-shape contributions.

-
