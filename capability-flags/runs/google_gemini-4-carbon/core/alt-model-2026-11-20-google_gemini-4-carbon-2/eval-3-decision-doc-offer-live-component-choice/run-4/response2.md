I have written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`. Here is the decision doc in full for review:

---

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Handling

## Context

TidePlot serves 24 seasonal field workers sharing 12 Android tablets across 320 permanent coastal vegetation plots, producing roughly 6,000 plot-visit records per season. Tablets operate offline for up to 48 hours, and workers sometimes correct the same visit independently on different tablets after comparing field notebooks. Two coordinators review open issues ahead of a weekly Friday CSV export to a regional science partner.

Each visit record contains a plot reference (`plotId`), `observationDate`, `observers`, `speciesCover` entries, and `notes`. Concurrent edits fall into two domain patterns that look similar structurally:

- **Unrelated field corrections**, such as one worker fixing an observer name spelling while another adds an overlooked species entry.
- **Scientifically coupled edits**, such as one worker re-identifying a sedge species and adjusting its cover percentage while another worker revises cover percentages or field notes under the original identification.

Field names alone do not reveal whether two edits on different fields or different species rows are scientifically independent. At the same time, server receipt order reflects when a tablet regained connectivity rather than which observation is accurate.

Every viable design in `record-store` shares two foundational invariants: all original worker submissions are retained immutably with author and receipt metadata, and arrival order never silently overwrites a concurrent edit. Within those bounds, `record-store` must define how concurrent edits from a shared starting state are represented, reconciled, and exposed to `tablet-sync` and `review-export`.

## Decision Elements

- **Cross-field scientific coherence (major)** — Whether concurrent edits can produce an active or exported visit record that combines field values no worker or coordinator ever observed or evaluated together. Derives from the HLD tenet *Do not silently discard a submitted edit* (treating silent distortion of an observation's scientific meaning on par with dropping a field) and the HLD non-goal against automated inference of scientific intent.
- **Submission-to-export provenance clarity (major)** — How directly a coordinator or regional science partner can trace an exported CSV row back to the exact submitted observation(s) and human review decisions that produced it. Derives from the HLD tenet *Keep the path from a submitted observation to an exported value inspectable*.
- **Reconciliation rule and schema maintenance (major)** — The engineering and operational cost of specifying, testing, and evolving concurrency rules across server storage, tablet sync state, and schema changes without dedicated operations staff. Derives from the HLD tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*.
- **Coordinator review throughput before Friday export (major)** — How many concurrent edits require manual coordinator intervention prior to the weekly CSV export versus becoming export-ready automatically when edits do not collide. Also engages *Prefer workflows two coordinators can operate without a dedicated systems administrator*, pulling toward smaller review queues for the two-coordinator team.
- **Manual synthesis error risk during review (moderate)** — When concurrent edits touch distinct parts of a multi-species visit, how much manual reconstruction a coordinator must perform and the resulting risk of human omission while combining edits under deadline pressure.
- **Offline client state and transmission footprint (minor)** — What baseline state tablets must persist across 48-hour disconnections and restarts (per *Let field workers continue collecting observations without connectivity*) and how much data each edit transmits on reconnection.

## Options in the Domain

### Whole-Visit Revisions

#### Description

Each accepted worker submission or coordinator resolution is stored as an immutable whole-visit revision (`revisionId`) containing the complete `VisitPayload`. When a worker edits an existing visit on a tablet, the tablet tracks only the starting `baseRevisionId` alongside the working draft and submits the complete updated visit payload.

If `baseRevisionId` is still the visit's sole active head when the submission arrives, the new revision supersedes it directly as `currentRevision` with no review needed. If another edit has already advanced from that `baseRevisionId`, both active heads remain intact as `competingRevisions`, `currentRevision` is withheld (`null`), and the visit enters `unresolved` status. A coordinator resolves competing revisions by inspecting them against their ancestor revision and submitting a complete resolved `VisitPayload` (either selecting one revision intact or reconciling fields manually), producing a new revision that supersedes the reviewed heads and records `contributingSubmissionIds`. Unresolved visits are excluded from the Friday CSV export until resolved.

#### Demonstration

Starting from `R1` (`observers: ["A. Lin"]`, `speciesCover: [{species: "Spartina alterniflora", cover: 40}]`, `notes: "wrack line"`):

- Tablet 1 submits `baseRevisionId: R1` with `observers: ["A. Lin", "M. Ortiz"]` → accepted as `R2` (`status: resolved`, `currentRevision: R2`).
- Tablet 2 (offline since `R1`) submits `baseRevisionId: R1` with `speciesCover` replacing *Spartina alterniflora* (40%) with *Spartina patens* (35%) and `notes: "re-checked ligule; high marsh"` → accepted as `R3` (`status: unresolved`, `currentRevision: null`, `competingRevisions: [R2, R3]`).
- Coordinator reviews `R2` and `R3` against `R1` and records `R4` combining both observers with `R3`'s species and note update (`status: resolved`, `currentRevision: R4`).

#### Analysis

- **Cross-field scientific coherence**: **Strong** — No automated process combines fields from separate submissions; every active `currentRevision` is either a single worker's complete submitted observation or a visit explicitly reviewed as a whole by a coordinator.
- **Submission-to-export provenance clarity**: **Strong** — Every exported visit maps to one `revisionId` backed either by a single worker `submissionId` or a coordinator `resolutionId` listing the exact `resolvedRevisionIds` and `contributingSubmissionIds`.
- **Reconciliation rule and schema maintenance**: **Strong** — `record-store` evaluates lineage solely via `baseRevisionId` and `resolvedRevisionIds` without inspecting internal field semantics; adding or changing visit fields requires no merge-rule updates.
- **Coordinator review throughput before Friday export**: **Weak** — Every concurrent edit pair produces `unresolved` review work and holds the visit out of the CSV export, even when one tablet only fixed an observer name and another only appended a note.
- **Manual synthesis error risk during review**: **Partial** — Coordinators must produce a complete resolved payload when two revisions each contain valid, unrelated corrections, creating a risk of overlooking a subtle change in a large species table unless the comparison UI highlights per-field diffs against the ancestor revision.
- **Offline client state and transmission footprint**: **Strong** — Tablets persist only a UUID (`baseRevisionId`) alongside local drafts rather than full baseline snapshots, and full structured visit payloads without photographs remain a few kilobytes over cellular or Wi-Fi reconnection.

#### Summary

Preserves whole-observation scientific integrity and keeps storage and sync mechanics simple, at the cost of routing every concurrent edit—including non-overlapping ones—through manual coordinator review.

### Field-Aware Three-Way Merge

#### Description

Tablets retain a complete snapshot of the base visit state alongside local edits and submit structured changes paired with that base reference (or the server diffs the submitted visit against the stored base snapshot). `record-store` applies maintained field-level three-way merge rules relative to the common base:

- **Scalar fields** (`plotId`, `observationDate`, `notes`): if only one branch modified a scalar relative to base, take that modification; if both modified it to identical values, converge; if both modified it to different values, mark a field conflict.
- **Observer list** (`observers`): compute additions and removals relative to the base observer set; disjoint additions/removals combine automatically, while contradictory edits surface for review.
- **Species cover entries** (`speciesCover`): key entries by species identifier; independent additions or cover edits to distinct species combine automatically, while concurrent edits to the same species entry mark a species conflict.

When all field changes across concurrent submissions are disjoint (or convergent), `record-store` synthesizes a merged current record automatically with per-field provenance pointing to the contributing `submissionId`s, making the visit immediately eligible for Friday CSV export without coordinator intervention. Only visits with overlapping field or same-species collisions enter `unresolved` coordinator review, where coordinators resolve just the colliding fields while non-conflicting merged fields carry through automatically.

#### Demonstration

Starting from `R1` (`observers: ["A. Lin"]`, `speciesCover: [{species: "Spartina alterniflora", cover: 40}]`, `notes: "wrack line"`):

- *Unrelated edits*: Tablet 1 adds `"M. Ortiz"` to `observers`; Tablet 2 adds `{species: "Distichlis spicata", cover: 10}` to `speciesCover`. Both diff cleanly against `R1` on disjoint paths and auto-merge into an export-ready visit with field provenance (`observers` → Sub 1, `Distichlis spicata` → Sub 2, remaining fields → `R1`).
- *Coupled edits across distinct keys*: Tablet 1 adjusts `Spartina alterniflora` cover from 40% to 45% after re-estimating quadrat photos; Tablet 2 adds `Spartina patens` at 40% and updates `notes` to `"40% patch is S. patens, not S. alterniflora"` while forgetting to delete the `Spartina alterniflora` row (or editing a different field). Because `notes` and the `Spartina patens` addition do not collide on the `Spartina alterniflora` key, three-way merge combines both into an export-ready visit reporting 45% *S. alterniflora* plus 40% *S. patens* without coordinator review.

#### Analysis

- **Cross-field scientific coherence**: **Weak** — Disjoint structural paths do not imply scientific independence: edits across distinct species keys, total cover balance, `observationDate`, and `notes` combine automatically without review, creating composite observations neither worker intended.
- **Submission-to-export provenance clarity**: **Partial** — Every merged attribute retains field- or entry-level `submissionId` provenance, but explaining a single exported CSV row requires reconstructing a composite record assembled from multiple submissions plus deterministic merge rules.
- **Reconciliation rule and schema maintenance**: **Weak** — Requires specifying, testing, and maintaining merge semantics for scalars, set/list ordering on `observers`, and species-keyed collection diffs (including multi-way divergence beyond two branches and species code renames), plus base-snapshot management on tablets.
- **Coordinator review throughput before Friday export**: **Strong** — Routine non-overlapping corrections merge automatically on receipt and remain eligible for the Friday CSV export, reserving coordinator attention for direct field collisions.
- **Manual synthesis error risk during review**: **Strong** — Non-overlapping fields merge deterministically without manual re-entry, narrowing coordinator decisions strictly to the colliding field or species entry.
- **Offline client state and transmission footprint**: **Partial** — Structured change sets reduce upload bytes slightly, but tablets must retain immutable base snapshots per edited visit across multi-day offline sessions and restarts to construct and validate field-level changes.

#### Summary

Minimizes coordinator review load and manual re-combination on routine disjoint edits, at the cost of maintained per-type merge rules and silent combination of scientifically coupled edits across distinct fields.

## Selection

**Selected option: Whole-Visit Revisions.**

Whole-Visit Revisions wins on three of the four **major** criteria—cross-field scientific coherence, submission-to-export provenance clarity, and reconciliation rule maintenance—while accepting a deliberate disadvantage on the fourth major criterion, coordinator review throughput.

The decision turns primarily on *Do not silently discard a submitted edit* and *Keep the path from a submitted observation to an exported value inspectable*, alongside the system-simplicity dimension of *Prefer workflows two coordinators can operate without a dedicated systems administrator*. In coastal vegetation surveys, species identifications, cover percentages, and qualifying field notes frequently form a single coupled judgment. Under Field-Aware Three-Way Merge, edits that touch different species keys or pair a species change with a note change pass disjoint-path checks and enter the partner CSV unreviewed. At roughly 6,000 visits per season (~200–400 per active field week) where concurrent offline edits to the *same* visit are the exception rather than the norm, asking two coordinators to review every concurrent visit pair is preferable to maintaining per-field merge rules that can silently fabricate composite ecological records.

### Why Field-Aware Three-Way Merge Remains Viable Under Changed Conditions

Field-Aware Three-Way Merge is not eliminated by a hard gate; it solves a real operational risk where *Prefer workflows two coordinators can operate without a dedicated systems administrator* pulls the other way. This decision should be revisited if operational data shows either of two shifts:

1. **Disjoint-conflict volume outstrips Friday review capacity** — for example, if shared-tablet workflows regularly split roles across devices (one tablet logging plot metadata/observers and another logging botany for the same `visitId`), producing dozens of routine non-overlapping conflicts every Thursday afternoon.
2. **Coordinators introduce transcription mistakes during manual reconciliation** — if manually folding unrelated edits across 20+ species rows proves error-prone even with diff-assisted tooling, justifying at least bounded merge rules (or coordinator-confirmed pre-filled merges) for structurally independent metadata.

### Implications of Committing

**What this forecloses:**
- Concurrent edits to the same `visitId`—even on completely unrelated fields—cannot become `resolved` or enter the Friday CSV export without a coordinator resolution action.
- Clients cannot submit partial field patches without a contract revision; every submission and resolution carries a complete `VisitPayload`.

**What downstream designs must accommodate:**
- **`tablet-sync`**:
  - Persist the `revisionId` from which any local draft originated as `baseRevisionId` (`null` for offline-created visits) across app restarts and 48-hour offline windows, paired with a stable `idempotencyKey` for retries.
  - Send complete `VisitPayload` snapshots on submission and advance local `baseRevisionId` tracking from the returned `revisionId` when `status` is `resolved`.
  - Surface `unresolved` outcomes and `competingRevisions` clearly to field workers without treating any competing head as authoritative, and define which `revisionId` a worker bases subsequent offline edits on when a visit already has competing heads awaiting coordinator review.
- **`review-export`**:
  - Provide a revision comparison screen that displays all `competingRevisions` alongside their ancestor revision snapshot(s) and highlights field-by-field and species-by-species differences relative to the base revision—mitigating the **moderate** manual synthesis error risk when a coordinator combines valid unrelated edits into a resolved whole-visit payload.
  - Support both one-click adoption of an intact competing revision and coordinator-authored whole-visit payloads (with optional `resolutionNote`) submitted via `record-store`'s resolution operation.
  - Exclude all `unresolved` visits (`currentRevision: null`) from the Friday partner CSV export and surface unresolved visit counts prominently so coordinators can clear the queue before generating the weekly file.
```

---

### Remaining Phase 2 Check Before Phase 3 (`record-store-specs.md`)

1. Does this decision doc and the `record-store-design.md` LLD look good to approve?
2. From the Phase 2 edge-case list above (items 1–7: late submission during review, `contributingSubmissionIds` accumulation, ancestor snapshot depth, duplicate `baseRevisionId: null`, `plotId` edits/archived plots, idempotency replay status, and payload/error validation), which ones would you like settled in `record-store-design.md` now versus moved into `Open Questions & Future Decisions`?
3. Should I also update the stale "concurrency choice open / pending" lines in `docs/high-level-design.md` and `docs/intent/site-catalog/site-catalog-design.md`?