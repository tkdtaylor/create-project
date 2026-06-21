# create-project — Agent briefing (canonical)

This is the **canonical, harness-neutral briefing** for the create-project repo. It
is the single source of truth for project context, structure, conventions, the
working rules, and the load-bearing process rules every agent must follow when
working on this repo.

Every coding-agent harness loads this file:

- **Codex** auto-loads `AGENTS.md` (this file).
- **Antigravity / Gemini** load it via `GEMINI.md` (a symlink to this file).
- **Claude Code** loads `CLAUDE.md`, which imports this file (`@AGENTS.md`) and adds
  the Claude-specific mechanics (skill packaging, slash commands).

Keep this file harness-neutral. Anything that only one harness understands belongs
in that harness's layer (`CLAUDE.md` for Claude Code), not here.

## What this is

create-project is a **Claude Code skill that scaffolds new projects** with
opinionated structure, isolated Docker workspaces, and Claude-specific tooling. It
also adopts existing codebases into the same workflow, syncs globally installed
skills, and audits projects for documentation/spec/diagram drift. Installed to
`~/.claude/skills/create-project/`.

This repo is the **skill source**. The `assets/templates/` directory holds the
starters that get copied into scaffolded projects — it is *product*, not this repo's
own configuration. Editing template behavior is different from editing how an agent
works on this repo.

## Project structure

```
SKILL.md                     <- entry point: Step 0 mode routing, interview, tooling config (Step 1-3)
commands/                    <- slash commands (copied to ~/.claude/commands/ at install)
  cp-init.md                   /cp-init — scaffold new or adopt existing (mode=init)
  cp-sync.md                   /cp-sync — sync skills + project artifacts (mode=sync)
  cp-fix-drift.md              /cp-fix-drift — audit for drift and apply fixes (mode=fix-drift)
references/                  <- step-by-step setup guides and catalogs
  tech-project.md              T1-T8: technical project setup
  data-project.md              D1-D8: data/ML project setup
  research-project.md          R1-R7: research project setup
  adopt-existing.md            A1-A9: existing codebase adoption (incl. spec/diagram generation)
  sync-skills.md               S1-S5: skill sync with three-way merge
  tooling.md                   skills, hooks, agents, MCPs catalog
  framework-snippets.md        stack-specific CLAUDE.md convention snippets
  fitness-functions.md         per-stack catalog of fitness-function tools (import-linter, dep-cruiser, ArchUnit, k6, etc.)
assets/
  templates/
    common/                    shared starters for all/most project types
      .claude/scripts/         12 universal hook scripts (+ _hook_utils.py shared module)
      scripts/                 check-task-state.sh, start-task.sh, finish-task.sh (all types) + verify-worktree-isolation.sh (tech/data)
      agent-rules.md           starter retro log (tech/data, paired with inject-retros.py)
    tech/                      tech templates incl. C4 diagrams.md, spec/ (7 files incl. architecture.md and fitness-functions.md), settings, agents, tech-only hooks (incl. check-fitness.py + auto-cleanup-merge.py), the backlog runner (.claude/backlog-playbook.md + .claude/commands/backlog-*.md — data pulls these from tech), conditional RELEASE_CHECKLIST.md / CONTRIBUTING.md
    data/                      data templates incl. C4 diagrams.md, spec/ (7 files incl. architecture.md and fitness-functions.md), settings, agents (hooks from common/ + tech/)
    research/                  research templates, settings, agents (hooks from common/)
  base/                        shared Docker base images (Dockerfiles + entrypoints)
evals/evals.json             3 test cases with assertions
```

Key design: `common/` holds hooks, scripts, and starter content shared across all
types. `tech/` holds hooks only for code projects (config-protection, edit-tracker,
batch-format-typecheck, check-fitness, etc.). `data/` pulls from `common/` + `tech/`.
`research/` pulls from `common/` only. No script or starter file is duplicated across
template type-dirs — they live in `common/` once.

**Spec and diagrams (in scaffolded projects):** tech and data templates ship
`diagrams.md` (C4-structured Mermaid — Context/Container/Component + sequence/lineage
flows) and `spec/` (SPEC + behaviors + architecture + data-model + interfaces +
configuration + fitness-functions) as the **authoritative current-state snapshot** of
generated projects. These are dual-natured: outputs of every task that changes
externally-visible state, *and* inputs to onboarding, drift checks, and codebase
regeneration. They live at `docs/architecture/diagrams.md` and `docs/spec/` in
scaffolded projects. The `spec/architecture.md` file is the *tabular* C4 element
catalog that pairs with the *visual* diagrams. The `spec/fitness-functions.md` file is
the declarative list of executable architectural invariants (run via `make fitness`).
Research projects do not get them (the outline is the spec equivalent). The `architect`
agent has four modes: design review, ADR drafting, drift audit, and fitness-function
proposal.

## How it works

1. **Slash commands** (`commands/cp-*.md`) invoke the skill with an explicit `mode=`
   token; they install to `~/.claude/commands/`
2. **SKILL.md** Step 0 routes deterministically on the mode token; otherwise falls
   back to phrase-matching, then the interview
