Phase 1 — HLD check: coherent, no architectural change. The HLD already delegates the concurrency mechanism to record-store, so selecting whole-visit revisions does not reshape the architecture. I updated two now-stale lines in `docs/high-level-design.md` as a same-tree cascade: the record-store State cell no longer reads "concurrency choice open," and the paragraph no longer says tablet-sync and review-export "must wait for its contract."

Phase 2 — finalized `docs/intent/record-store/record-store-design.md`:

---

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

A visit's scientific fields include observation date, observer list, species cover estimates, and notes. Some edits are unrelated, such as correcting an observer name and adding a missing species. Other edits are related, such as revising a species identification and its cover estimate. The server cannot infer all such relationships from field names, so it does not attempt to combine edits automatically.

Concurrent edits are handled as whole-visit revisions: every edit names the revision it started from, and an edit made against a revision that has since advanced is preserved as a competing revision for a coordinator to resolve. This node defines the submission envelope, revision lineage, unresolved-work representation, and resolution operation. Tablet-sync and review-export build on this contract rather than inventing their own concurrency semantics.

## Architecture

The record store exposes authenticated submission, current-state retrieval, submission-history retrieval, and review-resolution operations. Persistence keeps original submissions, their authors, and server receipt times. A submission carries an idempotency key so a connection failure does not create another edit on retry.

## Revisions

A visit is a tree of revisions. Each accepted submission creates one revision carrying:

| Field | Meaning |
|---|---|
| revision ID | Server-assigned identifier, unique and stable for the life of the record. |
| visit ID | The client-generated visit UUID the revision belongs to. |
| base revision ID | The revision the editing worker started from, or null for the visit's first revision. |
| author ID | The authenticated worker who submitted the revision. |
| receipt time | Server time the submission was accepted. |
| payload | The complete visit field values as submitted. |

A revision is a complete visit, not a field diff. A resolution therefore selects one submitted visit as a whole and never combines fields from two.

## Submission

Authenticate the submitting worker and validate field types, plot references, and the base revision ID before accepting a submission. The base revision ID must name a revision of the same visit, or be null for the visit's first revision.

Preserve the original payload separately from the resolved state. A retry with the same idempotency key and identical payload returns the original acceptance result; reuse with a different payload is rejected and leaves the original submission unchanged.

## Current State and Unresolved Work

A visit has one or more branch tips — revisions no other revision names as its base. A visit with a single tip has a usable current state and no unresolved work. A visit with more than one tip is unresolved: the tips compete, and a coordinator must resolve them.

An edit submitted against the current tip adds the next revision on the same branch and produces no review work. An edit submitted against any other revision forks a new branch and makes the visit unresolved.

Current-state retrieval returns the revision a coordinator last selected, or — before any fork — the single tip, together with a flag indicating whether unresolved work exists. Submission-history retrieval returns every retained revision with its author and receipt time, so a coordinator can compare competing tips.

## Review Resolution

A coordinator resolves an unresolved visit by selecting one branch tip as the current state. The record store retains the coordinator's identity, the selected revision ID, and the IDs of the competing submissions resolved among. Unselected revisions remain retrievable in the visit's history. Resolution does not discard any submission.

## Contract Consumers

Tablet-sync caches the base revision ID alongside each cached visit and submits each edit against that ID; it holds a local draft until the server accepts it. Review-export reads the unresolved-work flag and submission history to present competing revisions side by side, and includes a visit in the export set only when it has no unresolved work.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrency policy for independently edited visits | Whole-visit revisions: each edit names its starting revision; concurrent edits become competing revisions a coordinator resolves | Field-aware three-way merge (auto-combine disjoint field changes, review overlaps) | Whole-visit revisions keep each submitted visit intact and need no maintained merge rules. A merge engine could combine scientifically related edits — a species re-identification with its cover estimate — without noticing the relationship. The team accepts a larger review queue and more visits held out of export in exchange for never emitting a silently combined record. This turns on the tenets *Do not silently discard a submitted edit* and *Keep the path from a submitted observation to an exported value inspectable*. |
| Unit of a submission | A complete visit revision | Structured field-level changes | Preserving the whole payload makes the resolved record a choice among intact submitted visits and keeps the worker's actual submission as the retained unit. |
| Resolution outcome | A coordinator selects one retained branch tip; revisions are not combined | Automatic or manual field combination | Avoids reintroducing merge rules through the review path, keeping review a comparison rather than a merge. |
| Revision identity | Server-assigned revision ID; each edit carries its base revision ID | Client-assigned revision IDs; arrival order as authority | Server assignment gives one ordering authority, and base revision IDs let the server detect forks without treating arrival order as evidence of authority. |

## Open Questions & Future Decisions

### Resolved

1. ✅ Concurrent visit edits use whole-visit revisions; resolution selects a retained revision (see Decisions).

### Deferred

1. Retention window and storage limit for a visit's revision history as seasons accumulate.
2. Whether a resolution is revisable after it is recorded, and by whom.
3. Validation behavior when a submission's base revision ID is unknown or names another visit.

## References

- `docs/high-level-design.md` — project tenets and architecture.
- `docs/intent/record-store/record-store-specs.md` — EARS specs for this node.
```

---

Phase 2 edge-case probe (independent reader) — gaps it found in this LLD, for you to triage as fix-now vs. defer:

- What happens when a coordinator resolves a visit but unselected tips remain — how does the unresolved-work flag become false, and are the left-behind tips still "tips"?
- What happens when a new submission after a resolution bases against the newly selected current state while unselected tips remain — does the visit stay resolved or re-fork?
- What happens when a submission carries a null base revision for a visit that already has revisions (a second "first revision")?
- What is the scope of the idempotency key (per worker, visit, or global), and what happens on reuse across a different visit or author?
- What error shapes do validation failures and idempotency rejections return, and how are they distinguished?
- What happens when two same-key different-payload submissions race concurrently?
- What happens when two submissions from the same base are accepted at nearly the same instant — is fork ordering deterministic?
- What ordering defines submission-history retrieval (receipt time, revision ID, lineage), and how are receipt-time ties handled?
- What happens when resolution names a revision that is not a current tip, or that is superseded between read and resolve?
- Does a resolution create a revision, mutate the selected tip, or record only side metadata?
- What happens when a competing edit bases against a tip left unselected by an earlier resolution?
- Is there a defined rejection path for an unknown base revision ID or one naming another visit?
- What happens when a payload omits a field versus sending it explicitly null — does the retained revision distinguish them?
- What happens when a submission bases against a tip that is not the coordinator-selected current state — is that a fork?

Two things need your judgment before I touch EARS:

1. **Decision doc.** The whole-visit-vs-field-aware-merge choice stays live for a cold reader — credible options, more than one criterion, and tablet-sync/review-export will be sized around it. Do you want it recorded as a full decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`, or is the Decisions & Alternatives row enough?
2. **Gap triage.** Which of the gaps above should I close in the LLD, and which should become deferred open questions (item 3 already defers base-revision validation)?

Approve the LLD as-is or send numbered edits; on approval I'll move to Phase 3 and draft the record-store EARS specs.