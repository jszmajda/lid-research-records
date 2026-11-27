**Phase 1 — HLD check:** The selected 2Q policy fits the existing architecture: replacement bookkeeping stays private to the preview worker, and the API, render queue, and cache budget remain unchanged. No HLD architecture or tenet change is needed. The HLD does still say the eviction policy is open; I’ll update that once the 2Q choice is recorded in the previews design.

The current previews design lists LRU, aged frequency, and 2Q as candidates. Its specs cover the cache limit but do not yet specify eviction behavior. I found no preview implementation or tests in the repository, and made no file changes in this phase.

Do you approve this HLD check so I can proceed to Phase 2 and revise the previews design?