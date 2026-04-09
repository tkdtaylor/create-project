# create-project

A Claude Code skill that scaffolds new projects with opinionated structure, isolated Docker workspaces, and Claude-specific tooling setup.

> **Note:** This skill is a work in progress. If you run into any issues, please [open an issue](https://github.com/tkdtaylor/create-project-skill/issues) on the repo.

## What it does

Triggered by phrases like "start a new project", "scaffold a codebase", "set up a research project", "start a data science project", "sync my skills", or "update my skills". The skill:

1. Interviews you until the goal, scope, and success criteria are unambiguous — confirms a written summary before touching any files
2. Creates a type-matched directory structure with template files, including requirement-traceable task and test spec templates (`REQ-NNN` IDs flow from task → test spec → code)
3. Generates a `CLAUDE.md` so every future session starts with full project context
4. **Technical / Data:** offers to scaffold a minimal runnable starter in `src/` (health endpoint, CLI entrypoint, data pipeline skeleton, etc.)
5. **Research:** offers to run initial web searches and seed `sources/web/` so the project starts with real material; ships output templates (decision brief, deep research report, learning plan) in `outputs/templates/`
6. Optionally initialises git and creates a GitHub repo (with scoped access token for the container)
7. **Technical / Data:** sets up an isolated workspace automatically — Docker Sandbox (`sbx`) when available (microVM with network policies and credential proxy), falling back to Docker Engine (shared base image + project-specific image + per-project named volume) on Linux or CI
8. **Technical / Data:** adds a VS Code devcontainer config when using Docker Engine (skipped with `sbx` — the sandbox is the dev environment)
9. **Technical / Data:** configures code quality tooling — auto-detects the language and sets up linting, formatting, pre-commit hooks, coverage thresholds, and a Makefile with standard targets
10. Ships four agents out of the box: task-executor (TDD workflow), architect (design review + ADRs), code-reviewer (10 structured review perspectives), and security-auditor (OWASP Top 10). Recommends additional agents, skills, hooks, and CLI tools suited to the project, with model tiers auto-mapped to the best available model
11. Installs hooks: plan-to-tasks restructuring on exit from plan mode, secret file write protection, and context recovery after compaction
12. Writes a `.claude/skill-manifest.json` that tracks which files came from skill templates, enabling future syncs
13. **Skill sync:** checks globally installed skills for upstream updates (via git pull) and syncs managed project artifacts (hooks, agents, settings) from updated templates — with three-way merge to preserve local customizations

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

### For isolated workspaces (steps T6/D6/R6)

The skill checks for isolation tools in this order: **Docker Sandbox (`sbx`)** first, then **Docker Engine** as fallback. If neither is found, the isolation step is skipped.

**Docker Sandbox (`sbx`)** *(recommended for macOS / Windows)*
Runs Claude Code in a microVM with its own kernel — stronger isolation than containers, with built-in network policies and credential management via OS keychain. No Dockerfiles, no volumes, no compose files.

```bash
# Mac (Apple Silicon)
brew install docker/tap/sbx
sbx login

# Windows 11
winget install -h Docker.sbx
sbx login
```
→ https://docs.docker.com/ai/sandboxes/

**Docker Engine** *(fallback — required for Linux, CI, or when sbx is not available)*
Docker Compose is optional — the skill detects whether `docker compose` (v2 plugin) or `docker-compose` (v1 standalone) is available and writes commands accordingly. If neither is installed, it falls back to plain `docker run` commands.

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

### For VS Code IDE integration (steps T7/D7/R7 — Docker Engine only)

**VS Code Dev Containers extension**
Optional. Only applies when using the Docker Engine path — skipped when Docker Sandbox (`sbx`) is configured. Lets you open the project directly inside the Docker container — your editor, terminal, and Claude Code all run in the isolated workspace.

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
| **research** | Synthesising information — literature reviews, competitive analysis, report writing | `sources/`, `notes/`, `outputs/` (with decision brief, deep research, and learning plan templates), `docs/` |
| **other** | Planning, tracking, organising — wedding planning, job search, project management | Research base structure with domain-specific top-level folders (e.g. `vendors/`, `budget/`, `timeline/`) chosen by the user |

## Isolation architecture

The skill supports two isolation backends. It detects what's available and picks the stronger option automatically.

### Docker Sandbox (`sbx`) — preferred

Available on macOS (Apple Silicon) and Windows 11. Each sandbox is a **microVM** with its own Linux kernel — not just namespace isolation. The agent runs with `--dangerously-skip-permissions` by default because the blast radius is contained within a disposable VM.

| Aspect | How it works |
|--------|-------------|
| **Isolation** | Dedicated kernel, filesystem, and Docker daemon per sandbox |
| **Network** | Configurable allow/deny lists per domain (balanced policy recommended) |
| **Credentials** | Stored in OS keychain, injected via proxy — never inside the sandbox |
| **Workspace** | Host directory mounted into the VM; changes persist on host |
| **Branches** | Built-in `--branch` mode creates Git worktrees under `.sbx/` |
| **Setup** | Zero config — `sbx run claude .` and go |

### Docker Engine — fallback

Used on Linux, in CI, or when `sbx` is not installed. Provides container-level isolation with a custom Docker setup.

#### Security model

| | Container sees | Can write |
|---|---|---|
| `/app` or `/workspace` | Named volume — project workspace | Yes |
| `/host` | Host project root (bind mount) | No — read-only |
| `/app/.env` | Host `.env` file (bind mount) | Yes |
| `~/.claude/` | Host Claude Code config directory (bind mount) | Yes — writable so Claude can refresh tokens and write session state |
| Everything else on host | Nothing | — |

The container runs as a non-root `developer` user. The entrypoint performs privileged init steps as root then drops to `developer` via `gosu` before starting the shell. This means Claude Code cannot install system packages, modify OS config, or escalate privileges.

#### Shared base images

Built once per machine, reused across all projects of that type:

| Image | Contents |
|-------|----------|
| `claude-project-dev:latest` | debian:bookworm-slim + git + Python + Node + Claude Code |
| `claude-project-research:latest` | same + pandoc + poppler-utils + Python research libs |

The skill stores a `sha256` hash of each Dockerfile as a Docker label and rebuilds automatically when the content changes. To update (e.g. pin a Claude Code version), edit `assets/base/tech.Dockerfile` — the next project setup detects the hash change and rebuilds.

#### Per-project (created in seconds)

- Named Docker volume (`<project-name>-workspace`) — the container's isolated, persistent workspace
- `docker/Dockerfile` extending the shared base with the project's runtime (Rust, Go, etc.) and a uid/gid fix so bind-mounted host files are accessible
- `docker/docker-compose.yml` building from the project Dockerfile, with all required volume and credential mounts
- `.env` with API keys and git credentials (gitignored) — `GIT_USER_NAME` and `GIT_USER_EMAIL` pre-filled from host git config if set
- `.devcontainer/devcontainer.json` for VS Code — created automatically

#### Entrypoint behaviour (runs on every `docker compose run`)

1. Volume empty → copy project files from `/host` into volume + `chown` to `developer`
2. `requirements.txt` present + `.venv` missing or hash changed → create/update venv + `pip install`
3. `.venv` broken after base image update → auto-recreate
4. Export `VIRTUAL_ENV` and `PATH` for venv activation
5. Configure git identity and credential helper from env vars (`GIT_USER_NAME`, `GIT_USER_EMAIL`, `GIT_TOKEN`) — token is never written to disk
6. Drop privileges → `exec gosu developer "$@"`

#### VS Code workflow

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
          architect.md           # architecture review + ADR drafting (tier: deep)
          code-reviewer.md       # structured multi-perspective code review (tier: balanced)
          security-auditor.md    # OWASP Top 10 application security audit (tier: deep)
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
      decision-brief-template.md # structured comparison + recommendation output template
      deep-research-template.md  # in-depth research report output template
      learning-plan-template.md  # three-phase learning syllabus output template
      .claude/                   # same hooks, research-adapted task-executor agent
      docker/
        docker-compose.yml
        .env.example
        requirements.txt         # pre-populated with requests, bs4, pdfminer, markdownify
      [outline, task, research-log templates...]
references/
  tech-project.md                # Step-by-step setup for technical projects (T1–T8)
  data-project.md                # Step-by-step setup for data / ML projects (D1–D8)
  research-project.md            # Step-by-step setup for research / other projects (R1–R7)
  adopt-existing.md              # Adopting an existing codebase (A1–A9)
  sync-skills.md                 # Syncing skills and project artifacts (S1–S5)
  tooling.md                     # Skills, hooks, agents, and CLI tools catalog with project-type matching
evals/
  evals.json                     # Test cases and assertions for skill evaluation
SKILL.md                         # Entry point — gathers info, routes to reference files
README.md                        # This file
```

## Installing / updating

The skill is developed here and installed to `~/.claude/skills/create-project/`.

**Option A — Clone (recommended).** Cloning preserves the `.git` directory, which lets the sync flow (`"sync my skills"`) automatically pull upstream updates via `git pull`:

```bash
git clone https://github.com/tkdtaylor/create-project-skill.git ~/.claude/skills/create-project
```

**Option B — Copy.** Works, but the sync flow won't be able to auto-update the global install (it will prompt you to reinstall manually):

```bash
rm -rf ~/.claude/skills/create-project && cp -r /path/to/create-project-skill ~/.claude/skills/create-project
```

The installed directory name must match the `name:` field in `SKILL.md` (`create-project`).

## Syncing skills and upgrading existing projects

Projects created with an older version of this skill won't automatically get new features (hooks, agents, boundaries, etc.). The skill includes a **sync flow** that checks for upstream changes and merges them into your project while preserving local customizations.

### Automatic sync (recommended)

Open Claude Code in your project and say:

- *"sync my skills"*
- *"update my skills"*
- *"make sure my skills are up to date"*

The sync flow does two things:

1. **Updates globally installed skills** — for each skill in `~/.claude/skills/` that is a git repo, fetches and fast-forward pulls upstream changes
2. **Syncs project artifacts** — compares your project's managed files (hooks, agents, settings) against the latest templates using `.claude/skill-manifest.json`, then:
   - **Auto-updates** files you haven't modified locally
   - **Preserves** your local customizations when the template hasn't changed
   - **Shows conflicts** when both sides changed, letting you choose how to merge
   - **Offers new files** added to the skill since your project was set up

Agent files get special handling: when an updated template is applied, the `model:` field from your project is preserved so your model tier configuration isn't lost.

### Manifest tracking

Projects set up with the current version of the skill include `.claude/skill-manifest.json`, which records sha256 hashes of each managed file at install time. This enables precise three-way change detection during sync.

Projects set up before manifest tracking was added still work — the sync generates a baseline manifest on first run by hashing current files, then tracks changes from that point forward.

### Manual upgrade (alternative)

If you prefer to update files manually, the managed files live in `assets/templates/<type>/` (where `<type>` is `tech`, `data`, or `research`):

| File | What it adds |
|------|-------------|
| `.claude/settings.json` | Permissions + hooks (plan restructuring, secret protection, post-compact recovery) |
| `.claude/scripts/restructure-plan.py` | Plan-to-tasks hook on exit from plan mode |
| `.claude/scripts/protect-secrets.py` | Blocks writes to private keys and credential files |
| `.claude/scripts/post-compact.py` | Re-injects task context after context compaction |
| `.claude/agents/task-executor.md` | Ephemeral agent for executing one task at a time |
| `.claude/agents/architect.md` | Architecture review + ADR drafting (tier: deep) |
| `.claude/agents/code-reviewer.md` | Structured multi-perspective code review (tier: balanced) |
| `.claude/agents/security-auditor.md` | OWASP Top 10 application security audit (tier: deep) |

Quick copy for a tech project (run from your project root):

```bash
SKILL=~/.claude/skills/create-project/assets/templates/tech
mkdir -p .claude/scripts .claude/agents
cp "$SKILL/.claude/settings.json" .claude/settings.json
cp "$SKILL/.claude/scripts/"*.py .claude/scripts/
cp "$SKILL/.claude/agents/"*.md .claude/agents/
```

Replace `tech` with `data` or `research` for other project types.

### Updating CLAUDE.md

`CLAUDE.md` is not a managed file (it has project-specific content), so the sync flow does not touch it. If the templates have added new sections (commit rules, three-tier boundaries, anti-rationalization tables, plan mode), you can either:
- Manually add the missing sections to your existing `CLAUDE.md` (look at the current template in `assets/templates/<type>/CLAUDE.md` for the format)
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

The skill can adopt existing codebases — not just scaffold new ones. Open Claude Code in an existing project directory and say *"set up this project for Claude"*, *"add project structure"*, or *"onboard this repo"*.

The skill will:

1. **Analyze the codebase** — detect the stack, read the directory structure, discover build/test/run commands, review git history and conventions
2. **Confirm understanding** — present a summary and ask you to verify before writing anything
3. **Generate `CLAUDE.md`** — a project context file based on the *actual* code, not generic templates. Includes real commands, real structure, real conventions discovered from the codebase
4. **Generate `docs/architecture/overview.md`** — component map, data flow, key dependencies, entry points — all derived from reading the code
5. **Create task structure** — `docs/tasks/active/`, `backlog/`, `completed/`, and test-spec tracking so plan mode and the task-executor work
6. **Copy hooks and agents** — settings.json, hook scripts, and agent templates (task-executor, architect, code-reviewer, security-auditor for tech/data projects)
7. **Configure model tiers** — detect available models and set the best one for each agent
8. **Recommend tooling** — skills, hooks, and CLI tools suited to the project
9. **Write skill manifest** — records which files came from templates in `.claude/skill-manifest.json`, enabling future syncs

Existing source code is never moved, renamed, or restructured. The skill adds a documentation and tooling layer alongside what's already there.

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

The structured code review perspectives (10 review dimensions with selective application), research output templates (decision brief, deep research report, learning plan), and the approach to auto-configuring code quality tooling (per-language linting, formatting, pre-commit hooks, coverage thresholds) are inspired by [claude-coding-commands](https://github.com/awood45/claude-coding-commands) by Alex Wood.
