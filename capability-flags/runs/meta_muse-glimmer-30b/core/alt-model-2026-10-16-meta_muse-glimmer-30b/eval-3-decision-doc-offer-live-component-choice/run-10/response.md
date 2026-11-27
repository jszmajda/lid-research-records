Phase 2 — LLD update complete for record-store.

**File changed:** `docs/intent/record-store/record-store-design.md`

The LLD now commits to whole-visit revisions and removes the open choice:

* Concurrency policy: each submission is stored as a complete visit revision referencing `baseRevisionId`. Concurrent edits create competing revisions resolved by a coordinator. No automatic merging.
* Submission envelope defined:
  - `visitId` client-generated UUID
  - `baseRevisionId` revision edited from, null for initial creation
  - `idempotencyKey` for retry deduplication
  - `payload` complete visit record
* Current-state retrieval returns `resolvedRevisionId`, `resolvedPayload`, and `pendingRevisions` list with revisionId, authorId, baseRevisionId, submittedAt, payload. A visit with ≥2 pending revisions is unresolved and excluded from export eligibility.
* Resolution operation records coordinatorId, timestamp, selected revisionId, and superseded revision IDs. Original submissions are retained.
* Decisions & Alternatives table records:
  - Concurrent edit handling → Whole-visit revisions over field-aware three-way merge. Rationale: preserves submitted visits as units, avoids merge rules that could combine scientifically related edits without noticing; user prefers larger review queue.
  - Revision identity → server-generated revisionId per submission with client baseRevisionId reference.

Downstream contract notes are updated for tablet-sync and review-export to depend on this envelope and unresolved-work representation.

**STOP for user review.**
Please confirm this LLD reflects the whole-visit revisions intent and is context-free. On explicit approval I will proceed to Phase 3 — EARS spec draft/update for `docs/intent/record-store/record-store-specs.md`.