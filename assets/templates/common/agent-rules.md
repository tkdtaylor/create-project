# Agent rules — rationalizations to refuse and project retros

The retro-injection hook (`.claude/scripts/inject-retros.py`) parses
this file at session start and surfaces entries that match the active
task's spec. The "Common rationalizations" table is loaded as a
fallback when no per-retro keyword match scores high enough.

Add new entries here, not to CLAUDE.md, when work is lost or significant
time is wasted to a preventable mistake. CLAUDE.md is the orientation
document; this file is the growing log of project-specific lessons.

## Common rationalizations

These are excuses agents use to skip steps. Don't fall for them.

| Excuse | Reality |
|--------|---------|
| "I'll commit after the next task too" | No. Commit now. Batched commits are impossible to untangle later. |
| "This task is too small for a test spec" | The spec defines done — without it you're guessing. Write one. |
| "I'll add tests later" | Later never comes. The test spec comes first, always. |
| "These two tasks are related, I'll do them together" | One task, one commit. If it feels too granular, the tasks are scoped correctly. |
| "The architecture doc doesn't need updating" | If you made a non-obvious design decision, write an ADR. |
| "I'll just quickly fix this other thing I noticed" | Stay on your task. Note it for later — don't scope-creep. |
| "I'll update the spec at the end of the day" | No. Spec drift is silent. Update it in the same commit, every time. |
| "The spec already covers this — close enough" | If "close enough" required reading the code to confirm, the spec is wrong. Fix it now. |
| "I'll add a 'previously this was X' note to the spec" | Don't. Rewrite the entry. The ADR carries history; the spec is a snapshot. |

## Failure modes (starter set)

These anti-patterns have been observed across multiple projects. When any apply, **stop and report** — do not rationalize and ship. Add project-specific entries below as your own retros accumulate; each new entry should name the concrete incident in a "Retro source:" line so future-you can reconstruct what happened.

### No self-justification of new warnings

If your change adds a new linter or typecheck warning compared to the baseline (the pre-change warning count), you must either fix the root cause or stop and report it as a blocker. "Acceptable false positive," "I'll clean it up later," and "the warning is wrong" are not labels you get to apply unilaterally — they are the agent rationalizing around a rule. If a warning is genuinely wrong, the fix is an explicit suppression (e.g. `#[allow(lint_name)]`, `# noqa`, `// eslint-disable-next-line`) with a comment explaining why, not silence.

### No smoke tests where the spec asks for assertions

If a test spec describes a specific assertion ("should return `Some(2)` when the range is unqualified"), the test you write must actually verify that assertion. A test that calls the method and checks it doesn't panic is a smoke test, not a real test. If constructing the state needed to verify the assertion is non-trivial, that is a blocker — stop and report. Do not downgrade the test to a smoke test and tell yourself it's "close enough."

### Git status must be clean after the commit

Run `git status` as your last action before declaring a task complete. It must report `nothing to commit, working tree clean`. If it shows staged, unstaged, or untracked files, you missed something — go back and fix it. The common failure is copying a task file from `backlog/` to `completed/` with `cp` instead of `git mv`, which leaves the original undeleted and the new copy unstaged.

### No dead-code delegates

A delegate method that only exists to preserve a pre-refactor API surface and has no non-test callers is a backwards-compat shim. The rule against backwards-compat shims is already in the "Never" boundaries — this is the refactor-specific version. The correct fix is to update the call sites to use the new path, not to preserve the old path with a thin wrapper.

### Parallel agent dispatches must enforce worktree isolation in two layers

When dispatching ≥2 code-modifying agents in one message, setting `isolation: "worktree"` on the Agent tool is **necessary but not sufficient**. The Claude Code harness can fail to provision a worktree — when that happens the agent reads the parent repo's `pwd`, edits files there, and commits to whatever branch the parent is on (frequently `main`), racing every other concurrent agent and any concurrent Claude session.

**Layer 1 — prompt-level fail-fast.** Every dispatch prompt must include an abort check at the top:

```
BEFORE doing any work, run `pwd`. If the path does NOT contain
'.claude/worktrees/agent-' (i.e. the harness failed to provision
a worktree for this run), STOP IMMEDIATELY. Do not edit any files,
do not run any build/test commands, do not commit. Report back:
"ABORT: no worktree provisioned, parent repo at <pwd>". The parent
session will retry the dispatch.
```

**Layer 2 — post-dispatch verification.** After every parallel dispatch completes, run `scripts/verify-worktree-isolation.sh <agent-id> [<agent-id> ...]` and check that each agent has a `worktree-agent-<id>` branch (and that no recent commit on `main` carries the agent's task signature). For any agent that bypassed isolation, `git revert` its commit and re-dispatch with the Layer-1 preamble in place.

**Why both layers:** Layer 1 stops the agent from polluting main if it can detect the missing worktree. But the agent's introspection isn't always trustworthy — Layer 2 is the parent-side audit that catches what slips through. A single layer is not enough: in a real incident, an agent that thought it was inside its worktree ran `git checkout --` to "restore main repo to clean state," which would have wiped foreign uncommitted work from a concurrent session if any had been present.

### No `git checkout -- <path>` over uncommitted work

When you want to compare current behavior to a prior commit (linter baseline, test count, file size, anything), use `git stash` first or `git worktree add` for the comparison. **Never** reach for `git checkout HEAD -- <path>` or `git checkout <ref> -- <path>` while you have uncommitted changes you intend to keep. The checkout silently overwrites those changes with the prior commit's content, the only recovery path is the reflog (which does not capture uncommitted blobs), and `git fsck --unreachable` can return ambiguous results that look like recoverable work but aren't.

This rule applies to **all** path-checkouts, not just `src/`. `git checkout HEAD -- .` is the same hazard at full-tree scale.

The right tools for "compare to prior state":
- `git stash` + work + `git stash pop` — safe but easy to forget the pop
- `git worktree add ../baseline <ref>` — strongest, forces the comparison into a different directory
- `git diff <ref> -- <path>` / `git show <ref>:<path>` — for read-only comparisons, no checkout needed at all
