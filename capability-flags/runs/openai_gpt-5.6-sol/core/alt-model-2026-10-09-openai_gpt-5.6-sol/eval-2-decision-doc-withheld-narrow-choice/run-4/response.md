Updated `docs/intent/previews/previews-design.md` with the selected 2Q design and recorded the alternatives. I also removed the stale “eviction policy remains open” statement from the HLD.

The Phase 2 probe found one foundational choice before the remaining edge cases can be resolved: how should the incoming-queue byte target behave?

1. **Soft target:** Use the split only to select an eviction victim when the full 12 GiB cache needs space. This maximizes utilization but permits the incoming queue to temporarily exceed its target.
2. **Hard partition:** Keep the incoming queue within its target after every admission. This provides stronger scan isolation but may evict sheets while space remains elsewhere.
3. **Adaptive target:** Adjust the split using ghost hits. This adapts to workloads but adds substantially more policy state and tuning.

Which behavior should the design use?