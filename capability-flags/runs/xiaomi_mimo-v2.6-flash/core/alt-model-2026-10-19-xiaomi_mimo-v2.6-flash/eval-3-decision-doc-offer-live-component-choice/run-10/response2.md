**Phase 2 — LLD finished, decision doc written. Stop for your review.**

### Decision doc: `docs/intent/record-store/decisions/whole-visit-revisions.md`

```markdown
---
node: record-store
---

# Decision: Whole-visit revisions for concurrent visit edits

## Context

Field workers edit the same visit from separate offline tablets, sometimes days after fetching it. The record store must turn those submissions into one current visit without treating arrival order as authority and without discarding any submitted edit — both mechanisms below preserve originals, so that constraint eliminates neither.

The choice sets the submission contract tablet-sync implements and the unresolved-work representation review-export builds its review interface and export eligibility on.

## Decision Elements

- **Scientific integrity of reconciled values** (major; tenet: Keep the path from a submitted observation to an exported value inspectable) — whether every value in the current record traces to one submitted revision or one recorded coordinator decision, or whether software combined edits that were scientifically related without noticing.
- **Coordinator operating burden** (moderate; tenet: Prefer workflows two coordinators can operate without a dedicated systems administrator) — review actions required per season against two coordinators and a weekly export cadence.
- **Export readiness without human action** (moderate) — how many visits become export-eligible with no coordinator involvement. This criterion cuts toward automated combination.
- **Implementation and maintenance burden** (moderate) — logic that must stay correct as visit fields change over seasons, and who can safely modify it.
- **Tablet-side complexity** (minor) — client storage for base state, payload shape, and retry behavior on 12 shared tablets surviving 48-hour disconnections.

## Options in the Domain

### Whole-visit revisions

**Description.** Each submission carries the base revision ID the tablet edited from and a complete visit payload. The server appends the submission as a new revision when its base is the current revision. When the base is no longer current, the submission is stored as a competing revision and the visit enters unresolved review work: a coordinator compares complete revisions and records an outcome (adopt one revision's payload, or compose a replacement as a new revision). Originals stay in history. Tablets track one base revision ID per visit; review-export compares whole revisions and holds unresolved visits out of the export.

**Demonstration.** Current revision R12. Tablet A submits from base R12 (observer name fix); tablet B, offline since R12, submits from base R12 (species cover correction). A becomes R13. B's base no longer matches the current revision, so B is stored as a competing revision; the visit is unresolved until a coordinator records which payload (or composed replacement) becomes current.

**Analysis**

- Scientific integrity: **strong** — no software combines field values; the current record is one submitted revision or a coordinator-authored revision whose contributors are recorded.
- Coordinator operating burden: **weak** — every competing pair reaches review even when the edits touched unrelated fields; queue volume tracks the collision rate across ~6,000 visits per season.
- Export readiness without human action: **weak** — competing visits wait for a coordinator before entering the Friday CSV.
- Implementation and maintenance burden: **strong** — acceptance is a base-ID comparison; no per-field rule set to maintain as species, observer, or notes fields evolve.
- Tablet-side complexity: **strong** — the tablet stores one base revision ID per in-progress visit and sends the full payload it already holds; retry reuses the idempotency key unchanged.

**Summary.** Buys provable reconciliation at the price of a review queue that includes non-conflicting collisions.

### Field-aware three-way merge

**Description.** Tablets keep a base snapshot of each visit and submit structured changes against it. The server performs a three-way merge: fields changed on only one side combine automatically, and only overlapping changes reach review. A maintained rule set handles scalar fields, observer lists, and species entries; review-export shows field-level provenance for the overlaps it does display. Disjoint edits become export-ready without human action, shrinking the review queue to true conflicts.

**Demonstration.** Same base R12: tablet A changes the observer list, tablet B changes a species cover estimate. The merge treats these as disjoint fields, produces a combined record automatically, and the visit exports with no review. If both changed the same species' cover, that field alone is flagged for review.

**Analysis**

- Scientific integrity: **partial** — rules see field boundaries, not scientific relationships; an identification change on one side and its cover estimate on the other are disjoint to the rule set and combine silently, which is the failure mode this project's inspectable-path tenet most needs to avoid. Field-level provenance shows what happened after the fact but does not prevent a combination the rules cannot understand.
- Coordinator operating burden: **strong** — only genuine field overlaps create review work.
- Export readiness without human action: **strong** — disjoint collisions export without coordinator time.
- Implementation and maintenance burden: **weak** — separate merge rules for scalars, ordered observer lists, and species entries, each kept correct as fields are added or redefined; a rule change can alter historical merge behavior.
- Tablet-side complexity: **partial** — base snapshots occupy local storage for every in-progress visit, and the client must encode and version structured changes rather than sending the payload it already holds.

**Summary.** Buys a smaller review queue at the price of merge rules that must notice scientific relationships the data model does not express.

## Selection

**Whole-visit revisions.** The decision turns on scientific integrity (major): the project's inspectable-path tenet requires that an exported value be explainable by one submission or one recorded coordinator decision, and the merge option's rule set cannot express the relationships between a species identification, its cover estimate, and the observer list that produced them — silently combining them is the specific failure this system exists to replace. The burden criteria are weighed against it honestly: the team accepts a review queue that includes unrelated-field collisions, bounded by the two-coordinator tenet, rather than a maintained rule set whose mistakes are invisible at review time. Export readiness without human action is consciously traded away for the first release; automation can be revisited if the queue proves unworkable once real collision rates are known.

Committing forecloses automatic reconciliation of disjoint edits: every competing submission waits for a coordinator, and export eligibility is gated on resolution. It obligates downstream:

- **record-store** defines the revision chain, the submission envelope (base revision ID + full payload + idempotency key), the unresolved-work representation, and the resolution operation.
- **tablet-sync** stores a base revision ID per in-progress visit, sizes retry state machines around full-payload resubmission, and explains competing-revision outcomes to the worker.
- **review-export** provides a whole-revision comparison view and excludes unresolved visits from the CSV until a coordinator records an outcome.

The decision is taken against field-aware three-way merge as the first-release mechanism; if review volume later justifies automation, that reopens this decision rather than modifying it in place.
```

