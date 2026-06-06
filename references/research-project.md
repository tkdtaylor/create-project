# Research / Documentation / Planning Project Setup

Follow these steps for research, writing, analysis, documentation, **and planning/tracking projects** ("other" type). Return to the main skill (Step 3) when done.

## Note for "other" type projects

Planning, tracking, and organising projects use this same base structure, but replace the generic `sources/`, `notes/`, `outputs/` folders with **domain-specific named folders** that map to what the user is actually tracking.

Before creating directories (Step R1), ask: *"What are the main categories you need to track or organise?"* Use their answer to name the top-level folders. For example:

| Project | Folders instead of sources/notes/outputs |
|---------|------------------------------------------|
| Home renovation | `tasks/`, `contractors/`, `costs/`, `timeline/` |
| Event planning | `vendors/`, `budget/`, `schedule/`, `guests/` |
| Job search | `companies/`, `applications/`, `interviews/`, `offers/` |
| Product launch | `research/`, `decisions/`, `risks/`, `stakeholders/` |

Keep `docs/` as-is (task tracking, log, README). Adapt the CLAUDE.md "Research approach" section to describe the tracking/planning approach rather than research methodology.

---

## Structure

```
project-root/
├── README.md                   # Project landing page (for GitHub and users)
├── CLAUDE.md                   # Project context for Claude Code sessions
├── sources/                    # Input materials — never edited, only read
│   ├── local/                  # PDFs, docs, files the user provides
│   └── web/                    # Saved pages, downloaded references, search results
├── notes/                      # Working synthesis — Claude's scratchpad
│   └── by-topic/               # Notes organized by research area or theme
├── outputs/                    # Final deliverables
│   ├── templates/              # Output structure templates (decision brief, research report, etc.)
│   ├── drafts/                 # Work in progress
│   └── final/                  # Completed and approved pieces
└── docs/                       # Project management
    ├── research-log.md         # Running log of searches, sources reviewed, status
    ├── outline.md              # Structure of the intended output(s)
    └── tasks/
        ├── active/
        ├── backlog/
        └── completed/
```

The key separation: `sources/` and `docs/` are the input side (what guides the work), `notes/` and `outputs/` are the output side (what gets produced).

---

## Step R1 — Create directory structure

```bash
mkdir -p sources/local sources/web
mkdir -p notes/by-topic
mkdir -p outputs/templates outputs/drafts outputs/final
mkdir -p docs/tasks/active docs/tasks/backlog docs/tasks/completed
```

Add `.gitkeep` so empty directories are tracked:

```bash
touch sources/local/.gitkeep sources/web/.gitkeep
touch notes/by-topic/.gitkeep
touch outputs/templates/.gitkeep outputs/drafts/.gitkeep outputs/final/.gitkeep
touch docs/tasks/backlog/.gitkeep docs/tasks/completed/.gitkeep
```

---

## Step R2 — Populate template files

Templates come from two directories:
- **`$CLAUDE_SKILL_DIR/assets/templates/common/`** — hook scripts shared by all project types
- **`$CLAUDE_SKILL_DIR/assets/templates/research/`** — research-specific templates, settings, and agents

| Placeholder | Value |
|-------------|-------|
| `{{PROJECT_NAME}}` | Project name |
| `{{PROJECT_DESCRIPTION}}` | Description |
| `{{DATE}}` | Today's date (YYYY-MM-DD) |

**From `research/`** (substitute placeholders where marked):

| Template | Output path |
|----------|-------------|
| `README.md` | `README.md` (project root) |
| `research-log.md` | `docs/research-log.md` |
| `outline.md` | `docs/outline.md` |
| `progress-tracker.md` | `docs/tasks/progress-tracker.md` |
| `.claude/settings.json` | `.claude/settings.json` |
| `.claude/agents/task-executor.md` | `.claude/agents/task-executor.md` |
| `decision-brief-template.md` | `outputs/templates/decision-brief.md` |
| `deep-research-template.md` | `outputs/templates/deep-research.md` |
| `learning-plan-template.md` | `outputs/templates/learning-plan.md` |

