# Technical Project Setup

Follow these steps for software/code projects. Return to the main skill (Step 3) when done.

## Structure

```
project-root/
├── README.md                         # Project landing page (for GitHub and users)
├── CLAUDE.md                         # Project context for Claude Code sessions
├── src/                              # Code outputs — written by Claude, committed to repo
├── artifacts/                        # Non-code outputs (diagrams, schemas, exports)
│   ├── diagrams/
│   ├── schemas/
│   └── exports/
└── docs/                             # Documentation — inputs that guide implementation
    ├── architecture/
    │   ├── overview.md
    │   ├── tech-stack.md
    │   └── decisions/                # ADRs
    ├── plans/
    │   ├── roadmap.md
    │   └── sprints/
    └── tasks/
        ├── active/
        ├── backlog/
        ├── completed/
        └── test-specs/               # Written BEFORE implementation
            └── coverage-tracker.md
```

Every task file (`NNN-name.md`) has a paired test spec (`NNN-name-test-spec.md`). The test spec is always created first — no exceptions.

---

## Step T1 — Create directory structure

```bash
mkdir -p src
mkdir -p artifacts/diagrams artifacts/schemas artifacts/exports
mkdir -p docs/architecture/decisions
mkdir -p docs/plans/sprints
mkdir -p docs/tasks/active docs/tasks/backlog docs/tasks/completed
mkdir -p docs/tasks/test-specs
```

Add `.gitkeep` so empty directories are tracked:

```bash
touch src/.gitkeep
touch artifacts/diagrams/.gitkeep artifacts/schemas/.gitkeep artifacts/exports/.gitkeep
touch docs/plans/sprints/.gitkeep
touch docs/tasks/backlog/.gitkeep docs/tasks/completed/.gitkeep
```

---

## Step T2 — Populate template files

Read each template from `$CLAUDE_SKILL_DIR/assets/templates/tech/`, substitute placeholders, and write the output.

| Placeholder | Value |
|-------------|-------|
| `{{PROJECT_NAME}}` | Project name |
| `{{PROJECT_DESCRIPTION}}` | Description |
| `{{TECH_STACK}}` | Tech stack |
| `{{DATE}}` | Today's date (YYYY-MM-DD) |

| Template | Output path |
|----------|-------------|
| `README.md` | `README.md` (project root — GitHub landing page) |
| `architecture-overview.md` | `docs/architecture/overview.md` |
| `tech-stack.md` | `docs/architecture/tech-stack.md` |
| `roadmap.md` | `docs/plans/roadmap.md` |
| `coverage-tracker.md` | `docs/tasks/test-specs/coverage-tracker.md` |
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/scripts/restructure-plan.py` | `.claude/scripts/restructure-plan.py` |
| `.claude/scripts/protect-secrets.py` | `.claude/scripts/protect-secrets.py` |
| `.claude/scripts/post-compact.py` | `.claude/scripts/post-compact.py` |
| `.claude/agents/task-executor.md` | `.claude/agents/task-executor.md` |

The following templates have no placeholders — copy them as-is:
- `.claude/settings.json` — pre-configures Claude Code permissions (bash auto-approved, destructive ops prompted) and three hooks: plan restructuring on ExitPlanMode, secret file protection on Write/Edit, and context recovery after compaction.
- `.claude/scripts/restructure-plan.py` — PostToolUse hook. Splits plan steps into `docs/tasks/backlog/` task files, creates test spec stubs, updates the coverage tracker, and replaces the plan with a lightweight skeleton.
- `.claude/scripts/protect-secrets.py` — PreToolUse hook. Hard-blocks writes to private keys, credential files, and auth configs (`.pem`, `.key`, `service-account*.json`, `.npmrc`, etc.).
- `.claude/scripts/post-compact.py` — PostCompact hook. Re-injects the active task, test spec, and plan status into the conversation after context compaction so Claude doesn't lose track of what it was doing.
- `.claude/agents/task-executor.md` — ephemeral agent for executing one task at a time. Follows TDD with self-review, commits after completion, and reports back without bloating the main conversation. Ships with `model: inherit` and a `# model-tier: fast` comment — Step 3d will detect available models and update the field to the best fast-tier model before completing setup.

Fill in the tech stack table using what the user provided. If a layer (e.g. framework, database) wasn't mentioned, use `—`.

**For `README.md` at the project root:** substitute `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}`, and `{{TECH_STACK}}`, then tailor the "Run locally" commands to the actual stack (e.g. `npm test`, `pytest`, `go test ./...`). Mark anything unknown as `# TODO: fill in`. This README is the first thing users see on GitHub — make the project purpose and getting-started instructions clear.

---

## Step T3 — Create CLAUDE.md

