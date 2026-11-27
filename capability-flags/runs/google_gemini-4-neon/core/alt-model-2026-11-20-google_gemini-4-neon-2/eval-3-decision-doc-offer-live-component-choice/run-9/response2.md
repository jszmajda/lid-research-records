Created `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edits

## Context

TidePlot supports 24 seasonal field workers sharing 12 Android tablets across 320 permanent coastal vegetation plots, producing roughly 6,000 plot-visit records per season. Tablets can remain offline for up to 48 hours, and workers sometimes correct the same visit independently after comparing field notes. Arrival order at the server carries no scientific authority, and both options preserve every submitted payload without silent discard.

A visit contains structured scientific fields: plot reference, observation date, observer list, species cover estimates, and notes. Some concurrent edits are independent (for example, correcting an observer name while another worker adds a missing species). Other concurrent edits are scientifically coupled (for example, revising a species identification in one submission while another worker revises the cover estimate for the original species). The server cannot reliably infer scientific coupling from field names alone.

Two coordinators review flagged records before exporting a reviewed CSV to the regional science partner every Friday. The concurrency mechanism chosen by `record-store` is a foundational contract: `tablet-sync` must size its local state, submission payload, and status UI around it, and `review-export` must size its coordinator review interface, provenance display, and Friday CSV export eligibility rules around it.

## Decision Elements

No binary gate eliminates either option; both satisfy the standing invariants of offline capture and lossless preservation of submitted edits. Selection turns on five weighted criteria:

- **Preservation of scientifically coupled edits (major)** — Prevents concurrent edits to scientifically related fields from being combined automatically without human review. Grounded in the HLD non-goal *Automated botanical validation or inference of scientific intent* and the tenet *Keep the path from a submitted observation to an exported value inspectable*.
- **Operational and maintenance simplicity (major)** — Minimizes ongoing rule maintenance and engineering overhead as visit schemas or field semantics evolve. Grounded in the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*.
- **Coordinator review throughput and export readiness (major)** — Limits manual review volume for two coordinators so unrelated concurrent edits do not stall visits from reaching the Friday CSV export. Grounded in the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*.
- **Traceability from submission to exported value (moderate)** — Keeps the lineage from original worker submissions to an exported CSV row straightforward for coordinators and the regional science partner to inspect. Grounded in the tenet *Keep the path from a submitted observation to an exported value inspectable*.
- **Offline client state and sync footprint (minor)** — Minimizes local snapshot storage and sync complexity on shared Android tablets operating across 48-hour offline windows. Grounded in the tenet *Let field workers continue collecting observations without connectivity*.

## Options in the Domain

### Whole-visit revisions

**Description**

Each submission carries a `base_revision_id` naming the revision the worker edited from, along with the complete visit payload. Linear updates advance `current_revision_id` directly. When a submission arrives whose `base_revision_id` is older than `current_revision_id`, or arrives while the visit is already unresolved, the store persists the submission as an immutable competing revision and places the visit in `needs_review`. The visit is excluded from CSV export until a coordinator compares the competing whole-visit revisions and records a resolution (either selecting a winning revision or authoring a reconciled whole-visit revision).

**Demonstration**

Worker A fetches revision `rev-1` and corrects an observer name, submitting `rev-2` (`base_revision_id: rev-1`). Offline, Worker B also edits `rev-1` to revise a species identification and its cover estimate, submitting `rev-3` (`base_revision_id: rev-1`). Upon receiving `rev-3`, the store marks the visit `needs_review` with competing heads `[rev-2, rev-3]` and common ancestor `rev-1`. Neither edit is combined automatically; a coordinator reviews both complete visits side by side before the visit becomes eligible for Friday export.

**Analysis**

- **Preservation of scientifically coupled edits**: **strong** — Every submitted visit stays intact as a single scientific unit; coupled field edits are never combined without coordinator inspection.
- **Operational and maintenance simplicity**: **strong** — Conflict detection is a single revision-ID comparison (`base_revision_id == current_revision_id`) with no field-level merge rules to author or maintain as visit fields change.
- **Coordinator review throughput and export readiness**: **weak** — Any concurrent edit to the same visit creates a review item and blocks export until resolved, even when workers edited completely unrelated fields.
- **Traceability from submission to exported value**: **strong** — Every exported row maps directly to a single accepted or coordinator-resolved whole-visit revision, with full competing submissions preserved in history.
- **Offline client state and sync footprint**: **strong** — Tablets store only `base_revision_id` alongside the current local draft rather than a full prior snapshot, at the cost of transmitting complete (small text) visit payloads on each edit.

**Summary**

Trades higher manual review volume on disjoint concurrent edits for zero merge-rule maintenance and intact whole-visit scientific semantics.

### Field-aware three-way merge

**Description**

Each submission supplies its base state (or base revision reference) and structured field-level changes. When two concurrent edits arrive against the same base, the server compares modified fields using type-specific merge rules for scalar fields (observation date, notes), set/list fields (observer names), and keyed collections (species cover entries). Disjoint field changes are merged automatically into a new current visit state; only overlapping changes to the same field or entry are routed to coordinator review. Original submissions remain stored alongside field-level provenance recording which submission supplied each field value.

**Demonstration**

Using the same scenario above, Worker A changes `observers` and Worker B changes `species_cover` against `rev-1`. Because the changed fields do not overlap, the server automatically merges both changes into a new `current` visit ready for Friday export, recording field-level provenance for `observers` (Worker A) and `species_cover` (Worker B). If Worker A instead changed `species_cover[sp-1].taxon` while Worker B changed `species_cover[sp-1].cover_pct` or a note explaining that taxon, whether the merge rule catches the coupling depends on how the rule groups related fields.

**Analysis**

- **Preservation of scientifically coupled edits**: **weak** — Disjoint field paths combine automatically even when the edits are scientifically dependent (for example, a species note or cover estimate coupled to a species identification), unless coupling constraints are explicitly encoded and kept current in merge rules.
- **Operational and maintenance simplicity**: **weak** — Requires designing, testing, and maintaining merge rules for scalar fields, observer lists, and species cover collections, plus updating those rules whenever the survey schema changes.
- **Coordinator review throughput and export readiness**: **strong** — Disjoint concurrent edits resolve automatically without coordinator intervention, keeping the review queue smaller and allowing more visits to reach the Friday CSV export without delay.
- **Traceability from submission to exported value**: **partial** — Explaining an exported row requires field-level provenance across multiple contributing submissions and automatic merge events, rather than a single revision pointer.
- **Offline client state and sync footprint**: **partial** — Tablets must retain base snapshots to compute or transmit structured field-level diffs, increasing client state management complexity even though uploaded diffs are smaller than full visit payloads.

**Summary**

Trades merge-rule complexity and risk of silently combining scientifically coupled edits for lower coordinator review volume and faster export readiness.

## Selection

**Chosen: Whole-visit revisions.**

Whole-visit revisions win on the two major criteria tied to scientific integrity and operational sustainability: **preservation of scientifically coupled edits** (strong vs. weak) and **operational and maintenance simplicity** (strong vs. weak), as well as **traceability** (strong vs. partial) and **offline client state** (strong vs. partial). This turns directly on the HLD tenets *Keep the path from a submitted observation to an exported value inspectable* and *Prefer workflows two coordinators can operate without a dedicated systems administrator*, and avoids violating the non-goal *Automated botanical validation or inference of scientific intent* by never asking merge rules to guess whether two field edits are scientifically independent.

The decision knowingly accepts a **weak** fit on **coordinator review throughput and export readiness**: two coordinators will review some concurrent edits that only touched unrelated fields. At ~6,000 visits per season, a somewhat larger review queue is a bounded, visible operational cost, whereas silently producing a scientifically inconsistent merged record is an invisible data-quality failure.

### Why field-aware three-way merge remains a live alternative

Field-aware three-way merge is the primary alternative to revisit if operational evidence shifts the tradeoff—specifically, if concurrent edits to unrelated administrative and botanical fields prove frequent enough to bottleneck the two coordinators before Friday exports, and the team is willing to invest in explicit, domain-reviewed merge rules and field-level provenance.

### Implications and downstream obligations

This decision is owned by `record-store` and forecloses automatic server-side merging of disjoint fields and field-level provenance in the first release. It creates explicit downstream obligations (cascades, not co-ownership) for two sibling nodes:

- **tablet-sync**: Must retain the `base_revision_id` alongside each local draft, transmit complete visit payloads with a stable `idempotency_key` per edit, and surface `needs_review` outcomes and pending competing revisions clearly to field workers.
- **review-export**: Must provide a side-by-side whole-visit revision comparison and resolution workflow for `needs_review` visits, submit the exact reviewed `resolved_competing_revision_ids` set when resolving a conflict, and exclude `needs_review` visits from the Friday CSV export until resolved.
```

---

We're still at the **Phase 2 stop** for `record-store`. Let me know:
1. Any changes to the decision doc or `record-store-design.md`.
2. How you want to triage the Phase 2 edge-case probe items (1–9 from the previous message — which to lock into the LLD now vs. defer).
3. Whether you're ready to move on to **Phase 3 (EARS specs)** for `record-store` (and refresh the HLD's `record-store` status line).