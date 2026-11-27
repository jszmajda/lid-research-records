The 2Q choice is local to the preview worker and does not alter the HLD architecture or review API. One design fork remains before I can finish the preview LLD:

1. **Full 2Q:** probationary FIFO plus protected LRU, with a metadata-only ghost history for recently evicted probationary keys. A comparison sheet requested again after a screening scan is promoted into the protected queue, but this adds a third bookkeeping structure.
2. **Resident-only 2Q:** probationary FIFO plus protected LRU, with promotion only when a sheet is requested again while still resident. This matches the earlier “two queues” description and is simpler, but a comparison sheet evicted before its second request receives no protection when re-rendered.

Which interpretation should the design use?