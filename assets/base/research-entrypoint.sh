#!/bin/bash
# entrypoint.sh — workspace initializer for claude-project-research
#
# Runs as root throughout init, then drops to the developer user via gosu
# before exec. This gives the entrypoint the permissions it needs for chown
# and setup while keeping the actual research session unprivileged.
set -e

WORKSPACE=/workspace
REQS="$WORKSPACE/requirements.txt"
VENV="$WORKSPACE/.venv"
HASH_FILE="$VENV/.requirements.sha256"

# ── Step 1: Seed workspace volume on first run ────────────────────────────────
if [ -z "$(ls -A "$WORKSPACE" 2>/dev/null)" ]; then
    echo "[init] Seeding workspace from /host..."
    cp -r /host/. "$WORKSPACE/"
    chown -R developer:developer "$WORKSPACE/"
    echo "[init] Workspace ready."
fi

# ── Step 2: Install / update Python dependencies ─────────────────────────────
if [ -f "$REQS" ]; then
    if [ -d "$VENV" ] && ! gosu developer "$VENV/bin/python3" -c "" 2>/dev/null; then
        echo "[init] Venv is broken (base image updated?) — recreating..."
        rm -rf "$VENV"
    fi

    CURRENT_HASH=$(sha256sum "$REQS" | cut -d' ' -f1)
    STORED_HASH=$(cat "$HASH_FILE" 2>/dev/null || echo "")

    if [ ! -d "$VENV" ] || [ "$CURRENT_HASH" != "$STORED_HASH" ]; then
        echo "[init] Installing Python dependencies into .venv..."
        gosu developer python3 -m venv "$VENV"
        gosu developer "$VENV/bin/pip" install --quiet --no-cache-dir -r "$REQS"
        echo "$CURRENT_HASH" > "$HASH_FILE"
        echo "[init] Dependencies ready."
    fi
fi

# ── Step 3: Activate venv ────────────────────────────────────────────────────
if [ -d "$VENV" ]; then
    export VIRTUAL_ENV="$VENV"
    export PATH="$VENV/bin:$PATH"
fi

# ── Step 4: Configure git identity and credentials ───────────────────────────
[ -n "$GIT_USER_NAME" ]  && gosu developer git config --global user.name  "$GIT_USER_NAME"
[ -n "$GIT_USER_EMAIL" ] && gosu developer git config --global user.email "$GIT_USER_EMAIL"

if [ -n "$GIT_TOKEN" ]; then
    gosu developer git config --global credential.helper \
        '!f() { printf "username=x-access-token\npassword=$GIT_TOKEN\n"; }; f'
fi

if [ -n "$GIT_REMOTE_URL" ] && [ -d "$WORKSPACE/.git" ]; then
    gosu developer git -C "$WORKSPACE" remote set-url origin "$GIT_REMOTE_URL" 2>/dev/null \
        || gosu developer git -C "$WORKSPACE" remote add origin "$GIT_REMOTE_URL" 2>/dev/null \
        || true
fi

# ── Step 5: Ensure Claude Code directories exist ────────────────────────────
# ~/.claude/ is bind-mounted from the host. Claude Code expects certain
# subdirectories to exist (e.g. plans/ for plan mode). Create them as the
# developer user so there are no permission issues.
gosu developer mkdir -p /home/developer/.claude/plans

# ── Step 6: Drop privileges and exec ─────────────────────────────────────────
exec gosu developer "$@"
