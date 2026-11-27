## Phase 1: HLD Review

Updated `docs/high-level-design.md` to record the selected whole-visit revision strategy:

- The record store preserves every submitted edit as a complete visit revision.
- Concurrent revisions are routed to review rather than automatically merged.
- Visits with unresolved revisions are excluded from CSV export.
- Tablet sync and review/export remain downstream components that will consume this contract.

The HLD remains coherent with its tenets: no submitted edit is silently discarded, and the export path remains inspectable.

Please approve the HLD update to proceed to the `record-store` LLD design.