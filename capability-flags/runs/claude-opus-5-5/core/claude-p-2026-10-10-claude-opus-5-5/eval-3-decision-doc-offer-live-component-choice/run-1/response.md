I've rewritten the record-store design around whole-visit revisions, and it's ready for your review before I touch the specs. Nothing is committed, and `record-store-specs.md` is unchanged until you approve the design.

## What the design now says

Full text is in `docs/intent/record-store/record-store-design.md`.

- **Revision:** every accepted submission is a complete visit with a tablet-generated revision ID, which doubles as the idempotency key. It names the base revision the worker started from; a visit's first revision has none.
- **Visit state:** a visit is `current` when exactly one revision has not been superseded, and `unresolved` when two or more compete. Arrival order, author and which fields differ play no part.
- **Late edits:** an edit on an already-superseded base is accepted and competes. This means a late tablet sync can reopen a visit a coordinator already resolved.
- **Retrieval:** a current visit returns its one current revision. An unresolved visit returns all competing revisions plus their shared base, and never a provisional value, so an export has nothing to take.
- **History and queue:** history shows every revision and what superseded it, and a listing of unresolved visits feeds the review queue.
- **Resolution:** a coordinator submits a complete visit naming every competing revision. If another edit arrived in the meantime, it is rejected as `stale_resolution` and the coordinator is shown the new set.
- **Rejections:** a submission is rejected only for authentication, an invalid payload, an unknown base, a base from another visit, or a reused revision ID with different content. It is never rejected for being late.
- **Decisions table:** it records your choice and reason (a bigger review queue over merge rules that can combine related edits unnoticed), with field-aware merge as the rejected alternative.

I also removed the "concurrency choice open" wording from `docs/high-level-design.md`, in the architecture table and the paragraph beneath it.

## Choices I made that are yours to confirm

1. **Coordinator-composed resolutions.** I let a coordinator either pick one competing revision unchanged or type a visit that draws on several. The alternative is pick-one-only, with any further correction made as an ordinary edit afterwards. I leaned towards composing because the existing spec REC-006 speaks of "contributing submission IDs", plural.
2. **Identical competing payloads still go to review.** Two workers who make the same correction after comparing notes produce an unresolved visit. Settling these automatically would discard nothing and shrink the queue, but it is a small merge rule; I kept the rule uniform.
3. **Resolutions must cover every competing revision.** There is no resolving two of three.

## Gaps from a cold-read probe

A subagent given only the HLD and this design raised these. Tell me which to fix in the design and which to defer.

**Need your call**

4. **Shared tablets:** worker A edits offline and worker B is signed in when it syncs. The design takes the author from the session, which would credit B.
5. **Broken offline chain:** if the first of three chained edits is rejected as invalid, the later two can never be accepted, because their base is unknown.
6. **Reopened after export:** a visit resolved Thursday and exported Friday can be reopened by a Saturday sync. Nothing distinguishes it from a never-resolved visit or says what its value is meanwhile.
7. **Editing an unresolved visit:** the design doesn't say whether a worker may do this, or which competing revision their edit is based on.
8. **Plot and date:** it is unstated whether an edit may move a visit to a different plot, and whether two visit IDs for the same plot and date are allowed.
9. **Coordinator starvation:** a tablet draining a chain of edits can make each resolution attempt stale as Friday approaches, with no recourse described.

**Mechanical — I'd fix these as recommended unless you object**

10. **Second "first" revision:** a base-less submission for a visit that already exists competes with the existing revisions.
11. **Identical retry:** "identical" means the same field values, not the same bytes. I still need to know from you whether species-list order counts.
12. **Rejection precedence and concurrency:** state an order when several rejection reasons apply, and apply resolutions one at a time alongside submissions.
13. **Shared base:** define it by graph distance, not receipt time.
14. **History:** list every revision that superseded a given one, not just one.
15. **Queue age:** report when the visit became unresolved, not the age of its oldest competing revision.

## Three more things

16. **Decision doc.** The revisions-versus-merge choice will keep getting questioned: both options are credible, and two more designs are about to be sized around it. Do you want a standalone decision doc in `docs/intent/record-store/decisions/`, or is the Decisions table row enough?
17. **Where the vocabulary lives.** Tablet-sync and review-export will both use "revision", "base revision", "competing" and "unresolved". I defined them in record-store because the HLD says the mechanism belongs there. The alternative is a short vocabulary section in the HLD.
18. **Stale sentence in site-catalog.** Its design still says tablet-sync's behaviour "remains pending" the concurrency choice. That is another node's document, so I left it; say the word and I'll remove the sentence.

Once the design is approved I'll revise the specs: REC-004 and REC-005 still speak of an unnamed "concurrency policy" and "review work", and the base, competing, retrieval and resolution rules need new lines.