**Phase 4 — Intent-Narrowing Edge Audit**

**Cross-spec / cross-segment interactions:**

1. **PREVIEW-004 vs PREVIEW-009/010/011**: PREVIEW-004 says "evict entries before admission" but doesn't specify *which* entries or *from where*. The 2Q specs (009-011) fill this gap. The composition is coherent — 004 is the general requirement, 009-011 are the 2Q-specific refinement.

2. **PREVIEW-006/007 vs PREVIEW-002**: PREVIEW-002 says "when cached, return 200". PREVIEW-006/007 specify the internal queue placement on first/second access. No conflict — 002 is the external contract, 006-007 are internal mechanics.

3. **Review API segment**: The review API (`review-api-design.md`) only calls `GET /internal/previews/{clip-id}/{revision}`. It has no visibility into cache internals. No cross-segment coupling introduced.

**Per-spec divergence probes (new specs 006-011):**

| Spec | Divergent Reading 1 | Divergent Reading 2 | Resolution |
|------|---------------------|---------------------|------------|
| **006** (first access → A1 head) | "First access" = first *render completion* for that key | "First access" = first *cache hit* after admission | 006 says "accessed for the first time and admitted" — admission happens at render completion. The render-completion event is the admission point. |
| **007** (A1 hit → promote to Am head) | Promotion happens on *any* A1 hit, including the same request that just admitted it | Promotion only on a *subsequent* request after admission | "Accessed again" implies a distinct request after admission. The same request cannot "access again" — it's the admission request. |
| **009** (A1 > 3 GiB → evict A1 tail) | Evict one entry at a time until under limit | Evict all excess bytes in one batch (may evict multiple entries) | "Evict entries from the tail... until it is within the limit" — iterative tail eviction is the standard 2Q algorithm; batch is an implementation detail. Both satisfy the spec. |
| **011** (admission would exceed 12 GiB → evict A1 tail first, then Am) | Check total budget *before* placing in A1; if over, evict A1 then Am, then admit | Admit to A1 first, *then* evict if total exceeds budget | "When admitting... would exceed" implies a pre-admission check. The spec says evict *before* the cache exceeds budget. Pre-check is correct. |

**Sequencing ambiguity:**
- PREVIEW-006/007/008 form a state machine: A1 → Am → Am. No ambiguity on ordering.
- PREVIEW-011's "evict A1 tail first, then Am tail" is a clear priority order.

**Namespace ambiguity:** None — all specs use `PREVIEW-` prefix consistently.

**Open questions for your resolution:**

1. **PREVIEW-007 promotion timing**: Is "accessed again" strictly a *subsequent* request (my reading above), or could a single request that renders *and* immediately re-reads count? (I recommend: subsequent request only — the render-completion admission is not an "access again".)

2. **PREVIEW-009/010 eviction granularity**: The spec says "evict entries... until within limit." Should the implementation evict one entry per loop iteration, or calculate how many bytes to free and evict that many entries at once? (Both satisfy the spec; the former is simpler, the latter fewer loop iterations.)

3. **Renderer version in cache key**: The LLD says "cache key includes clip ID, revision, and renderer version." The specs don't explicitly mention renderer version in eviction. Is it intentional that a renderer version bump treats the entry as a *new* key (entering A1 fresh)? (I recommend yes — renderer version is part of the immutable key, so a new version is a new entry.)

**STOP for your review.** Please confirm the three resolutions above, or provide alternatives.