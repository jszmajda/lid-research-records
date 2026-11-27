**Phase 1: HLD Update**

Updated `docs/high-level-design.md` to establish the selected architecture:

- `record-store` now preserves competing whole-visit revisions until review establishes a current record.
- Its architecture state now records that the whole-visit revision policy is selected.
- `tablet-sync` and `review-export` now explicitly depend on the forthcoming whole-visit revision contract rather than an unresolved concurrency choice.

Please review and approve this HLD update to proceed to Phase 2: completing the `record-store` design.