Read `$CLAUDE_SKILL_DIR/assets/templates/tech/CLAUDE.md`, substitute placeholders, and write to `CLAUDE.md` at the project root.

For the **Commands** section: fill in real commands based on the tech stack (e.g. `npm test` for Node, `pytest` for Python, `go test ./...` for Go). Mark anything unknown as `# TODO: fill in`.

For the **Do not** section: add 1–2 project-type-specific guardrails beyond the defaults — e.g. for an API project "do not add authentication logic until Task 003", for a CLI "do not write to files outside the designated output directory".

---

## Step T4 — Offer to create the first task

Ask: *"Would you like me to create the first task? Typical starting point is project setup — package manager, linting, CI, or any bootstrapping work."*

If yes:
1. Create `docs/tasks/test-specs/001-project-setup-test-spec.md` first (from `test-spec-template.md`)
2. Then create `docs/tasks/active/001-project-setup.md` (from `task-template.md`)

Populate both with real content based on the project context — not generic placeholder text. The test spec should have actual acceptance criteria for the setup task.

Add a row to `docs/tasks/test-specs/coverage-tracker.md`:
```
| 001 | Project setup | 001-project-setup-test-spec.md | ✅ | ⏳ In progress |
```

Then ask: *"Would you like me to scaffold a minimal starter in `src/` based on your stack? This gives you something runnable from day one — e.g. a health endpoint for an API, an entry point for a CLI, or a basic pipeline skeleton."*

If yes, generate the minimal files needed to make the first test case in the test spec pass (or get close). Keep it thin — the goal is a working skeleton, not a full implementation. For example:
- **FastAPI**: `src/__init__.py`, `src/main.py` (app instance + health route), `src/config.py` (pydantic-settings stub)
- **CLI (Python)**: `src/__init__.py`, `src/main.py` (argument parser + main function)
- **Go**: `main.go` (package main + minimal HTTP handler or CLI entrypoint)
- **Node/Express**: `src/index.js` (express app + health route), `src/config.js`

If the stack doesn't map to these patterns, use your judgment or ask what a "hello world" looks like for this project.

After creating task files and any scaffold, commit:
```bash
git add docs/tasks/ src/
git diff --cached --quiet || git commit -m "chore: add first task, test spec, and starter scaffold"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

---

## Step T5 — Initialize git and remote

Check:
```bash
test -d .git && echo "exists" || echo "missing"
```

If missing, ask whether to initialize. If yes:
```bash
git init
git branch -m main
git add .
git commit -m "chore: initialize project structure"
```

Then check if `gh` (GitHub CLI) is installed:
```bash
command -v gh >/dev/null 2>&1 && echo "available" || echo "not found"
```

If available, ask: *"Would you like to create a GitHub repository for this project?"*

If yes:

1. Ask: public or private? (default: private)

2. Create the repo and configure the remote:
```bash
gh repo create <project-name> --private --source=. --remote=origin --push
```

3. **Tell the user to create a fine-grained access token themselves** — programmatic PAT creation via `gh api` requires a specific auth scope that usually isn't granted, and it silently fails more often than it works.

   Give them these exact instructions:

   > To let the Docker container push commits, you'll need a fine-grained personal access token:
   >
   > 1. Open https://github.com/settings/personal-access-tokens/new
   > 2. **Token name:** `create-project-<project-name>`
   > 3. **Expiration:** 1 year (or whatever you prefer)
   > 4. **Repository access:** *Only select repositories* → pick this repo
   > 5. **Permissions** → *Repository permissions*:
   >    - **Contents:** Read and write
   >    - **Metadata:** Read-only (set automatically)
   > 6. Click **Generate token** and copy it
   > 7. In step T6 you'll paste it directly into `.env` yourself — **do not share it in this chat**

   **Do not ask the user to paste the token in the conversation.** They will edit `.env` themselves. The token never gets written into the repo — it sits in `.env` (which is gitignored) and the container entrypoint loads it into git's credential helper at runtime.

---

## Step T6 — Docker setup

First check whether Docker is installed:
```bash
command -v docker >/dev/null 2>&1 && echo "available" || echo "not found"
```

If not found: tell the user Docker was not detected and skip this step entirely. Do not create any Docker files.

If available, tell the user: *"Setting up the Docker environment — this is how you'll run autonomous Claude Code sessions on this project. The base image (Claude Code, git, Python) is built once and shared across all your technical projects; each project gets its own isolated workspace volume and a project-specific image with the right runtime installed."* Then proceed with the steps below. Do not ask — Docker is the standard setup for technical projects.

**0. Detect docker compose**

```bash
if docker compose version >/dev/null 2>&1; then
    echo "COMPOSE=docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
    echo "COMPOSE=docker-compose"
else
    echo "COMPOSE=none"
