## Record-Store LLD Review

Updated `docs/intent/record-store/record-store-design.md` to select whole-visit revisions:

- Every submitted edit is an immutable, complete visit revision with its base revision ID.
- A submission based on the current revision becomes current only when no review is pending.
- A stale-base submission, or any submission while review is pending, is retained as a competing revision and marks the visit for coordinator review.
- The store never performs field-level merging.
- A coordinator resolves review by selecting one retained revision as current, while retaining every submission and recording the coordinator, time, and considered revision IDs.
- Tablet sync and review/export obligations are captured as downstream contracts, without designing those nodes yet.
- The decision table records why the larger review queue is preferred over scientifically unsafe merge rules.

### LLD Edge-Case Probe

Please decide these design-level gaps before I draft or revise the `REC` requirements:

1. **First revision:** Should creating a new visit submit a revision with no base revision ID, or should the tablet create an initial local revision ID and submit it as the base?
2. **Current revision while pending review:** The LLD currently keeps the last non-conflicted current revision readable but not export-ready. Is that the intended meaning of “current,” or should a visit with competing revisions have no current revision until resolved?
3. **Coordinator choice:** Must a resolution select exactly one submitted revision unchanged, or may a coordinator create a new complete revision that incorporates their own corrections while retaining the competing submissions?
4. **Rejected submissions:** When a submission names an unknown revision, a revision from another visit, or an invalid plot, should the server reject it without creating any revision, as assumed in the LLD?
5. **Decision record:** This concurrency choice has durable, cross-node consequences. Would you like a standalone decision document, or is the LLD’s Decisions & Alternatives row sufficient?

Please approve the LLD and answer the numbered questions.