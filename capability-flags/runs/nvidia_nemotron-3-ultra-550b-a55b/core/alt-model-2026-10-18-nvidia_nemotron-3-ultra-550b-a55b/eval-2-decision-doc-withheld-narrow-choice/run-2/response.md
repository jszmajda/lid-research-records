## Phase 4 — Intent-Narrowing Edge Audit

### Cross-segment interactions (previews ↔ review-api)
- The 2Q policy is private to the preview worker (per tenet "Keep cache paths and replacement bookkeeping private to the preview worker"). No review-api spec changes needed.
- **Latency concern**: Eviction during admission (PREVIEW-004 → PREVIEW-006) adds synchronous work before the 200 response. The LLD says "Before admitting a completed sheet, evict enough existing sheets" — this is on the render-completion path, not the request path, so request latency is unaffected. ✓

### Spec composition forks

| Specs | Fork |
|-------|------|
| **PREVIEW-003 + PREVIEW-006/007** | PREVIEW-003 handles concurrent *misses* (deduplication map). PREVIEW-007 says "cache hit on an entry in Am" — but what about a request for a key that's in the deduplication map (render pending) but not yet in Am/A1? Is that a "miss" (returns 202) or something else? The LLD says "Once rendering completes, subsequent requests can receive the JPEG directly" — implying pending keys are not cache hits. |
| **PREVIEW-004 + PREVIEW-006** | Ordering: LLD says "Before admitting… evict enough existing sheets." PREVIEW-004 (evict) must happen *before* PREVIEW-006 (insert). Not stated in specs. |
| **PREVIEW-007 + PREVIEW-009 (concurrency)** | If a hit promotes an Am entry to A1 head *while* eviction is scanning Am tail, does the promoted entry escape eviction? Atomic move vs. race. |
| **PREVIEW-009 + PREVIEW-010** | "Am exhausted" in PREVIEW-009 requires knowing Am's current byte total. PREVIEW-010 says "transfer size accounting" — implying separate Am/A1 byte counters. Not explicit in PREVIEW-009. |
| **PREVIEW-009** | "Evict entries from tail of Am first" — one at a time until budget met, or drain all of Am first? LLD says "evicted from the tail of Am first; only when Am is exhausted does eviction proceed from the tail of A1" — suggests drain-Am-first. |
| **PREVIEW-006/007/008** | "Head" and "tail" for FIFO: head = insertion/promotion point (newest), tail = eviction point (oldest). Consistent in LLD but not explicit in specs. |

### Per-spec divergence probes (new specs)

| Spec | Divergent readings (pick one) |
|------|-------------------------------|
| **PREVIEW-006** | (a) Insert at Am head *before* eviction | (b) Insert at Am head *after* eviction (LLD intent) | (c) Insert at Am tail (standard FIFO) |
| **PREVIEW-007** | (a) Atomic remove-from-Am + insert-at-A1-head | (b) Copy to A1, leave in Am until eviction | (c) Mark for promotion, move lazily |
| **PREVIEW-008** | (a) True move: remove from current pos, insert at head | (b) Lazy: update timestamp, re-sort on eviction | (c) Duplicate at head, mark original for GC |
| **PREVIEW-009** | (a) Evict one Am entry at a time until under budget | (b) Drain all of Am first, then A1 if still over | (c) Proportional eviction from both queues |
| **PREVIEW-010** | (a) Separate Am/A1 byte counters, transfer on promotion | (b) Only combined counter, "exhausted" = combined size | (c) Per-entry size in both queues, sum on demand |

---

**Please resolve the forks above** — I'll narrow the specs accordingly before Phase 5 (tests). The main decisions needed:

1. **Pending-key hit vs miss** (PREVIEW-003/007 interaction): Treat keys in deduplication map as misses (return 202) — they're not in Am/A1 yet.
2. **Admission ordering**: Explicit "evict then insert" in PREVIEW-006 or new spec.
3. **Promotion atomicity**: Atomic move (remove from Am, insert at A1 head) for PREVIEW-007/008.
4. **Eviction granularity**: Drain Am fully before touching A1 (per LLD "exhausted").
5. **Size accounting**: Separate Am/A1 byte counters (enables PREVIEW-009's "exhausted" check).
6. **Head/tail definition**: Add a spec or clarify in PREVIEW-006/009.

Reply with your choices (or "use LLD intent for all" if the LLD text already captures your intent) and I'll update the specs.