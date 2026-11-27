I wrote the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

### `docs/intent/record-store/decisions/concurrent-visit-edits.md`

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edits

## Context

Field workers on 12 shared Android tablets collect roughly 6,000 vegetation plot-visit records per season across 320 permanent plots, often offline for up to 48 hours. Workers occasionally correct the same visit independently after comparing field notes, so edits based on the same starting revision can arrive at the server hours or days apart. Arrival order does not indicate which worker's observations are scientifically authoritative.

A visit's scientific fields—`plotId`, `observationDate`, `observers`, `speciesCover`, and `notes`—contain a mix of independent and scientifically coupled data. Correcting an observer's name and adding a missed species are unrelated, whereas changing a species identification and adjusting its cover estimate (or adding a note qualifying that estimate) are coupled. The server cannot reliably infer all scientific relationships from field names alone.

Both options in this domain respect the project's foundational invariants: neither silently discards a submitted edit, neither blocks offline capture on tablets, and both preserve original submissions. The decision determines how the record store reconciles concurrent edits into an exportable current state, and it directly shapes the contracts that `tablet-sync` and `review-export` must implement.

## Decision Elements

### Weighted Criteria

- **Preservation of cross-field scientific intent** (*major* — grounded in the HLD non-goal against automated botanical validation or inference of scientific intent): Avoiding silent combinations of edits to different fields that are scientifically coupled, producing a composite record that neither field worker observed.
- **Operational and maintenance burden** (*major* — derives from the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*): Keeping server conflict logic simple enough to operate, debug, and evolve without dedicated systems engineering support for custom merge rules.
- **Coordinator review volume and Friday export readiness** (*moderate*): Minimizing manual review work for two coordinators before the weekly Friday CSV export, particularly when concurrent edits touch unrelated fields.
- **Auditability and lineage simplicity** (*moderate* — derives from the tenet *Keep the path from a submitted observation to an exported value inspectable*): Keeping the trace from every submitted observation to any exported value direct and easy for coordinators and science partners to inspect.
- **Tablet storage and sync payload complexity** (*minor*): Limiting the local state and wire format that shared Android tablets must maintain across restarts and multi-day offline windows.

## Options in the Domain

### Whole-visit revisions

**Description.** Every accepted worker submission is stored as an immutable complete-visit revision referencing the `baseRevisionId` it was edited from. When a submission's `baseRevisionId` matches the visit's current revision, the visit advances linearly and remains `clean`. When a submission's `baseRevisionId` diverges from the current revision—or arrives while the visit is already unresolved—the server appends it as a competing active head and marks the visit `needs_review`. Unresolved visits are excluded from the Friday CSV export until a coordinator compares the competing whole visits and submits a `resolution` revision referencing the reviewed competing head IDs.

**Demonstration.** Worker A and Worker B both fetch revision `R1`. Offline, Worker A fixes an observer's name (`R2a`, parent `R1`) and Worker B revises a species identification and cover estimate (`R2b`, parent `R1`). When both sync, the record store keeps both `R2a` and `R2b` intact as competing heads and marks the visit `needs_review`. A coordinator inspects both complete visits side by side and records resolution `R3` (parents `[R2a, R2b]`), returning the visit to `clean` and eligible for Friday export.

**Analysis.**
- *Preservation of cross-field scientific intent:* **strong** — Every worker submission stays intact as a complete observation unit; no automated rule ever combines fields from separate submissions.
- *Operational and maintenance burden:* **strong** — Server logic is a straightforward revision DAG with no per-field merge rules, list-reconciliation heuristics, or schema-specific conflict tables to maintain.
- *Coordinator review volume and Friday export readiness:* **weak** — Any concurrent edit to the same visit, even on completely unrelated fields (such as an observer name and an added species), enters the review queue and holds the visit out of Friday's CSV until a coordinator resolves it.
- *Auditability and lineage simplicity:* **strong** — Lineage is a small DAG of whole-visit revisions where each resolution explicitly names the competing revision IDs and coordinator identity.
- *Tablet storage and sync payload complexity:* **strong** — Tablets only track a `baseRevisionId` per local visit and submit whole-visit payloads with an idempotency key.

**Summary.** Trades higher coordinator review volume on disjoint concurrent edits for zero silent cross-field merges and minimal server and tablet complexity.

### Field-aware three-way merge

