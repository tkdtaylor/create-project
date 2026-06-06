# Skill Sync

Follow these steps when the user asks to sync or update skills. Triggered by phrases like "sync my skills", "update my skills", "make sure my skills are up to date", "pull latest skill changes", or "update project hooks/agents".

This covers two independent scopes that can run together or separately:

1. **Global skill sync** — update skills installed at `~/.claude/skills/` from their upstream source (git pull)
2. **Project artifact sync** — update managed files (hooks, agents, settings) in the current project from the globally installed skill's templates

---

## Step S1 — Determine scope

Check what the user is asking for:

| User intent | Run |
|-------------|-----|
| "sync my skills" / "update my skills" / "make sure everything is up to date" | Both scopes |
| "update create-project" / "pull the latest skill" | Global skill sync only |
| "sync my project files" / "update hooks" / "update agents" | Project artifact sync only |
| "check for updates" | Both scopes, report only (don't apply changes) |

If unclear, default to both scopes.

---

## Step S2 — Sync global skills

### 2a — Inventory installed skills

```bash
ls ~/.claude/skills/ 2>/dev/null || echo "No skills directory"
```

For each skill directory, read the `SKILL.md` frontmatter to get the name and description:

```bash
for dir in ~/.claude/skills/*/; do
  [ -d "$dir" ] || continue
  name=$(head -5 "$dir/SKILL.md" 2>/dev/null | grep '^name:' | sed 's/name: *//')
  echo "$name → $dir"
done
```

### 2b — Check for upstream updates

For each skill directory, check if it's a git repo with an upstream:

```bash
for dir in ~/.claude/skills/*/; do
  [ -d "$dir" ] || continue
  skill_name=$(basename "$dir")
  if [ -d "$dir/.git" ]; then
    git -C "$dir" fetch --quiet 2>/dev/null
    LOCAL=$(git -C "$dir" rev-parse HEAD 2>/dev/null)
    REMOTE=$(git -C "$dir" rev-parse @{u} 2>/dev/null || echo "no-upstream")
    if [ "$REMOTE" = "no-upstream" ]; then
      echo "$skill_name: git repo but no upstream tracking branch"
    elif [ "$LOCAL" = "$REMOTE" ]; then
      echo "$skill_name: up to date"
    else
      BEHIND=$(git -C "$dir" rev-list --count HEAD..@{u} 2>/dev/null || echo "?")
      echo "$skill_name: $BEHIND commit(s) behind upstream"
      git -C "$dir" log --oneline "HEAD..@{u}"
    fi
  else
    echo "$skill_name: not a git repo — reinstall from source to update"
  fi
done
```

### 2c — Apply updates

For each skill with updates available:

```bash
git -C "$dir" pull --ff-only
```

If fast-forward fails (diverged history), report the error and tell the user:

> Skill `<name>` has diverged from upstream. To update manually:
> ```bash
> cd ~/.claude/skills/<name>
> git pull --rebase
> ```

If the skill is not a git repo, tell the user the current install command:

> Skill `<name>` is not a git repo — to update, reinstall from source:
> ```bash
> rm -rf ~/.claude/skills/<name> && cp -r /path/to/source ~/.claude/skills/<name>
> ```

### 2d — Report

Present a summary table:

```
Global skills:
  create-project — updated (3 commits pulled)
  code-scanner — up to date
  simplify — not a git repo (reinstall to update)
```

### 2e — Refresh global slash commands

The create-project skill ships slash commands in `commands/` that register from `~/.claude/commands/`. After pulling skill updates, copy them so new or changed commands take effect:

```bash
if ls ~/.claude/skills/create-project/commands/cp-*.md >/dev/null 2>&1; then
  mkdir -p ~/.claude/commands
  cp ~/.claude/skills/create-project/commands/cp-*.md ~/.claude/commands/
  echo "Refreshed global commands: $(ls ~/.claude/skills/create-project/commands/cp-*.md | xargs -n1 basename | tr '\n' ' ')"
fi
```

Mention in the report which commands were refreshed (e.g. `cp-init`, `cp-sync`, `cp-fix-drift`).

---

## Step S3 — Sync project artifacts

This step syncs files in the current project that were originally copied from a skill's templates (hooks, agents, settings). It uses `.claude/skill-manifest.json` to track what was installed and detect changes on both sides.

### 3a — Read the manifest (or enter first-sync mode)

```bash
cat .claude/skill-manifest.json 2>/dev/null || echo "NOT_FOUND"
```

**If the manifest exists:** read it and proceed to 3b in *manifest-tracked* mode.

**If the manifest does NOT exist:** the project was set up before manifest tracking was added. Enter **first-sync mode**: we cannot tell whether the user has edited any of the managed files since install, so the safe default is to *intelligently merge* every file rather than overwrite. Do NOT pre-generate a baseline manifest with `installed_hash == current_hash` — that would mask any existing local edits and let the next upstream change silently overwrite them. The manifest is written at S4 from post-sync hashes.

1. Check for create-project artifacts:
```bash
ls .claude/scripts/restructure-plan.py .claude/scripts/protect-secrets.py .claude/scripts/post-compact.py .claude/agents/task-executor.md 2>/dev/null
```

2. If found, infer the project type:
```bash
if [ -d "data" ] && [ -d "experiments" ]; then
  PROJECT_TYPE="data"
elif [ -d "sources" ] && [ -d "notes" ]; then
  PROJECT_TYPE="research"
else
  PROJECT_TYPE="tech"
fi
echo "Detected project type: $PROJECT_TYPE"
```

3. Locate the global skill:
```bash
SKILL_DIR=$(ls -d ~/.claude/skills/create-project 2>/dev/null)
TEMPLATE_DIR="$SKILL_DIR/assets/templates/$PROJECT_TYPE"
```

4. Build the managed file list. These are the files the create-project skill copies verbatim into projects. Note that universal hooks come from `assets/templates/common/`, tech-only hooks from `assets/templates/tech/`, and everything else from `assets/templates/<type>/`:

**All project types (settings from `<type>/`, hooks from `common/`):**
- `.claude/settings.json` → `assets/templates/<type>/.claude/settings.json`
- `.claude/scripts/_hook_utils.py` → `assets/templates/common/.claude/scripts/_hook_utils.py`
- `.claude/scripts/protect-secrets.py` → `assets/templates/common/.claude/scripts/protect-secrets.py`
- `.claude/scripts/block-no-verify.py` → `assets/templates/common/.claude/scripts/block-no-verify.py`
- `.claude/scripts/restructure-plan.py` → `assets/templates/common/.claude/scripts/restructure-plan.py`
- `.claude/scripts/pre-compact.py` → `assets/templates/common/.claude/scripts/pre-compact.py`
- `.claude/scripts/post-compact.py` → `assets/templates/common/.claude/scripts/post-compact.py`
- `.claude/scripts/periodic-checkpoint.py` → `assets/templates/common/.claude/scripts/periodic-checkpoint.py`
- `.claude/scripts/strategic-compact.py` → `assets/templates/common/.claude/scripts/strategic-compact.py`
- `.claude/scripts/desktop-notify.py` → `assets/templates/common/.claude/scripts/desktop-notify.py`
- `.claude/scripts/inject-retros.py` → `assets/templates/common/.claude/scripts/inject-retros.py`
- `.claude/scripts/no-commit-on-main.py` → `assets/templates/common/.claude/scripts/no-commit-on-main.py`
- `.claude/scripts/session-lock.py` → `assets/templates/common/.claude/scripts/session-lock.py`
- `.claude/scripts/session-lock-touch.py` → `assets/templates/common/.claude/scripts/session-lock-touch.py`
- `.claude/agents/task-executor.md` → `assets/templates/<type>/.claude/agents/task-executor.md`
- `scripts/check-task-state.sh` → `assets/templates/common/scripts/check-task-state.sh` (mode 755)
- `scripts/start-task.sh` → `assets/templates/common/scripts/start-task.sh` (mode 755)

**tech and data only (hooks from `tech/`, agents from `<type>/`):**
- `.claude/scripts/config-protection.py` → `assets/templates/tech/.claude/scripts/config-protection.py`
- `.claude/scripts/protect-checkout.py` → `assets/templates/tech/.claude/scripts/protect-checkout.py`
- `.claude/scripts/edit-tracker.py` → `assets/templates/tech/.claude/scripts/edit-tracker.py`
- `.claude/scripts/batch-format-typecheck.py` → `assets/templates/tech/.claude/scripts/batch-format-typecheck.py`
- `.claude/scripts/spec-coverage-check.py` → `assets/templates/tech/.claude/scripts/spec-coverage-check.py`
- `.claude/scripts/scope-drift-summary.py` → `assets/templates/tech/.claude/scripts/scope-drift-summary.py`
- `.claude/scripts/detect-smoke-tests.py` → `assets/templates/tech/.claude/scripts/detect-smoke-tests.py`
- `.claude/scripts/check-fitness.py` → `assets/templates/tech/.claude/scripts/check-fitness.py`
- `.claude/scripts/auto-cleanup-merge.py` → `assets/templates/tech/.claude/scripts/auto-cleanup-merge.py`
- `.claude/agents/architect.md` → `assets/templates/<type>/.claude/agents/architect.md`
- `.claude/agents/code-reviewer.md` → `assets/templates/<type>/.claude/agents/code-reviewer.md`
- `.claude/agents/security-auditor.md` → `assets/templates/<type>/.claude/agents/security-auditor.md`
- `.claude/agents/spec-verifier.md` → `assets/templates/<type>/.claude/agents/spec-verifier.md`
- `scripts/verify-worktree-isolation.sh` → `assets/templates/common/scripts/verify-worktree-isolation.sh` (mode 755; copied for tech/data only)

**Optional agent templates** — only treated as managed if the project's manifest lists them or the file already exists in the project (Step 3d may have installed them):
- `.claude/agents/qa.md` → `assets/templates/<type>/.claude/agents/qa.md` (tech, data)
- `.claude/agents/docs-writer.md` → `assets/templates/<type>/.claude/agents/docs-writer.md` (tech, data)
- `.claude/agents/task-planner.md` → `assets/templates/<type>/.claude/agents/task-planner.md` (tech, data)
- `.claude/agents/dependency-auditor.md` → `assets/templates/tech/.claude/agents/dependency-auditor.md` (tech only; data projects pull from tech)

`docs/architecture/agent-rules.md` is a **starter file** (like CLAUDE.md and `docs/architecture/diagrams.md`) — projects accumulate retro entries there, so sync should never overwrite it. Source: `assets/templates/common/agent-rules.md` (tech and data only — research projects skip). Only offer to seed it if the file is missing entirely.

5. Set `FIRST_SYNC=true` in memory and proceed to 3b. Do not write a manifest yet — it gets written at S4 from post-sync hashes.

Tell the user once, before processing any files:

*"No skill manifest found — I'll merge each managed file rather than overwrite, and show you the diff. After this sync I'll write a manifest so future runs can be more precise. Use `git diff` afterwards to review everything."*

### Manifest format

```json
{
  "create-project": {
    "project_type": "tech",
    "setup_date": "2026-04-09",
    "files": {
      ".claude/settings.json": {
        "template": "assets/templates/tech/.claude/settings.json",
        "installed_hash": "a1b2c3...",
        "template_hash": "a1b2c3..."
      },
      ".claude/scripts/protect-secrets.py": {
        "template": "assets/templates/common/.claude/scripts/protect-secrets.py",
        "installed_hash": "d4e5f6...",
        "template_hash": "d4e5f6..."
      }
    }
  }
}
```

The top-level key is the skill name. Multiple skills can contribute to the same manifest — each manages its own file set independently.

- `template` — relative path within the skill directory to the source template
- `installed_hash` — sha256 of the file as written to the project (after all modifications including model tier updates)
- `template_hash` — sha256 of the source template at install time

### 3b — Compare each managed file

The principle: **make this as easy as possible for the user.** If the manifest tells us a file is genuinely safe to update, just update it. If we can't tell, or both sides changed, perform an intelligent merge that preserves local customizations and apply upstream improvements — show the diff, do not prompt unless the merge identifies an irreconcilable conflict (same line/section, incompatible logic). The user's safety net is `git diff` after the sync, not a prompt during it.

**Manifest-tracked mode** (manifest exists) — for each file, compute two checks:

```bash
# Current state
current_hash=$(sha256sum "$file" 2>/dev/null | cut -d' ' -f1 || echo "MISSING")
current_template_hash=$(sha256sum "$SKILL_DIR/$template_path" 2>/dev/null | cut -d' ' -f1 || echo "MISSING")

# From manifest
installed_hash=<from manifest>
template_hash=<from manifest>

# Classify
user_modified=false
upstream_changed=false
[ "$current_hash" != "$installed_hash" ] && user_modified=true
[ "$current_template_hash" != "$template_hash" ] && upstream_changed=true
```

Classification:

| User modified? | Upstream changed? | Category | Action |
|---------------|-------------------|----------|--------|
| No | No | Up to date | Skip |
| No | Yes | Upstream update | **Apply upstream** — copy template, update manifest, report diff (3c) |
| Yes | No | Local change | **Keep** — user customized, no upstream change |
| Yes | Yes | Both changed | **Merge** — intelligent merge, show diff, prompt only on irreconcilable conflict (3d) |
| File missing | Yes | New upstream | **Offer to add** — new file in template (see 3f) |
| File missing | No | Removed | **Skip** — user deleted it intentionally |

**First-sync mode** (`FIRST_SYNC=true`, no manifest) — we have no `installed_hash` or `template_hash` to compare against, so we cannot trust the (No / Yes) classification. Treat every file the same way:

| Current vs current template | Action |
|-----------------------------|--------|
| Identical | Skip (nothing to do) |
| Differ | **Merge** — intelligent merge (3d), show diff, prompt only on irreconcilable conflict |
| File missing in project | New upstream (see 3f) |

This is the "easy as possible" default for an unknown setup: never overwrite blindly, never prompt unnecessarily, always show what changed.

### 3c — Apply upstream-only updates

**Only reachable in manifest-tracked mode** when the manifest confirms the user hasn't modified the file. In first-sync mode, every divergent file routes through 3d instead.

Capture the diff for the final report, then copy the new template version:

```bash
diff_summary=$(diff -u "$file" "$SKILL_DIR/$template_path" | head -40)
cp "$SKILL_DIR/$template_path" "$file"
```

**Exception — agent files:** before overwriting, read the current `model:` field from the project's agent file. After copying the template, restore the `model:` value so the project's model configuration is preserved. The template update changes the agent's instructions but keeps the model assignment:

```bash
# Before copy: extract model line
current_model=$(grep '^model:' "$file" | head -1)

# Copy template
cp "$SKILL_DIR/$template_path" "$file"

# Restore model
sed -i "s/^model:.*/$current_model/" "$file"
```

Record the file in the sync report (printed once at S5):
```
Updated .claude/scripts/protect-secrets.py — new version from create-project
Updated .claude/agents/task-executor.md — new instructions (model: sonnet preserved)
```

### 3d — Intelligent merge (default for any divergence)

This path runs whenever the file may carry local edits — i.e. the (Yes / Yes) row in manifest-tracked mode and *every* divergent file in first-sync mode. The default is **always merge first, prompt only when the merge identifies an irreconcilable conflict**. The user's safety net is `git diff` after the sync — not a prompt during it.

Procedure:

1. Read the available versions:
   - **current** — the project file as it stands now (may carry local edits)
   - **template** — the new upstream template
   - **base** *(optional, manifest-tracked mode only)* — the prior template the project was synced against. Recover from the skill repo's git history if practical: `git -C "$SKILL_DIR" log --all --pretty=format:%H -- "$template_path" | while read h; do test "$(git -C "$SKILL_DIR" show "$h:$template_path" | sha256sum | cut -d' ' -f1)" = "$template_hash" && echo "$h" && break; done`. If recovery is awkward, skip the base — a two-way merge of *current* against *template*, informed by your understanding of the file's intent, is sufficient. In first-sync mode no base exists.

2. Produce an intelligent merge — not a line-by-line three-way diff, but a content-aware merge that uses your understanding of what the file does:
   - Preserve every local customization that doesn't directly contradict an upstream change
   - Apply every upstream improvement that doesn't directly contradict a local edit
   - For agent files: always preserve the project's `model:` field (extract before merge, restore after)
   - For settings.json: defer to the merge logic in 3e
   - For hook scripts: prefer the upstream control-flow but preserve any local config constants the user has set at the top of the file
   - For task-executor and other workflow agents: prefer upstream when the change is a safety/correctness improvement (e.g., a new pre-stage verification step) — the user is unlikely to want to opt out of those

3. Capture both diffs for the final report — `diff(current, merged)` (what the sync changed) and a one-line summary of the merge intent (e.g. "applied upstream pre-stage verification step; preserved local model: sonnet and custom failure-mode entry"):

```bash
diff_summary=$(diff -u "$file" "$merged_tmp" | head -40)
mv "$merged_tmp" "$file"
```

4. **Only prompt the user if the merge cannot reconcile a region** — i.e. the same line or contiguous block was changed on both sides in incompatible ways. In that case, present:
   - The conflicting region from *current*
   - The conflicting region from *template*
   - Your recommended resolution and why
   - Options: `(a) take my recommendation`, `(b) keep my version`, `(c) take upstream`, `(d) describe the merge you want`

If no conflict region exists, write the merged file and move on. Do not prompt for confirmation just because the file changed — the diff in the S5 report is the confirmation surface.

### 3e — Special handling: settings.json

`.claude/settings.json` contains both skill-managed content (hooks) and user-added content (permissions, custom hooks). **Always merge rather than overwrite**, even for upstream-only updates.

Merge strategy:

1. Read the current project `settings.json` and the new template `settings.json`
2. For the `hooks` section:
   - **Match hooks by their command's script path** (e.g. `.claude/scripts/protect-secrets.py`)
   - Update existing hooks whose script path matches a template hook (template version is newer)
   - Add new hooks from the template that aren't in the project
   - **Preserve** any hooks the user added that aren't in the template
3. For the `permissions` section:
   - **Preserve the user's permissions entirely** — do not modify
   - If the template has new permission entries not present in the project, mention them but don't add automatically
4. Write the merged result

### 3f — Check for new template files

After syncing existing files, check if the skill's templates now include files that weren't in the original manifest:

```bash
SKILL_DIR=~/.claude/skills/create-project
COMMON_DIR="$SKILL_DIR/assets/templates/common"
TEMPLATE_DIR="$SKILL_DIR/assets/templates/$PROJECT_TYPE"
TECH_DIR="$SKILL_DIR/assets/templates/tech"

# Check for new .claude/ files across all template sources
for template_file in \
  "$COMMON_DIR"/.claude/scripts/*.py \
  "$TEMPLATE_DIR"/.claude/scripts/*.py \
  "$TEMPLATE_DIR"/.claude/agents/*.md \
  "$TECH_DIR"/.claude/scripts/*.py; do
  [ -f "$template_file" ] || continue
  # Determine relative output path (strip template dir prefix)
  for prefix in "$COMMON_DIR/" "$TEMPLATE_DIR/" "$TECH_DIR/"; do
    case "$template_file" in "$prefix"*) relative="${template_file#$prefix}"; break;; esac
  done
  # Check if this file is already in the manifest
  # If not, it's a new file from upstream
done
```

For new files found, treat **hook scripts** and **agent files** differently — they are not the same kind of thing:

**Hook scripts** (`.claude/scripts/*.py`) — **auto-add, then report.**
Hook scripts are safety and workflow infrastructure. Their defaults are carefully chosen, they are gated by the `CLAUDE_HOOK_PROFILE` environment variable (so users can mute them without deleting them), and missing hooks usually indicate the project was set up before the hook existed rather than a deliberate choice to exclude it. The cost of auto-adding a hook the user didn't want is low (they can disable it with `CLAUDE_DISABLED_HOOKS=<name>` or remove it from `settings.json`); the cost of *not* adding a safety hook is potentially high. Copy these without asking, then list what was added in the final report.

**Agent files** (`.claude/agents/*.md`) — **offer, do not auto-add.**
Agents are opinionated tooling. An agent that is in the template but not in the project can mean either:
- The user deliberately removed it (respect that), OR
- The user was never offered it during the original setup — either because they set the project up before the agent existed in the skill, or because Step 3d's subtype guidance didn't recommend it for this project type. Absence is not the same as explicit rejection.

Because you cannot distinguish these cases reliably, **always present missing agents as an opt-in list** — do not assume either removal or omission. Present them as:

> *"The create-project skill ships these additional agents that aren't in your project. They weren't necessarily excluded — they may just never have been offered during the original setup. Would you like me to add any?"*

For each missing agent, read the file and present:
- Name, model tier (from the `# model-tier:` comment)
- One-sentence summary of what it does (from the `description:` frontmatter)
- When to invoke it (typical trigger phrase)

Then let the user pick per-agent. Copy only the selected ones, set the `model:` field based on available models (same mapping as Step 3d), and add them to the manifest.

**Settings files and other managed content** — handle per their own rules (settings.json uses the merge logic in Step 3e).

---

## Step S4 — Write or update the manifest and commit

Write `.claude/skill-manifest.json` from post-sync hashes. In manifest-tracked mode this is an update; in first-sync mode this is the first time the manifest gets written, and it now reflects the merged state of every file (so subsequent syncs can use precise classification).

For each managed file present in the project, write:
- `installed_hash` — sha256 of the file as it stands now (post-merge, post-update)
- `template_hash` — sha256 of the template that was synced against in this run

```bash
git add .claude/ scripts/ 2>/dev/null
git diff --cached --quiet || git commit -m "chore: sync skill artifacts from updated templates"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

Tell the user before committing that the next step belongs to them: *"Sync done. Run `git diff HEAD~1` to review every change before pushing — or `git reset --hard HEAD~1` to back the whole sync out."*

---

## Step S5 — Summary

Present a final report listing every project artifact, its action, and (for any file that changed) a short diff summary so the user can review without running diff themselves:

```
Skill sync complete.

Global skills:
  create-project — updated (3 commits)
  code-scanner — up to date

Project artifacts (from create-project):
  .claude/scripts/protect-secrets.py — applied upstream (no local edits)
  .claude/scripts/restructure-plan.py — merged (preserved local CHECKPOINT_INTERVAL=20; applied upstream JSON-output fix)
  .claude/scripts/post-compact.py — up to date
  .claude/settings.json — merged (1 new hook added; user permissions preserved)
  .claude/agents/task-executor.md — merged (applied upstream pre-stage verification step; preserved model: sonnet and local failure-mode entry)
  .claude/agents/architect.md — up to date
  .claude/agents/code-reviewer.md — kept local version (no upstream change)
  .claude/agents/security-auditor.md — up to date
  scripts/check-task-state.sh — added (new file from upstream)
  NEW: .claude/agents/qa.md — offered, user accepted

Review with:  git diff HEAD~1
Back out with: git reset --hard HEAD~1
```

If no changes were found in either scope, say: *"Everything is up to date — no changes needed."*

Action vocabulary used in the report (use these consistently):

| Term | Meaning |
|------|---------|
| `up to date` | No diff between project, manifest, and template |
| `applied upstream` | Manifest confirmed no local edits; template change copied in (3c) |
| `merged` | Intelligent merge ran; both sides had something — resolved without prompting |
| `merged (conflict resolved)` | Intelligent merge surfaced an irreconcilable region; user chose a resolution |
| `kept local version` | Local edits exist, no upstream change |
| `added` | File didn't exist in project; auto-added (hook scripts) or user-accepted offer (agents) |
| `offered, declined` | New agent surfaced; user chose not to add |
