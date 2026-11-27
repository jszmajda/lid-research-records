Now I'll surface an edge-case probe for this design, as required in Phase 2:

## Phase 2: LLD Edge-Case Probe

The record-store design above has several gaps worth clarifying before moving to specs:

1. **Resolution replaces current state**: When a coordinator selects a revision, does it become the new "current" state, or does it stack on top? If it replaces, what is the state if a coordinator later selects a different revision? (Implies revision history of decisions, not just submissions.)

2. **Tablet retry after submission**: A tablet submits an edit, loses connectivity before receiving the revision ID response, and retries. Does the store match by idempotency key and return the assigned revision ID, or require the tablet to query for it separately?

3. **Edit referencing unresolved competing revisions**: A visit has competing unresolved revisions (e.g., revisions 3 and 4 from the same base revision 2). A tablet arrives with an edit based on revision 2. Is this accepted as a third competing revision, or rejected because the state is unresolved?

4. **Visit with unresolved revisions has no "current" yet**: If a visit has competing revisions and no coordinator has selected one, what state is returned to a tablet that queries for the current data? An error, the first-arriving revision, or null?

5. **Revision history retention and coordinator undo**: Can a coordinator review and revert a prior resolution decision? Are rejected revisions kept permanently, or archived after resolution?

6. **Identical submissions**: Two workers independently submit identical data (same observation date, species, notes) based on the same revision. Are these treated as competing revisions (two entries in the review queue) or deduplicated?

7. **Base revision stale by design deadline**: A tablet holds a local visit with base revision 5 for 48 hours offline. By the time it submits, the server's current state is revision 12. The submission references base revision 5, which may have been superseded by five coordinator resolutions. How does the server handle this?

These gaps do not block the design's core mechanism, but their resolution shapes the submission contract and review workflow. Which of these need clarification before we move to EARS specs?