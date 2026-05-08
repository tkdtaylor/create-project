# Audit project

Runs after a round of tasks (or before a release) to verify the project's docs, manifests, diagrams, and README all still accurately describe the current code state. The audit is **read-only by default** — it produces a punch list; the user decides what to apply.

## When to invoke

Trigger phrases: *"audit my project"*, *"audit the docs"*, *"drift check"*, *"are docs up to date"*, *"check for drift"*, *"project audit"*, *"post-task audit"*.

Use this when:
- A round of tasks just completed and you want to confirm nothing slipped through
- Before tagging a release (pairs with `RELEASE_CHECKLIST.md`)
- After a refactor that touched multiple modules
- When the spec or diagrams haven't been touched in a while

## How it works

Five focused sub-agents, each with a tight brief and **read-only** access. Layers 1–4 run in parallel; Layer 5 (README freshness) runs after them because it needs their findings as context. The main session aggregates and presents results.

**Do NOT pass `isolation: "worktree"` on these dispatches.** A worktree checks out the last committed state, which means uncommitted changes (the most common reason an audit is run after a round of tasks) are invisible to the sub-agents. Read-only audits don't need the worktree's race-protection — the agents can't pollute main if they don't write. Run the audit against the working tree directly.

```
Layer 1: Inventory + cross-refs       ─┐
Layer 2: Hook wiring + stale numbers   ├─ parallel ─┐
Layer 3: Spec drift (architect mode)   │            │
Layer 4: Fitness rows ↔ Make targets  ─┘            ├─→ Layer 5: README freshness ─→ Aggregator
                                                    │
```

## Step AU1 — Gather context

Read `.claude/skill-manifest.json` to learn project type. If absent, infer from directory structure (presence of `src/`, `data/`, `docs/spec/`, etc.). Note whether the project has a `Makefile`, a `docs/spec/fitness-functions.md`, and a `.claude/agents/architect.md` — these gate which layers are useful.

Run `scripts/verify-worktree-isolation.sh` is unnecessary here (no agents have run yet). Continue.

## Step AU2 — Dispatch layers 1–4 in parallel

Send all four agent calls in **one message**, with each prompt opening with "Read-only audit. Do not modify any files." Do NOT set `isolation: "worktree"` — the agents need to see the current working tree (uncommitted edits included) for the audit to be useful. Use `subagent_type: "general-purpose"` unless the project has a more specific auditor agent.

### Layer 1 — Inventory + cross-references

```
Read-only audit. Do not modify any files.

Verify the project's file inventory is consistent with how it's documented:

1. Every file referenced by a manifest, table, or copy instruction in
   .claude/skill-manifest.json, README.md, CLAUDE.md, or docs/spec/* must
   exist on disk. Flag missing files.

2. Every file in directories the skill manages (.claude/scripts/,
   .claude/agents/, scripts/, docs/spec/, docs/architecture/) should be
   referenced somewhere it would be discovered. Flag orphans the user
   may have forgotten.

3. Every markdown link in README.md, CLAUDE.md, and docs/architecture/*.md
   that points to a relative path must resolve. Flag broken links.

4. Every TC-NNN-XX marker cited in docs/spec/* should be findable in
   tests/ or in the test-spec it came from. Flag dangling markers.

Output a punch list:
- One bullet per finding
- Each bullet: file:line — what's wrong — recommended fix
- Order by impact (broken refs first)
- Under 300 words total. Skip sections with no findings.
```

### Layer 2 — Hook wiring + stale numbers

```
Read-only audit. Do not modify any files.

Verify hook plumbing and number-citations match reality:

1. Every script in .claude/scripts/ should have at least one entry in
   .claude/settings.json. Flag orphans (script exists, never invoked).

2. Every command path in .claude/settings.json should resolve to a real
   script. Flag broken references (settings entry → missing script).

3. Cited numbers in prose are dangerous when they drift. Grep CLAUDE.md,
   README.md, SKILL.md (if present), and references/*.md for patterns
   like "N hooks", "N agents", "N lifecycle events", "N project types".
   Verify each against reality (count files, count settings.json
   invocations, etc.). Flag every stale number with the actual count.

4. The "What it does" or feature list at the top of README.md often
   enumerates capabilities by number — check those too.

Output a punch list with the same format as Layer 1. Under 300 words.
```

### Layer 3 — Spec drift (architect drift-audit mode)

Skip this layer if the project has no `docs/spec/` or no `.claude/agents/architect.md`.

```
Use the architect agent's drift-audit mode (see .claude/agents/architect.md).

Read docs/spec/* and docs/architecture/diagrams.md. For each spec entry
or diagrammed component, verify the current source code under src/ still
reflects what the spec/diagram claims.

For each divergence:
- Which spec file or diagram is stale (file:line range)
- What the code actually does now
- Whether the spec or the code is the right truth (most often: spec is
  stale because someone shipped without updating it)
- Recommended fix: rewrite-spec / rewrite-code / add-ADR

Output a punch list. Order by impact (interface contracts first, then
behaviors, then architecture, then diagrams). Under 400 words.
```

