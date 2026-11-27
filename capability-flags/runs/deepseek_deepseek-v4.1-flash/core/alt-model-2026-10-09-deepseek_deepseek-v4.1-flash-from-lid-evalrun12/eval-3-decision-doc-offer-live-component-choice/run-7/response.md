**Coherence pre-flight.** Record-store's specs still trace to the current LLD (`REC-004`–`REC-006` describe preservation, unresolved-state indication, and resolution provenance), the site-catalog contract is independent of this choice, and the HLD correctly delegates the mechanism to record-store. No drift found. Selecting the policy is an LLD-level choice, so we resume at Phase 2; I've drafted the finished LLD.

**— Phase 2 stop: record-store LLD —**

I replaced `docs/intent/record-store/record-store-design.md` with the following:

---

# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

The store retains every accepted submission and derives, from the revision relationship each submission declares, whether a visit has a single current state or unresolved competing states. Tablet-sync and review-export consume the contract defined here; neither invents concurrency semantics of its own.

## Architecture

The record store exposes authenticated operations for submitting a visit edit, retrieving a visit's current state, retrieving a visit's submission history, listing unresolved review work, and resolving review work. Persistence retains original submissions, their authors, server receipt times, the revision relationships between them, and resolution records.

A **submission** is one authenticated, validated edit: the complete visit payload plus submission metadata. Every accepted submission produces exactly one **revision** — the complete visit state that submission carries. A revision's identifier is the identifier of the submission that created it, so a revision ID and its origin submission ID are the same value.

A visit's scientific fields are observation date, observer list, species cover estimates, and notes, plus its catalog plot reference. A submission always carries all of these fields: under whole-visit revisions there is no partial-field edit, and the store never compares field values to decide whether two submissions conflict.

## Revision Model

Each visit has a revision tree. A revision's parent is its **base revision** — the revision the submitting worker started from. The first submission of a visit names no base; every later submission names one.

- A revision with no child is a **tip**.
- A tip not set aside by a resolution is an **open tip**.
- A visit is **resolved** when it has exactly one open tip; that tip is the **current revision**.
- A visit is **unresolved** when it has two or more open tips; those tips are the **competing revisions**.

Because each submission is a complete visit, the store does not inspect payload fields to detect conflict. Any submission whose base is not the current revision adds an open tip and therefore creates review work, even when the two edits touch unrelated fields.

| Existing visit state | Submission's base revision | Result |
|---|---|---|
| No revision yet | none | Creates the root revision; visit resolved |
| Resolved, current revision C | C | Appends a child of C; visit stays resolved |
| Resolved, current revision C | Any ancestor of C other than C | Adds a second open tip; visit becomes unresolved |
| Unresolved, open tips T | One of T | Extends that branch; visit stays unresolved |
| Any | A revision ID not belonging to this visit | Submission rejected |

## Submission Contract

