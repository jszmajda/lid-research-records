## Phase 2 Complete: LLD Update with Decision Doc

I've completed the record-store design with the whole-visit revisions choice fully specified and documented:

**Design Doc Changes:**
- Submission Envelope — visit_id, base_revision_id, submitted_state, author_id, idempotency_key, submitted_at
- Current-State Response — current_revision_id, current_state, unresolved_flag, competing_revision_ids with metadata
- Resolution Operations — immutable selection by coordinator, recording winning + superseded revision IDs
- Submission Storage — each submission gets immutable revision_id; visit workflow progresses through states (single submission → possibly unresolved → resolved → possibly unresolved again if new late submissions arrive)

**Decision Doc** — `decisions/concurrent-edit-strategy.md` — lays out:
- Why whole-visit revisions wins on **implementation simplicity** (no merge rules to maintain) and **coordinator transparency** (sees both competing submissions side-by-side, cannot miss scientific relationships)
- Why field-aware merge is still credible (lower review volume: ~30–50 reviews vs. ~180 for 6,000 seasonal visits)
- Trade-off: accepts higher review volume for simpler code and clearer coordinator workflow
- **Downstream implications:** tablet-sync must track revision_id in local state and include it in submissions; review-export must implement a comparison UI and exclude unresolved visits from export until manually resolved

**EARS Specs** — 9 new specs covering submission handling, current-state retrieval, resolution operations, and preservation:
- REC-001 through REC-005: submission envelope semantics and retry idempotency
- REC-010 through REC-012: current-state response structure with metadata
- REC-020 through REC-022: coordinator resolution and state transitions
- REC-030: non-discard preservation

**Consistency verified:**
- ✅ Coverage: all design behaviors are spec'd
- ✅ No contradictions
- ✅ Scopes explicit (no implicit universal claims)
- ✅ Context-free reading (each spec stands alone)

**Five deferred questions** surface edge cases the design doc leaves open for later:

1. Invalid base_revision_id (data corruption, old cache) — reject or accept as fresh?
2. Coordinator role authentication — separate role or privilege on worker ID?
3. Late submission on resolved visit — new conflict or rejection?
4. Lifecycle of unresolved visits — indefinite retention or cleanup bounds?
5. Ordering of competing revisions — by time, author, or unspecified?

Are the design, decision doc, and specs ready to present for review, or do any of these edge cases need explicit answers before moving to Phase 3 (EARS spec finalization)?