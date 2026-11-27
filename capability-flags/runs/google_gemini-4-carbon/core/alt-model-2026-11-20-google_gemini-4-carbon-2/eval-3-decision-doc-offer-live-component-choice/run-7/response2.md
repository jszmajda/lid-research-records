I wrote `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md` (with `Downstream Contracts` aligned to match).

### `docs/intent/record-store/decisions/concurrent-visit-edits.md`

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edits

## Context

Twenty-four seasonal field workers share 12 Android tablets across 320 permanent coastal vegetation plots, submitting roughly 6,000 plot-visit records per season. Two coordinators review problem records ahead of a weekly Friday CSV export to a regional science partner.

Tablets operate offline for 48 hours or longer, and workers sometimes revise the same visit independently after comparing field notes. Because sync order reflects when a tablet regains connectivity rather than which observation is accurate, the server cannot treat arrival time or device clock order as scientific authority.

Each visit record contains a plot reference, observation date, observer list, species cover estimates, and free-text notes. Some concurrent edits touch independent parts of a visit, such as fixing an observer's spelling on one tablet while adding an overlooked species on another. Other edits express a single coupled botanical judgment across multiple fields without structural markers—for example, re-identifying a specimen, adjusting its percent cover, and updating notes that explain the plot's total cover. How `record-store` reconciles concurrent edits determines both the scientific integrity of exported records and the contracts that `tablet-sync` and `review-export` must implement.

## Decision Elements

### Gates

- **No silent overwrite of submitted edits** *(inherited — HLD tenet: "Do not silently discard a submitted edit")*: Accepted concurrent submissions must never overwrite one another in the current or exported visit state based solely on receipt order or timestamp; every submitted edit must either be preserved in a non-conflicting combination or surfaced explicitly for resolution.

### Weighted Criteria

- **Preservation of cross-field scientific coherence** (**major** — HLD tenet: *Do not silently discard a submitted edit*; HLD non-goal: *Automated botanical validation or inference of scientific intent*): Avoid producing a current visit record whose fields were never observed or verified together, such as combining one worker's taxonomic re-identification with another worker's cover adjustment or field note written under the prior identification.
- **Inspectability of provenance from submission to export** (**major** — HLD tenet: *Keep the path from a submitted observation to an exported value inspectable*): How directly a coordinator or science partner can trace an exported Friday CSV row back to the worker submission(s) and coordinator decisions that produced it.
- **Rule-set and operational simplicity** (**major** — HLD tenet: *Prefer workflows two coordinators can operate without a dedicated systems administrator*): Freedom from maintaining, evolving, and debugging field- and list-level merge rules across scalar fields, observer collections, and species-cover entries.
- **Coordinator review queue volume and Friday export readiness** (**moderate** — HLD tenet: *Prefer workflows two coordinators can operate without a dedicated systems administrator*; HLD goal: *Make reviewable problems visible before the Friday export*): Keeping genuinely unrelated concurrent edits out of manual review so two coordinators are not overloaded before the Friday export and routine visits are not held back from the CSV.
- **Availability of a settled head during concurrent syncs** (**moderate** — HLD tenet: *Let field workers continue collecting observations without connectivity*): Whether independent edits synced from two tablets still leave a single usable current visit for other shared tablets syncing before a coordinator reviews the queue.
- **Tablet local baseline state** (**minor** — HLD tenet: *Let field workers continue collecting observations without connectivity*): Keeping local persistence on offline Android tablets minimal across restarts without storing separate baseline copies alongside working drafts.

## Options in the Domain

### Option 1: Whole-Visit Revisions

Each accepted worker submission or coordinator resolution creates an immutable whole-visit revision in a per-visit revision graph. A tablet submits the complete visit payload alongside the `base_revision_id` it started from (`null` on initial creation). When `base_revision_id` matches the visit's sole active head, the new revision advances the head linearly and the visit stays `resolved`. When `base_revision_id` has already been superseded, the new revision is retained as a competing active head alongside existing active heads, placing the visit in `needs_review` with no single current state until a coordinator reviews the competing revisions against their base snapshot(s) and submits an explicit resolution.

