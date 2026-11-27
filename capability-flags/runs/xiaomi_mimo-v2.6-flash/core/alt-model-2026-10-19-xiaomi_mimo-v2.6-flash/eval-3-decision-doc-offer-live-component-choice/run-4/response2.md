**Phase 2 — record-store LLD finished around whole-visit revisions. Stop for your review.**

**1. Decision doc written** — `docs/intent/record-store/decisions/whole-visit-revisions.md`
- Context: what's at stake and why the choice lands on tablet-sync and review-export contracts.
- Decision Elements: two gates (no submitted edit discarded; combined output stays traceable) and six weighted criteria — including review volume marked as cutting *against* the chosen option, plus recovery-when-wrong as the criterion that decides it.
- Both options described as their advocates would, with a concrete demonstration (two workers editing from revision 7).
- Selection names the tenets it turns on, **what we'd still consider the other approach** (revisit if the queue outgrows two coordinators before Friday, or once merge rules for observer lists and species entries could be trusted and maintained by this team), and **what tablet and export work must accommodate**: tablet-sync retains base revision IDs per draft, sends complete payloads under idempotency keys, sizes storage for whole-record drafts, surfaces pending competing revisions; review-export builds whole-record comparison, gates the CSV on the unresolved-work indicator, carries resolution provenance.

**2. LLD revised** — `docs/intent/record-store/record-store-design.md`
- "Open Design Choice" replaced by a **Revision Model**: submission with no base creates the visit; base == current extends it; any other held base becomes a competing revision and the visit goes unresolved with the current revision unchanged; unknown base rejected.
- **Resolution**: coordinator submits a complete payload naming the submissions it settles; records coordinator identity and contributors; may settle a subset; settled submissions stay intact in history.
- Retrieval: current payload + revision ID + unresolved indicator; history returns author, receipt time, base, resulting revision, disposition.
- Decisions & Alternatives row linking the decision doc; Deferred entry on history retention; Downstream Obligations section (tablet-sync, review-export) so the sibling cascade is visible when we build those nodes.

**3. LLD-level edge-case probe** (delegated, blind to this conversation; probed hardest at the Revision Model bullets and Resolution section):

*Creation & acceptance*
1. No-base submission for an already-existing visit — rejected as unknown base, or a distinct outcome?
2. Two racing no-base submissions for the same new visit UUID — can both create the first revision, and what does the loser get?
3. Base == current while the visit is unresolved — does the standing current advance with competitors still pending (A), or is it blocked until resolution (B)?
4. Is the check-and-promote on base == current atomic, so two submissions sharing a base can't both become current?
5. Are concurrent in-flight requests with the same idempotency key serialized, and what does the second return?

*Rejections and error shapes*
6. What does an unknown-base rejection return — bare rejection, current revision ID for re-basing, held revision IDs?
7. What does validation failure return, and is it distinguishable from unknown-base and idempotency-mismatch rejections?
8. What do both retrievals return for a visit UUID never seen?
9. Does "returns the original acceptance result" mean revision ID + disposition, or bare acknowledgement?
10. Does "accepted" mean stored (A) or became current (B)? (affects "original acceptance result" and the no-discard invariant)

*Idempotency identity*
11. Uniqueness scope for keys — per worker, per visit, store-wide — and cross-scope collision behavior?
12. "Identical payload": byte-for-byte or field-wise? Does payload include the base revision (A) or only scientific fields (B)?
13. Does a rejected attempt (e.g. unknown base) reserve its key, so a corrected retry trips "reuse with a different payload" (A), or is the key unconsumed (B)?

*Disposition and history*
14. A submission that was current and then fast-forwarded past: none of current/competing/settled fits — what's its disposition?
15. Does history include payloads (A), or is there a separate undefined way to read competing payloads (B) that comparison needs?
16. Do resolutions appear as history entries, and with what disposition/base/resulting revision?
17. In what order is history returned; how are equal receipt times broken?
18. "Settled submissions remain in history unchanged": payload bytes only, disposition changes (A), or nothing changes (B, contradicting the disposition list)?
19. Does a competing submission merely contest a revision, or also produce its own revision ID — are submission and revision one object or two?

*Resolution*
20. What base does a resolution record, and what if the current revision moved between the coordinator's read and arrival — applied anyway (A), rejected (B), unaddressed?
21. Two concurrent resolutions for one visit — both apply in turn, second applies against superseded state, or one rejected?
22. Resolution on a visit that isn't unresolved, naming zero submissions, already-settled submissions, or another visit's IDs?
23. Are "settled" and "contributing" the same set, or can a resolution contribute payload from submissions it doesn't settle?
24. Does adopting a competing record create a new current revision copying it (A), or promote that submission's own revision to current (B)?
25. Which retrieval returns settlement provenance (who settled which submissions, when) — neither endpoint exposes it today?

*Invariants*
26. "No accepted submission is discarded…" — absolute (A), or does the Deferred retention/compaction entry carve an exception (B)?
27. Is a resolution a submission for idempotency purposes (A) or a separate operation with no key (B)?

Which gaps do you want fixed in the LLD now, and which should I record as deferred open questions? Also flag any reading (A/B) you want settled differently than I'd default. Once you triage, I'll revise the LLD and move to Phase 3 (EARS specs for the new contract).