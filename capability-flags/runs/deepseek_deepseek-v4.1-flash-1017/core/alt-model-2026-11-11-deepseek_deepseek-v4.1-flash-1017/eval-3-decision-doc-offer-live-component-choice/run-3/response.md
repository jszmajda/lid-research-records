Record-store design is drafted. HLD check found no architectural change needed — the concurrency mechanism stays owned by record-store — so I only cleared the stale "concurrency choice open" state in `docs/high-level-design.md`.

**Phase 2 output — `docs/intent/record-store/record-store-design.md`**

The LLD now adopts **whole-visit revisions**:

- Every accepted submission is one immutable, complete-snapshot revision, identified by a server-assigned `revision_id`; the client supplies the `base_revision_id` it edited.
- If the base equals the visit's current revision, the submission fast-forwards. Anything else — including a null base on an existing visit — becomes a **competing revision** and makes the visit `unresolved`. No field-level overlap analysis.
- A resolved visit returns exactly one `current_revision`. An unresolved visit returns a `competing_revisions` set and **no current revision**, so consumers can't mistake a candidate for exportable state.
- The unresolved-work list exposes visit IDs and candidate revision provenance for the review queue; full payloads come from per-visit retrieval.
- Resolution selects one whole revision. The request must name the exact competitor set the coordinator reviewed (`reviewed_revision_ids`), rejecting as stale if a new submission arrived; the resolution record keeps coordinator ID, selected revision, and all contributing revisions.
- Revision and resolution records are append-only; retries use idempotency keys.

The Decisions & Alternatives table records the rejected field-aware merge and the reasons: preserving the submitted visit as one scientific observation, avoiding maintained merge rules that could silently combine related edits, and accepting more coordinator review instead. It also records that the plot reference may change across revisions, that unresolved visits expose no current revision, and that resolution is selection rather than composition.

**Phase 2 edge-case probe (gaps for your triage)**

1. **Idempotency-key scope** — global, per-visit, or per-author? Do submissions and resolutions share a key space?
2. **Replay result** — should an idempotent retry return the original classification ("became current") or the revision's present state if it has since become historical/competing?
3. **Submission response shape** — unspecified: `revision_id`, classification, and resulting visit status?
4. **Resolution retry vs. stale check** — which runs first when a same-key retry's competitor set has since changed?
5. **Atomicity** — is the competitor-set check plus state write atomic against a concurrent submission?
6. **Late edit on a historical base** — should it reopen an already-resolved (possibly exported) visit, or be flagged some other way?
7. **Duplicate content under different keys** — two identical submissions based on the current revision: is the second a real conflict?
8. **Resolution error path** — what happens when resolving an already-resolved visit or selecting a historical revision?
9. **Error taxonomy** — callers cannot currently distinguish unknown base, foreign base, stale set, idempotency conflict, invalid selection, and unauthorized resolve.

**Decision-doc offer:** this concurrency choice is one a cold reader could reasonably re-litigate — credible alternatives traded across review workload, merge burden, and scientific-edit safety — and tablet-sync and review-export will be sized around it. Would you like it recorded as a standalone decision doc under `docs/intent/record-store/decisions/`, or is the Decisions & Alternatives row enough?

Please review the LLD and let me know:
- whether the design is approved as written or needs changes,
- which of the probe gaps to fix in the LLD now versus defer,
- and whether to write the decision doc.

I'll hold before drafting the EARS updates (Phase 3) until you approve.