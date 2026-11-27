## Phase 1: HLD Review

Updated `docs/high-level-design.md` to make the preview worker's 2Q eviction policy explicit.

- Long sequential screenings place first-use sheets in a separate queue, protecting reused comparison sheets from scan pollution.
- The extra queues and tunable size split remain private to the preview worker.
- The preview HTTP interface, render queue concurrency, and 12 GiB limit remain unchanged.
- LRU and frequency-based eviction with aging are recorded as rejected alternatives with their rationale.

Please approve this HLD update to proceed to the preview LLD.