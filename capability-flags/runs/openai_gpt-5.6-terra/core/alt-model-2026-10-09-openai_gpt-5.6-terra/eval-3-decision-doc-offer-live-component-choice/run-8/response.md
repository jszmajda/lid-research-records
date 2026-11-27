**Phase 1: HLD Review**

Updated `docs/high-level-design.md` to reflect the selected architecture:

- `record-store` now shows “whole-visit revisions selected.”
- The architecture describes the policy: competing complete revisions remain available for coordinator resolution rather than being automatically merged.
- `tablet-sync` and `review-export` remain intentionally deferred until the record-store contract is completed.

The HLD remains coherent with the selected direction:
- It preserves all submitted edits.
- It favors explainable review over automated scientific-field merging.
- It keeps concurrency semantics owned by `record-store`, with downstream components depending on its resulting contract.

Please approve this HLD update to proceed to Phase 2: completing the `record-store` LLD.