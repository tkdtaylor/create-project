# create-project

A Claude Code skill that scaffolds new projects with opinionated structure, isolated Docker workspaces, and Claude-specific tooling. Installed to `~/.claude/skills/create-project/`.

## Project structure

```
SKILL.md                     <- entry point: interview, routing, tooling config (Step 1-3)
references/                  <- step-by-step setup guides and catalogs
  tech-project.md              T1-T8: technical project setup
  data-project.md              D1-D8: data/ML project setup
  research-project.md          R1-R7: research project setup
  adopt-existing.md            A1-A9: existing codebase adoption
  sync-skills.md               S1-S5: skill sync with three-way merge
  tooling.md                   skills, hooks, agents, MCPs catalog
  framework-snippets.md        stack-specific CLAUDE.md convention snippets
assets/
  templates/
    common/.claude/scripts/    9 universal hook scripts (all project types)
    tech/                      tech templates, settings, agents, 3 tech-only hooks
    data/                      data templates, settings, agents (hooks from common/ + tech/)
    research/                  research templates, settings, agents (hooks from common/)
  base/                        shared Docker base images (Dockerfiles + entrypoints)
evals/evals.json             3 test cases with assertions
```

Key design: `common/` holds hooks shared across all types. `tech/` holds hooks only for code projects (config-protection, edit-tracker, batch-format-typecheck). `data/` and `research/` have no scripts of their own — they pull from `common/` and (for data) `tech/`.

## How it works

1. **SKILL.md** routes to the right reference file based on project type or sync request
2. **Reference files** contain step-by-step instructions that Claude follows
3. **Templates** are copied into scaffolded projects with `{{PLACEHOLDER}}` substitution
4. **Hook scripts** are copied as-is (no placeholders) and tracked via `.claude/skill-manifest.json`

## Conventions

- Hook scripts are Python 3 — they read JSON from stdin, exit 0 (allow), 2 (block), or print JSON to stdout/stderr
- All hook scripts import `_hook_utils.check_gate(__file__, "<profile>")` for profile gating
- Profile levels: `minimal` (safety), `standard` (workflow), `strict` (formatting/notifications)
- Template placeholders: `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}`, `{{TECH_STACK}}`, `{{DATE}}`
- Files listed in the template tables of reference docs must exist in the corresponding template dir
- The manifest table in SKILL.md (Step 3e) must list every file that gets copied as-is

## Working in this project

- When adding a new hook: create in `common/` (if universal) or `tech/` (if code-only), add to all relevant `settings.json` files, add to the template tables in reference docs, add to SKILL.md manifest table, update README repo structure tree
- When modifying an existing hook: edit the single canonical copy — no duplication to sync
- When adding a template file: add to the template table in the relevant reference doc
- When changing placeholder conventions: update all three project reference files
- Test with `evals/evals.json` assertions after structural changes

## Boundaries

### Always
- Keep hook scripts in one canonical location (common/ or tech/) — never duplicate across template dirs
- Update all three project references (tech/data/research) when changing shared conventions
- Update README repo structure tree when adding/removing files
- Keep the SKILL.md manifest table in sync with actual template files

### Ask first
- Adding new hook lifecycle events (changes all settings.json files)
- Changing the template directory layout
- Modifying the skill sync manifest format

### Never
- Duplicate hook scripts across template directories — use common/ or tech/
- Add Docker or complex dependencies to the skill itself — it should stay installable via `cp` or `git clone`
- Edit `.claude/settings.local.json` — that's the user's accumulated permissions
