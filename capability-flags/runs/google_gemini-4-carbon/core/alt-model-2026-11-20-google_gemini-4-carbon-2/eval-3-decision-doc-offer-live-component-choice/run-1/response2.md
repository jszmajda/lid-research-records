`docs/intent/record-store/decisions/concurrent-visit-edits.md` is written and linked from the `Decisions & Alternatives` row (and `References`) in `docs/intent/record-store/record-store-design.md`. Here is the decision doc in full for review:

---

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Handling

## Context

Twenty-four seasonal field workers share 12 Android tablets to survey 320 permanent coastal plots, producing roughly 6,000 plot-visit records per season. Tablets operate offline for up to 48 hours, and workers routinely correct existing visits independently after comparing field notes. Because edits arrive hours or days after their starting state was fetched, server receipt order and uncalibrated tablet clocks carry no evidence about which worker's observation is more accurate.

Each visit record contains `plot_id`, `observation_date`, `observers`, `species_cover`, and `notes`. Concurrent edits fall into two patterns that look similar structurally:

- **Scientifically independent edits**, such as one worker correcting a misspelled observer name while another adds a missing species entry.
- **Scientifically coupled edits**, such as one worker re-identifying `Spartina patens` as `Distichlis spicata` and revising both its cover percentage and explanatory note while another worker adjusts the original `Spartina patens` cover estimate from field memory.

Two coordinators resolve flagged visits ahead of a weekly Friday CSV export to a regional science partner. `record-store` owns the concurrency mechanism, and both `tablet-sync` and `review-export` size their storage model, sync envelopes, coordinator tooling, and export eligibility rules around that choice. Getting this wrong either silently corrupts longitudinal ecological data or overwhelms two coordinators ahead of Friday delivery.

## Decision Elements

### Gates

- **No silent loss of submitted observations** *(inherited gate — HLD tenet: "Do not silently discard a submitted edit")*: Every accepted worker submission must remain stored intact, and concurrent edits to the same visit must never overwrite or suppress one another solely on the basis of arrival order or client timestamps.

### Weighted Criteria

- **Cross-field scientific coherence** (**major** — HLD non-goal against *inference of scientific intent*; tenet *Keep the path from a submitted observation to an exported value inspectable*): Exported visit records should not automatically combine fields from separate submissions when those fields express a single ecological judgment across species identity, cover percentages, or notes.
- **Friday export readiness and coordinator queue volume** (**major** — tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*; goal *Make reviewable problems visible before the Friday export*): Concurrent corrections to unrelated parts of a visit should avoid overloading two coordinators or holding clean visits out of the weekly Friday CSV.
- **Rule and operational maintainability** (**moderate** — tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*): Reconciliation behavior, provenance schemas, and future field additions should remain simple to operate and reason about without curating per-field merge rules across scalars, observer lists, species entries, and free-text notes.
- **End-to-end provenance inspectability** (**moderate** — tenet *Keep the path from a submitted observation to an exported value inspectable*): Tracing an exported CSV value back to the worker submission(s) and coordinator resolution that produced it should be direct and unambiguous.
- **Preservation of non-overlapping fixes during reconciliation** (**minor** — derived from tenet *Do not silently discard a submitted edit*): When concurrent submissions modify genuinely unrelated fields, resolving the visit should preserve both fixes rather than risking one fix being overlooked during manual comparison.
- **Offline tablet state and sync simplicity** (**minor** — tenet *Let field workers continue collecting observations without connectivity*): Local tracking metadata retained across 48-hour offline windows and shared-tablet restarts, together with sync request/response handling, should stay compact and straightforward.

## Options in the Domain

### Receipt- or Timestamp-Ordered Overwrite (Last-Write-Wins)

**Description**

Each tablet submits a complete visit payload keyed by `visit_id`. Even if `record-store` appends prior payloads to an audit table, it automatically promotes whichever submission arrived most recently at the server (or carried the greatest client timestamp) as the current exportable visit without creating coordinator review work. `tablet-sync` tracks no base state beyond `visit_id`, and `review-export` exports the latest stored payload for every visit directly into the Friday CSV.

**Demonstration**

