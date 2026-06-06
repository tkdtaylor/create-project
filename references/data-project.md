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
    ├── spec/                         # Authoritative current-state snapshot
    │   ├── SPEC.md                   #   Index + system summary + invariants
    │   ├── behaviors.md              #   Pipeline behaviors (training, eval, inference)
    │   ├── architecture.md           #   C4 element catalog + datasets (paired with diagrams.md)
    │   ├── data-model.md             #   Datasets, features, model artifacts, results schema
    │   ├── interfaces.md             #   CLI runners, notebook entrypoints, public src/ API
    │   ├── configuration.md          #   Experiment configs, env vars, metrics catalog
    │   └── fitness-functions.md      #   Executable invariants — reproducibility, raw immutability, perf budgets (run via `make fitness`)
    ├── architecture/
    │   ├── overview.md               # Narrative tour of the pipeline
    │   ├── diagrams.md               # Mermaid data lineage + pipeline flows
    │   ├── tech-stack.md
    │   └── decisions/                # ADRs (history + rationale)
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

Code in `src/` follows TDD (test spec before implementation). Experiments follow their own workflow: hypothesis → config → run → results → log. The spec in `docs/spec/` is the authoritative snapshot of what the pipeline does and how to reproduce its results — every pipeline-changing task or experiment updates it in the same commit.

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
mkdir -p docs/spec
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

Templates come from three directories:
- **`$CLAUDE_SKILL_DIR/assets/templates/common/`** — hook scripts shared by all project types
- **`$CLAUDE_SKILL_DIR/assets/templates/tech/`** — tech-only hook scripts (config-protection, protect-checkout, edit-tracker, batch-format-typecheck) — also used by data projects
- **`$CLAUDE_SKILL_DIR/assets/templates/data/`** — data-specific templates, settings, and agents

| Placeholder | Value |
|-------------|-------|
| `{{PROJECT_NAME}}` | Project name |
| `{{PROJECT_DESCRIPTION}}` | Description |
| `{{TECH_STACK}}` | Tech stack |
| `{{DATE}}` | Today's date (YYYY-MM-DD) |

**From `data/`** (substitute placeholders where marked):

