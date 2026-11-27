`docs/intent/record-store/decisions/concurrent-visit-edits.md` has been written and linked from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`:

---

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edits

## Context

Twenty-four seasonal field workers share 12 Android tablets to survey 320 permanent coastal vegetation plots, producing roughly 6,000 visit records per season. Tablets operate without connectivity for 48 hours or more, and workers sometimes edit the same visit independently on different tablets after comparing field notes. Server receipt order reflects when a tablet regained connectivity, not which worker's observation is more accurate.

Each visit record contains a plot reference (`plotId`), `observationDate`, `observers`, `speciesCover` entries, and `notes`. Two coordinators review problem records and deliver a reviewed CSV to a regional science partner every Friday. Every viable concurrency approach in `record-store` must satisfy two standing invariants: retain every accepted worker submission with its author and receipt timestamp rather than overwriting it on arrival, and allow offline capture and submission without server-side locks.

Within those invariants, `record-store` must define how concurrent edits derived from the same starting visit state produce either an export-eligible current record or coordinator review work. Some concurrent edits are genuinely independent, such as fixing an observer's name on one tablet while adding an omitted species on another. Other edits are scientifically coupled across fields or list entries — such as re-identifying a marsh species and updating its cover estimate, or adding field notes that qualify a cover reading — in ways field names and keys cannot reveal. How `record-store` models that boundary sizes local state and sync envelopes in `tablet-sync` as well as review screens, provenance views, and CSV export rules in `review-export`.

## Decision Elements

No binary gate eliminates either contender: both preserve all raw worker submissions, operate over multi-day offline disconnections, and respect the absence of mandatory manual sign-off on uncontested visits. Selection turns on six weighted criteria:

- **Cross-field scientific integrity (major)** — Avoid producing an export-eligible visit whose fields combine separate submissions without coordinator review when those fields may carry unstated botanical dependencies. Grounded in the non-goal against *Automated botanical validation or inference of scientific intent* and the tenet *Keep the path from a submitted observation to an exported value inspectable*.
- **Coordinator review volume and Friday export readiness (major)** — Limit manual review queue size and avoid holding visits out of the weekly Friday CSV when concurrent edits touch unrelated parts of a record. Grounded in the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator* (coordinator workload) and the goal of surfacing manageable review work before Friday export.
- **End-to-end provenance inspectability (major)** — Keep the lineage from submitted field observations to exported CSV values direct enough for coordinators and science partners to verify without reconstructing automated merge steps. Grounded in the tenet *Keep the path from a submitted observation to an exported value inspectable*.
- **Merge-rule and cross-node maintenance burden (moderate)** — Minimize ongoing specification, testing, and schema coupling of concurrency rules across `record-store`, `tablet-sync`, and `review-export` as survey conventions evolve. Grounded in the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator* (operational simplicity).
- **Coordinator manual synthesis fidelity (moderate)** — Reduce the chance that a coordinator reconciling concurrent edits overlooks a change in a non-overlapping field (such as one cover value among many species) and omits it from the resolved record. Grounded in the tenet *Do not silently discard a submitted edit*.
- **Offline tablet state and sync overhead (minor)** — Keep tablet storage, crash recovery, and submission envelopes lightweight across shared tablets and 48-hour disconnections. Grounded in the tenet *Let field workers continue collecting observations without connectivity*.

## Options in the Domain

### Whole-Visit Revisions

**Description**

Every submission supplies a complete whole-visit payload and the `baseRevisionId` the tablet edited (`null` for a newly created visit). When a `clean` visit receives an edit naming its sole active tip revision, `record-store` advances `currentRevision` linearly without review. When two or more edits share a superseded `baseRevisionId` (or arrive while the visit already has competing tips), `record-store` records each as an unmerged whole-visit tip revision, sets `currentRevision` to `null`, and marks the visit `unresolved`.

`tablet-sync` stores only the latest known `revisionId` alongside each cached visit, uploads complete visit payloads, and surfaces pending competing revisions when the server reports `unresolved`. `review-export` withholds `unresolved` visits from the Friday CSV and gives coordinators a revision comparison screen showing `baseRevision` alongside all competing whole-visit revisions so a coordinator can select one revision or submit a reconciled whole-visit payload naming the `resolvedRevisionIds` reviewed.

**Demonstration**

Visit `V1` stands at `R1` (`observers: ["A. Lin"]`, `speciesCover: [{species: "Spartina alterniflora", cover: 40}]`, `notes: null`). Offline on Tablet 1, a worker corrects the observer list (`["A. Lin", "M. Ortiz"]`) and submits against `baseRevisionId: R1`, advancing `V1` to `R2` (`clean`). Offline on Tablet 2, another worker re-identifies the grass (`[{species: "Spartina patens", cover: 25}]`, `notes: "Verified ligule from voucher"`) and submits against `baseRevisionId: R1`. `record-store` records `R3` alongside `R2`, transitions `V1` to `unresolved` (`currentRevision: null`), holds `V1` out of the CSV, and presents `R1`, `R2`, and `R3` together for coordinator resolution. An unrelated edit pair (observer fix plus adding `Salicornia depressa`) follows the identical path into coordinator review.

**Analysis**

- **Cross-field scientific integrity**: **strong** — Every export-eligible visit is either one worker's intact whole-visit submission or an explicit coordinator resolution; fields from separate submissions are never combined automatically.
- **Coordinator review volume and Friday export readiness**: **weak** — Every concurrent edit from a shared base revision places the visit in `unresolved` and blocks CSV export until coordinator resolution, including disjoint fixes such as an observer correction and a note addition.
- **End-to-end provenance inspectability**: **strong** — Every exported row traces to a single whole-visit revision backed either by one worker `submissionId` or one coordinator `resolutionId` listing its contributing submissions.
- **Merge-rule and cross-node maintenance burden**: **strong** — `record-store` evaluates revision parent pointers (`baseRevisionId`) without field-type diff or merge rules, decoupling concurrency mechanics from changes inside `VisitPayload`.
- **Coordinator manual synthesis fidelity**: **weak** — When two competing revisions modify different fields across a dense species list, the coordinator must assemble a combined whole-visit payload and can omit an edit if field differences from `baseRevision` are overlooked.
- **Offline tablet state and sync overhead**: **strong** — Tablets persist a single `baseRevisionId` UUID per visit and send complete structured text payloads (~1–4 KB without photographs) without retaining separate base snapshots.

**Summary**

Preserves whole-observation scientific integrity and simple revision mechanics at the cost of routing disjoint concurrent field edits through manual coordinator review.

### Field-Aware Three-Way Merge

**Description**

Every edit tracks the full base visit snapshot it started from and submits structured changes (or a full payload diffed against the stored base revision) for scalar fields (`observationDate`, `notes`), `observers`, and keyed `speciesCover` entries. When concurrent submissions touch disjoint fields or distinct species keys relative to their base revision, `record-store` automatically combines the non-overlapping changes into a new `clean` current state with field-level provenance linking each field or entry to its originating `submissionId`. Only overlapping edits to the same scalar field, observer entry, or species key produce an `unresolved` field-conflict state held out of export.

`tablet-sync` retains immutable base visit snapshots across offline edits and restarts, computes structured changesets, and reconciles server-merged states on sync. `review-export` displays field-level provenance on auto-merged visits, restricts manual coordinator review to overlapping field conflicts, and allows auto-merged visits with no overlapping conflicts directly into the Friday CSV.

**Demonstration**

Starting from `R1` above, if Tablet 1 adds `"M. Ortiz"` to `observers` and Tablet 2 adds `{species: "Salicornia depressa", cover: 10}` to `speciesCover` (both based on `R1`), `record-store` merges both disjoint changes automatically into a `clean` export-eligible state attributing `observers` to Tablet 1's submission and `Salicornia depressa` to Tablet 2's submission. However, if Tablet 1 adjusts `notes` (`" grazed patch — 40% Spartina alterniflora confirmed"`) while Tablet 2 replaces `Spartina alterniflora` (deleted) with `Spartina patens` (`cover: 25`), those changes touch distinct fields/keys (`notes` vs. two separate species keys) and also merge automatically without coordinator review, pairing Tablet 1's note confirming `Spartina alterniflora` with Tablet 2's species list that removed it.

**Analysis**

- **Cross-field scientific integrity**: **weak** — Disjoint field and species-key changes combine automatically into an export-eligible visit without human inspection, allowing coupled edits (such as species re-identifications paired with cover or note updates) to produce internally inconsistent botanical records.
- **Coordinator review volume and Friday export readiness**: **strong** — Non-overlapping concurrent corrections merge automatically into `clean` export-ready records, keeping routine disjoint fixes out of the two coordinators' pre-Friday review queue.
- **End-to-end provenance inspectability**: **partial** — Field-level provenance links each exported value to an originating submission, but auditing why a combined visit exists requires tracing per-field merge rules across a base snapshot and multiple change envelopes.
- **Merge-rule and cross-node maintenance burden**: **weak** — Requires specifying, testing, and maintaining merge semantics for scalars, observer sets/lists, and species entries (where renaming a species collides with delete-plus-insert rules) across `record-store`, `tablet-sync`, and `review-export`.
- **Coordinator manual synthesis fidelity**: **strong** — Disjoint edits are preserved automatically by the merge rules, focusing human coordinator attention strictly on overlapping field values.
- **Offline tablet state and sync overhead**: **partial** — Reduces edit payload size on the wire, but requires shared offline tablets to store and manage immutable base snapshots alongside mutable drafts across restarts.

**Summary**

Automates disjoint concurrent fixes to shrink the Friday review queue and prevent manual copy omissions, at the cost of maintained per-field merge rules that can silently combine scientifically coupled edits.

## Selection

Select **Whole-Visit Revisions**.

Across the major criteria, preserving **cross-field scientific integrity** and **end-to-end provenance inspectability** outweighs automating **coordinator review volume** at TidePlot's operating scale (~6,000 visits per season across 320 plots, where concurrent offline edits affect only the subset of visits independently corrected on separate tablets). Because botanical coupling between species identifications, cover percentages, and qualifying notes cannot be inferred from field names — and *Automated botanical validation or inference of scientific intent* is an explicit non-goal — automated disjoint-field merging risks exporting composite records neither field worker observed. Whole-visit revisions uphold *Keep the path from a submitted observation to an exported value inspectable* and lean on the operational-simplicity side of *Prefer workflows two coordinators can operate without a dedicated systems administrator* by avoiding maintained merge rules, while consciously accepting more manual queue items on the coordinator-workload side of that same tenet.

**When to reconsider Field-Aware Three-Way Merge**: Field-aware merging remains credible if seasonal visit volume, multi-tablet concurrency, or turn-around frequency grows to the point where disjoint-field collisions routinely exceed what two coordinators can clear before the Friday export, or if the visit schema introduces strictly administrative metadata fields guaranteed to have no scientific coupling to observation fields.

**What committing forecloses and obligates downstream**:

- **Foreclosed**: Automatic server-side combination of concurrent edits (even on non-overlapping fields) and delta-only submission envelopes.
- **`tablet-sync` accommodations**:
  - Persist the server-returned `revisionId` as `baseRevisionId` alongside each locally cached visit and draft across app restarts and 48-hour offline periods.
  - Submit complete whole-visit payloads paired with `baseRevisionId` (`null` on initial creation) and a per-attempt `idempotencyKey`.
  - Handle `reviewState: unresolved` in submission acceptance and visit retrieval responses by surfacing pending competing revisions to field workers rather than treating an arbitrary branch as authoritative or silently overwriting local drafts.
- **`review-export` accommodations**:
  - Provide a pre-Friday coordinator queue of `unresolved` visits and hold all `unresolved` visits out of the partner CSV export (exporting `currentRevision.payload` only for `clean` visits).
  - Render a whole-visit revision comparison view anchored to `baseRevision` and all active `competingRevisions`, explicitly highlighting per-field differences from `baseRevision` across competing branches so coordinators do not overlook non-overlapping edits when assembling a reconciled whole-visit payload (mitigating the manual synthesis fidelity risk under *Do not silently discard a submitted edit*).
  - Submit coordinator resolutions with the exact `resolvedRevisionIds` reviewed and refresh the comparison screen if a late-arriving offline submission triggers a stale-resolution conflict response.
```

---

Does this decision doc capture the reasoning and downstream obligations as you want it?

Before we exit **Phase 2** into **Phase 3 (`record-store-specs.md`)**, let me know whether you'd like to triage the Phase 2 LLD probe items (1–7 above — either together or one at a time) and whether to update the pending-choice notes in `docs/high-level-design.md` and `docs/intent/site-catalog/site-catalog-design.md`.