# Progress Tracker

**Project:** {{PROJECT_NAME}}

## Tasks

| Task ID | Research question / goal | Status | Answered by |
|---------|--------------------------|--------|-------------|
| | | | |

## Status key

| Symbol | Meaning |
|--------|---------|
| ✅ | **Answered** — research question has a concrete, sourced answer captured in `notes/by-topic/` or a draft section in `outputs/drafts/` |
| 🟡 | **Sources gathered** — relevant material logged and saved, but synthesis is incomplete or the question is not yet definitively answered |
| ⏳ | In progress |
| ❌ | Not started |
| ⚠️ | Blocked — waiting on source or clarification |
| 🔄 | Needs revisiting — new findings changed scope |

## Answered-by ladder

| Level | Evidence | Status this earns |
|-------|----------|-------------------|
| 1 | Searches logged | ⏳ |
| 2 | Sources saved to `sources/web/` or `sources/local/` | 🟡 |
| 3 | Synthesis notes written in `notes/by-topic/` | 🟡 |
| 4 | Research question has a stated answer with source citations | ✅ |
| 5 | Answer is incorporated into `outputs/drafts/` and survives a second-pass review | ✅ |

A "done when" criterion in the task file that says "find five sources" earns ✅ at level 2 if the criterion was literally about sources. A criterion that says "answer whether X is feasible for our use case" requires level 4 — finding sources doesn't answer the question; synthesizing them does.

## Rule

**The task-executor returns at 🟡 by default** when sources are gathered but synthesis is uncertain. The main session flips a row to ✅ only when the research question has a stated answer — either in notes, in a draft, or both. This keeps "I looked at it" distinct from "I know the answer."
