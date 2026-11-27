Phase 1 (HLD check): no architecture change — the interface, queue concurrency, and disk budget are policy-invariant by design. One stale line fixed in `docs/high-level-design.md:14` ("eviction policy remains open" → 2Q). No cross-segment cascade: review-api consumes none of the eviction metadata, so its segment is untouched.

Phase 2 — the preview design is finished around 2Q in `docs/intent/previews/previews-design.md`. The choice is recorded as a row in the Decisions & Alternatives table (it lives entirely inside this component's cache, so it belongs here, not in a standalone decision doc). Here is the revised design in full:

> ---
> parent: high-level-design
> prefix: PREVIEW
> ---
>
> # Previews Design
>
> ## Context
>
> The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The mix varies by production, so the replacement policy must tolerate both patterns: a screening must not displace the comparison working set, and a project switch must not be held hostage by stale favorites.
>
> ## Architecture
>
> Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.
>
> Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.
>
> ## Rendering and Deduplication
>
> Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.
>
> ## Cache Replacement: 2Q
>
> Cached JPEG data is bounded to 12 GiB (PREVIEW-004). Replacement follows 2Q with three lists:
>
> - **A1 (probation, FIFO)** — every newly rendered sheet is admitted here. A screening fills A1 with single-use sheets that age out without ever displacing comparison sheets.
> - **A1-ghost (keys only, FIFO)** — when A1 evicts an entry, its key moves here and its JPEG bytes are discarded. The ghost list holds no data, so it costs only key memory.
> - **A2 (main, LRU)** — sheets that have proven reuse. Comparison working sets settle here.
>
> Access rules:
>
> | Request finds the key... | Response | List effect |
> |---|---|---|
> | in A2 | 200 | move to A2 MRU |
> | in A1 | 200 | none — A1 is FIFO; a hit neither refreshes nor promotes |
> | in A1-ghost | 202 (miss; re-render) | on completion, admit directly to A2 MRU |
> | nowhere | 202 (miss; render) | on completion, admit to A1 tail |
>
> A hit in A1-ghost is a cache miss like any other: it follows the pending-job and deduplication semantics of PREVIEW-003 and PREVIEW-005. The ghost list only changes where the completed sheet is admitted. A sheet must be evicted from A1 and then requested again to prove reuse — that gate is what keeps a sequential screening from promoting its own recent tail (an editor backing up a few clips during one screening).
>
> Capacity and eviction:
>
> - A1 and A2 are byte-accounted against a combined 12 GiB bound. Initial split: 25% A1 / 75% A2, tunable (see Open Questions).
> - Before admitting a completed sheet, evict until the admission fits. If A1 is over its share, evict the A1 FIFO head into A1-ghost. If A2 is over its share, evict the A2 LRU tail and drop it entirely.
> - A1-ghost is bounded by entry count (not bytes) at roughly half the combined entry capacity; overflow drops the ghost FIFO head.
> - A sheet whose JPEG alone exceeds the 12 GiB bound is never admitted; it is streamed to the requester and discarded.
>
> Eviction never deletes source footage and never changes job-ticket semantics. Entries keyed by an older renderer version are not specially invalidated — they become unreferenced and are reclaimed by ordinary replacement, so a renderer bump reclaims old bytes lazily. All list bookkeeping stays private to the preview worker.
>
> ## Decisions & Alternatives
>
> | Decision | Chosen | Alternatives Considered | Rationale |
> |---|---|---|---|
> | Replacement policy | 2Q (A1 FIFO probation, A1-ghost, A2 LRU main) | LRU; frequency counts with aging | Screenings introduce many single-use sheets; comparisons re-reference a small set. LRU lets a long sequential screening evict the comparison working set. Frequency-with-aging retains repeatedly popular sheets but adds counter maintenance and keeps yesterday's favorites after a project switch. 2Q admits new sheets to probation and promotes only after eviction plus re-reference, so scans cannot displace comparison sheets and unused entries leave quickly. |
> | 2Q variant | Classic, with the A1-ghost re-reference gate | Simplified 2Q promoting on any second hit | Promoting on any second hit lets a screening promote its own recent tail. Requiring eviction-then-re-reference filters that noise at the cost of one key-only FIFO list, modest next to the two data queues 2Q already requires. |
> | Capacity accounting | Bytes, combined bound across A1 and A2 | Per-list entry counts | Sheets average ~2 MiB but are not uniform; only byte accounting actually holds the 12 GiB promise. |
> | Initial capacity split | 25% A1 / 75% A2; ghost at ~half the combined entry capacity | 50/50 split; byte-bounded ghost | Starting point only, sized so a screening bursts into probation without squeezing the main queue; see Open Questions for tuning. |
>
> ## Open Questions & Future Decisions
>
> ### Resolved
>
> 1. ✅ Replacement policy: 2Q, selected to protect comparison sheets during big screenings while letting one-off screening sheets leave quickly.
>
> ### Deferred
>
> 1. The A1/A2 byte split (initial 25/75) and A1-ghost entry bound need tuning against observed workload; instrument per-list hit rates before changing either.
> 2. Warm restart: whether A1/A2/ghost bookkeeping persists across worker restarts alongside the cache directory, or the cache starts cold — currently unspecified.
> 3. Old renderer-version entries could be proactively invalidated on a renderer upgrade rather than reclaimed lazily; lazy reclamation is simpler but holds dead bytes until replacement reaches them.
>
> ## References
>
> - HLD: docs/high-level-design.md
> - Review API (consumer of the fixed preview interface): docs/intent/review-api/review-api-design.md

**Edge-case probe — gaps for your triage.** A delegated probe of the revised LLD surfaced these; they need your call on fix-in-LLD-now vs. defer as open questions:

1. **Eviction between lookup and completion.** The access table fixes admission placement by where the *request* found the key, but eviction can move a key (A1 → ghost, or out entirely) while its render job is pending. Where does the completed sheet admit? This one touches the promotion gate itself — I'd recommend fixing it in the LLD now (e.g., placement is decided at admission time, not request time).
2. **In-flight 200s vs. eviction.** Nothing says whether a response currently streaming a sheet's bytes pins it against eviction. A screening-driven eviction storm could otherwise truncate JPEGs mid-stream.
3. **Failed ghost-hit retry.** If a ghost hit's render job fails and a later request retries, does the retry admit to A2 (the original ghost hit proved reuse) or start over in A1? Failure arguably shouldn't erase the promotion proof, but the doc doesn't say.
4. **Ghost/A2 double membership.** On promotion, the doc never explicitly removes the key from A1-ghost — one line fixes it.
5. **Renderer version in the interface.** The cache key includes renderer version, but `GET /internal/previews/{clip-id}/{revision}` has no way to carry it — implicit "current worker version" vs. client-supplied is a genuine fork in the existing design. (Pre-dates 2Q, but it's load-bearing for the lazy-reclamation claim.)
6. **What counts against 12 GiB** — on-disk file size vs. in-memory bytes, and whether a render-in-progress counts. Affects how PREVIEW-004 is even measured.
7. Lower priority, pre-existing: render-failure outcome for a polling client (202 forever vs. terminal status), render-queue depth/backpressure, and 404 semantics for resolved-but-unrenderable revisions.

**This is the Phase 2 stop.** Please (a) triage the gaps above — which get fixed in the LLD now, which go to Open Questions, which are out of scope — and (b) approve the LLD or send numbered feedback. On approval I'll draft the 2Q EARS specs (Phase 3), then stop again before tests and code.