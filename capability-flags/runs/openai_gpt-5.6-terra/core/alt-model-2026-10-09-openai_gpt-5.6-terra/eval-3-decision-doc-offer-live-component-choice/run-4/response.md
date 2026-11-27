## Phase 1: HLD Review

Updated `docs/high-level-design.md` to record the selected concurrency policy:

- `record-store` now preserves competing whole-visit revisions for coordinator resolution.
- Revisions retain the revision they started from.
- Tablet sync must retain base revision IDs.
- Review/export must compare competing revisions and exclude unresolved visits from CSV output.
- Added a Key Design Decision documenting why whole-visit revisions were chosen over field-aware three-way merge.

The HLD remains consistent with its tenets: it does not silently discard edits, preserves an inspectable path to export, and avoids automatic merging of scientifically related fields.

Please approve this HLD update to proceed to the record-store LLD.