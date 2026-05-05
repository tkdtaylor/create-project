# {{PROJECT_NAME}} — Authoritative Spec

**Project:** {{PROJECT_NAME}}
**Last updated:** {{DATE}}

## What this directory is

`docs/spec/` is the **authoritative current-state snapshot** of {{PROJECT_NAME}}. It answers the question:

> "If the code were deleted tomorrow, what would I need to write down to rebuild it?"

The spec is dual-natured:

- **Output of current sessions** — every completed task that changes externally-observable behavior, the data model, an interface, or configuration must update the relevant spec file in the same commit.
- **Input to future sessions** — used for onboarding, drift audits against the code, and (in the limit) regenerating the codebase from scratch.

The code is one *realization* of this spec. If the spec and code disagree, one of them is wrong — fix the wrong one in that same change.

## Spec vs. ADRs vs. overview

| Doc | Purpose | Lifecycle |
|-----|---------|-----------|
| [`docs/spec/`](.) | What the system **does and is** today | Snapshot — supersede in place, never append |
| [`docs/architecture/decisions/`](../architecture/decisions/) | **Why** decisions were made | Append-only history; ADRs can be superseded by later ADRs |
| [`docs/architecture/overview.md`](../architecture/overview.md) | Narrative tour of the system | Snapshot, but optimized for human reading |
| [`docs/architecture/diagrams.md`](../architecture/diagrams.md) | Visual structure and flows | Snapshot, part of the spec |

When ADR-005 supersedes ADR-001, the spec just reflects the new choice. The ADRs preserve the reasoning trail; the spec preserves the current truth.

## The six files

| File | Covers | Read this when |
|------|--------|---------------|
| [behaviors.md](behaviors.md) | What the system does — user-facing behaviors, use cases, observable contracts | You need to know what should happen when X |
| [architecture.md](architecture.md) | C4 element catalog — persons, systems, containers, components, cross-cutting decisions | You need a structured/queryable view of the architecture (paired with [`../architecture/diagrams.md`](../architecture/diagrams.md)) |
| [data-model.md](data-model.md) | Entities, schemas, persistent state, in-memory state shape | You need to know what data exists and how it's structured |
| [interfaces.md](interfaces.md) | External and internal interfaces — CLI, APIs, public traits, wire protocols | You need to know what calls into or out of the system |
| [configuration.md](configuration.md) | Env vars, config files, runtime parameters, deployment knobs | You need to know what's tunable |
| [fitness-functions.md](fitness-functions.md) | Executable architectural invariants — layering, perf budgets, security thresholds, complexity ceilings | You're adding a continuous check, or wondering why `make fitness` exists |

The spec **starts at six files and grows organically**. If a topic outgrows its file (e.g. interfaces.md becomes too large because the project exposes both a CLI and a wire protocol), split it: `interfaces-cli.md`, `interfaces-protocol.md`. Don't force everything into the original six.

### Spec vs. fitness functions vs. drift audit

The first five files describe what *is*; `fitness-functions.md` declares what *must always hold* and is checkable by a tool. The two are different shapes of truth:

- The spec describes the system. Drift audit (the `architect` agent's mode 3) reconciles spec docs against the code on demand.
- Fitness functions enforce invariants on every run of `make fitness` — locally, and at Stop in the `strict` hook profile. They are the executable backbone of the architectural rules the spec implies.

If the rule can be expressed as code, prefer a fitness function over relying on drift audit to catch a regression after the fact.

## Maintenance rules

1. **Update in the same commit as the code change.** A task that changes behavior is not done until `behaviors.md` reflects it. The Boundaries section of `CLAUDE.md` enforces this.
2. **Supersede in place. Never append.** When a decision changes, rewrite the spec entry — don't add a "previously this was X" note. The ADR carries that history.
3. **No future tense.** The spec describes what *is*, not what *will be*. Roadmap and planned work live in `docs/plans/` and `docs/tasks/`.
4. **No implementation rationale.** "We chose X because Y" belongs in an ADR. The spec just says "uses X."
5. **Audit drift periodically.** Use the `architect` agent's drift-audit mode to check the spec against the code. Drift accumulates silently; catch it before it gets large.

## Project summary

> Replace this with a 2–4 sentence description of what {{PROJECT_NAME}} is and what it does. This is the elevator pitch — anyone reading just this section should know whether the spec is relevant to their question.

{{PROJECT_DESCRIPTION}}

## Top-level invariants

> List the load-bearing rules that hold across the entire system. These are the things that, if violated, break the spec — not just one feature. Examples:
>
> - All persistent writes go through the repository layer; no direct DB access from handlers.
> - Strategies depend only on `types` and `strategy` crates; never on `engine`. (Build-time guard enforces.)
> - Time is read from the `Clock` abstraction, never `SystemTime::now()` directly.

-

## Non-goals

> What this project deliberately does **not** do. Distinct from constraints — these are scope decisions. Helps prevent scope creep and wrong-shape contributions.

-
