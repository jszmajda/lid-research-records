I've completed the record-store design by incorporating your whole-visit revisions choice. Here's what changed:

## Updated Sections

**Removed**: "Open Design Choice" section

**Added/Expanded**:

1. **Submission Envelope** — Complete specification of what tablets send: visit UUID, base revision ID, idempotency key, plot reference, observation fields, and species records as structured objects.

2. **Revision States and Storage** — Three states (resolved, unresolved, pending) with clear transition rules. Sequential integer revision IDs per visit for human-readable coordinator review.

3. **Retrieval Operations** — Three endpoints with JSON response schemas:
   - Get current state (returns competing revisions when unresolved)
   - Get submission history (for revision comparison)
   - Get unresolved visits (coordinator work queue)

4. **Resolution Operation** — POST endpoint where coordinators select a winning revision; records coordinator identity with the decision.

5. **Idempotency** — Retry handling: same payload returns original result, different payload rejects with 409 Conflict.

6. **Downstream Contracts** — Explicit obligations for tablet-sync (track base revision IDs, handle unresolved state) and review-export (exclude unresolved from exports, provide comparison UI).

7. **Decisions & Alternatives** — Records the choice with rationale: whole-visit revisions preserve scientific units and avoid merge rules that could silently combine related edits, accepting larger review queues as the trade.

The design now provides a complete contract that tablet-sync and review-export can build against. Each visit maintains full submission history, coordinators see competing whole-visit revisions side-by-side, and the Friday export contains only resolved visits.

**Review**: Does this specification capture what you need from the record store, or should any mechanism be adjusted before we move to EARS specs?