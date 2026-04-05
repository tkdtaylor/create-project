# Data / ML Project Setup

Follow these steps for data science, machine learning, and analytics projects. Return to the main skill (Step 3) when done.

## Structure

```
project-root/
├── README.md                         # Project landing page (for GitHub and users)
├── CLAUDE.md                         # Project context for Claude Code sessions
├── data/
│   ├── raw/                          # Original, immutable data
│   ├── processed/                    # Cleaned and transformed data
│   └── external/                     # Third-party data sources
├── notebooks/                        # Jupyter notebooks for exploration
├── src/                              # Reusable Python modules
│   ├── data/                         # Loading and preprocessing
│   ├── features/                     # Feature engineering
│   ├── models/                       # Model definitions and training
│   └── evaluation/                   # Metrics and evaluation utilities
├── experiments/                      # Experiment tracking
│   ├── configs/                      # Experiment configuration files
│   └── results/                      # Metrics, plots, artifacts per run
├── models/                           # Saved model artifacts (gitignored)
├── tests/                            # Unit tests for src/ modules
├── artifacts/                        # Reports, exported plots, presentations
└── docs/
    ├── architecture/
    │   ├── overview.md
    │   ├── tech-stack.md
    │   └── decisions/                # ADRs
    ├── plans/
    │   └── roadmap.md
    └── tasks/
        ├── active/
        ├── backlog/
        ├── completed/
        ├── experiment-tracker.md     # All experiment runs logged here
        └── test-specs/               # TDD specs for src/ code
            └── coverage-tracker.md
```

Code in `src/` follows TDD (test spec before implementation). Experiments follow their own workflow: hypothesis → config → run → results → log.

---

## Step D1 — Create directory structure

```bash
mkdir -p data/raw data/processed data/external
mkdir -p notebooks
mkdir -p src/data src/features src/models src/evaluation
mkdir -p experiments/configs experiments/results
mkdir -p models
mkdir -p tests
mkdir -p artifacts
mkdir -p docs/architecture/decisions
mkdir -p docs/plans
mkdir -p docs/tasks/active docs/tasks/backlog docs/tasks/completed
mkdir -p docs/tasks/test-specs
```

Add `.gitkeep` so empty directories are tracked:

```bash
touch data/raw/.gitkeep data/processed/.gitkeep data/external/.gitkeep
touch notebooks/.gitkeep
touch src/data/.gitkeep src/features/.gitkeep src/models/.gitkeep src/evaluation/.gitkeep
touch experiments/configs/.gitkeep experiments/results/.gitkeep
touch models/.gitkeep
touch tests/.gitkeep
touch artifacts/.gitkeep
touch docs/plans/.gitkeep
touch docs/tasks/backlog/.gitkeep docs/tasks/completed/.gitkeep
```

Create `src/__init__.py` and subpackage inits:

```bash
touch src/__init__.py src/data/__init__.py src/features/__init__.py src/models/__init__.py src/evaluation/__init__.py
```

---

## Step D2 — Populate template files

Read each template from `$CLAUDE_SKILL_DIR/assets/templates/data/`, substitute placeholders, and write the output.

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
| `experiment-tracker.md` | `docs/tasks/experiment-tracker.md` |
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/scripts/restructure-plan.py` | `.claude/scripts/restructure-plan.py` |
| `.claude/scripts/protect-secrets.py` | `.claude/scripts/protect-secrets.py` |
| `.claude/scripts/post-compact.py` | `.claude/scripts/post-compact.py` |
| `.claude/agents/task-executor.md` | `.claude/agents/task-executor.md` |

The following templates have no placeholders — copy them as-is:
- `.claude/settings.json` — pre-configures Claude Code permissions and hooks (plan restructuring, secret protection, post-compact context recovery).
- `.claude/scripts/` — hook scripts for plan restructuring, secret file protection, and context recovery after compaction.
- `.claude/agents/task-executor.md` — ephemeral agent for executing one task at a time. Follows TDD for code, experiment workflow for ML, commits after completion.

Fill in the tech stack table using what the user provided. If a layer wasn't mentioned, use `—`.

**For `README.md` at the project root:** substitute `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}`, and `{{TECH_STACK}}`. Tailor the test command to the actual stack (e.g. `pytest`, `nose2`). Fill in the "Data" section with whatever the user described — data sources, formats, access requirements. This README is the first thing users see on GitHub.

---

## Step D3 — Create CLAUDE.md

Read `$CLAUDE_SKILL_DIR/assets/templates/data/CLAUDE.md`, substitute placeholders, and write to `CLAUDE.md` at the project root.

For the **Commands** section: fill in real commands based on the tech stack (e.g. `pytest` for testing, `jupyter lab` for notebooks, `python -m src.models.train` for training). Mark anything unknown as `# TODO: fill in`.

