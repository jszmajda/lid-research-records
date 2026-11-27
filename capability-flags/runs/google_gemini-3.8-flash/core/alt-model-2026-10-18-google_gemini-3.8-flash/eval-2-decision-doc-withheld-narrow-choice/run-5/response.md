I have updated the design documents to record the 2Q eviction decision and specify the preview cache replacement strategy:

1. **`docs/high-level-design.md`**: Updated the Previews architecture entry to reflect 2Q eviction in the private 12 GiB cache.
2. **`docs/intent/previews/previews-design.md`**: Added the 2Q strategy structure (`A1in` FIFO for initial admissions, `A1out` ghost FIFO for evicted keys, and `Am` LRU for multi-hit entries), populated the Decisions & Alternatives table with the rejected options and rationale, and tracked the queue partition ratio under Open Questions.

---

### Phase 2 LLD-Level Edge-Case Probe

Before moving to Phase 3 (EARS specs update), here are the structural edge-case questions identified for the 2Q implementation in `previews-design.md`:

1. **`A1out` bounds & persistence**: What is the size/entry limit for the ghost metadata queue `A1out`, and does `A1out` need persistence across worker restarts, or does it start empty on process reboot?
2. **Hit promotion while in `A1in`**: Does a hit on an item currently resident in `A1in` immediately promote it to `Am` on access, or does it wait until eviction from `A1in`?
3. **Ghost hit during active re-rendering**: If a request misses the cache but hits `A1out`, and concurrent requests arrive before rendering completes, do they share the pending job ticket without altering `A1out` state until admission into `Am`?
4. **Renderer version invalidation**: When a renderer version bump occurs, are keys in `A1in`, `A1out`, and `Am` invalidated simultaneously, or does the versioned cache key naturally cause older versions to drain via normal eviction?

Would you like to resolve any of these in the LLD before we proceed to updating the EARS specifications, or keep them deferred for implementation?