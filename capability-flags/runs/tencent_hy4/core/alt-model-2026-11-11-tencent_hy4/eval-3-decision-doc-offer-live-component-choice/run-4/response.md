Resuming at Phase 2 (record-store LLD) with your selection: **whole-visit revisions**. Coherence pre-flight: the HLD already delegates concurrency to record-store (architecture unchanged), REC-001–006 are coherent but deliberately policy-agnostic, and there are no tests/code yet. I fixed one stale HLD marker and did **not** touch tablet-sync or review-export, and did **not** cascade to specs/tests/code — that waits on your approval at this stop.

**Phase 2 output** — finished `docs/intent/record-store/record-store-design.md` (full text is in the file; I'll paste it here in full if you'd rather review in-message):
- Removed the OPEN placeholder, the "not yet specified" notes, and the option-deliberation prose. The rejected field-aware merge now lives only in the **Decisions & Alternatives** row, with your rationale: bigger review queue over merge rules that could combine scientifically related edits unnoticed (e.g. species ID + its cover estimate, which the server can't infer from field names), aligning with *"Do not silently discard a submitted edit"* (losing revisions are retained).
- Mechanism: each edit submits a complete visit as a revision naming its **base revision**; concurrent edits — even to unrelated fields — become **competing revisions**; nothing is auto-merged or promoted; a coordinator resolves; non-selected revisions stay in history and are never export-eligible.
- Contract: revision data model, resolved/unresolved state, current-state vs. unresolved-work retrieval, review-outcome operation, and resolved-only export eligibility.
- Cascade notes (not designs) for the sibling nodes: tablet-sync retains base revision IDs and shows pending competing revisions; review-export compares competing whole-visit revisions, drives resolution, and holds unresolved visits out of the CSV. Per the HLD's delegation, the decision is owned by record-store with those as cascade notes, not co-owned.
- `docs/high-level-design.md`: state cell → `Drafted`; dependency note reworded to point at the now-defined contract.

**Where I need your call before continuing — I've stopped here (Phase 2 STOP):**

1. **Decision doc?** This choice stays live for a cold reader (two credible options traded against review load, implementation burden, and scientific-error risk; tablet-sync and review-export are sized around it), so it clears the bar for a full decision doc (options, weighted criteria, the tenet it turns on). I've written the Decisions row as the default. Want me to expand it into a full decision doc at `docs/intent/record-store/decisions/…`, or keep the row only?

2. **Edge-case probe — triage these gaps (fix in the LLD now vs. defer as open questions):**
   1. Submission whose base revision is a valid ancestor but not the current head — reject, hold as competing, or promote over intervening revisions?
   2. Brand-new visit's first submission — what base revision ID / payload shape signals "new visit" vs. an edit?
   3. "No other edit pending against that head" — what decides whether a near-simultaneous first edit is promoted or both are held as competing?
   4. One worker sends two distinct edits against the same base before resolution — competing, or does their own later edit supersede the earlier?
   5. Idempotency-key scope (per worker / per visit / global) and cross-worker collisions — retry or collision?
   6. A validation-rejected submission retried with the same key but a corrected payload — forbidden "different payload" reuse or a fresh submission?
   7. Submission referencing a plot UUID archived since fetch — accepted, rejected, or flagged, and what error shape for "validate plot references"?
   8. New submission arriving after a winner is chosen but before the resolution outcome commits — rebased, added as another competitor, or rejected?
   9. Resolution — must the winning head be a competing revision taken verbatim, or may a coordinator compose a new visit from several submissions?
   10. Current-state retrieval for an unresolved visit — serve the pre-divergence base as a usable value or an empty/error field, and what shape does "indicates unresolved review work" take?
   11. Ordering of several competing revisions returned as a "set" (arrival order is explicitly not authority) — by receipt time, worker, or client observation date?
   12. A long chain of sequential non-competing revisions with no coordinator resolution — "resolved"/export-eligible by single head alone, and do retained losing revisions from an earlier fork count as "competing"?
   
   Also fold in the two deferrals I sketched in the LLD's Open Questions (revision-history retention/compaction; whether resolution provenance is export-facing): fix, defer, or drop?

3. **Scope boundary:** tablet-sync and review-export are separate segments whose contracts are now unblocked. I kept them out per your "after that." Confirm they stay deferred — and say whether, once this is approved, you want me to propagate the cascade into them (pausing at each segment boundary) or hold.

4. **Tenet (optional):** your rationale reads like a standing lean — *prefer a visible coordinator decision over automatic field combination*. Want that added to the HLD `## Tenets`, or should the rationale stay only in the decision row / doc?

**Approve the LLD as drafted or send numbered feedback.** On approval, the next phase is the in-segment EARS cascade: REC-004/005/006 are currently policy-agnostic ("regardless of the concurrency policy's outcome", "unresolved review work", "contributing submission IDs") and will need refinement plus new specs for base revision IDs, competing-revision representation, the resolution outcome, and export eligibility. I won't proceed to specs/tests/code until you approve.