3. **Reference files** contain step-by-step instructions that the agent follows
4. **Templates** are copied into scaffolded projects with `{{PLACEHOLDER}}`
   substitution
5. **Hook scripts** are copied as-is (no placeholders) and tracked via
   `.claude/skill-manifest.json`

## Conventions

- Hook scripts are Python 3 — they read JSON from stdin, exit 0 (allow), 2 (block),
  or print JSON to stdout/stderr
- All hook scripts import `_hook_utils.check_gate(__file__, "<profile>")` for profile
  gating
- Profile levels: `minimal` (safety), `standard` (workflow), `strict`
  (formatting/notifications)
- Template placeholders: `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}`,
  `{{TECH_STACK}}`, `{{DATE}}`
- Files listed in the template tables of reference docs must exist in the
  corresponding template dir
- The manifest table in SKILL.md (Step 3e) must list every file that gets copied
  as-is

## Working in this project

- When adding a new hook: create in `common/` (if universal) or `tech/` (if
  code-only), add to all relevant `settings.json` files, add to the template tables in
  reference docs, add to SKILL.md manifest table, update README repo structure tree
- When modifying an existing hook: edit the single canonical copy — no duplication to
  sync
- When adding a template file: add to the template table in the relevant reference doc
- When changing placeholder conventions: update all three project reference files
- When adding a new spec sub-file (e.g. `interfaces-protocol.md`): add to both tech
  and data templates if it applies to both, update the table in `spec/SPEC.md`, update
  the template tables in `tech-project.md` / `data-project.md`, update the README repo
  structure tree
- When adding or renaming a slash command: add/rename the `commands/cp-*.md` file, add
  its `mode=` token to the SKILL.md Step 0 routing table, and update the README
  slash-command table + repo tree. The `mode=` token must match a Step 0 row or
  routing silently falls through to phrase-matching.
- The **project-template** slash commands (the `/backlog-*` runner) live in
  `assets/templates/tech/.claude/commands/` with shared logic in
  `assets/templates/tech/.claude/backlog-playbook.md` — tech and data only (data pulls
  from `tech/`, never a second copy). When changing them: edit the single tech copy,
  and keep the SKILL.md manifest table, both reference template tables (tech + data's
  "From tech/"), the sync-skills managed list, and the README repo tree in sync.
- `finish-task.sh` is the verified task-closure partner to `start-task.sh` (both in
  `common/scripts/`, all types). It merges + deletes the branch + removes the worktree
  and exits non-zero if anything is left — the backlog playbook and the general task
  lifecycle call it instead of a bare `git merge`.
- Test with `evals/evals.json` assertions after structural changes

## Load-bearing process rules

These are the rules that exist specifically to stop a preventable mistake. The
essentials, inlined so they reach you regardless of which harness loaded this file:

- **Commit after every milestone — now, not "after the next change too."** Batched
  commits are impossible to untangle. One logical change, one commit.
- **Test/verify before declaring done.** For structural changes, run the
  `evals/evals.json` assertions; do not call a change complete on inspection alone.
  If there is a spec or test for the area you touched, satisfy it — "too small to
  test" is not a valid exception.
- **Never work directly on the default branch when a task warrants isolation.** Put
  task work on its own branch (`task/NNN-<slug>` or a worktree); reserve direct `main`
  commits for genuine standalone doc/config fixes (mark them `[allow-main]`). When a
  worktree is created, your **next command must `cd` into it** — editing the parent
  repo while believing you're isolated is the silent failure.
- **Never `git checkout -- <path>` over uncommitted work.** It silently overwrites
  and the reflog cannot recover it. Use `git stash`, `git worktree add <ref>`, or
  `git diff <ref> -- <path>` / `git show <ref>:<path>` to compare instead.
- **Git status must be clean before declaring a task complete.** `git status` must
  report `nothing to commit, working tree clean`. The common miss: `cp` instead of
  `git mv` when moving a file leaves the original undeleted.
- **Keep the canonical-copy invariant.** Hook scripts and starter files live in one
  place (`common/` or `tech/`) — never duplicate across template dirs. A change that
  needs to reach two type-dirs is a sign the file belongs in `common/`.
- **Keep cross-references in sync in the same change.** Adding/removing/renaming a
  template file, hook, spec sub-file, or slash command means updating every table that
  lists it (SKILL.md manifest, reference template tables, README repo tree) in the
  same commit. A stale table is a silent product bug.

## Boundaries

### Always
- Keep hook scripts in one canonical location (`common/` or `tech/`) — never duplicate
  across template dirs
- Update all three project references (tech/data/research) when changing shared
  conventions
- Update README repo structure tree when adding/removing files
- Keep the SKILL.md manifest table in sync with actual template files
- Test with `evals/evals.json` assertions after structural changes

### Ask first
- Adding new hook lifecycle events (changes all settings.json files)
- Changing the template directory layout
- Modifying the skill sync manifest format

### Never
- Duplicate hook scripts across template directories — use `common/` or `tech/`
- Add Docker or complex dependencies to the skill itself — it should stay installable
  via `cp` or `git clone`
- Edit `.claude/settings.local.json` — that's the user's accumulated permissions
- Force push or rewrite published git history
