# Fitness Functions — Tool Catalog

**For:** projects scaffolded with the create-project skill that ship `docs/spec/fitness-functions.md` (tech + data).

This catalog is read when:
- The user asks "how do I implement these fitness functions for my stack?"
- The `architect` agent in Mode 4 proposes rules and needs to recommend a concrete check command
- A new project is being scaffolded and the user wants to wire up real rules at T8 / D8

It does **not** prescribe rules — the rules live in each project's `docs/spec/fitness-functions.md`. This file just maps a category + stack to a tool that can express it as an executable check.

---

## How fitness functions sit alongside the other quality mechanisms

Three things in scaffolded projects watch the relationship between the code and the spec. They are not redundant — they have different jobs:

| Mechanism | What it guards | When it runs | Where it's defined |
|-----------|---------------|--------------|--------------------|
| `spec-coverage-check` hook | Active task's `TC-NNN` markers must have test references | Pre-commit (`git commit`) | `.claude/scripts/spec-coverage-check.py`, settings.json |
| `architect` drift-audit (Mode 3) | Spec docs and diagrams still describe what the code does | On demand, periodically | The agent's instructions |
| **Fitness functions** | **Architectural invariants the code must always satisfy — including reproducibility for data projects** | **Continuously: `make fitness` locally + Stop hook in `strict` profile** | `docs/spec/fitness-functions.md` + `Makefile` |

Pick the right tool for the job:
- A rule about a single task's tests → `spec-coverage-check` already covers it; not a fitness function.
- A semantic claim that's hard to express as a check ("the data flow is clear", "the abstraction is clean") → drift-audit, not a fitness function.
- A rule that can be expressed as a number, a yes/no, or an enumerable set of violations → **fitness function**, every time. Don't rely on the agent or the human to remember.

---

## Standard project entry point

Every scaffolded project's Makefile gets a `fitness` umbrella target plus per-rule sub-targets:

```makefile
.PHONY: fitness fitness-no-cycles fitness-layering fitness-perf fitness-deps

fitness: fitness-no-cycles fitness-layering fitness-perf fitness-deps
	@echo "All fitness functions passed."

fitness-no-cycles:
	# tool-specific command, see catalog below

fitness-layering:
	# tool-specific command

fitness-perf:
	# tool-specific command

fitness-deps:
	# tool-specific command
```

If the project has no Makefile (rare, but possible for very simple data projects), `scripts/fitness.sh` is an acceptable fallback — the `check-fitness.py` Stop hook looks for it second. Keep the contract identical: exit 0 on pass, non-zero on failure, print one-line summaries per rule.

The `check-fitness.py` Stop hook (strict profile only) runs `make fitness` automatically after each Claude turn. It does **not** block — failures print to stderr so the agent sees them on the next turn.

---

## Catalog by category

For each category and stack, the entry shows:
- **Tool** — the package to install
- **Install** — one-line install
- **Example rule** — what a typical check looks like
- **Where it goes** — file path or directory in the project

### Structural — cycles, layering, dependency direction

| Stack | Tool | Install | Example rule | Where it goes |
|-------|------|---------|--------------|---------------|
| Python | `import-linter` | `pip install import-linter` | "Modules in `src/domain/` may not import from `src/infra/`" | `.importlinter` |
| Python | `pytest-archon` | `pip install pytest-archon` | "Cycles between top-level packages = 0" | `tests/test_architecture.py` |
| JS / TS | `dependency-cruiser` | `npm i -D dependency-cruiser` | "No cycles, no orphans, no `forbidden` rule violations" | `.dependency-cruiser.cjs` |
| JS / TS | `eslint-plugin-boundaries` | `npm i -D eslint-plugin-boundaries` | "Layered imports (controllers → services → repos)" | `eslint.config.js` |
| Go | `go-arch-lint` | `go install github.com/fe3dback/go-arch-lint@latest` | "Domain may not import infra" | `.go-arch-lint.yml` |
| Go | `depguard` (golangci-lint) | already in `golangci-lint` | "Forbidden import paths" | `.golangci.yml` |
| Java / Kotlin | `ArchUnit` | gradle dep | "Slices defined by package; no inverse dependencies" | `src/test/java/.../ArchitectureTest.java` |
| Rust | `cargo-modules` | `cargo install cargo-modules` | "Crate graph DAG check" | `make fitness-no-cycles` script |
| Any | `madge` (JS-focused but works for anything with a parseable import graph) | `npm i -g madge` | "Cycle detection across the file tree" | shell command |

