## Phase 1: HLD Review

Updated `docs/high-level-design.md` to state that the preview worker’s private 12 GiB cache uses 2Q eviction.

The selection is coherent with the existing architecture and tenets:

- 2Q remains entirely inside the preview worker; the review API and public response protocol remain unchanged.
- It preserves the 12 GiB bound and immutable-preview keying.
- Its scan resistance directly supports repeated clip comparisons during long sequential screenings.
- Cache paths and all queue metadata remain private implementation details.

No HLD tenet needs to change. Please approve this HLD update so I can proceed to Phase 2 and complete the preview LLD.