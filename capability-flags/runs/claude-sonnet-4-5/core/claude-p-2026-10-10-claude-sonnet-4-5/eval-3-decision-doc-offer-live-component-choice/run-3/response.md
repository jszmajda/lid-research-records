Now I'll run an edge-case probe on the LLD to identify gaps:

## LLD Edge-Case Probe

**Concurrent submission race conditions:**
1. What happens when two submissions arrive with the same `base_revision` number within milliseconds of each other? Which gets the next sequence number, and does the second automatically enter unresolved state?

**Resolution boundary cases:**
2. What happens if a coordinator attempts to resolve a visit that is already `clean` (no competing revisions)?
3. What happens if a new submission arrives after a coordinator starts reviewing but before they submit the resolution?
4. Does the coordinator resolution operation verify that the `contributing_revision_ids` still represent the complete set of competing revisions at resolution time?

**Validation and error handling:**
5. The design mentions validating `plot_id` against the site catalog and checking field types. What response does a submitter receive when these validations fail? Does a rejected submission consume an idempotency key?
6. What happens if an idempotency key is reused with the same visit_id but from a different authenticated author?

**Retrieval and history:**
7. The current-state response mentions "a separate operation retrieves the full payload for a specific revision number." Is this operation scoped to competing revisions only, or can any historical revision be retrieved even after resolution?

**State transitions:**
8. When a clean visit (current_revision = N) receives a new submission with base_revision = N, does it simply increment to N+1 and remain clean, or is there any other state change?
9. After a coordinator resolves a visit, can that visit ever return to `unresolved` status if a late-arriving submission references an old base revision?

**Invariants:**
10. Is there an invariant that revision numbers are strictly monotonic and gapless within a visit (1, 2, 3...), or can gaps exist if submissions are rejected?

---

**STOP** — Please review the updated record-store design and this edge-case probe. Which gaps should be addressed in the LLD before moving to EARS specs?