# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Tech stack

{{TECH_STACK}}

## Getting started

### Run locally

```bash
# TODO: fill in — install dependencies
# TODO: fill in — run tests
# TODO: fill in — start the app / run the entry point
```

### Run in Docker (recommended)

If Docker was set up during project creation, the container has Claude Code, the full runtime, and git pre-configured:

```bash
# Open an interactive shell inside the container
docker compose -f docker/docker-compose.yml run --rm dev

# Or open the project in VS Code with the Dev Containers extension
# Command Palette → "Dev Containers: Reopen in Container"
```

See [CLAUDE.md](CLAUDE.md) for full Docker and command reference.

## Project structure

```
src/          source code
artifacts/    non-code outputs (diagrams, schemas, exports)
tests/        unit tests
docs/         documentation
  architecture/   system design, ADRs, tech stack
  plans/          roadmap, sprints
  tasks/          active, backlog, completed task files
    test-specs/   TDD specs (written before implementation)
```

## How to work on this project

This project follows a TDD + task-based workflow:

1. **Pick a task** from [`docs/tasks/active/`](docs/tasks/active/) or [`docs/tasks/backlog/`](docs/tasks/backlog/)
2. **Read its test spec** in [`docs/tasks/test-specs/`](docs/tasks/test-specs/) — no implementation starts without one
3. **Implement** until all test cases pass
4. **Move** the task to [`docs/tasks/completed/`](docs/tasks/completed/) and commit

Tasks are scoped small — one task does one thing. When in doubt, break it smaller.

### Working with Claude Code

This project is set up to work with Claude Code. [CLAUDE.md](CLAUDE.md) is loaded automatically in every session and contains the project conventions, commit rules, and boundaries.

Key workflow:
- Use **plan mode** to plan multi-task work — a hook will restructure plans into task files automatically
- Use the **task-executor** agent to implement individual tasks in ephemeral context
- Every milestone (ADR, test spec, task completion) gets its own commit

## Key files

- [CLAUDE.md](CLAUDE.md) — project context for Claude Code sessions
- [docs/architecture/overview.md](docs/architecture/overview.md) — system design
- [docs/architecture/tech-stack.md](docs/architecture/tech-stack.md) — full tech stack table
- [docs/plans/roadmap.md](docs/plans/roadmap.md) — planned work
- [docs/tasks/test-specs/coverage-tracker.md](docs/tasks/test-specs/coverage-tracker.md) — test coverage by task
