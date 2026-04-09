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
| `experiments/EXPERIMENT-TEMPLATE.md` | `experiments/EXPERIMENT-TEMPLATE.md` |
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/scripts/restructure-plan.py` | `.claude/scripts/restructure-plan.py` |
| `.claude/scripts/protect-secrets.py` | `.claude/scripts/protect-secrets.py` |
| `.claude/scripts/post-compact.py` | `.claude/scripts/post-compact.py` |
| `.claude/scripts/pre-compact.py` | `.claude/scripts/pre-compact.py` |
| `.claude/scripts/periodic-checkpoint.py` | `.claude/scripts/periodic-checkpoint.py` |
| `.claude/agents/task-executor.md` | `.claude/agents/task-executor.md` |
| `.claude/agents/architect.md` | `.claude/agents/architect.md` |
| `.claude/agents/code-reviewer.md` | `.claude/agents/code-reviewer.md` |
| `.claude/agents/security-auditor.md` | `.claude/agents/security-auditor.md` |

The following templates have no placeholders — copy them as-is. These files are tracked in `.claude/skill-manifest.json` (written in Step 3e) so they can be synced when the skill is updated later:
- `.claude/settings.json` — pre-configures Claude Code permissions and five hooks: plan restructuring on ExitPlanMode, secret file protection on Write/Edit, pre-compact checkpoint enforcement, post-compact context recovery, and periodic checkpoint reminders on Stop.
- `.claude/scripts/` — hook scripts for plan restructuring, secret file protection, pre-compact checkpoint enforcement, post-compact context recovery, and periodic checkpoint reminders.
- `.claude/agents/task-executor.md` — ephemeral agent for executing one task at a time. Follows TDD for code, experiment workflow for ML, commits after completion. Ships with `model: inherit` and a `# model-tier: fast` comment — Step 3d will detect available models and update the field to the best fast-tier model before completing setup.
- `.claude/agents/architect.md` — reviews proposed features, pipeline design, and data model changes. Drafts ADRs for non-obvious decisions. Ships with `model: inherit` and a `# model-tier: deep` comment.
- `.claude/agents/code-reviewer.md` — reviews changed files using structured perspectives (correctness, data integrity, reproducibility, performance, testing, etc.). Selects 2–4 perspectives based on what changed. Ships with `model: inherit` and a `# model-tier: balanced` comment.
- `.claude/agents/security-auditor.md` — reviews application code for data leakage, credential exposure, injection risks, and insecure defaults. Ships with `model: inherit` and a `# model-tier: deep` comment.

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
   > 7. You'll configure it in step D6 — **do not share it in this chat**

   **Do not ask the user to paste the token in the conversation.** In step D6, they'll either store it via `sbx secret set -g github` (sandbox path) or paste it into `.env` (Docker path). The token never gets written into the repo.

---

## Step D6 — Sandbox or Docker setup

Detect what's available — prefer Docker Sandbox (`sbx`) when present:

```bash
if command -v sbx >/dev/null 2>&1; then
    echo "ISOLATION=sbx"
elif command -v docker >/dev/null 2>&1; then
    echo "ISOLATION=docker"
else
    echo "ISOLATION=none"
fi
```

If `ISOLATION=none`: tell the user neither sbx nor Docker was detected and skip this step entirely.

If `ISOLATION=sbx`: proceed with **Option A** below.
If `ISOLATION=docker`: skip to **Option B** below.

---

### Option A — Docker Sandbox (`sbx`)

Docker Sandbox runs Claude Code inside a microVM with its own kernel — stronger isolation than a container, with built-in network policies and credential management. No base images to build, no Dockerfiles to write, no volumes to manage.

Tell the user: *"Docker Sandbox (`sbx`) detected — setting up a sandboxed environment. This runs Claude Code in an isolated microVM with network controls and credential injection. No Docker images or compose files needed."*

**A1. Check login status**

```bash
sbx ls >/dev/null 2>&1 && echo "logged in" || echo "needs login"
```

If not logged in, tell the user:
```bash
sbx login
```

This opens a browser for Docker OAuth. During first login, `sbx` prompts for a default network policy — recommend **Balanced** (default deny with common dev sites allowed).

**A2. Configure credentials**

Tell the user to set their Anthropic API key and (if a GitHub repo was created in D5) their GitHub token:

```bash
sbx secret set -g anthropic
sbx secret set -g github
```

Each command prompts for the secret interactively — the value is stored in the OS keychain and injected via proxy at runtime. **Credentials are never stored inside the sandbox.** If they already ran these for a previous project, they can skip — global secrets apply to all sandboxes.

