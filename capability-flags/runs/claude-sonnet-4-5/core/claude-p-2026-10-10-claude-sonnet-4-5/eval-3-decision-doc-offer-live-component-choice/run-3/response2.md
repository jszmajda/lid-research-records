## Record Store LLD Complete

I've finished the record-store design around whole-visit revisions. Here's what the design now covers:

**Core mechanism**: Integer-sequenced revisions per visit. Each submission names its base revision. Matching base → clean increment. Mismatched base → unresolved status with competing revisions awaiting coordinator resolution.

**Downstream obligations**:
- **Tablet-sync** must retain base revision numbers, handle unresolved responses, size retry logic for full-visit payloads, and display server-assigned revision numbers
- **Review-export** must provide side-by-side revision comparison, exclude unresolved visits from CSV, display resolution history, and support bulk resolution workflows

**Key rationale** (in Decisions table): Field-aware merge would reduce review volume by auto-combining disjoint edits, which is appealing. But scientifically related edits (species ID + cover estimate) can appear disjoint to field-name rules and combine incorrectly. The team already compares whole observations in their field-note workflow, so whole-visit revisions match existing practice. We accept the larger review queue over the risk of scientifically invalid automated merges.

**Edge cases covered**: Race conditions serialize to monotonic sequence numbers. Post-resolution submissions can return a visit to unresolved (preserves the "no discarded edits" tenet). Coordinator resolution detects mid-review submission races and rejects stale resolutions. Validation failures reject before creating revisions, leaving idempotency keys reusable.

**Deferred to implementation**: Bulk resolution UI shortcuts, notification strategy, archival policy for unbounded revision growth, and depth of cover_class validation (schema vs. reference).

---

**STOP** — Does this design give tablet-sync and review-export the contract they need? Any gaps before moving to EARS specs?