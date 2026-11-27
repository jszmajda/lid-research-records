The record-store design is finished around your choice. Since you said "finish the design," I consolidated the Phase 2 and Phase 3 stops into this one review.

**What changed**

- `docs/intent/record-store/record-store-design.md` — the open choice is now a specified design. Every submission becomes one immutable revision of one visit (full payload, author, receipt time, base revision). One current revision per visit; a valid edit based on the current revision fast-forwards with no review work; an edit based on any other stored revision is retained as an *open competing revision*, giving the visit unresolved review work until a coordinator adopts or withdraws each open one. The submission envelope, current-state response, unresolved-work listing, and resolution operations are defined. First arrival sets only a provisional current record — every divergent arrival gets human comparison, honoring "arrival order is not authority."
- `record-store-specs.md` — REC-001–006 kept as-is; added REC-007–019 (first revision, fast-forward, divergence, adopt/withdraw, content immutability under resolution, stale-resolution rejection, the three retrieval shapes, and the rejection cases). Consistency check: full coverage of the LLD, no contradictions, scopes explicit; a short definition note makes the specs grep-standalone.
- `docs/high-level-design.md` — record-store's state now "Designed," and the paragraph saying tablet-sync/review-export "wait for its contract" now points them at it.

**Edge probe** (delegated, blind): 12 findings. Fixed in the LLD: sibling open revisions survive an adoption and re-target the new current; any stored revision is a valid base regardless of its own state; stale resolutions are pure error responses with no record; idempotency keys are worker-scoped and remembered only on acceptance; a visit exits the unresolved listing only when all open revisions are resolved; archived plots still resolve. Deferred to Open Questions for your triage: (1) identical-content divergent submissions — auto-no-op or always review? (2) can a withdrawn revision be re-opened, or must it be resubmitted? (3) unresolved-listing pagination (sized with review-export).

**Two questions for you**

1. Cross-segment cascade: `site-catalog-design.md` still says tablet-sync's behavior "remains pending that choice" — one stale sentence now that the choice is made. OK to update it, or leave site-catalog untouched?
2. The whole-visit-vs-merge decision is recorded as a Decisions row in the LLD. Since two nodes will be sized around it, want it as a full decision doc instead (`docs/intent/record-store/decisions/`)? The row stands if not.

Numbered feedback on the LLD and specs welcome; after your review, the next step is the Phase 4 intent-narrowing audit before any tests or code.