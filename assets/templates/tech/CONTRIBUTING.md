# Contributing to {{PROJECT_NAME}}

> This file is a starter template. **For private/internal-only projects**, rename to `HANDOVER.md` (or `INTERNAL.md`) and adjust the License posture section to describe the operator handoff instead of external contribution. The rest of the structure (Workflow / Project invariants / Local setup / CI) applies to both audiences.

Thank you for considering a contribution. Before opening a PR, please read this short guide — {{PROJECT_NAME}} uses a deliberate, test-spec-first workflow that affects what's accepted.

## License posture

> **Public projects:** state the licence (`MIT`, `Apache-2.0`, `BUSL-1.1`, `PolyForm Noncommercial 1.0.0`, etc.) and whether contributions are accepted under the same terms or a CLA. Be explicit about whether the project is OSI-approved open source or "source-available" — those are different things and people care.
>
> **Internal projects:** describe the operator handoff instead — who owns the codebase, how access is granted, what the on-call expectation is. Delete the rest of this section.

{{PROJECT_NAME}} ships under [LICENSE NAME](LICENSE). [One sentence on what the licence allows.]

By opening a PR you agree your changes are licensed under the same terms.

## Workflow

{{PROJECT_NAME}} is built using an agent-driven workflow documented in [`CLAUDE.md`](CLAUDE.md). You don't need to use the same tooling, but the conventions still apply:

1. **Test spec first.** Every change that touches behavior, an interface, or the data model needs a paired test spec — a short markdown describing the test cases (TC-NNN-XX) the change must satisfy, written before the implementation. For an external PR a `tests/<feature>-test-spec.md` alongside the new tests is sufficient.
2. **One task, one commit.** Don't batch unrelated changes. If a fix and a refactor are both warranted, two commits, please.
3. **Spec moves with code.** If your change alters externally-visible behavior, the data model, an interface, or configuration, the matching `docs/spec/` file is updated **in the same commit** as the source change. Stale spec entries are rewritten in place — never appended to. The ADR carries the history; the spec carries the current truth.
4. **ADR for non-obvious decisions.** Significant design decisions get an ADR under `docs/architecture/decisions/`. Number sequentially.

## Project invariants

> Replace this list with the rules that actually hold for {{PROJECT_NAME}}. Each one should be the kind of rule a contributor could violate without realizing it — invariants enforced by CI, hooks, or fitness functions belong here.

These are non-negotiable and enforced by CI / hooks:

- *(example)* **No outbound network calls in the daemon code path.** All telemetry is opt-in and lives in a separate module.
- *(example)* **Verdicts are immutable.** Pipelines compose verdicts, never mutate them.
- *(example)* **No `git commit --no-verify`.** The pre-commit hook is a second-to-last line of defense.

## Local setup

```bash
# TODO: fill in — install commands, env setup, build steps

# Standard development loop
make check          # lint + typecheck + unit tests
make fitness        # architectural invariants from docs/spec/fitness-functions.md
# make release-check  # uncomment if RELEASE_CHECKLIST.md exists
```

See [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) for the pre-tag verification sequence (if the project ships versioned releases).

## Continuous integration

> Replace this with the actual CI status of the project. If there's no CI yet, delete the section.

Every PR runs the CI workflow (lint, format, typecheck, unit tests, fitness — each as a separate check row). **CI must pass before a PR is merged.** A failing job is a blocking comment, not a suggestion.

## Filing issues

- **Bugs:** include reproduction steps, environment, and which test-spec marker (`TC-NNN-XX`) the issue maps to if known.
- **Feature requests:** describe the use case and where it sits in the architecture (cite the relevant `docs/spec/behaviors.md` entry or propose where a new one belongs).
