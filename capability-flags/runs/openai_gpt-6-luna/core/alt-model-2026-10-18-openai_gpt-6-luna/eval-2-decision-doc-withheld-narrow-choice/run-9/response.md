### Phase 1 — HLD check

The HLD already places the 12 GiB cache and all replacement bookkeeping inside the preview worker, and keeps the preview API contract independent of eviction policy. Choosing 2Q fits that architecture, so no HLD change is needed. The working tree is clean.

I’ll carry your 2Q selection into the preview design. **Approve this Phase 1 result so I can continue to the LLD review?**