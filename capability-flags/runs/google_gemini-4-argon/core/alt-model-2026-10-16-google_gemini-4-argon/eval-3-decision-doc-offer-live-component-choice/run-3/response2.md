I have written `docs/intent/record-store/decisions/concurrent-visit-reconciliation.md` and linked it from the `Decisions & Alternatives` table and `References` section in `docs/intent/record-store/record-store-design.md`.

### `docs/intent/record-store/decisions/concurrent-visit-reconciliation.md`

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Reconciliation

## Context

TidePlot serves 24 seasonal field workers sharing 12 Android tablets across 320 permanent coastal vegetation plots, producing roughly 6,000 plot-visit records per season. Tablets operate offline for up to 48 hours. Workers frequently review paper or verbal field notes after returning from a site and independently submit corrections to the same visit from different tablets before syncing. Two coordinators manage data quality and deliver a reviewed CSV export to a regional science partner every Friday.

Every visit record contains a plot reference (`plotId`), observation date, observer list, species cover estimates, and free-text notes. Two domain invariants govern any concurrency mechanism in `record-store`:

- **No silent data loss**: Per the High-Level Design tenet *Do not silently discard a submitted edit*, arrival order at the server is not evidence of authority. Naive last-write-wins or timestamp-ordered overwrite is outside the viable design space because a tablet syncing later after a 48-hour disconnection would silently erase an earlier correction. Every accepted worker submission must be retained immutably.
- **No unverified botanical inference**: Per the High-Level Design non-goal excluding *automated botanical validation or inference of scientific intent*, fields within a visit can carry domain coupling that is invisible to schema structure—for example, changing a misidentified Carex species code while adjusting its cover percentage and updating the habitat note explaining that cover value.

Because `record-store` defines how concurrent submissions become a settled visit or enter review, this choice determines the submission payload contract, the local tracking state in `tablet-sync`, and the coordinator workflow and CSV eligibility rules in `review-export`.

## Decision Elements

### Weighted Criteria

- **Cross-field scientific coherence (major)** — Derived from the tenet *Keep the path from a submitted observation to an exported value inspectable* and the non-goal against *automated botanical validation or inference of scientific intent*. Measures whether the mechanism preserves a worker's observation as a scientifically coherent whole or risks assembling synthetic records from independently edited fields whose scientific assumptions conflict.
- **Rule-maintenance and operational simplicity (major)** — Derived from the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*. Measures the complexity of server reconciliation rules, edge-case maintenance across scalar fields, set-like observer lists, and keyed species cover entries, and the cognitive load of debugging why a visit reached its current state.
- **Coordinator review queue volume before Friday export (major)** — Derived from the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator* and the goal *Make reviewable problems visible before the Friday export*. Measures how effectively the mechanism keeps routine, non-overlapping corrections out of manual review so two coordinators can clear the queue before the weekly partner export deadline.
- **Auditability and provenance clarity (moderate)** — Derived from the tenet *Keep the path from a submitted observation to an exported value inspectable*. Measures how directly an exported visit row traces back to an intact worker submission or an explicit coordinator resolution.
- **Offline tablet storage and sync payload complexity (minor)** — Derived from the tenet *Let field workers continue collecting observations without connectivity*. Measures the local state a tablet must persist across restarts and 48-hour disconnections to submit edits and represent server outcomes.

## Options in the Domain

### Option 1: Whole-Visit Revisions

#### Description

Each accepted submission creates an immutable whole-visit revision containing the complete visit payload (`plotId`, `observationDate`, `observers`, `speciesCoverEstimates`, `notes`) and the `baseRevisionId` the worker started from (`null` for initial creation).

When a visit is in `current` state and an incoming submission's `baseRevisionId` matches the visit's single active head revision, the new revision supersedes the head and becomes the new `current` revision immediately. When an incoming submission's `baseRevisionId` refers to an already-superseded revision—or when the visit already has unresolved competing revisions—`record-store` records the submission as an additional active head revision and places the visit in `needs_review`. A coordinator resolves a `needs_review` visit by comparing the competing whole-visit revisions against their referenced `baseRevisions` and recording a new whole-visit revision that supersedes the resolved heads.

#### Demonstration

```text
Initial sync:
  rev-1 (status: current)
    observers: ["Ada", "Ben"]
    speciesCoverEstimates: [{ species: "Spartina alterniflora", coverPct: 40 }]
    notes: "Dense lower-marsh stand"

Worker A edits from rev-1 (fixes observer list):
  submits baseRevisionId: rev-1 -> creates rev-2 (status: current, head: [rev-2])

Worker B edits offline from rev-1 (re-identifies species and updates note):
  submits baseRevisionId: rev-1 -> rev-1 is already superseded by rev-2
  creates rev-3 (status: needs_review, heads: [rev-2, rev-3], base: [rev-1])

Coordinator resolves [rev-2, rev-3]:
  creates rev-4 (status: current, head: [rev-4], supersedes: [rev-2, rev-3])
```

