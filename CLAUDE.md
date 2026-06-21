# create-project — Claude Code layer

The canonical, harness-neutral briefing for this repo is **`AGENTS.md`**. Read it
first — it holds project context, structure, conventions, the working rules,
boundaries, and the load-bearing process rules. This file adds only what is
**specific to Claude Code** (the skill packaging and slash commands).

@AGENTS.md

---

Everything below is Claude Code-specific and supplements `AGENTS.md`.

## Claude Code packaging

create-project *is* a Claude Code skill. Its Claude-specific surfaces:

- **The skill itself** installs to `~/.claude/skills/create-project/`. `SKILL.md` is
  the entry point Claude Code loads when the skill is invoked.
- **Slash commands** in `commands/cp-*.md` install to `~/.claude/commands/`
  (`/cp-init`, `/cp-sync`, `/cp-fix-drift`). Each invokes the skill with an explicit
  `mode=` token that `SKILL.md` Step 0 routes on.
- **Scaffolded-project tooling** under `assets/templates/` (hooks, `.claude/agents/`
  subagents, `.claude/settings.json`, the `/backlog-*` runner) is Claude Code
  tooling that gets copied *into* the projects this skill creates — it is product, not
  this repo's own configuration.

When working on this repo, the `AGENTS.md` process rules govern; the items above are
just the Claude-specific shapes of the things `AGENTS.md` describes neutrally.
