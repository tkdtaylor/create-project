# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Getting started

### Run in Docker (recommended)

If Docker was set up during project creation, the container has Claude Code, Python, pandoc, PDF tools, and the research dependencies pre-installed:

```bash
# Open an interactive shell inside the container
docker compose -f docker/docker-compose.yml run --rm research

# Or open the project in VS Code with the Dev Containers extension
# Command Palette → "Dev Containers: Reopen in Container"
```

### Run locally

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

See [CLAUDE.md](CLAUDE.md) for full command reference.

## Project structure

```
sources/        input materials (never edited — treat as read-only)
  local/          files the user provided
  web/            saved pages and downloaded references
notes/          working synthesis (scratchpad — can be messy)
  by-topic/       notes organized by research area
outputs/        final deliverables
  drafts/         work in progress
  final/          completed and approved pieces
docs/           project management
  research-log.md   running log of searches and findings
  outline.md        target structure for the output
  tasks/            active, backlog, completed
```

## How to work on this project

Research tasks define **a question to answer**, not a deliverable to build. A task is done when the question is answered.

1. **Pick a task** from [`docs/tasks/active/`](docs/tasks/active/)
2. **Check the research log** in [`docs/research-log.md`](docs/research-log.md) to avoid duplicating previous searches
3. **Research and synthesize** — save worthwhile sources to `sources/web/`, add notes to `notes/by-topic/`
4. **Log every search** in the research log (including empty results — dead ends prevent duplicate work)
5. **Move the task to `completed/`** when the research question is answered and commit

### Sources workflow

- **`sources/`** — input materials, never edited. Save web results here with URL + date at the top of each file.
- **`notes/`** — working synthesis. Can be messy. Organize by topic, not by source.
- **`outputs/drafts/`** — work in progress, ready for review.
- **`outputs/final/`** — requires explicit user review before writing.

### Working with Claude Code

[CLAUDE.md](CLAUDE.md) is loaded automatically in every session. It contains the research approach, commit rules, and source handling conventions.

Key workflow:
- Use **plan mode** to plan multi-task research — a hook will restructure plans into task files automatically
- Use the **task-executor** agent for individual research tasks
- Every completed task and outline update gets its own commit

## Key files

- [CLAUDE.md](CLAUDE.md) — project context for Claude Code sessions
- [docs/research-log.md](docs/research-log.md) — searches and findings
- [docs/outline.md](docs/outline.md) — target output structure
- [docs/tasks/progress-tracker.md](docs/tasks/progress-tracker.md) — task status