fi
```

Store the result as `COMPOSE` — used in step 8 when writing CLAUDE.md commands.

**1. Check and build the shared base image**

The base image (`claude-project-dev:latest`) is shared across all technical projects. Build it only if it is missing or its Dockerfile has changed (detected via a hash stored in the image label).

```bash
TECH_DOCKERFILE="$CLAUDE_SKILL_DIR/assets/base/tech.Dockerfile"
CURRENT_HASH=$(sha256sum "$TECH_DOCKERFILE" | cut -d' ' -f1)
STORED_HASH=$(docker image inspect claude-project-dev:latest \
    --format '{{index .Config.Labels "dev.claude-project.dockerfile-hash"}}' 2>/dev/null || echo "missing")

if [ "$CURRENT_HASH" != "$STORED_HASH" ]; then
    echo "Building shared base image (claude-project-dev:latest)..."
    docker build \
        --label "dev.claude-project.dockerfile-hash=$CURRENT_HASH" \
        -t claude-project-dev:latest \
        -f "$TECH_DOCKERFILE" \
        "$CLAUDE_SKILL_DIR/assets/base/"
    echo "Base image ready."
else
    echo "Base image is up-to-date — skipping build."
fi
```

**2. Write project Dockerfile**

The base image has Claude Code, git, Python, and Node. Each project needs a Dockerfile that extends it with the project's own runtime and aligns the container uid/gid to the host — this is required so that bind-mounted host files (`.env`, `.credentials.json`) are readable and writable inside the container.

Read host uid and gid:
```bash
HOST_UID=$(id -u)
HOST_GID=$(id -g)
echo "HOST_UID=$HOST_UID HOST_GID=$HOST_GID"
```

Write `docker/Dockerfile`. Start with this base for every project:
```dockerfile
# <project-name> dev image
# Extends the shared Claude Code base with the <tech-stack> toolchain.
FROM claude-project-dev:latest

# Align container uid/gid to host so bind-mounted host files are accessible.
RUN usermod -u <HOST_UID> developer \
 && groupmod -g <HOST_GID> developer \
 && chown -R developer:developer /app /home/developer
```

Then append the tech-stack runtime installation:

- **Rust**:
  ```dockerfile
  USER developer
  ENV PATH="/home/developer/.cargo/bin:$PATH"
  RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable --no-modify-path
  USER root
  ```
- **Go**:
  ```dockerfile
  RUN GO_VERSION=1.22.0 \
   && curl -sL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -C /usr/local -xz
  ENV PATH="/usr/local/go/bin:$PATH"
  ```
- **Python / Node**: already in the base image — no additional steps needed.
- **Other**: add a `# TODO: install <runtime> toolchain` comment.

After writing the file, build the project image:
```bash
docker build -t <project-name>-dev:latest -f docker/Dockerfile docker/
```

**3. Create the project workspace volume**

```bash
docker volume create <project-name>-workspace
```

The volume is empty at creation. The entrypoint seeds it from the host project and installs Python dependencies on first run.

**4. Ensure Claude config directory exists on host**

The container bind-mounts the entire `~/.claude/` directory writable so Claude Code can read credentials, refresh tokens, and write session state. Create it and required subdirectories if needed:
```bash
mkdir -p ~/.claude/plans
```

**5. Write per-project files**

Read each file from `$CLAUDE_SKILL_DIR/assets/templates/tech/docker/`, substitute the placeholders below, and write to `docker/<filename>`. Two files are exceptions — write them to the **project root**, not inside `docker/`:
- `.env.example` → project root
- `requirements.txt` → project root (only if `requirements.txt` does not already exist)

| Placeholder | Value |
|-------------|-------|
| `{{PROJECT_NAME}}` | Project name, lowercased, spaces/underscores → hyphens |
| `{{DATE}}` | Today's date (YYYY-MM-DD) |

Do not substitute `${HOME}` — that is a Docker Compose variable resolved at runtime, not a skill placeholder.

**6. Update `.gitignore`**

Append to `.gitignore` (create it if it does not exist):
```
# Secrets
.env

# Python virtual environment (lives in the Docker volume — not part of the repo)
.venv/
```

**7. Write `.env` with git credentials**

Read host git identity to pre-fill:
```bash
HOST_GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
HOST_GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
```

Create `.env` at the project root with placeholders:
```
ANTHROPIC_API_KEY=
GIT_TOKEN=
GIT_REMOTE_URL=https://github.com/<owner>/<project-name>.git
GIT_USER_NAME=<HOST_GIT_NAME value, or blank if empty>
GIT_USER_EMAIL=<HOST_GIT_EMAIL value, or blank if empty>
```

If no GitHub repo was created in T5, also leave `GIT_REMOTE_URL` blank.

