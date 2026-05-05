# Fitness functions

**Project:** {{PROJECT_NAME}}
**Last updated:** {{DATE}}

## What this file is

Fitness functions are **executable invariants** — automated checks that verify the pipeline still obeys the rules this project commits to. For data/ML projects these include reproducibility contracts (every experiment writes its seed and library versions), data integrity rules (`data/raw/` is never written to), pipeline determinism (splits are stable across runs), resource budgets (model artifact size, training memory), and the standard structural / performance / security checks any code project needs.

This file is the **declarative spec** for those checks. The implementation lives in the runner the rules point to (Makefile targets, pytest files, schema validators, log inspectors). This file does not describe how the checks are coded — it describes which invariants the pipeline must satisfy.

## Why this is separate from the rest of the spec

Three things in this project enforce alignment between the pipeline and what the spec claims. They have different jobs and run at different times:

| Mechanism | What it guards | When it runs |
|-----------|---------------|--------------|
| `spec-coverage-check` hook | Active task's TC markers must have test references before commit | Pre-commit (git commit) |
| `architect` drift-audit mode | Spec docs and diagrams still describe what the pipeline does | On demand, periodically |
| **Fitness functions (this file)** | **Invariants the pipeline must always satisfy — including reproducibility contracts** | **Continuously — `make fitness` locally, also at Stop in `strict` profile** |

The drift-audit asks *"do the docs still describe the pipeline?"* — semantic, agent-driven, episodic. Fitness functions ask *"does the pipeline still obey the rules?"* — mechanical, executable, continuous. For data projects the second question includes *"is every experiment still reproducible from its config?"* — and that's a fitness function, not a drift check.

## How to run

```bash
make fitness          # run all fitness functions
make fitness-<rule>   # run one rule by name (see table below)
```

Add new rules by:
1. Append a row to the **Rules** table below
2. Add a `fitness-<rule>` target to the Makefile that runs the underlying tool
3. Add `fitness-<rule>` to the `fitness` umbrella target's prerequisites

If a rule starts failing intentionally (e.g. a reproducibility contract has been deliberately loosened during a refactor), update or delete the row in the same commit — don't leave a dead rule in the table.

For tool selection per stack, see `references/fitness-functions.md` in the create-project skill.

## Rules

> Replace these example rows with the rules that actually hold for {{PROJECT_NAME}}. Keep entries concrete: the rule must be checkable by a tool, and the threshold must be a number or a yes/no, not a vibe. Delete rules that are no longer load-bearing.

| ID | Rule | Category | Asserts | Threshold | Check command | Severity |
|----|------|----------|---------|-----------|---------------|----------|
| F-001 | *(example) Raw data is immutable* | data integrity | No file under `data/raw/` was modified after its initial commit | 0 modifications | `make fitness-raw-immutable` | block |
| F-002 | *(example) Every experiment records its seed and library versions* | reproducibility | Every `experiments/results/*/run-info.json` contains `seed`, `python_version`, and pinned versions for the libraries listed in `configuration.md` | 100% | `make fitness-repro-contract` | block |
| F-003 | *(example) Train/test split determinism* | reproducibility | Re-running the splitter with the configured seed produces byte-identical split files | 0 diff | `make fitness-split-determinism` | block |
| F-004 | *(example) No cycles between src/ subpackages* | structural | `src/data`, `src/features`, `src/models`, `src/evaluation` form a DAG | 0 cycles | `make fitness-no-cycles` | block |
| F-005 | *(example) Notebooks do not import notebooks* | layering | Reusable logic lives in `src/`; one notebook never imports another | 0 violations | `make fitness-notebook-boundary` | warn |
| F-006 | *(example) Inference latency budget* | performance | Single-record inference p95 on the reference machine | < 100ms | `make fitness-inference-perf` | warn |
| F-007 | *(example) Model artifact size cap* | resource budget | Saved model in `models/` does not exceed the documented size limit | < 250 MB | `make fitness-model-size` | warn |
| F-008 | *(example) Zero high-severity dependency CVEs* | security | Dependency scan reports no high or critical CVEs | 0 high+ | `make fitness-deps` | block |

Categories: `data integrity` (raw immutability, schema stability), `reproducibility` (seeds, versions, split determinism, config-completeness), `structural` (cycles, layering, dependency direction), `performance` (training/inference latency, throughput), `resource budget` (artifact size, memory), `complexity` (cyclomatic, file size), `security` (deps, surface, secrets), `coverage` (test coverage thresholds).

Severity:
- `block` — fitness check exits non-zero; the runner reports a failure. Reproducibility and data-integrity rules are almost always `block`.
- `warn` — surfaces in output but does not fail the runner. Use for budgets that may have a temporary justified excursion.

## Source-of-truth links

> List which other spec files or ADRs each rule traces back to, so a reader can find the *why*.

- F-001 (raw immutable) ← top-level invariants in [SPEC.md](SPEC.md)
- F-002, F-003 (reproducibility) ← `configuration.md` §Reproducibility contract
- F-004 (no cycles) ← `architecture.md` §Components
- F-007 (model size) ← `data-model.md` §Model artifacts

## Notes

- Reproducibility-affecting rules belong in this file — every parameter that changes results must either be captured by a fitness function or by a config the function reads from. Silent reproducibility drift is the most expensive kind of drift in a data project.
- Rules should fail fast and have low false-positive rates. A rule that flags 50 things every run gets ignored.
- The hook only runs at `strict` profile so fast iteration isn't slowed down. Run `make fitness` manually before any milestone where invariants matter — especially before promoting a model or publishing results.
