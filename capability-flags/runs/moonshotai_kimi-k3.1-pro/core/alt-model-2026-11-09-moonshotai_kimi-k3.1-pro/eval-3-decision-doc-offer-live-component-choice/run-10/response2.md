### Phase 2 — Record-store LLD draft

Completed `docs/intent/record-store/record-store-design.md`. It now defines:

- Immutable, complete visit revisions with server-generated revision IDs and client-supplied base revision IDs.
- Active-head rules for linear edits, concurrent edits, duplicate roots, stale bases, and reopened conflicts.
- Submission, idempotent-retry, retrieval, history, and resolution contracts.
- Coordinator resolution by selecting one complete candidate—not merging fields.
- Transactional expected-head checks to prevent resolving away an unseen submission.
- Concrete tablet-sync obligations: frozen retry envelopes, base revision persistence, complete snapshots, and no client-side rebasing or winner selection.
- Concrete review/export obligations: whole-revision comparison, stale-resolution refresh, audit provenance, and exclusion of unresolved visits from CSV.
- A Decisions & Alternatives table explaining why field-aware merge remains attractive if review volume becomes unmanageable, and what maintaining it would require.

### LLD edge-case probe

The independent probe found the document context-free and confirmed that the alternative approach and downstream consequences are covered. It identified these gaps for your triage:

1. **Plot changes:** May a correction change `plot_id` relative to its base, or is plot identity immutable for a visit?
2. **Idempotency identity:** Should the same key submitted by a different authenticated worker or coordinator be rejected?  
   *Recommended:* yes; include the authenticated principal in idempotency comparison.
3. **Equivalent retry encoding:** Should canonicalization disregard species ordering and expected-head ordering while preserving observer order?  
   *Recommended:* yes, with explicit numeric and null-handling rules.
4. **History classification:** A resolved-away revision can later acquire a child.  
   *Recommended:* represent active-head, superseded-by-child, and resolved-away as independent properties rather than exclusive states.
5. **Error contract:** Validation, idempotency, stale-head, and invalid-selection failures need stable machine-readable codes.  
   *Recommended:* define these in the record-store contract, including current competing heads with stale-resolution errors.
6. **Resolution response:** The successful and replayed resolution result is undefined.  
   *Recommended:* return a server-generated resolution ID, selected revision ID, resolution time, and resulting current revision ID.
7. **Duplicate content under different keys:** Two identical submissions with different keys could create competing revisions.  
   *Recommended:* preserve both; idempotency deduplicates retries, not independently intended submissions.
8. **Stable history ordering:** Equal timestamps need a deterministic tiebreaker.
9. **Zero-head invariant:** State explicitly that every existing visit always has at least one active head.
10. **Unknown visits and empty candidate lists:** Define not-found behavior and return an empty competing-revision list for current visits.

Please approve the recommendations or identify which items should remain open. Once these are settled, I’ll revise the LLD and proceed to **Phase 3: update the EARS specifications**.

The whole-visit versus field-aware merge trade-off is currently recorded in the LLD’s Decisions & Alternatives table. Because it materially shapes two downstream components and may be reconsidered later, it could also justify a standalone decision document; would you like one, or is the table sufficient?