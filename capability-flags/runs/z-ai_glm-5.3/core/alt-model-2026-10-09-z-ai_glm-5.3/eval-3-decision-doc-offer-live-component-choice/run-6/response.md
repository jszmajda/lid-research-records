All Phase 2 work is done. Here is the stop for review.

---

**Phase 2 (LLD) stop — record-store design completed around whole-visit revisions.**

What changed:
- `docs/intent/record-store/record-store-design.md` — rewritten as a complete design (full text below). The open-choice section is replaced by the revision model, envelope, states, and resolution contract; the two options are recorded in Decisions & Alternatives.
- `docs/high-level-design.md` — record-store's State row now reads "Drafted", and the "unresolved choice" paragraph now says the two downstream designs build on record-store's contract. Both were stale the moment you selected; veto either edit if you disagree.

The completed design:

> ```
> # Record Store
>
> ## Context
> This node owns visit persistence and the meaning of a current visit when
> independently edited copies arrive. A visit is identified by a client-generated
> UUID and refers to a catalog plot ID. Updates can arrive days after their
> starting state was fetched. The server must not treat arrival order as evidence
> that one worker's observations are more authoritative.
>
> Some concurrent edits touch unrelated fields, such as correcting an observer
> name and adding a missing species. Others are scientifically related, such as
> revising a species identification and the cover estimate taken under the old
> identification. The server cannot infer these relationships from field names,
> so it never combines concurrent edits on its own: every competing edit
> reaches a coordinator.
>
> Tablet-sync and review-export are not yet designed. Both build on the
> submission envelope, visit states, and review operations defined here.
>
> ## Architecture
> The store uses whole-visit revisions: an edit submits a complete visit, and
> concurrent edits become competing revisions that a coordinator resolves. The
> current record is always identical to one submitter's complete payload.
>
> Operations:
> | Submit visit | Worker or coordinator | Accept a complete visit submission |
> | Retrieve current state | Any authenticated caller | Current revision and review state for one visit, or all visits of a plot |
> | Retrieve submission history | Any authenticated caller | Every retained submission for one visit |
> | List unresolved visits | Any authenticated caller | Visits with an open review |
> | Retrieve review detail | Any authenticated caller | Full payloads of one open review's competing revisions |
> | Resolve review | Coordinator | Select the revision that becomes current |
>
> Persistence retains every accepted submission — payload, author, server
> receipt time, idempotency key, base revision — separately from any resolution
> outcome. Revisions are server-assigned numbers in one sequence per visit; a
> competing revision receives a revision number only if a coordinator selects it.
>
> ## Submission Envelope and Acceptance
> A submission carries: visit UUID; plot UUID (must resolve in the site catalog);
> base revision (the revision the edit started from; omitted by the creating
> submission); complete scientific payload (observation date, observer list,
> species cover estimates, notes; always the whole visit, never field deltas);
> idempotency key. The author comes from authentication, not the payload.
>
> Acceptance proceeds in order:
> 1. Authenticate; validate field types and the plot reference. A base revision
>    that does not name a revision of the visit is rejected; rejected submissions
>    are not retained.
> 2. Idempotency: same key + identical payload returns the original acceptance
>    result; same key + different payload is rejected.
> 3. Visit does not exist: created; submission becomes revision 1.
> 4. Visit resolved: base == current → accepted as the next revision; earlier
>    or absent base → retained as a competing revision; visit becomes unresolved.
> 5. Visit unresolved: retained as a competing revision in the open review,
>    whatever its base revision.
>
> Invariant: the current revision advances only through rule-4 acceptance on a
> resolved visit or through resolution — never while a review is open.
>
> ## Visit States and Current Record
> A visit is unresolved while an open review holds competing revisions, resolved
> otherwise; a visit that has never conflicted is resolved. The current revision
> is the authoritative complete state — revision 1 at creation, advanced by
> rule-4 acceptance or resolution. While unresolved, the current revision is
> still retrievable (it is what the coordinator keeps by selecting `current`);
> the unresolved state is what review-export uses to hold a visit out of the
> CSV — eligibility itself is that node's rule.
>
> ## Review and Resolution
> One open review per visit. Resolution carries the visit UUID, the competing
> submission IDs the coordinator reviewed, and the selection (`current` or a
> competing submission ID). If the carried set doesn't match the open review's
> current set, the resolution is rejected and the coordinator reloads — a
> resolution cannot ride past an unseen competing revision, mirroring the
> base-revision discipline tablets use. The selected competing revision becomes
> the next revision; the outcome retains coordinator identity, time, the full
> competing set, and the selection; unselected submissions stay retained and
> linked. Resolution never authors content — a coordinator wanting a hybrid
> resolves, then submits their own correction through the normal path.
>
> ## Downstream Contract
> Tablet-sync: keeps each visit's current revision number as the edit base,
> sends this envelope, treats "retained as competing revision" as a visible
> outcome, not an error. Review-export: lists unresolved visits and review
> details, presents the comparison screen, holds unresolved visits out of the
> export set; it owns eligibility. Both link back to this contract.
> ```