**Demonstration**: Visit `V-104` at revision `R1` lists *Spartina patens* (40% cover), observer `[A. Rivera]`, and note `"Salt pan edge"`. Offline Tablet 1 re-identifies the grass from a pressed voucher as *Distichlis spicata* (40% cover) and updates the note to `"Voucher confirmed Distichlis"`, submitting against `R1` to produce `R2`. Offline Tablet 2, also starting from `R1`, updates *Spartina patens* cover to 55% and adds observer `B. Chen`, producing `R3`. `record-store` retains both `R2` and `R3` as active heads (`needs_review`), holds `V-104` out of the Friday CSV, and gives the coordinator `R1`, `R2`, and `R3` side-by-side to produce resolved revision `R4`.

**Analysis**:
- **No silent overwrite of submitted edits**: **passes** — every concurrent branch remains an active head until explicitly superseded by a coordinator resolution, and original submissions remain immutable.
- **Preservation of cross-field scientific coherence**: **strong** — each worker's visit stays intact as observed; fields from separate submissions are combined only when a coordinator inspects both revisions in context.
- **Inspectability of provenance from submission to export**: **strong** — every exported visit maps to a single settled revision created either by one worker submission or by one explicit coordinator resolution naming its contributing submissions.
- **Rule-set and operational simplicity**: **strong** — conflict detection reduces to checking whether `base_revision_id` equals the sole active head; no field-diff or collection-merge rules exist to maintain or explain.
- **Coordinator review queue volume and Friday export readiness**: **weak** — any concurrent edit to the same visit, including disjoint fixes such as adding a missing observer on one tablet and fixing a date on another, enters `needs_review` and is held out of the Friday CSV until resolved.
- **Availability of a settled head during concurrent syncs**: **weak** — every concurrent edit places the visit in `needs_review` (`current_revision: null`), leaving no single settled head for other syncing tablets until a coordinator resolves the competing revisions.
- **Tablet local baseline state**: **strong** — tablets persist only the working visit plus a single `base_revision_id` token rather than a separate immutable base snapshot, and structured text/cover payloads remain a few kilobytes on the wire without photographs.

**Summary**: Preserves whole-visit scientific intent and keeps server/client concurrency mechanics minimal, at the cost of routing every concurrent visit edit through coordinator review.

### Option 2: Field-Aware Three-Way Merge

Tablets retain the full base visit snapshot downloaded at sync time and submit structured changes alongside the base state (or base revision reference). `record-store` applies deterministic three-way merge rules relative to the base snapshot: scalar fields (`plot_id`, `observation_date`, `notes`) merge automatically when only one branch modifies a field and conflict when both modify the same field to different values; `observers` merges as a keyed set of additions and removals; `species_cover` merges per taxon identifier so edits to distinct species combine automatically while concurrent edits to the same taxon (or delete-versus-modify on a taxon) trigger targeted field/entry review. Visits with strictly disjoint edits become `resolved` immediately via a system-generated merged revision; visits with overlapping field edits enter `needs_review` with field-level conflict markers.

**Demonstration**: Starting from the same `V-104` at `R1`, if Tablet 1 adds observer `B. Chen` and Tablet 2 appends a weather note, three-way merge combines both changes automatically into an export-ready visit with zero coordinator review. In the voucher re-identification scenario, however, if Tablet 1 replaces *Spartina patens* with *Distichlis spicata* and edits `notes` while Tablet 2 updates `observation_date` and adds a second species whose cover estimate assumed the prior *Spartina* baseline, disjoint fields and distinct taxon keys combine automatically without flagging the cross-field relationship; where Tablet 2 instead updates *Spartina patens* cover to 55%, the delete-versus-modify rule on *Spartina patens* flags that species entry while auto-merging `B. Chen` and Tablet 1's note.

