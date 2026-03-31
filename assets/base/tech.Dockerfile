# syntax=docker/dockerfile:1
# claude-project-dev — shared base image for technical projects
#
# Managed by the create-project skill. Built once, reused across all technical
# projects. Each project gets its own named Docker volume; this image provides
# the runtime environment (Claude Code, git, Python, Node).
#
# Python dependencies are NOT installed here. The entrypoint installs them from
# the project's requirements.txt into a per-volume .venv on first run, and
# re-installs automatically when requirements.txt changes.
#
# Update mechanism: the skill stores a hash of this file as a Docker label and
# rebuilds automatically when the content changes (new tool version, new package).

FROM debian:bookworm-slim

LABEL dev.claude-project.image-type="tech"
LABEL dev.claude-project.description="Shared base image for Claude-assisted technical projects"

ENV DEBIAN_FRONTEND=noninteractive
# Ensure Python output is not buffered in docker logs
ENV PYTHONUNBUFFERED=1
# Prevent .pyc files from cluttering the workspace volume
ENV PYTHONDONTWRITEBYTECODE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    # Network / TLS
    curl \
    ca-certificates \
    # Version control
    git \
    # C compiler — required by Python packages that build native extensions
    build-essential \
    # Python runtime + venv support
    python3 \
    python3-pip \
    python3-venv \
    # Node.js runtime — required by the Claude Code CLI
    nodejs \
    npm \
    # Privilege-dropping tool for entrypoint — safer than su/sudo in containers
    gosu \
 && rm -rf /var/lib/apt/lists/*
# ↑ Always clean apt lists in the same RUN layer to keep the layer small

# Install Claude Code CLI globally
# Pin to a specific version for reproducible builds: @1.x.x
# Changing this line changes the Dockerfile hash, triggering an automatic rebuild.
RUN npm install -g @anthropic-ai/claude-code@latest

# Create a non-root user for running the dev environment.
# The entrypoint runs as root (for init/chown), then drops to this user via gosu.
RUN groupadd -r developer && useradd -r -g developer -m -s /bin/bash developer

# Pre-create the workspace directory owned by developer so volume mounts
# inherit the correct ownership without a separate chown on every start.
RUN mkdir -p /app && chown developer:developer /app

WORKDIR /app

COPY tech-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Entrypoint runs as root — it does init work then drops to developer via gosu
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
