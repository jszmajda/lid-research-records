Recorded the decision at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md` under `Decisions & Alternatives`.

---

### `docs/intent/record-store/decisions/concurrent-visit-edits.md`

```markdown
---
node: record-store
---

# Decision: Reconciling Concurrent Visit Edits

## Context

TidePlot serves 24 seasonal field workers sharing 12 Android tablets across 320 permanent coastal vegetation plots, producing roughly 6,000 visit records per season. Tablets operate offline for up to 48 hours. After comparing paper notes or noticing entry mistakes back at camp, two workers on different tablets can edit the same visit starting from the same cached state and upload days apart. Server receipt order reflects when a tablet reached connectivity, not which observation is scientifically accurate.

Each visit record contains a plot UUID, observation date, observer list, species cover estimates, and free-text notes. Concurrent edits fall into two patterns that look identical at the schema level:

- **Unrelated corrections**: one worker fixes a misspelled observer name while another adds an overlooked trace species.
- **Scientifically coupled corrections**: one worker reclassifies *Spartina alterniflora* to *Spartina patens* after checking a voucher specimen while another adjusts the *Spartina* cover percentage or edits the note explaining why cover changed.

Two coordinators review flagged issues ahead of a weekly Friday CSV export to a regional science partner. Reconciling concurrent edits too aggressively risks exporting a synthetic combination of observations that no worker actually recorded in the field; reconciling too conservatively increases the Friday review queue and holds visits out of the partner CSV until a coordinator acts. Because `record-store` defines the concurrency contract, this choice also determines what baseline state `tablet-sync` persists offline and what review and export controls `review-export` must build.

## Decision Elements

### Gate

- **No silent overwrite of conflicting observations** *(inherited from HLD tenet "Do not silently discard a submitted edit")*: When two submissions make incompatible changes to a visit, the system must preserve every submitted payload and surface the conflict for coordinator resolution rather than picking a winner automatically by receipt order or device clock.

### Weighted Criteria

- **Cross-field scientific coherence** (**major** — grounded in HLD Non-Goal *"Automated botanical validation or inference of scientific intent"* and tenet *"Keep the path from a submitted observation to an exported value inspectable"*): Whether the store prevents concurrent edits across scientifically coupled fields (such as species identity, cover percentage, and explanatory notes) from combining into an unreviewed hybrid record.
- **Coordinator review load and Friday export throughput** (**major** — grounded in HLD tenet *"Prefer workflows two coordinators can operate without a dedicated systems administrator"* and Goal *"Make reviewable problems visible before the Friday export"*): How much coordinator effort concurrent edits require before the weekly Friday export, how many visits are held out of the CSV while awaiting review, and how exposed coordinators are to human copy mistakes when reconciling unrelated edits manually.
- **Auditability from submission to exported CSV** (**moderate** — grounded in HLD tenet *"Keep the path from a submitted observation to an exported value inspectable"*): How directly a coordinator or science partner can trace any exported visit back to the exact worker submissions and coordinator decisions that produced it.
- **Rule maintenance and schema evolution cost** (**moderate** — grounded in HLD tenet *"Prefer workflows two coordinators can operate without a dedicated systems administrator"*): The ongoing complexity of specifying, testing, and maintaining server and client reconciliation rules across scalar fields, observer lists, and species cover collections as survey requirements evolve.
- **Offline client and mid-conflict editing ergonomics** (**minor** — grounded in HLD tenet *"Let field workers continue collecting observations without connectivity"*): How much baseline state tablets must store per cached visit and how smoothly field workers can inspect or update a visit that has already received concurrent edits prior to Friday review.

## Options in the Domain

### Whole-Visit Revisions

#### Description

Every accepted submission carries the `baseRevisionId` that the tablet started from (`null` for a newly created visit) along with a complete visit payload. If the visit is `clean` and `baseRevisionId` matches its `currentRevisionId`, the new revision supersedes the current revision cleanly. If `baseRevisionId` refers to an earlier revision — or if the visit already has unresolved competing edits — the store preserves both complete revisions as active `competingRevisions` and marks the visit `unresolved` (`currentRevision: null`) until a coordinator submits a complete resolved visit payload naming the `supersededRevisionIds`. The server never combines fields across submissions on its own.

