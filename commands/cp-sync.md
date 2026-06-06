---
description: Update globally installed skills and sync this project's managed hooks/agents/settings
---
Invoke the **create-project** skill with arguments `mode=sync`.

This runs the skill-sync flow: fast-forward-pulls upstream changes for globally installed skills, then syncs this project's managed files (hooks, agents, settings) from the latest templates using `.claude/skill-manifest.json` — intelligent merge over overwrite. Skips the project interview.
