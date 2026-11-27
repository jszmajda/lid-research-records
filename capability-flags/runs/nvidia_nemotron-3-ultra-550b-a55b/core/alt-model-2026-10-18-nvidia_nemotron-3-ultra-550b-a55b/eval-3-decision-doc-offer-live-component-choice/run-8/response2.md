**Phase 2 & 3 Complete** — Record store design and EARS specs updated for whole-visit revisions.

**Summary of changes:**

| Artifact | Key updates |
|----------|-------------|
| `record-store-design.md` | Full submission envelope, `VisitState` response, unresolved-work representation, resolution operation. Decisions & Alternatives table now documents three decisions with full rationale. Added **Downstream Contract Implications** section specifying exactly what tablet-sync and review-export must accommodate. |
| `record-store-specs.md` | 10 specs (REC-001 through REC-010) covering submission, idempotency, retrieval, competing revisions, resolution, history, and stale-base acceptance. |

**Open questions deferred (from design doc):**
1. Revision ID scheme (UUID vs. monotonic integer per visit)
2. Whether resolution can create a new merged revision (current: selects existing only)
3. Pagination for submission history at scale

**Ready for Phase 4 edge audit** — I'll run the divergence probe on the updated specs, or we can proceed if you're satisfied.