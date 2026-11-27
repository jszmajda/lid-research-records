**Revised Phase 1: HLD Review**

`docs/high-level-design.md` now records the whole-visit-revisions decision in a dedicated Key Design Decisions section.

It explains:
- Why each accepted concurrent edit remains a complete revision and why competing revisions require coordinator resolution.
- Why field-aware three-way merge remains a credible future option: it could reduce review volume by combining genuinely independent changes.
- Why it is not selected: field relationships can carry scientific meaning that merge rules cannot safely infer.
- What downstream nodes must accommodate:
  - `tablet-sync` retains a base revision ID, submits complete revisions, and distinguishes a current acceptance from a competing revision awaiting review.
  - `review-export` compares competing revisions, records coordinator outcomes, and excludes unresolved visits from the partner CSV.
- That the detailed submission and resolution contract remains owned by `record-store`.

Please approve this revised HLD before I complete the `record-store` LLD in Phase 2.