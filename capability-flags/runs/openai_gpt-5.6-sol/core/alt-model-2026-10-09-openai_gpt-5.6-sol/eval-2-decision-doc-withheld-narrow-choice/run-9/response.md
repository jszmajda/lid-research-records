**Phase 1: HLD Check**

Updated `docs/high-level-design.md` to remove the stale statement that preview eviction remains open. Selecting 2Q does not alter FrameDesk’s architecture: cache data and replacement bookkeeping remain private to the preview worker, while the review API and render queue contracts stay unchanged.

Pre-flight found no implementation drift: all preview specs remain active gaps, and the repository contains no tests or implementation yet.

Please approve this HLD check so I can update and present the preview LLD with the complete 2Q design.