A submission carries the visit ID, the base revision ID (absent for a visit's first submission), the complete visit payload, and a client idempotency key. The submitting worker's identity comes from authentication.

Before acceptance the store validates that the worker is authenticated, that payload field types are well formed, and that the plot reference resolves in the catalog. The base revision ID, when present, must be a revision of the same visit.

Acceptance behavior:

- A valid first submission or a valid descendant of the current revision is stored and its revision becomes the current or an additional open tip.
- A retry that repeats an accepted idempotency key with an identical payload returns the original acceptance result and creates no new submission.
- A retry that repeats an accepted idempotency key with a different payload is rejected and leaves the original submission unchanged.

The response reports the submission ID (and therefore the revision ID), the resulting resolution state of the visit, and the server receipt time. The base check and the resulting tree update happen atomically per visit, so two simultaneous submissions naming the same base cannot both extend a single open tip.

## Retrieval

Current-state retrieval returns the visit ID and a resolution state:

- **resolved** — the current revision: its revision ID, payload, author, and receipt time.
- **unresolved** — the competing revisions, each with its revision ID, payload, author, and receipt time, so a coordinator can compare them and a tablet can show that the visit is pending.

Submission-history retrieval returns every revision of the visit in receipt order with its base revision link, together with every resolution record, giving an inspectable path from any submitted observation to the resolution that made state current.

## Resolution

A coordinator resolves an unresolved visit by selecting one of its open tips. The resolution operation carries the visit ID, the selected revision ID, and a client idempotency key; the coordinator's identity comes from authentication, and the store accepts the operation only from an identity holding the coordinator role.

The selected revision must be an open tip of the visit at the time of resolution. The store then:

- records a resolution outcome holding the coordinator's identity, the selected revision, the server resolution time, and the IDs of the competing submissions it set aside;
- marks every other open tip as superseded by that resolution;
- makes the selected revision the current revision.

The resolution response reports the resolution ID, the current revision ID, and a resolved state. Every submission remains stored. A later submission based on a superseded revision creates a new open tip and returns the visit to unresolved.

A resolution repeats idempotently under the same key; a resolution naming a revision that is no longer an open tip, or targeting a visit that is already resolved, is rejected as a conflict.

## Downstream Contract Notes

This node exposes the resolution state and the competing-revision set as the boundary other nodes consume. Review-export excludes a visit from its export set while the visit is unresolved. Tablet-sync tracks the revision ID it last received as the base revision for its next submission. Both link back to this node rather than defining their own concurrency semantics.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrency policy for concurrent visit edits | Whole-visit revisions: each edit names its base revision, and independently based edits become competing complete revisions for a coordinator to resolve | Field-aware three-way merge (auto-combine disjoint field edits) | Preserves each submitted visit as a unit and needs no maintained field-merge rules, which could combine scientifically related edits without noticing. Accepted cost: edits to unrelated fields also create review work, so the coordinator queue is larger. |
| Revision identity | A revision is identified by its origin submission's ID | A separate server-generated revision ID decoupled from the submission ID | One identity avoids a second identifier that could drift; whole-visit submissions map one-to-one onto revisions. |
| Current-state representation | The current revision is the visit's unique open tip; unresolved visits expose their competing revisions | A synthetic merge revision assembled from competing branches | Never fabricates a visit state no worker submitted, keeping whole-visit intent intact. |
| Resolution mechanism | Adopt one competing revision as current; retain the others as superseded | Coordinator composes a new merged revision | Composing content reintroduces exactly the field-merge logic the whole-visit policy rejects. |
| Superseded revisions | Retained in history, never deleted | Delete or compact non-selected revisions on resolution | Keeps every submitted edit inspectable, per the HLD tenet against silently discarding a submission. |

## Open Questions & Future Decisions

### Resolved

1. ✅ Whether concurrent visit edits use whole-visit revisions or field-aware merge — whole-visit revisions (see Decisions).

### Deferred

1. Persistence-level concurrency control (per-visit lock versus optimistic version check) — an implementation choice.
2. Retention and pruning of superseded revisions and payload storage across a season (~6,000 visits/season).
3. Coordinator role source in the team's identity provider.
4. How tablet-sync renders an unresolved visit (competing set versus last resolved ancestor) — owned by tablet-sync.
5. Whether a base-less submission to a visit that already has revisions is rejected or treated as a branch from the root.

## References

- `docs/high-level-design.md`
- `docs/intent/site-catalog/site-catalog-design.md`
- `docs/intent/record-store/record-store-specs.md`

---

**Edge-case probe (delegated, internal to this LLD).** Gaps surfaced — triage which to fix here vs. defer:

1. Is resolution atomic per visit like the submission base-check, or can a tip created mid-resolution escape being set aside?
2. Two simultaneous base-less submissions for the same brand-new visit — who becomes root, and what happens to the loser?
3. Two submissions name the same current revision; only one can extend it. Is the loser rejected, or turned into a second competing open tip? (The result table associates "append" with the base, not with losing a race.)
4. A submission whose base is a *superseded sibling tip* (not an ancestor of the current revision) hits no row of the result table, though the prose says it returns the visit to unresolved.
5. Idempotency-key scope — per visit, per worker, or global? Does the same key on a different visit collide?
6. Resolution retry with the same key but a different selected revision — the mismatched-argument rule is unstated (the submission contract defines only the payload case).
7. What "identical payload" means for idempotency (observer-list order, cover formatting).
8. Error/rejection response shapes, and retrieval of an unknown or absent visit.
9. Ordering of competing revisions and the receipt-time tie-break.

**One decision offer.** The whole-visit-vs-merge choice is a live one a cold reader could re-litigate, and tablet-sync and review-export are about to be sized around it. Want me to record it as a full decision doc under `docs/intent/record-store/decisions/`, or leave it as the Decisions row above?

On your approval I'll (a) apply the triaged gap fixes, (b) update the stale HLD node state from "Drafted; concurrency choice open" to "Drafted", and (c) move to Phase 3 to update the record-store EARS specs. Reply with numbered feedback or "approved".