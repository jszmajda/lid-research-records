Preview design finished to 2Q per LID workflow.

**Phase 1 – HLD**
* docs/high-level-design.md updated: Previews node now records a private 12 GiB cache with 2Q eviction instead of “policy remains open”.

**Phase 2 – LLD**
* docs/intent/previews/previews-design.md updated
  * Private Cache now specifies 2Q: first access → Q1 FIFO first-use, second access → promotion to Q2 FIFO reused, eviction removes Q1 before Q2, replacement metadata private to worker, API/queue unchanged.
  * Decisions & Alternatives table records choice of 2Q over LRU and frequency-based aging with rationale about protecting comparison sheets during big screenings and accepting extra bookkeeping.
  * Open Questions & Future Decisions records eviction policy resolved, queue size split deferred for pilot tuning.

**Phase 3 – EARS**
* docs/intent/previews/previews-specs.md added:
  * PREVIEW-006: When a cached preview is requested for the second time, the system SHALL promote it from the first-use queue to the reused queue.
  * PREVIEW-007: When evicting entries to meet the 12 GiB limit, the system SHALL evict from the first-use queue before evicting from the reused queue.
* Consistency check: coverage of 2Q promotion and eviction order present, no contradictions, scopes explicit.

**Phase 4 – Intent-narrowing edge audit**
Two forks need your call before tests/code:
1. Promotion trigger – PREVIEW-006 says “requested for the second time”. Should promotion fire only on a 200 cache hit, or also on a 202 pending response for an already-cached key? I’ve assumed 200 only.
2. Queue sizing – Q1/Q2 size split is deferred. Do you want a default split now, or keep it as a pilot-tune parameter?

Confirm the promotion trigger interpretation and whether you want an initial Q1/Q2 size split documented, and I’ll lock the specs and proceed to tests-first.
