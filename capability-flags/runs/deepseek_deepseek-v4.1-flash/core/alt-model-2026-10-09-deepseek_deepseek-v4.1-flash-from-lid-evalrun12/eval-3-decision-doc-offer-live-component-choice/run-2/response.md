**Phase 2 — Record Store LLD (stop for review)**

I finalized `docs/intent/record-store/record-store-design.md` around whole-visit revisions and removed the open choice. Also de-staled the HLD row ("concurrency choice open" → "Drafted") and its dependency paragraph. The contract now reads:

- **Whole-visit revisions.** Every submission is a complete visit naming a `base revision ID`. The server assigns each accepted submission a `revision ID`, author, and receipt time; accepted revisions form a lineage-linked history.
- **Conflict rule.** Base equals current revision → advances the visit (common case). Base is stale → **competing revision**: retained, never merged; the visit becomes *unresolved* and the competing revisions become coordinator review work. Concurrency is decided by lineage alone, never by field contents.
- **Submission envelope.** visit ID, base revision ID (empty on first revision), idempotency key, and the full visit fields; acceptance returns revision ID, receipt time, and current-vs-competing.
- **Retrieval.** Current state returns the current revision's fields plus an unresolved-review indicator; history returns each revision with author, receipt time, base; review-outcome ops read unresolved work and record resolutions.
- **Unresolved work & resolution.** Unresolved visits expose their competing revision IDs (so review-export can compare and hold them out of the export). A coordinator designates one competing revision as current; the resolution records coordinator identity and contributing submission IDs, and all originals are retained.

Recorded in the Decisions & Alternatives table: concurrent-edit policy (whole-visit vs. field-aware three-way merge), lineage-based conflict detection, resolution-by-selection (vs. composing a merged revision), and server-assigned revision identity. Deferred: coordinator-authored revisions, superseded-revision retention, and queue-volume sizing.

Deliberately untouched (cross-segment pause): tablet-sync and review-export — they depend on this contract and remain unwritten.

Two questions:
1. Approve this LLD so I can cascade to Phase 3 (EARS specs for record-store)?
2. This concurrency choice stays genuinely live for a cold reader and two sibling designs will be sized around it. Want me to record a full decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md` (with the Decisions row kept as the lighter alternative)?