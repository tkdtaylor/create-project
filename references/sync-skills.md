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

---

## Step S3 — Sync project artifacts

This step syncs files in the current project that were originally copied from a skill's templates (hooks, agents, settings). It uses `.claude/skill-manifest.json` to track what was installed and detect changes on both sides.

### 3a — Read or generate the manifest

```bash
cat .claude/skill-manifest.json 2>/dev/null || echo "NOT_FOUND"
```

**If the manifest exists:** read it and proceed to 3b.

**If the manifest does NOT exist:** the project was set up before manifest tracking was added. Detect the setup and generate a baseline manifest:

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
- `.claude/agents/task-executor.md` → `assets/templates/<type>/.claude/agents/task-executor.md`

**tech and data only (hooks from `tech/`, agents from `<type>/`):**
- `.claude/scripts/config-protection.py` → `assets/templates/tech/.claude/scripts/config-protection.py`
- `.claude/scripts/edit-tracker.py` → `assets/templates/tech/.claude/scripts/edit-tracker.py`
- `.claude/scripts/batch-format-typecheck.py` → `assets/templates/tech/.claude/scripts/batch-format-typecheck.py`
- `.claude/agents/architect.md` → `assets/templates/<type>/.claude/agents/architect.md`
- `.claude/agents/code-reviewer.md` → `assets/templates/<type>/.claude/agents/code-reviewer.md`
- `.claude/agents/security-auditor.md` → `assets/templates/<type>/.claude/agents/security-auditor.md`

5. Generate the manifest by hashing each managed file that exists in the project. Use the current project file hash as `installed_hash` — this treats all current files as "not modified by user" for the first sync, so any template differences show as upstream changes:

```bash
# For each managed file that exists, compute:
sha256sum "$file" | cut -d' ' -f1      # installed_hash (current project copy)
sha256sum "$template_path" | cut -d' ' -f1  # template_hash (current template)
```

Write `.claude/skill-manifest.json` (see format below) and tell the user:

*"No skill manifest found — I've generated one from the current project state. This is a one-time setup so future syncs can track changes accurately."*

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

For each file in the manifest, compute two checks:

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
| No | Yes | Upstream update | **Auto-update** — copy template, update manifest |
| Yes | No | Local change | **Keep** — user customized, no upstream change |
| Yes | Yes | Conflict | **Ask user** — show diff, let them decide |
| File missing | Yes | New upstream | **Offer to add** — new file in template |
| File missing | No | Removed | **Skip** — user deleted it intentionally |

### 3c — Apply upstream-only updates

For files where the user hasn't modified but the template has changed, copy the new template version:

```bash
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

Report each update:
```
Updated .claude/scripts/protect-secrets.py — new version from create-project
Updated .claude/agents/task-executor.md — new instructions (model: sonnet preserved)
```

### 3d — Handle conflicts

For files where both the user and the template have changed:

1. Show what changed on each side:
```bash
# What the user changed (installed → current project file)
diff <(git show HEAD:.claude/scripts/protect-secrets.py 2>/dev/null || cat /dev/null) .claude/scripts/protect-secrets.py

# What upstream changed (old template → new template)
# Use the manifest's template_hash to identify the old version, or just show the current template
diff "$file" "$SKILL_DIR/$template_path"
```

2. Ask: *"This file has local modifications AND upstream changes. Options: (a) keep your version, (b) take the upstream version, (c) let me merge them."*

3. If they choose (c): read both versions, understand the intent of each change, and produce a merged version that preserves the user's customizations while incorporating the upstream improvements. This is an intelligent merge, not a line-by-line diff — use your understanding of what the code does.

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

For new files found:
1. Present them: *"The create-project skill now includes these files that aren't in your project:"*
2. List each with a one-line description (read the file to summarize)
3. Ask which ones to add
4. Copy selected files and add them to the manifest

---

## Step S4 — Update manifest and commit

Update `.claude/skill-manifest.json` with new hashes for all files that were synced or confirmed up-to-date:

For each managed file, update:
- `installed_hash` — sha256 of the file now in the project
- `template_hash` — sha256 of the current template

```bash
git add .claude/
git diff --cached --quiet || git commit -m "chore: sync skill artifacts from updated templates"
git remote get-url origin >/dev/null 2>&1 && git push || true
```

---

## Step S5 — Summary

Present a final report:

```
Skill sync complete.

Global skills:
  create-project — updated (3 commits)
  code-scanner — up to date

Project artifacts (from create-project):
  .claude/scripts/protect-secrets.py — updated
  .claude/scripts/restructure-plan.py — updated
  .claude/scripts/post-compact.py — up to date
  .claude/settings.json — merged (1 new hook added)
  .claude/agents/task-executor.md — updated (model: sonnet preserved)
  .claude/agents/architect.md — up to date
  .claude/agents/code-reviewer.md — up to date (local modifications kept)
  .claude/agents/security-auditor.md — up to date
  NEW: .claude/agents/qa.md — added
```

If no changes were found in either scope, say: *"Everything is up to date — no changes needed."*