Tell the user to open `.env` in their editor and fill in:
- `ANTHROPIC_API_KEY` — from https://console.anthropic.com/settings/keys
- `GIT_TOKEN` — the fine-grained PAT from T5 (https://github.com/settings/personal-access-tokens/new — Contents: read/write, this repo only)
- `GIT_REMOTE_URL` — if T5 wasn't run, the URL of the project's git remote
- `GIT_USER_NAME` / `GIT_USER_EMAIL` — only if they weren't pre-filled from host git config

**Never ask the user to paste the token or API key into the chat.** They should open `.env` directly and type them in. The container entrypoint configures git from these values on every start — the token is never written to disk inside the container.

**8. Append Docker commands to `CLAUDE.md`**

Add the following block to the `## Commands` section of `CLAUDE.md`. Substitute `<project-name>` with the actual lowercased, hyphenated project name.

If `COMPOSE` is `docker compose` or `docker-compose`:
```bash
# Docker (run from host, outside the container)
<COMPOSE> -f docker/docker-compose.yml run --rm dev           # open shell
<COMPOSE> -f docker/docker-compose.yml run --rm dev <cmd>     # run a command

# Export workspace → host
docker run --rm -v <project-name>-workspace:/src:ro -v "$(pwd)":/dst debian:bookworm-slim cp -r /src/. /dst/

# Backup / restore workspace volume
docker run --rm -v <project-name>-workspace:/src:ro -v "$(pwd)":/dst debian:bookworm-slim tar czf /dst/workspace-backup.tar.gz -C /src .
docker run --rm -v <project-name>-workspace:/dst -v "$(pwd)":/src debian:bookworm-slim tar xzf /src/workspace-backup.tar.gz -C /dst
```

If `COMPOSE` is `none` (docker compose plugin not installed), use plain `docker run`:
```bash
# Docker (run from host, outside the container)
docker run --rm -it \
  -v <project-name>-workspace:/app \
  -v "$(pwd)":/host:ro \
  -v "$HOME/.claude":/home/developer/.claude \
  -v "$(pwd)/.env":/app/.env \
  --env-file .env \
  <project-name>-dev:latest

# Export workspace → host
docker run --rm -v <project-name>-workspace:/src:ro -v "$(pwd)":/dst debian:bookworm-slim cp -r /src/. /dst/

# Backup / restore workspace volume
docker run --rm -v <project-name>-workspace:/src:ro -v "$(pwd)":/dst debian:bookworm-slim tar czf /dst/workspace-backup.tar.gz -C /src .
docker run --rm -v <project-name>-workspace:/dst -v "$(pwd)":/src debian:bookworm-slim tar xzf /src/workspace-backup.tar.gz -C /dst
```

**9. Seed the workspace volume**

```bash
docker run --rm \
  -v <project-name>-workspace:/app \
  -v "$(pwd)":/host:ro \
  -v "$HOME/.claude":/home/developer/.claude \
  --env-file .env \
  <project-name>-dev:latest \
  echo "Workspace initialized."
```

**10. Commit Docker files**

```bash
git add docker/ .env.example .gitignore CLAUDE.md
test -f requirements.txt && git add requirements.txt || true
git commit -m "chore: add Docker development environment"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

---

## Step T7 — VS Code devcontainer

Only run this step if Docker was configured in Step T6.

Create `.devcontainer/devcontainer.json` so VS Code can open the project directly inside the Docker workspace — Claude Code, the terminal, and the editor all run in the isolated container.

1. Create the `.devcontainer/` directory
2. Read `$CLAUDE_SKILL_DIR/assets/templates/tech/devcontainer.json`, substitute `{{PROJECT_NAME}}` with the project name (lowercased, hyphenated), and write to `.devcontainer/devcontainer.json`

Do not ask — always create the devcontainer when Docker is set up.

To use it: install the **Dev Containers** extension in VS Code, then:
- Open the project folder → VS Code detects `.devcontainer/` and prompts to reopen in container
- Or: Command Palette → *Dev Containers: Reopen in Container*

The container starts (seeding the workspace volume on first open if needed) and VS Code connects to `/app` inside. Claude Code, the project runtime, and all files are available immediately.

```bash
git add .devcontainer/
git commit -m "chore: add VS Code devcontainer"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

---

## Task readiness rule

A task must not start until:
1. Its paired test spec exists in `docs/tasks/test-specs/`
2. The test spec has at least one test case with defined inputs and expected outputs

When asked to work on a task, check for the test spec first. If it doesn't exist, create it before writing code.

---

## Resuming in a new session

Paste into the new session:
- The active task file (`docs/tasks/active/NNN-*.md`)
- Its test spec (`docs/tasks/test-specs/NNN-*-test-spec.md`)
- Relevant sections of `docs/architecture/overview.md`
