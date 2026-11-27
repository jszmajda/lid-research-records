Now I'll run an LLD-level edge-case probe to identify gaps before presenting the design.

**LLD Edge-Case Probe:**

1. **Visit ID initialization**: The design says visit ID is client-generated, but how does the plot_id association happen? Does the visit ID encode the plot reference, or is it sent in the first submission?

2. **Base revision validation**: What happens when base_revision_id points to a revision that exists but is no longer current (was superseded by a coordinator resolution)? Should this create a competing revision, or require the worker to fetch the latest resolved state first?

3. **Resolution request validation**: 
   - What happens if both selected_revision_id and resolved_content are provided?
   - What happens if neither is provided?
   - What happens if selected_revision_id points to a revision that's not in the competing set?

4. **Mid-resolution concurrency**: What happens if a new worker submission arrives while a coordinator is drafting a resolution (between fetching the visit and posting the resolution)?

5. **Partial resolution**: The resolved_revision_ids field suggests a coordinator might resolve only some competing revisions. Is this intended, or must all competing revisions be resolved atomically?

6. **History retrieval**: Architecture mentions "submission-history retrieval" but no endpoint is specified. What does this return, and who can access it?

7. **Invalid plot reference**: What specific response does a submission with a non-existent plot ID receive?

8. **Competing revision race on first submission**: Can two workers submit the first revision (base_revision_id null) concurrently? How is that resolved?

Which of these gaps should be addressed in the LLD versus deferred?

---

**Phase 2 - Updated LLD**

Here's the completed record-store design incorporating whole-visit revisions:

## Key Changes

1. **Resolved the concurrency mechanism**: Adopted whole-visit revisions with server-assigned revision IDs and base revision tracking
2. **Specified all four contract elements**:
   - Submission envelope with idempotency_key, base_revision_id, and content
   - Current-state response showing status and competing revisions
   - Resolution operation for coordinator review
   - Export eligibility rule (current-only)
3. **Added Decisions & Alternatives table** documenting the concurrency choice and two implementation decisions

The design now provides a complete contract for tablet-sync (what to send, what base revision ID means) and review-export (competing revision format, resolution operation, export filter).

Ready to proceed with the edge-case triage?