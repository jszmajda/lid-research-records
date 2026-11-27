I’ve drafted the 2Q preview design in `docs/intent/previews/previews-design.md` and updated the HLD to reflect the selection.

The design uses:
- A FIFO **probationary queue** for newly rendered sheets.
- An LRU **protected queue** for sheets requested again.
- Private byte-based queue capacities summing to at most 12 GiB.
- No non-resident history queue.
- No changes to the preview API, render queue, or four-job limit.

The design probe found five gaps to resolve before I update the EARS specs. My recommended resolutions are:

1. A sheet larger than the probationary capacity is served but not cached.
2. Both queue capacities must be positive; a sheet larger than the protected capacity remains probationary rather than being promoted and immediately evicted.
3. Once a cache hit is selected, its bytes remain readable until the response finishes, even if the entry is concurrently evicted.
4. Successful renders are cache-admitted before their deduplication entry is released; intervening requests receive the cached sheet.
5. After render failure, a later request creates a fresh job and ticket; failed tickets are not reused.

The actual capacity split remains deferred for workload-based tuning.

Do you approve the design with these five resolutions, or would you like any numbered item changed?