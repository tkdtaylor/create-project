# Architecture Overview

**Project:** {{PROJECT_NAME}}
**Last updated:** {{DATE}}

## What this is

{{PROJECT_DESCRIPTION}}

## High-level design

> Describe the main components and how they interact. Add a diagram to `artifacts/diagrams/` if helpful.

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

This project follows **Unix philosophy** as its default design approach — favoring **composability over monolithic design**. The operating-system analogy is deliberate: Unix's lasting contribution is not any particular tool but the principle that complex behavior should emerge from combining small, independent components that communicate through standardized interfaces. Complex systems are built by chaining simple ones, not by growing one large one.

### The four structural properties to design for

- **Modularity** — break the system into independent units that can be built, understood, changed, and tested on their own. A module that "does two related things" is two modules. A function whose name needs an "and" in it is two functions.
- **Interface standardization** — components communicate through **stable, well-defined contracts**: typed function signatures, versioned APIs, plain-text formats (JSON, YAML, TOML, TSV), Unix-style pipes where it makes sense. A universal interface makes pieces composable without coordination. Bespoke interfaces make pieces captive.
- **Maintainability** — changes to one module should not require rewriting or redeploying the rest. If a one-line bug fix touches three unrelated services, the boundaries are wrong.
- **Reusability** — small, focused components should be combinable in ways the original author did not anticipate. Test: could this piece be lifted out and dropped into another project, or is it entangled with this one's specifics?

### Derived working rules

- **One thing, well** — each module, function, and service has a single clear responsibility.
- **Small, composable pieces over large configurable ones.** A 300-line function that branches on options is usually three 100-line functions that call each other. Composition is reversible; configuration flags accumulate and rarely get removed.
- **Plain text where possible.** Configs, intermediate artifacts, and data interchange in plain text. Plain text is inspectable with standard tools, greppable, version-controllable, diffable, and readable by both humans and agents.
- **Explicit over implicit.** Surface assumptions in code and types, not in comments or README paragraphs you hope someone reads.
- **Fail fast, crash loudly.** Unexpected state should raise or return an error, not be silently papered over with a default. Silent continuation is how subtle bugs become load-bearing.
- **Test in isolation.** Every component should be runnable and testable without spinning up the whole system. If you need the full stack to exercise one piece, the piece is too coupled.
- **Defer premature decisions.** No abstractions, plugin points, or configurability until the second or third concrete use case demands them. The cost of under-abstracting is one refactor; the cost of over-abstracting is a permanent tax on every future change.

### When composability is the wrong answer

Not every subsystem should be userspace-composable. **The Linux kernel itself is monolithic, and that is the right choice** — the performance, correctness, and safety properties of a kernel require tight internal coupling that a plug-in architecture would undermine. The same reasoning can apply to a hot-path runtime core, a tightly-coupled state machine, a cryptographic primitive, or a real-time control loop.

The principle is not *"always decompose"* — it is *"prefer composability for everything that lives at a user-facing or cross-module boundary, and be deliberate (with a documented ADR) when you go monolithic."* A monolithic core with composable userspace around it is the Unix pattern itself. **Monolithic is a legitimate choice; accidental monolithic is not.**

When reviewing a design or change, the architect agent weighs it against these principles and flags deviations.

## Constraints and non-goals

> What this project deliberately does NOT do. Helps avoid scope creep.

-
