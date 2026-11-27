The current design leaves one consequential ambiguity: “2Q” can mean either:

1. **Canonical 2Q:** probationary FIFO, bounded ghost history, and protected LRU. This best recognizes comparison sheets reused after probationary eviction, but requires three bookkeeping structures.
2. **Two-resident-queue variant:** probationary FIFO and protected LRU, with no ghost history. This matches the earlier “two queues” description and is simpler, but only protects sheets reused before probationary eviction.

I recommend canonical 2Q because it better preserves comparison sheets across large screening scans. Which variant should the preview design specify?