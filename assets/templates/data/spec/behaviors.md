# Behaviors

**Project:** {{PROJECT_NAME}}
**Last updated:** {{DATE}}

What the pipeline does, observably. Each behavior describes a triggering condition, the system's response, and any externally-visible side effects. This is the "you can verify this from outside the process" view.

For data projects this includes: training runs, evaluation runs, inference, data ingestion, feature computation, experiment comparison.

Not in this file:
- *How* it does it (that's in source code; the contract is here, the implementation is there)
- *Why* it does it (that's in ADRs)
- *What data it operates on* (that's in [data-model.md](data-model.md))
- *What the entry points are* (that's in [interfaces.md](interfaces.md))

---

## Format

Each behavior is a numbered subsection with these parts:

> **B-NNN: Short imperative title**
>
> - **Trigger:** what causes this behavior to fire (CLI invocation, scheduled run, notebook cell, etc.)
> - **Inputs:** which datasets, configs, or upstream artifacts are required
> - **Response:** what the pipeline does
> - **Outputs:** what gets written and where (paths, tracker entries, model artifacts)
> - **Determinism:** what makes this run reproducible — seed sources, library version pinning, ordering guarantees
> - **Failure modes:** how it can fail and what the system does when it does
> - *(optional)* **References:** ADRs that drove the behavior, related experiment configs

Behaviors are numbered `B-001`, `B-002`, … sequentially. Numbers are stable references — never reuse a number, even if a behavior is removed (mark it `B-NNN: REMOVED — see ADR-XXX` and leave the number).

---

## Pipeline behaviors

> Replace this section with the system's primary behaviors. Order them roughly by where they sit in the pipeline (ingest → process → train → evaluate → serve), not chronologically by when they were added.

### B-001: <data ingestion / preprocessing behavior>

- **Trigger:**
- **Inputs:**
- **Response:**
- **Outputs:**
- **Determinism:**
- **Failure modes:**

### B-002: <training behavior>

- **Trigger:**
- **Inputs:**
- **Response:**
- **Outputs:**
- **Determinism:**
- **Failure modes:**

### B-003: <evaluation behavior>

- **Trigger:**
- **Inputs:**
- **Response:**
- **Outputs:**
- **Determinism:**
- **Failure modes:**

---

## Validation and quality behaviors

> How the pipeline catches its own mistakes — schema validation on raw inputs, leakage checks on splits, sanity bounds on metrics, regression alerts. Distinct from `Failure modes` above: these are *deliberate* checks, not unhandled errors.

### B-NNN: <validation title>

- **Trigger:**
- **Response:**
- **Outputs:**
- **Failure modes:**

---

## Behavioral invariants

> Cross-cutting properties that hold across many or all behaviors. Examples for data projects:
>
> - All training runs log `git rev-parse HEAD`, library versions, and seed into `experiments/results/<id>/`.
> - No behavior reads from or writes to `data/raw/` (only `data/processed/` is mutable).
> - Evaluation never touches data that was used in training or hyperparameter selection.
> - Predictions on held-out data are deterministic given (model artifact, input rows, seed).
>
> If an invariant is enforced by code (assertion, hash check, separate dataset partition), say so.

-