#### Analysis

- **Cross-field scientific coherence**: **strong** — Every revision is either an intact snapshot submitted by a single worker or an explicit whole-visit snapshot approved by a coordinator; the server never combines fields from separate submissions automatically.
- **Rule-maintenance and operational simplicity**: **strong** — Conflict detection depends only on comparing `baseRevisionId` against the visit's active head `revisionId`; no per-field diffing or collection merge rules are required even if visit schema fields change.
- **Coordinator review queue volume before Friday export**: **weak** — Any two concurrent edits based on the same revision enter `needs_review` and block that visit from export until a coordinator acts, even when the workers edited unrelated fields such as `observers` and `notes`.
- **Auditability and provenance clarity**: **strong** — Every settled visit points to a single revision ID created either by one worker submission or one coordinator resolution naming the exact competing revisions it superseded.
- **Offline tablet storage and sync payload complexity**: **strong** — Tablets store only the latest synced `revisionId` alongside the current visit snapshot and submit full visit payloads, which are small (~1–2 KB of structured JSON per visit).

#### Summary

Preserves cross-field scientific integrity and keeps server and tablet state machines simple, at the cost of routing all concurrent edits—including disjoint field fixes—through manual coordinator review.

---

### Option 2: Field-Aware Three-Way Merge

#### Description

Each edit submission supplies the base visit state (or base revision reference with stored server snapshot) alongside structured field-level changes against that base. When concurrent edits arrive derived from the same base state, `record-store` computes a three-way merge across the visit's fields relative to their common base snapshot:

- **Scalar fields (`observationDate`, `notes`, `plotId`)**: If only one submission changed the scalar relative to base, or both changed it to the identical value, the change is applied automatically; if both changed it to different values, that field is marked conflicted.
- **Set-like lists (`observers`)**: Additions and removals relative to base are unioned automatically unless the same entry is simultaneously modified in incompatible ways.
- **Keyed collections (`speciesCoverEstimates`)**: Additions of distinct species codes merge automatically; concurrent edits to the same species code (or removal vs. cover modification of the same species) flag a conflict on that species entry.

If all modified fields merge cleanly without overlap, `record-store` produces a merged current revision automatically and attaches field-level provenance linking each field or collection entry to the `submissionId` that supplied it. If any field or entry overlaps in conflict, the visit enters review with the non-conflicting fields pre-merged and the overlapping fields highlighted for coordinator resolution.

Why this option remains a credible alternative: in field operations where most post-survey corrections are administrative and orthogonal (for example, one worker adding a forgotten co-observer while another corrects a date or appends a site access note), three-way merging resolves those edits without human intervention, keeping the weekly review queue small and maximizing the share of visits ready for the Friday CSV export.

#### Demonstration

```text
Base snapshot (rev-1):
  observers: ["Ada"]
  speciesCoverEstimates: [{ species: "Spartina patens", coverPct: 25 }]
  notes: "Upper marsh edge"

Worker A (from rev-1): adds "Ben" to observers
Worker B (from rev-1): changes "Spartina patens" to "Distichlis spicata" (coverPct: 25)
  and updates notes to "Re-keyed grass voucher from upper marsh edge"

Three-way merge outcome:
  Disjoint fields (observers vs. speciesCoverEstimates + notes) -> auto-merged into rev-m1
  Status: current (no coordinator review triggered)
  Provenance: observers <- sub-A; speciesCoverEstimates, notes <- sub-B
```

If instead Worker A adjusted `Spartina patens` cover to 35% based on a field sketch while Worker B replaced `Spartina patens` with `Distichlis spicata` at 25% and updated `notes`, a species-keyed merge either flags only the `Spartina patens` deletion/update while auto-merging `notes` and `Distichlis spicata`, or requires custom cross-species conflict rules to recognize that the two changes refer to the same physical plant patch.

#### Analysis

- **Cross-field scientific coherence**: **weak** — Disjoint field changes can be scientifically coupled without overlapping on the same schema key (for example, one worker adjusting a cover estimate or habitat note under the original species assumption while another worker re-identifies the species under a different key), allowing automatic merges to construct composite records no worker intended.
- **Rule-maintenance and operational simplicity**: **weak** — Requires defining, testing, and maintaining merge semantics and identity keys for scalars, observer lists, and species cover entries, plus per-field provenance tracking; any schema addition requires new merge rules.
- **Coordinator review queue volume before Friday export**: **strong** — Orthogonal edits (such as observer list fixes vs. species cover additions) combine automatically and become immediately eligible for export, reserving coordinator attention for direct field collisions.
- **Auditability and provenance clarity**: **partial** — Tracing an exported visit requires field-level provenance metadata (`field -> submissionId`) and merge-rule history rather than pointing to a single worker submission or coordinator resolution.
- **Offline tablet storage and sync payload complexity**: **partial** — Tablets must retain full immutable base snapshots alongside working drafts to compute or verify structured field diffs across multi-day offline sessions, and conflict UIs must render partial merges with field-level conflict markers.