### LLD: `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

Concurrency is handled with whole-visit revisions: competing submissions are held for coordinator resolution rather than combined by the server. Tablet-sync and review-export are not yet designed; their contracts consume this node's definitions below rather than defining concurrency semantics of their own.

## Revision Model

A visit is a chain of revisions. Each revision stores the complete visit payload plus a revision ID, the ID of the revision it was edited from (its base), the author's ID, the server receipt time, and the submission's idempotency key. Original revisions are never rewritten; the current state of a visit is derived from the chain, not by mutating stored submissions.

A visit's scientific fields include observation date, observer list, species cover estimates, and notes. Some edits are unrelated, such as correcting an observer name and adding a missing species. Other edits are related, such as revising a species identification and its cover estimate. The server does not attempt to infer these relationships: it records whole revisions and lets a coordinator resolve competition.

Acceptance rule: if a submission's base revision ID equals the visit's current revision ID, the submission appends as the new current revision. Otherwise it is stored as a competing revision and the visit enters unresolved review work. A visit is unresolved exactly when competing revisions are waiting; the last resolved revision remains the current state until a coordinator records an outcome.

## Submission Contract

A submission carries the visit ID, the base revision ID, the complete visit payload, and an idempotency key. The server authenticates the submitting worker and validates field types and plot references before accepting. A retry with the same key and an identical payload returns the original acceptance result; reuse of an accepted key with a different payload is rejected, so a connection failure cannot create a second edit.

Both branches of the acceptance rule store the original payload with its author and receipt time. A submission that creates competition is an ordinary acceptance — the worker's edit is retained in full and surfaces as review work, not as an error.

## Retrieval Contract

Retrieving a visit returns the current revision (payload and metadata), the visit's status (`resolved` or `unresolved`), and, while unresolved, summaries of each competing revision: revision ID, base revision ID, author, and receipt time. Callers can therefore distinguish a usable current state from outstanding review work without joining a second endpoint.

Submission-history retrieval returns the full chain in receipt order, including revisions that lost a resolution, so any exported value can be traced to the submission it came from.

## Unresolved Work and Resolution

