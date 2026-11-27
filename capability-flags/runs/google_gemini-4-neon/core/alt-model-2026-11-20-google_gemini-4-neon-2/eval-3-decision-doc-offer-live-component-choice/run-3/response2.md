I have written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edits

## Context

TidePlot serves 24 seasonal field workers sharing 12 Android tablets across 320 permanent coastal vegetation plots, producing roughly 6,000 plot-visit records per season. Tablets can remain offline for up to 48 hours, and workers sometimes correct the same visit independently after comparing field notes. Two coordinators review anomalies before exporting a partner CSV every Friday, with no dedicated systems administrator.

Each visit record contains a plot reference, observation date, observer list, species cover estimates, and notes. Some concurrent edits are scientifically independent (for example, correcting an observer's name on one tablet while adding a missed species on another). Other edits are scientifically coupled (for example, revising a species identification alongside its cover estimate, or qualifying an estimate in the notes). The server cannot reliably infer scientific coupling from field names alone.

Every submitted edit must be preserved without silent discard, and arrival order cannot be treated as evidence of scientific authority. The concurrency policy chosen by `record-store` defines how competing submissions become a canonical record—and directly shapes the contracts that `tablet-sync` and `review-export` must build around. Choosing poorly risks either overwhelming two coordinators with avoidable review work or introducing silent scientific corruption and brittle merge-rule maintenance.

## Decision Elements

All options in contention preserve original submissions immutably (no silent discard), so that invariant is background rather than a differentiating gate. The choice turns on five weighted criteria:

- **Preservation of whole-visit scientific coherence** (**major** — grounded in the HLD non-goal against automated inference of scientific intent and the tenet *Keep the path from a submitted observation to an exported value inspectable*): competing edits to scientifically related fields must not be silently combined into a record state that neither field worker observed or verified.
- **Operational and merge-rule maintenance simplicity** (**major** — grounded in the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*): the concurrency mechanism should remain understandable and low-maintenance over seasons without requiring ongoing engineering of field-level merge rules for lists, species entries, or schema additions.
- **Coordinator review throughput and Friday export readiness** (**moderate** — grounded in the HLD goal *Make reviewable problems visible before the Friday export* and the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*): the volume of visits diverted to manual review should stay manageable for two coordinators so reviewed data is ready for the weekly partner CSV export.
- **Provenance and audit clarity** (**moderate** — grounded in the tenet *Keep the path from a submitted observation to an exported value inspectable*): a coordinator or science partner should be able to trace any exported visit back to the submissions and decisions that produced it.
- **Offline tablet storage and submission overhead** (**minor** — grounded in the tenet *Let field workers continue collecting observations without connectivity*): what tablets must store locally across 48-hour disconnections and transmit over intermittent field connectivity.

## Options in the Domain

### Whole-visit revisions

**Description**

Each worker submission carries the complete visit payload along with the `base_revision_id` it was edited from. When `base_revision_id` matches the visit's current canonical revision and no competing revisions are pending, the submission fast-forwards as the new current revision. When `base_revision_id` is stale or the visit already has pending competing revisions, the store accepts and retains the submission intact as a pending competing revision, leaves the canonical revision unchanged, and marks the visit `unresolved`. A coordinator compares the complete competing revisions and submits a `resolution` revision—either selecting one revision verbatim or authoring a combined visit—which advances the canonical revision and returns the visit to `clean`. Unresolved visits are excluded from the Friday CSV export until resolved.

**Demonstration**

Suppose visit `V1` is at revision `R1`. Offline Worker A corrects an observer name from `R1` and submits `R2` (`base_revision_id: R1`); it fast-forwards as current (`clean`). Offline Worker B revises a species identification and its cover estimate from `R1` and submits `R3` (`base_revision_id: R1`). Because `R1 != R2`, the store accepts `R3` as a competing revision and marks `V1` `unresolved`. A coordinator inspects `R2` and `R3` side by side and submits resolution `R4` (`resolved_revision_ids: [R2, R3]`), preserving `R1`, `R2`, and `R3` in history.

**Analysis**

- **Preservation of whole-visit scientific coherence** — **strong**: every worker submission is kept as an intact unit; no automated rule can combine fields from separate revisions into an unverified scientific state.
- **Operational and merge-rule maintenance simplicity** — **strong**: concurrency logic is a small base-revision check and append-only revision log with no field-specific merge semantics to maintain as visit schemas evolve.
- **Coordinator review throughput and Friday export readiness** — **weak**: even clearly disjoint edits (such as fixing an observer name and adding a species) divert the entire visit into the coordinator review queue and hold it out of the Friday export until manually resolved.
- **Provenance and audit clarity** — **strong**: every canonical visit state is either a single worker's complete submission or an explicit coordinator resolution referencing the exact competing revision IDs it reconciled.
- **Offline tablet storage and submission overhead** — **strong**: tablets store only the latest visit record and its `base_revision_id`, submitting complete visit payloads (small JSON records) without maintaining local diff machinery.

**Summary**

Trades a larger manual review queue for zero automated cross-field merges and minimal concurrency complexity.

---

### Field-aware three-way merge

**Description**

Each worker submission carries a reference to its base state (or base snapshot) plus structured field-level changes across scalar fields (`observation_date`, `notes`), set/list fields (`observers`), and keyed collection entries (`species_cover_estimates`). On arrival, the store diffs the incoming edit and the current state against their common base. Changes to disjoint fields merge automatically into a new current state without coordinator intervention. Only overlapping edits—two workers changing the same scalar field or the same species entry—are routed to coordinator review. Original submissions are still retained immutably alongside field-level provenance recording which submission supplied each field value.

**Demonstration**

Suppose visit `V1` is at base state `S1`. Offline Worker A fixes a typo in `observers` from `S1`, and offline Worker B adds a missing species entry to `species_cover_estimates` from `S1`. Because the changed paths do not overlap, the store automatically merges both changes into `S2` and keeps `V1` export-ready with no coordinator action. If instead Worker A edits species `X`'s cover estimate while Worker B removes species `X` or changes its cover estimate, the overlap flags only that conflict for coordinator review.

**Analysis**

- **Preservation of whole-visit scientific coherence** — **weak**: disjoint-field auto-merges can silently combine scientifically coupled edits (for example, one worker changing a species identification or cover estimate while another edits `notes` qualifying that observation, or changing two related cover estimates whose sum or ecological interpretation depends on both).
- **Operational and merge-rule maintenance simplicity** — **weak**: requires defining, testing, and maintaining merge rules for scalar fields, observer lists, and species collections (including identity keys, additions/deletions, and schema changes) over time.
- **Coordinator review throughput and Friday export readiness** — **strong**: disjoint edits resolve automatically without entering the review queue, keeping more visits immediately eligible for the Friday CSV export and reducing coordinator workload when multi-worker corrections are frequent.
- **Provenance and audit clarity** — **partial**: original submissions remain stored, but explaining an exported visit requires field-level provenance tracking which submission supplied each field and which merge rule produced the combined record.
- **Offline tablet storage and submission overhead** — **partial**: tablets must retain base snapshots and construct structured field-level change payloads (handling list and species-entry edits cleanly) rather than submitting a single current document.

**Summary**

Trades merge-rule maintenance and risk of silent cross-field semantic errors for a smaller review queue and faster export readiness.

## Selection

**Selected: Whole-visit revisions.**

Whole-visit revisions wins on both major criteria—preserving whole-visit scientific coherence and keeping operational and maintenance complexity low—while also scoring strongly on audit clarity and tablet simplicity. This decision turns on two HLD tenets (*Keep the path from a submitted observation to an exported value inspectable* and *Prefer workflows two coordinators can operate without a dedicated systems administrator*) and the HLD non-goal against automated inference of scientific intent. At ~6,000 visits per season, accepting a larger review queue for occasional concurrent edits is a safer trade than maintaining per-field merge rules that can silently produce scientifically invalid combinations.

### Why field-aware three-way merge remains a live alternative

Field-aware three-way merge is not ruled out on principle, and its primary advantage—automatically resolving disjoint edits so visits stay export-ready—directly serves the two-coordinator operational tenet when concurrent edits are common. Revisit this decision if field operations produce enough disjoint concurrent edits that two coordinators cannot clear the review queue before the Friday CSV export, or if the visit record expands to include high-churn, strictly independent administrative metadata whose edits routinely collide with botanical observations (where merge rules could be scoped narrowly to non-scientific fields).

### Downstream obligations

This choice is owned by `record-store`; `tablet-sync` and `review-export` consume its contract as downstream obligations rather than co-owning concurrency semantics:

- **`tablet-sync` must accommodate**:
  - Storing `base_revision_id` alongside each locally cached visit.
  - Generating and retaining a stable `idempotency_key` per edit attempt so retries over intermittent connectivity deduplicate safely.
  - Submitting complete visit payloads rather than field-level diffs.
  - Explaining `accepted_as_competing` and `unresolved` server outcomes to field workers without blocking continued offline collection.
- **`review-export` must accommodate**:
  - Presenting a whole-visit revision comparison view over `current_revision` and `pending_revisions` so coordinators can inspect complete competing visits side by side.
  - Supporting coordinator resolution by either selecting a competing revision verbatim or authoring a combined complete visit, and handling rejection if a new competing submission arrives before resolution is saved.
  - Excluding visits with `review_state == unresolved` from the Friday partner CSV export so only `clean` visits are exported.
```

---

**Still at the Phase 2 stop — before moving to Phase 3 (`record-store-specs.md`):**
1. Any changes to `concurrent-visit-edits.md` or `record-store-design.md`?
2. How would you like to triage the 10 edge-case probe items from above (which to specify in `record-store-design.md` now vs. defer as open questions)?
3. Should I also update the "concurrency choice open" lines in `docs/high-level-design.md` once this LLD is settled?