Base visit `V1` lists `Spartina patens: 40%`, `observers: ["J. Morales"]`. Tablet 1 (offline Tuesday, synced Thursday) submits `Spartina patens: 40%`, `observers: ["J. Morales", "K. Chen"]`. Tablet 2 (edited Wednesday from the original state, synced Wednesday evening) submits `Distichlis spicata: 35%`, `observers: ["J. Morales"]`. Under receipt-ordered promotion, Tablet 1's Thursday sync becomes the current visit and Tablet 2's species correction disappears from Friday's CSV without warning.

**Analysis**

- **No silent loss of submitted observations (gate)**: **eliminated** — promoting a single current record by receipt time or tablet clock suppresses competing accepted edits from the exported state without coordinator review.
- **Cross-field scientific coherence**: **strong** — each submission replaces the entire visit as a unit, so fields from separate submissions are never mixed into a hybrid record.
- **Friday export readiness and coordinator queue volume**: **strong** — concurrent edits produce zero coordinator review items and never hold visits out of the Friday CSV.
- **Rule and operational maintainability**: **strong** — requires no lineage graph, per-field diff logic, or conflict resolution workflow.
- **End-to-end provenance inspectability**: **weak** — although the winning row maps to one submission, audit history alone does not record why earlier competing submissions were superseded rather than reviewed.
- **Preservation of non-overlapping fixes during reconciliation**: **weak** — whichever concurrent submission loses the ordering race has all of its non-overlapping fixes dropped from the current visit.
- **Offline tablet state and sync simplicity**: **strong** — tablets store only the latest known visit payload and `visit_id`.

**Summary**

Maximizes sync simplicity and immediate export availability by sacrificing conflict visibility, eliminating it under the project's primary data-preservation tenet.

### Whole-Visit Immutable Revisions

**Description**

Every accepted worker submission creates an immutable complete visit revision referencing `base_revision_id` (`null` on initial capture, or the fetched `revision_id` on edit). When a visit is `resolved` and an edit's `base_revision_id` matches `current_revision_id`, the new revision advances `current_revision_id` linearly without review. When an edit branches from an older or `null` base — or arrives while the visit already has competing heads — `record-store` retains all active branch heads in `competing_revisions`, sets `review_status = needs_review`, and sets `current_revision = null`.

`tablet-sync` stores only `current_revision.revision_id` alongside cached visits, sends whole-visit payloads with `base_revision_id` and an `idempotency_key`, and displays `needs_review` status when concurrent edits branch. `review-export` holds all `needs_review` visits out of the Friday CSV and provides a coordinator comparison view showing `competing_revisions` against `common_base_revision`; resolving a conflict submits a complete visit payload via `ResolveVisitReview`, recording a `coordinator_resolution` revision that cites `contributing_revision_ids` and restores `review_status = resolved`.

**Demonstration**

Revision `rev-1` records `Spartina patens: 40%`, `observers: ["J. Morales"]`, `notes: ""`.
- Worker A submits from `base_revision_id: rev-1` -> `rev-2`: `Distichlis spicata: 35%`, `observers: ["J. Morales"]`, `notes: "Re-checked ligule voucher; mislogged as S. patens"`.
- Worker B submits from `base_revision_id: rev-1` -> `rev-3`: `Spartina patens: 40%`, `observers: ["J. Morales", "K. Chen"]`, `notes: ""`.

`rev-2` advances `current_revision_id` on arrival; when `rev-3` arrives still citing `rev-1`, the visit transitions to `needs_review` with `competing_revisions: [rev-2, rev-3]` and `common_base_revision: rev-1`. Both revisions remain intact, the visit is held out of CSV export until reviewed, and a coordinator sees both changes against `rev-1` to produce `rev-4` (`Distichlis spicata: 35%`, `observers: ["J. Morales", "K. Chen"]`, voucher note retained) citing `[rev-2, rev-3]`.

**Analysis**

- **No silent loss of submitted observations (gate)**: **passes** — every worker submission is stored immutably, and concurrent branches enter `needs_review` rather than overwriting one another.
- **Cross-field scientific coherence**: **strong** — no automated combination crosses species, cover, or note fields; every multi-submission combination is inspected as a complete ecological visit by a coordinator.
- **Friday export readiness and coordinator queue volume**: **weak** — every concurrent edit pair enters `needs_review` and is held out of the Friday CSV until coordinator action, even when the two edits touched completely unrelated fields such as `observers` and `notes`.
- **Rule and operational maintainability**: **strong** — conflict detection depends only on `base_revision_id` lineage equality, independent of field types or future changes to survey columns.
- **End-to-end provenance inspectability**: **strong** — every exported visit is either a single intact `worker_submission` revision or an explicit `coordinator_resolution` revision naming the exact `contributing_revision_ids` and coordinator who approved it.
- **Preservation of non-overlapping fixes during reconciliation**: **partial** — both competing revisions are preserved and shown against `common_base_revision`, but carrying forward non-overlapping edits from multiple branches depends on the comparison interface and coordinator attention during resolution.
- **Offline tablet state and sync simplicity**: **strong** — tablets persist a single `base_revision_id` UUID per synced visit alongside the visit payload, with no separate base snapshot or structured diff log.