**From `common/`** (copy as-is, no placeholders — shared across all project types):

| Template | Output path |
|----------|-------------|
| `scripts/check-task-state.sh` | `scripts/check-task-state.sh` (mode 755) |
| `scripts/start-task.sh` | `scripts/start-task.sh` (mode 755) |
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

All scripts and settings are tracked in `.claude/skill-manifest.json` (Step 3e) for future sync. Research projects use a reduced hook set (no config-protection, edit-tracker, batch-format-typecheck, or spec-coverage hooks — research has no test specs). See `references/tech-project.md` Step T2 for the full hook profile table.

**Agent:** `task-executor` (fast) — ephemeral single-task executor for research. Ships with `model: inherit` and `# model-tier: fast` — Step 3d updates it.

**Output templates** (copy as-is):
- `decision-brief.md` — structured option comparison with matrix, pros/cons, recommendation
- `deep-research.md` — in-depth report with methodology, findings, cross-source analysis
- `learning-plan.md` — three-phase syllabus (Apprentice → Journeyman → Master)

**For `README.md` at the project root:** substitute `{{PROJECT_NAME}}` and `{{PROJECT_DESCRIPTION}}`. This README is the first thing someone sees on GitHub — the description should make the research goal and intended output clear.

For `outline.md`: if the user has described what they're trying to produce (a report, a summary, an analysis), pre-populate the outline structure with a reasonable skeleton for that output type. Leave section bodies blank but give the headings real names where possible.

---

## Step R3 — Create CLAUDE.md

Read `$CLAUDE_SKILL_DIR/assets/templates/research/CLAUDE.md`, substitute placeholders, and write to `CLAUDE.md` at the project root.

For the **Research approach** section: tailor based on the project. For a literature review, note the domains and databases to prioritize. For competitive analysis, note the scope (geography, market segment). For report writing, note the intended audience and tone. Keep it specific.

---

## Step R4 — Offer to create the first task

Ask: *"Would you like me to create the first task? A good starting point is usually scoping the research — defining the key questions, identifying primary sources, and setting bounds on what's in and out of scope."*

If yes, create `docs/tasks/active/001-scope-research.md` from `task-template.md`.

Populate it with real content based on the project description — list actual research questions to answer and real criteria for what a complete answer looks like. Don't use placeholder text.

Add a row to `docs/tasks/progress-tracker.md`:
```
| 001 | Scope research | ⏳ In progress |
```

Then ask: *"Would you like me to run a few initial searches to seed your sources? I can look for [2–3 specific terms derived from the project description] and save the most useful results to `sources/web/`."*

Fill in the bracketed terms with actual search queries relevant to the project — for a competitive analysis, that's the main tools or vendors; for a literature review, the key concepts or authors; for a market study, the market segment and geography.

