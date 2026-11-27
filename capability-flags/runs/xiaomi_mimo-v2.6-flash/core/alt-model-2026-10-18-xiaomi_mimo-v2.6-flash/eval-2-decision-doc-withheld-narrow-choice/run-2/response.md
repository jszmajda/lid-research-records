**Phase 1 output — HLD changes** (`docs/high-level-design.md`):

1. Architecture section, Previews bullet — was: *"Owns rendering, pending jobs, and a private 12 GiB cache. Its eviction policy remains open."* Now:

   > - Previews: `docs/intent/previews/previews-design.md`, with `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs, and a private 12 GiB cache with 2Q eviction.

2. Goals — was: *"Return a ready preview or a pending response through the same interface for every eviction policy."* Now:

   > - Return a ready preview or a pending response through the same interface regardless of cache state.

No other HLD sections change: the Approach, Tenets, and Non-Goals already describe a bounded private cache without naming a policy, and the interface/12 GiB/dedup goals hold under 2Q. The 2Q choice itself (queues, split, trade-offs vs. LRU and aged-frequency) will be recorded in the previews design's Decisions & Alternatives table in Phase 2 — its substance lives in that node, so it doesn't rise to a standalone decision doc.

**STOP — please review the Phase 1 HLD changes.** Approve to proceed to Phase 2 (previews LLD: record the 2Q decision and design the queue structure), or give numbered feedback.