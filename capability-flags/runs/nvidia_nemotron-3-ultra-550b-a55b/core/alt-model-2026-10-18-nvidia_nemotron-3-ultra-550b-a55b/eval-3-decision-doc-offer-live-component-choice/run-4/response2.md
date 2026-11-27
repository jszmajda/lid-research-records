**Phase 2 (LLD) and Phase 3 (EARS specs) complete.** The record-store design now documents the whole-visit revisions decision with full rationale, alternatives table, and downstream contract requirements.

**LLD** (`docs/intent/record-store/record-store-design.md`):
- Concurrency policy decision with rationale: "A bigger review queue is preferred over maintaining merge rules that can combine scientifically related edits without noticing"
- Decisions & Alternatives table covering 5 sub-decisions (concurrency model, revision numbering, head selection, resolution creates new revision, export exclusion)
- Submission envelope, retrieval, unresolved-work representation, resolution operation
- Explicit downstream contracts for tablet-sync (local draft storage, retry, rejection handling, offline queue) and review-export (comparison screen, resolution submission, export eligibility, provenance)

**EARS specs** (`docs/intent/record-store/record-store-specs.md`):
- 12 specs covering submission acceptance/rejection, idempotency, revision assignment, conflict detection, unresolved marking, resolution (select/merge), and head advancement

Ready for **Phase 4 (intent-narrowing edge audit)**. The forks I previously identified remain:

1. **REC-007/008** — Gap in revision numbers: `base_revision < head_revision - 1` — treat as "does not match" (same rejection) or distinct error?
2. **REC-009/010** — Three+ competitors: resolve all at once or pairwise? (Pairwise changes head mid-process)
3. **REC-010/011** — Invalid `selected_revision` (not a competitor): reject or treat as merged?
4. **REC-012** — Resolution revision's `base_revision`: what value? If a worker later submits with old head as base, does it conflict?

Please resolve these, or I can propose resolutions for each.