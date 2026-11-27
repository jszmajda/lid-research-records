The whole-visit record-store draft is ready for review in [record-store-design.md](docs/intent/record-store/record-store-design.md). I also updated the HLD’s dependency note to point to the selected contract.

### Proposed contract

Each submission contains a complete visit, its visit UUID, its base revision ID, and a retry key. The store preserves the payload, authenticated author, and receipt time as immutable history.

| Submission | Store outcome |
|---|---|
| First submission for a visit | Establish it as current |
| Edit based on current, with no unresolved work | Advance current |
| Edit based on another known revision | Preserve it as competing review work |
| Any valid edit while review is unresolved | Add it to the review set |

A competing revision makes the **entire visit ineligible for export**, including the previously current payload. Retrieval distinguishes that contextual current payload from an export candidate.

Coordinator resolution checks the visit’s state version and the complete reviewed set atomically. An intervening submission or coordinator decision requires a fresh review. Original submissions and resolution outcomes remain inspectable.

The Decisions & Alternatives table records your rationale: preserving scientifically related edits together and avoiding maintained merge rules outweigh the larger review queue. Tablet-sync and review-export obligations are recorded here for their later designs.

### Questions from the design probe

Please give numbered feedback on these choices:

1. **Resolution:** Can coordinators only select an existing revision, or also author a corrected complete visit? Selection-only is simpler; authoring can resolve cases where neither submission is acceptable.
2. **Corrections to pending submissions:** Should an earlier candidate remain separately reviewable after its author submits a correction, or become superseded while its history remains preserved? The draft retains both.
3. **Revision identity after resolution:** Should selecting an existing revision retain its ID, allowing offline edits based on it to advance current, or issue a fresh ID so pre-resolution edits return to review?
4. **Plot validation:** May a correction change the visit’s plot UUID? May a new offline submission reference a plot archived since the tablet downloaded its catalog?
5. **Review selection:** May a coordinator choose any historical revision, or only one of the competing candidates?
6. **Retry handling:** Should an accepted retry always replay its receipt before checking current plot validity or review preconditions? The contract also needs cross-visit uniqueness for worker-scoped retry keys.
7. **Remaining contract details:** Worker access to others’ visits, validation limits, error precedence, and history ordering are explicit open questions. Which should be settled now, and which may remain deferred?

**Decision-record option:** This choice has credible competing tradeoffs and shapes two downstream designs. Would you like a standalone decision document, or keep the rationale in the existing Decisions & Alternatives row?

The existing EARS remain the baseline. Their next update needs to clarify that retry equality covers the full envelope—not just the scientific payload—and capture the new transitions. `git diff --check` passed.

Please review the draft and triage these gaps; I’ll stop at this design boundary before updating EARS.