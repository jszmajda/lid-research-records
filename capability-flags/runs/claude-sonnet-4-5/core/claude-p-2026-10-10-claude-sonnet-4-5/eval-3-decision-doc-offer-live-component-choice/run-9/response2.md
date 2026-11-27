## Updated Record-Store Design

I've completed the record-store design with the whole-visit revisions approach. Here's what was resolved:

### Core Mechanism

**Whole-visit revisions**: Each submission carries its base revision ID. When concurrent edits occur, they become competing revisions that await manual coordinator resolution. No automatic merging - the coordinators' scientific expertise is the merge engine.

### Key Design Points

**Submission envelope** includes visit ID, base revision ID (null for new visits), idempotency key, author ID, and complete payload. Server assigns revision IDs on acceptance.

**Revision states**: visits progress through current → competing → resolved. When competing, there's no current revision available - this is an explicit contract for downstream nodes.

**Resolution** allows coordinators to either select an existing competing revision or create a new one combining their judgment. Resolutions are idempotent and retain audit trails.

**Edge cases resolved**:
- Workers can submit based on any base revision (even already-resolved ones) - creates new competition as normal editing
- No limit on competing revision count
- New visit collision (reused UUID) is rejected as a client bug
- All revisions retained permanently; history API provides full audit trail
- Resolution itself is idempotent with its own key

### Why Field-Aware Merge Remains Credible

The Decisions table documents that field-aware three-way merge could still make sense if review volume becomes unsustainable. The tradeoff: that approach would need maintained merge rules and field-level provenance, and could silently combine scientifically coupled edits (like a species ID correction and its cover estimate) without noticing. Current choice prioritizes scientific correctness over coordinator convenience.

### Downstream Contracts

**Tablet-sync** must retain base revision IDs, handle absent current revisions (competing state), and show workers when their submissions are under review.

**Review-export** must provide side-by-side revision comparison, exclude competing visits from exports, and support creating new resolution revisions.

The HLD is updated to reflect that the concurrency choice is resolved, unblocking tablet-sync and review-export design.

**STOP for user review.**