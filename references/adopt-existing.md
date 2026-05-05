# Adopting an Existing Codebase

Follow these steps when the user wants to bring an existing project into the create-project workflow. The goal is to analyze what's already there and generate baseline docs so new work fits within a structured process — without reorganizing the codebase itself.

**Do not move, rename, or restructure existing source files.** The project's layout is established. Your job is to document it, add the tooling layer, and create a task/spec structure alongside what already exists.

---

## Step A1 — Analyze the codebase

Read the project before writing anything. Build a mental model of what's there.

**1. Project basics**
```bash
# Language/framework detection
ls package.json pyproject.toml Cargo.toml go.mod setup.py setup.cfg Makefile CMakeLists.txt *.sln 2>/dev/null
cat package.json 2>/dev/null | head -20
cat pyproject.toml 2>/dev/null | head -30
cat Cargo.toml 2>/dev/null | head -20

# Git history summary
git log --oneline -20
git shortlog -sn --no-merges | head -10

# Directory structure
find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './.venv/*' -not -path './target/*' -not -path './__pycache__/*' | head -100

# Existing docs
ls README.md CONTRIBUTING.md CHANGELOG.md docs/ .github/ 2>/dev/null
```

**2. Existing conventions**
- Is there a linter config (`.eslintrc`, `ruff.toml`, `.clang-format`, etc.)?
- Is there a test framework configured? Where do tests live?
- Is there CI (`Makefile`, `.github/workflows/`, `Dockerfile`, etc.)?
- What are the build/run/test commands?
- Is there an existing README? What does it cover?

**3. Architecture patterns**
- Entry points — where does execution start?
- Module organization — flat, layered, feature-based, monorepo?
- External dependencies — what are the major ones and why?
- Data flow — where does data come in, how is it processed, where does it go out?

**4. Current state**
- Are there open issues or TODOs in the code?
- What was the most recent work? (`git log --oneline -10`)
- Is there technical debt visible? (large files, commented-out code, TODO comments)

```bash
# Find TODOs and FIXMEs
grep -rn 'TODO\|FIXME\|HACK\|XXX' --include='*.py' --include='*.ts' --include='*.js' --include='*.rs' --include='*.go' --include='*.java' . 2>/dev/null | head -30
```

---

## Step A2 — Confirm understanding with the user

Present a concise summary of what you found:

