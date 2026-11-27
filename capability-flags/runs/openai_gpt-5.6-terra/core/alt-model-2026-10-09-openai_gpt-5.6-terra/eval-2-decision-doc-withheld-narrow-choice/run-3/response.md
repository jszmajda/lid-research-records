## Phase 1: HLD Review

Updated `docs/high-level-design.md` to record that the preview worker uses 2Q eviction. The HLD still assigns all replacement bookkeeping to the worker and preserves the API, queue, and cache-budget boundaries.

The selected policy is a preview-component decision rather than a project-wide architectural mechanism, so its queue structure and tuning details belong in the preview LLD.

Please approve this HLD update to proceed to the preview LLD.