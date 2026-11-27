Updated the design docs for the **2Q** cache eviction policy (Phase 2 — LLD):

- **`docs/high-level-design.md`**: Removed the stale `"Its eviction policy remains open."` note under Previews; the 12 GiB private cache boundary remains unchanged.
- **`docs/intent/previews/previews-design.md`**:
  - Updated `## Context` and `## Private Cache` to specify 2Q (`A1in` FIFO at initial 25% / 3 GiB `K_in`, `A1out` FIFO ghost history at initial ~3,000 keys `K_out`, `Am` LRU for promoted sheets, plus admission/hit/eviction rules).
  - Added `## Decisions & Alternatives` recording 2Q vs. LRU and aged frequency eviction (kept as a table row rather than a standalone decision doc since replacement state is private to the preview worker).
  - Added `## Open Questions & Future Decisions` with `K_in`/`K_out` empirical tuning deferred.

### Phase 2 LLD Edge-Case Probe (for triage: fix in LLD vs. defer)

**2Q Cache Invariants & Edge Cases**
1. **Oversized or boundary eviction**: What happens when `size(A1in) <= K_in` and evicting all of `Am` still does not free enough space for a new sheet of size `S` (or `S` exceeds `12 GiB`)? Does eviction fall through to `A1in`, or is admission skipped?
2. **Per-queue vs. total budget on `Am` admission**: When `size(A1in) < K_in` and `size(Am) >= 12 GiB - K_in`, does promoting an `A1out` key into `Am` evict from `Am` to keep `Am <= 12 GiB - K_in`, or only evict when total `size(A1in) + size(Am) + S > 12 GiB`?
3. **Storage accounting & renderer version bumps**: Is `12 GiB` measured as exact JPEG byte length or filesystem-allocated bytes, and do stale renderer-version entries age out naturally via 2Q or get purged on version bump?
4. **Configuration bounds**: What bounds are enforced on `K_in` and `K_out` (e.g., `0 < K_in < 12 GiB`, `K_out > 0`)?

**Concurrency, Ordering & Restart Lifecycle**
5. **Atomic dedup-to-cache transition**: Is removing a completed job from the deduplication map atomic with cache admission so no concurrent `GET` slips between them?
6. **Eviction vs. in-flight `200` reads**: How are cached JPEG bytes protected while streaming a `200` response if a concurrent admission evicts that entry?
7. **Worker restart**: Are orphaned temporary render files cleaned up on startup, and is 2Q state persisted, rebuilt into `A1in`, or cleared?
8. **Queue locking**: How are `A1in`, `A1out`, `Am`, and size counters synchronized across concurrent `200` hits and up to 4 active render completions?

**HTTP & Queue Gaps (existing LLD)**
9. **Render failure & queue bounds**: What HTTP status/body is returned if a render job fails or the FIFO render queue is bounded and full, and what is the exact `202` job-ticket payload/header shape?

Please review the updated `docs/high-level-design.md` and `docs/intent/previews/previews-design.md`, let me know which probe items to resolve in the LLD vs. defer, and confirm when you're ready to proceed to **Phase 3 (EARS specs)**.