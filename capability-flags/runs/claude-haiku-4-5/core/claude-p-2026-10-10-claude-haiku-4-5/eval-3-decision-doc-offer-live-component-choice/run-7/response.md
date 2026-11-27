Now I'll present the updated design and specs for your review at the Phase 3 stop.

---

## Phase 3 Stop: Record-Store Design & EARS Specs

I've completed the record-store design with the whole-visit revisions approach and added the full contract specs. Here's what changed:

**Design Updates (record-store-design.md):**
- Replaced the open choice section with the complete specification of whole-visit revisions
- Defined the submission envelope (visit ID, base revision ID, author ID, idempotency key, payload, timestamp)
- Specified current-state representation (resolved vs. unresolved visits, what retrieval returns)
- Defined the resolution operation (coordinator selection or manual merge)
- Added forward contracts for tablet-sync and review-export

**New Specs (record-store-specs.md):**
- **REC-001 to REC-005**: Core submission & storage (with explicit handling of the null base for initial creation)
- **REC-010 to REC-015**: Current state & resolution status (marking visits resolved vs. unresolved, export eligibility)
- **REC-020 to REC-022**: Resolution operations (coordinator actions, immutability of resolved state)

**Consistency Report:**
- ✓ Coverage: All behaviors described in the LLD now have corresponding specs
- ✓ Contradiction: No conflicting specs found
- ✓ Scoping: All specs apply to the whole-visit revisions approach now selected
- ✓ Context-free: Each spec reads independently; baseline states and transitions are explicit

The design is ready. HLD and downstream node status have been updated. Proceed with drafting tablet-sync and review-export?