**Description.** Each worker edit supplies its base state (or references a server-known base snapshot) alongside structured field-level changes. On submission, the server computes a three-way merge against the current state using field-type rules: scalar fields (`observationDate`, `notes`), set/list fields (`observers`), and keyed collections (`speciesCover`). Disjoint field changes merge automatically into a new clean, export-eligible record; only overlapping edits to the same field (or same species entry) are routed to coordinator review. Original submissions remain stored alongside field-level provenance recording which submission supplied each field value.

**Demonstration.** Worker A and Worker B both start from revision `R1`. Offline, Worker A fixes an observer's name and Worker B adds a missed species entry. Because the changes touch disjoint fields, the server merges them automatically into a clean, exportable visit without coordinator intervention. If Worker A instead corrects a species identification while Worker B updates that species' cover estimate or adds a qualifying note, the merge rules either combine them automatically without recognizing the scientific coupling or require explicit domain coupling rules to flag the conflict.

**Analysis.**
- *Preservation of cross-field scientific intent:* **weak** — Disjoint-field auto-merges can combine scientifically related edits (such as a species name, cover estimate, and qualifying note) into a composite visit neither worker observed, unless domain-specific coupling rules are authored and kept current.
- *Operational and maintenance burden:* **weak** — Requires designing, testing, and maintaining merge semantics for scalars, observer lists, and keyed species entries, plus field-level provenance and edge-case rules whenever the visit schema evolves.
- *Coordinator review volume and Friday export readiness:* **strong** — Unrelated concurrent edits resolve automatically, keeping the two coordinators' review queue focused on genuine same-field overlaps and leaving more visits ready for Friday's CSV export.
- *Auditability and lineage simplicity:* **partial** — Original submissions are preserved, but explaining an exported visit requires field-level provenance showing which submission contributed each field and which merge rule ran.
- *Tablet storage and sync payload complexity:* **partial** — Tablets must retain base snapshots (or base field values) and serialize structured field-level diffs rather than simple whole-visit envelopes.

**Summary.** Trades rule-maintenance burden and the risk of silently combining scientifically coupled fields for a smaller coordinator review queue and higher automatic export readiness.

## Selection

**Whole-visit revisions** is selected.

It wins on both *major* criteria: it guarantees that no automated rule silently combines scientifically coupled fields across separate submissions (aligning with the HLD non-goal against automated inference of scientific intent), and it keeps the system simple enough to operate without a dedicated systems administrator (turning on the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*). It also provides direct, inspectable whole-visit lineage (turning on *Keep the path from a submitted observation to an exported value inspectable*) and minimizes tablet state.

**Why field-aware three-way merge remains a credible alternative to revisit.** Whole-visit revisions accepts a weak fit on *Coordinator review volume and Friday export readiness*. At ~6,000 visits per season with occasional post-field corrections, the review queue is expected to stay manageable for two coordinators. If concurrent edits to disjoint fields become frequent enough that the coordinators cannot clear the queue before the Friday CSV export, field-aware three-way merge—potentially restricted to a narrow, explicitly safe subset of fields—would warrant reconsideration.

### Implications and Downstream Obligations

Committing to whole-visit revisions forecloses automatic merging of disjoint concurrent edits and partial-field export of unresolved visits. Because concurrency semantics belong to `record-store`, implementing this choice cascades specific contract obligations to sibling nodes:

- **`tablet-sync` (cascade obligation):** Must persist `baseRevisionId` per local visit across restarts and 48-hour offline windows, send complete visit payloads with an `idempotencyKey`, and display pending `needs_review` outcomes to field workers without blocking continued offline capture.
- **`review-export` (cascade obligation):** Must provide a side-by-side whole-visit revision comparison screen for `needs_review` visits, submit coordinator resolutions naming the exact set of reviewed competing head IDs (`resolvedRevisionIds`), and exclude visits in `needs_review` state from the Friday partner CSV export.
```

---

**Still at the Phase 2 stop — please let me know:**
1. Any changes to `decisions/concurrent-visit-edits.md` or `record-store-design.md`.
2. How you want to triage the 8 LLD edge-case probe items from above (which to resolve in `record-store-design.md` now vs. defer to `Open Questions & Future Decisions`).
3. Whether we're good to update the HLD's open-status note and move to Phase 3 (`record-store-specs.md`).