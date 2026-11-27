I recorded the whole-visit revision choice in `docs/intent/record-store/record-store-design.md` and updated the HLD’s status. The submission and resolution contracts still need decisions before the design is complete.

**How should retrieval represent a visit while competing revisions await review?** For example, A and B both edit revision R0, and A arrives first:

1. **Show R0** as the last uncontested state, alongside A and B.
2. **Show A provisionally**, alongside the conflict, without treating its earlier arrival as authoritative.
3. **Show no current state** until a coordinator resolves the conflict, but make R0, A, and B available for review.

In all three cases, the submissions are retained and the unresolved visit is excluded from CSV export. Which approach should the record store use?

The existing record-store specs are broadly compatible but do not yet define this contract; no code or tests exist. The site-catalog design also has a now-stale reference to the concurrency choice being pending; that sibling segment needs a later cascade.