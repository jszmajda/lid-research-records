**Phase 2 stop — record-store LLD completed around whole-visit revisions.** Also touched up the HLD (record-store row now reads "Designed — whole-visit revisions"; the Architecture paragraph names the mechanism instead of calling it open). EARS specs are untouched — Phase 3 updates them once you approve this design.

The completed LLD (`docs/intent/record-store/record-store-design.md`):

---

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

Concurrency is resolved by whole-visit revisions: every accepted submission is stored as a complete revision, and competing revisions are settled by a coordinator rather than by merge logic. Tablet-sync and review-export are not yet designed; their contracts depend on this node's submission envelope and unresolved-work representation.

## Revision Model

A visit is an append-only sequence of immutable revisions. Each revision holds the complete visit payload as submitted — observation date, observer list, species cover estimates, notes, and the plot UUID — never a field-level patch. Every revision records:

- a server-assigned revision ID
- the visit ID
- the base revision ID the author started from (null for a visit's first submission)
- the author ID
- the server receipt time

A visit carries a current-revision pointer. A submission whose base revision ID matches the visit's current revision becomes the new current revision, and the visit has no unresolved review work. A submission whose base revision ID does not match the current revision is stored as a competing revision: it is preserved in full, does not advance the pointer, and marks the visit as having unresolved review work.

[mermaid flowchart: submission → visit exists? → base = current? → new current or competing; unresolved visits route all submissions to the competing set; coordinator selects from unsettled set]

While a visit is unresolved, further submissions are accepted and join the competing set without advancing the pointer; a first submission (null base) creates the visit as its first revision, current and without unresolved work. Revisions are never edited or deleted — superseded revisions remain retrievable, and original submissions outlive every resolution.

## Submission Envelope

| Field | Meaning |
|---|---|
| visit_id | Client-generated UUID of the visit being edited |
| base_revision_id | Revision the author started from; null only when creating a visit |
| payload | Complete visit record: plot UUID, observation date, observer list, species cover estimates, notes |
| idempotency_key | Client-generated key, unique per submitting worker |

Authentication supplies the author; the server assigns the revision ID and receipt time. The server validates field types and that the plot UUID resolves in the site catalog before accepting a submission. A base revision ID that is neither null nor an existing revision of that visit is rejected — creating a visit requires a null base. There is no partial-update form; every submission is a whole visit.

A retry with the same idempotency key and an identical payload returns the original acceptance result without storing another revision. Reuse of an accepted key with a different payload is rejected and leaves the stored revision unchanged. Idempotency keys are scoped per submitting worker.

## Retrieval

Current-state retrieval returns the current revision — full payload, revision ID, and metadata — and an indicator of whether unresolved review work exists for the visit. The current revision ID is the base a worker's next edit starts from. While a visit is unresolved, the current pointer remains at the last non-superseded revision, so retrieval always yields a concrete revision to display and to use as a base.

Submission-history retrieval returns the visit's revisions in receipt order, each with its base revision ID and author. While unresolved, the unsettled set — the revisions a coordinator may select from — is the current revision plus every competing revision accepted since the last resolution.

## Resolution

A coordinator resolves unresolved work by selecting one revision from the unsettled set — the current revision or any competing revision — as the visit's new current revision. The resolution records the coordinator's identity, the selected revision ID, and the contributing submission IDs: every revision the resolution settles. Resolution requires the visit to still be unresolved; a resolution aimed at an already-resolved visit is rejected. After resolution the visit has no unresolved review work, and subsequent submissions base on the newly current revision. Superseded revisions remain in history.

A coordinator cannot author a composite revision through this operation — resolution selects among submitted revisions only.

## Downstream Contract Work

Tablet-sync retains the base revision ID on each local draft, uses the current revision ID from retrieval as that base, and surfaces to the worker when a submission has become a competing revision pending review. Its local storage and retry state machine size around the submission envelope above.

Review-export includes only the current revision of visits with no unresolved review work in the partner's CSV, and holds unresolved visits out until a coordinator resolves them. It sizes its coordinator interface — including whatever revision comparison it presents — around the history and resolution operations above.

Neither sibling defines its own concurrency semantics; both link back to this node.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrency policy for independently edited visits | Whole-visit revisions with coordinator resolution of competing submissions | Field-aware three-way merge; arrival-order winner | Arrival-order winner silently discards a submitted edit. Field-aware merge reduces review volume but needs maintained rules for scalar fields, observer lists, and species entries, and those rules can combine scientifically related edits — a revised identification with its cover estimate — without noticing. A review queue two coordinators can work is accepted over that risk. |
| Submissions while a visit is unresolved | Accept and add to the competing set; never advance the current pointer | Block submissions until resolution | Offline tablets cannot be forced to hold retries until a coordinator is available; blocking would either discard worker input or wedge the sync queue. Accumulation grows the review set, which the team accepts. |
| Coordinator resolution | Select an existing revision from the unsettled set as current | Coordinator-authored composite revision; field-level merge on the server | Selection keeps the first release free of merge tooling and keeps every exported value traceable to a worker's submitted visit. A composite form can be added later if coordinators regularly find no submitted revision acceptable. |
| Revision storage | Append-only immutable revisions with a current pointer | Mutable visit row overwritten on accept; field-level patch log | The HLD requires that no submitted edit be silently discarded and that the path from submission to export stay inspectable; an append-only history is the audit trail review and export rely on. |

## Open Questions & Future Decisions

### Resolved
1. ✅ Concurrency policy: whole-visit revisions with coordinator resolution (see Decisions).
2. ✅ While unresolved, further submissions accumulate as competing revisions rather than being blocked.
3. ✅ Resolution selects among the unsettled set only; it cannot resurrect a superseded historical revision or author a composite.

### Deferred
1. Coordinator-authored composite resolution — add if revision comparison shows no submitted revision is acceptable with regularity.
2. Retention and purge of superseded submissions — none in the first release; revisit when volume demands it.
3. Structured export of a visit's revision history to the science partner — the partner receives current values only until requested otherwise.
```

---

**LLD-level edge-case probe — triage these before I move to Phase 3 (EARS):**

1. **Unknown visit ID with a non-null base revision ID** — draft *rejects* it (creating a visit requires a null base). Alternative: accept as a create and ignore the stale base. Reject keeps the model clean; accept is more forgiving of a tablet that lost local state. Fix in LLD, or leave as drafted?
2. **Coordinator-authored composite resolution** — draft *defers* it (resolution selects among submitted revisions only). If comparison regularly shows neither submitted visit is acceptable, coordinators will want to compose one themselves. Defer, or include now?
3. **Retention/purge of superseded submissions** — draft *defers* (retain indefinitely for the first release). Given ~6,000 visits/season, revisit later, or set a retention rule now?
4. **Resolution reason** — draft records coordinator identity, selected revision, and contributing submissions, but no free-text reason. Add one for the audit trail, or keep resolutions bare?
5. **Notifying the losing worker** — out of this node's scope; recorded as a tablet-sync obligation (tablet-sync surfaces competing-revision status; whether it later surfaces "your revision was not selected" is that node's call). Flagging so it isn't lost when we design tablet sync.

**Also flagging one cross-boundary item (not edited without your word):** `site-catalog-design.md` still says "Tablet-sync's visit submission and reconciliation behavior remains pending that choice" — that sentence is now stale. One-line fix when you approve propagation into that segment.

**Decision-doc offer:** the whole-visit-revs-vs-field-aware-merge choice is recorded as a Decisions row. Because tablet-sync and review-export will both be sized around it, a cold reader could be tempted to revisit it — want it promoted to a full decision doc at `docs/intent/record-store/decisions/`, or is the table row enough?

Approve (with any triage answers) and I'll proceed to Phase 3: rewriting the REC specs against this model — new IDs for competing-revision acceptance, pointer semantics, unresolved accumulation, and resolution rules.