| Template | Output path |
|----------|-------------|
| `README.md` | `README.md` (project root) |
| `architecture-overview.md` | `docs/architecture/overview.md` |
| `diagrams.md` | `docs/architecture/diagrams.md` |
| `tech-stack.md` | `docs/architecture/tech-stack.md` |
| `spec/SPEC.md` | `docs/spec/SPEC.md` |
| `spec/behaviors.md` | `docs/spec/behaviors.md` |
| `spec/architecture.md` | `docs/spec/architecture.md` |
| `spec/data-model.md` | `docs/spec/data-model.md` |
| `spec/interfaces.md` | `docs/spec/interfaces.md` |
| `spec/configuration.md` | `docs/spec/configuration.md` |
| `spec/fitness-functions.md` | `docs/spec/fitness-functions.md` |
| `roadmap.md` | `docs/plans/roadmap.md` |
| `coverage-tracker.md` | `docs/tasks/test-specs/coverage-tracker.md` |
| `experiment-tracker.md` | `docs/tasks/experiment-tracker.md` |
| `experiments/EXPERIMENT-TEMPLATE.md` | `experiments/EXPERIMENT-TEMPLATE.md` |
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/agents/task-executor.md` | `.claude/agents/task-executor.md` |
| `.claude/agents/architect.md` | `.claude/agents/architect.md` |
| `.claude/agents/code-reviewer.md` | `.claude/agents/code-reviewer.md` |
| `.claude/agents/security-auditor.md` | `.claude/agents/security-auditor.md` |
| `.claude/agents/spec-verifier.md` | `.claude/agents/spec-verifier.md` |

**From `tech/`** (tech-only hooks and the backlog runner, also used by data projects):

| Template | Output path |
|----------|-------------|
| `.claude/backlog-playbook.md` | `.claude/backlog-playbook.md` |
| `.claude/commands/backlog-run.md` | `.claude/commands/backlog-run.md` |
| `.claude/commands/backlog-run-parallel.md` | `.claude/commands/backlog-run-parallel.md` |
| `.claude/commands/backlog-autopilot.md` | `.claude/commands/backlog-autopilot.md` |
| `.claude/commands/backlog-autopilot-parallel.md` | `.claude/commands/backlog-autopilot-parallel.md` |
| `.claude/scripts/config-protection.py` | `.claude/scripts/config-protection.py` |
| `.claude/scripts/protect-checkout.py` | `.claude/scripts/protect-checkout.py` |
| `.claude/scripts/edit-tracker.py` | `.claude/scripts/edit-tracker.py` |
| `.claude/scripts/batch-format-typecheck.py` | `.claude/scripts/batch-format-typecheck.py` |
| `.claude/scripts/spec-coverage-check.py` | `.claude/scripts/spec-coverage-check.py` |
| `.claude/scripts/scope-drift-summary.py` | `.claude/scripts/scope-drift-summary.py` |
| `.claude/scripts/detect-smoke-tests.py` | `.claude/scripts/detect-smoke-tests.py` |
| `.claude/scripts/check-fitness.py` | `.claude/scripts/check-fitness.py` |
| `.claude/scripts/auto-cleanup-merge.py` | `.claude/scripts/auto-cleanup-merge.py` |

**From `common/`** (copy as-is, no placeholders — shared across all project types):

| Template | Output path |
|----------|-------------|
| `agent-rules.md` | `docs/architecture/agent-rules.md` |
| `scripts/check-task-state.sh` | `scripts/check-task-state.sh` (mode 755) |
| `scripts/start-task.sh` | `scripts/start-task.sh` (mode 755) |
| `scripts/finish-task.sh` | `scripts/finish-task.sh` (mode 755) |
| `scripts/verify-worktree-isolation.sh` | `scripts/verify-worktree-isolation.sh` (mode 755) |
| `.claude/scripts/_hook_utils.py` | `.claude/scripts/_hook_utils.py` |
| `.claude/scripts/protect-secrets.py` | `.claude/scripts/protect-secrets.py` |
| `.claude/scripts/block-no-verify.py` | `.claude/scripts/block-no-verify.py` |
| `.claude/scripts/no-commit-on-main.py` | `.claude/scripts/no-commit-on-main.py` |
| `.claude/scripts/session-lock.py` | `.claude/scripts/session-lock.py` |
| `.claude/scripts/session-lock-touch.py` | `.claude/scripts/session-lock-touch.py` |
| `.claude/scripts/restructure-plan.py` | `.claude/scripts/restructure-plan.py` |
| `.claude/scripts/pre-compact.py` | `.claude/scripts/pre-compact.py` |
| `.claude/scripts/post-compact.py` | `.claude/scripts/post-compact.py` |
| `.claude/scripts/periodic-checkpoint.py` | `.claude/scripts/periodic-checkpoint.py` |
| `.claude/scripts/strategic-compact.py` | `.claude/scripts/strategic-compact.py` |
| `.claude/scripts/desktop-notify.py` | `.claude/scripts/desktop-notify.py` |
| `.claude/scripts/inject-retros.py` | `.claude/scripts/inject-retros.py` |

All scripts and settings are tracked in `.claude/skill-manifest.json` (Step 3e) for future sync. Hook profiles are identical to technical projects — see `references/tech-project.md` Step T2 for the full profile table.

**Agents:** Ship with `model: inherit` and a `# model-tier:` comment — Step 3d detects available models and updates the field.
- `task-executor` (fast) — ephemeral single-task executor with TDD + experiment workflow
- `architect` (deep) — pipeline design review, ADR drafting, drift audit, and fitness function proposal (incl. reproducibility contracts)
- `code-reviewer` (balanced) — structured review with data integrity and reproducibility perspectives
- `security-auditor` (deep) — data leakage, credential exposure, injection risks
- `spec-verifier` (balanced) — assertion-by-assertion check that the implementation matches the test spec; invoke before commit on completed tasks

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
| 001 | Project setup | 001-project-setup-test-spec.md | ✅ | ⏳ | — |
```
(Six columns: Task ID, Feature, Spec file, Tests written, Status, Verified by. The `Verified by` column is filled in by the verify commit later — `—` is fine while the task is in progress.)

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
# Initialize on 'main' (never 'master') — robust across git versions and any
# global init.defaultBranch setting; falls back to repointing the unborn HEAD.
git init -b main 2>/dev/null || { git init && git symbolic-ref HEAD refs/heads/main; }
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

## Step D6 — Choose an isolation mode

This is a real decision, not an auto-default — present it to the user with the reasons for each path, then branch on their choice. First detect what's installed so you only offer options that are available:

```bash
command -v sbx    >/dev/null 2>&1 && echo "sbx available"
command -v docker >/dev/null 2>&1 && echo "docker available"
```

Present the trade-off. The deciding factor is usually whether this project needs to reach **other projects on your machine** (e.g. a shared dataset repo, a sibling library, or another model project):

- **Isolated — Docker Sandbox (Option A) or Docker (Option B).** Best when the project runs untrusted code, installs many or unfamiliar dependencies, needs a reproducible environment decoupled from your host, or benefits from network-egress control. The workspace is walled off from the rest of your machine — which also means it **cannot see other local projects** unless you explicitly mount them.
- **Local — no container (Option C).** Best when this project needs to **read or reference other projects on your machine** (a container would wall them off), when you want the fastest iteration on your existing host toolchain (e.g. a local GPU/CUDA setup), or when Docker overhead isn't worth it for a small or short-lived project. Claude Code runs directly on the host.

Ask which they prefer. Guidance for steering:
- If they mention needing to work against, import from, or stay in sync with **another local project or dataset directory**, recommend **Option C (Local)** and capture those paths (Option C handles this).
- Otherwise, if they have no preference, recommend the strongest isolation available: `sbx` → Option A, else Docker → Option B.
- If neither `sbx` nor Docker is installed, Option A/B aren't available — present Option C (Local) as the path, or note they can install Docker/`sbx` first.

Routing:
- **Option A** — user chose sandbox and `sbx` is available
- **Option B** — user chose Docker and Docker is available
- **Option C** — user chose Local, or neither `sbx` nor Docker is installed

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

# Per-task worktrees (created by scripts/start-task.sh under concurrent sessions)
.claude/worktrees/

# Per-session lock files (used by session-lock.py to detect concurrent sessions)
.claude/sessions/

# Periodic-checkpoint marker (touched by periodic-checkpoint.py / pre-compact.py)
.claude/.last-checkpoint

# Secrets
.env

# Python virtual environment
.venv/

# Python bytecode — also emitted by .claude/scripts/ hooks
__pycache__/
*.pyc

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
# Per-task worktrees (created by scripts/start-task.sh under concurrent sessions)
.claude/worktrees/

# Per-session lock files (used by session-lock.py to detect concurrent sessions)
.claude/sessions/

# Periodic-checkpoint marker (touched by periodic-checkpoint.py / pre-compact.py)
.claude/.last-checkpoint

# Secrets
.env

# Python virtual environment
.venv/

# Python bytecode — also emitted by .claude/scripts/ hooks
__pycache__/
*.pyc

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

### Option C — Local (no container)

Use this path when the user chose to run on the host — typically because the project needs to read or reference **other projects or dataset directories on their machine**, or to use a local GPU/CUDA toolchain directly. No Dockerfile, compose file, workspace volume, or devcontainer is created; Claude Code runs directly against the working directory.

**C1. Update `.gitignore`**

Append to `.gitignore` (create if it does not exist):
```
# Per-task worktrees (created by scripts/start-task.sh under concurrent sessions)
.claude/worktrees/

