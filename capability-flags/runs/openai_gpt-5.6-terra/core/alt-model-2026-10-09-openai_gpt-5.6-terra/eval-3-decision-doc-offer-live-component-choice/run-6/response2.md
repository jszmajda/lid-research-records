## Phase 1: HLD Review

Added `docs/decisions/concurrent-visit-revisions.md` and linked it from the HLD's Key Design Decisions table.

The decision record covers:

- The selected whole-visit revision policy and why it protects scientific intent and auditability.
- Field-aware three-way merge as a credible alternative, including its lower review volume, field-provenance needs, and risk of combining scientifically connected edits without adequate domain rules.
- Conditions that would justify revisiting the decision.
- Required downstream accommodations:
  - Tablets retain base revision IDs, submit complete revisions, retry idempotently, and show competing-revision outcomes.
  - Review/export compares complete revisions, records coordinator resolutions and contributing revision IDs, and excludes unresolved visits from the CSV.

`git diff --check` passes.

Please approve the Phase 1 artifacts. After approval, I will complete the record-store LLD and run its design-level edge-case probe.