**Summary**

Preserves whole-visit scientific integrity, provenance clarity, and simple lineage mechanics at the cost of routing all concurrent edits — including unrelated field fixes — through the coordinator review queue.

### Field-Aware Three-Way Merge

**Description**

Each tablet retains the full base visit snapshot fetched from the server and submits structured field changes (or a full payload paired with its base snapshot reference) against that base. When concurrent edits share a base state, `record-store` diffs each submission against the base using per-field merge rules: scalar comparison for `plot_id` and `observation_date`, set additions/removals for `observers`, taxon-keyed entry rules for `species_cover`, and conflict or delimiter rules for `notes`.

When two concurrent submissions modify disjoint fields or distinct species keys, `record-store` automatically synthesizes a combined current visit with field-level provenance linking each field/entry to the submission that supplied it, keeping `review_status = resolved` (or, in a conservative variant, pre-populating a combined draft that still awaits coordinator sign-off). Only overlapping modifications to the same scalar field, the same species entry, or conflicting `notes` enter `needs_review`. `tablet-sync` persists base snapshots alongside local drafts to construct accurate changesets across multiple offline edits, and `review-export` displays field-level provenance and targeted conflict diffs for overlapping fields while letting cleanly merged visits flow directly into the Friday CSV.

**Demonstration**

Starting from base snapshot `S1` (`Spartina patens: 40%`, `observers: ["J. Morales"]`, `notes: ""`):
- *Case A (disjoint metadata + species addition)*: Worker A adds `"K. Chen"` to `observers`; Worker B adds `Salicornia pacifica: 10%` to `species_cover`. Three-way merge combines both automatically into an export-ready visit with field provenance pointing `observers` to A and `Salicornia pacifica` to B.
- *Case B (coupled ecological edit across distinct keys)*: Worker A deletes `Spartina patens` and inserts `Distichlis spicata: 35%` after realizing the grass was misidentified; Worker B leaves `Spartina patens` untouched and updates `notes: "Total graminoid cover ~40%, dominated by S. patens"` (or adds a second species assuming total canopy cover stays below 100%). Because `notes` and distinct species keys do not collide syntactically, disjoint merge combines A's taxon replacement with B's note referencing `S. patens` without flagging a conflict.

**Analysis**

- **No silent loss of submitted observations (gate)**: **passes** — raw worker submissions remain stored in history, and syntactic field collisions are routed to coordinator review rather than overwritten.
- **Cross-field scientific coherence**: **weak** — disjoint merge rules operate on field names and taxon keys, so edits that are syntactically disjoint (`species_cover` entry changes vs. `notes`, total canopy proportions across species, or taxon split/rename across distinct species keys) combine automatically without detecting ecological contradictions.
- **Friday export readiness and coordinator queue volume**: **strong** — concurrent edits to unrelated fields resolve automatically into export-eligible records, reserving coordinator time ahead of Friday export for overlapping field collisions.
- **Rule and operational maintainability**: **weak** — requires defining, testing, and maintaining merge semantics for each field shape (observer set operations, species identity keys when a taxon name itself changes, cover-sum interactions, and `notes` text handling) whenever the survey schema evolves.
- **End-to-end provenance inspectability**: **partial** — field-level provenance records which submission supplied each field, but an exported CSV row can represent a composite visit that neither field worker observed as a whole and no coordinator explicitly reviewed.
- **Preservation of non-overlapping fixes during reconciliation**: **strong** — non-overlapping field edits are combined deterministically by rule, eliminating manual copy omissions when combining unrelated fixes.
- **Offline tablet state and sync simplicity**: **partial** — tablets must retain immutable base snapshots alongside working drafts across restarts and shared-device handoffs so offline multi-step edits produce accurate diffs against the server base.

**Summary**

