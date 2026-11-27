I've completed the record-store design around whole-visit revisions and updated the HLD status (the concurrency-choice-open note is gone). Here's the design for your review before I draft the EARS specs.

**Submission envelope** — visit UUID, idempotency key, base revision ID (absent for a visit's first submission), author ID, and the complete visit payload. The server assigns revision IDs; clients never invent one.

**Revision lifecycle** — first submission creates revision 1. A submission whose base revision ID matches the current revision applies cleanly and advances the chain. A stale-base submission is retained as a competing revision and puts the visit into an *unresolved* state — the previously current revision stays current, the competitor waits for review, and multiple competitors can pile up. A base revision ID naming no revision of that visit is rejected as invalid, not treated as stale.

**Resolution** — a coordinator either accepts a competing revision as-is or records a corrected payload. The outcome becomes a new revision; resolved competitors are marked resolved and retained, never deleted, so the path from any submission to an exported value stays inspectable.

**Current-state retrieval** — carries the current payload and revision ID, an unresolved flag, and the list of competing revisions with author, receipt time, and base revision ID. Competitors are never served as current state.

**LLD-level edge-case probe** — gaps I found in my own design; tell me which to fix in the LLD now vs. defer:
1. Two competing revisions arrive whose payloads are *identical* to the current revision (a worker re-submits the same data). Auto-resolve, or still queue coordinator review? (Currently deferred in Open Questions.)
2. May a coordinator resolve while further stale-base submissions are still arriving, or must the visit be quiet first? (Currently deferred.)
3. Should the envelope carry a client timestamp or device ID alongside server receipt time? The current design keeps only server receipt time.
4. Does resolution itself need an idempotency key (I've assumed yes, by resolution ID), or can resolution fail-and-retry be considered rare enough to skip?

**Recording the choice** — whole-visit-revisions vs. three-way-merge was a genuine trade (review volume vs. merge-maintenance risk), and tablet-sync and review-export will both be sized around the result. I've recorded it as a Decisions row; this also seems worth a full decision doc under `docs/intent/record-store/decisions/` so the trade stays re-litigable. Want the decision doc, or is the row enough?

Once you approve the design (and settle the probe items), I'll draft the EARS specs as the next phase.