# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Project structure

```
src/          ← code outputs (what you write)
artifacts/    ← non-code outputs (diagrams, schemas, exports)
docs/         ← documentation inputs (what guides your work)
  architecture/   system design, ADRs, tech stack
  plans/          roadmap, sprints
  tasks/          active, backlog, completed task files
    test-specs/   TDD specs — always written before implementation
```

The key distinction: `docs/` is the input side (read before you act), `src/` is the output side (what gets produced).

## Tech stack

{{TECH_STACK}}

## Commands

```bash
# TODO: fill in — how to run tests
# TODO: fill in — how to build / compile
# TODO: fill in — how to start dev server / run the app
# TODO: fill in — how to lint / format
```

## Conventions

- Task files are named `NNN-short-name.md` (zero-padded, sequential across all task states)
- Every task has a paired test spec; no implementation starts without one
- Tasks follow Unix philosophy — one task, one responsibility; break things smaller when in doubt
- ADRs live in `docs/architecture/decisions/` — add one whenever a significant design decision is made

## Working in this project

1. Start each session by reading the relevant task file and its test spec
2. Check `docs/architecture/overview.md` for system context
3. Write the test spec before any implementation code
4. Move tasks to `completed/` and update `coverage-tracker.md` when done

## Do not

- Do not modify files in `docs/` unless explicitly asked — they are planning documents, not implementation
- Do not create new files in `src/` without a corresponding task and test spec
- Do not combine multiple unrelated changes in one task
- Do not skip the test spec even for "small" changes
- Do not add a `Co-Authored-By` line to commit messages unless explicitly asked
