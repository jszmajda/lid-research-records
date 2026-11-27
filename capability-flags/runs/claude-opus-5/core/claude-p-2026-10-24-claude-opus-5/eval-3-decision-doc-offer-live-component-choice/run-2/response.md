**Phase 2 complete — record-store LLD now specifies whole-visit revisions.** Written to `docs/intent/record-store/record-store-design.md` (the OPEN section is gone; the doc reads as a settled design).

## What the design now says

**Revision model.** A visit is an append-only set of revisions, each holding a *complete* payload plus author, server receipt time, and the revision it derives from (its base). A revision is *superseded* once another names it as base; otherwise it is *open*. One open revision = the visit's **current record**. More than one = the visit is **contested** and has no current record. Nothing is ever modified or deleted. No field comparison happens anywhere in this node — a submission naming a superseded base is accepted whole and simply becomes a second open revision.

**Submission.** Envelope is `visitId`, `baseRevisionId` (absent on first submission), `idempotencyKey`, and a complete `payload`. Author comes from the session, receipt time from the server. Validation covers field types, catalog plot resolution, and that the named base exists and belongs to that visit. Acceptance means *stored*, not *current* — the result returns the new revision ID, the visit's resulting state, and all open revision IDs, so a tablet learns immediately that it landed alongside another edit and knows what to base its next edit on.

**Retrieval.** Current record with provenance, or a contested marker listing open revisions with authors and times — and no payload under "current", since the only tiebreaker available would be arrival order. Plus full revision history, and a contested-visit listing that is the coordinator review queue.

**Resolution.** A coordinator's resolution stores *one more whole revision* naming every currently open revision as its bases — adopting one verbatim or hand-composing from several. The visit returns to a single open revision, and later tablet edits base on it like any other. If the open set changed while the coordinator was deciding, the resolution is rejected and they re-read the visit — otherwise a coordinator could close a revision nobody ever saw.

Decisions table records the rejected field-aware merge with your reasoning, plus four more: no provisional current value on a contested visit; resolution-as-revision rather than a winner-pointer; whole payloads rather than structured changes; and the staleness check on resolution.

## Edge probe — please triage

A delegated probe (given only the docs, not our conversation) found gaps inside this node. My recommendations, but these are your calls:

1. **Can a worker submit to an already-contested visit?** Two readings: contested visits freeze until resolution, or contests grow to three-plus open revisions that churn while a coordinator composes. The staleness check behaves very differently under each. *This one I think we must settle now — recommend allowing it (freezing would discard a field edit), which means accepting churn.*
2. **Atomicity of accept-and-report.** Open/contested is a derived query, and the doc states no serialization invariant — so it's unspecified whether an acceptance result can report an open set missing a revision stored microseconds earlier, and whether two coordinators resolving concurrently both succeed. *Recommend fixing in the LLD now.*
3. **Is the plot UUID editable after the first revision, and does archived status block acceptance?** It currently sits in the payload as an ordinary field. *Recommend fixing now — cheap, and it's a real invariant question.*
4. **Payload-identity rule for idempotent retries** (reordered observer lists, reordered species entries, numeric formatting) and **idempotency key scope** (global / per-visit / per-session) and retention window. *Recommend fixing now — tablet-sync's retry machine turns on it.*
5. **Rejection error shape** — no code vocabulary, no all-vs-first-failure rule, no retryable/terminal distinction. *Recommend fixing now, for the same reason.*
6. **Lesser gaps I'd defer:** history ordering over a DAG and receipt-time ties; which revision's plot/date shows in the contested listing when they differ; content-level validation (empty observer list, future dates, notes size); whether resolution itself carries an idempotency key and enforces a coordinator role; recovery path for a first-submission `visitId` collision.

## Two things for you to decide

7. **Record this as a decision doc?** The concurrency choice clears the bar I'd normally hold: two genuinely credible options traded against review workload, submission size, and scientific safety — and two sibling nodes are about to be sized around the result, so a cold reader could be tempted to reverse it. Offer is `docs/intent/record-store/decisions/concurrent-visit-edits.md`. The Decisions table row already in the LLD is the alternative, and is sufficient if you'd rather not carry the doc.

8. **Cascade into the HLD.** Two HLD passages are now stale: the record-store row's state cell ("Drafted; concurrency choice open") and the paragraph saying tablet-sync and review-export "must wait for its contract." The architecture itself is unchanged. Want me to refresh those two spots?

Phase 3 (EARS specs — the existing REC-001…006 stay, with new IDs for the revision states, the open-set contract, and resolution) waits on your ruling here.