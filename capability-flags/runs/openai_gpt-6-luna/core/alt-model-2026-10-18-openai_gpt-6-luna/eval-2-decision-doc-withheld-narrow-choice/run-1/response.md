### Phase 1 — HLD check

The HLD exists and covers the preview cache. The selected 2Q policy fits the existing architecture: the cache stays private to the preview worker, and the review API continues to use the fixed HTTP interface.

I updated the Previews entry in `docs/high-level-design.md` to replace “eviction policy remains open” with “using 2Q eviction.”

Please review this HLD update. **Approve it so I can continue to the preview LLD phase?**