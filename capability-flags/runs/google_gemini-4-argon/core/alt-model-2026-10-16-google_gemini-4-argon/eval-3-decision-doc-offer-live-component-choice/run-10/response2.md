I have created `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md`.

### `docs/intent/record-store/decisions/concurrent-visit-edits.md`

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Policy

## Context

Field workers survey 320 permanent coastal vegetation plots using 12 shared Android tablets that can operate offline for up to 48 hours. After comparing field notes or returning to camp, workers independently correct the same plot-visit record from cached copies fetched days earlier.

A visit record contains a catalog plot reference (`plotId`), observation date (`observationDate`), observer names (`observers`), species cover estimates (`speciesCovers`), and free-text field notes (`notes`). Some field edits are independent—for example, one worker fixing a misspelled observer name while another adds a forgotten note. Other edits are scientifically coupled across fields—for example, re-identifying a plant specimen (`speciesCovers` entry) while adjusting its cover percentage and updating `notes` to explain the taxonomic change.

`record-store` owns visit persistence and defines how concurrent edits become a current record. This decision establishes the concurrency model and directly determines the contracts that `tablet-sync` (local state retention, submission payloads, sync status feedback) and `review-export` (coordinator comparison workflows, resolution payloads, Friday CSV export eligibility) must accommodate.

## Decision Elements

### Gates

- **No silent loss of submitted edits (HLD Tenet: *Do not silently discard a submitted edit*)**: Every accepted worker submission must be preserved intact in history and accounted for in the resulting visit state; arrival order at the server cannot overwrite an independent edit without trace.

### Weighted Criteria

- **Scientific integrity of coupled observations (major — HLD Non-Goal: *No automated botanical validation or inference of scientific intent*; HLD Tenet: *Keep the path from a submitted observation to an exported value inspectable*)**: How well the mechanism avoids producing synthetic visit records whose combined fields were never observed or reviewed together as a coherent scientific record.
- **Operational simplicity and rule maintenance (major — HLD Tenet: *Prefer workflows two coordinators can operate without a dedicated systems administrator*)**: How little ongoing rule maintenance, schema-coupled merge logic, and provenance complexity the team must build and operate.
- **Coordinator review queue volume (moderate — HLD Goal: *Make reviewable problems visible before the Friday export*)**: How many concurrent edits require manual coordinator resolution before Friday's CSV export when workers touch unrelated fields on the same visit.
- **Client and review surface complexity (moderate)**: The storage, payload, and UI obligations imposed on `tablet-sync` and `review-export`.

## Options in the Domain

### Whole-Visit Revisions

#### Description

Every accepted submission stores a complete, immutable visit payload and names the single `baseRevisionId` that the worker edited (`null` for an initial submission). When a submission's `baseRevisionId` matches the visit's sole active head revision, it supersedes that head linearly and the visit remains `resolved`. When a submission branches from an already-superseded revision—or arrives while the visit already has competing heads—the store records it as a competing active head revision and transitions the visit to `needs_review`.

A coordinator resolves a `needs_review` visit by inspecting the competing whole-visit revisions alongside their common base revision and submitting a new `coordinator_resolution` revision that explicitly supersedes the competing head revision IDs. Visits in `needs_review` are excluded from the Friday CSV export until resolved.

#### Demonstration

- Worker A and Worker B both start from revision `rev-1`.
- Worker A submits a full visit payload with `baseRevisionId: "rev-1"` → creates `rev-2`; visit is `resolved` with active head `["rev-2"]`.
- Worker B later syncs a full visit payload with `baseRevisionId: "rev-1"` → creates `rev-3`; visit transitions to `needs_review` with active heads `["rev-2", "rev-3"]` and `commonBaseRevision: "rev-1"`.
- Coordinator submits a resolution superseding `["rev-2", "rev-3"]` → creates `rev-4`; visit returns to `resolved` with active head `["rev-4"]`.

#### Analysis

- **No silent loss of submitted edits (gate)**: **passes** — every worker submission is retained as an immutable revision, and any non-linear edit enters the active head set for coordinator resolution.
- **Scientific integrity of coupled observations (major)**: **strong** — the store never synthesizes a hybrid visit from separate submissions; any concurrent edit to the same visit is reviewed as a complete observation before entering the current record or export.
- **Operational simplicity and rule maintenance (major)**: **strong** — concurrency detection depends only on `baseRevisionId` lineage against active head IDs; adding or evolving payload fields requires no field-specific merge rules.
- **Coordinator review queue volume (moderate)**: **weak** — concurrent edits to completely unrelated fields (such as an observer name typo and a note addition) still produce competing whole-visit revisions that a coordinator must resolve before Friday export.
- **Client and review surface complexity (moderate)**: **strong** — tablets only track a single `baseRevisionId` per cached visit and send whole payloads; `review-export` compares whole revisions against a common base without tracking field-level merge provenance.

#### Summary

Trades a larger coordinator review queue on disjoint concurrent edits for zero automated cross-field synthesis and minimal server/client merge machinery.

### Field-Aware Three-Way Merge