**Analysis**:
- **No silent overwrite of submitted edits**: **passes** — original submissions are retained, disjoint field changes are preserved in the merged record, and overlapping edits to the same field or taxon key are routed to coordinator review rather than overwritten.
- **Preservation of cross-field scientific coherence**: **weak** — merge rules operate on field names and taxon keys and cannot detect implicit botanical relationships across species entries, cover totals, and free-text notes, allowing scientifically inconsistent hybrid visits to pass straight to export.
- **Inspectability of provenance from submission to export**: **partial** — explaining an auto-merged CSV row requires per-field and per-species-entry attribution across multiple worker submissions plus knowledge of the merge rules active when the merge ran.
- **Rule-set and operational simplicity**: **weak** — requires specifying, testing, and maintaining merge semantics for scalars, observer lists, species rename-versus-delete+add cases, and N-way merges when three offline tablets edit the same visit.
- **Coordinator review queue volume and Friday export readiness**: **strong** — routine concurrent edits to unrelated fields resolve automatically on ingest and qualify immediately for the Friday CSV, reserving coordinator attention for direct field collisions.
- **Availability of a settled head during concurrent syncs**: **strong** — disjoint concurrent edits merge immediately into a single current revision that syncing tablets can fetch and build upon without waiting for coordinator intervention, stalling only when edits collide on the same field or taxon.
- **Tablet local baseline state**: **weak** — tablets must persist an immutable base snapshot alongside every modified draft across app restarts and multi-day disconnections to compute structured three-way changes accurately.

**Summary**: Minimizes coordinator review toil and maximizes automatic Friday export readiness for routine disjoint edits, at the cost of maintained merge rules and silent combination of scientifically coupled edits across distinct fields.

### Option 3: Last-Write-Wins by Receipt or Device Timestamp

Each submission sends a whole-visit payload, and `record-store` marks whichever submission has the latest server receipt time (or latest tablet clock timestamp) as the visit's current `resolved` state while archiving earlier submissions in history.

**Demonstration**: In `V-104`, if Tablet 1 syncs on Wednesday and Tablet 2 comes back from a remote marsh on Thursday and syncs its edit from Tuesday's notes, receipt-order last-write-wins promotes Tablet 2's state to current and drops Tablet 1's voucher re-identification from Friday's CSV without surfacing any review item. Device-clock ordering fails similarly when shared tablet clocks drift or when a later edit on one field unintentionally overwrites an earlier correction on another field.

**Analysis**:
- **No silent overwrite of submitted edits**: **eliminated** — concurrent submissions overwrite earlier (or earlier-clocked) edits in the current exported state without surfacing the lost changes for combination or coordinator review.
- **Preservation of cross-field scientific coherence**: **strong** — the winning record is always a single whole-visit observation, though achieved by discarding competing whole-visit observations.
- **Inspectability of provenance from submission to export**: **partial** — the winning submission is easy to identify, but superseded concurrent edits are invisible in the current state unless someone manually audits submission history.
- **Rule-set and operational simplicity**: **strong** — requires no branching state, merge logic, or review queue.
- **Coordinator review queue volume and Friday export readiness**: **strong** — creates zero concurrency review work and never holds visits out of export.
- **Availability of a settled head during concurrent syncs**: **strong** — always exposes a single current revision to syncing tablets, though achieved by discarding competing edits.
- **Tablet local baseline state**: **strong** — tablets store only the working visit payload without base snapshots or revision IDs.

**Summary**: Eliminated by the gate against silently discarding submitted edits, reproducing the exact spreadsheet-import failure TidePlot exists to replace.

## Selection

Select **Option 1: Whole-Visit Revisions**.

**Last-Write-Wins** fails the gate derived from *Do not silently discard a submitted edit*. Between **Whole-Visit Revisions** and **Field-Aware Three-Way Merge**, the decision turns on the three **major** criteria and how TidePlot's tenets weigh them:

1. **Scientific coherence and non-inference**: TidePlot explicitly excludes *automated botanical validation or inference of scientific intent* and prioritizes *Do not silently discard a submitted edit*. Field-aware merging treats structural disjointness (different field names or different taxon IDs) as semantic independence, which does not hold when workers re-identify species, rebalance cover estimates, or explain observations in notes. Whole-visit revisions guarantee that cross-submission combinations happen only under coordinator judgment.
2. **Provenance inspectability**: Under *Keep the path from a submitted observation to an exported value inspectable*, every exported row under whole-visit revisions traces to one whole-visit revision—either a single worker's intact submission or an explicit coordinator resolution naming the competing revisions and contributing submissions—without reconstructing per-field merge provenance.
3. **Operational trade within coordinator capacity**: *Prefer workflows two coordinators can operate without a dedicated systems administrator* pulls in both directions here: whole-visit revisions removes the ongoing burden of maintaining and troubleshooting field/collection merge rules, while increasing the manual review queue whenever workers make unrelated concurrent edits to the same visit. Across ~6,000 seasonal visits over 320 plots, independent post-capture edits to the same visit are an exception path rather than steady-state traffic for every record, making a larger review queue preferable to silent cross-field merge errors.

