I've recorded 2Q and drafted the eviction section of the previews LLD. This is the Phase 2 stop, so I haven't written EARS specs, tests, or code.

**What changed**
- `docs/intent/previews/previews-design.md`:
  - The "policy is still open" paragraph is replaced by an **Eviction Policy (2Q)** section: a FIFO probation queue, an LRU protected queue, and a metadata-only eviction history. The history is not counted toward the 12 GiB bound.
  - A **Decisions & Alternatives** row records 2Q against LRU and aged frequency.
  - An **Open Questions** list holds the two items below.
- `docs/high-level-design.md`: the Previews bullet no longer says the policy is open. This change stays within the existing design tree, so it didn't need a cascade pause.
- **No separate decision doc:** the choice affects only the preview worker, and the 2Q-vs-LRU/frequency rationale fits in one table row. Say if you'd rather have a full decision doc.
- **Tenets and goals:** 2Q keeps replacement bookkeeping private to the worker and leaves the HTTP contract, render queue, and 12 GiB bound unchanged, so it fits the HLD's tenets and goals.

**Two decisions I left for you**
1. **What counts as "reused"?**
   - **(a) Hit on a probation sheet promotes it.** An editor who opens a sheet twice in a row gets protection immediately. A burst of repeated views within one screening can also pull scan sheets into the protected queue.
   - **(b) Only a request that finds its key in the eviction history promotes it** (classic 2Q). Sheets must survive one probation pass and be re-requested to be protected, so scans stay out, but a sheet is unprotected until it has been evicted once.
   - I lean toward (b) for your scan-protection goal, but it's your call.
2. **Probation share and history length.** A 12 GiB cache holds about 6,000 two-MiB sheets, roughly the weekly distinct-clip count. Classic 2Q starts with probation at about 25% and a history of about half the cache's entry count. Do you want those as starting values, or a different split? They're a worker config value either way.

**LLD gaps I noticed**
- A history hit is admitted after a fresh render, which takes about 450 ms. Is that cost acceptable, or should reuse promotion also apply to sheets still resident?
- When a render fails or completes after its key left the history, where does it enter: probation, as a first use?
- Cache state on worker restart is unspecified: do the queues and history rebuild from disk, or start cold?
- A bumped renderer version makes old-version sheets unreachable. They should age out of the queues normally rather than needing a purge, and I'd say that explicitly.

Once you answer the two decisions and triage the gaps, I'll move to Phase 3 and draft the EARS specs.