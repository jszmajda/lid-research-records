I have written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md`'s `Decisions & Alternatives` table.

### `docs/intent/record-store/decisions/concurrent-visit-edits.md`

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edits

## Context

TidePlot serves 24 seasonal field workers sharing 12 Android tablets across 320 permanent coastal plots, producing roughly 6,000 visit records per season. Tablets remain disconnected for up to 48 hours, and workers frequently revise the same visit independently after comparing paper notes or checking species identifications at camp. Two coordinators review flagged observations ahead of a weekly Friday CSV export delivered to a regional science partner.

Each visit record contains a plot reference (`plot_id`), `observation_date`, `observers`, `species_cover` (species and cover estimate entries), and `notes`. Concurrent edits fall into two domain patterns that look identical at the transport layer:

- **Unrelated clerical or additive edits**, such as correcting an observer's name on one tablet while adding an omitted species entry on another.
- **Scientifically coupled edits**, such as reclassifying a misidentified species on one tablet while adjusting another species' cover estimate or ecological notes under the original identification on a second tablet.

Field names do not encode which edits are scientifically coupled, and server receipt order reflects connectivity timing rather than observational authority. Any viable `record-store` concurrency mechanism must accept offline edits without treating arrival order as authoritative, preserve original worker submissions, and define the contract around which `tablet-sync` and `review-export` are built.

## Decision Elements

### Gates

- **Server-side persistence of stale-base edits from shared tablets** *(inherited — derives from the tenets "Do not silently discard a submitted edit" and "Let field workers continue collecting observations without connectivity")*: When a tablet reconnects up to 48 hours after fetching a visit, the worker holding that shared tablet is often not the observer who authored the queued edit. The server must accept and persist valid edits referencing a superseded base state rather than rejecting uploads until reconciled on the client device.

### Weighted Criteria

- **Protection against unreviewed cross-field scientific combinations** (**major** — derives from the tenet *"Keep the path from a submitted observation to an exported value inspectable"* and the non-goal *"Automated botanical validation or inference of scientific intent"*): Degree to which the mechanism prevents edits with hidden botanical dependencies across distinct fields or list entries from entering an exportable current state without human review.
- **Rule-maintenance and provenance simplicity** (**major** — derives from the tenets *"Keep the path from a submitted observation to an exported value inspectable"* and *"Prefer workflows two coordinators can operate without a dedicated systems administrator"*): Simplicity of the reconciliation rules and provenance model as visit fields evolve, without maintaining per-field merge semantics across scalars, observer lists, and species entries.
- **Friday coordinator review throughput and export readiness** (**major** — derives from the tenet *"Prefer workflows two coordinators can operate without a dedicated systems administrator"* and the goal *"Make reviewable problems visible before the Friday export"*): How few concurrent edits block visits from the Friday partner CSV or consume scarce review capacity across the two coordinators.
- **Resistance to accidental omission during manual reconciliation** (**moderate** — derives from the tenet *"Do not silently discard a submitted edit"*): Degree to which non-overlapping edits from competing branches are carried into the resolved visit without relying on manual re-combination under Friday deadline pressure.
- **Upload payload size over marginal connectivity** (**minor** — derives from the tenet *"Let field workers continue collecting observations without connectivity"*): Volume of data a tablet must transmit over weak coastal cellular links when submitting an edit to an existing visit.

## Options in the Domain

### Option 1: Whole-Visit Revisions

**Description**: Every worker submission carries a `base_revision_id` (`null` on initial creation) and a complete whole-visit payload. If `base_revision_id` matches the visit's sole active head revision, the new revision supersedes it and becomes `current_revision`. If `base_revision_id` has already been superseded, `record-store` stores the submission as a competing active head revision, sets `current_revision` to `null`, and marks the visit as having unresolved review work (`has_unresolved_review: true`). Coordinators compare the complete competing revisions alongside their base revision(s) and submit a whole-visit resolution superseding the full active head set. `tablet-sync` tracks `base_revision_id` per visit, uploads full visit payloads, and surfaces competing-revision status to workers. `review-export` provides a whole-visit comparison workflow and holds unresolved visits out of the Friday CSV.

**Demonstration**: Visit `V-1` starts at revision `R1` (`Spartina alterniflora: 40%`, observer `["M. Chen"]`). Offline Tablet A submits against `R1` with observer `["M. Chen", "J. Ortiz"]`, creating `R2` (`current_revision = R2`). Offline Tablet B later submits against `R1` reclassifying the grass to `Spartina patens: 40%` and adding a note, creating `R3`. `record-store` sets `current_revision = null` and `competing_revisions = [R2, R3]`, holding `V-1` out of export until a coordinator resolves `[R2, R3]` into `R4`.

**Analysis**:
- **Gate — Server-side persistence of stale-base edits from shared tablets: passes.** Every valid submission referencing an existing revision of the visit is accepted and stored as an immutable submission and active head revision regardless of concurrent advances.
- **Protection against unreviewed cross-field scientific combinations: strong fit.** Each worker's observation remains a complete unit; any concurrent divergence requires coordinator review before the visit can become `current_revision` or enter an export.
- **Rule-maintenance and provenance simplicity: strong fit.** `record-store` tracks a uniform revision graph (`parent_revision_ids` and immutable submissions/resolutions) with no field-type-specific merge logic; every exported record traces directly to one worker submission or one coordinator resolution.
- **Friday coordinator review throughput and export readiness: weak fit.** Every concurrent edit to a visit—including strictly clerical edits to unrelated fields—enters the coordinator review queue and withholds the visit from the Friday CSV until resolved.
- **Resistance to accidental omission during manual reconciliation: partial fit.** Both original submissions remain immutable in history, but when two competing revisions modify unrelated fields, the coordinator must carry forward changes from both whole-visit snapshots into `resolved_payload` without overlooking a non-overlapping edit.
- **Upload payload size over marginal connectivity: partial fit.** Every edit re-transmits the complete structured visit payload rather than changed fields, though structured text records without photographs remain a few kilobytes per visit.

**Summary**: Preserves whole-visit scientific coherence and keeps server and provenance mechanics simple, at the cost of routing all concurrent edits—including benign disjoint edits—through manual coordinator review.

### Option 2: Field-Aware Three-Way Merge

**Description**: Tablets retain an immutable snapshot of the base visit alongside local edits and submit the base snapshot reference plus structured changes across scalar fields (`observation_date`, `notes`), `observers` entries, and keyed `species_cover` entries. When `record-store` receives concurrent submissions derived from the same base state, it applies deterministic three-way merge rules: edits touching disjoint fields or distinct species keys combine automatically into a synthesized current record with field-level provenance linking each value to its contributing submission; overlapping edits (such as two modifications to `notes` or to the same species key) enter coordinator review and hold the visit out of export until resolved. Both original submissions remain stored intact whether merged automatically or sent to review. `tablet-sync` stores base snapshots and computes structured diffs locally; `review-export` displays field-level provenance and presents targeted overlap resolution views.

**Demonstration**: Against `R1` (`Spartina alterniflora: 40%`, observer `["M. Chen"]`), Tablet A adds observer `"J. Ortiz"` and Tablet B appends a tide note. `record-store` automatically combines both disjoint deltas into an export-ready visit carrying provenance to both submissions. Conversely, if Tablet A deletes `Spartina alterniflora` and inserts `Spartina patens: 40%` while Tablet B updates `notes` describing `S. alterniflora` stand density, those keys are structurally disjoint and merge automatically without flagging the coupled botanical contradiction for review.

**Analysis**:
- **Gate — Server-side persistence of stale-base edits from shared tablets: passes.** Structured change submissions against historical base states are accepted and persisted on the server whether they merge cleanly or trigger an overlap review.
- **Protection against unreviewed cross-field scientific combinations: weak fit.** Disjoint structural changes combine automatically into an exportable current state, allowing coupled botanical edits—such as a species reclassification on one tablet and cover or note adjustments assuming the old identification on another—to pass into the Friday CSV unreviewed.
- **Rule-maintenance and provenance simplicity: weak fit.** Requires maintaining three-way merge and identity rules across scalars, observer sets, and species entries (including ambiguous delete-plus-insert reclassifications and multi-cycle merges), plus field-level provenance metadata to keep auto-combined exports explainable.
- **Friday coordinator review throughput and export readiness: strong fit.** Benign concurrent edits to separate fields reconcile automatically and remain eligible for Friday export, focusing coordinator review strictly on overlapping field collisions.
- **Resistance to accidental omission during manual reconciliation: strong fit.** Non-overlapping changes are combined deterministically by the merge engine rather than relying on manual coordinator synthesis across two full visit records.
- **Upload payload size over marginal connectivity: strong fit.** Tablets transmit compact structured change sets rather than unmodified species lists and notes.

**Summary**: Minimizes coordinator review load and preserves non-overlapping edits automatically, at the cost of maintained per-field merge rules, field-level provenance complexity, and silent combination of scientifically coupled edits across distinct fields.

### Option 3: Stale-Base Rejection with Tablet-Side Reconciliation

**Description**: `record-store` maintains a single linear revision chain per visit and accepts an edit only when `base_revision_id` matches the current head. When `base_revision_id` is stale, the server rejects the submission and returns the latest server revision so the tablet can reconcile locally and resubmit a new linear revision. `review-export` requires no concurrency review queue because all visits in `record-store` are linearly ordered.

**Demonstration**: Tablet A advances `V-1` from `R1` to `R2`. Two days later, shared Tablet B reconnects carrying Worker K's offline edit based on `R1`, while Worker P is now using Tablet B in the field. `record-store` rejects Tablet B's upload; the edit remains unsubmitted on Tablet B until someone on that device reconciles Worker K's changes against `R2`.

**Analysis**:
- **Gate — Server-side persistence of stale-base edits from shared tablets: eliminated.** Rejecting stale-base uploads leaves valid offline observations unpersisted on local tablet storage, where the rotating worker holding the shared device lacks context to reconcile another observer's botanical edits before Friday export.
- **Protection against unreviewed cross-field scientific combinations: strong fit.** No automated cross-field merge occurs on the server; every reconciliation is performed explicitly by a human.
- **Rule-maintenance and provenance simplicity: partial fit.** Server storage is strictly linear, but pre-reconciliation competing observations are never captured in server history if overwritten on the client.
- **Friday coordinator review throughput and export readiness: partial fit.** Coordinators avoid a server review queue, but visits awaiting tablet-side reconciliation remain invisible to coordinators ahead of Friday export.
- **Resistance to accidental omission during manual reconciliation: weak fit.** Reconciliation is pushed onto field workers on small screens without access to both observers' paper field notes.
- **Upload payload size over marginal connectivity: weak fit.** Rejected full-visit uploads must be fetched, reconciled, and transmitted again.

**Summary**: Eliminates server-side branching and coordinator conflict queues, but fails the shared-tablet offline persistence gate by stranding stale edits on devices rotated among seasonal workers.

## Selection

Select **Option 1: Whole-Visit Revisions**.

Stale-base rejection (Option 3) is eliminated by the shared-tablet persistence gate, leaving a genuine trade between Whole-Visit Revisions (Option 1) and Field-Aware Three-Way Merge (Option 2). Both options satisfy *"Do not silently discard a submitted edit"* at the storage layer, so the decision turns on how the major criteria weigh *"Keep the path from a submitted observation to an exported value inspectable"*, *"Automated botanical validation or inference of scientific intent"* (non-goal), and *"Prefer workflows two coordinators can operate without a dedicated systems administrator"*.

Whole-Visit Revisions wins because automatically merging structurally disjoint fields makes an implicit botanical assumption—that edits to distinct keys within a plot visit are scientifically independent. In vegetation surveys, species reclassifications, cover percentages, and ecological notes routinely depend on one another across keys. Preventing silent, scientifically inconsistent combinations in the partner's Friday CSV outweighs reducing the weekly review count, and a uniform revision graph avoids maintaining bespoke scalar, set, and species-entry merge rules plus field-level provenance machinery. On the operational tenet (*"Prefer workflows two coordinators can operate without a dedicated systems administrator"*), the two options pull in opposite directions—Option 1 increases weekly coordinator review items, while Option 2 increases system rule complexity and provenance opacity—and at ~6,000 visits per season, only the small subset of visits edited concurrently while offline enters review.

### Why Field-Aware Three-Way Merge Remains the Revisit Candidate

Field-Aware Three-Way Merge remains credible if production history shows a different empirical profile: specifically, if concurrent edits occur frequently enough to bottleneck the two coordinators before Friday exports *and* resolved-conflict audits show those collisions are overwhelmingly benign clerical edits (such as observer-list corrections paired with independent notes) rather than coupled species/cover revisions, or if manual whole-visit reconciliation causes coordinators to overlook non-overlapping edits. Because `record-store` retains immutable worker submissions and parent revision links, introducing conservative auto-merge rules for demonstrably independent metadata fields later would not invalidate historical records.

### Downstream Implications

Committing to Whole-Visit Revisions forecloses delta-only edit uploads and automatic Friday export of concurrently edited visits, and places concrete obligations on the two remaining nodes:

- **`tablet-sync` accommodations**:
  - Persist the server-assigned `revision_id` for each synced visit locally and send it as `base_revision_id` (`null` on initial creation) paired with a durable `idempotency_key` across retries.
  - Send complete whole-visit payloads on every submission rather than field-level diffs.
  - Handle accepted submissions that return `has_unresolved_review: true` (`current_revision_id: null`): explain to field workers on shared tablets that competing revisions are queued for coordinator review without presenting either revision as arrival-order winner, and make explicit which revision ID (`competing_revision_ids`) a worker starts from if recording a follow-up edit before review completes.
- **`review-export` accommodations**:
  - Provide a coordinator comparison screen across all active `competing_revisions` and their `base_revisions` that visually highlights per-field and per-species differences against the common base—mitigating the moderate risk of a coordinator accidentally omitting a non-overlapping edit from one branch when authoring `resolved_payload`.
  - Submit whole-visit coordinator resolutions naming the full active `superseded_revision_ids` set, and handle stale-resolution rejections by refreshing the comparison view when a late tablet sync adds another competing head mid-review.
  - Exclude every visit with `has_unresolved_review: true` from the Friday partner CSV export, surfacing the unresolved count to coordinators ahead of export and retaining resolution provenance (`coordinator_id`, `contributing_submission_ids`, `resolution_note`) for audit.
```

---

### Next Step in Phase 2

Does this decision doc capture the trade-off and downstream accommodations as you want them?

Before we close Phase 2 and move to Phase 3 (`record-store-specs.md`), let me know whether you want to approve `record-store-design.md` as drafted (deferring the edge cases to `Open Questions & Future Decisions`) or walk through the open `record-store` questions one at a time—starting with **`plot_id` mutability**: should an edit or coordinator resolution on an existing `visit_id` be allowed to change `plot_id` (e.g., when a worker selected the wrong adjacent plot in the field), or should `plot_id` be immutable once a visit is created?