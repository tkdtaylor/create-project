# syntax=docker/dockerfile:1
# claude-project-research — shared base image for research projects
#
# Managed by the create-project skill. Built once, reused across all research
# projects. Each project gets its own named Docker volume; this image provides
# the runtime environment (Claude Code, pandoc, PDF tools, Python).
#
# Python dependencies are NOT installed here. The entrypoint installs them from
# the project's requirements.txt into a per-volume .venv on first run, and
# re-installs automatically when requirements.txt changes.
#
# Note: build-essential is intentionally excluded — all default research packages
# (requests, beautifulsoup4, pdfminer.six, markdownify) are pure Python.
# Add it back if you need compiled extensions (e.g. lxml with C).
#
# Update mechanism: the skill stores a hash of this file as a Docker label and
# rebuilds automatically when the content changes.

FROM debian:bookworm-slim

LABEL dev.claude-project.image-type="research"
LABEL dev.claude-project.description="Shared base image for Claude-assisted research projects"

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    # Network / TLS
    curl \
    ca-certificates \
    wget \
    # Version control
    git \
    # Python runtime + venv support
    python3 \
    python3-pip \
    python3-venv \
    # Document format conversion (Markdown ↔ HTML ↔ PDF ↔ DOCX etc.)
    pandoc \
    # PDF text extraction via pdftotext / pdfinfo (faster than Python for plain text)
    poppler-utils \
    # Node.js runtime — required by the Claude Code CLI
    nodejs \
    npm \
    # Privilege-dropping tool for entrypoint — safer than su/sudo in containers
    gosu \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code@latest

# Create a non-root user. Entrypoint runs as root for init, drops to developer.
RUN groupadd -r developer && useradd -r -g developer -m -s /bin/bash developer
RUN mkdir -p /workspace && chown developer:developer /workspace

WORKDIR /workspace

COPY research-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
