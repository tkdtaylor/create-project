# create-project

A Claude Code skill that scaffolds new projects with opinionated structure, isolated Docker workspaces, and Claude-specific tooling setup.

> **Note:** This skill is a work in progress. If you run into any issues, please [open an issue](https://github.com/tkdtaylor/create-project-skill/issues) on the repo.

## What it does

Triggered by phrases like "start a new project", "scaffold a codebase", or "set up a research project". The skill:

1. Interviews you until the goal, scope, and success criteria are unambiguous — confirms a written summary before touching any files
2. Creates a type-matched directory structure with template files
3. Generates a `CLAUDE.md` so every future session starts with full project context
4. **Technical:** offers to scaffold a minimal runnable starter in `src/` (health endpoint, CLI entrypoint, etc.)
4. **Research:** offers to run initial web searches and seed `sources/web/` so the project starts with real material
5. Optionally initialises git and creates a GitHub repo (with scoped access token for the container)
6. **Technical:** sets up Docker automatically — shared base image + project-specific image (with the right runtime installed) + per-project named volume
7. **Technical:** adds a VS Code devcontainer config automatically so you can open the project inside the container
8. Recommends MCPs, hooks, and installed skills suited to the project; offers to create `.claude/agents/` files for the suggested agents

## First-time setup

Every project created by this skill includes a `.claude/settings.json` that auto-approves most bash commands inside the container while retaining prompts for destructive operations (`sudo`, `rm -rf`, `git push --force`, etc.). No manual configuration needed per project.

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

### For Docker workspaces (steps T6/R6)

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

### For automatic GitHub repo creation and scoped tokens (steps T5/R5)

**GitHub CLI (`gh`)**
Optional. If installed, the skill can create the GitHub repository and generate a fine-grained personal access token scoped to that repo only — no manual PAT setup needed. Without it, the skill gives manual instructions instead.

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

To enable automatic token generation (requires one-time scope grant):
```bash
gh auth refresh -h github.com -s write:personal_access_tokens
```

---

### For VS Code IDE integration (steps T7/R7)

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
| **technical** | Building software — APIs, CLIs, scripts, data pipelines | `src/`, `artifacts/`, `docs/` with TDD scaffolding (test specs before tasks) |
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
| `~/.claude/settings.json` | Host Claude Code settings (bind mount) | No — read-only |
| `~/.claude/.credentials.json` | Host Claude Code auth token (bind mount) | No — read-only |
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
      docker/
        Dockerfile               # extends shared base with project runtime + uid fix
        docker-compose.yml       # builds project image, mounts volume + credentials
        .env.example             # documents all required env vars including git creds
        requirements.txt
      [architecture, task, roadmap templates...]
    research/                    # Per-project templates — research projects
      CLAUDE.md
      devcontainer.json
      docker/
        docker-compose.yml
        .env.example
        requirements.txt         # pre-populated with requests, bs4, pdfminer, markdownify
      [outline, task, research-log templates...]
references/
  tech-project.md                # Step-by-step setup for technical projects (T1–T7)
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

## Updating the base Docker images

Edit the relevant Dockerfile in `assets/base/` then sync the skill. The next time `create-project` runs the Docker setup step it detects the hash change and rebuilds. Existing project volumes are unaffected — the new image is used on the next `docker compose run`.

Example — pin a specific Claude Code version:
```dockerfile
# assets/base/tech.Dockerfile
RUN npm install -g @anthropic-ai/claude-code@1.x.x
```
