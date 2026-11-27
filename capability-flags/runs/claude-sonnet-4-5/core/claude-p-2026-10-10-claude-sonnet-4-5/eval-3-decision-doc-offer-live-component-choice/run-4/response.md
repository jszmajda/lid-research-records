Now I'll run an LLD-level edge-case probe to check for gaps in the design:

**Edge cases for record-store mechanisms:**

1. **Multiple revisions from same base**: What happens when worker A submits based on revision 1, creating revision 2, and then worker B also submits based on revision 1, creating revision 3? (Both accepted, both compete, seems clear from the design.)

2. **Initial submission state**: When exactly one revision exists (the initial submission with `baseRevisionId: null`), is the visit's state `resolved` or `unresolved`? The design says unresolved state occurs when "concurrent edits occur," but doesn't specify the single-revision case.

3. **Base revision validation**: What happens if a submission arrives with a `baseRevisionId` that doesn't exist for that visit? Is this accepted (creating a revision anyway) or rejected (invalid base)?

4. **Resolution of already-resolved visit**: What happens if a coordinator attempts to resolve a visit that's already in `resolved` state? Is this a no-op, an error, or does it update the selected revision and record a new resolution?

5. **Idempotency key collision across visits**: What happens if the same idempotency key is used for different visit IDs? The design says "repeats an accepted idempotency key" but doesn't specify whether keys are scoped to a visit ID or globally unique.

6. **Empty competing revisions after resolution**: After resolution, what happens to the `unresolvedRevisionIds` field? Does it become an empty array, or is the field omitted entirely?

7. **Revision history retrieval scope**: The design mentions "revision-history operations" but doesn't specify what these operations are or what they return. What's the contract?

8. **Coordinator identity validation**: Is there any validation of `coordinatorId`, or can any authenticated user act as a coordinator?

Which of these gaps should I address in the LLD before moving to EARS specs? Some might be intentionally deferred to implementation.