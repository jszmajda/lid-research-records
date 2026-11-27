## Phase 2 Stop: LLD Update and Edge-Case Probe

I've updated the record-store design document with the complete whole-visit revisions approach. Here's what's now specified:

**Design completion:**
- Submission structure with base revision ID tracking
- Three distinct visit states (single revision, competing/unresolved, coordinator-resolved)
- Resolution operation with full audit trail
- Clear downstream contracts for tablet-sync and review-export

**Design & Specs Consistency Report:**
- ✓ Coverage: All LLD behaviors have corresponding specs (submission, idempotency, base revision tracking, current-state retrieval, competing revisions, resolution, data preservation)
- ✓ No contradictions between specs
- ✓ Scopes are explicit (REC-010/011/012 clearly differentiate the three visit states)
- ✓ Context-free reading: all specs stand alone via grep

**Edge-Case Probe — Internal Gaps:**

1. **New submission to a resolved visit**: When a visit has been resolved and a field worker submits new edits, does the new submission start a fresh competing set or append to an already-decided state? Currently unspecified.

2. **Base revision not found**: If a submission references a base revision ID that doesn't exist (tablet has stale/corrupted data), what should the API return and how should tablet-sync handle it?

3. **Concurrent acceptance**: If two submissions arrive nearly simultaneously for the same base revision, is there a total ordering guarantee, or can they both be accepted in the same competing set atomically?

4. **Submission immutability**: Once accepted, can a submission be edited or deleted? Can a resolution decision be reverted?

5. **Submission size limits**: Are there constraints on payload size, and if a submission exceeds limits, what error should the API return?

6. **Ordering visibility**: Once a submission is accepted, is it immediately visible to other workers retrieving the same visit, or is there a lag?

Which of these gaps should I address in the design vs. defer as open questions for tablet-sync and review-export to clarify when they're designed?