# Per-session lock files (used by session-lock.py to detect concurrent sessions)
.claude/sessions/

# Periodic-checkpoint marker (touched by periodic-checkpoint.py / pre-compact.py)
.claude/.last-checkpoint

# Secrets
.env

# Python virtual environment
.venv/

# Python bytecode — also emitted by .claude/scripts/ hooks
__pycache__/
*.pyc
```

**C2. Capture related local projects**

If the project needs awareness of other projects or dataset directories on the host, ask the user for their paths (one or more). Record them in `CLAUDE.md` as **read-only context** so future sessions know where the siblings live and that they are not to be modified from here. Append a `## Related projects` section:

```markdown
## Related projects

These live elsewhere on this machine and are **read-only context** — reference them, do not edit them from this project:

- `<absolute-or-relative-path>` — <one line: what it is and why this project needs it>
```

Use absolute paths (or paths relative to this project's root) exactly as the user gives them. Do not copy or symlink the sibling projects — just record where they are. If the user has no related projects to declare, skip this section.

**C3. Append run commands to `CLAUDE.md`**

Add to the `## Commands` section of `CLAUDE.md`:
```bash
# Local (run from the project root on the host)
claude .                                      # start Claude Code in this project
```

**C4. Commit**

```bash
git add .gitignore CLAUDE.md
git diff --cached --quiet || git commit -m "chore: configure local (no-container) environment"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

After completing Option C, **skip Step D7** (devcontainer) — there is no container to open into. Continue to Step D8.

---

## Step D7 — VS Code devcontainer

Only run this step if **Option B (Docker)** was used in Step D6. Skip entirely if `sbx` (Option A) or Local (Option C) was chosen — there is no Docker workspace to open into.

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
.PHONY: lint format test fitness check notebook-clean

lint:
	ruff check src/ tests/

format:
	ruff format src/ tests/

test:
	pytest

notebook-clean:
	nbstripout notebooks/*.ipynb

# Fitness functions — see docs/spec/fitness-functions.md
#
# For data projects, reproducibility and data-integrity rules usually come first.
# Each F-NNN rule in fitness-functions.md gets its own `fitness-<id>` target below,
# and the umbrella lists the ones whose tooling is installed by default.
fitness:
	@echo "No fitness functions defined yet. Add rules in docs/spec/fitness-functions.md and per-rule targets below."

# Worked example — uncomment and adapt when you add F-001 to fitness-functions.md.
# .PHONY: fitness-raw-immutable
# fitness-raw-immutable:
# 	@modified=$$(git log --diff-filter=M --name-only --pretty=format: -- 'data/raw/*' | sort -u); \
# 	if [ -n "$$modified" ]; then \
# 	  printf "F-001 (raw data immutable) FAILED — files under data/raw/ have been modified after initial commit:\n%s\n" "$$modified"; exit 1; \
# 	fi; \
# 	echo "F-001 (raw data immutable) passed."

check: lint test fitness
	@echo "All checks passed."
```

The commented `fitness-raw-immutable` block shows the canonical per-rule shape — uncomment and adapt as rules are added to `fitness-functions.md`. The Stop hook `check-fitness.py` (strict profile) runs `make fitness` automatically; an empty umbrella is a no-op until the user opts in.

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
