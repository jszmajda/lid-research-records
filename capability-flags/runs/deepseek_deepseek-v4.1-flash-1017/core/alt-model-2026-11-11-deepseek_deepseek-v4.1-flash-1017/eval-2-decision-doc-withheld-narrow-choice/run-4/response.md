Phase 1 (HLD) is checked: no architectural change. I only removed the stale "eviction policy remains open" wording and aligned the interface goal to current intent.

Phase 2 (previews LLD) is updated in `docs/intent/previews/previews-design.md`:

- Completed sheets enter a FIFO first-use queue; a cache hit promotes them to a reused, recency-ordered queue.
- The first-use queue is capped at a tunable share, initially 3 GiB of the 12 GiB budget, so a long screening churns only that share.
- Reused entries are evicted least-recently-used only when total cached data would exceed 12 GiB.
- The HTTP contract, four-job render queue, and 12 GiB limit are unchanged.
- LRU and aging-frequency alternatives and why they were rejected are recorded in Decisions & Alternatives.

The LLD-level edge probe left three points for your ruling:

1. **First-use share:** I set the starting split at 3 GiB (25%). Confirm that, or name another starting value.
2. **Remembered first-use keys:** if a first-use sheet is evicted and then requested again, it currently re-renders and re-enters the first-use queue. Should we remember recently evicted first-use keys so that re-request goes straight into the reused queue, or keep strictly two queues?
3. **Scan-only capacity:** with nothing in the reused queue, the first-use queue stays capped at 3 GiB and the remaining 9 GiB stays idle. Should unused capacity be available to first-use entries while the reused queue is empty, or stay reserved?

Approve this LLD with any numbered changes, and answer 1–3, then I'll update the EARS specs.