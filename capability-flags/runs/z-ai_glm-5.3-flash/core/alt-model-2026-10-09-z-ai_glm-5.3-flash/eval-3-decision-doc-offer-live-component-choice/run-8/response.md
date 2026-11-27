The record-store design is now finished around your whole-visit revisions choice — here's the Phase 2 stop for your review.

**What changed**
- `docs/intent/record-store/record-store-design.md` — rewritten: an immutable **revision model** (each submission carries a base revision ID; complete payload; idempotency key), current-state semantics (**linear** tree → chain tip is the current record; any same-base fork → **unresolved**, no current record, arrival order never breaks a tie), coordinator **resolution** (select a competing revision, or record a reconciled revision based at the fork point; losers retained permanently in history), submissions against non-tip bases are **accepted** and surface as new competing work rather than rejected, a four-operation interface table (submit / get state / list revisions / resolve), a filled Decisions & Alternatives table, and cascade notes for tablet-sync and review-export.
- `docs/high-level-design.md` — removed the now-stale "concurrency choice open" wording and the paragraph making tablet-sync/review-export wait on it; the record-store row now points at the settled contract.

**Design decisions to check** (full rationale is in the LLD's table): (1) the server never auto-merges anything — even disjoint-field edits go to review, since a weaker version of the merge mechanism you declined would reintroduce the risk it was declined for; (2) chain status is derived at read time, not stored, so resolutions never rewrite history; (3) late submissions against superseded bases are accepted and become new review work, not server rejections — workers may be offline 48 hours and can't rebase interactively.

**Edge-case probe — please triage.** The fresh-reader probe found these gaps; tell me which to fix in the LLD now and which to defer as open questions:

1. After a resolution, a new submission names a base on the *losing* chain — does the visit re-enter unresolved, and can a losing revision ever be re-selected?
2. Is a coordinator's reconciled revision an ordinary chain tip that can itself be branched by two later workers, or something special?
3. A submission names a base revision ID that doesn't exist or belongs to a different visit — reject, or define the error?
4. Idempotency-key replay after the original revision went off-chain — return the stale revision, or re-evaluate?
5. No error taxonomy for failed validation, and unclear whether a failed validation consumes the idempotency key.
6. A third revision arrives on an already-branched base, or a visit has multiple branched bases — does the unresolved marker show one list or per-base groups?
7. A base is both on the winning chain *and* multi-child — the two rules ("branched" vs "off-chain") overlap; precedence is unstated.
8. The three chain-status values don't distinguish a formerly-winning revision that lost a later resolution from one never on a winning chain.
9. Resolve operation has no validation: wrong visit's revision, already-resolved selection, selecting *and* supplying a reconciled payload together.
10. Two initial submissions (base `null`) for the same visit UUID — the root's implicit pseudo-base makes this a fork the branching rule doesn't literally cover.

My suggestion: 1–3 and 9–10 are structural (fix now); 4–8 can be fixed cheaply alongside since they're one-liners, but I'll follow your triage.

**One more thing — decision doc.** The whole-visit-revisions choice stays live for a cold reader: two credible options weighed on review volume vs. merge-rule burden vs. scientific-unit preservation, and both downstream nodes will size their designs around it. Want me to write it up as `docs/intent/record-store/decisions/concurrent-edit-policy.md` (the Decisions row already links there), or keep it as just the table row?