### Why Field-Aware Three-Way Merge Remains Reconsiderable

A future maintainer should revisit **Option 2** (or a constrained hybrid that auto-merges administrative metadata such as `observers` while keeping `species_cover` and `notes` coupled as an atomic block) only if production history shows both of the following:
- Concurrent edits to the same visit occur at high enough volume to bottleneck the two coordinators ahead of the Friday export or routinely hold a meaningful share of visits out of the weekly CSV.
- Audit of resolved `needs_review` visits shows those concurrent edits are overwhelmingly routine, scientifically independent changes (such as observer-list corrections vs. date fixes) rather than coupled species/cover/note revisions.

Because `record-store` already retains immutable submissions and parent revision snapshots in a revision DAG, introducing constrained auto-merge later would add a new `source_type` for auto-merged revisions rather than discarding the underlying revision model.

### Implications and Downstream Obligations

Committing to whole-visit revisions forecloses automatic server-side merging of concurrent edits: any two accepted edits anchored to the same superseded state will hold that visit out of the Friday export until a coordinator resolves them. Sibling nodes must accommodate the following obligations:

- **`tablet-sync` accommodations**:
  - Persist the server-assigned `revision_id` with each synced visit and send it as `base_revision_id` (`null` for new offline visits) alongside the complete whole-visit payload and a stable per-edit `idempotency_key`.
  - Coalesce multiple sequential local draft saves made on a single tablet while offline into one submission anchored to that tablet's last synced `base_revision_id`, preventing a single worker's iterative offline drafting from creating multiple server revisions.
  - Distinguish `resolved` acceptance from `needs_review` acceptance in the tablet UI so field workers see clearly that a competing edit was preserved and sent to coordinator review rather than lost or rejected.
  - Define local viewing and editing behavior when a tablet syncs a visit currently in `needs_review` (where `current_revision` is `null` and multiple `head_revision_ids` exist—for example, displaying competing revisions read-only by default and requiring the worker to explicitly base any urgent follow-up field correction on a chosen head revision).
- **`review-export` accommodations**:
  - Provide a coordinator review queue backed by `ListUnresolvedVisits` and a whole-visit comparison screen backed by `GetVisitReviewDetail` that renders all active `competing_revisions` side-by-side against `base_revisions`, visually highlighting field and species-list differences relative to each branch's starting revision so coordinators can resolve routine disjoint edits quickly alongside complex botanical conflicts.
  - Allow coordinators either to adopt one competing whole-visit revision directly or to assemble a verified whole-visit payload across branches, submitting `ResolveVisitRevisions` with the reviewed `resolved_revision_ids` and surfacing stale head-set conflicts if another offline tablet syncs mid-review.
  - Exclude every visit with `has_unresolved_review: true` (`visit_status: needs_review`) from the Friday partner CSV, and display pending `needs_review` counts prominently ahead of export so unresolved visits are visible before Friday.
  - Record or expose the settled `current_revision` reference alongside exported visits so partner questions trace directly back through `GetVisitHistory` to original submissions and coordinator resolutions.
```

---

### Phase 2 Review Check

1. Does this decision doc and `record-store-design.md` match what you want?
2. Before we move to Phase 3 (`record-store-specs.md`), one sharp edge case from the LLD probe worth a quick call (we can park the rest as deferred open questions if you'd like): **if two workers independently enter the exact same correction from the same `base_revision_id`** (for example, both add missing observer `B. Chen` and nothing else differs), should `record-store` still send both branches to `needs_review` like any other concurrent edit, or auto-coalesce byte-identical payloads into one `resolved` head while keeping both original submissions on record?