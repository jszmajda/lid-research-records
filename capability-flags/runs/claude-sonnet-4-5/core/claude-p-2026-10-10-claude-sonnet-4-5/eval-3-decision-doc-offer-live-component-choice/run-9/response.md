Now I'll run an edge-case probe on this design.

## LLD-Level Edge-Case Probe

Questions about gaps in the current design:

1. **Stale base revision**: What happens when a worker submits an edit based on a revision that was already resolved? Does their submission become a new competing revision against the resolved current state, or is it rejected?

2. **Resolution creates new revision**: When a coordinator creates a new revision during resolution (combining their judgment rather than selecting an existing one), what is the base revision ID of that coordinator-created revision? Does it reference all competing revisions, or the most recent one?

3. **Multiple concurrent editors**: If three workers all edit from the same base revision, do all three submissions become competing revisions? Is there a limit to how many competing revisions can exist before resolution is required?

4. **Null base collision**: What happens when a worker submits with null base revision ID (creating a new visit) but that visit ID already exists on the server? Is this a rejection, or does the visit ID guarantee it's actually new?

5. **Post-resolution access**: After resolution, are the non-selected competing revisions still fetchable via API? If so, through what operation - regular retrieval, or a separate history/audit operation?

6. **Resolving non-competing visits**: What happens if a coordinator attempts to resolve a visit that's in "current" state with zero competing revisions? Is this a no-op, an error, or allowed as an audit record?

7. **Absent current revision**: During the competing state, "current revision ID is absent" - what should tablet-sync and review-export do when they fetch a visit and get no current revision? Should they show the most recent revision by timestamp, or no data?

8. **Resolution idempotency**: If a resolution submission needs retry, what makes it idempotent? Does the resolution operation itself need an idempotency key, or does repeating "select revision X as current" with the same revision ID qualify as safe retry?

**STOP for user review.**