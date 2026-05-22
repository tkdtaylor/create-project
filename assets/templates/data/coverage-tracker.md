# Test Coverage Tracker

**Project:** {{PROJECT_NAME}}

## Rules

- Test specs are written **before** implementation begins — no exceptions for `src/` code
- A task is **not** "complete" because the feat commit landed and unit tests passed. Reproducibility on a fixture or measured-metric improvement is the bar. See the verification ladder below.
- Each row maps a task ID to its spec file, current test status, and the verification level achieved

## Coverage

| Task ID | Feature | Spec file | Tests written | Status | Verified by |
|---------|---------|-----------|---------------|--------|-------------|
| | | | | | |

## Status key

| Symbol | Meaning |
|--------|---------|
| ✅ | **Verified** — pipeline ran end-to-end on a known fixture and the measured metric matches the acceptance threshold, **or** the operator observed the targeted behaviour live |
| 🟡 | **Code merged** — feat-commit landed, unit tests + fitness + CI green, but no end-to-end run on a fixture yet |
| ⏳ | In progress |
| ❌ | Not started |
| ⚠️ | Blocked |

## Verification ladder

A task earns 🟡 at levels 1–4 and ✅ only at level 5 or 6. The `Verified by` column records which level the row reached, with the measured metric and the fixture/run ID.

| Level | Evidence | Status this earns |
|-------|----------|-------------------|
| 1 | Code merged | 🟡 |
| 2 | Unit tests pass (paste verbatim final line of `make check`) | 🟡 |
| 3 | `make fitness` passes — reproducibility invariants hold (raw-data immutability, seed coverage, metric-catalog completeness) | 🟡 |
| 4 | CI passes (`gh run watch <id> --exit-status` → success) | 🟡 |
| 5 | **End-to-end pipeline run** on a fixture dataset — measured metric reported with its number, fixture path, and run ID; metric meets the acceptance threshold | ✅ |
| 6 | **Operator-observed** — operator ran the pipeline against real data and observed the targeted behaviour (model artifact loaded, inference shape correct, dashboard updated) | ✅ |

For data tasks, the most common gap is "the feature transform passed unit tests but the live pipeline never ingests it." Level 5 closes that gap — a real pipeline run on a fixture proves the transform is wired in, not just defined.

## Rule

**The task-executor commits at 🟡 by default.** Only the main session (after spec-verifier APPROVE + level-5/6 evidence) updates the row to ✅, in a separate commit titled `verify: confirm task NNN — <fixture and measured metric>`. This keeps the verification step visible in git history and prevents "trained ≠ deployed" drift.