Resolution is a coordinator operation on one visit. The coordinator supplies the contributing submission IDs and an outcome: either adopt one competing revision's payload as current, or compose a replacement payload as a new revision authored by the coordinator. The server records the coordinator's identity, the contributing submission IDs, and the outcome, then advances the visit's current revision accordingly.

Competing revisions not incorporated by an outcome remain competing; the visit stays unresolved until every competing revision has been accounted for by some recorded outcome. Losing submissions stay in history under the same preservation rule as all submissions.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrent visit edits | Whole-visit revisions ([decision doc](decisions/whole-visit-revisions.md)) | Field-aware three-way merge; overwrite on arrival (today's spreadsheet import behavior) | A review queue of competing revisions is preferred to merge rules that would combine scientifically related edits without noticing; arrival-order overwrite discards submitted edits. Full tradeoff in the decision doc. |
| Current state while unresolved | Last resolved revision plus the set of competing revisions | Latest-arrival payload as current; any server-combined view | Arrival order is not authority, and no combined view exists under this model; tablets and reviewers need one stable base to display and edit from. |
| Submission retry | Idempotency key checked against payload equality | Deduplication by visit and author; at-most-once delivery without server-side replay | Offline retry must be safe without forbidding deliberate follow-up edits to the same visit. |
| Visit identity | Client-generated UUID assigned before first submission | Server-assigned ID returned on first sync | Visits are created on tablets with no connectivity; a server round-trip cannot participate in creation. |
| Resolution outcomes | Adopt one competing revision, or compose a replacement as a coordinator revision | Coordinator-only free edit with no contributing IDs; automatic selection of latest arrival | Every outcome must name its contributors so the exported value stays inspectable to the submissions it came from. |

## Open Questions & Future Decisions

### Resolved

1. ✅ Concurrency policy for concurrent visit edits: whole-visit revisions — recorded in [decisions/whole-visit-revisions.md](decisions/whole-visit-revisions.md).

## Downstream Obligations

Tablet-sync sizes its local storage and retry state machine around the submission contract: it stores a base revision ID per in-progress visit, resubmits full payloads under the idempotency key, and surfaces competing-revision outcomes to the worker. Review-export sizes its coordinator interface and export eligibility around the unresolved-work representation: it provides a whole-revision comparison view and excludes unresolved visits from the CSV until a resolution outcome exists.

Both nodes link back to this design rather than inventing their own concurrency semantics.
```

### LLD-level edge-case probe — triage needed

"What happens when…" questions aimed at this LLD's own gaps. Number the ones you want fixed in the LLD now; the rest I'll record as Deferred open questions.

1. **First submission to a brand-new visit.** There is no current revision to match a base against. Does the first submission create the chain root (base empty/null accepted), or must tablets fetch a server-created stub first?
2. **Base revision ID matches no stored revision** (corrupt client, truncated history). Reject as invalid — which risks stranding an edit the tenet says not to discard — or accept it as a competing revision against current?
3. **Two coordinators resolve the same visit concurrently.** Both compute against the same current revision. Is the second outcome rejected as stale, queued, or applied on top? The LLD says nothing about serializing resolutions.
4. **Can a coordinator decline a competing revision?** Outcomes listed are adopt or compose; "accounted for by some recorded outcome" is vague. Is an explicit recorded decline a third outcome (visible, not silent discard), or must every competing revision be incorporated?
5. **A tablet edits from a competing (non-current) revision** of an unresolved visit and submits with that as base. Allowed — building lineage among pendings — or must base always be the current revision?
6. **Revision retention.** Is submission history ever pruned, given ~6,000 visits per season each accumulating revisions?

### Other flags

- **Cross-boundary cascade (needs your permission):** `site-catalog-design.md` still says "Tablet-sync's visit submission and reconciliation behavior remains pending that choice." That choice is now made; the line is stale. It's in the site-catalog segment — want me to update that one line when we cascade, or leave it?
- **Still open from Phase 1:** the candidate tenet ("Prefer visible coordinator review over automated combination of edits") — add to the HLD Tenets, or leave it as decision-doc rationale only?

Reply with numbered feedback (or "approved") and I'll proceed to Phase 3 — EARS specs for the revision contract plus a post-draft consistency report.