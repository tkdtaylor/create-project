# Architecture — C4 Element Catalog

**Project:** {{PROJECT_NAME}}
**Last updated:** {{DATE}}

The structured catalog of pipeline elements that the diagrams in [`../architecture/diagrams.md`](../architecture/diagrams.md) render. Tables here are the **machine-readable spec** for the pipeline's structure — they survive a Mermaid rewrite and are what a drift audit checks the code against.

## How this file relates to the diagrams

| File | Form | Use when |
|------|------|----------|
| [`../architecture/diagrams.md`](../architecture/diagrams.md) | Visual (Mermaid C4 + lineage + sequence) | You want to *see* the pipeline |
| `architecture.md` (this file) | Tabular (rows + columns) | You want to *check, query, or regenerate* the pipeline structure |

When the pipeline changes, both files update in the same commit. The tables here are the source of truth for *what exists*; the diagrams are the source of truth for *how it's drawn*.

This file pairs with [data-model.md](data-model.md): `architecture.md` lists *containers and components* (the runnable code and the stores), `data-model.md` defines the *schemas* of the data inside those stores. Section 5 (Datasets) below is the bridge — it names each dataset that flows between stages and points at the schema in `data-model.md`.

---

## 1. Persons (actors)

| Name | Description | Goals |
|------|-------------|-------|
| | | |

---

## 2. Systems

| Name | Type | Description | Owner |
|------|------|-------------|-------|
| {{PROJECT_NAME}} | In-scope | | This team |

---

## 3. Containers (pipeline stages and stores)

> Each runnable stage and each persistent store. Stages are the transforms (ingestion, feature engineering, training, evaluation, inference); stores are where data lands between stages (raw lake, processed warehouse, model registry, experiment tracker).

| Name | Kind | Technology | Responsibility | Source path | Depends on |
|------|------|------------|----------------|-------------|------------|
| | (stage / store) | | | | |

**Invariants for this table**
- Every stage listed has a corresponding entry point in `src/` (or equivalent runner script).
- Every store listed has a corresponding directory, table, or registry path that the pipeline reads or writes.
- Every `Depends on` entry resolves to another row in this table or in Section 2 (Systems).
- The drift-audit mode of the `architect` agent checks this against the actual repo layout and dataset directories.

---

## 4. Components

> Modules / packages inside containers that are worth naming at the architecture level — typically the ones with stable interfaces between them. Not every file belongs here; only the load-bearing ones.

| Container | Component | Source path | Responsibility | Depends on |
|-----------|-----------|-------------|----------------|------------|
| | | | | |

---

## 5. Datasets

> Each dataset that flows between stages. Captures location, source stage, and consumers — these rows are what the lineage diagram renders, made queryable. Schema details live in [data-model.md](data-model.md); link to the relevant section.

| Name | Path | Schema (link) | Produced by | Consumed by | Immutable? |
|------|------|---------------|-------------|-------------|------------|
| | | [data-model.md#…](data-model.md) | | | |

**Invariants for this table**
- Every dataset marked `Immutable: yes` lives under `data/raw/` (or equivalent immutable lake) and is never overwritten by the pipeline.
- Every `Produced by` and `Consumed by` entry resolves to a row in Section 3 (Containers).
- The schema link must point to a section in `data-model.md` that describes the dataset's columns / fields.

---

## 6. Cross-cutting decisions

> Architectural choices that span multiple stages — split rule (how train/test/holdout are partitioned), seed propagation, feature store strategy, experiment tracking system, model serialization format, monitoring approach. Each entry should link to an ADR.

-

---

## Maintenance

- **Update in the same commit as `../architecture/diagrams.md`** when the pipeline structure changes. The catalog and the diagrams are two views of the same model.
- **Supersede in place. Never append.** When a stage is replaced or a dataset path moves, rewrite the row. The ADR carries history; this file carries *what* exists now.
- **Reproducibility note.** Section 6 entries that affect results (split rule, seeds, feature store choice) are reproducibility-critical — they must be in the spec, not just in the code.
- The drift-audit mode of the `architect` agent uses this catalog as its primary check against the actual code structure and dataset directory layout.
