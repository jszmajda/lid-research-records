## Phase 1: HLD Review

Updated `docs/high-level-design.md` to record that `record-store` uses a **whole-visit revision policy**:

- Competing concurrent edits remain complete submitted revisions for coordinator resolution.
- `tablet-sync` and `review-export` will consume the record-store contract when their designs are created.
- The architecture, goals, non-goals, and tenets remain consistent with this choice.

Please approve this HLD update to proceed to the `record-store` LLD.