# create-project

A Claude Code skill that scaffolds new projects with opinionated structure, isolated Docker workspaces, and Claude-specific tooling setup.

> **Note:** This skill is a work in progress. If you run into any issues, please [open an issue](https://github.com/tkdtaylor/create-project-skill/issues) on the repo.

## What it does

Triggered by phrases like "start a new project", "scaffold a codebase", "set up a research project", or "start a data science project". The skill:

1. Interviews you until the goal, scope, and success criteria are unambiguous — confirms a written summary before touching any files
2. Creates a type-matched directory structure with template files
3. Generates a `CLAUDE.md` so every future session starts with full project context
4. **Technical / Data:** offers to scaffold a minimal runnable starter in `src/` (health endpoint, CLI entrypoint, data pipeline skeleton, etc.)
5. **Research:** offers to run initial web searches and seed `sources/web/` so the project starts with real material
6. Optionally initialises git and creates a GitHub repo (with scoped access token for the container)
7. **Technical / Data:** sets up Docker automatically — shared base image + project-specific image (with the right runtime installed) + per-project named volume
8. **Technical / Data:** adds a VS Code devcontainer config automatically so you can open the project inside the container
9. Recommends skills, hooks, and agents suited to the project (MCPs only when skills can't cover the need); offers to create `.claude/agents/` files for the suggested agents with model tiers auto-mapped to the best available model
10. Installs hooks: plan-to-tasks restructuring on exit from plan mode, secret file write protection, and context recovery after compaction — with a task-executor agent for working through tasks efficiently

## First-time setup

Every project created by this skill includes a `.claude/settings.json` that auto-approves most bash commands inside the container while retaining prompts for destructive operations (`sudo`, `rm -rf`, `git push --force`, etc.). It also configures three hooks: plan restructuring on exit from plan mode, secret file write protection, and context recovery after compaction. No manual configuration needed per project.

If you want the same behaviour on the **host** or in sessions outside a project container, add the same permissions to your global `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Bash(*)", "Read", "Write", "Edit", "Glob", "Grep"],
    "ask": [
      "Bash(sudo:*)",
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)",
      "Bash(git push -f:*)",
      "Bash(git reset --hard:*)",
      "Bash(dd :*)",
      "Bash(mkfs:*)"
    ]
  }
}
```

---

## Dependencies

### Required

**Claude Code**
The skill runs inside Claude Code. Install it via npm or the desktop app:
```bash
npm install -g @anthropic-ai/claude-code
```
→ https://docs.anthropic.com/en/docs/claude-code

---

### For Docker workspaces (steps T6/D6/R6)

**Docker Engine**
The skill checks for Docker automatically and skips the Docker setup steps if it's not found. Docker Compose is optional — the skill detects whether `docker compose` (v2 plugin) or `docker-compose` (v1 standalone) is available and writes commands accordingly. If neither is installed, it falls back to plain `docker run` commands.

- **Mac / Windows:** Install Docker Desktop → https://www.docker.com/products/docker-desktop
- **Linux:** Install Docker Engine (Compose plugin optional but recommended):
  ```bash
  # Debian / Ubuntu
  curl -fsSL https://get.docker.com | sh
  sudo apt-get install docker-compose-plugin   # optional
  sudo usermod -aG docker $USER   # log out and back in after this
  ```
  → https://docs.docker.com/engine/install/

---

### For GitHub repo creation (steps T5/D5/R5)

**GitHub CLI (`gh`)**
Optional. If installed, the skill can create the GitHub repository and configure the remote automatically. Without it, the skill gives manual instructions instead.

```bash
# Mac
brew install gh

# Linux (Debian / Ubuntu)
sudo apt install gh

# Windows
winget install GitHub.cli
```
→ https://cli.github.com

After installing, authenticate:
```bash
gh auth login
```

**Note on tokens:** The skill does not attempt to generate a personal access token programmatically — it guides you through creating a fine-grained PAT manually at https://github.com/settings/personal-access-tokens/new. The `gh api` approach for PAT generation requires an extra auth scope that usually isn't granted and fails silently more often than it works.

---

### For VS Code IDE integration (steps T7/D7/R7)

**VS Code Dev Containers extension**
Optional. Lets you open the project directly inside the Docker container — your editor, terminal, and Claude Code all run in the isolated workspace.

Install from VS Code Extensions panel: search **Dev Containers** (publisher: Microsoft)
or:
```bash
code --install-extension ms-vscode-remote.remote-containers
```
→ https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers

---

## Project types

| Type | Use when | Key structure |
|------|----------|---------------|
| **technical** | Building software — APIs, CLIs, scripts, automation | `src/`, `artifacts/`, `docs/` with TDD scaffolding (test specs before tasks) |
| **data** | Data science or machine learning — model training, data pipelines, analytics, experiment-driven work | `data/`, `notebooks/`, `src/`, `experiments/`, `models/`, `tests/`, `docs/` with dual TDD + experiment tracking |
| **research** | Synthesising information — literature reviews, competitive analysis, report writing | `sources/`, `notes/`, `outputs/`, `docs/` |
| **other** | Planning, tracking, organising — wedding planning, job search, project management | Research base structure with domain-specific top-level folders (e.g. `vendors/`, `budget/`, `timeline/`) chosen by the user |

## Docker architecture

The Docker setup gives Claude (or any tool) a fully isolated, persistent workspace without any access to the host filesystem beyond the project root — and even that is read-only after the first-run seed.

### Security model

| | Container sees | Can write |
|---|---|---|
| `/app` or `/workspace` | Named volume — project workspace | Yes |
| `/host` | Host project root (bind mount) | No — read-only |
| `/app/.env` | Host `.env` file (bind mount) | Yes |
| `~/.claude/` | Host Claude Code config directory (bind mount) | Yes — writable so Claude can refresh tokens and write session state |
| Everything else on host | Nothing | — |

The container runs as a non-root `developer` user. The entrypoint performs privileged init steps as root then drops to `developer` via `gosu` before starting the shell. This means Claude Code cannot install system packages, modify OS config, or escalate privileges.

### Shared base images

Built once per machine, reused across all projects of that type:

| Image | Contents |
|-------|----------|
| `claude-project-dev:latest` | debian:bookworm-slim + git + Python + Node + Claude Code |
| `claude-project-research:latest` | same + pandoc + poppler-utils + Python research libs |

The skill stores a `sha256` hash of each Dockerfile as a Docker label and rebuilds automatically when the content changes. To update (e.g. pin a Claude Code version), edit `assets/base/tech.Dockerfile` — the next project setup detects the hash change and rebuilds.

### Per-project (created in seconds)

- Named Docker volume (`<project-name>-workspace`) — the container's isolated, persistent workspace
- `docker/Dockerfile` extending the shared base with the project's runtime (Rust, Go, etc.) and a uid/gid fix so bind-mounted host files are accessible
- `docker/docker-compose.yml` building from the project Dockerfile, with all required volume and credential mounts
- `.env` with API keys and git credentials (gitignored) — `GIT_USER_NAME` and `GIT_USER_EMAIL` pre-filled from host git config if set
- `.devcontainer/devcontainer.json` for VS Code — created automatically

### Entrypoint behaviour (runs on every `docker compose run`)

1. Volume empty → copy project files from `/host` into volume + `chown` to `developer`
2. `requirements.txt` present + `.venv` missing or hash changed → create/update venv + `pip install`
3. `.venv` broken after base image update → auto-recreate
4. Export `VIRTUAL_ENV` and `PATH` for venv activation
5. Configure git identity and credential helper from env vars (`GIT_USER_NAME`, `GIT_USER_EMAIL`, `GIT_TOKEN`) — token is never written to disk
6. Drop privileges → `exec gosu developer "$@"`

### VS Code workflow

```
open project folder in VS Code
  → Dev Containers: Reopen in Container
    → entrypoint seeds volume + installs deps (first open only)
      → VS Code connects as developer user to /app or /workspace
        → Claude Code, terminal, language servers all run inside the container
```

## Repo structure

```
assets/
  base/                          # Shared Docker base images — managed by the skill
    tech.Dockerfile
    tech-entrypoint.sh           # init + gosu privilege drop
    research.Dockerfile
    research-entrypoint.sh
  templates/
    tech/                        # Per-project templates — technical projects
      CLAUDE.md
      devcontainer.json
      .claude/
        settings.json            # permissions + hooks (plan, secrets, post-compact)
        scripts/
          restructure-plan.py    # splits plans into task files on exit from plan mode
          protect-secrets.py     # blocks writes to private keys and credential files
          post-compact.py        # re-injects task context after context compaction
        agents/
          task-executor.md       # ephemeral agent for executing one task at a time
      docker/
        Dockerfile               # extends shared base with project runtime + uid fix
        docker-compose.yml       # builds project image, mounts volume + credentials
        .env.example             # documents all required env vars including git creds
        requirements.txt
      [architecture, task, roadmap templates...]
    data/                        # Per-project templates — data / ML projects
      CLAUDE.md
      devcontainer.json
      .claude/                   # same hooks and agents as tech (adapted for ML workflow)
      docker/                    # same Docker pattern as tech
      experiment-tracker.md      # tracks experiment runs alongside coverage-tracker
      [architecture, task, roadmap templates...]
    research/                    # Per-project templates — research projects
      CLAUDE.md
      devcontainer.json
      .claude/                   # same hooks, research-adapted task-executor agent
      docker/
        docker-compose.yml
        .env.example
        requirements.txt         # pre-populated with requests, bs4, pdfminer, markdownify
      [outline, task, research-log templates...]
references/
  tech-project.md                # Step-by-step setup for technical projects (T1–T7)
  data-project.md                # Step-by-step setup for data / ML projects (D1–D7)
  research-project.md            # Step-by-step setup for research / other projects (R1–R7)
  tooling.md                     # Skills, MCP servers, hooks, and agents catalog with project-type matching
evals/
  evals.json                     # Test cases and assertions for skill evaluation
SKILL.md                         # Entry point — gathers info, routes to reference files
README.md                        # This file
```

## Installing / updating

The skill is developed here and installed to `~/.claude/skills/create-project/`. To sync after changes:

```bash
rm -rf ~/.claude/skills/create-project && cp -r /path/to/create-project-skill ~/.claude/skills/create-project
```

The installed directory name must match the `name:` field in `SKILL.md` (`create-project`).

## Upgrading existing projects

Projects created with an older version of this skill won't automatically get new features (hooks, agents, boundaries, etc.). You can retrofit them by copying the relevant files from the current templates into your project.

### What to copy

The files below live in `assets/templates/<type>/` (where `<type>` is `tech`, `data`, or `research`). Copy them into the matching paths in your existing project:

| File | What it adds |
|------|-------------|
| `.claude/settings.json` | Permissions + hooks (plan restructuring, secret protection, post-compact recovery) |
| `.claude/scripts/restructure-plan.py` | Plan-to-tasks hook on exit from plan mode |
| `.claude/scripts/protect-secrets.py` | Blocks writes to private keys and credential files |
| `.claude/scripts/post-compact.py` | Re-injects task context after context compaction |
| `.claude/agents/task-executor.md` | Ephemeral agent for executing one task at a time |

Quick copy for a tech project (run from your project root):

```bash
SKILL=~/.claude/skills/create-project/assets/templates/tech
mkdir -p .claude/scripts .claude/agents
cp "$SKILL/.claude/settings.json" .claude/settings.json
cp "$SKILL/.claude/scripts/"*.py .claude/scripts/
cp "$SKILL/.claude/agents/task-executor.md" .claude/agents/task-executor.md
```

Replace `tech` with `data` or `research` for other project types.

### Updating CLAUDE.md

The templates now include commit rules, three-tier boundaries (Always / Ask First / Never), anti-rationalization tables, and a plan mode section. You can either:
- Manually add these sections to your existing `CLAUDE.md` (look at the current template for the format)
- Or regenerate `CLAUDE.md` from the template and merge with your project-specific content

### Updating Docker mounts

If your project was created before the `~/.claude/` writable mount fix, update your Docker config:

**devcontainer.json** — replace individual read-only mounts:
```jsonc
// Old (broken — Claude can't refresh tokens)
"source=${localEnv:HOME}/.claude/settings.json,target=/home/developer/.claude/settings.json,type=bind,readonly=true",
"source=${localEnv:HOME}/.claude/.credentials.json,target=/home/developer/.claude/.credentials.json,type=bind,readonly=true"

// New (working)
"source=${localEnv:HOME}/.claude,target=/home/developer/.claude,type=bind"
```

**docker-compose.yml** — same change in the volumes section.

## Adding to an existing codebase

This skill is designed for new projects, but the hooks, agents, and conventions work in any codebase. To adopt them in an existing project without the full scaffold:

1. **Copy `.claude/`** — settings, scripts, and agents (same as the upgrade steps above)
2. **Create a `CLAUDE.md`** at the project root — describe your project structure, commands, conventions, and paste in the boundaries / commit rules / plan mode sections from the template
3. **Optionally adopt the task structure** — create `docs/tasks/active/`, `backlog/`, `completed/`, and `docs/tasks/test-specs/` if you want the plan restructuring hook to work (it detects `docs/tasks/` to activate)

You don't need to adopt the full directory structure. The hooks are the most portable piece — they work in any project with a `.claude/` directory. The plan restructuring hook simply won't fire if `docs/tasks/` doesn't exist.

## Updating the base Docker images

Edit the relevant Dockerfile in `assets/base/` then sync the skill. The next time `create-project` runs the Docker setup step it detects the hash change and rebuilds. Existing project volumes are unaffected — the new image is used on the next `docker compose run`.

Example — pin a specific Claude Code version:
```dockerfile
# assets/base/tech.Dockerfile
RUN npm install -g @anthropic-ai/claude-code@1.x.x
```

## Acknowledgments

The plan mode optimization (context-saving skeleton + ephemeral task executor) is adapted from [plan-plus](https://github.com/RandyHaylor/plan-plus) by Randy Haylor. The original splits plans into step files and uses lightweight skeletons to reduce context token usage. This skill adapts that approach to work within its opinionated task structure, TDD workflow, and commit conventions.

The post-compact context recovery hook and protect-secrets hook are adapted from [claudeframework](https://github.com/dixus/claudeframework) by Holger Kreissl. The task-executor's self-review step before committing is also inspired by their pre-flight review pattern.

The three-tier boundary system (Always / Ask First / Never) and anti-rationalization tables in the CLAUDE.md template are adapted from [agent-skills](https://github.com/addyosmani/agent-skills) by Addy Osmani.
