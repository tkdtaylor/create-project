# Task {{TASK_ID}}: {{TASK_NAME}}

**Project:** {{PROJECT_NAME}}
**Created:** {{DATE}}
**Status:** active

## Goal

> One clear sentence: what does completing this task achieve?

## Context

- Tech stack: {{TECH_STACK}}
- Related ADRs: `docs/architecture/decisions/`
- Dependencies: none (or list task IDs this depends on)

## Requirements

> Link acceptance criteria to requirement IDs for traceability. Use the format `REQ-NNN` where NNN matches the feature or spec area. This lets you trace from requirement → task → test spec → code.

| Req ID | Description | Priority |
|--------|-------------|----------|
| REQ-001 | | must have |
| | | |

## Readiness gate

Before writing any code, verify:

- [ ] Test spec `{{TASK_ID}}-{{TASK_SLUG}}-test-spec.md` exists in `docs/tasks/test-specs/`
- [ ] All acceptance criteria below have a linked REQ ID
- [ ] Any blocking tasks are complete

## Acceptance criteria

> Each criterion should reference its requirement: `[REQ-001]` description of what done looks like.

- [ ] [REQ-001]
- [ ]

## Verification plan

> **How will we know this works end-to-end on a fixture or real dataset?** Fill this in *before* writing code or running an experiment. A task that can't articulate this up-front cannot be marked ✅ later. See `docs/tasks/test-specs/coverage-tracker.md` for the full verification ladder.

- **Highest level achievable:** L<N> — <one-line reason>
- **Level 5 — End-to-end pipeline run (if applicable):**
  - Fixture dataset: `<path, e.g. data/fixtures/test_2024_01.parquet>`
  - Command: `<exact invocation, e.g. python -m src.train --config experiments/configs/NNN.yaml>`
  - Acceptance metric: `<metric name>` ≥ `<threshold number>` (or other comparison)
- **Level 6 — Operator observation (if applicable):**
  - Real-data run: `<command to run on production sample>`
  - Targeted observation: `<artifact / dashboard / inference shape that should appear>`
- **Cross-stage state risk:** <none | new feature column / artifact path / metric key — the executor must produce a producer-consumer trace>
- **Pipeline-visible surface:** <none | data load | training | eval | inference | artifact serialization — the executor must run the pipeline path end-to-end>
- **Random seed:** `<seed value>` (required for any experiment)

If the task is a pure utility or doc change with no pipeline behaviour, write *"L2 only — utility code, unit-test-covered"* and explain why ✅ at L2 is appropriate here.

## Out of scope

> What this task deliberately does NOT cover. Helps keep it atomic.

-

## Notes

> Any context useful for Claude or future collaborators — decisions made, gotchas, links.
