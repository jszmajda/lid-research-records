## Phase 1: Revised HLD Review

`docs/high-level-design.md` now records the decision in `Key Design Decisions`:

- Whole-visit revisions preserve every submitted correction and route competing revisions to coordinator review.
- Unresolved visits are excluded from the reviewed CSV.
- Field-aware three-way merge remains documented as a viable alternative because it could reduce review work by combining non-overlapping edits.
- The rationale for rejecting it is explicit: scientifically related fields may be edited independently, and an automatic combination could create an observation no worker actually made.
- The required downstream contracts are stated:
  - Tablets retain a base revision ID and distinguish accepted submissions from submissions awaiting review.
  - Review/export presents complete competing revisions, supports selecting the current revision, and omits unresolved visits from CSV generation.

Please approve this HLD revision to begin the `record-store` LLD.