### Layer 4 — Fitness rows ↔ Make targets

Skip this layer if the project has no `docs/spec/fitness-functions.md` or no `Makefile`.

```
Read-only audit. Do not modify any files.

Read docs/spec/fitness-functions.md (the Rules table) and the project
Makefile (every fitness-<id> target).

1. Every F-NNN row in fitness-functions.md should have a fitness-<id>
   target in the Makefile. Flag missing targets.

2. Every fitness-<id> target in the Makefile should appear as an F-NNN
   row in fitness-functions.md. Flag undocumented targets.

3. The `fitness:` umbrella target's prerequisites should match the
   active set of `block`-severity rules from the table. Warn-only or
   tooling-gated targets may legitimately be excluded — flag only
   block-severity rules that are missing from the umbrella.

Output a punch list. Under 200 words.
```

## Step AU3 — Dispatch Layer 5 (README freshness)

After AU2 returns, collect the four punch lists. Dispatch one more agent (no parallelism here; it needs the prior findings as input):

```
Read-only audit. Do not modify any files.

You will receive punch lists from four prior audit layers. Use them as
context — items already flagged elsewhere don't need to be flagged again.

Read README.md in full. Verify each claim it makes:

1. The "What it does" / feature list still matches what the project does
   today. Flag features that no longer exist or capabilities that have
   been added but aren't listed.

2. Install / setup / usage commands still work. Flag stale commands
   (deprecated flags, renamed binaries, removed paths).

3. Example outputs and screenshots are still representative.

4. Version / dependency claims (minimum versions, supported platforms)
   are still accurate.

5. Any section describing a removed feature should be removed or marked
   deprecated.

6. Cross-document references (links to CLAUDE.md, docs/spec/, ADRs) all
   resolve and still describe what the README claims they describe.

The README is the project's front door. It being wrong is a higher-
impact finding than internal-doc drift — order findings accordingly.

Output a punch list. Under 400 words.

Prior layers' findings: <inline the four punch lists from AU2>
```

## Step AU4 — Aggregate

Collect all five punch lists. Group findings by file. Within each file, order by impact:

- **Must-fix** — broken refs, contradictions that mislead a reader, stale code examples a user will copy-paste, security claims that no longer hold
- **Should-fix** — stale numbers, missing manifest rows, spec/code drift, fitness rows without Make targets
- **Probably-fine** — bloat, minor wording, prose that could be tighter

Deduplicate: when two layers flagged the same line, keep the more specific finding.

Render the consolidated report inline in chat:

```
## Project audit — <project-name>

**Scope:** N files reviewed across 5 layers
**Findings:** A must-fix, B should-fix, C probably-fine

### Must-fix

- file.md:42 — <finding> — <recommended fix>
- ...

### Should-fix

- ...

### Probably-fine (your call)

- ...
```

## Step AU5 — Offer to apply

After the report, ask:

> "I see N must-fix and M should-fix items. Want me to apply both batches now? The probably-fine items I'll leave for your call."

If the user says yes:
- Apply must-fix + should-fix in one pass, file by file (smallest blast radius first)
- After each file, run any project-local checks if cheap (`make check` if it's fast; skip otherwise)
- At the end, summarize: which files changed, which findings were applied, which were skipped (and why)
- Do NOT commit automatically — leave the working tree dirty for the user to review and commit. The audit's job ends at "made the changes"; the commit is the user's call.

If the user says no, leave the punch list in chat and skip to "audit complete."

## Notes for the executing agent

- Layers 1–4 must be dispatched in **one message** to actually run in parallel. Don't dispatch them sequentially.
- **No worktrees.** Worktrees check out the last committed state and would hide the user's uncommitted edits — exactly the changes the audit is supposed to verify. Read-only audits don't need worktree protection.
- The layer-5 dispatch needs the prior punch lists inlined into its prompt — do not assume the sub-agent can read prior chat history.
- If a layer returns an empty punch list, surface that as ✅ in the aggregate report (not as missing data).
- The audit is **idempotent** — running it twice in a row should produce the same findings (unless someone else changed files between runs).
- This procedure works in any project type that has the relevant artifacts. For research projects, layers 3 and 4 typically skip (no spec, no Makefile); the audit is still useful for layers 1, 2, and 5.
- Layer 1 also includes a "Layer-1 abort" check in many projects' agent-rules.md retros — but that is for *code-modifying* parallel dispatches, not for read-only audit dispatches. The audit's sub-agents won't have the abort check in their prompts, and that's intentional.