For the **Tech stack** section: fill in the ML stack table. If the user mentioned specific libraries (PyTorch, scikit-learn, etc.), include them. Otherwise use reasonable defaults for the project type.

---

## Step D4 — Offer to create the first task

Ask: *"Would you like me to create the first task? Typical starting points for data/ML projects: environment setup (dependencies, data pipeline skeleton), data exploration (initial EDA notebook), or data ingestion (loading raw data into the pipeline)."*

If yes:
1. Create `docs/tasks/test-specs/001-project-setup-test-spec.md` first (from `test-spec-template.md`)
2. Then create `docs/tasks/active/001-project-setup.md` (from `task-template.md`)

Populate both with real content based on the project — include actual acceptance criteria for whatever setup work is needed (e.g. "pytest runs with 0 errors", "data can be loaded from data/raw/ into a pandas DataFrame").

Add a row to `docs/tasks/test-specs/coverage-tracker.md`:
```
| 001 | Project setup | 001-project-setup-test-spec.md | ✅ | ⏳ In progress |
```

Then ask: *"Would you like me to scaffold a minimal data pipeline in `src/`? This gives you a working skeleton — a data loader, a basic feature transform, and a simple model training entry point."*

If yes, generate the minimal files. For example:
- `src/data/loader.py` — function to load raw data into a DataFrame
- `src/features/transform.py` — basic feature preprocessing
- `src/models/train.py` — minimal training loop or fit call
- `tests/test_loader.py` — smoke test for data loading

After creating task files and any scaffold, commit:
```bash
git add docs/tasks/ src/ tests/
git diff --cached --quiet || git commit -m "chore: add first task, test spec, and starter scaffold"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

---

## Step D5 — Initialize git and remote

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
   > 7. In step D6 you'll paste it directly into `.env` yourself — **do not share it in this chat**

   **Do not ask the user to paste the token in the conversation.** They will edit `.env` themselves. The token never gets written into the repo — it sits in `.env` (which is gitignored) and the container entrypoint loads it into git's credential helper at runtime.

---

## Step D6 — Docker setup

First check whether Docker is installed:
```bash
command -v docker >/dev/null 2>&1 && echo "available" || echo "not found"
```

If not found: tell the user Docker was not detected and skip this step entirely.

If available, tell the user: *"Setting up the Docker environment — this is how you'll run autonomous Claude Code sessions on this project. The base image (Claude Code, git, Python) is built once and shared across all your projects; each project gets its own isolated workspace volume and a project-specific image."* Then proceed. Do not ask — Docker is the standard setup.

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

Store the result as `COMPOSE`.

**1. Check and build the shared base image**

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

Read host uid and gid:
```bash
HOST_UID=$(id -u)
HOST_GID=$(id -g)
```

Write `docker/Dockerfile`. Data/ML projects use the tech base image (which has Python) and add data science dependencies:

```dockerfile
# <project-name> dev image
# Extends the shared Claude Code base with data science toolchain.
FROM claude-project-dev:latest

# Align container uid/gid to host so bind-mounted host files are accessible.
RUN usermod -u <HOST_UID> developer \
 && groupmod -g <HOST_GID> developer \
 && chown -R developer:developer /app /home/developer