**Do not ask the user to paste credentials into the chat.** They run the commands themselves.

**A3. Custom template**

The default `sbx` template includes Claude Code, Git, Python, Node.js, Go, and Java — everything a data/ML project needs. **Skip this step** unless the project requires unusual system libraries (e.g. GPU drivers, spatial databases).

If a custom template is needed, create `docker/sandbox.Dockerfile`:
```dockerfile
FROM docker/sandbox-templates:claude-code
USER root
RUN apt-get update && apt-get install -y <packages>
USER agent
```

Build and push:
```bash
docker build -t <registry>/<project-name>-sandbox:latest -f docker/sandbox.Dockerfile --push .
```

**A4. Update `.gitignore`**

Append to `.gitignore` (create if it does not exist):
```
# Docker Sandbox worktrees
.sbx/

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

**A5. Append sandbox commands to `CLAUDE.md`**

Add the following to the `## Commands` section of `CLAUDE.md`:

```bash
# Sandbox (run from host)
sbx run claude .                              # start or reconnect
sbx run claude --name <project-name>          # named sandbox
sbx run claude --branch <feature-name> .      # work on a branch (auto-worktree)
sbx run claude . -- "<prompt>"                # start with a prompt
sbx exec -it <project-name> bash              # shell into running sandbox
sbx stop <project-name>                       # stop (preserves state)
sbx rm <project-name>                         # remove (destroys sandbox state)
```

**A6. Commit**

```bash
git add .gitignore CLAUDE.md
test -f docker/sandbox.Dockerfile && git add docker/sandbox.Dockerfile || true
git diff --cached --quiet || git commit -m "chore: configure Docker Sandbox environment"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

After completing Option A, **skip Step D7** (devcontainer) — the sandbox is the dev environment. Continue to Step D8.

---

### Option B — Docker (fallback)

Use this path when `sbx` is not available (Linux hosts, CI environments, or user preference).

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

Only run this step if **Option B (Docker)** was used in Step D6. Skip entirely if `sbx` was configured — the sandbox is the dev environment.

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

## Step D8 — Code quality tooling

Set up linting, formatting, and test coverage enforcement. Data/ML projects are Python-first, so configure accordingly.

**1. Detect existing config**

```bash
ls ruff.toml pyproject.toml .flake8 .pre-commit-config.yaml Makefile 2>/dev/null || echo "none found"
```

If config files already exist, skip that tool — don't overwrite existing setup.

**2. Configure Python tooling**

**Linter + formatter:** ruff (covers both — replaces flake8, isort, black)

Create `ruff.toml`:
```toml
target-version = "py312"
line-length = 120

[lint]
select = ["E", "F", "I", "N", "W", "UP", "B", "SIM", "RUF"]
ignore = ["E501"]

[lint.per-file-ignores]
"notebooks/*" = ["E402", "F401"]  # notebooks have different import patterns

[format]
quote-style = "double"
```

**Test coverage:** pytest-cov

Add to `requirements.txt` (or `requirements-dev.txt`):
```
ruff
pytest
pytest-cov
```

Create or update `pyproject.toml` coverage section:
```toml
[tool.pytest.ini_options]
addopts = "--cov=src --cov-report=term-missing --cov-fail-under=80"
testpaths = ["tests"]
```

**Pre-commit:** create `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
  - repo: https://github.com/kynan/nbstripout
    rev: 0.7.1
    hooks:
      - id: nbstripout
```

Note: `nbstripout` strips notebook outputs before commits — prevents accidentally committing large outputs, credentials in cell outputs, or PII.

**3. Create a Makefile (if one doesn't exist)**

```makefile
.PHONY: lint format test check notebook-clean

lint:
	ruff check src/ tests/

format:
	ruff format src/ tests/

test:
	pytest

notebook-clean:
	nbstripout notebooks/*.ipynb

check: lint test
	@echo "All checks passed."
```

If a `Makefile` already exists, add missing targets only.

**4. Update CLAUDE.md commands**

Fill in the TODO placeholders in the `## Commands` section of `CLAUDE.md`:
- `make lint` or `ruff check src/ tests/`
- `make format` or `ruff format src/ tests/`
- `make test` or `pytest`

**5. Install pre-commit hooks**

```bash
pip install pre-commit nbstripout && pre-commit install
```

**6. Commit**

```bash
git add Makefile .pre-commit-config.yaml ruff.toml pyproject.toml requirements*.txt 2>/dev/null
git diff --cached --quiet || git commit -m "chore: add code quality tooling (lint, format, coverage)"
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