- **Project type**: tech / data / research (based on what the code does)
- **Stack**: language, framework, key dependencies
- **Structure**: how files are organized (describe the actual layout, don't prescribe a different one)
- **Build/test/run commands**: what you found or inferred
- **Key decisions already made**: frameworks chosen, patterns in use, deployment targets

Ask: *"Does this capture your project accurately? Is there anything important I'm missing about how this project works or what conventions you follow?"*

Do not proceed until the user confirms. If they correct or expand your understanding, update before continuing.

---

## Step A3 — Generate CLAUDE.md

This is the most important output. Write a `CLAUDE.md` at the project root that accurately describes the project as it exists — not as it would be if scaffolded from scratch.

Read the appropriate CLAUDE.md template from `$CLAUDE_SKILL_DIR/assets/templates/<type>/CLAUDE.md` as a structural guide, but **rewrite every section to match the actual project**:

- **Project structure**: describe the real directory layout, not the template's layout
- **Tech stack**: the actual stack, not placeholders
- **Commands**: real build/test/run/lint commands discovered in A1 — not `# TODO: fill in`
- **Conventions**: describe patterns actually in use (naming, file organization, test location, commit style from git log)
- **Working in this project**: adapt to the real workflow — if tests exist, reference them; if there's CI, reference it
- **Commit rules**: include the milestone-based commit rules from the template
- **Boundaries**: write the Always / Ask First / Never tiers based on this project's actual conventions
- **Common rationalizations**: include these from the template — they're universal
- **Plan mode**: include this section from the template — it works in any project with `docs/tasks/`

If the project already has a CLAUDE.md, read it first and merge — preserve anything the user already wrote, add what's missing.

---

## Step A4 — Generate architecture overview

Write `docs/architecture/overview.md` by reading the actual code:

- **System purpose**: what the project does (from README + code)
- **Component map**: the major modules/packages and what each is responsible for
- **Data flow**: how data moves through the system (entry → processing → output)
- **Key dependencies**: the major external libraries and why they're used
- **Entry points**: where execution starts (main files, API routes, CLI commands)
- **Key decisions**: architectural patterns in use (e.g. "layered architecture", "event-driven", "monolith", "microservices") — describe what IS there, not what should be

```bash
mkdir -p docs/architecture
```

If `docs/architecture/` already exists, read what's there first and fill gaps rather than overwriting.

---

## Step A4b — Generate diagrams.md (tech and data only)

Write `docs/architecture/diagrams.md` based on the architecture you mapped in A4. Skip for research projects.

1. **Copy the template** from `$CLAUDE_SKILL_DIR/assets/templates/<type>/diagrams.md` as a starting structure (frontmatter, footer, section ordering).

2. **Replace the placeholder Mermaid blocks with real diagrams** based on what the code actually does. The template uses C4 structure (Context → Container → Component → Sequence). Populate the levels the codebase warrants — small projects can collapse Container and Component into one diagram, or skip Container if there's only one deployable unit. Aim for at least:
   - **System Context** (`C4Context`) — the system as one box, who uses it, what external systems / data sources it touches. Source: README, environment config, observed network calls, third-party imports.
   - **Containers** (`C4Container`) — independently deployable / runnable units. Source: process entry points, services in compose files, deployment configs, scheduled jobs. For data projects, include both stages (transforms) and stores (where data lands between stages).
   - **Components** (`C4Component`) — load-bearing modules inside the container a new contributor will touch first. Source: top-level packages and their import graph. Skip for trivial codebases.
   - **Primary runtime flow** (`sequenceDiagram`) — the most important runtime path: startup, first user action, or main data flow end-to-end.
   - **End-to-end data lineage** (`flowchart LR`) — *data projects only*, in addition to the C4 diagrams. Source: dataset directories, transform scripts, model output paths.

3. **Cross-reference**: link to the ADRs (if any exist) that govern each diagrammed flow. If there are no ADRs yet, leave the references for later.

4. **Be honest about uncertainty.** If the code is large or unclear, don't invent a flow — produce a smaller, accurate diagram with a note like "Initial diagram — covers the trader-mode startup path. Scanner mode and reconnect flow not yet drawn."

5. The "Maintaining these diagrams" footer stays as-is.

If `docs/architecture/diagrams.md` already exists, read it first and update / append rather than overwriting — the user may have hand-drawn diagrams worth preserving.

---

## Step A4c — Generate spec/ (tech and data only)

Write the six-file spec at `docs/spec/` based on what the code does today. Skip for research projects.

```bash
mkdir -p docs/spec
```

For each file, copy the template from `$CLAUDE_SKILL_DIR/assets/templates/<type>/spec/` as a structural guide, then **populate it from the code, not the placeholders**:

| File | What to populate from the codebase |
|------|------------------------------------|
| `SPEC.md` | The project summary, top-level invariants (architectural rules enforced in code or by guard scripts), non-goals (visible from what the project deliberately doesn't do — read the README and CLAUDE.md you just wrote) |
| `behaviors.md` | Each major user-facing or scheduled behavior — find them by reading entry points (CLI commands, route handlers, scheduled jobs, public functions). For each: trigger, response, side effects, failure modes. Number sequentially `B-001`, `B-002`, … |
| `architecture.md` | The C4 element catalog: Persons (who uses it), Systems (in-scope + external integrations), Containers (deployable units / pipeline stages and stores), Components (load-bearing modules), and — for data projects — Datasets that flow between stages. Source from the actual deployable artifacts and import graph; the table rows must correspond to things that exist on disk. This file is the tabular pair to `docs/architecture/diagrams.md`; both should describe the same model. |
| `data-model.md` | Persistent stores (DB schemas, file formats), in-memory state (key types and their lock/sharing rules), wire / interchange formats (JSON over HTTP, log formats, exports), data invariants enforced in code |
| `interfaces.md` | CLI surface (every subcommand and flag), HTTP/RPC API endpoints, internal public traits/interfaces (anything other modules depend on), external services called |
| `configuration.md` | Config files (read the parsing code for the schema), env vars (grep for them), runtime flags (cross-reference interfaces.md), secrets (names only, never values) |
| `fitness-functions.md` | Architectural invariants worth enforcing as executable checks. Seed proposals from what the audit revealed: existing layering rules (e.g. observed import patterns), perf-critical paths, security claims, dataset immutability rules. Mark each as `proposed` until the user confirms — and **only seed a row if you can also point to where the rule is currently enforced (or unenforced)**. Don't invent rules. If nothing in the codebase suggests a real invariant, leave the rules table with example rows and a note that the user (or `architect` Mode 4) should fill it in. |

**Reproducibility for data projects:** read `experiments/configs/` and `experiments/results/` if they exist. The `configuration.md` reproducibility contract should reflect what the project actually records — and call out anything missing as a finding.

**Be honest about uncertainty.** Where the code is clear, populate confidently. Where it's not, leave a clearly-marked TODO with a specific question rather than guessing. Example: `> TODO: confirm whether retry-on-failure behavior is bounded — see <file:line>`. The user can fill these in after review.

**If `docs/spec/` already exists, merge** — preserve anything the user wrote, fill the gaps, flag anything that contradicts the code.

After populating, present a short summary: how many behaviors / entities / interfaces / config keys you documented, and which TODOs need user confirmation.

---

## Step A5 — Create task structure

```bash
mkdir -p docs/tasks/active docs/tasks/backlog docs/tasks/completed
```

For **tech/data projects**, also create test spec tracking:
```bash
mkdir -p docs/tasks/test-specs
```

Copy the coverage tracker template:
```bash
cp "$CLAUDE_SKILL_DIR/assets/templates/tech/coverage-tracker.md" docs/tasks/test-specs/coverage-tracker.md 2>/dev/null || true
```

For **data projects**, also copy the experiment tracker:
```bash
cp "$CLAUDE_SKILL_DIR/assets/templates/data/experiment-tracker.md" docs/tasks/experiment-tracker.md 2>/dev/null || true
```

**Do not pre-populate tasks.** The user will decide what to work on next. The structure is there so plan mode and the task-executor can work.

---

## Step A6 — Copy hooks and agents

```bash
COMMON_DIR="$CLAUDE_SKILL_DIR/assets/templates/common"
TEMPLATE_DIR="$CLAUDE_SKILL_DIR/assets/templates/<type>"
mkdir -p .claude/scripts .claude/agents

# Settings (type-specific — includes hook config)
cp "$TEMPLATE_DIR/.claude/settings.json" .claude/settings.json

# Universal hook scripts (all project types)
cp "$COMMON_DIR/.claude/scripts/"*.py .claude/scripts/

# Tech/data-only hook scripts (config-protection, protect-checkout, edit-tracker, batch-format-typecheck)
if [ "<type>" != "research" ]; then
  TECH_DIR="$CLAUDE_SKILL_DIR/assets/templates/tech"
  cp "$TECH_DIR/.claude/scripts/"*.py .claude/scripts/
fi

# Agents
cp "$TEMPLATE_DIR/.claude/agents/"*.md .claude/agents/
```

For **tech/data projects**, this copies the universal hooks plus the tech-only hooks (config-protection, protect-checkout, edit-tracker, batch-format-typecheck, spec-coverage-check, scope-drift-summary, detect-smoke-tests, check-fitness) and 5 agents (task-executor, architect, code-reviewer, security-auditor, spec-verifier). For **research projects**, this copies the universal hooks and only task-executor.

Substitute `<type>` with `tech`, `data`, or `research` based on A2.

If `.claude/settings.json` already exists, **merge** — preserve existing permissions and hooks, add the new ones.

These copied files are tracked in `.claude/skill-manifest.json` (written in Step 3e of the main skill flow) so they can be synced when the skill is updated later. The manifest is written after A8 completes (which runs Step 3, including 3e).

---

## Step A7 — Detect models and configure agents

Run the model detection from Step 3d of the main skill flow:

1. List models accessible in the current session
2. Map tiers to concrete model identifiers (fast/balanced/deep)
3. Update `.claude/agents/task-executor.md` with the best fast-tier model
4. Report the mapping to the user

---

## Step A8 — Recommend tooling

Run Step 3 of the main skill flow (3a through 3d) using the project context gathered in A1–A2. This adds recommended skills, hooks, and agents to CLAUDE.md, and offers to create additional agent files.

---

## Step A9 — Commit

```bash
git add CLAUDE.md docs/ .claude/
git diff --cached --quiet || git commit -m "chore: add project docs, spec, task structure, and Claude Code tooling"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

Note: `.claude/skill-manifest.json` is committed here as part of `.claude/` — it was written during Step 3e (called via A8). The `docs/spec/` and `docs/architecture/diagrams.md` files are **not** in the manifest because they're populated from the user's codebase, not copied verbatim from templates — they're project content from day one.

---

## What this does NOT do

- **Does not restructure existing source code** — files stay where they are
- **Does not create a Docker setup** — the project already has its own environment
- **Does not initialize git** — the project is already tracked
- **Does not create a README from scratch** — if one exists, it's left alone; CLAUDE.md is the new addition
- **Does not create starter code** — the code already exists
