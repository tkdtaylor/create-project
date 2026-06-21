# Architecture Overview

**Project:** {{PROJECT_NAME}}
**Last updated:** {{DATE}}

## What this is

{{PROJECT_DESCRIPTION}}

## High-level design

> Describe the main components and how they interact. Visual diagrams (system components, runtime flows, state machines) live in [diagrams.md](diagrams.md) — keep this section to prose context that the diagrams reference.

> The full source-of-truth spec lives in [`docs/spec/`](../spec/) — start there if you need to know what the system *does and is* today (behaviors, data model, interfaces, configuration). This overview is the narrative tour; the spec is the structured snapshot.

## Key decisions

> Summarize the most important design choices here. Full rationale lives in `decisions/NNN-*.md` (ADRs).

| Decision | Choice | ADR |
|----------|--------|-----|
| | | |

## Data flow

> Describe how data enters the system, moves through it, and exits. One paragraph or a simple diagram is enough.

## External dependencies

> Third-party services, APIs, databases, or infrastructure this project relies on.

| Dependency | Purpose | Notes |
|------------|---------|-------|
| | | |

## Design principles

{{PROJECT_NAME}} follows **Unix philosophy** — composability over monolithic design. The full statement (the four structural properties, the derived working rules, and when monolithic is the right call) lives in `AGENTS.md` under *Design principles*. Do not restate it here.

> Instead, state the **load-bearing instance for this project**: the one seam or boundary where independently-evolving implementations plug in through a small, well-defined contract — and call out any core that is deliberately cohesive (monolithic) for correctness, and why. Keep it to a few sentences. This overview is an architecture overview of *this specific project*, not a place to re-explain the general philosophy. When reviewing a change, the architect agent weighs it against these principles.

## Constraints and non-goals

> What this project deliberately does NOT do. Helps avoid scope creep.

-
