Now I'll address the edge-case probe questions with clear answers based on the completed design:

---

## Addressing the Edge-Case Probe

**1. Baseline and creation**: When a new visit is created, `base_revision_id` is null. Once the first revision exists, subsequent submissions must reference an actual revision ID — null is not accepted. This constrains the namespace and prevents confusion about whether null means "create" or "build on nothing." This should be made explicit in REC-004.

**2. Reject boundaries**: REC-004 already covers this — invalid or non-existent base_revision_id causes rejection. Submissions that reference a revision from a different visit also fail.

**3. Merging constraints**: A coordinator performing a merge manually author the merged payload. The design should clarify: **merges are constrained to fields present in at least one competing revision**, so the audit trail remains unbroken. A coordinator cannot introduce a field that neither worker submitted. This preserves the requirement that all field values trace back to a submission.

**4. Clarification and retry**: When a coordinator issues a clarification request, the visit remains unresolved. If the field worker resubmits, they face a choice: submit with their prior base revision ID (creating a third competing revision) or submit with a new base that acknowledges the clarification (e.g., a "clarification acknowledged" revision the server creates in response to the request, which the worker then edits). The current design does not specify this flow. **Recommendation**: Clarification should resolve the visit to a `clarification_requested` state (not unresolved), and the field worker's next submission with the clarification resolution as the base counts as resolving the original request, not creating a new competing revision.

**5. Submission ordering and concurrency windows**: There is no concurrency window. A submission with base revision B is valid whenever it arrives, even if it was created offline days ago. It will correctly create a competing revision against any other submission with the same base. Tablets track the base revision ID for each local draft, so workers always know what their submission references. No reordering problem arises because the revision graph is implicit in the base_revision_id references, not in arrival order.

**6. Current state without resolution**: REC-007 and REC-008 answer this: when unresolved competing revisions exist, retrieval returns `has_unresolved_revisions: true` and the metadata for all competing revisions (author, submission time, base_revision_id, submitted payload). The caller gets the full set for comparison, not a "latest" single state. Only after a coordinator resolves does a single current state exist.

---

**Minor spec clarifications needed:**

- REC-004 should explicitly state: base_revision_id must be either null (visit creation only) or an existing revision ID for the same visit.
- Add REC-014: When a coordinator requests clarification, the visit enters a `clarification_requested` state. A subsequent submission by the field worker with the clarification revision as base resolves the clarification request and creates a new competing revision set if the new submission differs from the original unresolved submissions.
- REC-010 should clarify: merged fields must be a combination of fields from the competing submissions; coordinators cannot introduce new fields.

Would you like me to update the specs with these clarifications, or shall we proceed with Phase 4 (intent-narrowing edge audit) as-is?