(The full file also carries the Decisions & Alternatives table — four rows: concurrent-edit policy, queue-during-review, resolution shape, stale review protection — plus Open Questions and References.)

**Edge-case probe** (delegated to a fresh reader given only the docs). The gaps, with my suggested triage — you decide fix-vs-defer:

| # | Gap (section) | My suggestion |
|---|---|---|
| 1 | Two base==current submissions race on a resolved visit — which becomes the revision? (rule 4) | Fix: state per-visit serialization; first wins, the rest become competing |
| 2 | Submission vs. resolve race — which wins? (Acceptance/Resolution) | Fix: same serialization point resolves it |
| 3 | Two creating submissions, same visit UUID (rules 3–4) | Fix: one becomes revision 1, the other a competing revision |
| 4 | Revision numbering after resolution — selection order vs. receipt order (Architecture) | Fix: numbers follow acceptance/selection order, one sentence |
| 5 | Idempotency key scope — per visit, per author, or global? (rule 2) | Fix: globally unique (client-generated) |
| 6 | "Identical payload" definition; is a rule-2 rejection retained? (rules 1–2) | Fix lightly: not retained, consistent with rule 1; equality detail → implementation |
| 7 | Retry of an unselected competing submission after its review closed (rule 2) | Fix: idempotency check precedes review-state logic, returns original result |
| 8 | Duplicate-content competing submission admitted or deduplicated? (rule 5) | Defer: admitted as distinct; dedup is an optimization |
| 9 | Resolve selecting an ID not in the carried set (Resolution) | Fix: rejected as invalid |
| 10 | Can a review close without a selection, or does it block until resolved? (Resolution/Invariant) | Fix: no abandon path — confirm you're comfortable with reviews being resolutely resolvable |
| 11 | Rule-1 rejection retried with the same key — idempotency interplay (rules 1–2) | Fix lightly: deterministic re-rejection, no retention |
| 12 | Listing ordering/completeness guarantees (Operations) | Defer: implementation detail |

**Two judgment calls to eyeball** (both recorded in the Decisions table): (a) submissions arriving during an open review join the queue rather than fast-forwarding — this fixes the comparison set but means even a trivial typo fix waits for resolution; (b) resolution can't compose hybrid records — coordinators resolve, then submit their own correction.

**Decision doc?** The concurrency choice will read as a live trade to a cold reader — every unrelated concurrent edit generating review work looks reversible unless you know the auto-merge risk — and two nodes are about to be sized around it. I've recorded the Decisions & Alternatives row; want a full decision doc in `docs/intent/record-store/decisions/`, or is the row enough?

**Cross-segment note:** site-catalog's design says tablet-sync's behavior "remains pending that choice" — now stale. It's a different segment, so asking before touching: may I apply the one-line touch-up there?

On your approval (and gap triage), Phase 3: REC-001–006 stand as-is; new specs for revision acceptance, competing-revision retention, review joining, resolution semantics, stale-set rejection, and state exposure.