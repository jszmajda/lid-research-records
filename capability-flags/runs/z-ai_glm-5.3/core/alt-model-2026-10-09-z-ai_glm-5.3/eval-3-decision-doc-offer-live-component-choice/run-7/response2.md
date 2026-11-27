The decision doc is written at `docs/intent/record-store/decisions/visit-edit-concurrency.md`, and the concurrency row in the LLD's Decisions & Alternatives table now links to it. Here it is in full:

---

# Decision: Whole-visit revisions for concurrent visit edits

## Context

Field workers correct the same visit independently after comparing notes, and tablets can be offline for 48 hours, so the record store regularly accepts edits prepared against a visit state that is already out of date. The store must define which edit becomes the current record when that happens.

Some concurrent edits touch unrelated parts of a visit (an observer-name fix and an added species). Others touch fields that are scientifically coupled even though the field names do not show it — a revised species identification and the cover estimate recorded for the earlier identification belong together. The store cannot recover these relationships from field names, and a wrongly combined record lands in the reviewed CSV the regional science partner receives every Friday. Two coordinators handle all review work.

Inherited constraints both candidates respect (background, not selection elements): original submissions are never discarded; the path from a submitted observation to an exported value stays inspectable; workflows are operable by two coordinators without a systems administrator.

## Decision Elements

**Gates.** None eliminates an option in contention: both candidates retain original submissions, keep provenance inspectable, and run on infrastructure the team already operates. The decision runs on weighted criteria.

- **Silent loss or alteration of submitted intent** — major; tenet: *do not silently discard a submitted edit*. A mechanism that resolves overlapping fields by rule, or combines fields a worker meant to travel together, discards that worker's intent without anyone seeing it happen.
- **Provenance explainability** — major; tenet: *keep the path from a submitted observation to an exported value inspectable*. Values in the reviewed CSV must trace back to submissions without a dedicated provenance system.
- **Coordinator workload** — major. Review volume and per-item effort at roughly 6,000 visits per season across two coordinators, against a Friday export.
- **Maintenance burden** — moderate; tenet: *workflows two coordinators can operate without a dedicated systems administrator*. Rules that need authoring, tuning, and debugging.
- **Offline cost** — moderate. Submission size and tablet-local storage over 48-hour disconnections and multi-day retries.
- **Time to export-ready** — moderate. How quickly a visit touched by concurrent edits becomes eligible for the Friday CSV.

Latent criteria probed and folded in: per-item review effort (a whole-visit diff is one coordinator decision; field-level review is fewer but finer-grained decisions) folds into coordinator workload; the missing second pair of eyes on automatically approved records folds into silent loss.

## Options in the Domain

### Whole-visit revisions

Each accepted submission is a complete revision naming the revision it was prepared against. Base equals current: the revision becomes current. Base behind current: it waits as pending, and a coordinator resolves — selecting one revision, authoring a combined payload, or dismissing the pending set. Nothing merges automatically; the comparison a coordinator sees is a whole-visit diff.

Tablet-sync must accommodate: retain the current revision ID per visit; submit a full payload plus base revision ID and idempotency key; show the worker whether an acceptance landed as current or pending.

Review-export must accommodate: a revision-comparison screen over current versus pending; unresolved visits held out of the CSV.

Analysis:

- Silent loss: **strong** — no submitted intent is altered or combined without a human act; the only loss path is a coordinator's explicit, recorded decision.
- Provenance: **strong** — provenance is submission-shaped; every exported value traces to a stored revision and its resolution outcome.
- Coordinator workload: **weak** — every concurrent edit becomes review work, including edits to unrelated fields.
- Maintenance burden: **strong** — no merge rules exist to author or tune.
- Offline cost: **partial** — every edit resends the complete visit payload.
- Time to export-ready: **weak** — the visit stays unresolved, and out of the CSV, until a coordinator acts.

