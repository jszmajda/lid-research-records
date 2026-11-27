I have written the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md` (in `Decisions & Alternatives` and `References`).

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Policy

## Context

TidePlot serves 24 seasonal field workers sharing 12 Android tablets across 320 permanent coastal vegetation plots, producing roughly 6,000 plot-visit records per season. Tablets can remain offline for up to 48 hours. Workers occasionally correct the same visit independently after comparing field notes, so multiple edits derived from the same starting visit state arrive out of order.

A visit record contains a plot reference, observation date, observer list, species cover estimates, and notes. Some concurrent edits are independent (such as correcting an observer name in one edit and adding a missed species in another), while others are scientifically coupled (such as changing a species identification in one edit and adjusting its cover estimate in another). The server cannot reliably infer scientific coupling from field names alone.

Two foundational invariants hold regardless of which concurrency policy is chosen: original worker submissions are never discarded (per the HLD tenet *Do not silently discard a submitted edit*), and field workers can continue collecting and editing observations without connectivity (per *Let field workers continue collecting observations without connectivity*). Neither option is eliminated by a hard gate; the choice turns on how competing edits are reconciled and what downstream contracts `tablet-sync` and `review-export` must implement.

## Decision Elements

All elements below are weighted criteria that differentiate the options in contention:

- **Preservation of whole-visit scientific intent (major)** — Derived from the HLD tenet *Keep the path from a submitted observation to an exported value inspectable* and the HLD non-goal *Automated botanical validation or inference of scientific intent*. The concurrency mechanism must avoid silently combining field edits that are scientifically interdependent without human review.
- **Operational and maintenance simplicity (major)** — Derived from the HLD tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*. The policy should minimize ongoing rule authoring, edge-case maintenance, and debugging burden for a small conservation team.
- **Coordinator review throughput and Friday export readiness (moderate)** — Two coordinators must resolve queued review work before the weekly Friday partner CSV export. Routing fewer benign concurrent edits to manual review reduces coordinator workload and the risk of visits being held back from the weekly export.
- **Provenance and review inspectability (moderate)** — Derived from the HLD tenet *Keep the path from a submitted observation to an exported value inspectable*. Coordinators and science partners need a clear, comprehensible path from original worker submissions to the exported record.
- **Offline client state and submission complexity (minor)** — Tablets operate offline for multi-day stretches on shared hardware. Simpler local revision tracking and submission payloads reduce client-side state-machine complexity in `tablet-sync`.

## Options in the Domain

### Whole-Visit Revisions

**Description**

Each visit is stored as an append-only DAG of immutable whole-visit revisions. A worker submits a complete visit payload naming the `base_revision_id` they edited from. If `base_revision_id` matches the visit's sole active head, the submission fast-forwards the current state. If `base_revision_id` is older—or the visit already has competing heads—the submission is stored intact as a competing active head and the visit enters `needs_review`. No fields are merged automatically. A coordinator compares the competing whole visits side by side and records a `resolution` revision superseding the active heads. Visits in `needs_review` are held out of the Friday CSV export until resolved.

**Demonstration**

Visit `V1` is at revision `R1`. Offline Worker A fixes an observer name and submits `R2` (base `R1`). Offline Worker B revises a species identification and its cover estimate and submits `R3` (base `R1`). `R2` fast-forwards `V1` to `current (R2)`. When `R3` arrives with base `R1`, `V1` transitions to `needs_review` with competing heads `[R2, R3]`. `V1` is excluded from export until a coordinator compares `R2` and `R3` against `R1` and commits resolution `R4` (parents `[R2, R3]`).

**Analysis**

- *Preservation of whole-visit scientific intent*: **strong** — Every submitted visit remains an intact scientific unit; no two edits are ever combined without a coordinator inspecting both whole visits.
- *Operational and maintenance simplicity*: **strong** — Requires only revision-parent tracking and head-set management, with no per-field merge rules or schema-specific reconciliation logic to maintain as visit fields evolve.
- *Coordinator review throughput and Friday export readiness*: **weak** — Even completely disjoint concurrent edits (such as fixing an observer name and adding a species) create a `needs_review` item and hold the visit out of the Friday export until a coordinator resolves it.
- *Provenance and review inspectability*: **strong** — Every exported value traces directly to a single intact worker submission or a single coordinator-approved resolution revision with explicit parent links.
- *Offline client state and submission complexity*: **strong** — Tablets only store a `base_revision_id` per cached visit and submit complete payloads with an idempotency key.

**Summary**

Trades higher coordinator review volume on disjoint concurrent edits for whole-visit scientific integrity and minimal ongoing maintenance.

### Field-Aware Three-Way Merge

**Description**

Each edit supplies its base state (or base revision reference) and structured field-level changes. On receipt, the server compares incoming changes against the common ancestor and current state using field-type merge rules: scalar fields (observation date, notes), set/list fields (observer list), and keyed collection entries (species cover estimates keyed by species). Disjoint changes combine automatically into a new current state ready for export, while overlapping changes to the same field or entry route to coordinator review. Original submissions remain stored separately for auditability.

**Demonstration**

Using the same scenario: `R2` changes `observers` and `R3` changes `species_cover[Carex]`. Because the modified fields are disjoint relative to `R1`, the server automatically produces a combined current state containing Worker A's observer correction and Worker B's species update, leaving `V1` eligible for Friday export without coordinator intervention. Only if both workers edited `species_cover[Carex]` (or both edited `notes`) would the overlapping field route to review.

**Analysis**

- *Preservation of whole-visit scientific intent*: **weak** — Automated merging of disjoint fields can silently combine scientifically related edits (for example, one worker changing a species identification while another adjusts a cover estimate or note tied to the prior identification) because field-level rules cannot detect cross-field ecological dependencies.
- *Operational and maintenance simplicity*: **weak** — Requires authoring, testing, and maintaining merge semantics for scalars, lists, and keyed species collections, plus updating those rules whenever the visit schema changes.
- *Coordinator review throughput and Friday export readiness*: **strong** — Automatically resolves disjoint concurrent edits, keeping the review queue focused on true field collisions and allowing more visits to reach the Friday export without manual intervention.
- *Provenance and review inspectability*: **partial** — Preserves original submissions, but explaining an exported visit requires field-level provenance showing which submission contributed each merged field and which merge rule applied.
- *Offline client state and submission complexity*: **partial** — Tablets must retain base snapshots (or compute accurate structured deltas against a known base) rather than simply submitting a whole visit with a base revision ID.

**Summary**

Trades ongoing merge-rule maintenance and risk of silent cross-field scientific combinations for lower coordinator review volume and faster export readiness.

## Selection

**Whole-visit revisions** is selected.

This choice turns on two HLD tenets and one explicit non-goal: *Keep the path from a submitted observation to an exported value inspectable*, *Prefer workflows two coordinators can operate without a dedicated systems administrator*, and the non-goal *Automated botanical validation or inference of scientific intent*. Both major criteria—preserving whole-visit scientific intent and keeping the system operationally simple—strongly favor whole-visit revisions. The primary cost is a weak fit on coordinator review throughput when disjoint concurrent edits occur, which is an acceptable trade for a 6,000-visit seasonal workload where silent scientific distortion is more damaging than a larger review queue.

### Why Field-Aware Three-Way Merge Remains Worth Re-Evaluating

Field-aware three-way merge is not flawed in principle; it is the stronger choice if review queue volume becomes a bottleneck before Friday exports. Specifically, if seasonal operations show frequent disjoint concurrent edits—such as routine administrative metadata cleanups colliding with botanical field corrections—such that two coordinators cannot clear `needs_review` visits in time for the weekly partner CSV, this decision should be revisited. Re-opening it would require defining explicit scientific-coupling rules (identifying which field groups must always be treated as an atomic unit rather than merged independently) and funding the maintenance of those rules.

### Downstream Obligations

Committing to whole-visit revisions shapes both downstream design nodes:

- **`tablet-sync` must accommodate**:
  - Persisting `base_revision_id` alongside each locally cached visit and sending it with every whole-visit edit (and `null` for new visits).
  - Sending complete visit payloads with a persistent `idempotency_key` for retry safety.
  - Interpreting the server acceptance response (`current` vs. `needs_review`) and explaining to field workers when an offline edit created or joined a competing revision awaiting coordinator review.
  - *(Foreclosed / not needed)*: Local base-state snapshots and client-side structured diff generation.
- **`review-export` must accommodate**:
  - A coordinator revision-comparison workflow that displays competing whole-visit heads side by side (with authors, receipt times, and common-ancestor history from revision-history retrieval).
  - Submitting resolutions with `expected_head_ids` and handling stale-head conflict errors when another offline edit arrives during review.
  - Holding all `needs_review` visits out of the Friday partner CSV export and surfacing unresolved visit counts before export so coordinators know what is excluded.
  - *(Foreclosed / not needed)*: Field-level merge provenance views and per-field conflict resolution controls.
```

---

We are still at the **Phase 2 stop** for `record-store`. Please let me know:
1. Any changes to `concurrent-visit-edits.md` or `record-store-design.md`.
2. How you want to triage the 8 edge-case probe items from above (which to specify in `record-store-design.md` now vs. defer to `Open Questions & Future Decisions`).

Once you approve Phase 2, I will move to Phase 3 (`record-store-specs.md`).