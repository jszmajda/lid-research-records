Coherence pre-flight passed. HLD, LLD, EARS are mutually coherent for the previews segment.

**Phase 1 – HLD**
- `docs/high-level-design.md`
  - Architecture: Previews now “uses 2Q eviction” instead of “eviction policy remains open”.
  - Added Key Design Decisions:
    - Preview cache eviction – Chosen 2Q to protect repeatedly accessed comparison sheets from one-off screening scans. LRU and frequency-with-aging were considered; LRU offers lower bookkeeping but is vulnerable to sequential eviction, while frequency-with-aging retains yesterday's favorites too long and adds counter maintenance.

**Phase 2 – LLD**
- `docs/intent/previews/previews-design.md`
  - Private Cache now specifies 2Q: A1 for first-use entries, A2 for entries accessed ≥2 times. First hit inserts into A1; second hit moves A1→A2 and promotes recency. Hits in A2 update recency within A2. Eviction prefers A1 then A2. A1/A2 size split is tunable. Bookkeeping remains private to the worker.
  - Decisions & Alternatives table added with 2Q chosen over LRU and frequency-with-aging.
  - Open Questions & Future Decisions: eviction policy resolved; A1/A2 size split deferred for pilot tuning.

**Phase 3 – EARS**
- `docs/intent/previews/previews-specs.md`
  - PREVIEW-006: When a preview is admitted to the cache, the system SHALL place it in the first-use queue.
  - PREVIEW-007: When a preview in the first-use queue is accessed again, the system SHALL move it to the reused queue.
  - PREVIEW-008: When eviction is required, the system SHALL evict entries from the first-use queue before evicting entries from the reused queue.
  - Consistency report: coverage of queue placement/promotion/eviction order is present; no contradictions. Implicit scoping cleared. Specs are context-free.

**Phase 4 – Intent-narrowing edge audit**
Gaps surfaced for your triage before tests:
- A1/A2 size split value/range is unspecified – tunable but no default.
- Recency update semantics inside A2 on repeated hits are described in LLD but not specced.
- Admission when cache is exactly at 12 GiB – evict “enough” is defined, but minimum eviction granularity not stated.
- Concurrent access promotion atomicity – race between hit-in-A1 and eviction not covered.
- No decision on ghost queues/classic 2Q vs simplified two-queue variant.

Do you approve the HLD, LLD, and EARS changes as written, and want me to proceed to Phase 5 tests-first for PREVIEW-006/007/008 and then Phase 6 code?