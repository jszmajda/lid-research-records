## Phase 1: HLD Review

Updated `docs/high-level-design.md` to make 2Q the selected private preview-cache eviction policy. The HLD now states that 2Q protects repeatedly compared sheets from one-off screening scans; the worker boundary, HTTP outcomes, render queue, and 12 GiB limit remain unchanged.

The existing cache-privacy and bounded-storage tenets support this decision. Queue sizing and promotion mechanics remain a preview-component design decision for Phase 2.

Please approve the HLD update to proceed to the preview LLD.