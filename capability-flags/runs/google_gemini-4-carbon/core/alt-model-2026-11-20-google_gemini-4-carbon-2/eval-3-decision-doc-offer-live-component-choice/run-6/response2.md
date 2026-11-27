I have written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Concurrent visit edit policy` row (and `References`) in `docs/intent/record-store/record-store-design.md`.

### Decision Doc (`docs/intent/record-store/decisions/concurrent-visit-edits.md`)

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Reconciliation

## Context

TidePlot serves 24 seasonal field workers sharing 12 Android tablets across 320 permanent coastal plots, producing roughly 6,000 plot-visit records per season. Tablets operate offline for up to 48 hours, and workers sometimes correct the same visit independently after comparing field notes. Each visit contains a plot reference (`plotId`), observation date (`observationDate`), observer names (`observers`), species cover estimates (`speciesCover`), and free-text `notes`. Two coordinators resolve questions about observations and deliver a reviewed CSV to a regional science partner every Friday.

Because edits arrive hours or days after their starting state was fetched, `record-store` cannot treat server arrival order as authority and cannot overwrite prior submissions in place. Every viable concurrency design in `record-store` must retain all original worker submissions with their author identities and receipt times, enforce idempotent retries, and expose whether a visit has unresolved review work. Within those standing invariants, `record-store` must still choose the unit at which concurrent edits are tracked, reconciled, and handed across contracts to `tablet-sync` and `review-export`.

If this choice is wrong in one direction, automated reconciliation combines edits across fields that carry unstated botanical relationships—producing an exported visit no worker observed and no coordinator reviewed. If it is wrong in the other direction, routine non-overlapping corrections flood the two coordinators ahead of the Friday export, delaying valid records and increasing human merge errors under review fatigue.

## Decision Elements

All options in contention preserve original submissions and reject arrival-order overwrites; no binary gate eliminates an option here. Selection turns on five weighted criteria:

- **Cross-field scientific integrity (`major`)** — Derives from the HLD tenet *Do not silently discard a submitted edit* (preserving observational meaning, not only stored bytes) and the HLD non-goal *Automated botanical validation or inference of scientific intent*. Evaluates how reliably the mechanism avoids synthesizing scientifically inconsistent combinations of fields within a visit.
- **Coordinator review load and Friday export readiness (`major`)** — Derives from the HLD tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*. Evaluates how well two coordinators can clear weekly review volume before Friday exports without manual-reconciliation fatigue on routine orthogonal fixes.
- **End-to-end lineage inspectability (`moderate`)** — Derives from the HLD tenet *Keep the path from a submitted observation to an exported value inspectable*. Evaluates how directly a coordinator or science partner can trace every exported visit value back to submitted observations and human decisions.
- **Rule maintenance and cross-node contract complexity (`moderate`)** — Derives from the HLD tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*. Evaluates the complexity of reconciliation logic, failure modes, and contract surface across `record-store`, `tablet-sync`, and `review-export` as visit schemas evolve.
- **Convergence across offline tablet shifts (`minor`)** — Derives from the HLD tenet *Let field workers continue collecting observations without connectivity*. Evaluates whether subsequent tablet shifts syncing from the server receive a single settled visit immediately after non-overlapping concurrent edits or must work around pending review state.

## Options in the Domain

### Whole-Visit Revisions

#### Description

Each worker submission carries a complete visit payload and the `baseRevisionId` of the revision the draft started from (`null` for initial visit creation). `record-store` stores each accepted submission as an immutable revision in a per-visit directed acyclic graph. When a submission's `baseRevisionId` matches the visit's sole active leaf revision, the new revision supersedes it as `currentRevision` (`status = current`). When a submission references an already-superseded revision, `record-store` retains all active leaf revisions as `competingRevisions` (`status = unresolved`, `currentRevision = null`) alongside their lowest common ancestor (`commonBaseRevision`). A coordinator resolves an `unresolved` visit by inspecting the competing whole-visit payloads against `commonBaseRevision` and submitting a resolved whole-visit payload naming the exact `contributingRevisionIds` reviewed, creating a single new leaf revision (`status = current`).

#### Demonstration

Suppose `R1` records plot `UUID-42` with observers `["Patel"]`, species `[{"taxon": "Spartina patens", "cover": 35}]`, and empty notes:

- **Coupled edit vs. disjoint edit**: Offline on Tablet 1, Worker A realizes *Spartina patens* was misidentified *Distichlis spicata* and submits `R2` (`baseRevisionId = R1`) replacing that entry with `{"taxon": "Distichlis spicata", "cover": 30}` and adding a note explaining the voucher check. Offline on Tablet 2, Worker B notices *Spartina patens* cover was under-counted on the sheet and submits `R3` (`baseRevisionId = R1`) updating *Spartina patens* cover to `40` and adding `"Kim"` to `observers`. Both `R2` and `R3` remain intact leaves (`status = unresolved`), preventing `notes` or species entries from being combined across incompatible identifications.
- **Purely disjoint edits**: If Worker A only adds `"Kim"` to `observers` in `R2` while Worker B only adds a field note in `R3` (both from `R1`), `record-store` likewise marks the visit `unresolved` with competing leaves `{R2, R3}` until a coordinator submits a combined whole-visit resolution `R4`.

#### Analysis

- **Cross-field scientific integrity — strong fit.** Every `current` visit is either a single worker's complete submission or a coordinator's explicit whole-visit resolution; `record-store` never combines fields across independent edits on its own.
- **Coordinator review load and Friday export readiness — weak fit.** Any concurrent pair of edits sharing a superseded base revision enters the coordinator queue and withholds the entire visit from the Friday CSV until resolved, even when one edit only corrected an observer list and the other only added notes; high volumes of unrelated concurrent edits require manual re-combination by coordinators.
- **End-to-end lineage inspectability — strong fit.** Every exported row traces to a single `currentRevision` whose lineage points directly to a worker submission or a coordinator resolution over an explicit set of `contributingRevisionIds`, with no per-field merge trace required to explain the record.
- **Rule maintenance and cross-node contract complexity — strong fit.** `record-store` tracks revision graph leaves without field-specific merge semantics; `tablet-sync` tracks only a `baseRevisionId` per draft rather than full base snapshots; `review-export` implements one whole-visit comparison and resolution flow.
- **Convergence across offline tablet shifts — partial fit.** Tablets continue capturing and editing visits offline against known revision IDs, but concurrent edits to unrelated fields leave the visit in `status = unresolved` across syncing tablets until a coordinator resolves the branch set.

#### Summary

Preserves whole-observation scientific coherence and keeps sync and storage contracts compact, at the cost of routing every concurrent edit on a visit through manual coordinator review and holding those visits out of export until resolved.

### Field-Aware Three-Way Merge

#### Description

Each worker edit supplies its starting revision reference (backed by a local base snapshot on the tablet) and structured changes across the visit's fields: scalar attributes (`plotId`, `observationDate`, `notes`), the `observers` set/list, and `speciesCover` entries keyed by taxon identifier. When an edit arrives against a superseded base revision, `record-store` computes a three-way merge against the base revision and subsequent changes:

- Edits touching disjoint fields or distinct species keys combine automatically into a new merged `currentRevision` (`status = current`), recording field-level provenance that maps each resulting field or species entry to the submission ID that supplied it.
- Edits that modify the same scalar field to different values, make incompatible changes to `observers`, or modify the same taxon key in `speciesCover` to different values transition the visit to `status = unresolved`, isolating the overlapping fields for coordinator resolution while preserving non-overlapping changes.

Original submissions are still stored immutably alongside any merged or coordinator-resolved representation.

#### Demonstration

Starting from the same `R1` on plot `UUID-42`:

- **Purely disjoint edits**: Worker A adds `"Kim"` to `observers` while Worker B adds a drainage note to `notes` (both based on `R1`). `record-store` automatically produces a merged `current` revision containing `["Patel", "Kim"]` and the drainage note, attributing `observers` to Worker A's submission and `notes` to Worker B's submission; the visit is immediately ready for the Friday CSV without coordinator action.
- **Coupled edit across distinct keys**: Worker A (`baseRevisionId = R1`) deletes `"Spartina patens"` and inserts `"Distichlis spicata": 30` after re-identifying the specimen, while Worker B (`baseRevisionId = R1`) adds a trace `"Salicornia pacifica": 5` observed in the same quadrat and updates `notes` referencing `"total graminoid cover alongside Spartina"`. Because `"Spartina patens"`, `"Distichlis spicata"`, `"Salicornia pacifica"`, and `notes` are distinct keys unless custom coupling rules forbid combining species-map edits with note edits, an automated merge combines Worker A's taxonomic replacement with Worker B's *Spartina*-referencing note into a `current` exportable record without coordinator review.

#### Analysis

- **Cross-field scientific integrity — weak fit.** Key-disjoint edits across `speciesCover`, `observers`, `observationDate`, and `notes` combine automatically even when one worker's change invalidates the scientific premise of another's (for example, taxonomic re-identification paired with cover adjustments or notes referencing the prior species). Preventing those combinations requires encoding domain-specific coupling rules that approach botanical inference.
- **Coordinator review load and Friday export readiness — strong fit.** Routine concurrent updates to unrelated fields (such as observer names versus field notes, or independent additions of missed species) converge automatically into `status = current`, keeping those visits eligible for the Friday CSV and focusing coordinator review on direct field collisions.
- **End-to-end lineage inspectability — partial fit.** Field-level provenance links each exported attribute to a contributing submission or resolution, keeping individual cell origins auditable, but explaining why a composite visit exists requires reconstructing how scalar, list, and taxon-key merge rules interacted across multiple submissions.
- **Rule maintenance and cross-node contract complexity — weak fit.** `record-store` must define and maintain deterministic merge semantics for scalars, observer collections, and species maps (including list ordering, taxon-key deletion-vs-modification rules, and multi-hop chains of three-way merges); `tablet-sync` must persist full base snapshots to compute structured deltas offline; `review-export` must render field-level provenance and partial-conflict resolution views.
- **Convergence across offline tablet shifts — strong fit.** Non-overlapping edits from separate offline tablets merge immediately on sync into a single `currentRevision`, giving the next tablet shift one settled record without waiting for coordinator turnaround.

#### Summary

Minimizes coordinator review queues and maximizes automatic export readiness for non-overlapping edits, at the cost of silently combining scientifically coupled cross-field edits and maintaining structured diff, merge, and field-provenance machinery across all three subsystems.

## Selection

Select **Whole-Visit Revisions**.

The two `major` criteria pull in opposite directions, and this decision prioritizes **Cross-field scientific integrity** over **Coordinator review load and Friday export readiness**. In vegetation survey data, scientific dependencies routinely cross structural field boundaries—a taxonomic correction changes how cover percentages and notes must be read—and TidePlot explicitly avoids automated inference of scientific intent. Routing concurrent edits on the same visit to human coordinators upholds *Do not silently discard a submitted edit* at the level of observational meaning, not merely stored payloads. The two `moderate` criteria reinforce this choice: whole-visit lineage directly satisfies *Keep the path from a submitted observation to an exported value inspectable*, and avoiding maintained merge semantics across scalars, observer lists, and species maps honors the operational-simplicity side of *Prefer workflows two coordinators can operate without a dedicated systems administrator*.

The decision knowingly trades against the review-volume side of *Prefer workflows two coordinators can operate without a dedicated systems administrator* and accepts only partial fit on *Let field workers continue collecting observations without connectivity* when concurrent offline edits wait on coordinator resolution. **Field-Aware Three-Way Merge** remains the primary alternative to revisit if seasonal concurrency rates on unrelated fields (for example, routine administrative fixes to observer lists after tablet sync) grow high enough to bottleneck Friday exports or cause coordinator errors during manual whole-visit recombination.

### Implications of Committing

**What this forecloses:**

- Automatic server-side combination of concurrent edits to disjoint fields of the same visit; any edit against a superseded revision transitions the visit to `status = unresolved` (`currentRevision = null`).
- Field-level conflict isolation and per-field provenance in `record-store`'s initial data model and APIs.

**Downstream obligations across sibling nodes:**

- **`tablet-sync` must accommodate:**
  - Recording the `revisionId` from which each local visit draft began and sending that `baseRevisionId` alongside the complete visit `payload` and a per-edit `idempotencyKey` on submission.
  - Representing `status = unresolved` locally when submission or `List visits` sync reports competing leaf revisions—explaining to field workers that competing submissions are pending coordinator review rather than presenting either the local draft or the earliest-synced revision as settled, and defining which revision ID anchors any further offline edit on that visit.
- **`review-export` must accommodate:**
  - Driving a coordinator review queue from `status = unresolved` visits and providing a whole-visit comparison interface that renders all `competingRevisions` alongside their `commonBaseRevision` (diffing fields visually for coordinator inspection without auto-merging them).
  - Submitting coordinator resolutions as complete visit payloads paired with the exact `contributingRevisionIds` inspected—allowing coordinators either to adopt one competing revision intact or to author a reconciled whole-visit payload—and handling `stale-review` conflicts if another offline tablet syncs an edit to that visit mid-review.
  - Holding every `status = unresolved` visit out of the weekly partner CSV export (`status = current` only) while surfacing unresolved visit counts to coordinators ahead of the Friday export.
```

---

### Remaining Phase 2 Check Before Phase 3 (`record-store-specs.md`)

1. Do `concurrent-visit-edits.md` and `record-store-design.md` look ready?
2. From the Phase 2 edge-case probe on `record-store-design.md`, would you like to settle any of the six items (`plotId` mutability across revisions, identical competing payloads, duplicate `baseRevisionId: null` on an existing `visitId`, idempotency key scope/retry status, scientific `payload` bounds, and read/resolution error & ordering rules) in the LLD now, or defer some/all under `Open Questions & Future Decisions` and proceed to **Phase 3** (updating `docs/intent/record-store/record-store-specs.md`)?