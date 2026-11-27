## Phase 1: HLD Review

Updated `docs/high-level-design.md` to establish whole-visit revisions as the project architecture:

- Each submitted edit is a complete revision based on a known prior revision.
- Concurrent revisions are preserved for coordinator resolution; the system does not automatically merge fields.
- Tablet sync will retain base revision IDs.
- Review/export will compare competing revisions and exclude unresolved visits from the partner CSV.
- The HLD now records the choice, rationale, and rejected field-aware merge alternative in **Key Design Decisions**.

This choice remains consequential across the record store, tablet sync, and review/export. I recorded it in the HLD because it is the shared architectural contract; a standalone decision document is optional but would preserve the comparison criteria for future reconsideration.

Please approve the HLD update and say whether you want a standalone decision document for this concurrency decision. After approval, I will update the record-store design and its EARS specifications.