Reduces coordinator review load and deterministically combines unrelated field fixes at the cost of maintaining schema-coupled merge rules that can silently combine scientifically incompatible edits across fields.

## Selection

**Selected option: Whole-Visit Immutable Revisions.**

The inherited gate from *Do not silently discard a submitted edit* eliminates **Receipt- or Timestamp-Ordered Overwrite**. Between the two surviving approaches, **Whole-Visit Immutable Revisions** wins because **Cross-field scientific coherence** (major), **Rule and operational maintainability** (moderate), and **End-to-end provenance inspectability** (moderate) outweigh **Friday export readiness and coordinator queue volume** (major) at TidePlot's seasonal scale (~6,000 visits across 320 plots).

The decision turns on three HLD tenets and one explicit non-goal:

- **Non-goal against inference of scientific intent & *Keep the path from a submitted observation to an exported value inspectable***: Automated field-level merging makes an implicit claim that edits to distinct fields or species keys are scientifically independent. In vegetation surveys — where re-identifying a species affects cover estimates, multi-species cover proportions, and explanatory notes — that claim fails silently in exactly the cases hardest to spot in a downstream CSV. Whole-visit revisions guarantee every exported row is either one worker's intact observation or a coordinator's explicit whole-visit resolution.
- ***Prefer workflows two coordinators can operate without a dedicated systems administrator***: This tenet pulls in both directions — whole-visit revisions increase the weekly review queue, while three-way merge introduces nuanced per-field merge behaviors and composite provenance that coordinators must understand and trust without specialist support. Accepting a larger, transparent comparison queue is safer than operating subtle merge rules.
- ***Let field workers continue collecting observations without connectivity***: Tracking a single `base_revision_id` per cached visit keeps tablet local storage and retry recovery minimal across 48-hour offline windows.

### Why and When to Reconsider Field-Aware Three-Way Merge

**Field-Aware Three-Way Merge** remains a viable alternative if operational experience falsifies the queue-volume assumption — specifically if:

1. Concurrent edits occur frequently enough across the 12 shared tablets that two coordinators regularly cannot clear `needs_review` visits before the Friday partner CSV deadline, **and**
2. Inspection of resolved conflicts shows the overwhelming majority are routine, scientifically uncoupled edits (such as observer-list additions paired with unrelated notes) rather than coupled botanical revisions, **or**
3. Manual coordinator synthesis measurably drops non-overlapping field fixes despite diff highlighting in the review UI.

If those conditions arise, revisiting **Field-Aware Three-Way Merge** should treat coupled ecological fields conservatively — for example, treating `species_cover` and `notes` together as a single indivisible conflict unit while permitting automatic three-way merge only on genuinely independent metadata fields (such as `observers`), preserving whole-visit history so `record-store`'s revision ledger can migrate without losing prior provenance.

### Implications and Downstream Obligations

Committing to whole-visit revisions forecloses automatic server-side merging of concurrent disjoint edits; any concurrent branch places the visit into `needs_review` with `current_revision = null` until coordinator action. Downstream designs must accommodate this directly:

- **`tablet-sync` accommodations**:
  - Persist `current_revision.revision_id` as the local `base_revision_id` whenever caching a `resolved` visit (`null` only for newly created offline visits), and submit complete whole-visit payloads paired with an `idempotency_key`.
  - Present `needs_review` sync outcomes and `competing_revisions` clearly to field workers on shared tablets so workers understand their submission was safely retained for coordinator review rather than lost, and define local editing behavior when a visit on the tablet is already in `needs_review` (for example, branching explicitly from a chosen head revision vs. holding non-urgent edits until resolution).
- **`review-export` accommodations**:
  - Exclude all visits with `review_status = needs_review` (`current_revision = null`) from the Friday partner CSV and surface pending-review counts prominently so coordinators see blocked visits well before export.
  - Provide a side-by-side revision comparison screen driven by `competing_revisions` and `common_base_revision` that highlights per-field changes relative to the common base, making it fast for two coordinators to clear a larger queue and directly mitigating the risk of overlooking non-overlapping field fixes when assembling the resolved payload for `ResolveVisitReview`.
```

---

Does this decision doc and `record-store-design.md` look ready to approve for **Phase 2**? If so, let me know whether you'd like to defer the six Phase 2 probe edge cases under `Open Questions & Future Decisions` and move to **Phase 3 (`docs/intent/record-store/record-store-specs.md`)**, or settle any of them in the LLD first.