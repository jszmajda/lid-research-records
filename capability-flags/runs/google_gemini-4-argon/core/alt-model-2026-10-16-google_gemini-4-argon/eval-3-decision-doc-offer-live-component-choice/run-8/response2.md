I have written the decision doc at `docs/intent/record-store/decisions/concurrent-visit-revisions.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

### `docs/intent/record-store/decisions/concurrent-visit-revisions.md`

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Handling

## Context

Seasonal field workers use shared Android tablets that remain offline for up to 48 hours while surveying permanent coastal vegetation plots. Workers sometimes independently update the same plot-visit record on different tablets after comparing field notes. Because edits may arrive days after a worker fetched the starting state of a visit, arrival order at the server does not reflect which observation is more accurate.

A visit record contains a plot reference (`plot_id`), observation date, observer names, species cover estimates, and freeform notes. Some fields have latent scientific relationships that are not expressed in the schema: for example, revising a species identification often goes with adjusting its cover estimate or explaining a voucher specimen in the notes, and removing an observer can correspond to removing that observer's quadrant observations.

The record store must define how concurrent edits to the same visit are submitted, stored, and reconciled into a current record. That choice sets the contract that `tablet-sync` (local storage and submission payloads) and `review-export` (coordinator review workflows and Friday CSV export eligibility) must accommodate.

## Decision Elements

### Gates

- **Preserve all submitted observations** (Inherited — Tenet: *Do not silently discard a submitted edit*): Every accepted worker submission must remain stored and retrievable with its author and receipt timestamp, regardless of whether it becomes the current state immediately or requires coordinator resolution.

### Weighted Criteria

- **Scientific coherence of combined records** (**major** — Tenet: *Keep the path from a submitted observation to an exported value inspectable*; Non-Goal: *Automated botanical validation or inference of scientific intent*): The extent to which the concurrency mechanism prevents scientifically related fields from two separate submissions from being combined into a hybrid visit record that neither worker observed and no coordinator reviewed.
- **Rule maintenance and operational simplicity** (**major** — Tenet: *Prefer workflows two coordinators can operate without a dedicated systems administrator*): How little schema-specific merge logic must be specified, tested, and maintained as visit fields or collection conventions evolve.
- **Coordinator review queue volume** (**moderate** — Goal: *Make reviewable problems visible before the Friday export*): How effectively the mechanism avoids routing non-overlapping edits (such as fixing a typo in an observer's name while another worker appends a note) into manual coordinator review before the weekly export.
- **Client and review-surface footprint** (**minor**): The amount of state tablets must retain offline and the complexity of the coordinator review UI and export filtering required to inspect and resolve concurrent edits.

## Options in the Domain

### Option 1: Whole-Visit Revisions

#### Description

Each accepted submission stores a complete, immutable visit snapshot as a revision linked to the `base_revision_id` the worker started from (`null` on initial creation).

- When a submission's `base_revision_id` matches the visit's sole active head revision, the new revision supersedes that head and becomes the visit's `current` revision.
- When a submission's `base_revision_id` refers to an already-superseded revision (or is `null` for an existing visit), the new revision is recorded as a competing active head and the visit enters `needs_review`.
- A coordinator resolves a visit in `needs_review` by inspecting the competing revisions in full, selecting or composing the complete resolved visit payload, and submitting a resolution that names the exact `resolved_revision_ids` being superseded.

#### Demonstration

```json
// Submission envelope from tablet-sync
{
  "idempotency_key": "8f14e45f-ceea-467f-a8f0-15e93c421a20",
  "base_revision_id": "rev_01J9X2A",
  "payload": {
    "plot_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "observation_date": "2026-06-14",
    "observers": ["A. Rivera", "M. Chen"],
    "species_cover": [
      { "species_code": "SPAL", "cover_pct": 45 },
      { "species_code": "DISP", "cover_pct": 20 }
    ],
    "notes": "Reclassified Spartina patch in NE corner to DIST."
  }
}
```

#### Analysis

- **Preserve all submitted observations** (gate): **passes** — Every accepted submission is stored as an immutable revision in the visit's history; resolutions create a new revision citing `resolved_revision_ids` without mutating or deleting prior revisions.
- **Scientific coherence of combined records** (major): **strong** — A visit is never assembled from parts of different submissions without a coordinator inspecting both complete submissions side by side. Cross-field relationships (such as a species reclassification paired with a cover adjustment and explanatory note) stay intact unless deliberately combined during manual review.
- **Rule maintenance and operational simplicity** (major): **strong** — The record store only compares `base_revision_id` against the visit's active head set. No per-field diffing, list-element identity matching, or botanical coupling rules need to be authored or maintained.
- **Coordinator review queue volume** (moderate): **weak** — Any two concurrent edits to the same visit produce competing active heads and require coordinator resolution, even when one worker only corrected an observer name and another edited species cover.
- **Client and review-surface footprint** (minor): **strong** — Tablets only track a single `base_revision_id` string alongside the local visit draft, and the coordinator review screen compares complete visit revisions rather than per-field provenance trees.

#### Summary

Guarantees that every current visit was either submitted whole by one worker or explicitly reviewed by a coordinator, at the cost of sending all concurrent same-visit edits to the coordinator review queue.

### Option 2: Field-Aware Three-Way Merge

#### Description

Each edit is evaluated against the full base snapshot the worker started from. The client submits either the base snapshot and structured field deltas or the base revision and modified visit, and the server performs a field-by-field three-way merge against the current visit state:

- Scalar fields (`observation_date`, `notes`, `plot_id`) merge automatically if only one branch modified the field relative to the common base revision.
- Collection fields (`observers`, `species_cover`) merge using element-key rules (for example, matching `species_cover` entries by `species_code` and `observers` by normalized name): disjoint additions, removals, or single-side updates combine automatically into a merged visit revision.
- Only when both branches modify the same scalar field or the same keyed collection entry does the visit enter `needs_review` with field-level conflict markers.

Why this option remains credible: across 6,000 seasonal visits, many post-visit edits are routine bookkeeping—adding a forgotten second observer, fixing a date typo, or appending a site-access note—while another worker enters or refines species cover. Field-aware three-way merge clears those disjoint edits automatically so more visits are immediately ready for the Friday partner CSV without coordinator intervention.

#### Demonstration

```json
// Base rev_01: observers=["A. Rivera"], species_cover=[{SPAL: 65}], notes=""
// Edit A (from rev_01): species_cover=[{SPAL: 45}, {DISP: 20}] (split misidentified grass)
// Edit B (from rev_01): notes="SPAL cover is high across entire plot; no DISP present."
// Auto-merged result: species_cover=[{SPAL: 45}, {DISP: 20}], notes="SPAL cover is high across entire plot; no DISP present."
```

#### Analysis

- **Preserve all submitted observations** (gate): **passes** — Original submissions and deltas remain stored in the audit history alongside the auto-merged revision.
- **Scientific coherence of combined records** (major): **weak** — Disjoint fields can be scientifically coupled even when their schema keys do not overlap. In the demonstration above, Edit A split `SPAL` into `SPAL` + `DISP`, while Edit B added a note asserting `DISP` is absent based on the base `species_cover`; an automatic merge combines both into a self-contradictory record that bypasses coordinator review and exports directly to the Friday CSV. Similarly, re-identifying a species (`SPAL` → `SPPA`) looks like deleting one keyed entry and inserting another, which can silently combine with a concurrent edit to another species even when total canopy cover assumptions were linked.
- **Rule maintenance and operational simplicity** (major): **weak** — Requires defining and maintaining merge semantics for scalars, observer sets, and keyed species rows, plus deciding whether cross-field coupling rules should force conflicts. Any future schema addition requires new merge rules and edge-case tests.
- **Coordinator review queue volume** (moderate): **strong** — Routine disjoint edits (e.g., observer list fixes vs. species cover edits) merge automatically without entering the coordinator queue.
- **Client and review-surface footprint** (minor): **weak** — Tablets must retain full base snapshots (or compute structured diffs offline), and `review-export` must display field-level provenance showing which submission contributed each field alongside partial-record conflict resolution controls.

#### Summary

Reduces coordinator review work for routine disjoint edits, but requires maintained per-field merge rules and risks exporting unreviewed records whose fields are scientifically contradictory.

## Selection

**Chosen: Option 1 — Whole-Visit Revisions.**

Whole-visit revisions win on both **major** criteria (**Scientific coherence of combined records** and **Rule maintenance and operational simplicity**). Because the server cannot infer when edits to different fields (such as two different species codes, or a species cover entry and the visit notes) represent a single coupled scientific judgment, automatically merging disjoint fields risks exporting hybrid records that no observer or coordinator ever validated. With ~6,000 visits per season and two coordinators already reviewing anomalies before the weekly export, a larger review queue for concurrent same-visit edits is a safer and more predictable cost than maintaining domain-specific merge heuristics. This aligns with the HLD tenets *Keep the path from a submitted observation to an exported value inspectable* and *Prefer workflows two coordinators can operate without a dedicated systems administrator*, as well as the non-goal against *automated botanical validation or inference of scientific intent*.

### What This Forecloses

- Disjoint concurrent edits to the same visit will not auto-resolve; every concurrent edit to an already-updated visit requires a coordinator resolution before that visit is eligible for the Friday CSV export.

### Downstream Obligations to Accommodate

1. **`tablet-sync` must accommodate**:
   - **Base revision tracking**: When downloading or creating a visit, the tablet must store the server's `revision_id` as the local draft's `base_revision_id` (`null` if created offline before first sync).
   - **Whole-visit submission envelopes**: Submissions must send the complete `VisitPayload` along with `base_revision_id` and a client-generated `idempotency_key` so retries after connection drops remain idempotent.
   - **Conflict visibility without blocking field work**: When a submission returns `needs_review` (or when syncing a visit that has competing active heads on the server), the tablet must explain to the worker that competing revisions are awaiting coordinator review, and make clear which revision a new local edit will use as its `base_revision_id`.
2. **`review-export` must accommodate**:
   - **Revision comparison screen**: Coordinators need a view that loads all `active_head_revisions` for a visit in `needs_review` (alongside their common `base_revision_id` when present), highlights differences across the complete visit payloads, and lets the coordinator pick a winning revision or author a combined payload.
   - **Explicit head resolution**: When submitting a resolution to `POST /visits/{visit_id}/resolutions`, `review-export` must pass the exact list of `resolved_revision_ids` the coordinator inspected so a late-arriving tablet submission is not accidentally marked resolved.
   - **Export gating and provenance**: The Friday CSV export must exclude any visit whose status is `needs_review` (surfacing the count of held visits to coordinators before export) and trace each exported visit row directly to its single `current` revision ID.
```

---

### Remaining Phase 2 Check

Does this decision doc and the `record-store` LLD look good to approve for Phase 2, and how would you like to handle the 6 LLD edge-case probe items from above (tighten any now in `record-store-design.md`, or defer them) before we proceed to Phase 3 (`record-store-specs.md`)?