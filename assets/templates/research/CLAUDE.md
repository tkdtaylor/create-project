# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Project structure

```
sources/       ← input materials (never edited — treat as read-only)
  local/         files the user provided
  web/           saved pages and downloaded references
notes/         ← working synthesis (scratchpad — can be messy)
  by-topic/      notes organized by research area
outputs/       ← final deliverables
  drafts/        work in progress
  final/         completed and approved pieces
docs/          ← project management
  research-log.md   running log of searches and findings
  outline.md        target structure for the output
  tasks/            active, backlog, completed
```

The key distinction: `sources/` and `docs/` are the input side, `notes/` and `outputs/` are the output side.

## Research approach

> TODO: fill in specifics — e.g. primary domains to search, databases or journals to prioritize, geographic or time scope, intended audience for the output.

## Conventions

- Log every search in `docs/research-log.md` — include the query, platform, date, and key result
- Save web sources worth keeping to `sources/web/` as markdown with URL + date at the top
- Notes in `notes/` are working material; only move content to `outputs/` when it's ready to share
- Tasks define a research question, not a deliverable — done means the question is answered

## Do not

- Do not edit files in `sources/` — they are reference material, not drafts
- Do not write to `outputs/final/` until the user has reviewed the draft
- Do not skip logging a search just because it came up empty — dead ends prevent duplicate work
- Do not conflate note-taking with writing — `notes/` is for synthesis, `outputs/` is for the final product