Summary: every concurrent edit is seen by a human, at the cost of a queue sized by how often concurrency happens.

### Field-aware three-way merge

Each edit supplies its base state and structured field changes. Disjoint changes combine automatically; overlapping changes queue for review as usual. Merge rules cover scalar fields, observer lists, and species entries. In its strongest form, every combined record is additionally routed through mandatory manual approval, so a human still signs off on each combination.

Tablet-sync must accommodate: retain a base snapshot per visit; compute and send structured changes; reconcile server merge outcomes against local expectations.

Review-export must accommodate: field-level provenance views; a review screen for overlapping changes, with its semantics defined by the maintained merge rules.

Analysis:

- Silent loss: **weak** — the rules combine fields whose scientific coupling they cannot see: a species-identification correction and the cover estimate belonging to the earlier identification merge as "disjoint," and the result enters the record with no one the wiser. Overlap rules that pick a side discard one worker's intent by rule. Mandatory approval of combinations repairs this only by handing back the option's main advantage — every combined record becomes a review item anyway, and the reviewer signs off on a pre-combined whole rather than judging the workers' competing intents.
- Provenance: **partial** — export-ready values carry field-level lineage, which is finer-grained but demands a provenance representation and interface maintained alongside the rules.
- Coordinator workload: **strong** — only overlapping edits queue; disjoint concurrent edits never occupy a coordinator.
- Maintenance burden: **weak** — merge rules for three field shapes must be authored, tuned, and debugged by two coordinators with no systems administrator.
- Offline cost: **partial** — base snapshots ride on every submission and must be held locally; total bytes are comparable to full payloads.
- Time to export-ready: **strong** — disjoint concurrent edits become export-ready with no human latency.

Summary: concurrency costs the coordinators almost nothing, but the rules that save that effort are exactly the mechanism that can hide a scientifically wrong combination.

## Selection

**Whole-visit revisions.**

The decision turns on silent loss and provenance — both major, both tenet-anchored — where the merge option is weakest and the revision option strongest. The merge option's strengths are real, but they are costs the team can see and schedule around: a larger queue is visible in the review screen and can be worked down before Friday; a scientifically wrong combination produced by rules is invisible in the output and reaches the science partner. The choice accepts review volume over rule maintenance, so every concurrent-edit judgment is made by a named human.

What committing forecloses: no concurrent edit reaches the current record without either being based on the current state or passing through a coordinator. There is no path on which an edit combination skips human review.

What committing obligates:

- **Tablet-sync**: track base revision IDs per visit; submit complete payloads with base revision IDs and idempotency keys; surface current-versus-pending acceptance outcomes and rejection reasons to the worker; size local storage for full payloads.
- **Review-export**: build the revision comparison (current versus pending, whole-visit diffs) on the store's retrieval shapes; order the review queue by oldest pending receipt time; hold unresolved visits out of the Friday CSV using the store's export-eligible enumeration.

The field-aware option remains the credible alternative, and this decision should be re-run if its criteria change weight: if measured concurrency makes the queue a genuine bottleneck — visits' readiness slipping past the Friday export, coordinator hours exceeding capacity — coordinator workload and time to export-ready rise toward dominance, and a conservatively scoped merge (disjoint-only, mandatory manual approval of every combined record) becomes worth building. Nothing structural blocks that re-run: both options retain original submissions and revision lineage, so the data a later switch needs is exactly what this design already keeps.

---

Still holding at the Phase 2 stop from my last message — to proceed to the EARS update I need your rulings on:

1. **LLD approval** or numbered feedback on the design as presented (including the two HLD touches).
2. **Two stances to confirm or veto**: fast-forward during unresolved state (a submission based on current still becomes current while pending work persists); base-less submission against an existing visit is rejected.
3. **Deferred-item triage**: my suggestion was to keep all five deferred (concurrent resolution, duplicate visits, queue ordering, rejection audit, coordinator corrections outside review) — agree, or pull any into the LLD now?