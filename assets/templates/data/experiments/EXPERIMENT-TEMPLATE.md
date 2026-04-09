# Experiment: {{EXPERIMENT_NAME}}

**ID:** {{EXPERIMENT_ID}}
**Created:** {{DATE}}
**Status:** IDENTIFY

## Problem

What specific question are you trying to answer? What motivated this experiment?

## Current state

What do you know today? What's the baseline performance or behavior?

## Hypothesis

> If we [do X], then [Y will happen], because [reasoning].

## Target

What does success look like? Define a concrete, measurable outcome.

| Metric | Baseline | Target | Actual |
|--------|----------|--------|--------|
|        |          |        |        |

## Lifecycle

Track phase transitions. Each phase should be a conscious decision, not a drift.

- [x] **IDENTIFY** — problem defined
- [ ] **RESEARCH** — prior art reviewed, constraints documented
- [ ] **HYPOTHESIZE** — testable hypothesis written
- [ ] **PLAN** — experiment design, config, data splits decided
- [ ] **IMPLEMENT** — code written, config in `experiments/configs/`
- [ ] **EVALUATE** — results collected in `experiments/results/`
- [ ] **DECIDE** — GO / NO-GO / ITERATE

## Research notes

Prior art, related papers, relevant findings from earlier experiments.

## Design

- **Config:** `experiments/configs/{{EXPERIMENT_ID}}-{{SHORT_NAME}}.yaml`
- **Data splits:** (describe train/val/test split or sampling strategy)
- **Controls:** (what stays fixed while the variable changes)
- **Variables:** (what you're varying)

## Findings

Record observations as you go — don't wait until the end.

## Decision

**Outcome:** (GO / NO-GO / ITERATE)

**Rationale:**

**Actions:**
- GO: create tasks in the project journal, port validated patterns to `src/`
- NO-GO: document why, record as a failed approach to prevent re-exploration
- ITERATE: refine hypothesis, adjust parameters, run again

---

*Rule: port results, not files. Experiment artifacts stay in the sandbox. Only actionable outcomes (code patterns, validated configs, documented decisions) move to the project.*