#### Demonstration

Visit `V1` is at revision `R1` (`observers: ["A. Chen"]`, `species: [{taxon: "Spartina alterniflora", cover: 40}]`, `notes: "dense stand"`).

- Tablet 1 submits `baseRevisionId: R1` reclassifying the grass to `Spartina patens` (`cover: 40`), advancing `V1` to `clean` revision `R2`.
- Tablet 2 later uploads `baseRevisionId: R1` keeping `Spartina alterniflora` (`cover: 25`, `notes: "25% live cover; rest wrack"`).
- `record-store` records `R3`, transitions `V1` to `unresolved` with `competingRevisions: [R2, R3]` and `baseRevisions: [R1]`, and withholds `V1` from export until a coordinator compares `R2` and `R3` against `R1`. If Tablet 2 had instead only added `"B. Ortiz"` to `observers`, `V1` would follow the exact same path into `unresolved`.

#### Analysis

- **Passes** (*No silent overwrite of conflicting observations*): Every worker submission is retained intact and any off-base submission enters `competingRevisions` for coordinator resolution.
- **Strong fit** (*Cross-field scientific coherence*): No server-generated combination of fields can occur without a coordinator reading the competing full-visit contexts together.
- **Weak fit** (*Coordinator review load and Friday export throughput*): Disjoint edits (such as an observer spelling fix on one tablet and a note addition on another) enter the same coordinator queue as genuine observational disagreements, holding the visit out of the Friday CSV until resolved and requiring the coordinator to carry forward non-conflicting changes without dropping either side.
- **Strong fit** (*Auditability from submission to exported CSV*): Every revision in a visit's lineage was authored whole by either an identified field worker or an identified coordinator superseding an explicit set of revisions.
- **Strong fit** (*Rule maintenance and schema evolution cost*): Concurrency transitions depend only on `visitId` and `baseRevisionId` equality; adding or restructuring survey fields requires no new merge semantics.
- **Partial fit** (*Offline client and mid-conflict editing ergonomics*): Tablets store only a `baseRevisionId` alongside each cached visit rather than a separate base snapshot, but while a visit is `unresolved` it has no single settled `currentRevision`, requiring tablets and workers to handle competing candidates if edited again before coordinator review.

#### Summary

Trades higher coordinator review volume on benign disjoint edits for guaranteed preservation of whole-visit scientific context and minimal server/client synchronization rules.

### Field-Aware Three-Way Merge

#### Description

Tablets retain the full base visit snapshot they started from (or compute structured changes against it) and submit either base snapshot + full state or typed field/collection operations referencing `baseRevisionId`. When concurrent submissions arrive against the same base revision, `record-store` compares each side's changes against the base across explicit merge units: scalar fields (`observationDate`, `notes`), set/list membership (`observers`), and keyed collection entries (`speciesCoverEstimates` keyed by taxon). If two concurrent submissions modify strictly disjoint merge units, `record-store` produces a combined `clean` revision automatically while retaining both raw submissions and per-field provenance. Only overlapping modifications to the same merge unit (for example, both tablets changing `observationDate` or the same taxon's cover value) mark the visit `unresolved` for coordinator review.

#### Demonstration

Starting from `R1` above:

- If Tablet 1 adds `"B. Ortiz"` to `observers` and Tablet 2 appends `" tide rising"` to `notes`, `record-store` diffs both against `R1`, sees disjoint changes, and automatically creates `clean` revision `R3` containing both edits — ready immediately for Friday export with zero coordinator action.
- However, if Tablet 1 deletes `Spartina alterniflora` (`40%`) and adds `Spartina patens` (`40%`) while Tablet 2 updates `Spartina alterniflora` to `25%` (or updates `notes` to explain the `25%` estimate), taxon-keyed rules flag the `Spartina alterniflora` delete-vs-modify overlap in the first case, whereas in the note-only case `Spartina patens (40%)` and `"25% live cover; rest wrack"` merge cleanly into a `clean` exportable record without coordinator review.