**Makefile snippet (Python with import-linter):**

```makefile
fitness-layering:
	import-linter
```

**Makefile snippet (JS/TS with dependency-cruiser):**

```makefile
fitness-no-cycles:
	npx depcruise --validate .dependency-cruiser.cjs src
```

**Makefile snippet (Go with depguard via golangci-lint):**

```makefile
fitness-layering:
	golangci-lint run --no-config --disable-all --enable=depguard
```

### Performance — latency, throughput, memory budgets

| Stack | Tool | Install | Example rule | Where it goes |
|-------|------|---------|--------------|---------------|
| Any HTTP | `k6` | `brew install k6` / package manager | "p95 latency on /health < 50ms at 50 RPS" | `tests/perf/health.js` |
| Frontend | `lighthouse-ci` | `npm i -g @lhci/cli` | "Lighthouse perf score ≥ 90 on landing page" | `lighthouserc.json` |
| Python | `pytest-benchmark` | `pip install pytest-benchmark` | "Hot-path function under N µs at the 95th percentile" | `tests/test_benchmarks.py` |
| Go | `go test -bench` + `benchstat` | built-in / `go install golang.org/x/perf/cmd/benchstat@latest` | "Benchmark regression vs. baseline ≤ 5%" | `bench/` |
| Rust | `criterion` | `cargo add --dev criterion` | "Criterion regression vs. baseline ≤ 5%" | `benches/` |

Performance rules are **almost always `warn` severity, not `block`** — false positives on a noisy machine destroy trust. Keep them in `make fitness` so they're visible, but don't fail the runner unless the threshold has a wide margin.

**Makefile snippet (k6 against a local server):**

```makefile
fitness-perf:
	k6 run --quiet --summary-export=fitness-perf.json tests/perf/health.js \
		&& python3 scripts/check_perf_thresholds.py fitness-perf.json
```

### Complexity — cyclomatic, file size, fan-out

| Stack | Tool | Install | Example rule | Where it goes |
|-------|------|---------|--------------|---------------|
| Multi-language | `lizard` | `pip install lizard` | "No function exceeds CCN 15 or 80 lines" | shell command |
| Python | `radon` | `pip install radon` | "Maintainability Index ≥ B" | shell command |
| Python | `ruff` (mccabe) | already in ruff | "C901: McCabe complexity" — set in `[tool.ruff.lint.mccabe]` | `pyproject.toml` |
| JS / TS | `eslint` (`complexity` rule) | already in eslint | "Max cyclomatic complexity 15" | `eslint.config.js` |
| Go | `gocyclo` (golangci-lint) | already in `golangci-lint` | "Function complexity ≤ 15" | `.golangci.yml` |

**Makefile snippet (lizard, language-agnostic):**

```makefile
fitness-complexity:
	lizard --CCN 15 --length 80 --warnings_only src/ \
		| (! grep -q .)
```

### Security — dependencies, surface, secrets

| Stack | Tool | Install | Example rule | Where it goes |
|-------|------|---------|--------------|---------------|
| Multi-language | `dep-scan` (skill catalog tool) | `curl -fsSL https://raw.githubusercontent.com/tkdtaylor/dep-scan/main/install.sh \| bash` | "No high or critical CVEs in installed deps" | `make fitness-deps` |
| Python | `pip-audit` | `pip install pip-audit` | "0 known vulns" | shell |
| JS | `npm audit` | built-in | "0 high+ vulns" | shell |
| Go | `govulncheck` | `go install golang.org/x/vuln/cmd/govulncheck@latest` | "0 known vulns reachable" | shell |
| Rust | `cargo-audit` | `cargo install cargo-audit` | "0 known vulns" | shell |
| Multi-language | `gitleaks` / `trufflehog` | `brew install gitleaks` | "0 secrets in working tree" | `.gitleaks.toml` |

