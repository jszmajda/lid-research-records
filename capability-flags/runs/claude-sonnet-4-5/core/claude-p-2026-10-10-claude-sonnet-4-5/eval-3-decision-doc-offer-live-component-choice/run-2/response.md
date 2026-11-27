Now let me run an edge-case probe on this LLD to identify any gaps:

**Edge cases and gaps for review**:

1. **Submission with unknown baseRevisionId** — what happens when a worker submits an edit based on a revision that doesn't exist (stale client state, wrong visit)?

2. **Submission to visit with competing revisions** — when a visit already has competing revisions and a new submission arrives, does it join the competing set or get a special status?

3. **Worker edits based on competing revision** — what if a worker's baseRevisionId points to a competing revision rather than the current revision? Is this rejected, or added to the competing set?

4. **Concurrent coordinator resolutions** — two coordinators attempt to resolve the same visit's conflicts simultaneously. What prevents the second resolution from clobbering the first?

5. **Resolution selecting current revision** — coordinator attempts to resolve by selecting the revision that's already current. Valid no-op, or rejected as meaningless?

6. **Field validation boundaries** — the design says "validate field types and plot references" but doesn't specify: can observers array be empty? Can notes be null? Must observationDate be within a range? Are there limits on speciesCover array size?

7. **Idempotency key reuse across visits** — what if a worker accidentally uses the same idempotency key for two different visitIds?

8. **Retrieval of deleted/non-existent visits** — how does current-state retrieval respond when the visitId doesn't exist?

**Context-free check**: The LLD now reads independently without conversation assumptions. The Decisions table captures the rationale. Tablet-sync and review-export can reference the envelope/response formats without needing to reconstruct the design discussion.

---

**STOP: Please review the updated record-store LLD and the edge cases above. Which gaps should be addressed in the design, and which are acceptable to defer?**