```

No additional runtime installation needed — Python is in the base image, and project-specific ML libraries come from `requirements.txt` (installed by the entrypoint into `.venv`).

After writing the file, build the project image:
```bash
docker build -t <project-name>-dev:latest -f docker/Dockerfile docker/
```

**3. Create the project workspace volume**

```bash
docker volume create <project-name>-workspace
```

**4. Ensure Claude config directory exists on host**

```bash
mkdir -p ~/.claude/plans
```

**5. Write per-project files**

Read each file from `$CLAUDE_SKILL_DIR/assets/templates/data/docker/`, substitute placeholders, and write to `docker/<filename>`. Two files are exceptions — write them to the **project root**:
- `.env.example` → project root
- `requirements.txt` → project root (only if it does not already exist)

| Placeholder | Value |
|-------------|-------|
| `{{PROJECT_NAME}}` | Project name, lowercased, hyphens |
| `{{DATE}}` | Today's date (YYYY-MM-DD) |

Do not substitute `${HOME}` — that is a Docker Compose variable resolved at runtime.

**6. Update `.gitignore`**

Append to `.gitignore` (create if it does not exist):
```
# Secrets
.env

# Python virtual environment
.venv/

# Model artifacts (too large for git)
models/*.pkl
models/*.pt
models/*.h5
models/*.onnx
models/*.joblib

# Data files (track with DVC or manage separately)
data/raw/*
data/processed/*
data/external/*
!data/raw/.gitkeep
!data/processed/.gitkeep
!data/external/.gitkeep

# Jupyter notebook checkpoints
.ipynb_checkpoints/

# Experiment results that are too large
experiments/results/**/model_*
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

If no GitHub repo was created in D5, also leave `GIT_REMOTE_URL` blank.

Tell the user to open `.env` in their editor and fill in:
- `ANTHROPIC_API_KEY` — from https://console.anthropic.com/settings/keys
- `GIT_TOKEN` — the fine-grained PAT from D5 (https://github.com/settings/personal-access-tokens/new — Contents: read/write, this repo only)
- `GIT_REMOTE_URL` — if D5 wasn't run, the URL of the project's git remote
- `GIT_USER_NAME` / `GIT_USER_EMAIL` — only if they weren't pre-filled from host git config

**Never ask the user to paste the token or API key into the chat.** They should open `.env` directly and type them in. The container entrypoint configures git from these values on every start — the token is never written to disk inside the container.

**8. Append Docker commands to `CLAUDE.md`**

Add the Docker commands block to the `## Commands` section, same pattern as tech. Substitute `<project-name>` and use the detected `COMPOSE` value.

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

## Step D7 — VS Code devcontainer

Only run this step if Docker was configured in Step D6.

Create `.devcontainer/devcontainer.json` so VS Code can open the project directly inside the Docker workspace.

1. Create the `.devcontainer/` directory
2. Read `$CLAUDE_SKILL_DIR/assets/templates/data/devcontainer.json`, substitute `{{PROJECT_NAME}}`, and write to `.devcontainer/devcontainer.json`

Do not ask — always create the devcontainer when Docker is set up.

The devcontainer template includes Python and Jupyter extensions by default.

```bash
git add .devcontainer/
git commit -m "chore: add VS Code devcontainer"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

---

## Task readiness rule

A task that involves `src/` code must not start until:
1. Its paired test spec exists in `docs/tasks/test-specs/`
2. The test spec has at least one test case with defined inputs and expected outputs

Experiment-only tasks (hyperparameter tuning, data exploration) do not require a test spec, but they DO require an entry in `docs/tasks/experiment-tracker.md` before running.

---

## Resuming in a new session

Paste into the new session:
- The active task file (`docs/tasks/active/NNN-*.md`)
- Its test spec (`docs/tasks/test-specs/NNN-*-test-spec.md`)
- `docs/tasks/experiment-tracker.md` (if running experiments)
- Relevant sections of `docs/architecture/overview.md`