**Makefile snippet (Python):**

```makefile
fitness-deps:
	pip-audit --strict
```

### Coverage — test coverage thresholds

| Stack | Tool | Install | Example rule | Where it goes |
|-------|------|---------|--------------|---------------|
| Python | `pytest-cov` | already configured at T8/D8 | "Branch coverage ≥ 80% in `src/`" | `pyproject.toml` |
| JS / TS | `jest` / `vitest` coverage | already configured at T8 | "Lines, branches, functions ≥ 80%" | `jest.config.js` / `vitest.config.ts` |
| Go | `go test -cover` + `goverdict` | built-in | "Per-package coverage ≥ 70%" | shell pipeline |

The lint/format/test tooling at T8/D8 already enforces coverage as part of `make test`. Adding the same threshold as a fitness function is fine but redundant — only do it if the threshold itself differs (e.g. `make test` enforces 70%, fitness enforces 90% on a critical sub-package).

---

## Data-project additions

The categories above all apply to data projects too, but data projects have two extra categories that are usually higher-leverage than anything else:

### Reproducibility

The `configuration.md` file in a data-project spec carries a "reproducibility contract" — every parameter that affects results must be recorded with each experiment. Fitness functions enforce that contract.

| Tool | What it checks | Implementation |
|------|---------------|----------------|
| `jsonschema` / `pydantic` | Every `experiments/results/*/run-info.json` has the required fields (seed, library versions, dataset hash, git SHA) | Schema + a small Python script that walks the results dir |
| `python -m pip freeze` snapshot | Library versions match `requirements.txt` constraints when the run was logged | Compare run-info.json against current env |
| Replay test | Re-running with the same config produces byte-identical artifacts | A `make fitness-replay` target that runs one canonical config and diffs results against a stored hash |

**Makefile snippet:**

```makefile
fitness-repro-contract:
	python3 scripts/check_run_info_schema.py experiments/results/

fitness-split-determinism:
	python3 scripts/replay_split.py --config experiments/configs/canonical.yaml --check
```

### Data integrity

| Rule | Implementation |
|------|----------------|
| `data/raw/` is immutable | `git status` shows no modified files under `data/raw/` (excluding tracked changes that are part of an explicit raw-data update commit). Easy script. |
| Schema stability | A schema-on-read tool (`pandera`, `pydantic`, `great_expectations`) validates loaded raw data matches the documented schema |
| No leakage between train/test | A test that asserts `train_keys ∩ test_keys = ∅` |

**Makefile snippet:**

```makefile
fitness-raw-immutable:
	bash scripts/check_raw_immutable.sh

fitness-schema:
	pytest tests/test_data_schemas.py
```

---

## Wiring it up — recommended workflow

When a project is being scaffolded (or adopted via `adopt-existing`), Claude should:

1. Generate `docs/spec/fitness-functions.md` from the template with example rows commented or marked as examples — the user fills in real rules later
2. Generate the Makefile with a `fitness` umbrella target that has *no* prerequisites yet (so `make fitness` passes vacuously)
3. Suggest 1–3 starter rules based on the project type and stack (e.g. for a Python web service: no-cycles + deps + perf budget on health endpoint)
4. Leave the rest to the user / `architect` Mode 4

Adding a rule later is a three-step task:
1. Append a row to `docs/spec/fitness-functions.md`
2. Add a `fitness-<rule>` Makefile target with the actual tool invocation
3. Add `fitness-<rule>` to the `fitness` umbrella prerequisites

This is small enough to be a single commit. Keep rules + targets in the same commit so `make fitness` is always self-consistent.

---

## CI later (when you want it)

The same `make fitness` command runs in any CI you eventually wire up. Example for GitHub Actions:

```yaml
- name: Run fitness functions
  run: make fitness
```

That's the whole CI integration. Local execution and CI execution share one command — there's no second pipeline to keep in sync.