#### Description

Each tablet retains the full base snapshot of a visit alongside local edits and submits either the base snapshot or structured field-level deltas anchored to that base. When concurrent edits arrive from the same base state, `record-store` performs a field-by-field three-way merge using domain-specific merge rules: scalar fields (`plotId`, `observationDate`, `notes`), set/list rules for `observers`, and keyed-entry rules (by species code) for `speciesCovers`.

If the two submissions modify disjoint fields (or disjoint keys within list/map structures), the store automatically combines them into a merged current state that is immediately eligible for export. Only overlapping changes to the same field or species entry are flagged for coordinator review.

#### Demonstration

- Starting from `rev-1`, Worker A updates `observers` while Worker B adds a species entry in `speciesCovers`.
- The store diffs both against `rev-1`, detects disjoint field modifications, and produces an auto-merged current state containing Worker A's observer list and Worker B's species entry without entering the coordinator review queue.
- If Worker A and Worker B both modify the cover percentage for `Spartina alterniflora` differently, that field is marked conflicted while non-overlapping fields merge automatically.

#### Analysis

- **No silent loss of submitted edits (gate)**: **passes** — original submissions are retained in history, and overlapping edits to the same field are routed to coordinator review rather than overwritten.
- **Scientific integrity of coupled observations (major)**: **weak** — automated merging assumes field independence; if Worker A reclassifies `Salicornia` to `Sarcocornia` (removing one key and adding another in `speciesCovers`) while Worker B updates `notes` or cover values based on the original identification, the merge rules can combine scientifically incompatible edits without flagging a conflict.
- **Operational simplicity and rule maintenance (major)**: **weak** — requires defining and maintaining merge semantics for scalars, ordered or unordered observer lists, keyed species cover maps, and free-text notes, plus schema migrations whenever visit structure changes.
- **Coordinator review queue volume (moderate)**: **strong** — disjoint edits resolve automatically on sync, keeping routine non-overlapping corrections out of the coordinators' Friday pre-export queue.
- **Client and review surface complexity (moderate)**: **weak** — `tablet-sync` must store full base snapshots and construct structured diffs or base-snapshot envelopes; `review-export` must render per-field provenance (showing which submission contributed which field in an auto-merged record) and partial-record conflict resolution UI.

#### Summary

Reduces coordinator review volume when disjoint concurrent edits are frequent, at the cost of maintaining field-merge rules that can silently combine scientifically coupled changes across fields.

## Selection

**Selected option: Whole-Visit Revisions.**

Whole-visit revisions win on both **major** criteria. In vegetation survey records, changes across `speciesCovers` and `notes` (or across two species entries when a specimen is re-identified) are frequently coupled in ways that structural field names cannot express. Avoiding unreviewed synthetic combinations directly upholds the HLD non-goal against automated inference of scientific intent and the tenet *Keep the path from a submitted observation to an exported value inspectable*, while keeping the system operable by two coordinators without maintaining per-field merge rules (*Prefer workflows two coordinators can operate without a dedicated systems administrator*).

We would reconsider **Field-Aware Three-Way Merge** if seasonal review volume grows beyond what two coordinators can clear before the Friday export and empirical review history shows that nearly all concurrent edits touch genuinely independent metadata fields (such as observer lists vs. arrival notes) rather than species observations.

### Downstream Accommodations Required

1. **`tablet-sync` obligations**:
   - Store the server-assigned `revisionId` alongside each locally cached visit and send it as `baseRevisionId` (`null` for newly created visits) with every whole-visit submission.
   - Retain a client-generated `idempotencyKey` across retries of the same pending edit until the server acknowledges receipt.
   - Handle acceptance responses where the visit's `status` is `"needs_review"` (returning `activeHeadRevisionIds`) by recording that the worker's submission is safely stored on the server and awaiting coordinator review, rather than treating `"needs_review"` as a transport failure or silent overwrite.
2. **`review-export` obligations**:
   - Query `record-store` for visits with `status == "needs_review"` and provide a revision comparison screen that displays all `competingRevisions` alongside `commonBaseRevision` (highlighting which fields each competing submission changed relative to the shared base).
   - Submit coordinator resolutions via `POST /visits/{visitId}/resolutions` with the exact `supersededRevisionIds` reviewed on screen, and handle `409 Conflict` (`stale_review_set`) by refreshing the comparison view if another tablet synced a competing revision while the coordinator was reviewing.
   - Hold all visits with `status == "needs_review"` out of the Friday partner CSV export so only visits with a single `resolved` current revision are exported.
```

---

**STOP — Phase 2 Review:**
1. Does the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` look good as written?
2. Which of the 6 edge cases from the Phase 2 LLD probe (coordinator resolution idempotency, byte-identical concurrent payloads, `plotId` mutability across revisions, `commonBaseRevision` DAG computation, error codes, list endpoint shape) would you like settled in `record-store-design.md` now vs. deferred?
3. Once those are triaged, do you approve `record-store-design.md` to move to **Phase 3 (EARS spec update for `REC-*`)**?