#### Analysis

- **Passes** (*No silent overwrite of conflicting observations*): Direct edits to the same scalar field or keyed entry are flagged as overlapping conflicts for coordinator review, and raw worker submissions are preserved.
- **Weak fit** (*Cross-field scientific coherence*): Merge units defined over schema fields cannot detect implicit scientific dependencies across distinct fields or across renamed taxa and free-text notes, allowing incompatible field combinations to auto-settle as `clean`.
- **Strong fit** (*Coordinator review load and Friday export throughput*): Routine non-overlapping corrections settle automatically on upload, keeping visits eligible for Friday CSV export and concentrating coordinator attention on true field-level collisions.
- **Partial fit** (*Auditability from submission to exported CSV*): Explaining an auto-merged `clean` visit requires field-level provenance tracking which submission contributed each attribute or species row, rather than pointing to a single human-authored snapshot.
- **Weak fit** (*Rule maintenance and schema evolution cost*): Requires well-specified, maintained three-way rules for list ordering, observer deduplication, species entry identity (especially under taxonomy renames or split/lump edits), and partial-conflict states, updated whenever the visit schema changes.
- **Partial fit** (*Offline client and mid-conflict editing ergonomics*): Disjoint concurrent edits immediately yield a settled `currentRevision` for subsequent tablet syncs, at the cost of tablets storing full base snapshots (or structured change logs) alongside in-progress local drafts.

#### Summary

Trades maintained field/collection merge rules and exposure to silent cross-field scientific mismatches for automatic convergence on unrelated edits and a smaller Friday review queue.

### Automatic Convergence (CRDT / Last-Writer-Wins)

#### Description

Each visit field and collection entry is modeled as a convergent state or operation-based register/set (for example, last-writer-wins registers stamped with hybrid logical clocks for scalar fields and observed-remove sets for observers and species rows). Concurrent offline edits from any number of tablets converge deterministically to a single current visit state without creating an `unresolved` state or blocking CSV export on coordinator intervention.

#### Demonstration

If Tablet 1 records `Spartina alterniflora` at `40%` (`t = 14:02`) and Tablet 2 independently corrects it to `15%` (`t = 14:05`, or with a skewed tablet clock at `t = 13:58`), the store deterministically selects the higher-timestamped register value as the current and exportable visit state without queuing review work.

#### Analysis

- **Eliminated** (*No silent overwrite of conflicting observations*): Conflicting edits to the same field resolve automatically via clock or tie-breaker ordering without coordinator review, allowing device clock skew or upload timing to supersede a field observation silently in exported data.
- **Weak fit** (*Cross-field scientific coherence*): Independent per-field registers combine concurrent changes across coupled fields without human inspection.
- **Strong fit** (*Coordinator review load and Friday export throughput*): Concurrent edits never block export or generate conflict queues.
- **Weak fit** (*Auditability from submission to exported CSV*): Exported values depend on fine-grained clock/tie-breaker ordering across field registers rather than explicit human review of disagreements.
- **Partial fit** (*Rule maintenance and schema evolution cost*): Standard CRDT primitives avoid custom review state machines, but require logical clocks, tombstones, and careful schema migration across offline clients.
- **Strong fit** (*Offline client and mid-conflict editing ergonomics*): Every visit always exposes a single mergeable state offline and online.

#### Summary

Eliminates coordinator conflict queues entirely, but fails the gate against silently discarding competing field observations.

## Selection

**Selected option: Whole-Visit Revisions.**

Automatic convergence is eliminated by the gate derived from *"Do not silently discard a submitted edit"*. Between the two surviving options, the decision turns on weighing **Cross-field scientific coherence** (**major**) alongside **Auditability from submission to exported CSV** (**moderate**) and **Rule maintenance and schema evolution cost** (**moderate**) against **Coordinator review load and Friday export throughput** (**major**).

