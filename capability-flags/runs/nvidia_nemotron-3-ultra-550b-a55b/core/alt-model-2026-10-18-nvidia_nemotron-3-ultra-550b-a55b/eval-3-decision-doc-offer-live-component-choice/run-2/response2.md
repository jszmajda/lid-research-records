The record-store design is complete. Here's what was finalized:

**HLD** (`docs/high-level-design.md`): Updated to reflect concurrency policy selected.

**Record-Store LLD** (`docs/intent/record-store/record-store-design.md`):
- Complete submission envelope, current-state response, unresolved-work representation, and resolution operation specs
- 10 decisions documented with rationale in Decisions & Alternatives table, including the core choice (whole-visit revisions over field-aware merge) and 9 edge-case resolutions from the intent-narrowing audit
- Detailed downstream contract work for tablet-sync and review-export

**Record-Store Specs** (`docs/intent/record-store/record-store-specs.md`): 20 EARS specs (REC-001 through REC-020) covering:
- Submission acceptance/rejection with base revision matching
- Idempotency semantics
- Competing revision detection and flat competing set model
- Coordinator-only resolution with `resolvedFrom` tracking
- Superseded flag on history entries
- Historically valid plot UUID acceptance (offline-first)
- Uniform validation for worker and coordinator submissions
- Audit-trail-preserving resolution even when payload matches existing revision

The design is now ready for tablet-sync and review-export phases.