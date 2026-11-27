Now let me verify the consistency of the specs and present the Phase 2 & 3 output for your review.

## Phase 2 — LLD Update (Complete)

The record-store design has been updated with the whole-visit revisions approach. Key sections:

- **Submission**: Each submission carries its base-revision ID, complete observation state, idempotency key, author, and receipt timestamp.
- **Revision and Unresolved Work**: Submissions with matching base-revision IDs advance the current revision; stale submissions create competing revisions and mark the visit unresolved.
- **Retrieval**: Callers receive current state, revision ID, and unresolved flag.
- **Resolution**: Coordinators select a winner; all submissions are retained permanently.
- **Key Design Decisions**: One table documenting the whole-visit approach choice, its rationale (scientific integrity, no automatic merging), and its implications (review volume, revision comparison, base ID tracking).

**LLD-level edge-case probe:**
1. What happens if a submission arrives with a base-revision ID that no longer exists in history? → Spec gap: should the system reject it, treat it as stale, or require a minimum retention window? Recommend spec clarification.
2. What is the initial revision ID for a new visit with no prior submissions? → The first submission has a special case: base-revision would be null or "new." Recommend explicit spec for initial submissions.
3. Can a coordinator re-resolve a visit that was previously resolved? → Current specs do not address re-resolution. Recommend clarification: is resolution final, or can coordinators change their mind?

---

## Phase 3 — EARS Specs (Complete)

Specs have been expanded from 6 to 11 items, covering:
- **Submission** (REC-001 to REC-003): retention, idempotency retry, rejection on key collision
- **Revision Application** (REC-004 to REC-006): advancement, competing creation, revision ID format
- **Retrieval** (REC-007 to REC-008): current state with flags, full revision history
- **Resolution** (REC-009 to REC-011): coordinator selection, metadata recording, export eligibility

**Consistency verification:**

| Check | Result | Notes |
|---|---|---|
| **Coverage** | ✓ Pass | All LLD behaviors are specified. Three edge cases flagged above warrant clarification. |
| **Contradiction** | ✓ Pass | No conflicting specs. |
| **Implicit scoping** | ✓ Pass | All specs explicitly scope their conditions (e.g., "submission's base-revision matches," "when coordinator resolves"). |
| **Context-free reading** | ✓ Pass | Each spec is concrete; none rely on conversation context. |

**Gaps to resolve before proceeding:**
1. **Initial visit revision**: how is the base-revision ID specified for the first submission to a new visit?
2. **Non-existent base-revision**: if a submission references a base-revision that was never stored, should the system treat it as unresolvable or as stale?
3. **Resolution finality**: can a coordinator revise an earlier resolution, or is resolution outcome immutable?

---

## Next Steps

This design is now context-free and ready for implementation, pending your answers to the three gaps above. Once resolved, tablet-sync and review-export can proceed with their contracts fully defined. Please review the updated LLD and specs and indicate whether the design matches your intent or needs adjustment.