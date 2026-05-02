# Interfaces

**Project:** {{PROJECT_NAME}}
**Last updated:** {{DATE}}

The contact surface — how runs are launched, how predictions are served (if at all), what `src/` modules expose to notebooks and other consumers, and what external services this project calls.

Not in this file:
- What the interfaces *do* (that's in [behaviors.md](behaviors.md))
- What data flows through them (that's in [data-model.md](data-model.md))
- How they're configured (that's in [configuration.md](configuration.md))

---

## CLI runners

> Scripts and entrypoints that launch pipeline behaviors from the shell. Document every command users / agents are expected to run.

```
<runner> <subcommand> [flags] [args]

Subcommands:
  train       Train a model from an experiment config
  evaluate    Evaluate a saved model on a dataset
  ingest      Pull and validate raw data
```

| Command | Args | Effect |
|---------|------|--------|
| | | |

**Exit codes:**
- `0` — success
- `1` — generic error
- `2` — usage error (bad config, missing file)
- *(add more as defined)*

---

## Notebook entrypoints

> Reusable patterns notebooks use to invoke `src/` code. If notebooks repeat the same setup boilerplate, that's a sign the boilerplate belongs in `src/` and should be documented here.

| `src/` module | Public API | What notebooks call this for |
|---------------|------------|------------------------------|
| `src.data.loaders` | `load_processed(name) -> pd.DataFrame` | reading processed datasets |
| | | |

**Notebook conventions:**
- Numbered (`01-...`, `02-...`) and one topic each
- No project-critical logic in notebooks — port to `src/` once validated
- Restart-and-run-all must succeed; no hidden cell ordering

---

## Model serving (if applicable)

> If models are served — batch prediction script, REST endpoint, scheduled inference job — document the contract here.

### Endpoint / job: <name>

- **Trigger:** how it's invoked (HTTP, cron, manual)
- **Input contract:** request shape / input file shape
- **Output contract:** response shape / output file shape
- **Latency / throughput floor:** if relevant
- **Failure behavior:** what the consumer sees on error

---

## Public `src/` API

> Stable functions / classes in `src/` that other modules and notebooks depend on. Treat changes here as breaking changes.

### Module: `src.<module>`

- **Public functions:** signatures with type hints, one-line description each
- **Public classes:** name, key methods, lifecycle
- **Stability:** how breaking changes are coordinated

> If the module is small enough, paste the function signatures verbatim. Otherwise, link to the source and just list names + purpose here.

---

## External services and APIs

> Everything this project calls out to: data vendors, cloud storage, MLflow / Weights & Biases servers, paid APIs, internal services.

| Service | What we call | Library / version | Failure mode | Cost / quota |
|---------|--------------|-------------------|--------------|--------------|
| | | | | |

---

## Extension points

> If the pipeline has plugin slots (custom loss functions, custom data loaders, model registries), document them here. If there are none, say "None — extension is by source modification" so it's an explicit choice.

-