If yes, run 2–4 targeted searches using WebSearch (or suggest the user install a search MCP if WebSearch isn't available in this session). Save each worthwhile result as a markdown file in `sources/web/` with the URL and access date at the top. Log each search in `docs/research-log.md`.

This gives the project a running start rather than leaving the user with an empty sources directory.

---

## Step R5 — Initialize git and remote

Check:
```bash
test -d .git && echo "exists" || echo "missing"
```

If missing, ask whether to initialize. If yes:
```bash
git init
git branch -m main
git add .
git commit -m "chore: initialize research project structure"
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
   > 7. You'll configure it in step R6 — **do not share it in this chat**

   **Do not ask the user to paste the token in the conversation.** In step R6, they'll either store it via `sbx secret set -g github` (sandbox path) or paste it into `.env` (Docker path). The token never gets written into the repo.

---

## Step R6 — Choose an isolation mode

This is a real decision, not an auto-default — present it to the user with the reasons for each path, then branch on their choice. First detect what's installed so you only offer options that are available:

```bash
command -v sbx    >/dev/null 2>&1 && echo "sbx available"
command -v docker >/dev/null 2>&1 && echo "docker available"
```

Present the trade-off. For research, isolation matters less than for code (you're mostly fetching sources and writing notes), so the deciding factor is usually whether this project needs to reach **other projects or document collections on your machine**:

- **Isolated — Docker Sandbox (Option A) or Docker (Option B).** Best when you want network-egress control over what sources get fetched, a reproducible toolchain (pandoc, PDF tooling), or a workspace decoupled from your host. The workspace is walled off — which also means it **cannot see other local projects** unless you explicitly mount them.
- **Local — no container (Option C).** Best when this project needs to **read or reference other projects, notes, or document folders on your machine** (a container would wall them off), or when container overhead isn't worth it for a lightweight research project. Claude Code runs directly on the host. **This is a fine default for research** — most research projects don't need isolation.

Ask which they prefer. Guidance for steering:
- If they mention needing to reference **another local project, notes folder, or document collection**, recommend **Option C (Local)** and capture those paths (Option C handles this).
- Otherwise, follow their preference; if they have none, Local (Option C) is a reasonable default for research, and isolation (Option A/B) is worth offering when they want network controls.
- If neither `sbx` nor Docker is installed, Option A/B aren't available — use Option C (Local).

Routing:
- **Option A** — user chose sandbox and `sbx` is available
- **Option B** — user chose Docker and Docker is available
- **Option C** — user chose Local, or neither `sbx` nor Docker is installed

---

### Option A — Docker Sandbox (`sbx`)

Docker Sandbox runs Claude Code inside a microVM with its own kernel — stronger isolation than a container, with built-in network policies and credential management.

Ask: *"Docker Sandbox (`sbx`) detected — would you like to set up a sandboxed research environment? This runs Claude Code in an isolated microVM with network controls and credential injection. No Docker images or compose files needed."*

If yes:

**A1. Check login status**

```bash
sbx ls >/dev/null 2>&1 && echo "logged in" || echo "needs login"
```

If not logged in, tell the user:
```bash
sbx login
```

Recommend **Balanced** network policy during first login.

**A2. Configure credentials**

Tell the user to set their Anthropic API key and (if a GitHub repo was created in R5) their GitHub token:

```bash
sbx secret set -g anthropic
sbx secret set -g github
```

**Do not ask the user to paste credentials into the chat.** They run the commands themselves. If they already ran these for a previous project, they can skip — global secrets apply to all sandboxes.

**A3. Update `.gitignore`**

Append to `.gitignore` (create if it does not exist):
```
# Docker Sandbox worktrees
.sbx/

# Per-task worktrees (created by scripts/start-task.sh under concurrent sessions)
.claude/worktrees/

# Per-session lock files (used by session-lock.py to detect concurrent sessions)
.claude/sessions/

# Secrets
.env

# Python virtual environment
.venv/

# Python bytecode — also emitted by .claude/scripts/ hooks
__pycache__/
*.pyc
```

**A4. Add a Commands section to `CLAUDE.md`**

The research `CLAUDE.md` template has no `## Commands` section. Create one:

```markdown
## Commands

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
```

**A5. Commit**

```bash
git add .gitignore CLAUDE.md
git diff --cached --quiet || git commit -m "chore: configure Docker Sandbox environment"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

After completing Option A, **skip Step R7** (devcontainer). Continue to the "Working with sources" section.

---

### Option B — Docker (fallback)

Use this path when `sbx` is not available (Linux hosts, CI environments, or user preference).

Ask: *"Would you like to set up a Docker research environment? This uses a shared base image (Claude Code, pandoc, PDF tools, Python research libraries) that is built once and reused across all your research projects. A new workspace volume is created for this project — no per-project image build needed."*

If yes:

**1. Check and build the shared base image**

The base image (`claude-project-research:latest`) is shared across all research projects. Build it only if it is missing or its Dockerfile has changed.

```bash
RESEARCH_DOCKERFILE="$CLAUDE_SKILL_DIR/assets/base/research.Dockerfile"
CURRENT_HASH=$(sha256sum "$RESEARCH_DOCKERFILE" | cut -d' ' -f1)
STORED_HASH=$(docker image inspect claude-project-research:latest \
    --format '{{index .Config.Labels "dev.claude-project.dockerfile-hash"}}' 2>/dev/null || echo "missing")

if [ "$CURRENT_HASH" != "$STORED_HASH" ]; then
    echo "Building shared base image (claude-project-research:latest)..."
    docker build \
        --label "dev.claude-project.dockerfile-hash=$CURRENT_HASH" \
        -t claude-project-research:latest \
        -f "$RESEARCH_DOCKERFILE" \
        "$CLAUDE_SKILL_DIR/assets/base/"
    echo "Base image ready."
else
    echo "Base image is up-to-date — skipping build."
fi
```

**2. Create the project workspace volume**

```bash
docker volume create {{PROJECT_NAME}}-workspace
```

The volume is empty at creation. The container entrypoint seeds it from the host project and installs Python dependencies on first run.

**3. Ensure Claude config directory exists on host**

The container bind-mounts the entire `~/.claude/` directory writable so Claude Code can read credentials, refresh tokens, and write session state. Create it and required subdirectories if needed:
```bash
mkdir -p ~/.claude/plans
```

**4. Write per-project files**

Read each file from `$CLAUDE_SKILL_DIR/assets/templates/research/docker/`, substitute the placeholders below, and write to `docker/<filename>`. Two files are exceptions — write them to the **project root**, not inside `docker/`:
- `.env.example` → project root
- `requirements.txt` → project root (only if it does not already exist)

| Placeholder | Value |
|-------------|-------|
| `{{PROJECT_NAME}}` | Project name, lowercased, spaces/underscores → hyphens |
| `{{DATE}}` | Today's date (YYYY-MM-DD) |

Do not substitute `${HOME}` — that is a Docker Compose variable resolved at runtime.

**5. Update `.gitignore`**

Append to `.gitignore` (create it if it does not exist):
```
# Per-task worktrees (created by scripts/start-task.sh under concurrent sessions)
.claude/worktrees/

# Per-session lock files (used by session-lock.py to detect concurrent sessions)
.claude/sessions/

# Secrets
.env

# Python virtual environment (lives in the Docker volume — not part of the repo)
.venv/

# Python bytecode — also emitted by .claude/scripts/ hooks
__pycache__/
*.pyc
```

**6. Write `.env` with git credentials**

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

If no GitHub repo was created in R5, also leave `GIT_REMOTE_URL` blank.

Tell the user to open `.env` in their editor and fill in:
- `ANTHROPIC_API_KEY` — from https://console.anthropic.com/settings/keys
- `GIT_TOKEN` — the fine-grained PAT from R5 (https://github.com/settings/personal-access-tokens/new — Contents: read/write, this repo only)
- `GIT_REMOTE_URL` — if R5 wasn't run, the URL of the project's git remote
- `GIT_USER_NAME` / `GIT_USER_EMAIL` — only if they weren't pre-filled from host git config

**Never ask the user to paste the token or API key into the chat.** They should open `.env` directly and type them in. The container entrypoint configures git from these values on every start — the token is never written to disk inside the container.

**7. Add a Commands section to `CLAUDE.md`**

The research `CLAUDE.md` template has no `## Commands` section. Create one and add the block below. Substitute `<project-name>` with the actual lowercased, hyphenated project name:
```markdown
## Commands

```bash
# Docker
docker compose -f docker/docker-compose.yml run --rm research                            # open shell (seeds workspace + installs deps on first run)
docker compose -f docker/docker-compose.yml run --rm research pandoc sources/local/input.pdf -o outputs/drafts/output.md
docker compose -f docker/docker-compose.yml run --rm research python scripts/fetch.py

# Export workspace → host (run on the host, not inside the container)
docker run --rm -v <project-name>-workspace:/src:ro -v "$(pwd)":/dst debian:bookworm-slim cp -r /src/. /dst/

# Backup / restore workspace volume
docker run --rm -v <project-name>-workspace:/src:ro -v "$(pwd)":/dst debian:bookworm-slim tar czf /dst/workspace-backup.tar.gz -C /src .
docker run --rm -v <project-name>-workspace:/dst -v "$(pwd)":/src debian:bookworm-slim tar xzf /src/workspace-backup.tar.gz -C /dst
```
```

**8. Offer to initialize**

Ask: *"Docker is ready. Would you like me to initialize the workspace volume now? This seeds your project files into the container and installs Python research dependencies (takes a moment on first run)."*

If yes:
```bash
docker compose -f docker/docker-compose.yml run --rm research echo "Workspace initialized."
```

---

### Option C — Local (no container)

Use this path when the user chose to run on the host — typically because the research needs to reference **other projects, notes, or document collections on their machine**, or because container overhead isn't warranted for a lightweight research project. No Dockerfile, compose file, workspace volume, or devcontainer is created; Claude Code runs directly against the working directory.

**C1. Update `.gitignore`**

Append to `.gitignore` (create if it does not exist):
```
# Per-task worktrees (created by scripts/start-task.sh under concurrent sessions)
.claude/worktrees/

# Per-session lock files (used by session-lock.py to detect concurrent sessions)
.claude/sessions/

# Secrets
.env

# Python virtual environment
.venv/

# Python bytecode — also emitted by .claude/scripts/ hooks
__pycache__/
*.pyc
```

**C2. Capture related local projects**

If the research needs awareness of other projects, notes folders, or document collections on the host, ask the user for their paths (one or more). Record them in `CLAUDE.md` as **read-only context** so future sessions know where they live and that they are not to be modified from here. Append a `## Related projects` section:

```markdown
## Related projects

These live elsewhere on this machine and are **read-only context** — reference them, do not edit them from this project:

- `<absolute-or-relative-path>` — <one line: what it is and why this research needs it>
```

Use absolute paths (or paths relative to this project's root) exactly as the user gives them. Do not copy or symlink the sources — just record where they are. If the user has no related projects to declare, skip this section.

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

After completing Option C, **skip Step R7** (devcontainer). Continue to the "Working with sources" section.

---

## Step R7 — VS Code devcontainer

Only run this step if **Option B (Docker)** was used in Step R6. Skip entirely if `sbx` (Option A) or Local (Option C) was chosen — there is no Docker workspace to open into.

Ask: *"Would you like to add a devcontainer.json for VS Code? This lets you open the project directly inside the Docker workspace via the Dev Containers extension — your editor, terminal, and Claude Code all run in the isolated container."*

If yes:

1. Create the `.devcontainer/` directory
2. Read `$CLAUDE_SKILL_DIR/assets/templates/research/devcontainer.json`, substitute `{{PROJECT_NAME}}` with the project name, and write to `.devcontainer/devcontainer.json`

To use it: install the **Dev Containers** extension in VS Code, then either:
- Open the project folder → VS Code detects `.devcontainer/` and prompts to reopen in container
- Or: Command Palette → *Dev Containers: Reopen in Container*

The container will start (seeding the workspace volume on first open if needed) and VS Code will connect to `/workspace` inside the container.

---

## Working with sources

When the user provides local files (PDFs, docs, notes), place them in `sources/local/`. Use descriptive filenames — `author-year-title.pdf` for academic papers, `domain-topic-date.md` for web saves.

When doing web searches, save meaningful results to `sources/web/` as markdown files. Include the URL, date accessed, and a brief note on why it's relevant at the top of each saved file.

Notes in `notes/` are working synthesis — they can be messy. Final outputs belong in `outputs/drafts/` and `outputs/final/` only when they're ready to share or review.

---

## Task format for research projects

Research tasks define a question to answer, not a feature to build. A task is done when the question is answered, not when a certain amount of effort has been spent. See `task-template.md` for the format — the key fields are **Research question**, **Scope**, and **Done when**.

---

## Resuming in a new session

Paste into the new session:
- The active task file (`docs/tasks/active/NNN-*.md`)
- `docs/research-log.md` (current status and what's been tried)
- `docs/outline.md` (the target structure)