#### Summary

Minimizes manual coordinator review for unrelated field edits and keeps more visits immediately export-ready, at the cost of maintaining collection merge rules and risking silent cross-field scientific inconsistencies.

## Selection

**Selected option: Option 1 — Whole-Visit Revisions.**

### Why It Wins

The decision turns on a trade between two major criteria anchored in the project's tenets: **Cross-field scientific coherence** and **Rule-maintenance and operational simplicity** on one side, and **Coordinator review queue volume before Friday export** on the other.

In vegetation surveys, a plot visit is recorded as an interdependent scientific observation: species identifications, percent-cover estimates (which must make ecological sense together on the same plot), and explanatory field notes routinely depend on one another across schema fields and across different species keys. Under **Field-Aware Three-Way Merge**, two workers correcting the same visit from different angles—such as one worker re-identifying a grass voucher under a new species key while another worker adjusts cover percentages or notes under the prior identification—can touch disjoint keys and merge automatically without coordinator review. Avoiding silent synthetic combinations aligns directly with the HLD tenet *Do not silently discard a submitted edit*, the tenet *Keep the path from a submitted observation to an exported value inspectable*, and the non-goal against *automated botanical validation or inference of scientific intent*.

At TidePlot's scale (~6,000 visits per season across 24 workers), concurrent post-survey edits to the *same* visit occur on a bounded subset of records. The two coordinators can absorb a larger review queue of side-by-side whole-visit comparisons more reliably than a seasonal team without a dedicated systems administrator can maintain and debug field-level merge heuristics (`Prefer workflows two coordinators can operate without a dedicated systems administrator`).

### When to Reconsider Option 2

A future maintainer should revisit **Field-Aware Three-Way Merge** (or a hybrid that auto-merges only administrative metadata such as `observers` while treating `speciesCoverEstimates` and `notes` as a single atomic block) if operational data shows that:

1. Concurrent disjoint edits (especially administrative fixes to `observers` or `observationDate`) generate enough `needs_review` volume to routinely bottleneck the two coordinators before the Friday export cutoff, and
2. The team can draw a strict boundary between administrative fields that never carry botanical coupling and scientific observation fields that must stay grouped.

### Downstream Obligations

Committing to **Whole-Visit Revisions** establishes the following requirements for sibling design nodes:

- **`tablet-sync` accommodations**:
  - **Base revision tracking**: Persist the server-assigned `revisionId` of the most recently fetched settled visit state and include it as `baseRevisionId` (`null` for new visits) in every edit submission envelope.
  - **Whole-visit payload and idempotency**: Submit the complete visit payload on each edit alongside a persistent client-generated `idempotencyKey` that survives app restarts and 48-hour disconnections until the server acknowledges acceptance.
  - **Conflict state presentation**: When a submission response or sync refresh reports `status: needs_review`, display that the visit has competing revisions awaiting coordinator review and expose the competing whole-visit snapshots rather than attempting client-side field merging.
- **`review-export` accommodations**:
  - **Whole-visit revision comparison view**: Present coordinators with all active `competingRevisions` for a `needs_review` visit alongside their referenced `baseRevisions` so the coordinator can see what each worker changed relative to their starting revision and either select one revision intact or author a reconciled whole-visit payload.
  - **Explicit resolution lineage**: Submit coordinator resolutions naming the specific `resolvedRevisionIds` being superseded so `record-store` can record `coordinatorId`, contributing `submissionId`s, and the new head revision—and leave the visit in `needs_review` if a new worker submission arrived while the coordinator was reviewing.
  - **Export hold on unresolved visits**: Exclude any visit whose `record-store` status is `needs_review` from the Friday partner CSV export, surfacing the count and list of held visits to coordinators before export generation.
```

---

### Next Step (Phase 2 Review Stop)

Please review `docs/intent/record-store/record-store-design.md` and `docs/intent/record-store/decisions/concurrent-visit-reconciliation.md`.

1. Do you approve the `record-store` LLD and decision doc as written, or would you like any changes?
2. Would you like to resolve any of the Phase 2 edge-case items now (e.g., `plotId` mutability across revisions, `baseRevisionId: null` collisions, or coordinator resolution idempotency), or leave them under `Deferred` and proceed to Phase 3 (`docs/intent/record-store/record-store-specs.md`)?