Whole-visit revisions win because TidePlot's survey data contains scientific couplings that schema structure does not encode — most acutely between species identifications, cover percentages, and explanatory field notes. Under field-aware three-way merge, any pair of concurrent edits that touch coupled facts residing in distinct fields (such as changing a species taxon on one tablet while adjusting a cover explanation in `notes` on another) bypasses review and enters the Friday partner CSV as a settled fact. That outcome directly conflicts with the HLD Non-Goal *"Automated botanical validation or inference of scientific intent"* and weakens *"Keep the path from a submitted observation to an exported value inspectable"*. While *"Prefer workflows two coordinators can operate without a dedicated systems administrator"* pulls both ways — favoring smaller Friday review queues on one hand, and simpler, predictable server behavior without subtle merge bugs on the other — at a scale of ~6,000 seasonal visits across 12 shared tablets, concurrent edits to the *same* visit represent post-visit corrections rather than continuous multi-user collaboration, keeping expected review volume manageable for two coordinators.

### Why Field-Aware Three-Way Merge Remains the Credible Alternative

A future review of this decision should reconsider field-aware three-way merge if production telemetry shows that concurrent post-visit edits are frequent enough — and predominantly disjoint administrative fixes (such as adding co-observers or appending logistics notes) — that manual whole-visit resolution bottlenecks Friday exports or causes coordinators to accidentally drop one worker's unrelated edit while hand-combining records. If revisited, a safer boundary than fine-grained per-species merging would be **coarse-grained coupling groups**: merging clearly administrative fields (such as `observers`) automatically while still treating the scientific observation block (`observationDate`, `speciesCoverEstimates`, and `notes`) as a single atomic unit that routes any concurrent touch to coordinator review.

### Implications and Downstream Obligations

Committing to whole-visit revisions forecloses automatic server-side fast-forwarding when concurrent offline edits touch unrelated fields, and forecloses treating an unreviewed concurrent edit as export-ready. Downstream nodes must accommodate the resulting contract:

- **`tablet-sync`**:
  - Persist `currentRevision.revisionId` as the local `baseRevisionId` whenever caching a `clean` visit (`null` when creating a new visit offline), and send complete visit payloads paired with `idempotencyKey` and `baseRevisionId`.
  - Distinguish an accepted submission that entered `reviewStatus: "unresolved"` from a transport or validation failure so workers know their edit is safely stored and queued for coordinator review rather than retrying or re-entering it.
  - Represent downloaded visits whose `reviewStatus` is `"unresolved"` (`currentRevision: null`), surfacing `competingRevisions` and requiring an explicit choice of starting `revisionId` if a worker needs to record an additional offline observation before a coordinator has resolved the visit.
- **`review-export`**:
  - Provide a coordinator queue over `reviewStatus: "unresolved"` visits and a revision comparison screen that diffs each candidate in `competingRevisions` against its corresponding entry in `baseRevisions`. Because coordinators will resolve disjoint edits as well as overlapping ones, the comparison UI must clearly highlight every field changed by each candidate relative to its base so coordinators do not inadvertently omit a non-conflicting change when constructing the resolved payload.
  - Submit coordinator resolutions as complete visit payloads guarded by `supersededRevisionIds` and `idempotencyKey`, handling `409 Conflict` if a late tablet upload expanded the competing set during review.
  - Gate the weekly Friday CSV on `reviewStatus: "clean"`, excluding all `unresolved` visits and surfacing withheld-visit counts before export so coordinators can clear pending items ahead of partner delivery.
```

---

### Next Step (Phase 2 Review)

1. Does `concurrent-visit-edits.md` capture the tradeoff and downstream obligations as you want them?
2. Before we move to **Phase 3** (`record-store-specs.md`), one transition in `record-store-design.md` is worth settling up front (we can defer the remaining edge cases under `Open Questions & Future Decisions` if you'd like):
   - Suppose a visit is already `unresolved` with `[R2, R3]` competing, and the worker who submitted `R2` notices a typo and submits `R4` with `baseRevisionId: R2`. Should `R4` **replace `R2` in the active competing set** (so the coordinator compares `[R3, R4]`, with `R2` retained in history), or keep **`[R2, R3, R4]` all active** in the review queue?