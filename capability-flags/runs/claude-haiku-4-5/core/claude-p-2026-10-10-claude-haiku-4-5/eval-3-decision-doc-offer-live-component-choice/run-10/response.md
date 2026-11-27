Now I'll run the LLD-level edge-case probe and consistency verification, then present both for your review.

**LLD-level edge-case probe** — questions about state transitions and unstated invariants within the record-store design:

1. **Baseline and creation**: When a new visit is created (no prior revision), is `base_revision_id` null or a special sentinel? Can a submission later re-reference null, or does that become an error once the first revision exists?

2. **Reject boundaries**: When a base_revision_id is invalid (nonexistent, or refers to a different visit), should the server return a 4xx client error, or should it merge with all existing revisions as if submitted concurrently?

3. **Merging constraints**: When a coordinator merges competing revisions, can they introduce fields that appear in neither competing revision (e.g., a note not submitted by either worker)? Or is merge limited to selecting/combining fields from the submitted revisions?

4. **Clarification and retry**: After a coordinator issues a clarification request, if the field worker resubmits with a new base_revision_id (the clarification note's revision?), is the new submission treated as a fresh competing edit or as an answer to the clarification? Does the clarification flag clear, or do both the original unresolved revisions and the clarification remain visible?

5. **Submission ordering and concurrency windows**: The design relies on base_revision_id to detect true concurrency. If a tablet submits with base revision B, then learns of a later submission that was actually created before it left the device, does the ordering become a problem? Is there a time window after which base_revision_id mismatches are treated as obsolete rather than concurrent?

6. **Current state without resolution**: Between the time a conflict is detected and a coordinator resolves it, what does retrieval return if the caller asks for a usable current state (not the metadata)? The design says "latest (or coordinator-selected)" — what is "latest" in a conflict scenario?

**Post-draft consistency verification**:

- **Coverage**: The LLD describes submission envelope, current-state response, unresolved-work representation, and resolution types (accept, merge, clarify). Specs REC-001–013 cover submission/idempotency, revision creation, unresolved flagging, and resolution operations. All major behaviors are specified.
- **Contradiction**: No conflicts detected. Specs flow from the LLD's structure.
- **Implicit scoping**: All specs cite a specific context (authenticated worker, coordinator, unresolved revisions). Scopes are explicit.
- **Context-free reading**: Each spec reads independently; no reliance on surrounding section name or conversation context.

---

**STOP for user review.** Please address the edge-case probe questions above, and confirm the LLD and specs are ready to proceed. Do you want to adjust any of these behaviors before moving to Phase 4 (intent-narrowing edge audit)?