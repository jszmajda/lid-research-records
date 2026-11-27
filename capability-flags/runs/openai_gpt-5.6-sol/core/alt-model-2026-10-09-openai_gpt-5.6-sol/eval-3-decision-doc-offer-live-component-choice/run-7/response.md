**Phase 2: Record-Store Design**
Updated `docs/intent/record-store/record-store-design.md` with:

- Immutable, complete whole-visit revisions and explicit base revision IDs.
- Automatic advancement only along an unambiguous revision line.
- Competing revision tips held for coordinator review.
- Submission outcomes of `current` or `review_required`.
- Current-state and revision-history retrieval contracts.
- Coordinator resolution by selecting a candidate or authoring a complete replacement revision.
- Optimistic candidate-set checking so submissions can continue during review.
- Explicit downstream obligations for tablet sync and review/export.
- A Decisions & Alternatives record explaining why field-aware merging was rejected.

The EARS specs remain unchanged pending this Phase 2 review.

**Edge Probe**
Please resolve or defer these design gaps:

1. For two racing initial submissions with no base, should the first remain the settled current revision while both enter review, or should the visit have no current revision until review?
2. Should every visit have at most one unresolved conflict, with candidate tips covering all branches from the last settled revision, including branches based on older ancestors?
3. After resolving a conflict, should a later edit based on an unselected candidate open a new conflict against the newly settled current revision?
4. May a revision change the visit’s plot UUID, or is the plot UUID immutable after the first accepted submission?
5. What base should a coordinator-authored replacement revision record: the last settled revision, the selected primary candidate, or no single base with provenance held only by the resolution record?
6. Should review resolution have its own idempotency key so coordinators can safely retry after timeouts?
7. Should idempotency keys be scoped per authenticated worker, per visit, or globally?
8. Is “identical submission” structural equality of the authenticated author, visit ID, base ID, and complete payload?
9. May detailed payload rules such as required fields, ranges, and duplicate species entries be deferred until the EARS phase, or should they be fixed in this LLD?

The probe also found that `docs/high-level-design.md` still says the concurrency choice is open. I recommend correcting those status statements after this LLD is approved.

This choice remains sufficiently live, and sizes two downstream components, that it qualifies for a full decision document rather than only the existing table row. Should I add `docs/intent/record-store/decisions/concurrent-visit-edits.md`?

Please reply with numbered answers and any other changes to the Phase 2 design.