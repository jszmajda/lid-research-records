Phase 2 (LLD) is drafted: `docs/intent/previews/previews-design.md`, plus two stale HLD lines that still called eviction an open, multi-policy question. Nothing outside the previews node changed.

**2Q cache design**
- 12 GiB split into a 3 GiB probationary queue (FIFO, first admission) and a 9 GiB protected queue (LRU, second cached request); both capacities are startup-tunable.
- A hit in probationary promotes the sheet to protected; a hit in protected refreshes its recency.
- Admission appends to probationary and evicts its front when over capacity; a promotion that overflows protected evicts the protected LRU first.
- Bookkeeping is queue membership plus recency, discarded with the entry and lost on restart.
- The Decisions & Alternatives table records 2Q against LRU and aged frequency, plus the split, protected-queue order, and promotion trigger.

**LLD edge-probe gaps**
1. A comparison sheet's first pass gets no protection until a second cached request; a long screening in between can evict it. I recorded this as deferred—acceptable, or do you want a first-touch protection rule?
2. Pending retries can promote one-off sheets: the browser retry after a render completes is a cache hit, so a screening sheet can enter protected on that second request. Should promotion require a second deliberate hit rather than any post-render retry, or is a retry legitimate reuse?
3. The 25/75 split is a starting point, not measured. Recorded as deferred tuning.

Please review the LLD and tell me whether to approve it and proceed to Phase 3 (EARS specs for the 2Q behaviors), or which gaps to settle first.