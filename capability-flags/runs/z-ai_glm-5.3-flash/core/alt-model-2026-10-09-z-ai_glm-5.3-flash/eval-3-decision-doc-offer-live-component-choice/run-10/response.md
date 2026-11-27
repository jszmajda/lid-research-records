I've finished the record-store LLD around whole-visit revisions. Here's the Phase 2 output for your review.

**What the design now says** (docs/intent/record-store/record-store-design.md):

- **Append-only revision log per visit.** Every accepted submission is an immutable revision: full visit payload, author, client-declared base revision ID, server-assigned revision ID, receipt time, state.
- **Acceptance rule:** a revision based on the visit's *current* revision becomes current immediately; a revision based on an *older* one is stored in full as a competing revision and the visit becomes `unresolved`. Nothing is ever blocked, merged, or discarded at acceptance.
- **Resolution:** a coordinator selects one competing revision; it becomes current, the others become `superseded` (still retrievable forever). Combining edits from two revisions happens by a worker re-submitting against the resolved base — this node only guarantees full payloads stay retrievable. No automatic combination, per your choice.
- **Retrieval** distinguishes `current` from `unresolved`, exposes competing revision IDs, and serves full revision history for comparison and re-editing.
- Only `current`-state visits are export-eligible — the hook review-export will size against.
- The field-aware merge option is recorded as rejected in the body and in a new Decisions & Alternatives table (with the rationale in your words). Deferred questions: revision ID format, whether a superseded revision can serve as a new base, superseded-revision retention.

**Decision doc offer.** This choice will stay live for a cold reader — two credible options traded on more than one criterion, and tablet-sync and review-export are about to size themselves around it. I've recorded it as a Decisions table row (the default). Want me to also write a full decision doc (`docs/intent/record-store/decisions/`) capturing the competing options and criteria, or is the row enough?

**LLD-level edge-case probe.** A blind reader of the draft raised these gaps — please tell me which to fix in the LLD now vs. defer as open questions. My suggested disposition is in brackets:

1. A revision arrives whose base revision ID doesn't exist (or is malformed/absent) — conflict rule, validation failure, or something else? [fix: treat as validation rejection, don't classify as a conflict]
2. During resolution, what happens to revisions queued *based on a competing* revision — do they ever keep the visit `unresolved` after it? [fix: after resolution they are stored for reference only and do not block `current`]
3. Can resolution race with an arriving same-base submission? [fix: yes — such a revision becomes a competing revision again and re-opens `unresolved`]
4. A same-base revision arrives while an earlier conflict already exists — auto-resolve or undefined? [fix: rule 1 must not fire while unresolved; it joins the competing set]
5. May a superseded revision serve as a base for a new submission? [defer — pairs with the deferred undo question, but a lean yes keeps workers unblocked]
6. What counts as an "identical payload" for idempotency — byte-equal or normalized? And what does a retry return if the original is now superseded? [fix: field-normalized equality; retry returns the original acceptance result regardless of later state]
7. Rejection error shape (auth vs validation vs idempotency-mismatch vs unknown plot) is unstated, and tablet-sync must explain each to field workers. [fix: enumerate the four rejection reasons in the contract]
8. Idempotency key scope — per worker? per visit? What if a different worker reuses a key? [fix: scope to visit + worker; foreign reuse is rejected]
9. What does current-state retrieval return right after resolution — presumably the newly selected revision, stated as such. [fix: one sentence]
10. Does revision history have an ordering guarantee? [fix: receipt time, tie-broken by revision ID]
11. Can a submission carry another visit's base revision ID? [fix: validation rejects it]
12. Atomicity between resolution and an in-flight export read. [defer — an eligibility rule concern that review-export will lean on; state the guarantee here only]

Once you tell me which gaps to land (or say "take all your suggested dispositions"), I'll revise the LLD, and after your Phase 2 approval move to Phase 3 — updating the EARS specs (REC-001…006 mostly stand; the lifecycle rules will need new atomic specs) with a consistency report.